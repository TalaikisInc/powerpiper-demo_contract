pragma solidity ^0.4.21;

import "./zeppelin/Ownable.sol";
import "./zeppelin/ERC20.sol";
import "./zeppelin/ApproveAndCallFallBack.sol";
import "./zeppelin/SafeMath.sol";

contract PowerPiperCrowdsale is ERC20, Ownable {

    bytes32 public symbol;
    bytes32 public  tokenName;
    uint8 public decimals;
    uint public _totalSupply;
    uint public startDate;
    uint public bonusEnds;
    uint public endDate;
    uint public rate;
    uint public bonusRate;
    uint public cap;
    uint public weiRaised;
    bool private reentrancyLock = false;
    mapping(address => mapping(address => uint)) internal allowed;
    mapping(address => bool) internal whitelist;

    modifier isWhitelisted(address _beneficiary) {
        require(whitelist[_beneficiary]);
        _;
    }

    function PowerPiperCrowdsale() public {
        symbol = "PWP";
        tokenName = "PowerPiperToken";
        decimals = 3;
        startDate = now + 200 seconds;
        bonusEnds = now + 1 weeks;
        endDate = now + 7 weeks;
        rate = 5000;
        cap = 100 ether;
        bonusRate = 6000;
    }

    function hasClosed() public view returns (bool) {
        return now > endDate;
    }

    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address _tokenOwner) public constant returns (uint balance) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint _tokens) public returns (bool success) {
        require(_to != address(0));
        require(_tokens <= balances[msg.sender] && _tokens > 0);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _tokens);
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _spender, uint _tokens) public returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public returns (bool success) {
        require(_to != address(0));
        require(_tokens <= balances[_from]);
        require(_tokens <= allowed[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _tokens);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _tokens);
        balances[_to] = SafeMath.add(balances[_to], _tokens);
        emit Transfer(_from, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender) public constant returns (uint remaining) {
        return allowed[_tokenOwner][_spender];
    }

    function approveAndCall(address _spender, uint _tokens, bytes _data) public returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _tokens, this, _data);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function () public payable { // isWhitelisted(_beneficiary) - disabled temporarily
        uint256 _weiAmount = msg.value;
        address _beneficiary = msg.sender;
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        require(now >= startDate && now <= endDate);
        require(SafeMath.add(weiRaised, _weiAmount) <= cap);

        uint tokens;

        if (now <= bonusEnds) {
            tokens = msg.value * bonusRate;
        } else {
            tokens = msg.value * rate;
        }

        require(!reentrancyLock);
        reentrancyLock = true;
        balances[_beneficiary] = SafeMath.add(balances[_beneficiary], tokens);
        _totalSupply = SafeMath.add(_totalSupply, tokens);
        emit Transfer(address(0), _beneficiary, tokens);
        owner.transfer(_weiAmount);
        weiRaised = SafeMath.add(weiRaised, _weiAmount);
        reentrancyLock = false;
    }

    function safeTransfer(address _to, uint256 _tokens) internal {
        assert(transfer(_to, _tokens));
    }

    function reclaimToken(address _tokenOwner) public onlyOwner returns (bool) {
        uint256 balance = balanceOf(_tokenOwner);
        safeTransfer(owner, balance);
    }

    function addToWhitelist(address _beneficiary) public onlyOwner {
        whitelist[_beneficiary] = true;
    }

    function addManyToWhitelist(address[] _beneficiaries) public onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    function removeFromWhitelist(address _beneficiary) public onlyOwner {
        whitelist[_beneficiary] = false;
    }

    function getWhitelistStatus(address _beneficiary) public onlyOwner returns (bool) {
        return whitelist[_beneficiary];
    }

}
