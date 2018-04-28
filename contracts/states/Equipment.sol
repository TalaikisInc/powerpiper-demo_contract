pragma solidity ^0.4.21;


contract EquipmentState {

    enum State {
        Available,
        NotAvailable,
        Damaged,
        InDebt
    }

    State public equipmentState = State.Available;

}
