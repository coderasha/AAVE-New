// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract LiquidityPool is ReentrancyGuard {
    using SafeMath for uint256;

    address public owner;
    address public collateralToken;
    address public debtToken;
    AggregatorV3Interface public collateralPriceFeed;
    AggregatorV3Interface public debtPriceFeed;

    uint256 public depositInterestRate;
    uint256 public borrowInterestRate;
    uint256 public ltvRatio;
    uint256 public liquidationThreshold;
    uint256 public liquidationBonus;

    struct User {
        uint256 collateralBalance;
        uint256 debtBalance;
        uint256 depositTimestamp;
        uint256 accruedInterest;
    }

    mapping(address => User) public users;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed borrower, uint256 repaidAmount, uint256 collateralSeized);
    event WithdrawInterest(address indexed user, uint256 interestAmount);
    event LiquidityProvided(address indexed owner, uint256 amount);

    error OnlyOwner();
    error InvalidAmount();
    error InsufficientCollateral();
    error UndercollateralizedPosition();
    error NoInterestToWithdraw();

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    constructor(
        address _collateralToken,
        address _debtToken,
        address _collateralPriceFeed,
        address _debtPriceFeed,
        uint256 _depositInterestRate,
        uint256 _borrowInterestRate,
        uint256 _ltvRatio,
        uint256 _liquidationThreshold,
        uint256 _liquidationBonus,
        address _owner
    ) {
        collateralToken = _collateralToken;
        debtToken = _debtToken;
        collateralPriceFeed = AggregatorV3Interface(_collateralPriceFeed);
        debtPriceFeed = AggregatorV3Interface(_debtPriceFeed);
        depositInterestRate = _depositInterestRate;
        borrowInterestRate = _borrowInterestRate;
        ltvRatio = _ltvRatio;
        liquidationThreshold = _liquidationThreshold;
        liquidationBonus = _liquidationBonus;
        owner = _owner;
    }

    function deposit(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();
        IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);

        User storage user = users[msg.sender];
        _updateDepositInterest(msg.sender);

        user.collateralBalance = user.collateralBalance.add(amount);
        user.depositTimestamp = block.timestamp;

        emit Deposit(msg.sender, amount);
    }

    function borrow(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();

        User storage user = users[msg.sender];
        uint256 collateralValue = calculateCollateralValue(msg.sender);
        uint256 maxBorrowable = collateralValue.mul(ltvRatio).div(10000);

        if (user.debtBalance.add(amount) > maxBorrowable) revert InsufficientCollateral();

        user.debtBalance = user.debtBalance.add(amount);
        IERC20(debtToken).transfer(msg.sender, amount);

        emit Borrow(msg.sender, amount);
    }

    function repay(uint256 amount) external nonReentrant {
        if (amount == 0) revert InvalidAmount();

        User storage user = users[msg.sender];
        if (user.debtBalance < amount) revert InvalidAmount();

        IERC20(debtToken).transferFrom(msg.sender, address(this), amount);
        user.debtBalance = user.debtBalance.sub(amount);

        emit Repay(msg.sender, amount);
    }

    function liquidate(address borrower) external nonReentrant {
        User storage user = users[borrower];
        uint256 collateralValue = calculateCollateralValue(borrower);
        uint256 borrowedValue = calculateBorrowedValue(borrower);

        if (collateralValue.mul(liquidationThreshold).div(10000) >= borrowedValue)
            revert UndercollateralizedPosition();

        uint256 maxRepayable = borrowedValue.div(2);
        uint256 collateralSeized = maxRepayable.mul(10000 + liquidationBonus).div(10000);

        IERC20(debtToken).transferFrom(msg.sender, address(this), maxRepayable);
        IERC20(collateralToken).transfer(msg.sender, collateralSeized);

        user.debtBalance = user.debtBalance.sub(maxRepayable);
        user.collateralBalance = user.collateralBalance.sub(collateralSeized);

        emit Liquidate(msg.sender, borrower, maxRepayable, collateralSeized);
    }

    function withdrawInterest() external nonReentrant {
        User storage user = users[msg.sender];
        _updateDepositInterest(msg.sender);

        uint256 interestToWithdraw = user.accruedInterest;
        if (interestToWithdraw == 0) revert NoInterestToWithdraw();

        user.accruedInterest = 0;
        IERC20(debtToken).transfer(msg.sender, interestToWithdraw);

        emit WithdrawInterest(msg.sender, interestToWithdraw);
    }

    function provideDebtLiquidity(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert InvalidAmount();

        IERC20(debtToken).transferFrom(msg.sender, address(this), amount);

        emit LiquidityProvided(msg.sender, amount);
    }

    function _updateDepositInterest(address userAddress) internal {
        User storage user = users[userAddress];
        uint256 newInterest = calculateDepositInterest(userAddress);
        user.accruedInterest = user.accruedInterest.add(newInterest);
        user.depositTimestamp = block.timestamp;
    }

    function calculateCollateralValue(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        uint256 collateralAmount = user.collateralBalance;
        (, int256 price, , , ) = collateralPriceFeed.latestRoundData();
        return collateralAmount.mul(uint256(price)).div(10**collateralPriceFeed.decimals());
    }

    function calculateBorrowedValue(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        uint256 debtAmount = user.debtBalance;
        (, int256 price, , , ) = debtPriceFeed.latestRoundData();
        return debtAmount.mul(uint256(price)).div(10**debtPriceFeed.decimals());
    }

    function calculateDepositInterest(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        uint256 timeElapsed = block.timestamp.sub(user.depositTimestamp);
        uint256 annualInterest = user.collateralBalance.mul(depositInterestRate).div(10000);
        return annualInterest.mul(timeElapsed).div(365 days);
    }

    function updateInterestRates(uint256 _depositInterestRate, uint256 _borrowInterestRate) external onlyOwner {
        depositInterestRate = _depositInterestRate;
        borrowInterestRate = _borrowInterestRate;
    }
}
