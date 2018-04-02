pragma solidity ^0.4.19;

import "./zeppelin/SafeMath.sol";
import "./zeppelin/Ownable.sol";


contract Fees is Ownable {
    using SafeMath for uint;

    uint public fee = 0;
    uint energyPriceMarkup = 0;

    function Fees() public {
        fee = 100; // 100 = 0.1% in 1-digit precision
        energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision
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

    function setNewFee(uint _fee) public onlyOwner {
        fee = _fee;
    }

    function setPriceMarkup(uint _priceMarkup) public onlyOwner returns (uint) {
        energyPriceMarkup = _priceMarkup;
    }

}
