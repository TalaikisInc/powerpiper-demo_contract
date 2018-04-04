pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/SafeMath.sol";
import "./utils/ProofOfLoss.sol";
import "./Management.sol";

/*
@TODOs:
* adding Management -> +4 failing crowdsale tests
* equipment transfers (?)
* insurance/ escrow
* can't be deleted before contract ends
* ensure contract time-dependency
* getByLocation, getByKWh, ...
* more throurough KYC
* tests
* privacy checks
* encrypt sensitive user data (crypto.js or better)
* ...
*/

contract PowerPiperToken is MintableToken, NoOwner, ProofOfLoss, Management {

    using SafeMath for uint;

    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;
    uint public fee = 300; // 300 = 0.3% in 1-digit precision
    uint public energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision

    function getEnergyPriceMarkup() public constant returns (uint) {
        return energyPriceMarkup;
    }

    function getFee() public constant returns (uint) {
        return fee;
    }

    function calculateFee(uint _amount) public view returns (uint) {
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
