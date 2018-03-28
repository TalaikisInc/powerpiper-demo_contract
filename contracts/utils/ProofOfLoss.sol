pragma solidity ^0.4.19;


contract ProofOfLoss {
    struct LossStruct {
        address receiver;
        uint initialBlockNumber;
    }

    event RecoverBalance(address indexed _owner, address indexed _receiver, bool _state);
    mapping (address => LossStruct) public getLoss;

    function existedLoss(address _owner) public view returns (bool) {   
        LossStruct storage _loss = getLoss[_owner];
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
