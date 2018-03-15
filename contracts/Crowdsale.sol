pragma solidity ^0.4.19;

import "./PWP.sol";
import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";


contract PWPCrowdsale is TimedCrowdsale, MintedCrowdsale, CappedCrowdsale {
    function PWPCrowdsale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, MintableToken _token, uint256 _cap) public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime) { }

}
