pragma solidity ^0.4.21;

import "../zeppelin/Ownable.sol";

contract Relay is Ownable {
    address public currentVersion;

    function Relay(address initAddr) public {
        currentVersion = initAddr;
    }

    function changeContract(address newVersion) public onlyOwner {
        currentVersion = newVersion;
    }

    function () external {
        require(currentVersion.delegatecall(msg.data));
    }

}
