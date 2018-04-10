pragma solidity ^0.4.21;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/SafeMath.sol";
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

contract PowerPiperToken is MintableToken, NoOwner, Management {

    using SafeMath for uint;

    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;
    uint public fee = 300; // 300 = 0.3% in 1-digit precision
    uint public energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision
    uint public rate = 3000;
    mapping (address => uint256) balances;
    uint256 public totalSupply;

    function PowerPiperToken(uint256 _initialAmount) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
    }

    function getEnergyPriceMarkup() public constant returns (uint) {
        return energyPriceMarkup;
    }

    function getRate() public constant returns (uint) {
        return rate;
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
