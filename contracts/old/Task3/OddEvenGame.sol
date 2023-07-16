    //SPDX-LICENSE-IDENTIFIER: MIT
    pragma solidity 0.8.19;

    import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
    import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

    /**
    * @notice A Chainlink VRF consumer which uses randomness which is used 
    * in Odd and Even betting game
    */

    contract OddEvenGame is VRFConsumerBaseV2 {

        uint256 constant public BET_IN_PROGRESS = 1;

        VRFCoordinatorV2Interface COORDINATOR;

        uint64 g_subscriptionId;

        // Polygon coordinator. 
        address constant public vrfCoordinator = 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255;

        // The gas lane to use, which specifies the maximum gas price to bump to.
        bytes32 g_keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. 
    uint32 callbackGasLimit = 40000;

    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    address g_owner;

    // map bettors to requestIds
    mapping(uint256 => address) private g_bettors;
    // map vrf results to rollers
    mapping(address => uint256) private g_results;

    event NumberRequested(uint256 indexed requestId, address indexed bettor);
    event NumberReceived(uint256 indexed requestId, uint256 indexed result);


    /**
        * @notice Constructor inherits VRFConsumerBaseV2
        *
        * @dev NETWORK: Polygon
        *
        * @param subscriptionId subscription id that this consumer contract can use
        */
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        g_owner = msg.sender;
        g_subscriptionId = subscriptionId;
    }


        /**
        * @notice Requests randomness
        * @dev Warning: if the VRF response is delayed, avoid calling requestRandomness repeatedly
        * as that would give miners/VRF operators latitude about which VRF response arrives first.
        * @dev You must review your implementation details with extreme care.
        *
        * @param bettor address of the bettor
        */
    function generateNumber(
        address bettor
    ) public onlyOwner returns (uint256 requestId) {
        require(g_results[bettor] == 0, "Already issued a bet");
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            g_keyHash,
            g_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        g_bettors[requestId] = bettor;
        g_results[bettor] = BET_IN_PROGRESS;
        emit NumberRequested(requestId, bettor);
    }


        /**
        * @notice Callback function used by VRF Coordinator to return the random number to this contract.
        *
        * @dev Some action on the contract state should be taken here, like storing the result.
        * @dev WARNING: take care to avoid having multiple VRF requests in flight if their order of arrival would result
        * in contract states with different outcomes. Otherwise miners or the VRF operator would could take advantage
        * by controlling the order.
        * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
        * contract ensures that this method only receives randomness from the designated VRFCoordinator.
        *
        * @param requestId uint256
        * @param randomWords uint256[] The random result returned by the oracle.
        */
        function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
            uint256 randomNumber = randomWords[0];
            address bettor = g_bettors[requestId];

            if (randomNumber % 2 == 0) {
                g_results[bettor] = 0;
            } else {
                g_results[bettor] = 1;
            }
            emit NumberReceived(requestId, randomNumber);
        }


        /**
        * @notice check whether the random number is even or odd
        * @param bettor address
        * @return result as a string
        */
        function getResult(address bettor) public view returns (string memory) {
            if (g_results[bettor] == 1) {
                return "odd";
            } else {
                return "even";
            }
        }


    modifier onlyOwner() {
        require(msg.sender == g_owner);
        _;
    }
    }