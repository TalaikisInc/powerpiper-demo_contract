pragma solidity ^0.4.19;

contract ProofOfExistence {
    mapping(bytes32 => bool) private proofs;

    function storeProof(bytes32 proof) {
        proofs[proof] = true;
    }

    function _proofFor(string document) constant returns(bytes32) {
        return sha256(document);
    }

    function notarize(string document) {
        var proof = _proofFor(document);
        storeProof(proof);
    }

    function checkDocument(string document) constant returns(bool) {
        var proof = _proofFor(document);
        return hasProof(proof);
    }

    function hasProof(bytes32 proof) constant returns(bool) {
        return proofs[proof];
    }

}
