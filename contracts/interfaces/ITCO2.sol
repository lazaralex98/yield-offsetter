// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import {IERC721Receiver} from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

interface ITCO2 is IERC20Upgradeable, IERC721Receiver {
    function retire(uint256 amount) external returns (uint256 retirementEventId);
}
