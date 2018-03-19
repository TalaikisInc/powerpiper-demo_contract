pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/HasNoEther.sol";
import "./zeppelin/HasNoContracts.sol";
//import "./zeppelin/HasNoTokens.sol"; // after NoEther
//import "./Convertlib.sol";
//import "./zeppelin/Whitelist.sol";

contract PowerPiperToken is MintableToken, HasNoEther, HasNoContracts, NoOwner {
    /*string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;
    uint256 public constant INITIAL_SUPPLY = 0;

    function PowerPiperToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }*/

    /*mapping (address => User) private users;

    
    uint256 public constant INITIAL_SUPPLY = 10000;

    function PowerPiperToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }*/

    /*function getBalanceInEth(address addr) public view returns(uint) {
        return Convertlib.convert(balanceOf(addr), 2);
    }*/

}
