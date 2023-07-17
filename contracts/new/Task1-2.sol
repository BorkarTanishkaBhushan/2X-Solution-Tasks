// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.19;

// interface CustomTokenInterface {
//     // function totalSupply() external view returns (uint);
//     function balanceOf(address tokenOwner) external view returns (uint balance);
//     function transfer(address to,  uint tokens) external returns (bool success);

//     function allowance(address tokenOwner, address spender) external view returns (uint remaining);
//     function approve(address spender, uint tokens) external returns (bool success);
//     function transferFrom(address from, address to, uint tokens) external returns (bool success);

//     event Transfer(address indexed from, address indexed to, uint tokens);
//     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
// }

// contract CustomToken is CustomTokenInterface{
//     string public name = "CustomToken";
//     string public symbol = "CT";
//     string public decimal = "0";
//     uint public totalSupply;
//     address public founder;
//     uint tokenPrice = 0.1 ether;
//     uint buyTaxPercent = 0.1;
//     uint totalTaxCollected;
//     uint fee;
//     uint totalFeeCollected;
//     mapping(address => uint) public balances;
//     mapping(address=>mapping(address=>uint)) allowed;

//     constructor(uint _totalsupply){
//         totalSupply = _totalsupply * 10**18;
//         founder = msg.sender;
//         balances[founder] = totalSupply;
//     }

//     function balanceOf(address tokenOwner) public view override returns (uint balance)
//     {
//         return balances[tokenOwner];
//     }

//     function transfer(address to, uint tokens) public override virtual returns (bool success){
//         require(balances[msg.sender] >= tokens);
//         balances[to] += tokens;
//         balances[msg.sender] -= tokens;
//         emit Transfer(msg.sender, to, tokens);
//         return true;
//     }

//     function approve(address spender, uint tokens) public override returns (bool success){
//         require(balances[msg.sender]>=tokens);
//         require(tokens>0);
//         allowed[msg.sender][spender] = tokens;
//         emit Approval(msg.sender, spender, tokens);
//         return true;
//     }

//     function allowance(address tokenOwner, address spender) public view override returns (uint noOfTokens){
//         return (allowed[tokenOwner][spender]);
//     }

//     function transferFrom(address from, address to, uint tokens) public override virtual returns(bool success)
//     {
//         require(allowed[from][to] >= tokens);
//         require(balances[from] >= tokens);
//         balances[from] -= tokens;
//         balances[to] += tokens;
//         return true;
//     }

//     function buy() public payable{
//         require(msg.value > 0, "1 CT = 0.1 ETH");
//         require(address(msg.sender).balance >= msg.value * tokenPrice, "You don't have enough balance");
//         uint totalBuyTax = msg.value + (msg.value * buyTaxPercent);
//         uint256 totalTokensToTransfer =  msg.value / totalBuyTax;

//         uint256 tokenBalance = balanceOf(address(this));
//         require(tokenBalance >= totalTokensToTransfer, "Not enough tokens available");

//         (bool sent) = transfer(msg.sender, totalTokensToTransfer);
//         require(sent, "Failed to buy CT");

//         (sent,) = founder.call{value: totalBuyTax}("");
//         require(sent, "Failed to send tax to owner");
//     }

// }




// //founder: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// //user1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// //user1 sends 1 eth
// //user gets token : 
// //founder balance:
// //contract balance: 
// //token balance of user1:
// //token balance of founder: