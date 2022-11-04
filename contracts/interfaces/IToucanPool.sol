// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';

interface IToucanPool is IERC20Upgradeable {
    function redeemAuto2(uint256 amount)
        external
        returns (address[] memory tco2s, uint256[] memory amounts);
}
