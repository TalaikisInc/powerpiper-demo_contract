pragma solidity ^0.4.21;

import "./ICOState.sol";
import "./Ownable.sol";


contract MigratePreICO is Ownable {

    function migrate(address[] _recipients) external botOnly {
        for(uint i = 0; i < _recipients.length; i++) {
            // doMigration(_investors[i]);
        }

    }

}
