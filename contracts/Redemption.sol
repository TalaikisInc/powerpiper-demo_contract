pragma solidity ^0.4.19;

import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./PowerPiperToken.sol";


contract Redemptions is Ownable {
    using SafeMath for uint;

    struct Redemption {
        address redeemer;
        string location;
        uint amount;
        uint timestamp;
    }

    Redemption[] redemptions;
    PowerPiperToken public token;
    event RedeemEvent(address _redeember, uint _amount, uint _timestamp);

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

}
