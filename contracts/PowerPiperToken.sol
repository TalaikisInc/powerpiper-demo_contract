pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/HasNoEther.sol";
import "./zeppelin/HasNoContracts.sol";
//import "./zeppelin/HasNoTokens.sol"; // after NoEther
//import "./Convertlib.sol";
//import "./zeppelin/Whitelist.sol";

contract PowerPiperToken is MintableToken, HasNoEther, HasNoContracts, NoOwner {
    struct pol {
        address receiver;
        uint initialBlockNumber;
    }

    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;
    event RecoverBalance(address indexed _owner, address indexed _receiver, bool _state);
    mapping (address => pol) public getPoL;

    /*uint256 public constant INITIAL_SUPPLY = 0;

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

    function existedPoL(address _owner) public returns (bool) {   
        pol _pol = getPoL[_owner];
        if (_pol.receiver == address(0) && _pol.initialBlockNumber == 0) {
            return false;
        }

        return true;
    }

    function recoverBalance(address _owner) public payable {
        require(msg.value > 0);
        require(!existedPoL(_owner));

        address _receiver = msg.sender;
        getPoL[_owner].receiver = _receiver;
        getPoL[_owner].initialBlockNumber = block.number;
        RecoverBalance(_owner, _receiver, true);
    }

}
