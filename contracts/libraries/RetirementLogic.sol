// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Errors} from './Errors.sol';
import {IToucanPool} from '../interfaces/IToucanPool.sol';
import {ITCO2} from '../interfaces/ITCO2.sol';

/// @title RetirementLogic
library RetirementLogic {
    address public constant NCT = 0xD838290e877E0188a4A44700463419ED96c16107;

    IToucanPool private constant POOL = IToucanPool(NCT);

    /// @notice Retires `amount` of TCO2 tokens
    /// @dev Requires caller to have NCT tokens
    /// @param amount Amount of TCO2 tokens to retire
    /// @return retirementEventIds The IDs of the retirement events
    function redeemAndRetire(uint256 amount) external returns (uint256[] memory) {
        require(POOL.balanceOf(address(this)) >= amount, Errors.R_INSUFFICIENT_NCT);

        (address[] memory tco2s, uint256[] memory amounts) = IToucanPool(NCT).redeemAuto2(amount);

        uint256 eventId;

        uint256 len = tco2s.length;

        uint256[] memory retirementEventIds = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            eventId = ITCO2(tco2s[i]).retire(amounts[i]);
            retirementEventIds[i] = eventId;
        }

        return retirementEventIds;
    }
}
