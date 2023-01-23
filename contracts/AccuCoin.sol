// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AccuCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20("ACCU COIN", "ACCU") {
        _mint(msg.sender, initialSupply);
    }
}
