pragma solidity ^0.4.21;

import "./Ownable.sol";


contract HasNoEther is Ownable {

    function HasNoEther() public payable {
        require(msg.value == 0);
    }

    function() external {
    }

    function reclaimEther() external onlyOwner {
        assert(owner.send(address(this).balance));
    }

}
