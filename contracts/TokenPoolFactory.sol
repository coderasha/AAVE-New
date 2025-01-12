// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TokenPool.sol";
import "./LendingHub.sol";

contract TokenPoolFactory is Ownable {
    LendingHub public lendingHub;

    event TokenPoolCreated(address indexed token, address pool, address owner);

    constructor(address initialOwner, address _lendingHub) Ownable(initialOwner) {
        lendingHub = LendingHub(_lendingHub);
    }

    function createTokenPool(address token, address priceFeed) external onlyOwner {
        // Deploy a new TokenPool instance
        TokenPool pool = new TokenPool(token, msg.sender, address(lendingHub));
        
        // Register the new pool in the LendingHub contract
        lendingHub.registerTokenPool(address(pool));
        
        // Set the price feed using a low-level call to avoid direct ABI mismatch
        (bool success, ) = address(pool).call(
            abi.encodeWithSignature("setPriceFeed(address)", priceFeed)
        );
        require(success, "Failed to set price feed");

        emit TokenPoolCreated(token, address(pool), msg.sender);
    }
}
