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
}
