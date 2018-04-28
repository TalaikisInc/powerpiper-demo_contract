pragma solidity ^0.4.21;


contract UserState {

    enum State {
        Starter,
        Pro,
        Damaged
    }

    State public userState = State.Starter;

}
