// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAccuCoin is IERC20 {
    function mint(address, uint256) external;
}
