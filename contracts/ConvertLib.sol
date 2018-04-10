pragma solidity ^0.4.21;


library Convertlib {

    function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount) {
        return amount * conversionRate;
    }

}
