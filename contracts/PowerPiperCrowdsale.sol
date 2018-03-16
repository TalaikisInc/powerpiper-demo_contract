pragma solidity ^0.4.19;

import "./PowerPiperToken.sol";
import "./zeppelin/MintedCrowdsale.sol";
import "./zeppelin/TimedCrowdsale.sol";
import "./zeppelin/CappedCrowdsale.sol";
// import "./zeppelin/WhitelistedCrowdsale.sol";
// import "./zeppelin/IncreasingPriceCrowdsale.sol";

contract PowerPiperCrowdsale is TimedCrowdsale, MintedCrowdsale, CappedCrowdsale {
    function PowerPiperCrowdsale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, MintableToken _token, uint256 _cap) public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    {

    }

    function createTokenContract() internal returns (MintableToken) {
        return new PowerPiperToken();
    }

}
