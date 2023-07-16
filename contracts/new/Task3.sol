// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract OddEvenGame is VRFConsumerBaseV2 {
   
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    uint participationFee = 0.01 ether;
    address[] bettors;
    uint totalOddBetAmt;
    uint totalEvenBetAmt;

    bool betOpen;
    // uint public betStart = block.timestamp;
    // uint public betEnd = block.timestamp + 3600; //1hr = 60*60 s


    event BettorRegistered(address bettor);

    enum BetChoice{ ODD, EVEN }

    // mapping(address => uint) odd;
    // mapping(address => uint) even;

    mapping(address => uint) bet;
    address[] odd;
    address[] even;


    

    /**
    * @notice Constructor inherits VRFConsumerBaseV2
    *
    * @dev NETWORK: Sepolia
    *
    * @param subscriptionId subscription id that this consumer contract can use
    */
    constructor(uint64 subscriptionId)VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        betOpen = true;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

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

    function fulfillRandomWords(
        uint256 /*_requestId*/,
        uint256[] memory _randomWords
    ) internal override {
        s_randomWords[0] = _randomWords[0];
    }

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


