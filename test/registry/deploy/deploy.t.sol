// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract Deploy_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deploy();
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deploy();
    }

    modifier ownerDoesNotHaveProxy() {
        _;
    }

    /// @dev it should deploy the proxy.
    function testFuzz_Deploy(address origin, address owner) external ownerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        address actualProxy = address(registry.deploy());
        address expectedProxy = computeProxyAddress({ origin: origin, seed: SEED_ZERO });
        assertEq(actualProxy, expectedProxy, "deployed proxy address");
    }

    /// @dev it should update the next seeds mapping.
    function testFuzz_Deploy_UpdateNextSeeds(address origin, address owner) external ownerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deploy();

        bytes32 actualNextSeed = registry.getNextSeed(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed");
    }

    /// @dev it should update the proxies mapping.
    function testFuzz_Deploy_UpdateProxies(address origin, address owner) external ownerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deploy();
        address actualProxy = address(registry.getProxy(owner));
        address expectedProxy = computeProxyAddress({ origin: origin, seed: SEED_ZERO });
        assertEq(actualProxy, expectedProxy, "proxy mapping");
    }

    /// @dev it should emit a {DeployProxy} event.
    function testFuzz_Deploy_Event(address origin, address owner) external ownerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        expectEmit();
        emit DeployProxy({
            origin: origin,
            operator: owner,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress({ origin: origin, seed: SEED_ZERO }))
        });
        registry.deploy();
    }
}
