// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

//pragma solicity 0.6.0;
//pragma solidity 0.8.4;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

//import "@chainlink/contracts/src/v0.6/VRFCoordinator.sol";

//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

//contract AdvancedCollectible is ERC721, VRFConsumerBaseV2, Ownable {
contract AdvancedCollectible is ERC721, VRFConsumerBaseV2, Ownable {
    uint256 public tokenCounter;
    bytes32 public keyHash;
    uint256 public fee;
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(uint256 => address) public requestIdToSender;
    event requestedCollectible(uint256 indexed requestId, address requester);
    event breedAssigned(uint256 indexed tokenId, Breed breed);

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURIextended;

    uint32 numWords = 1;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 subscriptionId = 10094;
    VRFCoordinatorV2Interface COORDINATOR;

    constructor(
        address _VRFCoordinator,
        address _linkToken,
        bytes32 _keyHash,
        uint256 _fee
    ) public VRFConsumerBaseV2(_VRFCoordinator) ERC721("Dogie", "DOG") {
        COORDINATOR = VRFCoordinatorV2Interface(_VRFCoordinator);
        tokenCounter = 0;
        keyHash = _keyHash;
        fee = _fee;
    }

    function createCollectible() public returns (uint256) {
        //bytes32 requestId = requestRandomness(keyHash, fee);
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requestIdToSender[requestId] = msg.sender;
        emit requestedCollectible(requestId, msg.sender);
        return requestId;
    }

    //function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomness)
        internal
        override
    {
        Breed breed = Breed(randomness[0] % 3);
        uint256 newTokenId = tokenCounter;
        tokenIdToBreed[newTokenId] = breed;
        emit breedAssigned(newTokenId, breed);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        //_setTokenURI(newTokenId, );
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: Caller is not owner or approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }
}
