//SPDX-LICENSE-IDENTIFIER: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20{
    address public owner;
    
    constructor(uint initialSupply) ERC20 ("CustomToken", "CT"){
        owner = msg.sender;
        _mint(owner, initialSupply * 10 ** 18);
    }
    
}