pragma solidity ^0.4.21;


contract Relay {
    address public currentVersion;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Relay(address initAddr) public {
        currentVersion = initAddr;
        owner = msg.sender;
    }

    function changeContract(address newVersion) public onlyOwner() {
        currentVersion = newVersion;
    }

    function () external {
        require(currentVersion.delegatecall(msg.data));
    }
}
