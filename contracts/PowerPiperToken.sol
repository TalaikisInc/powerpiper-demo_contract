pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/SafeMath.sol";
import "./utils/ProofOfLoss.sol";
import "./Management.sol";

/*
@TODOs:
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
    // should adjust depentend on orders and redeems
    uint public reserves = 100000000000;
    // this sets count of all tokens, including team and bonuses, totalSupply represents only available for sale
    // hould include minting of additonal tokens to crowdsale finalization
    uint public availableTokens = 1000000000;

    //those are defined in migrations or crowdsale creation react component
    //string public constant name = "PowerPiperToken";
    //string public constant symbol = "PWP";
    //uint8 public constant decimals = 3;
    uint public fee = 300; // 300 = 0.3% in 1-digit precision
    uint public energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision

    /*
    @TODO
    TEMPORAL for testing purposes ONLY!!!!
    */
    // mapping(address => bool) public owners;

    /*function OwnableMultiple() public {
        owners[msg.sender] = true;
    }

    function validate(address addr) public constant returns (bool) {
        return owners[addr];
    }

    function addOwner(address addr) public {
        if(owners[msg.sender])
            owners[addr] = true;
    }

    function removeOwner(address addr) public {
        if (owners[msg.sender])
            owners[addr] = false;
    }*/

    /*
    End for testinjg purposes only
    */

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

    function getEnergyReserves() public constant returns (uint) {
        return reserves;
    }

    function tokensSupplyAvailable() public constant returns (int) {
        return int(availableTokens) - int(totalSupply());
    }

}
