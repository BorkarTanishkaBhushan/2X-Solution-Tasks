// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract CustomToken{

    //uint bytes mapping

    // @notice Mapping: user => balance
    mapping(address => uint256) private balances;

    // @notice Mapping:addressWithAllowance => user => balance
    mapping(address => mapping(address => uint256)) private allowances;

    address public owner;
    uint256 public totalSupply;
    string public name;
    string public symbol;

    event Transferred(address to, uint amount);
    event TransferredFrom(address from, address to, uint amount);

    /*
    * @dev sets the owner, token's name, symbol and totalSupply
    */
    constructor(string memory _name, string memory _symbol, uint _totalSupply){
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * 10 ** 18;
        owner = msg.sender;
    }

    function mintCustomToken(address receiver, uint amount) onlyOwner public{
        balances[receiver] += amount;
    }

    function balanceOf(address user) public view returns(uint256){
        return (balances[user]);
    }

    function transfer(address to, uint256 amt) public returns (bool) {
        require( amt > balanceOf(msg.sender), "Insufficient Balance");
        balances[msg.sender] -= amt;
        balances[to] += amt;
        emit Transferred(to, amt);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }




}