pragma solidity ^0.4.21;

import "./zeppelin/Ownable.sol";
import "./zeppelin/SafeMath.sol";


contract Certificates is Ownable {
    using SafeMath for uint;

    struct Certificate {
        bytes32 url;
        uint amount;
        uint timestamp;
    }

    uint public reserves = 0;

    Certificate[] certificates;

    function addCertificate(bytes32 _url, uint _amount) public onlyOwner {
        Certificate memory certificate = Certificate({
            url: _url,
            amount: _amount,
            timestamp: now
        });

        reserves = reserves.add(certificate.amount);

        certificates.push(certificate);
    }

    function getCertificatesLength() public constant onlyOwner returns (uint) {
        return certificates.length;
    }

    function getCertificate(uint _index) public constant onlyOwner returns (bytes32, uint, uint) {
        Certificate memory certificate = certificates[_index];
        return (
            certificate.url,
            certificate.amount,
            certificate.timestamp
        );
    }

    function deleteCertificate(uint _index) public onlyOwner {
        require(certificates[_index].amount >= 0);

        reserves = reserves.sub(certificates[_index].amount);

        certificates[_index] = certificates[certificates.length-1];
        certificates.length--;
    }

}
