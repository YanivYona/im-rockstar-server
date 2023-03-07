// SPDX-License-Identifier: MIT
// An upgradeable version of ERC721A created by Chiru Labs https://ERC721A.org


pragma solidity ^0.8.12;

import "./ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract IMROCKSTARV1 is Initializable, ERC721AUpgradeable, UUPSUpgradeable, ERC2981Upgradeable, OwnableUpgradeable {

    using StringsUpgradeable for uint256;

    bool public saleActive;
    bool public revealed;

    uint256 public price;
    uint256 public maxPerTx;
    uint256 public maxPerAddress;
    uint256 public totalReserved;
    uint256 public reservedMinted;
    uint96 public royaltiesPercent;

    string public baseURI;
    string public unrevealedURI;
    address internal signerAddress;
    string public contractURI; //opensea

    uint256 public constant SUPPLY_LIMIT = 10000;

    function initialize(
        address owner_,
        address signerAddress_,
        address royaltyReceiver_)
    public initializer {
        __ERC721A_init("ImRockstar", "IMRS");
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC2981_init();
        saleActive = false;
        price = 0.25 ether;
        maxPerAddress = maxPerTx = 2;
        totalReserved = 500;
        royaltiesPercent = 7.5 * 100;
        unrevealedURI = "https://imrockstar.com/images/collection.jpeg";
        signerAddress = signerAddress_;
        require(signerAddress_ != address(0), "SET SIGNER");
        if (owner() != owner_) {
            _transferOwnership(owner_);
        }

        super._setDefaultRoyalty(royaltyReceiver_, royaltiesPercent);
    }

    function mintWhiteList(uint256 quantity, bytes memory signature)
    external
    payable {
        verifySignature(signature);
        mint(quantity);
    }

    function mintPublicSale(uint256 quantity)
    external
    payable {
        require(saleActive, "SALE INACTIVE");
        mint(quantity);
    }

    function mint(uint256 quantity)
    internal {
        // solhint-disable-next-line avoid-tx-origin
        require(tx.origin == msg.sender, "ONLY EOA");
        require(quantity > 0, "QUANTITY MUST BE POSITIVE");
        require(quantity <= maxPerTx, "MAXIMUM PER TX");
        require(_numberMinted(msg.sender) + quantity <= maxPerAddress, "MAXIMUM REACHED");
        require(
            (_totalMinted() + quantity) <= (SUPPLY_LIMIT - totalReserved + reservedMinted),
            "EXCEEDS SUPPLY LIMIT"
        );
        require(msg.value >= (quantity * price), "NOT ENOUGH ETHER");
        _safeMint(msg.sender, quantity);
    }

    function verifySignature(bytes memory signature)
    internal
    view {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        address messageSigner = ECDSA.recover(message, signature);
        require(messageSigner == signerAddress, "NOT WHITELISTED");
    }

    /*
        Owner Functions
    */

    function mintReserved(uint256 quantity, address to)
    external
    onlyOwner {
        require(quantity + reservedMinted <= totalReserved, "EXCEEDS RESERVED AMOUNT");
        require(_totalMinted() + quantity <= SUPPLY_LIMIT, "EXCEEDS SUPPLY LIMIT");
        reservedMinted += quantity;
        _safeMint(to, quantity);
    }

    function setSaleActive(bool _saleActive)
    external
    onlyOwner {
        saleActive = _saleActive;
    }

    function setPrice(uint256 _price)
    external
    onlyOwner {
        price = _price;
    }

    function setMaxPerTx(uint256 _maxPerTx)
    external
    onlyOwner {
        maxPerTx = _maxPerTx;
    }

    function setMaxPerAddress(uint256 _maxPerAddress)
    external
    onlyOwner {
        maxPerAddress = _maxPerAddress;
    }

    function setTotalReserved(uint256 _totalReserved)
    external
    onlyOwner {
        totalReserved = _totalReserved;
    }

    function setContractURI(string calldata contractURI_)
    external
    onlyOwner {
        contractURI = contractURI_;
    }

    function setBaseURI(string calldata baseURI_)
    external
    onlyOwner {
        baseURI = baseURI_;
    }

    function reveal()
    external
    onlyOwner {
        require(bytes(baseURI).length > 0, "SET BASEURI FIRST");
        require(!revealed, "ALREADY REVEALED");
        revealed = !revealed;
    }

    function withdraw() external payable onlyOwner {
        (bool success,) = payable(msg.sender).call{value : address(this).balance}("");
        require(success);
    }

    /*
        ERC2981 Royalties
    */

    function setDefaultRoyalty(address receiver, uint96 royaltyFeesInBips)
    public
    onlyOwner {
        super._setDefaultRoyalty(receiver, royaltyFeesInBips);
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 royaltyFeesInBips)
    public
    onlyOwner {
        super._setTokenRoyalty(tokenId, receiver, royaltyFeesInBips);
    }

    function resetTokenRoyalty(uint256 tokenId)
    public
    onlyOwner {
        super._resetTokenRoyalty(tokenId);
    }

    /*
        ERC721A Overrides
    */

    function _startTokenId()
    internal
    view
    virtual
    override
    returns (uint256) {
        return 1;
    }

    function _baseURI()
    internal
    view
    virtual
    override
    returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return revealed ? string(abi.encodePacked(abi.encodePacked(baseURI, tokenId.toString()), ".json")) : unrevealedURI;
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721AUpgradeable, ERC2981Upgradeable)
    returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyOwner
    override
    {}
}
