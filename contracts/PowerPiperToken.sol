pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./utils/ProofOfLoss.sol";

/*
@TODOs:
* equipment transfers
* insurance/ escrow
* can't be deleted before contract ends
* tests for all new functionality
* list of equipment/ providers
* list of places/ seekers
* geo-locations for places
* more throurough KYC
* privacy
* ...
*/

contract PowerPiperToken is MintableToken, NoOwner, ProofOfLoss {
    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;

    struct UserStruct {
        uint index;
        bytes32 email;
        bytes32 firstName;
        bytes32 lastName;
        address[] placeId;
        address[] equipmentId;
    }

    struct PlaceStruct {
        uint index;
        uint8 msq;
        uint8 kwh;
        uint16 price;
        address userId;
    }

    struct EquipmentStruct {
        uint index;
        uint8 kwh;
        uint16 price;
        address userId;
    }

    event NewUser(address indexed _addr, uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event NewPlace(address indexed _addr, address indexed _userAddr, uint _index, uint8 _msq, uint8 _kwh, uint16 _price);
    event NewEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint8 _kwh, uint16 _price);
    event UpdateUser(address indexed _addr,  uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event UpdatePlace(address indexed _addr, address indexed _userAddr, uint _index, uint8 _msq, uint8 _kwh, uint16 _price);
    event UpdateEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint8 _kwh, uint16 _price);
    event DeleteUser(address indexed _addr,  uint _index);
    event DeletePlace(address indexed _addr,  uint _index);
    event DeleteEquipment(address indexed _addr,  uint _index);
    
    mapping(address => UserStruct) users;
    mapping(address => PlaceStruct) places;
    mapping(address => EquipmentStruct) equipments;
    address[] private userIndex;
    address[] private placeIndex;
    address[] private equipmentIndex;

    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // @TODO
    modifier costs(uint _cost) {
        require(msg.value > _cost);
        _;
        if (msg.value > _cost) {
            msg.sender.transfer(_cost - msg.value);
        }
    }

    modifier nonEmpty(bytes32 _str) {
        require(bytes32(_str).length > 5);
        _;
    }

    function existsUser(address _addr) public constant returns(bool isIndexed) {
        if(userIndex.length == 0) return false;
        return (userIndex[users[_addr].index] == _addr);
    }

    function existsPlace(address _addr) public constant returns(bool isIndexed) {
        if(placeIndex.length == 0) return false;
        return (placeIndex[places[_addr].index] == _addr);
    }

    function existsEquipment(address _addr) public constant returns(bool isIndexed) {
        if(equipmentIndex.length == 0) return false;
        return (equipmentIndex[equipments[_addr].index] == _addr);
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
        NewUser(_addr, users[_addr].index,  _email, _firstName, _lastName);
        return userIndex.length - 1;
    }

    function newPlace(address _addr, address _userAddr, uint8 _msq, uint8 _kwh, uint16 _price)
    onlyOwner
    onlyBy(_userAddr)
    public
    returns(uint index) {
        require(existsPlace(_addr) == false);
        require(existsUser(_addr) == true);
        places[_addr].msq = _msq;
        places[_addr].kwh = _kwh;
        places[_addr].price = _price;
        places[_addr].userId = _userAddr;
        places[_addr].index = placeIndex.push(_addr) - 1;
        NewPlace(_addr, _userAddr, places[_addr].index,  _msq, _kwh, _price);
        users[_addr].placeId.push(_addr);
        return placeIndex.length - 1;
    }

    function newEquipment(address _addr, address _userAddr, uint8 _kwh, uint16 _price)
    onlyOwner
    onlyBy(_userAddr)
    public
    returns(uint index) {
        require(existsEquipment(_addr) == false);
        require(existsUser(_addr) == true);
        equipments[_addr].kwh = _kwh;
        equipments[_addr].price = _price;
        equipments[_addr].userId = _userAddr;
        equipments[_addr].index = equipmentIndex.push(_addr) - 1;
        NewEquipment(_addr, _userAddr, equipments[_addr].index, _kwh, _price);
        users[_addr].equipmentId.push(_addr);
        return placeIndex.length - 1;
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

    function getPlace(address _addr)
    public
    constant
    returns(uint index, uint8 msq, uint8 kwh, uint16 price, address userId) {
        require(existsPlace(_addr) == true);
        return(
            places[_addr].index,
            places[_addr].msq,
            places[_addr].kwh,
            places[_addr].price,
            places[_addr].userId
        );
    }

    function getEquipment(address _addr)
    public
    constant
    returns(uint index, uint8 kwh, uint16 price, address userId) {
        require(existsEquipment(_addr) == true);
        return(
            places[_addr].index,
            places[_addr].kwh,
            places[_addr].price,
            places[_addr].userId
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
        UpdateUser(_addr, users[_addr].index, _email, _firstName, _lastName);
        return true;
    }

    function updatePlace(address _addr, address _userAddr, uint8 _msq, uint8 _kwh, uint16 _price)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(bool) {
        require(existsPlace(_addr) == true);
        require(existsUser(_userAddr) == true);
        places[_addr].msq = _msq;
        places[_addr].kwh = _kwh;
        places[_addr].price = _price;
        UpdatePlace(_addr, _userAddr, places[_addr].index, _msq, _kwh, _price);
        return true;
    }

    function updateEquipment(address _addr, address _userAddr, uint8 _kwh, uint16 _price)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(bool) {
        require(existsEquipment(_addr) == true);
        require(existsUser(_userAddr) == true);
        equipments[_addr].kwh = _kwh;
        equipments[_addr].price = _price;
        UpdateEquipment(_addr, _userAddr, equipments[_addr].index, _kwh, _price);
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
        DeleteUser(_addr, _rowToDelete);
        UpdateUser(_keyToMove, _rowToDelete, users[_keyToMove].email, users[_keyToMove].firstName, users[_keyToMove].lastName);
        return _rowToDelete;
    }

    function deletePlace(address _addr, address _userAddr)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(uint index) {
        require(existsPlace(_addr) == true);
        uint _rowToDelete = places[_addr].index;
        address _keyToMove = placeIndex[placeIndex.length - 1];
        placeIndex[_rowToDelete] = _keyToMove;
        places[_keyToMove].index = _rowToDelete; 
        placeIndex.length--;
        DeletePlace(_addr, _rowToDelete);
        UpdatePlace(_keyToMove, places[_keyToMove].userId, _rowToDelete, places[_keyToMove].msq, places[_keyToMove].kwh, places[_keyToMove].price);
        return _rowToDelete;
    }

    function deleteEquipment(address _addr, address _userAddr)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(uint index) {
        require(existsEquipment(_addr) == true);
        uint _rowToDelete = equipments[_addr].index;
        address _keyToMove = equipmentIndex[equipmentIndex.length - 1];
        equipmentIndex[_rowToDelete] = _keyToMove;
        equipments[_keyToMove].index = _rowToDelete; 
        equipmentIndex.length--;
        DeleteEquipment(_addr, _rowToDelete);
        UpdateEquipment(_keyToMove, equipments[_keyToMove].userId, _rowToDelete, equipments[_keyToMove].kwh, equipments[_keyToMove].price);
        return _rowToDelete;
    }

    function getUserCount() public constant returns(uint count) {
        return userIndex.length;
    }

    function getPlaceCount() public constant returns(uint count) {
        return placeIndex.length;
    }

    function getEquipmentCount() public constant returns(uint count) {
        return equipmentIndex.length;
    }

    function getUserAtIndex(uint index)
    public
    onlyOwner
    constant returns(address _addr) {
        return userIndex[index];
    }

    function getPlaceAtIndex(uint index) public  constant returns(address _addr) {
        return placeIndex[index];
    }

    function getEquipmentAtIndex(uint index) public  constant returns(address _addr) {
        return equipmentIndex[index];
    }

}
