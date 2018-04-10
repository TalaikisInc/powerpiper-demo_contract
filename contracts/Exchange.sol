pragma solidity ^0.4.21;

import "./zeppelin/SafeMath.sol";
import "./Order.sol";
import "./Certificate.sol";
import "./Redemption.sol";
import "./PowerPiperToken.sol";


contract Exchange is Orders, Certificates, Redemptions {
    using SafeMath for uint;

    PowerPiperToken public token;
    uint256 _supply = 0;
    uint fee  = 1;
    mapping(address => uint) balances;
    event DestroyTokensEvent(address indexed _from, uint _value);
    // uint public fee = 300; // 300 = 0.3% in 1-digit precision
    // uint public energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision

    // @TODO fee functions duplicate with Token, should be united
    function Exchange(address _tokenAddress) public {
        token = PowerPiperToken(_tokenAddress);
        // fee = 300; // 300 = 0.3% in 1-digit precision
        // energyPriceMarkup = 1000; // 1000 = 1% in 3-digit precision
    }

    function destroyTokens(uint _value) external {
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        _supply = _supply.sub(_value);

        emit DestroyTokensEvent(msg.sender, _value);
    }

    function calculateFee(uint _amount) public constant returns (uint) {
        uint feeAmount = _amount * fee / 1000;

        if (feeAmount == 0) {
            return 1;
        } else {
            return feeAmount;
        }
    }

}
