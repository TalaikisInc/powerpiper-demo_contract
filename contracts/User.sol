pragma solidity ^0.4.21;

import "./zeppelin/SafeMath.sol";
import "./zeppelin/Ownable.sol";


contract User is Ownable {
    using SafeMath for uint;

    struct UserStruct {
        uint index;
        bytes32 email;
        bytes32 firstName;
        bytes32 lastName;
        address[] placeId;
        address[] equipmentId;
    }

    event NewUser(address indexed _addr, uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event UpdateUser(address indexed _addr,  uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event DeleteUser(address indexed _addr,  uint _index);
    
    mapping(address => UserStruct) users;
    address[] private userIndex;

    function User() public {
    }

    modifier nonEmpty(bytes32 _str) {
        require(bytes32(_str).length > 5);
        _;
    }

    function existsUser(address _addr) public constant returns(bool isIndexed) {
        if(userIndex.length == 0) return false;
        return (userIndex[users[_addr].index] == _addr);
    }

    function newtUser(address _addr, bytes32 _email, bytes32 _firstName, bytes32 _lastName)
    nonEmpty(_email)
    onlyOwner
    public
    nonEmpty(_firstName)
    nonEmpty(_lastName)
    returns(uint index) {
        require(existsUser(_addr) == false);
        users[_addr].email = _email;
        users[_addr].firstName = _firstName;
        users[_addr].lastName = _lastName;
        users[_addr].index = userIndex.push(_addr) - 1;
        emit NewUser(_addr, users[_addr].index,  _email, _firstName, _lastName);
        return userIndex.length - 1;
    }

    function getUser(address _addr)
    onlyOwner
    onlyBy(_addr)
    public
    constant
    returns(uint index, bytes32 email, bytes32 firstName, bytes32 lastName) {
        require(existsUser(_addr) == true);
        return(
            users[_addr].index,
            users[_addr].email,
            users[_addr].firstName,
            users[_addr].lastName
        );
    }

    function updateUser(address _addr, bytes32 _email, bytes32 _firstName, bytes32 _lastName)
    onlyOwner
    onlyBy(_addr)
    public
    nonEmpty(_email)
    nonEmpty(_firstName)
    nonEmpty(_lastName)
    returns(bool) {
        require(existsUser(_addr) == true);
        users[_addr].email = _email;
        users[_addr].firstName = _firstName;
        users[_addr].lastName = _lastName;
        emit UpdateUser(_addr, users[_addr].index, _email, _firstName, _lastName);
        return true;
    }

    function deleteUser(address _addr)
    public
    onlyOwner
    onlyBy(_addr)
    returns(uint index) {
        require(existsUser(_addr) == true);
        uint _rowToDelete = users[_addr].index;
        address _keyToMove = userIndex[userIndex.length - 1];
        userIndex[_rowToDelete] = _keyToMove;
        users[_keyToMove].index = _rowToDelete; 
        userIndex.length--;
        emit DeleteUser(_addr, _rowToDelete);
        emit UpdateUser(_keyToMove, _rowToDelete, users[_keyToMove].email, users[_keyToMove].firstName, users[_keyToMove].lastName);
        return _rowToDelete;
    }

    function getUserCount() public constant returns(uint count) {
        return userIndex.length;
    }

    function getUserAtIndex(uint index)
    public
    onlyOwner
    constant returns(address _addr) {
        return userIndex[index];
    }
}
