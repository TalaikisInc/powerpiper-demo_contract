pragma solidity ^0.4.19;

import "./zeppelin/MintableToken.sol";
import "./zeppelin/NoOwner.sol";
import "./zeppelin/HasNoEther.sol";
import "./zeppelin/HasNoContracts.sol";


contract PowerPiperToken is MintableToken, HasNoEther, HasNoContracts, NoOwner {
    struct Loss {
        address receiver;
        uint initialBlockNumber;
    }

    string public constant name = "PowerPiperToken";
    string public constant symbol = "PWP";
    uint8 public constant decimals = 3;

    event RecoverBalance(address indexed _owner, address indexed _receiver, bool _state);
    mapping (address => Loss) public getLoss;

    function existedLoss(address _owner) public view returns (bool) {   
        Loss storage _loss = getLoss[_owner];
        if (_loss.receiver == address(0) && _loss.initialBlockNumber == 0) {
            return false;
        }

        return true;
    }

    function recoverBalance(address _owner) public payable {
        require(msg.value > 0);
        require(!existedLoss(_owner));

        address _receiver = msg.sender;
        getLoss[_owner].receiver = _receiver;
        getLoss[_owner].initialBlockNumber = block.number;
        RecoverBalance(_owner, _receiver, true);
    }

}
