pragma solidity ^0.4.21;

import "./templates/Ownable.sol";


contract Users is Ownable {

    struct UserStruct {
        uint index;
        string _hash;
    }

    mapping(address => UserStruct) public users;
    address[] public userIndex;

    event NewUser(address indexed _addr, uint _index, string _hash);
    event UpdateUser(address indexed _addr,  uint _index, string _hash);
    event DeleteUser(address indexed _addr,  uint _index);

    function getUser(address _addr)
    onlyOwner
    public
    view
    returns(uint index, string _hash) {
        require(existsUser(_addr) == true);
        return(
            users[_addr].index,
            users[_addr]._hash
        );
    }

    function existsUser(address _addr) public view returns(bool isIndexed) {
        if(userIndex.length == 0) {
            return false;
        }
        return (userIndex[users[_addr].index] == _addr);
    }

    function newUser(string _hash)
    public
    returns(bool) {
        require(existsUser(msg.sender) == false);
        userIndex.push(msg.sender);
        users[msg.sender].index = userIndex.length - 1;
        users[msg.sender]._hash = _hash;

        emit NewUser(msg.sender, users[msg.sender].index,  _hash);
        return true;
    }

    function updateUser(address _addr, string _hash)
    onlyBy(_addr)
    public
    returns(bool) {
        require(existsUser(msg.sender) == true);
        users[msg.sender]._hash = _hash;
        emit UpdateUser(msg.sender, users[msg.sender].index, _hash);
        return true;
    }

    function deleteUser(address _addr)
    public
    onlyBy(_addr)
    returns(uint index) {
        require(existsUser(msg.sender) == true);
        uint _rowToDelete = users[msg.sender].index;
        address _keyToMove = userIndex[userIndex.length - 1];
        userIndex[_rowToDelete] = _keyToMove;
        users[_keyToMove].index = _rowToDelete; 
        userIndex.length--;
        emit DeleteUser(msg.sender, _rowToDelete);
        emit UpdateUser(_keyToMove, _rowToDelete, users[_keyToMove]._hash);
        return _rowToDelete;
    }

    function getUsers() public view onlyOwner returns(address[]) {
        return userIndex;
    }

    function getUserCount() public view onlyOwner returns(uint count) {
        return userIndex.length;
    }

    function getUserAtIndex(uint index)
    public
    onlyOwner
    view returns(uint, address, string) {
        return (
            users[userIndex[index]].index,
            userIndex[index],
            users[userIndex[index]]._hash
        );
    }

}
