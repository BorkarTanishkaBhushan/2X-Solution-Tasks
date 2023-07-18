// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Task3 - OddEvenGame
 * @dev A contract for playing the Odd-Even game using Chainlink's VRF (Verifiable Random Function).
 */ 
contract OddEvenGame is VRFConsumerBaseV2 {

    bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint participationFee = 0.01 ether;
    uint totalOddBetAmt;
    uint totalEvenBetAmt;
    uint64 s_subscriptionId;
    address s_owner;
    uint32 numWords = 2;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    bool betOpen;
    uint256 public s_requestId;
    uint256[] public s_randomWords;
    address[] bettors;
    mapping(address => uint) bet;
    address[] odd;
    address[] even;
    VRFCoordinatorV2Interface COORDINATOR;
    event BettorRegistered(address bettor);
    enum BetChoice{ ODD, EVEN }



    /**
    * @notice Constructor inherits VRFConsumerBaseV2
    * @dev NETWORK: Sepolia
    * @dev Starts the betting process
    * @param subscriptionId Subscription id that this consumer contract can use
    */
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
        );
        betOpen = true;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }


    /**
    * @notice Request a random word from chainlink
    * @dev Uses the requestId and all other constants required for chainlink vrf
    * @return requestId The generated requestId for the request.
    */
    function requestRandomWords() external onlyOwner returns (uint256 requestId){
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    /**
    * @dev The random word generated by chainlinkvrf
    * @param _randomWords Array which contains teh randomword generated
    */
    function fulfillRandomWords(
        uint256 /*_requestId*/,
        uint256[] memory _randomWords
    ) internal override {
        s_randomWords[0] = _randomWords[0];
    }


    /**
    * @notice New participants are registered
    * @dev Register the new bettors
    */    
    function bettorRegister() external payable {
        // require(block.timestamp >= betStart || block.timestamp <= betEnd, "Betting Closed");
        require(betOpen, "Betting Closed");
        for(uint i; i < bettors.length; ++i){
            require(bettors[i] != msg.sender, "You have already registered");
        }
        require(msg.value == participationFee, "Participation fee is 1 ether");
        bettors.push(msg.sender);
        emit BettorRegistered(msg.sender);
        //console.log(address(this).balance)
    }

    
    /**
    * @notice Place bet for the outcome
    * @dev Records the bet of a bettor
    * @param choice the outcome guessed by the bettor from enum BetChoice
    */
    function placebet(BetChoice choice) public payable{
        // require(block.timestamp >= betStart || block.timestamp <= betEnd, "Betting Closed");
        require(betOpen, "Betting Closed");
        require(bet[msg.sender] == 0, "You have already placed a bet");
        require(msg.value > 0, "Bet should be greater than zero");

        bet[msg.sender] = msg.value;
        
        if(choice == BetChoice.ODD){
            odd.push(msg.sender);
            totalOddBetAmt = msg.value;
        }
        else{
            even.push(msg.sender);
            totalEvenBetAmt = msg.value;
        }
    }


    /**
    * @notice End of the betting process
    * @dev Stops the betting process
    * @dev Calculates whether the random number generated by Chainlinks is even or odd
    * @return randomNumber Indicates whether the random number is even or odd
    */
    function betResult() public onlyOwner returns(BetChoice randomNumber) {
        betOpen = false;
        if(s_randomWords[0] % 2 == 0){
            randomNumber = BetChoice.EVEN;
        }
        else{
            randomNumber = BetChoice.ODD;
        }

        afterResult(randomNumber);
    }

    /**
    * @notice Chooses the winners
    * @dev Distributes the participation fee to all the bettors
    * @dev Distributes the rewards to the winners
    * @param randomNumber Store the enum equivalent of the randomNumber generated
    */
    function afterResult(BetChoice randomNumber) public{
        require(!betOpen, "Reselts are not yet declared");
        uint totalBettors = bettors.length;
        uint totalBetAmt = totalOddBetAmt + totalEvenBetAmt;
        // uint totalFeeCollected = participationFee * totalBettors;
        uint winners;

        for(uint i = 0; i < totalBettors; ++i){
            (bool sent, ) = bettors[i].call{value: participationFee}("");
            require(sent, "Failed to transfer participation fee");
        }

        if(randomNumber == BetChoice.ODD){
            winners = odd.length;
            uint priceToEachWinner = totalBetAmt / winners;
            for(uint i = 0; i < winners; ++i){
                (bool sent, ) = odd[i].call{value: priceToEachWinner}("");
                require(sent, "Failed to transfer winner price");
            }
        }
        else{
            winners = even.length;
            uint priceToEachWinner = totalBetAmt / winners;
            for(uint i = 0; i < winners; ++i){
                (bool sent, ) = even[i].call{value: priceToEachWinner}("");
                require(sent, "Failed to transfer winner price");
            }
        }
    }


    modifier onlyOwner()  {
        require(msg.sender == s_owner);
        _;
    }
}


