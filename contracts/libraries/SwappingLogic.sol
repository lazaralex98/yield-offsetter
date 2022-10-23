// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IUniswapV2Router02} from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Errors} from './Errors.sol';

/// @title SwappingLogic
library SwappingLogic {
    address public constant SWAP_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address public constant NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
    address public constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    IUniswapV2Router02 private constant ROUTER = IUniswapV2Router02(SWAP_ROUTER);

    /// @notice Swaps an amount `amountIn` of `from` tokens for NCT
    /// @dev Makes external calls to the swap router
    /// @param amountIn Amount of `from` tokens to swap
    /// @param from Address of the token to swap from
    /// @return amountOut Amount of NCT received
    function swapToCarbon(uint256 amountIn, address from) external returns (uint256 amountOut) {
        (address[] memory path, uint256[] memory amounts) = calculateSwap(amountIn, from);
        uint256 len = path.length;

        bool approved = IERC20(from).approve(SWAP_ROUTER, amounts[0]);
        require(approved, Errors.G_APPROVAL_FAILED);

        uint256[] memory receivedAmounts = ROUTER.swapExactTokensForTokens(
            amounts[0],
            amounts[len - 1],
            path,
            address(this),
            block.timestamp
        );
        return receivedAmounts[len - 1];
    }

    /// @notice Calculates the amount of NCT that will be received from swapping `amountIn` of `from` tokens
    /// @dev Makes external calls to the swap router
    /// @param amountIn The amount of `from` tokens to swap
    /// @param from The token to swap from
    /// @return path The path of tokens to swap through
    /// @return amounts The amounts of tokens to swap at each path step
    function calculateSwap(uint256 amountIn, address from)
        public
        view
        returns (address[] memory path, uint256[] memory amounts)
    {
        path = buildPath(from);
        amounts = ROUTER.getAmountsOut(amountIn, path);
        require(path.length == amounts.length, Errors.G_ARRAYS_NOT_SAME_LENGTH);
    }

    /// @notice Builds the path to be used for swapping `from` to NCT
    /// @param from The token to swap from
    /// @return path The path to be used for swapping
    function buildPath(address from) public pure returns (address[] memory) {
        if (from == USDC) {
            address[] memory path = new address[](2);
            path[0] = USDC;
            path[1] = NCT;
            return path;
        } else {
            address[] memory path = new address[](3);
            path[0] = from;
            path[1] = USDC;
            path[2] = NCT;
            return path;
        }
    }
}
