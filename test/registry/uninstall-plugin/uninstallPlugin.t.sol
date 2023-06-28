// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract UninstallPlugin_Test is Registry_Test {
    function test_RevertWhen_CallerDoesNotHaveProxy() external {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_CallerDoesNotHaveProxy.selector, users.bob)
        );
        changePrank({ msgSender: users.bob });
        registry.uninstallPlugin(plugins.empty);
    }

    modifier whenCallerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    function test_RevertWhen_PluginEmptyMethodList() external whenCallerHasProxy {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_PluginEmptyMethodList.selector, plugins.empty)
        );
        registry.uninstallPlugin(plugins.empty);
    }

    modifier whenPluginHasMethods() {
        _;
    }

    function test_UninstallPlugin_PluginNotInstalledBefore() external whenCallerHasProxy whenPluginHasMethods {
        // Uninstall the plugin.
        registry.uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "plugin method still installed");
        }
    }

    modifier whenPluginInstalled() {
        // Install the dummy plugin.
        registry.installPlugin(plugins.dummy);
        _;
    }

    function test_UninstallPlugin() external whenCallerHasProxy whenPluginHasMethods whenPluginInstalled {
        // Uninstall the plugin.
        registry.uninstallPlugin(plugins.dummy);

        // Assert that every plugin method has been uninstalled.
        bytes4[] memory pluginMethods = plugins.dummy.methodList();
        for (uint256 i = 0; i < pluginMethods.length; ++i) {
            IPRBProxyPlugin actualPlugin = registry.getPluginByOwner({ owner: users.alice, method: pluginMethods[i] });
            IPRBProxyPlugin expectedPlugin = IPRBProxyPlugin(address(0));
            assertEq(actualPlugin, expectedPlugin, "plugin method still installed");
        }
    }

    function test_UninstallPlugin_Event() external whenCallerHasProxy whenPluginHasMethods whenPluginInstalled {
        vm.expectEmit({ emitter: address(registry) });
        emit UninstallPlugin({ owner: users.alice, proxy: proxy, plugin: plugins.dummy });
        registry.uninstallPlugin(plugins.dummy);
    }
}
