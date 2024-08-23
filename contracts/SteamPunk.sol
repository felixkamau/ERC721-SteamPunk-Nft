// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";


contract SteamPunk is ERC721, ERC721Burnable, ReentrancyGuard, Ownable{
    // TokenId to keep track of the minted tokens
    using Counters  for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdCounter;

    uint256 public mintPrice; //The mint price to mint nft
    uint256 public maxSupply; //Tour token maxSupply
    string private baseURI; //The main URI 
    // Base uri  for computing `tokenURI`

    /**
     * @dev Emitted when a new token is minted
     * @param to the address that received the newely minted token
     * @param tokenId tokenId the unique identifier for the newly minted token
     */
    event Minted(address indexed to, uint256 tokenId);

    /**
     * @dev Emitted when a withrawal is made by the owner of the contract
     * @param owner Yhe address of the owner who withdrew the amount
     * @param amount The amoun of tokn that were withdrawn
     */
    event Withdrawn(address indexed owner, uint256 amount);

    // We need to pass an addresss to  the base constructor
    // the `address initialOwner` will be the msg.sender
    // lack of passing the argument results in an error `base constructor requires an argument`


     /**
     *@dev passing the required arguments to the constructor during deployment
     * @param _maxSupply  the maxSupply of your tokens in this case nft
     * @param _mintPrice    the mintPrice to mint your token
     * @param _initialBaseURI the base URI for your metadata
     */
    constructor(uint256 _mintPrice, uint256 _maxSupply, string memory _initialBaseURI)
        ERC721("SteamPunk","STP")
        // Am using @openzeppelin/contracts  version @4.9.3
        Ownable()
        {
            mintPrice = _mintPrice;
            maxSupply =_maxSupply;
            baseURI = _initialBaseURI; //we have _initilaBaseURI so that we can change the  `_baseURI`
            // afterwards but it will be `onlyOwner`
        }

    // safeMint function

    /**
     * @dev minting function require an `address to` the address to mint to
     * @param to address  the mint destination address 
     */

    function safeMint(address to) public payable{
        require(totalSupply() < maxSupply,"You cannot mint any more");
        require(msg.value >= mintPrice,"Insufficient funds sent for minting");

        uint256 tokenId = _tokenIdCounter.current() + 1; // Start tokrn IDs at 1
        _tokenIdCounter.increment();// Increment the token ID by 1
        _safeMint(to, tokenId);

        /**
         * @dev emits the `Minted event ` after a successful mint
         */ 
        emit Minted(to, tokenId);
    }



    /**
     * @dev function to check the current total supply of the tokens
     * it's a public view function does not write anything to the blockchain
     * @return _tokenIdCounter current Id
     */ 
    function totalSupply() public view returns (uint256){
        return _tokenIdCounter.current();
    }


    /**
     * @dev Returns the base URI for computing {tokenURI}.
     * This is an internal function that can be overridden in derived contracts.
     * 
     * @return The base URI as a string.
     */
    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    /**
     * @dev set or update the _baseURi for all token metadata
     * @param _newBaseURI the new baseURI for the metadata
     * It's an external function onlyOwner can be called only by the oowner
     */ 
    function setBaseURi(string memory _newBaseURI) external onlyOwner{
        baseURI = _newBaseURI;
    }


    /**
     * @dev Allows the contract owner to withdraw the entire balance of the contract.
     * Can only be called by the owner. The function is protected against reentrancy attacks.
     *
     * Requirements:
     * - The contract must have a positive balance.
     *
     * Emits a {Withdrawn} event upon successful withdrawal.
     */
    function withdraw() external onlyOwner nonReentrant{
        uint256 balance = address(this).balance;
        require(balance > 0,"Balance is 0 `zero`");
        payable(owner()).transfer(balance);

        emit Withdrawn(msg.sender, balance);
    }

    // Override required by Solidity because multiple base contracts implement this function
    /**
     * @dev Checks if a given interface ID is supported by this contract.
     * This function is required to be overridden by Solidity when multiple base contracts implement it.
     * 
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return A boolean value indicating whether the interface is supported (`true`) or not (`false`).
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    // Required by Solidity to correctly work with ERC721
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for a given token ID.
     * This function is required to be overridden by Solidity to correctly work with ERC721.
     *
     * @param tokenId The unique identifier for a token.
     * @return The URI string that points to the metadata of the token.
     *
     * Requirements:
     * - The token with the given `tokenId` must exist.
     *
     * Reverts if the token does not exist.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        // Construct the full URI by appending tokenId-specific part to the base URI
        return string(abi.encodePacked(baseURI, "/metadata", tokenId.toString(), "-json.json"));
    }

}