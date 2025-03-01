// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    address public immutable USDC;
    address public immutable USDT;
    address public immutable DAI;

    address public immutable owner;
    address public immutable developer;
    string public savingPurpose;
    uint256 public lockDuration;
    uint256 public createdAt;

    uint256 public constant PENALTY_PERCENT = 15;

    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Deposit) public deposits;

    // Custom errors for gas efficiency
    error InvalidToken();
    error InsufficientBalance();
    error LockPeriodActive();
    error TransferFailed();
    error AlreadyWithdrawn();
    error ZeroDeposit();

    event Deposited(address indexed user, address indexed token, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, address indexed token, uint256 amount, bool penalized);
    event EmergencyWithdraw(address indexed user, uint256 amount, uint256 penalty);

    constructor(
        address _usdc,
        address _usdt,
        address _dai,
        address _owner,
        address _developer,
        string memory _savingPurpose,
        uint256 _lockDuration
    ) {
        USDC = _usdc;
        USDT = _usdt;
        DAI = _dai;
        owner = _owner;
        developer = _developer;
        savingPurpose = _savingPurpose;
        lockDuration = _lockDuration;
        createdAt = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit(address token, uint256 amount) external onlyOwner {
        if (token != USDC && token != USDT && token != DAI) revert InvalidToken();
        if (amount == 0) revert ZeroDeposit();

        uint256 unlockTime = block.timestamp + lockDuration;
        deposits[token] = Deposit({amount: deposits[token].amount + amount, unlockTime: unlockTime});

        if (!IERC20(token).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        emit Deposited(msg.sender, token, amount, unlockTime);
    }

    function withdraw(address token) external onlyOwner {
        Deposit storage userDeposit = deposits[token];
        if (userDeposit.amount == 0) revert InsufficientBalance();

        uint256 amount = userDeposit.amount;
        // uint256 penalty = 0;
        bool penalized = false;

        if (block.timestamp < userDeposit.unlockTime) {
            revert LockPeriodActive();
        }

        delete deposits[token];

        if (!IERC20(token).transfer(msg.sender, amount)) revert TransferFailed();

        emit Withdrawn(msg.sender, token, amount, penalized);
    }

    /// @notice Emergency withdraw with 15% penalty
    function emergencyWithdraw(address token) external onlyOwner {
        Deposit storage userDeposit = deposits[token];
        if (userDeposit.amount == 0) revert InsufficientBalance();

        uint256 amount = userDeposit.amount;
        uint256 penalty = (amount * PENALTY_PERCENT) / 100;
        uint256 finalAmount = amount - penalty;

        delete deposits[token];

        if (!IERC20(token).transfer(developer, penalty)) revert TransferFailed();
        if (!IERC20(token).transfer(msg.sender, finalAmount)) revert TransferFailed();

        emit EmergencyWithdraw(msg.sender, finalAmount, penalty);
    }

    function isWithdrawn() external view returns (bool) {
        return deposits[USDC].amount == 0 && deposits[USDT].amount == 0 && deposits[DAI].amount == 0;
    }
}