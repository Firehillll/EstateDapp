// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// internal import from NFT OPENZIPLINE
import "@openzeppelin/contracts/utils/Counters.sol"; // keep track of the number of supply
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// Hardhat 
import "hardhat/console.sol";


abstract contract NFTMarketplce is ERC721URIStorage {
    // Use the counter contract
    using Counters for Counters.Counter;

    // Take the var
    Counters.Counter private _tokenIds;
    // keep track how many we are selling
    Counters.Counter private _itemsSold;

    // listing price fees
    uint256 listingPrice = 0.0025 ether;


    // Owner address
    address payable owner;

    // id for eacht NFT
    mapping (uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // trigger an event
    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // Owner modifier
    modifier onlyOwner(){
        require(
            msg.sender == owner,
            "only owner of the marketplace can change the listing price"
        );
        _;
    }

    // NFT symbol and name
    constructor() ERC721("Estate.place", "EstateNFT"){
        owner == payable(msg.sender);
    }

    // Marketplace NFT price
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner{
        {
            listingPrice = _listingPrice;
        }
    }

    // get the listing price
    function getListingPrice() public view returns (uint256){
        return listingPrice;
    }

    // NFT creation function
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        // Mint the token
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        // 
        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    // assign data to NFT that was created
    function createMarketItem(uint256 tokenId, uint256 price) private{
        require(price >0, "Price should be a least 1");
        require(msg.value == listingPrice, "Price must be a list the fees price");

        // insert the token item
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        // tranfer the NFT to the contract
        _transfer(msg.sender, address(this), tokenId);

        // Call the event
        emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    // Resale the NFT
    function reSellToken(uint256 tokenId, uint256 price) public payable{
        // make sure the only owner of the NFT can use this function
        require(idMarketItem[tokenId].owner == msg.sender, "only owner can list this NFT");

        require(msg.value == listingPrice, "Price should be bigger then listing value");

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        // decrease item sold
        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    // Create marketplace sale
    function createMarketSale(uint256 tokenId) public payable{
        uint256 price = idMarketItem[tokenId].price;
        // increase money to buy the NFT
        require(msg.value == price,"please sudmit asking price");

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].owner = payable(address(0));
    

    _itemsSold.increment();

    // Transfer the NFT to the buyer
    _transfer(address(this), msg.sender, tokenId);

    // Transfer marketplace listing fees to marketplace address
    payable(owner).transfer(listingPrice);

    // transfer everything after the fees to the seller
    payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }


    // Get NFT unsold
    function fetchMarketItem() public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current();
        uint256 unSoldItemCount = _tokenIds.current(); - _itemsSold.current();
        uint256 currentIndex = 0;
        
        // put all unsold items in marketplace
        MarketItem[] memory items = new MarketItem[unSoldItemCount];
        // loop function
        for (uint256 i = 0; i < itemCount; i++){
            if(idMarketItem[i+1.owner == address(this)){
                uint256 currentId = i+1;

                MarketItem storage currentItem = idMarketItem[currentIndex];

                currentIndex += 1;

            }
        }

        // return the functions
        return items;
    }

}
