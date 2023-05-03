// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "./abstracts/PRBProxyStorage.sol";
import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "./interfaces/IPRBProxyRegistry.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/

/// @title PRBProxy
/// @dev See the documentation in {IPRBProxy}.
contract PRBProxy is
    PRBProxyStorage, // 1 inherited component
    IPRBProxy // 1 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    IPRBProxyRegistry public immutable override registry;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Constructs the proxy by fetching the params from the registry.
    /// @dev This is implemented like this so that the proxy's CREATE2 address doesn't depend on the constructor params.
    constructor() {
        minGasReserve = 5000;
        registry = IPRBProxyRegistry(msg.sender);
        owner = registry.transientProxyOwner();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  FALLBACK FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Fallback function used to run plugins.
    /// @dev WARNING: anyone can call this function and thus run any installed plugin.
    fallback(bytes calldata data) external payable returns (bytes memory response) {
        // Check if the function signature exists in the installed plugins mapping.
        IPRBProxyPlugin plugin = plugins[msg.sig];
        if (address(plugin) == address(0)) {
            revert PRBProxy_PluginNotInstalledForMethod({ caller: msg.sender, selector: msg.sig });
        }

        // Delegate call to the plugin.
        bool success;
        (success, response) = _safeDelegateCall(address(plugin), data);

        // Log the plugin run.
        emit RunPlugin(plugin, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy_PluginReverted(plugin);
            }
        }
    }

    /// @dev Called when `msg.value` is not zero and the call data is empty.
    receive() external payable { }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {
        // Check that the caller is either the owner or an envoy with permission.
        if (owner != msg.sender && !permissions[msg.sender][target]) {
            revert PRBProxy_ExecutionUnauthorized({ owner: owner, caller: msg.sender, target: target });
        }

        // Check that the target is a contract.
        if (target.code.length == 0) {
            revert PRBProxy_TargetNotContract(target);
        }

        // Delegate call to the target contract.
        bool success;
        (success, response) = _safeDelegateCall(target, data);

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    // The length of the data is at `response`, while the actual data is at `response + 32`.
                    let returndata_size := mload(response)
                    revert(add(response, 32), returndata_size)
                }
            } else {
                revert PRBProxy_ExecutionReverted();
            }
        }
    }

    /// @inheritdoc IPRBProxy
    function transferOwnership(address newOwner) external override {
        // Check that the caller is the registry.
        if (address(registry) != msg.sender) {
            revert PRBProxy_CallerNotRegistry({ registry: registry, caller: msg.sender });
        }

        // Effects: update the owner.
        owner = newOwner;
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Performs a DELEGATECALL to the provided address with the provided data.
    /// @dev Shared logic between the {execute} and the {fallback} functions.
    function _safeDelegateCall(address to, bytes memory data) internal returns (bool success, bytes memory response) {
        // Save the owner address in memory so that this variable cannot be modified during the DELEGATECALL.
        address owner_ = owner;

        // Reserve some gas to ensure that the contract call will not run out of gas.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the provided contract.
        (success, response) = to.delegatecall{ gas: stipend }(data);

        // Check that the owner has not been changed.
        if (owner_ != owner) {
            revert PRBProxy_OwnerChanged(owner_, owner);
        }
    }
}
