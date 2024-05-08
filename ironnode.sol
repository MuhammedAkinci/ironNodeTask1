// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
   

    bool private _paused;
    event Paused(address account);
    event Unpaused(address account);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);
    

    constructor(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(msg.sender, initialSupply);
    }

    function pause() external onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {

        _mint(account, amount);
        emit Mint(account, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        require(!_paused || _msgSender() == owner(), "Token transfers are paused");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        require(!_paused || _msgSender() == owner(), "Token transfers are paused");
        return super.transferFrom(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        require(!_paused || _msgSender() == owner(), "Token approvals are paused");
        return super.approve(spender, amount);
    }

    function paused() external view returns (bool) {
        return _paused;
    }
}
