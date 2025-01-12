// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract LendingHub is Ownable, ReentrancyGuard {
    struct User {
        uint256 totalCollateralValue;
        uint256 totalDebtValue;
    }

    mapping(address => User) public users;
    mapping(address => bool) public tokenPools;
    mapping(address => AggregatorV3Interface) public priceFeeds;
    mapping(address => uint256) public liquidationBonuses;

    event TokenPoolRegistered(address indexed pool);
    event CollateralUpdated(address indexed user, uint256 totalCollateralValue);
    event DebtUpdated(address indexed user, uint256 totalDebtValue);
    event LiquidationBonusUpdated(address indexed token, uint256 bonus);

    modifier onlyPool() {
        require(tokenPools[msg.sender], "Caller is not a registered pool");
        _;
    }

    /// @dev Constructor explicitly passes `initialOwner` to the `Ownable` constructor.
    constructor(address initialOwner) Ownable(initialOwner) {
        // Additional constructor logic if needed
    }

    function registerTokenPool(address pool) external onlyOwner {
        require(!tokenPools[pool], "Pool already registered");
        tokenPools[pool] = true;
        emit TokenPoolRegistered(pool);
    }

    function setPriceFeed(address token, address feed) external onlyOwner {
        priceFeeds[token] = AggregatorV3Interface(feed);
    }

    function setLiquidationBonus(address token, uint256 bonus) external onlyOwner {
        require(bonus <= 50, "Bonus too high");
        liquidationBonuses[token] = bonus;
        emit LiquidationBonusUpdated(token, bonus);
    }

    function updateCollateral(address user, int256 collateralValue) external onlyPool {
        User storage userData = users[user];
        require(int256(userData.totalCollateralValue) + collateralValue >= 0, "Invalid collateral value");
        userData.totalCollateralValue = uint256(int256(userData.totalCollateralValue) + collateralValue);
        emit CollateralUpdated(user, userData.totalCollateralValue);
    }

    function updateDebt(address user, int256 debtValue) external onlyPool {
        User storage userData = users[user];
        require(int256(userData.totalDebtValue) + debtValue >= 0, "Invalid debt value");
        userData.totalDebtValue = uint256(int256(userData.totalDebtValue) + debtValue);
        emit DebtUpdated(user, userData.totalDebtValue);
    }

    function getPrice(address token) public view returns (uint256) {
        AggregatorV3Interface priceFeed = priceFeeds[token];
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return uint256(price);
    }

    function calculateHealthFactor(address user) public view returns (uint256) {
        User memory userInfo = users[user];
        if (userInfo.totalDebtValue == 0) return type(uint256).max;
        return (userInfo.totalCollateralValue * 1e18) / userInfo.totalDebtValue;
    }
}
