pragma solidity ^0.4.19;

import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./User.sol";


contract Places is Ownable, User {
    using SafeMath for uint;

    struct PlaceStruct {
        uint index;
        uint8 msq;
        uint8 kwh;
        uint16 price;
        address userId;
    }

    event NewPlace(address indexed _addr, address indexed _userAddr, uint _index, uint8 _msq, uint8 _kwh, uint16 _price);
    event UpdatePlace(address indexed _addr, address indexed _userAddr, uint _index, uint8 _msq, uint8 _kwh, uint16 _price);
    event DeletePlace(address indexed _addr,  uint _index);
    
    mapping(address => PlaceStruct) places;
    address[] private placeIndex;

    function Places() public {
    }

    function existsPlace(address _addr) public constant returns(bool isIndexed) {
        if(placeIndex.length == 0) return false;
        return (placeIndex[places[_addr].index] == _addr);
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

    function getPlaceCount() public constant returns(uint count) {
        return placeIndex.length;
    }

    function getPlaceAtIndex(uint index) public constant returns(address _addr) {
        return placeIndex[index];
    }

}
