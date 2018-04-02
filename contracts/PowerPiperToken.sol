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
* ...
*/

contract PowerPiperToken is MintableToken, NoOwner, ProofOfLoss, Management {
    using SafeMath for uint;

    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;
    // @TODO to remove, it moved to Exchangew
    uint256 _supply = 0;

    event DestroyTokensEvent(address indexed _from, uint _value);
    mapping(address => uint) balances;

    // @TODO to remove, it moved to Exchangew
    function totalSupply() public constant returns (uint) {
        return _supply;
    }

    function destroyTokens(uint _value) external {
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        _supply = _supply.sub(_value);

        DestroyTokensEvent(msg.sender, _value);
    }

}
