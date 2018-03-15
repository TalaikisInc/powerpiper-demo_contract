pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PWP.sol";

contract TestPowerPiperToken {

  function testInitialBalanceUsingDeployedContract() {
    PowerPiperToken meta = PowerPiperToken(DeployedAddresses.PowerPiperToken());

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

  function testInitialBalanceWithNewPWPCoin() {
    PowerPiperToken meta = new PowerPiperToken();

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

}
