// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Counters.sol";


contract Subscription is ERC721, Ownable, ERC721Burnable{
    
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct subscriptionInfo{
        address owner;
        uint256 tokenId;
        uint256 sellPrice;
        uint256 startTime;
        uint256 endTime;
    }

    uint buyPrice = 10 ether;
    uint royaltyPercentage = 10;
    uint subscriptionTime = 10 * 60;

    address[] public subscriptionHolders;
    address[] public subscriptionSellers;

    mapping (address => subscriptionInfo) public infoOfVault;
    mapping (address => bool) public isSelling;

    constructor() ERC721("Subscription", "SUB") Ownable(msg.sender) {
        _tokenIdCounter.increment();
    }

    modifier isExpired(address vault){
        if(infoOfVault[vault].endTime>=block.timestamp){
            burnSubscription(vault);
        } else{
            _;
        }
    }

    function getSubscriberEndTimeInfo(address vault) public view returns(uint256){
        return infoOfVault[vault].endTime;
    }

    function mintSubscription(address _toVault) public payable{

        require(msg.value >= buyPrice, "Not enough funds");

        uint256 tokenId = _tokenIdCounter.current();
        _mint(_toVault, tokenId);
        _tokenIdCounter.increment();

        subscriptionHolders.push(_toVault); 

        infoOfVault[_toVault] = subscriptionInfo(msg.sender, tokenId, 0, block.timestamp, block.timestamp+subscriptionTime);
    }

    function burnSubscription(address _vault) public {
        for (uint i = 0; i < subscriptionHolders.length; i++){
            if(subscriptionHolders[i]==_vault){
                delete subscriptionHolders[i];
            }
        }

        if(isSelling[_vault]){
            for (uint i = 0; i < subscriptionSellers.length; i++){
                if(subscriptionSellers[i]==_vault){
                    delete subscriptionSellers[i];
                }
            }
        }

        _burn(infoOfVault[_vault].tokenId);
        delete infoOfVault[_vault];
        delete isSelling[_vault];
    }

    function sellingOn(address _vault, uint256 _price) public {
        isSelling[_vault] = true;
        subscriptionSellers.push(_vault);
        
        infoOfVault[_vault].sellPrice = _price;
    }

    function sellingOff(address _vault) public{
        isSelling[_vault] = false;
        for (uint i = 0; i < subscriptionSellers.length; i++){
            if(subscriptionSellers[i]==_vault){
                delete subscriptionSellers[i];
            }
        }
    }

    function calcSellingPrice(uint256 price) public view returns(uint256) {
        return price + (price * royaltyPercentage)/100;
    }

    function purchase(address from, address vaultToBuy) public payable isExpired(vaultToBuy){ 
        require(isSelling[vaultToBuy] == true, "Not for sale");
        require(infoOfVault[vaultToBuy].sellPrice >= msg.value, "Not enough funds");

        payable(from).transfer(msg.value);

        sellingOff(vaultToBuy);
        for(uint i = 0; i < subscriptionSellers.length; i++){
            if(subscriptionSellers[i]==vaultToBuy){
                delete subscriptionSellers[i];
            }
        }

        for (uint i = 0; i < subscriptionHolders.length; i++){
            if(subscriptionHolders[i]==vaultToBuy){
                delete subscriptionHolders[i];
            }
        }

        infoOfVault[vaultToBuy].owner = from;
        infoOfVault[vaultToBuy].sellPrice = 0;
    }
    
}