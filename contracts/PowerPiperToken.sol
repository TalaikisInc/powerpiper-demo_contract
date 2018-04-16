pragma solidity ^0.4.21;

import "./zeppelin/SafeMath.sol";
import "./zeppelin/Ownable.sol";
import "./zeppelin/ERC20.sol";


contract PowerPiperToken is ERC20, Ownable {

    using SafeMath for uint;

    struct RedemptionStruct {
        address redeemer;
        string location;
        uint amount;
        uint timestamp;
    }

    struct OrderStruct {
        address buyer;
        uint amount;
        uint timestamp;
    }

    struct Cert {
        bytes32 url;
        uint amount;
        uint timestamp;
    }

    struct EquipmentStruct {
        uint index;
        uint kwh;
        uint price;
        address userId;
    }

    struct PlaceStruct {
        uint index;
        uint msq;
        uint kwh;
        uint price;
        address userId;
    }

    struct UserStruct {
        uint index;
        bytes32 email;
        bytes32 firstName;
        bytes32 lastName;
        address[] placeId;
        address[] equipmentId;
    }

    bytes32 public name;
    bytes32 public symbol;
    uint public decimals;
    uint public fee;
    uint public priceMarkup;
    uint _totalSupply;
    mapping(address => mapping(address => uint)) internal allowed;
    bool public mintingFinished = false;
    uint public reserves = 0;
    RedemptionStruct[] redemptions;
    OrderStruct[] orders;
    Cert[] certificates;
    mapping(address => EquipmentStruct) equipments;
    address[] private equipmentIndex;
    mapping(address => PlaceStruct) places;
    address[] private placeIndex;
    mapping(address => UserStruct) users;
    address[] private userIndex;

    event Mint(address indexed to, uint amount);
    event MintFinished();
    event DestroyTokens(address indexed _from, uint _value);
    event RedeemEvent(address _redeember, uint _amount, uint _timestamp);
    event BuyDirectEvent(address _buyer, uint _amount, uint _timestamp);
    event NewEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint _kwh, uint _price);
    event UpdateEquipment(address indexed _addr, address indexed _userAddr, uint _index, uint _kwh, uint _price);
    event DeleteEquipment(address indexed _addr,  uint _index);
    event NewPlace(address indexed _addr, address indexed _userAddr, uint _index, uint _msq, uint _kwh, uint _price);
    event UpdatePlace(address indexed _addr, address indexed _userAddr, uint _index, uint _msq, uint _kwh, uint _price);
    event DeletePlace(address indexed _addr,  uint _index);
    event NewUser(address indexed _addr, uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event UpdateUser(address indexed _addr,  uint _index, bytes32 _email, bytes32 _firstName, bytes32 _lastName);
    event DeleteUser(address indexed _addr,  uint _index);

    function PowerPiperToken() public {
        symbol = "PWP";
        name = "PowerPiperToken";
        decimals = 3;
        fee = 1 * 10 ** decimals; // 1%
        priceMarkup = 5 * 10 ** decimals; // 5%
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier nonEmpty(bytes32 _str) {
        require(bytes32(_str).length > 5);
        _;
    }

    function balanceOf(address _tokenOwner) public constant returns (uint balance) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint _tokens) public returns (bool success) {
        require(_to != address(0));
        require(_tokens <= balances[msg.sender] && _tokens > 0);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _tokens);
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _spender, uint _tokens) public returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public returns (bool success) {
        require(_to != address(0));
        require(_tokens <= balances[_from]);
        require(_tokens <= allowed[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _tokens);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _tokens);
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        emit Transfer(_from, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender) public constant returns (uint remaining) {
        return allowed[_tokenOwner][_spender];
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function calculateFee(uint _amount) public view returns (uint) {
        uint feeAmount = _amount * fee / (10 ** decimals);

        if (feeAmount == 0) {
            return 1;
        } else {
            return feeAmount;
        }
    }

    function setNewFee(uint _fee) public onlyOwner {
        fee = _fee;
    }

    function setPriceMarkup(uint _priceMarkup) public onlyOwner {
        priceMarkup = _priceMarkup;
    }

    function mint(address _to, uint _amount) canMint public returns (bool) {
        _totalSupply = SafeMath.add(_totalSupply, _amount);
        balances[_to] = SafeMath.add(balances[_to], _amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    function destroyTokens(uint _amount) onlyOwner public {
        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);
        _totalSupply = SafeMath.sub(_totalSupply, _amount);

        emit DestroyTokens(msg.sender, _amount);
    }

    function redeem(uint _value, string _location) public returns (uint) {
        require(balanceOf(msg.sender) >= _value);

        approve(msg.sender, _value);
        transferFrom(msg.sender, address(this), _value);

        RedemptionStruct memory redemption = RedemptionStruct({
            redeemer: msg.sender,
            amount: _value,
            location: _location,
            timestamp: now
        });

        redemptions.push(redemption);

        emit RedeemEvent(redemption.redeemer, redemption.amount, redemption.timestamp);
    }

    function approveRedemption(uint _index) public onlyOwner {
        require(redemptions[_index].amount >= 0);

        RedemptionStruct memory redemption = redemptions[_index];
        destroyTokens(redemption.amount);

        redemptions[_index] = redemptions[redemptions.length-1];
        redemptions.length--;
    }

    function declineRedemption(uint _index) public onlyOwner {
        require(redemptions[_index].amount >= 0);

        RedemptionStruct memory redemption = redemptions[_index];
        transfer(redemption.redeemer, redemption.amount);

        redemptions[_index] = redemptions[redemptions.length-1];
        redemptions.length--;
    }

    function getRedemptionsLength() public constant onlyOwner returns (uint) {
        return redemptions.length;
    }

    function getRedemption(uint _index) public constant onlyOwner returns (address, uint, string, uint) {
        RedemptionStruct memory redemption = redemptions[_index];
        return (
            redemption.redeemer,
            redemption.amount,
            redemption.location,
            redemption.timestamp
        );
    }

    function getOrder(uint _index) public constant onlyOwner returns (address, uint, uint) {
        OrderStruct memory order = orders[_index];
        return (order.buyer, order.amount, order.timestamp);
    }

    function approveOrder(uint _index, uint _amount) public onlyOwner {
        require(orders[_index].amount >= 0);

        OrderStruct memory order = orders[_index];

        uint feeAmount = calculateFee(_amount);
        _amount = _amount.sub(feeAmount);
        mint(this, feeAmount);

        mint(order.buyer, _amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function declineOrder(uint _index) public onlyOwner {
        require(orders[_index].amount >= 0);

        OrderStruct memory order = orders[_index];
        order.buyer.transfer(order.amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function getOrdersLength() public constant onlyOwner returns (uint) {
        return orders.length;
    }

    function buyDirect() public payable {
        require(msg.value > 0);

        OrderStruct memory order = OrderStruct({
            buyer: msg.sender,
            amount: msg.value,
            timestamp: now
        });

        orders.push(order);

        emit BuyDirectEvent(order.buyer, order.amount, order.timestamp);
    }

    function addCertificate(bytes32 _url, uint _amount) public onlyOwner {
        Cert memory certificate = Cert({
            url: _url,
            amount: _amount,
            timestamp: now
        });

        reserves = reserves.add(certificate.amount);

        certificates.push(certificate);
    }

    function getCertificatesLength() public constant onlyOwner returns (uint) {
        return certificates.length;
    }

    function getCertificate(uint _index) public constant onlyOwner returns (bytes32, uint, uint) {
        Cert memory certificate = certificates[_index];
        return (
            certificate.url,
            certificate.amount,
            certificate.timestamp
        );
    }

    function deleteCertificate(uint _index) public onlyOwner {
        require(certificates[_index].amount >= 0);

        reserves = reserves.sub(certificates[_index].amount);

        certificates[_index] = certificates[certificates.length-1];
        certificates.length--;
    }

    function existsEquipment(address _addr) public constant returns(bool isIndexed) {
        if(equipmentIndex.length == 0) return false;
        return (equipmentIndex[equipments[_addr].index] == _addr);
    }

    function newEquipment(address _addr, address _userAddr, uint _kwh, uint _price)
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
        emit NewEquipment(_addr, _userAddr, equipments[_addr].index, _kwh, _price);
        users[_addr].equipmentId.push(_addr);
        return equipmentIndex.length - 1;
    }

    function getEquipment(address _addr)
    public
    constant
    returns(uint index, uint kwh, uint price, address userId) {
        require(existsEquipment(_addr) == true);
        return(
            equipments[_addr].index,
            equipments[_addr].kwh,
            equipments[_addr].price,
            equipments[_addr].userId
        );
    }

    function updateEquipment(address _addr, address _userAddr, uint _kwh, uint _price)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(bool) {
        require(existsEquipment(_addr) == true);
        require(existsUser(_userAddr) == true);
        equipments[_addr].kwh = _kwh;
        equipments[_addr].price = _price;
        emit UpdateEquipment(_addr, _userAddr, equipments[_addr].index, _kwh, _price);
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
        emit DeleteEquipment(_addr, _rowToDelete);
        emit UpdateEquipment(_keyToMove, equipments[_keyToMove].userId, _rowToDelete, equipments[_keyToMove].kwh, equipments[_keyToMove].price);
        return _rowToDelete;
    }

    function getEquipmentCount() public constant returns(uint count) {
        return equipmentIndex.length;
    }

    function getEquipmentAtIndex(uint index) public  constant returns(address _addr) {
        return equipmentIndex[index];
    }

    function existsPlace(address _addr) public constant returns(bool isIndexed) {
        if(placeIndex.length == 0) return false;
        return (placeIndex[places[_addr].index] == _addr);
    }

    function newPlace(address _addr, address _userAddr, uint _msq, uint _kwh, uint _price)
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
        emit NewPlace(_addr, _userAddr, places[_addr].index,  _msq, _kwh, _price);
        users[_addr].placeId.push(_addr);
        return placeIndex.length - 1;
    }

    function getPlace(address _addr)
    public
    constant
    returns(uint index, uint msq, uint kwh, uint price, address userId) {
        require(existsPlace(_addr) == true);
        return(
            places[_addr].index,
            places[_addr].msq,
            places[_addr].kwh,
            places[_addr].price,
            places[_addr].userId
        );
    }

    function updatePlace(address _addr, address _userAddr, uint _msq, uint _kwh, uint _price)
    public
    onlyOwner
    onlyBy(_userAddr)
    returns(bool) {
        require(existsPlace(_addr) == true);
        require(existsUser(_userAddr) == true);
        places[_addr].msq = _msq;
        places[_addr].kwh = _kwh;
        places[_addr].price = _price;
        emit UpdatePlace(_addr, _userAddr, places[_addr].index, _msq, _kwh, _price);
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
        emit DeletePlace(_addr, _rowToDelete);
        emit UpdatePlace(_keyToMove, places[_keyToMove].userId, _rowToDelete, places[_keyToMove].msq, places[_keyToMove].kwh, places[_keyToMove].price);
        return _rowToDelete;
    }

    function getPlaceCount() public constant returns(uint count) {
        return placeIndex.length;
    }

    function getPlaceAtIndex(uint index) public constant returns(address _addr) {
        return placeIndex[index];
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
