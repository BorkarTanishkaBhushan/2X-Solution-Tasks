//SPDX-LICENSE-IDENTIFIER: UNLICENSED
pragma solidity ^0.8.0;


/// @title Task 1 - Custom Token Creation with Buy/Sell Tax and Fee Conversion 
contract CustomToken {

    /**
    * @dev A mapping to store balances of each address
    * Key: Address of the user
    * Value: Token balance of the user
    */
    mapping(address => uint256) public balances;
    /**
    * @dev Stores the approved allowances for token transfers between addresses
    * Key: Address of the user
    * Value: Number of allowed tokens
    */
    mapping(address => mapping(address => uint256)) public allowances;
    /// Total supply of the token
    uint256 public totalSupply;
    /// Number of decimal places for token representation
    uint8 public decimals;
    /// Name of the token
    string public name;
    /// Symbol or ticker of the token
    string public symbol;
    /// Price of the token in Ether (ETH)
    uint256 public tokenPrice = 1 ether;
    /// Tax applied on token purchases
    uint256 public buyTax;
    /// Tax percentage applied on token sales
    uint256 public sellTax;
    /// Percentage of collected fees to be converted
    uint256 public feeConversionPercentage;
    /// Address of the token contract owner
    address public owner;
    /// Event emitted when tokens are transferred between addresses
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// Event emitted when token transfer approval is granted
    event Approval(address indexed owner, address indexed spender, uint256 value);


    /**
    * @notice Sets all the required parameters
    * @dev Transfers all the tokens to owner
    * @param _name Name of the token
    * @param _symbol Short name of the token
    * @param _decimals Decimal places used
    * @param _buyTax Tax applied while buying the token
    * @param _sellTax Tax applied while selling the token
    * @param _feeConversionPercentage Tax converted into fees
    */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        uint256 _buyTax,
        uint256 _sellTax,
        uint256 _feeConversionPercentage
    ){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10**uint256(decimals);
        buyTax = _buyTax;
        sellTax = _sellTax;
        feeConversionPercentage = _feeConversionPercentage;
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    /**
    * @notice Gives the custom token balance of an account
    * @dev Returns the token balance of the specified address.
    * @param tokenOwner The address for which the token balance is to be retrieved.
    * @return balance The token balance of the specified address.
    */
    function balanceOf(address tokenOwner) public view returns (uint balance)
    { 
        return balances[tokenOwner];
    }


    /** 
    * @notice The ETH amount sent should be greater than 0 and should cover the cost of the tokens plus buy tax.
    * @notice The user should have enough ETH balance to make the purchase.
    * @dev Allows a user to buy custom tokens by sending ETH to the contract.
    */
    function buyToken() public payable{
        require(msg.value > 0, "1 CT = 1 ETH");
        require(address(msg.sender).balance >= msg.value, "You don't have enough balance");
        uint256 totalBuyTax = (msg.value * buyTax) / 100; 
        uint256 totalTokensToTransfer =  msg.value / (msg.value - totalBuyTax); 

        uint256 tokenBalance = balanceOf(address(this));
        require(tokenBalance >= totalTokensToTransfer, "Not enough tokens available");

        (bool sent) = transfer(msg.sender, totalTokensToTransfer);
        require(sent, "Failed to buy CT");

        (sent,) = owner.call{value: totalBuyTax}("");
        require(sent, "Failed to send tax to owner");
    }


    /**
    * @notice The token amount should be greater than 0 and not exceed the user's token balance.
    * @notice The contract should have enough ETH balance to fulfill the transaction.
    * @notice The sell tax will be deducted from the ETH amount before transferring to the user.
    * @dev Allows a user to sell custom tokens to the contract and receive ETH in return.
    * @param tokenAmt The amount of tokens to be sold.
    */
    function sellToken(uint256 tokenAmt) public {
        require(tokenAmt > 0, "Enter the right amount of tokens to be sold");
        require(balanceOf(msg.sender) >= tokenAmt, "Insufficient token balance");

        uint256 totalethAmt = tokenAmt * tokenPrice;
        require(address(this).balance >= totalethAmt, "Contract does not have enough ETH balance");

        uint256 sellTaxAmount = (totalethAmt * sellTax) / 100;
        uint256 transferEthAmt = tokenPrice * tokenAmt - sellTaxAmount;

        _transfer(msg.sender, address(this), tokenAmt);

        (bool sent) = transfer(msg.sender, transferEthAmt);//Wrong transfer functions ig do recheck
        require(sent, "Failed to send ETH");
        
        (sent,) = owner.call{value: sellTaxAmount}("");
        require(sent, "Failed to send tax to owner");
    }


    /**
    * @dev Transfers tokens from the sender's address to the recipient's address.
    * @param recipient The address to which the tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean value indicating the success of the transfer.
    */
    function transfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    /**
    * @dev Approves the spender to spend a specified amount of tokens on behalf of the sender.
    * @param spender The address to which the spender approval is granted.
    * @param amount The maximum amount of tokens that the spender is allowed to spend.
    * @return A boolean value indicating the success of the approval.
    */
    function approve(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }


    /**
    * @dev Transfers tokens from a specified address to another address on behalf of the sender.
    * @param sender The address from which the tokens will be transferred.
    * @param recipient The address to which the tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean value indicating the success of the transfer.
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            allowances[sender][msg.sender] - amount
        );
        return true;
    }


    /**
    * @notice Only the contract owner can set the buy tax percentage.
    * @dev Sets the buy tax percentage for the custom token.
    * @param percentage The new buy tax percentage to be set.
    */
    function setBuyTax(uint256 percentage) public {
        require(msg.sender == owner, "Only owner can set buy tax percentage");
        buyTax = percentage;
    }


    /**
    * @notice Only the contract owner can set the sell tax percentage.
    * @dev Sets the sell tax percentage for the custom token.
    * @param percentage The new sell tax percentage to be set.
    */
    function setSellTax(uint256 percentage) public {
        require(
            msg.sender == owner,
            "Only owner can set sell tax percentage"
        );
        sellTax = percentage;
    }


    /**
    * @notice Only the contract owner can set the fee conversion percentage.
    * @dev Sets the fee conversion percentage for converting fees to ETH.
    * @param percentage The new fee conversion percentage to be set.
    */
    function setFeeConversionPercentage(uint256 percentage) public {
        require(
            msg.sender == owner,
            "Only owner can set fee conversion percentage"
        );
        feeConversionPercentage = percentage;
    }


    /**
    * @notice Transfers cutom tokens from sender to reciever account
    * @dev Internal function to transfer tokens from the sender to the recipient.
    * @param sender The address from which the tokens will be transferred.
    * @param recipient The address to which the tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");        

        uint256 transferAmount = amount;
        balances[sender] -= amount;
        balances[recipient] += transferAmount;

        emit Transfer(sender, recipient, transferAmount);
        
    }


    /**
    * @notice The approval sets the allowance for spender to spend the specified amount of tokens on behalf of ownerSender.
    * @dev Internal function to approve the spender to spend a specified amount of tokens on behalf of the owner.
    * @param ownerSender The address of the token owner granting the approval.
    * @param spender The address to which the spender approval is granted.
    * @param amount The maximum amount of tokens that the spender is allowed to spend.
    */
    function _approve(
        address ownerSender,
        address spender,
        uint256 amount
    ) internal {
        require(ownerSender != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        allowances[ownerSender][spender] = amount;
        emit Approval(ownerSender, spender, amount);
    }
}
