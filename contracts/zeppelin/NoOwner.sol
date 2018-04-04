pragma solidity ^0.4.19;

import "./HasNoEther.sol";
import "./HasNoTokens.sol";
import "./HasNoContracts.sol";


contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}
