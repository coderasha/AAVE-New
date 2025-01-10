// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol@v0.8.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.3.3

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.3.3

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.3.3

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File contracts/LiquidityPoolFactory.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;




// Liquidity Pool Contract
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

    function addLiquidity(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert InvalidAmount();
        IERC20(debtToken).transferFrom(msg.sender, address(this), amount);
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
