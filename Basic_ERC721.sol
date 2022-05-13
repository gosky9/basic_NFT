// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

contract Basic_ERC721 {
    // 在 mint,burn,transfer 时反馈
    event Mint(uint256 _tokenId);
    event Transfer();
    event Burn();

    // 维护一个记录总量的状态变量
    uint256 tokenId = 0;

    //  token ID 到 持有人owner的映射
    mapping(uint256 => address) internal tokenOwner;
    // 持有人到持有的token数量的映射
    mapping(address => uint256) internal ownedTokensCount;

    // 在burn和transfer操作时需要确保msg.sender是token_Id的持有人
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(tokenOwner[_tokenId] == msg.sender);
        _;
    }

    // mint操作
    function mint() external {
        tokenOwner[tokenId] = msg.sender;
        tokenId += 1;
        ownedTokensCount[msg.sender] += 1;
        emit Mint(tokenId - 1);
    }

    // burn操作
    function burn(uint256 _tokenId) external onlyOwnerOf(_tokenId) {
        delete tokenOwner[_tokenId];
    }

    // transfer操作
    function transfer(address _receiver, uint256 _tokenId)
        external
        onlyOwnerOf(_tokenId)
    {
        require(tokenOwner[_tokenId] == msg.sender);
        require(_receiver != address(0));
        ownedTokensCount[msg.sender] -= 1;
        tokenOwner[_tokenId] = _receiver;
        ownedTokensCount[_receiver] += 1;
    }

    // 获取持有者的代币总数
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

    // 根据token ID获取持有者
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        return owner;
    }

    // 根据地址查询拥有的nft,考虑查询的便利性和 storage 的精简,
    // 如果精简为数组查询会更快，但是由于gas的原因，故如此实现
    function getTokensByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](ownedTokensCount[_owner]);
        uint256 counter = 0;
        // 遍历tokenId
        for (uint256 i = 0; i < tokenId; i++) {
            if (tokenOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
