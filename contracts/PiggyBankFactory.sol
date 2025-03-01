// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./PiggyBank.sol"; // Ensure PiggyBank.sol is in the same directory

contract PiggyBankFactory {
    struct BankInfo {
        address bankAddress;
        string savingPurpose;
    }

    address public immutable USDC;
    address public immutable USDT;
    address public immutable DAI;
    address public immutable developer;

    mapping(address => BankInfo[]) public userBanks;

    event PiggyBankCreated(address indexed owner, address piggyBank, string savingPurpose);

    constructor(address _usdc, address _usdt, address _dai, address _developer) {
        USDC = _usdc;
        USDT = _usdt;
        DAI = _dai;
        developer = _developer;
    }

    function createPiggyBank(string memory _savingPurpose, uint256 _lockDuration) external {
        PiggyBank newBank = new PiggyBank(
            USDC,
            USDT,
            DAI,
            msg.sender,
            developer,
            _savingPurpose,
            _lockDuration
        );

        userBanks[msg.sender].push(BankInfo(address(newBank), _savingPurpose));

        emit PiggyBankCreated(msg.sender, address(newBank), _savingPurpose);
    }

    function getUserBanks(address user) external view returns (BankInfo[] memory) {
        return userBanks[user];
    }
}