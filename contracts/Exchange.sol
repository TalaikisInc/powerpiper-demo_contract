pragma solidity ^0.4.19;

import "./zeppelin/SafeMath.sol";
import "./Order.sol";
import "./Certificate.sol";
import "./Redemption.sol";
import "./PowerPiperToken.sol";


contract Exchange is Orders, Certificates, Redemptions, PowerPiperToken {
    using SafeMath for uint;

    uint public reserves = 0;
    uint availableTokens = 0;
    
    function getReserves() public constant returns (uint) {
        return reserves;
    }

    function tokensSupplyAvailable() public constant returns (int) {
        return int(availableTokens) - int(totalSupply());
    }

    function setAvailableTokens(uint _availableTokens) public onlyOwner {
        availableTokens = _availableTokens;
    }

}
