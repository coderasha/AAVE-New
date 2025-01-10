// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

// Factory Contract
contract LiquidityPoolFactory {
    address public owner;
    address[] public allPools;

    event PoolCreated(address indexed poolAddress, address indexed creator);

    error OnlyOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPool(
        address collateralToken,
        address debtToken,
        address collateralPriceFeed,
        address debtPriceFeed,
        uint256 depositInterestRate,
        uint256 borrowInterestRate,
        uint256 ltvRatio,
        uint256 liquidationThreshold,
        uint256 liquidationBonus
    ) external onlyOwner {
        LiquidityPool newPool = new LiquidityPool(
            collateralToken,
            debtToken,
            collateralPriceFeed,
            debtPriceFeed,
            depositInterestRate,
            borrowInterestRate,
            ltvRatio,
            liquidationThreshold,
            liquidationBonus,
            msg.sender
        );

        allPools.push(address(newPool));
        emit PoolCreated(address(newPool), msg.sender);
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
}
