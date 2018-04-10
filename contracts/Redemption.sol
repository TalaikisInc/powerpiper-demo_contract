pragma solidity ^0.4.21;

import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./PowerPiperToken.sol";
import "./Exchange.sol";


contract Redemptions is Ownable {
    using SafeMath for uint;

    struct Redemption {
        address redeemer;
        string location;
        uint amount;
        uint timestamp;
    }

    Redemption[] redemptions;
    PowerPiperToken _token;
    Exchange _exchange;
    event RedeemEvent(address _redeember, uint _amount, uint _timestamp);

    function redeem(uint _value, string _location) public returns (uint) {
        require(_token.balanceOf(msg.sender) >= _value);

        _token.approve(msg.sender, _value);
        _token.transferFrom(msg.sender, this, _value);

        Redemption memory redemption = Redemption({
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

        Redemption memory redemption = redemptions[_index];
        _exchange.destroyTokens(redemption.amount);

        redemptions[_index] = redemptions[redemptions.length-1];
        redemptions.length--;
    }

    function declineRedemption(uint _index) public onlyOwner {
        require(redemptions[_index].amount >= 0);

        Redemption memory redemption = redemptions[_index];
        _token.transfer(redemption.redeemer, redemption.amount);

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

}
