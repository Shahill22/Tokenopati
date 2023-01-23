// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccuCoin is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(uint256 initialSupply) ERC20("ACCU COIN", "ACCU") {
        // Granting  the contract deployer default admin role: it will be able
        // to grant and revoke any roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function addWhitelist(
        address _address
    ) public onlyRole("DEFAULT_ADMIN_ROLE") {
        _grantRole(MINTER_ROLE, _address);
    }

    function revokeWhitelist(
        address _address
    ) public onlyRole("DEFAULT_ADMIN_ROLE") {
        _revokeRole(MINTER_ROLE, _address);
    }
}
