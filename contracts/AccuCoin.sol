// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccuCoin is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    mapping(address => bool) private _isWhitelisted;

    constructor() ERC20("ACCU COIN", "ACCU") {
        // Granting  the contract deployer default admin role: it will be able
        // to grant and revoke any roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice This function is to mint tokens to an address
     * @dev Only MINTER_ROLE can call this function
     * @param to Address to which tokens will be minted
     * @param amount Amount of tokens to be minted
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @notice View function to check if an address is whitelisted to transfer tokens
     * @param _address Address of the wallet
     */
    function isWhitelisted(address _address) external view returns (bool) {
        return _isWhitelisted[_address];
    }

    /**
     * @notice Function to add an address to transfer whitelist
     * @dev Only DEFAULT_ADMIN can call this function
     * @param _address Address of the wallet
     */
    function addToWhitelist(
        address _address
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _isWhitelisted[_address] = true;
    }

    /**
     * @notice Function to remove an address from transfer whitelist
     * @dev Only DEFAULT_ADMIN can call this function
     * @param _address Address of the wallet
     */
    function removeFromWhitelist(
        address _address
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _isWhitelisted[_address] = false;
    }

    /**
     * @notice Function to add MINTER_ROLE to an address
     * @dev Only DEFAULT_ADMIN can call this function
     * @param _address Address of the wallet
     */
    function addMinterRole(
        address _address
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, _address);
    }

    /**
     * @notice Function to revoke MINTER_ROLE from an address
     * @dev Only DEFAULT_ADMIN can call this function
     * @param _address Address of the wallet
     */
    function revokeMinterRole(
        address _address
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, _address);
    }

    /**
     * @notice Hook function that is called before any token actions involving a Transfer
     * @param from Address to transfer tokens from
     * @param to Address to which tokens are transferred
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal override {
        if (from != address(0))
            require(
                _isWhitelisted[from] || _isWhitelisted[to],
                "AccuCoin: only whitelisted can transfer"
            );
    }
}
