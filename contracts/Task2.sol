//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Task 2 - NFT Minting Smart Contract with Chain Flexibility
 * @dev A contract for minting ERC721 tokens with whitelisted addresses
 */
contract NftMinting is ERC721 {
    mapping(address => bool) whitelisted_address;
    address owner;
    uint256 whitelist_period;
    uint256 start_time;
    uint256 public tokenId;

    /**
    * @notice Whitelist period and owner is set
    * @dev Constructor function for initializing the NftMinting contract.
    * @param _whitelist_period The duration of the whitelist period in minutes.
    */
    constructor(uint256 _whitelist_period) ERC721("Token", "TKN") {
        owner = msg.sender;
        whitelist_period = _whitelist_period * 1 minutes;
        start_time = block.timestamp;
    }

    
    /**
    * @notice The function checks if the current timestamp is within the whitelist period and mints the nft to the correct address
    * @dev Mints a new ERC721 token and assigns it to the specified address.
    * @param to The address to which the token will be assigned.
    */
    function safeMint(address to) public {
        if(block.timestamp <= start_time + whitelist_period) {
            require(verifyUser(to), "Address not whitelisted");
            _safeMint(to, tokenId);
            ++tokenId;
        }

        if(block.timestamp > start_time + whitelist_period)
        {
            _safeMint(to, tokenId);
            ++tokenId;
        } 
    }


    /**
    * @notice A new whitelist address is added
    * @dev Owner adds an address to the whitelist.
    * @param _addressToWhitelist The address to be added to the whitelist.
    */    
    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelisted_address[_addressToWhitelist] = true;
    }


    /**
    * @notice Checks if the specified address is whitelisted or not
    * @dev Verifies if an address is whitelisted.
    * @param _whitelistedAddress The address to be verified.
    * @return A boolean value indicating whether the address is whitelisted or not.
    */
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelisted_address[_whitelistedAddress];
      return userIsWhitelisted;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Ownable: caller is not the owner");
      _;
    }
}


