pragma solidity 0.4.18;

import "./ERC721.sol";

contract ERC721Token is ERC721 {

    string public constant _name = "My Non Fungible Token";
    string public constant _symbol = "MNFT";

    struct Token {
        address mintedBy;
        uint64 mintedAt;
    }

    Token[] tokens;

    mapping(uint256 => address) public tokenIndexToOwner;
    mapping(address => uint256) ownershipTokenCount;
    mapping(uint256 => address) public tokenIndexToApproved;

    event Mint(address owner, uint256 tokenId);

    modifier available(uint256 _tokenId) {
        // throw in case owner is 0 which means either of
        // 1. unknown token
        // 2. burnt token
        require(tokenIndexToOwner[_tokenId] != address(0));
        _;
    }

    modifier owned(uint256 _tokenId, address _by)  {
        require(tokenIndexToOwner[_tokenId] == _by);
        _;
    }

    modifier notOwned(uint256 _tokenId, address _by)  {
        require(tokenIndexToOwner[_tokenId] != _by);
        _;
    }

    modifier own(uint256 _tokenId) {
        require(tokenIndexToOwner[_tokenId] == msg.sender);
        _;
    }

    modifier notOwn(uint256 _tokenId) {
        require(tokenIndexToOwner[_tokenId] != msg.sender);
        _;
    }

    modifier approved(uint256 _tokenId)  {
        require(tokenIndexToApproved[_tokenId] == msg.sender);
        _;
    }

    modifier approvedTo(uint256 _tokenId, address _to)  {
        require(tokenIndexToApproved[_tokenId] == _to);
        _;
    }

    modifier notToSender(address _to) {
        require(msg.sender != _to);
        _;
    }

    modifier notToContract(address _to) {
        require(msg.sender != address(this));
        _;
    }

    modifier notToBurn(address _to) {
        require(_to != address(0));
        _;
    }

    function name() public constant returns (string tokenName) {
        return _name;
    }

    function symbol() public constant returns (string tokenSymbol) {
        return _symbol;
    }

    function totalSupply() public constant returns (uint256 tokenTotalSupply) {
        tokenTotalSupply = tokens.length;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        balance = ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public constant available(_tokenId) returns (address owner) {
        owner = tokenIndexToOwner[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public available(_tokenId) own(_tokenId) notToSender(_to) {
        address previouslyApprovedTo = tokenIndexToApproved[_tokenId];
        tokenIndexToApproved[_tokenId] = _to;

        if ((previouslyApprovedTo == address(0)) && (_to == address(0)) ) {
            // The only situation when Approve() event is not fired - when clearing approval (i.e. approving to 0-address)
            // not previously approved (previous approve is to 0-address) token.
            // Actually, nothing changes in this case - 0 to 0 approve change
        } else {
            // fire event
            Approval(tokenIndexToOwner[_tokenId], tokenIndexToApproved[_tokenId], _tokenId);
        }
    }

    function transferToken(address _from, address _to, uint256 _tokenId) internal {
        // assign token to new owner (_to)
        tokenIndexToOwner[_tokenId] = _to;
        ownershipTokenCount[_to]++;

        // un-assign token from current owner (_from)
        if (_from == address(0)) {
            // just minted token - no current owner
        } else {
            // owned token
            // owner changed - clear approval made by previous owner (if any)
            delete tokenIndexToApproved[_tokenId];
            ownershipTokenCount[_from]--;
        }

        // fire event
        Transfer(_from, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public available(_tokenId) approved(_tokenId) notOwn(_tokenId) {
        transferToken(tokenIndexToOwner[_tokenId], msg.sender, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public available(_tokenId) own(_tokenId) notToBurn(_to) {
        transferToken(msg.sender, _to, _tokenId);
    }

    function mintToken(address _owner) internal returns(uint256 tokenId) {
        Token memory token = Token({
            mintedBy: _owner,
            mintedAt: uint64(now)
        });

        // id would be the last index in array
        tokenId = tokens.push(token) - 1;

        // fire event
        Mint(_owner, tokenId);

        // new token would be owned by _owner
        transferToken(address(0), _owner, tokenId);
    }

    function mint() public returns(uint256 tokenId) {
        tokenId = mintToken(msg.sender);
    }

    function getToken(uint256 _tokenId) public view returns(address mintedBy, uint64 mintedAt) {
        Token memory token = tokens[_tokenId];
        mintedBy = token.mintedBy;
        mintedAt = token.mintedAt;
    }

    function tokensOfOwner(address _owner) public view returns(uint256[]) {
        uint256 balance = balanceOf(_owner);
        if (balance == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](balance);
            uint256 maxTokenId = totalSupply();
            uint256 idx = 0;
            uint256 tokenId = 0;
            for (tokenId = 1; tokenId < maxTokenId; tokenId++) {
                if (tokenIndexToOwner[tokenId] == _owner) {
                    result[idx] = tokenId;
                    idx++;
                }
            }
        }

        return result;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint tokenId) {
        uint256[] memory _tokensOfOwner = tokensOfOwner(_owner);
        require(_index < _tokensOfOwner.length);
        tokenId = _tokensOfOwner[_index];
    }

    function tokenMetadata(uint256 _tokenId) public constant returns(string infoUrl) {
        return 'https://google.com';
    }
}
