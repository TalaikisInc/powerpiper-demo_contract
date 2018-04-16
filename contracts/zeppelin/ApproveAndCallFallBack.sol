pragma solidity ^0.4.21;


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokensAmount, address tokenAddr, bytes data) public;
}
