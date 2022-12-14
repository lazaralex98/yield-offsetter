// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

/**
 * @title Errors library
 * @notice Defines the error messages emitted by the different contracts
 * @dev Error messages prefix glossary:
 *  - F = YieldOffseterFactory
 *  - V = YieldOffseterVault
 *  - SW = SwappingLogic
 *  - RE = RetirementLogic
 *  - G = General / Global
 */
library Errors {
    /// User already has a vault
    string public constant F_ALREADY_HAVE_VAULT = '1';
    /// User is not the vault owner
    string public constant V_NOT_VAULT_OWNER = '2';
    /// User has not deposited enough
    string public constant V_NOT_ENOUGH_DEPOSITED = '3';
    /// Approval failed
    string public constant G_APPROVAL_FAILED = '4';
    /// Arrays do not have the same length
    string public constant G_ARRAYS_NOT_SAME_LENGTH = '5';
    /// User doesn't have enough NCT to retire
    string public constant R_INSUFFICIENT_NCT = '6';
    /// Amount provided cannot be 0
    string public constant G_AMOUNT_ZERO = '7';
    /// User doesn't have enough yield to offset that much
    string public constant V_NOT_ENOUGH_YIELD = '8';
    /// User doesn't have enough invested to withdraw that much
    string public constant V_NOT_ENOUGH_INVESTED = '9';
    /// User doesn't have enough balance in the vault to withdraw that much
    string public constant V_NOT_ENOUGH_BALANCE = '10';
}
