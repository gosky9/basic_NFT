// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

contract Advanced_ERC721 {
    // 是否转账、销毁、增发
    struct Metadata {
        bool transferable;
        bool burnable;
        bool mintable;
    }
    mapping(uint256 => Metadata) public metadata;

    uint256 classId = 0;

    // 维护一个记录某classId总量的映射
    mapping(uint256 => uint256) internal tokenId;
    // 该系列属于谁
    mapping(uint256 => address) internal classOwner;
    //token ID 到 持有人owner的映射
    mapping(uint256 => mapping(uint256 => address)) internal tokenOwner;
    // 持有人到持有的token数量的映射
    mapping(address => mapping(uint256 => uint256)) internal ownedTokensCount;

    // 某用户要新增发一个系列NFT,需要先注册一个 Class
    function mintClass(
        bool _transferable,
        bool _burnable,
        bool _mintable
    ) public {
        classOwner[classId] = msg.sender;
        metadata[classId] = Metadata(_transferable, _burnable, _mintable);
        // metadata[classId].transferable = false;
        // tokenId[classId] = 0;
        classId++;
    }

    // 修改是否可增发、销毁、转让
    function alterMetadata(
        uint256 _classId,
        bool _transferable,
        bool _burnable,
        bool _mintable
    ) public {
        require(classOwner[_classId] == msg.sender);
        metadata[_classId] = Metadata(_transferable, _burnable, _mintable);
    }

    // 在burn和transfer操作时需要确保msg.sender是tokenId的持有人
    modifier onlyOwnerOf(uint256 _classId, uint256 _tokenId) {
        require(tokenOwner[_classId][_tokenId] == msg.sender);
        _;
    }

    // mint操作
    function mint(uint256 _classId) external {
        // 判断是否可增发
        require(metadata[_classId].mintable);
        tokenOwner[_classId][tokenId[classId]] = msg.sender;
        ownedTokensCount[msg.sender][_classId]++;
    }

    // burn操作
    function burn(uint256 _classId, uint256 _tokenId)
        external
        onlyOwnerOf(_classId, _tokenId)
    {
        // 判断是否可销毁
        require(metadata[_classId].burnable);
        delete tokenOwner[_classId][_tokenId];
        ownedTokensCount[msg.sender][_classId]--;
    }

    // transfer操作
    function transfer(
        address _receiver,
        uint256 _classId,
        uint256 _tokenId
    ) external onlyOwnerOf(_classId, _tokenId) {
        require(metadata[_classId].transferable);
        ownedTokensCount[msg.sender][_classId]--;
        tokenOwner[_classId][_tokenId] = _receiver;
        ownedTokensCount[_receiver][_classId]++;
    }

    // 获取持有者的代币总数
    function balanceOf(address _owner, uint256 _classId)
        public
        view
        returns (uint256)
    {
        return ownedTokensCount[_owner][_classId];
    }

    // 根据token ID获取持有者
    function ownerOf(uint256 _classId, uint256 _tokenId)
        public
        view
        returns (address)
    {
        address owner = tokenOwner[_classId][_tokenId];
        return owner;
    }

    // 根据address和classId查询持有的tokenId
    function getTokensByOwner(address _owner, uint256 _classId)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](
            ownedTokensCount[_owner][_classId]
        );
        uint256 counter = 0;

        for (uint256 i = 0; i < tokenId[_classId]; i++) {
            if (tokenOwner[_classId][i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
