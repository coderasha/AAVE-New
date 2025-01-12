// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./LendingHub.sol";

contract TokenPool is ReentrancyGuard {
    LendingHub public lendingHub;
    address public token;
    address public owner;

    uint256 public ltv;
    uint256 public depositRate;
    uint256 public borrowRate;

    struct User {
        uint256 collateral;
        uint256 debt;
    }

    mapping(address => User) public users;

    event LiquidityAdded(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Liquidated(address indexed liquidator, address indexed user, uint256 debtRepaid, uint256 collateralSeized);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, address _owner, address _lendingHub) {
        token = _token;
        owner = _owner;
        lendingHub = LendingHub(_lendingHub);
    }

    function setLTV(uint256 _ltv) external onlyOwner {
        require(_ltv <= 100, "Invalid LTV");
        ltv = _ltv;
    }

    function setInterestRates(uint256 _depositRate, uint256 _borrowRate) external onlyOwner {
        depositRate = _depositRate;
        borrowRate = _borrowRate;
    }

    function deposit(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Invalid amount");

        uint256 collateralValue = (_amount * getPrice()) / 1e18;
        users[msg.sender].collateral += _amount;
        lendingHub.updateCollateral(msg.sender, int256(collateralValue));
        emit LiquidityAdded(msg.sender, _amount);
    }

    function borrow(uint256 _amount) external nonReentrant {
        uint256 borrowValue = (_amount * getPrice()) / 1e18;

        // Retrieve user information from LendingHub contract
        (uint256 totalCollateralValue, ) = lendingHub.users(msg.sender);

        // Check borrowing limits
        require(borrowValue <= (users[msg.sender].collateral * ltv) / 100, "Exceeds pool borrowing limit");
        require(borrowValue <= (totalCollateralValue * ltv) / 100, "Exceeds global borrowing limit");

        users[msg.sender].debt += borrowValue;
        lendingHub.updateDebt(msg.sender, int256(borrowValue));
        emit Borrowed(msg.sender, _amount);
    }

    function repay(uint256 _amount) external nonReentrant {
        uint256 debtValue = (_amount * getPrice()) / 1e18;
        require(debtValue <= users[msg.sender].debt, "Repay exceeds debt");

        users[msg.sender].debt -= debtValue;
        lendingHub.updateDebt(msg.sender, -int256(debtValue));
        emit Repaid(msg.sender, _amount);
    }

    function withdrawCollateral(uint256 _amount) external nonReentrant {
        uint256 collateralValue = (_amount * getPrice()) / 1e18;

        // Retrieve user information from LendingHub contract
        (uint256 totalCollateralValue, ) = lendingHub.users(msg.sender);

        require(collateralValue <= totalCollateralValue, "Exceeds collateral");
        require(lendingHub.calculateHealthFactor(msg.sender) > 1e18, "Health factor too low");

        users[msg.sender].collateral -= _amount;
        lendingHub.updateCollateral(msg.sender, -int256(collateralValue));
        emit CollateralWithdrawn(msg.sender, _amount);
    }

    function liquidate(address _user) external nonReentrant {
        uint256 healthFactor = lendingHub.calculateHealthFactor(_user);
        require(healthFactor < 1e18, "Health factor too high");

        uint256 debtValue = users[_user].debt;
        uint256 collateralValue = (users[_user].collateral * getPrice()) / 1e18;
        uint256 liquidationBonus = lendingHub.liquidationBonuses(token);
        uint256 collateralSeized = (debtValue * (100 + liquidationBonus)) / 100;

        if (collateralSeized > collateralValue) {
            collateralSeized = collateralValue;
        }

        users[_user].debt -= debtValue;
        users[_user].collateral -= (collateralSeized * 1e18) / getPrice();
        lendingHub.updateDebt(_user, -int256(debtValue));
        lendingHub.updateCollateral(_user, -int256((collateralSeized * 1e18) / getPrice()));

        emit Liquidated(msg.sender, _user, debtValue, collateralSeized);
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = lendingHub.priceFeeds(token);
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return uint256(price);
    }
}
