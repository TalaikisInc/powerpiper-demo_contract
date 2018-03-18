pragma solidity ^0.4.19;

//import "./zeppelin/MintedCrowdsale.sol";
// import "./zeppelin/WhitelistedCrowdsale.sol";
// import "./zeppelin/IncreasingPriceCrowdsale.sol";
import "./zeppelin/TimedCrowdsale.sol";
import "./PowerPiperToken.sol";
import "./zeppelin/CappedCrowdsale.sol";
import "./zeppelin/FinalizableCrowdsale.sol";

contract PowerPiperCrowdsale is CappedCrowdsale, FinalizableCrowdsale {
    function PowerPiperCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet, MintableToken _token) public
    CappedCrowdsale(_cap)
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_startTime, _endTime)
    {
    }

    function createTokenContract() internal returns (MintableToken) {
        return new PowerPiperToken();
    }

}
