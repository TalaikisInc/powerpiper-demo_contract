pragma solidity ^0.4.21;

import "./TimedCrowdsale.sol";
import "./SafeMath.sol";


contract IncreasingPriceCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    uint256 public initialRate;
    uint256 public finalRate;

    function IncreasingPriceCrowdsale(uint256 _initialRate, uint256 _finalRate) public {
        require(_initialRate >= _finalRate);
        require(_finalRate > 0);
        initialRate = _initialRate;
        finalRate = _finalRate;
    }

    function getCurrentRate() public view returns (uint256) {
        uint256 elapsedTime = now.sub(openingTime);
        uint256 timeRange = closingTime.sub(openingTime);
        uint256 rateRange = initialRate.sub(finalRate);
        return initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount);
    }
}
