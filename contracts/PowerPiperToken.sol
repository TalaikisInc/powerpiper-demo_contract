pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
//import "./Convertlib.sol";
import "./zeppelin/Whitelist.sol";

contract PowerPiperToken is MintableToken, Whitelist, NoOwner {
    struct User {
        bytes32 name;
    }

    mapping (address => User) private users;

    string public constant NAME = "PowerPiperToken";
    string public constant SYMBOL = "PWP";
    uint8 public constant DECIMALS = 3;
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(DECIMALS));

    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    // verifies that the address is different than contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    function PowerPiperToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    /*function getBalanceInEth(address addr) public view returns(uint) {
        return Convertlib.convert(balanceOf(addr), 2);
    }*/

}
