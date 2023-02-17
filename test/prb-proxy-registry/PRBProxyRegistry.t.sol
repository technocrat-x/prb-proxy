// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Base_Test } from "../Base.t.sol";

/// @notice Dummy contract only needed for providing naming context in the test traces.
abstract contract PRBProxyRegistry_Test is Base_Test {
    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        IPRBProxy proxy
    );

    function setUp() public virtual override {
        Base_Test.setUp();
    }
}
