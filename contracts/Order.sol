pragma solidity ^0.4.19;

import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";
import "./User.sol";
import "./Fee.sol";


contract Orders is Ownable, User, Fees {
    using SafeMath for uint;

    struct Order {
        address buyer;
        uint amount;
        uint timestamp;
    }

    Order[] orders;
    event BuyDirectEvent(address _buyer, uint _amount, uint _timestamp);

    function getOrder(uint _index) public constant onlyOwner returns (address, uint, uint) {
        Order memory order = orders[_index];
        return (order.buyer, order.amount, order.timestamp);
    }

    function approveOrder(uint _index, uint _amount) public onlyOwner {
        require(orders[_index].amount >= 0);

        //Order memory order = orders[_index];

        uint feeAmount = calculateFee(_amount);
        _amount = _amount.sub(feeAmount);
        // mint(this, feeAmount);

        //mint(order.buyer, _amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function declineOrder(uint _index) public onlyOwner {
        require(orders[_index].amount >= 0);

        Order memory order = orders[_index];
        order.buyer.transfer(order.amount);

        orders[_index] = orders[orders.length-1];
        orders.length--;
    }

    function getOrdersLength() public constant onlyOwner returns (uint) {
        return orders.length;
    }

    function buyDirect() public payable {
        require(msg.value > 0);

        Order memory order = Order({
            buyer: msg.sender,
            amount: msg.value,
            timestamp: now
        });

        orders.push(order);

        BuyDirectEvent(order.buyer, order.amount, order.timestamp);
    }

}
