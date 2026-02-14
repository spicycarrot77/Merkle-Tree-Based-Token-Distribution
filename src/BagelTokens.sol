//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//this is the ERC20 token we will air drop to a list of addresses

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract BagelToken is ERC20, Ownable {
    constructor() ERC20("Bagel Token", "BT") Ownable(msg.sender) {
        //Ownable(msg.sender) this signifies whoever deploys this contract
        //becomes the owner
    }
//only the user who deploys this contract (the owner) can mint new tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}