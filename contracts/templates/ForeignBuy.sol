pragma solidity ^0.4.21;

import "./ICOState.sol";
import "./Ownable.sol";


contract ForeignBuy is Ownable, ICOState {

    event ForeignBuy(address _recipient, uint _tokens, string _txHash);

    function foreignBuy(address _recipient, uint _tokens, string _txHash) external botOnly {
        require(icoState == State.Running);
        require(_tokens > 0);
        // buy(_recipient, _tokens);
        emit ForeignBuy(_recipient, _tokens, _txHash);
    }

}
