pragma solidity 0.4.18;

contract ERC721 {
    /**
     * spec: https://github.com/ethereum/eips/issues/721
     */

    /**
     * ERC-20 Compatibility section
     */

    /**
     * OPTIONAL
     * Returns the name of the collection of NFTs managed by this contract. - e.g. "My Non-Fungibles".
     */
    function name() public constant returns (string tokenName);

    /**
     * OPTIONAL
     * Returns a short string symbol referencing the entire collection of NFTs managed in this contract. e.g. "MNFT".
     */
    function symbol() public constant returns (string tokenSymbol);

    /**
     * Returns the total number of NFTs currently tracked by this contract.
     */
    function totalSupply() public constant returns (uint256 tokenTotalSupply);

    /**
     * Returns the number of NFTs assigned to address _owner.
     */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /**
     * Basic Ownership section
     */

    /**
     * Returns the address currently marked as the owner of _tokenID
     *
     * MUST throw if _tokenID does not represent an NFT currently tracked by this contract
     * MUST NOT return 0 (NFTs assigned to the zero address are considered destroyed, and queries about them should throw).
     */
    function ownerOf(uint256 _tokenId) public constant returns (address owner);

    /**
     * Grants approval for address _to to take possession of the NFT with ID _tokenId
     *
     * MUST throw if msg.sender != ownerOf(_tokenId) - owner only can approve
     * MUST throw if _tokenID does not represent an NFT currently tracked by this contract - can approve known tokens only
     * MUST throw if msg.sender == _to - can not approve for myself
     * Only one address can "have approval" at any given time;
     * Calling with a new address revokes approval for the previous address.
     * Calling with 0 as the _to argument clears approval for any address.
     *
     * MUST emit an Approval event unless the caller is attempting to clear approval when there is no pending approval
     * MUST emit an Approval event if the _to address is zero and there is some outstanding approval (clear outstanding approval)
     * MUST emit an Approval event if _to is already the currently approved address and this call otherwise has no effect
     * MUST emit an Approval event Approval(0, _tokenId) if there was an outstanding approval and implicit clearing of approval via ownership transfer was made
     */
    function approve(address _to, uint256 _tokenId) public;

    /**
     * Assigns the ownership of the NFT with ID _tokenId to msg.sender if and only if msg.sender currently has approval
     *
     * MUST fire the Transfer event in case of success
     * MUST transfer ownership to msg.sender or throw, no other outcomes can be possible
     * MUST throw if msg.sender does not have approval for _tokenId
     * MUST throw if _tokenID does not represent an NFT currently tracked by this contract
     * MUST throw if msg.sender already has ownership of _tokenId
     * MUST clear pending approval upon success transfer
     */
    function takeOwnership(uint256 _tokenId) public;

    /**
     * Assigns the ownership of the NFT with ID _tokenId to _to if and only if msg.sender == ownerOf(_tokenId)
     *
     * MUST fire the Transfer event
     * MUST transfer ownership to _to or throw, no other outcomes can be possible.
     * MUST throw if msg.sender is not the owner of _tokenId
     * MUST throw if _tokenID does not represent an NFT currently tracked by this contract
     * MUST throw if _to is 0
     *
     * MUST allow the current owner to "transfer" a token to themselves. This "no-op transfer" MUST be considered a successful transfer,
     * and therefore MUST fire a Transfer event (with the same address for _from and _to)
     */
    function transfer(address _to, uint256 _tokenId) public;

    /**
     * OPTIONAL
     * Returns the nth NFT assigned to the address _owner, with n specified by the _index argument.
     * MUST throw if _index >= balanceOf(_owner)
     * Recommended usage:
     * uint256 ownerBalance = nonFungibleContract.balanceOf(owner);
     * uint256[] memory ownerTokens = new uint256[](ownerBalance);
     * for (uint256 i = 0; i < ownerBalance; i++) {
     *   ownerTokens[i] = nonFungibleContract.tokenOfOwnerByIndex(owner, i);
     * }
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint tokenId);

    /**
     * NFT Metadata section
     */

    /**
     * OPTIONAL
     * Returns a multiaddress string referencing an external resource bundle that contains metadata about the NFT associated with _tokenId
     * MUST be an IPFS or HTTP(S) base path (without a trailing slash)
     * Standard sub-paths:
     *   name (required) - UTF-8 encoded name of the specific NFT
     *   image (optional) - PNG, JPEG, or SVG image with at least 300 pixels of detail in each dimension
     *   description (optional) - UTF-8 encoded textual description of the asset
     *   other metadata (optional) - A contract MAY choose to include any number of additional subpaths
     * Each metadata subpath (including subpaths not defined in this standard) MUST contain a sub-path default
     * leading to a file containing the default (i.e. unlocalized) version of the data for that metadata element.
     */
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl);

    /**
     * Events section
     */

    /**
     * MUST trigger when NFT ownership is transferred via any mechanism.
     * The creation of new NFTs MUST trigger a Transfer event for each newly created NFTs, with a _from address of 0 and a _to address matching the owner of the new NFT
     * The deletion (or burn) of any NFT MUST trigger a Transfer event with a _to address of 0 and a _from address of the owner of the NFT (now former owner!)
     * NOTE: A Transfer event with _from == _to is valid
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    /**
     * MUST trigger on any successful call to approve(address _spender, uint256 _value)
     * unless the caller is attempting to clear approval when there is no pending approval
     */
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}
