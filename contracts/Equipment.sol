pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./User.sol";


contract Equipments is Ownable, User {
    using SafeMath for uint;

    struct EquipmentStruct {
        uint index;
        uint8 kwh;
        uint16 price;
        address userId;
    }

    event NewEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint8 _kwh, uint16 _price);
    event UpdateEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint8 _kwh, uint16 _price);
    event DeleteEquipment(address indexed _addr,  uint _index);
    
    mapping(address => EquipmentStruct) equipments;
    address[] private equipmentIndex;

    function Equipments() public {
    }

    function existsEquipment(address _addr) public constant returns(bool isIndexed) {
        if(equipmentIndex.length == 0) return false;
        return (equipmentIndex[equipments[_addr].index] == _addr);
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
        return equipmentIndex.length - 1;
    }

    function getEquipment(address _addr)
    public
    constant
    returns(uint index, uint8 kwh, uint16 price, address userId) {
        require(existsEquipment(_addr) == true);
        return(
            equipments[_addr].index,
            equipments[_addr].kwh,
            equipments[_addr].price,
            equipments[_addr].userId
        );
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

    function getEquipmentCount() public constant returns(uint count) {
        return equipmentIndex.length;
    }

    function getEquipmentAtIndex(uint index) public  constant returns(address _addr) {
        return equipmentIndex[index];
    }

}
