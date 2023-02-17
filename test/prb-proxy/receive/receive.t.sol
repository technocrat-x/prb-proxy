// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { PRBProxy_Test } from "../PRBProxy.t.sol";

contract Receive_Test is PRBProxy_Test {
    /// @dev it should say that the call has not been successful.
    function test_RevertWhen_CallDataNonEmpty() external {
        uint256 value = 1 ether;
        bytes memory data = bytes.concat("0xcafe");
        (bool condition, ) = address(proxy).call{ value: value }(data);
        assertFalse(condition);
    }

    modifier callDataEmpty() {
        _;
    }

    /// @dev it should receive the ETH.
    function test_Receive() external callDataEmpty {
        uint256 value = 1 ether;
        (bool condition, ) = address(proxy).call{ value: value }("");
        assertTrue(condition);

        uint256 actualBalance = address(proxy).balance;
        uint256 expectedBalance = value;
        assertEq(actualBalance, expectedBalance, "proxy balance");
    }
}
