// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol"; // Import the LiquidityPool contract

contract LiquidityPoolFactory {
    address public owner; // Owner of the factory contract
    address[] public allPools; // Array to store all created pools

    event PoolCreated(address indexed poolAddress, address indexed creator);

    constructor() {
        owner = msg.sender; // Set the deployer as the owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
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
            msg.sender // Set the factory owner as the pool owner
        );

        allPools.push(address(newPool)); // Store the address of the new pool
        emit PoolCreated(address(newPool), msg.sender); // Emit event
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
}
