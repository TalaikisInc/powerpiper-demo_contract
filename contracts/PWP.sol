pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

import './ConvertLib.sol';

contract PowerPiperToken is StandardToken {
    string public constant name = 'PowerPiperToken';
    string public constant symbol = 'PWP';
    uint8 public constant decimals = 2;
    uint public constant initialSupply = 1000000;
    mapping (address => uint) private balances;
    address public owner;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function PowerPiperToken() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
    }

    function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Transfer(msg.sender, receiver, amount);
        return true;
    }

    function getBalanceInEth(address addr) public view returns(uint) {
        return ConvertLib.convert(getBalance(addr), 2);
    }

    function getBalance(address addr) public view returns(uint) {
        return balances[addr];
    }

}
