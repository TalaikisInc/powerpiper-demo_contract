pragma solidity ^0.4.19;

import "./zeppelin/MintedCrowdsale.sol";
import "./zeppelin/CappedCrowdsale.sol";
import "./zeppelin/RefundableCrowdsale.sol";
import "./zeppelin/SafeMath.sol";
import "./PowerPiperToken.sol";


contract PowerPiperCrowdsale is CappedCrowdsale, RefundableCrowdsale, MintedCrowdsale {
    using SafeMath for uint;

    struct Order {
        address buyer;
        uint amount;
        uint timestamp;
    }

    struct Certificate {
        bytes32 url;
        uint amount;
        uint timestamp;
    }

    struct Redemption {
        address redeemer;
        string location;
        uint amount;
        uint timestamp;
    }

    PowerPiperToken public token;
    Order[] orders;
    Redemption[] redemptions;
    Certificate[] certificates;
    uint public fee = 0;
    uint reserves = 0;
    uint availableTokens = 0;
    uint energyPriceMarkup = 0;

    event BuyDirectEvent(address _buyer, uint _amount, uint _timestamp);
    event RedeemEvent(address _redeember, uint _amount, uint _timestamp);

    function PowerPiperCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet, MintableToken _token, uint256 _goal) public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_startTime, _endTime)
    RefundableCrowdsale(_goal)
    {
        require(_goal <= _cap);
        fee = 100; // 100 = 0.1% in 1-digit precision
        energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision
    }

    function addCertificate(bytes32 _url, uint _amount) public onlyOwner {
        Certificate memory certificate = Certificate({
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

    function getReserves() public constant returns (uint) {
        return reserves;
    }

    function getEnergyPriceMarkup() public constant returns (uint) {
        return energyPriceMarkup;
    }

    function calculateFee(uint _amount) public constant returns (uint) {
        uint feeAmount = _amount * fee / 1000;

        if (feeAmount == 0) {
            return 1;
        } else {
            return feeAmount;
        }
    }

    function getCertificate(uint _index) public constant onlyOwner returns (bytes32, uint, uint) {
        Certificate memory certificate = certificates[_index];
        return (
            certificate.url,
            certificate.amount,
            certificate.timestamp
        );
    }

    function buyDirect() public payable {
        require(msg.value > 0);

        Order memory order = Order({
            buyer: msg.sender,
            amount: msg.value,
            timestamp: now
        });

        orders.push(order);

        BuyDirectEvent(order.buyer, order.amount, order.timestamp);
    }

    function redeem(uint _value, string _location) public returns (uint) {
        require(token.balanceOf(msg.sender) >= _value);

        token.approve(msg.sender, _value);
        token.transferFrom(msg.sender, this, _value);

        Redemption memory redemption = Redemption({
            redeemer: msg.sender,
            amount: _value,
            location: _location,
            timestamp: now
        });

        redemptions.push(redemption);

        RedeemEvent(redemption.redeemer, redemption.amount, redemption.timestamp);
    }

    function tokensSupplyAvailable() public constant returns (int) {
        return int(availableTokens) - int(token.totalSupply());
    }

    function deleteCertificate(uint _index) public onlyOwner {
        require(certificates[_index].amount >= 0);

        reserves = reserves.sub(certificates[_index].amount);

        certificates[_index] = certificates[certificates.length-1];
        certificates.length--;
    }

    function setAvailableTokens(uint _availableTokens) public onlyOwner {
        availableTokens = _availableTokens;
    }

    function setNewFee(uint _fee) public onlyOwner {
        fee = _fee;
    }

    function setPriceMarkup(uint _priceMarkup) public onlyOwner returns (uint) {
        energyPriceMarkup = _priceMarkup;
    }

    function approveRedemption(uint _index) public onlyOwner {
        require(redemptions[_index].amount >= 0);

        Redemption memory redemption = redemptions[_index];
        token.destroyTokens(redemption.amount);

        redemptions[_index] = redemptions[redemptions.length-1];
        redemptions.length--;
    }

    function declineRedemption(uint _index) public onlyOwner {
        require(redemptions[_index].amount >= 0);

        Redemption memory redemption = redemptions[_index];
        token.transfer(redemption.redeemer, redemption.amount);

        redemptions[_index] = redemptions[redemptions.length-1];
        redemptions.length--;
    }

    function getRedemptionsLength() public constant onlyOwner returns (uint) {
        return redemptions.length;
    }

    function getRedemption(uint _index) public constant onlyOwner returns (address, uint, string, uint) {
        Redemption memory redemption = redemptions[_index];
        return (
            redemption.redeemer,
            redemption.amount,
            redemption.location,
            redemption.timestamp
        );
    }

    function getOrder(uint _index) public constant onlyOwner returns (address, uint, uint) {
        Order memory order = orders[_index];
        return (order.buyer, order.amount, order.timestamp);
    }

    function approveOrder(uint _index, uint _amount) public onlyOwner {
        require(orders[_index].amount >= 0);

        Order memory order = orders[_index];

        if (token.users[order.buyer] == false) {
            uint feeAmount = calculateFee(_amount);
            _amount = _amount.sub(feeAmount);
            token.mint(this, feeAmount);
            token.users[order.buyer] = true;
        }

        token.mint(order.buyer, _amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function declineOrder(uint _index) public onlyOwner {
        require(orders[_index].amount >= 0);

        Order memory order = orders[_index];
        order.buyer.transfer(order.amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function getOrdersLength() public constant onlyOwner returns (uint) {
        return orders.length;
    }

    function hasEnded() public view returns (bool) {
        return super.hasClosed();
    }

    function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
        return super._getTokenAmount(weiAmount);
    }

    function forwardFunds() internal {
        return super._forwardFunds();
    }

}
