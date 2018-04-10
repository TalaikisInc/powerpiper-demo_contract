pragma solidity ^0.4.21;

import "./zeppelin/MintedCrowdsale.sol";
import "./zeppelin/CappedCrowdsale.sol";
import "./zeppelin/RefundableCrowdsale.sol";
import "./zeppelin/SafeMath.sol";


contract PowerPiperCrowdsale is CappedCrowdsale, RefundableCrowdsale, MintedCrowdsale {

    using SafeMath for uint256;

    uint public constant decimals = 3;

    function PowerPiperCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        uint256 _cap,
        address _wallet,
        MintableToken _token,
        uint256 _goal) public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_startTime, _endTime)
    RefundableCrowdsale(_goal)
    {
        require(_goal <= _cap);
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
