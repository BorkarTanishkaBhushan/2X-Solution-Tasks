//SPDX-LICENSE-IDENTIFIER: MIT
pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Task1.sol";

contract TokenVendor is Ownable{
    Token public token;
    event BuyCT(address user, uint256 tokenAmt);
    event SellCT(address user, uint256 tokenAmt);
    uint256 public constant buyTax = 10; // 10% tax on buy
    uint256 public constant sellTax = 5; // 5% tax on sell

    uint256 public constant tokensPerEth = 100; //change uint256 size later @note gas optimize later

    constructor(address tokenContractAddress, address initialOwner) Ownable(initialOwner) {
        token = Token(tokenContractAddress);
    }

    //buy token function
    function buyToken() public payable{
        require(msg.value > 0, "100 CT = 1 ETH");
        address user = msg.sender;
        uint256 ethAmt = msg.value;
        uint256 tokenAmt = ethAmt * tokensPerEth;
        uint256 tax = ethAmt * buyTax / 100;

        uint256 tokenVendorBalance = token.balanceOf(address(this));
        require(tokenVendorBalance >= tokenAmt, "Vendor does not have enough tokens");

        (bool sent) = token.transfer(user, tokenAmt - tax);
        require(sent, "Failed to buy CT");
        emit BuyCT(user, tokenAmt);

        // send tax to owner
        (sent,) = msg.sender.call{value: tax}("");
        require(sent, "Failed to send tax to owner");
    }

    function withdraw() public onlyOwner {
        uint256 ownerEthBalance = address(this).balance;
        require(ownerEthBalance > 0, "Owner has not balance to withdraw");
        uint256 fee = ownerEthBalance * sellTax / 100;
        uint256 amount = ownerEthBalance - fee;
        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to withdraw the balance");
    }
    
    function sellToken(uint256 tokenAmt) public{
        require(tokenAmt > 0, "Enter Right amount of tokens to be sold");
        uint256 userBalance = token.balanceOf(msg.sender);
        require(userBalance >= tokenAmt, "Sorry! You do not own that many tokens");

        uint256 ethAmt = tokenAmt/tokensPerEth;
        uint256 ownerEthBalance = address(this).balance;

        require(ownerEthBalance >= ethAmt, "Vendor does not have enough funds");
        (bool sent) = token.transferFrom(msg.sender, address(this), tokenAmt);
        require(sent, "Failed to transfer tokens from user to vendor");

        // send tax to owner
        uint256 fee = ethAmt * sellTax / 100;
        (sent,) = msg.sender.call{value: fee}("");
        require(sent, "Failed to send tax to owner");

        (sent,) = msg.sender.call{value: ethAmt - fee}("");
        require(sent, "Failed to send ETH to the user");

    }
}