pragma solidity ^0.4.21;


contract StopInEmergency {

    bool private stopped = false;
    address private owner;

    modifier isAdmin() {
        require(msg.sender == owner);
        _;
    }

    modifier stopInEmergency {
        if (!stopped) _;
    }

    modifier onlyInEmergency {
        if (stopped) _;
    }

}
