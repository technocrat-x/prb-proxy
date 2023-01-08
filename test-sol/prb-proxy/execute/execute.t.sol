// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { stdError } from "forge-std/StdError.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { TargetEcho } from "../../helpers/targets/TargetEcho.t.sol";
import { TargetRevert } from "../../helpers/targets/TargetRevert.t.sol";

contract Execute_Test is PRBProxy_Test {
    modifier callerUnauthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_NoPermission() external callerUnauthorized {
        changePrank(users.eve);
        bytes memory data = bytes.concat(targets.dummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                users.owner,
                users.eve,
                address(targets.dummy),
                targets.dummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    modifier callerHasPermission() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_PermissionDifferentTarget() external callerUnauthorized callerHasPermission {
        proxy.setPermission(users.envoy, address(targets.echo), targets.dummy.foo.selector, true);
        changePrank(users.envoy);

        bytes memory data = bytes.concat(targets.dummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                users.owner,
                users.envoy,
                address(targets.dummy),
                targets.dummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_PermissionDifferentFunction() external callerUnauthorized callerHasPermission {
        proxy.setPermission(users.envoy, address(targets.dummy), targets.dummy.bar.selector, true);
        changePrank(users.envoy);

        bytes memory data = bytes.concat(targets.dummy.foo.selector);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPRBProxy.PRBProxy_ExecutionUnauthorized.selector,
                users.owner,
                users.envoy,
                address(targets.dummy),
                targets.dummy.foo.selector
            )
        );
        proxy.execute(address(targets.dummy), data);
    }

    modifier callerAuthorized() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_TargetNotContract(address nonContract) external callerAuthorized {
        vm.assume(nonContract.code.length == 0);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_TargetNotContract.selector, nonContract));
        proxy.execute(nonContract, bytes(""));
    }

    modifier targetContract() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_GasStipendCalculationUnderflows() external callerAuthorized targetContract {
        // Set the min gas reserve.
        uint256 gasLimit = 10_000;
        proxy.execute(
            address(targets.minGasReserve),
            abi.encodeWithSelector(targets.minGasReserve.setMinGasReserve.selector, gasLimit + 1)
        );

        // Run the test.
        bytes memory data = abi.encode(targets.echo.echoUint256.selector, 0);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute{ gas: gasLimit }(address(targets.echo), data);
    }

    modifier gasStipendCalculationDoesNotUnderflow() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerChangedDuringDelegateCall()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
    {
        bytes memory data = bytes.concat(targets.changeOwner.changeOwner.selector);
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_OwnerChanged.selector, users.owner, address(0)));
        proxy.execute(address(targets.changeOwner), data);
    }

    modifier ownerNotChangedDuringDelegateCall() {
        _;
    }

    modifier delegateCallReverts() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_FailedAssertion()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.assertion.selector);
        vm.expectRevert(stdError.assertionError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_DivisionByZero()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.divisionByZero.selector);
        vm.expectRevert(stdError.divisionError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_ArithmeticOverflow()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.arithmeticOverflow.selector);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Panic_ArithmeticUnderflow()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.panic.arithmeticUnderflow.selector);
        vm.expectRevert(stdError.arithmeticError);
        proxy.execute(address(targets.panic), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_EmptyRevertStatement()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.revert.withNothing.selector);
        vm.expectRevert();
        proxy.execute(address(targets.revert), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_CustomError()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.revert.withCustomError.selector);
        vm.expectRevert(TargetRevert.TargetError.selector);
        proxy.execute(address(targets.revert), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_Require()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.revert.withRequire.selector);
        vm.expectRevert();
        proxy.execute(address(targets.revert), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_ReasonString()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.revert.withReasonString.selector);
        vm.expectRevert("You shall not pass");
        proxy.execute(address(targets.revert), data);
    }

    /// @dev it should revert.
    function test_RevertWhen_Error_NoPayableModifier()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallReverts
    {
        bytes memory data = bytes.concat(targets.revert.dueToNoPayableModifier.selector);
        vm.expectRevert();
        proxy.execute{ value: 0.1 ether }(address(targets.revert), data);
    }

    modifier delegateCallDoesNotRevert() {
        _;
    }

    /// @dev it should return the Ether amount.
    function test_Execute_EtherSent()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
    {
        uint256 amount = 0.1 ether;
        bytes memory data = bytes.concat(targets.echo.echoMsgValue.selector);
        bytes memory actualResponse = proxy.execute{ value: amount }(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(amount);
        assertEq(actualResponse, expectedResponse);
    }

    modifier noEtherSent() {
        _;
    }

    /// @dev it should return an empty response and send the ETH to the SELFDESTRUCT recipient.
    function test_Execute_TargetSelfDestructs()
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
    {
        uint256 previousAliceBalance = users.alice.balance;
        uint256 contractBalance = 3.14 ether;
        vm.deal({ account: address(proxy), newBalance: contractBalance });

        bytes memory data = abi.encodeCall(targets.selfDestruct.destroyMe, (users.alice));
        bytes memory actualResponse = proxy.execute(address(targets.selfDestruct), data);
        bytes memory expectedResponse = "";
        assertEq(actualResponse, expectedResponse);

        uint256 actualAliceBalance = users.alice.balance;
        uint256 expectedAliceBalance = previousAliceBalance + contractBalance;
        assertEq(actualAliceBalance, expectedAliceBalance);
    }

    modifier targetDoesNotSelfDestruct() {
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoAddress.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoBytesArray.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoBytes32.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoMsgValue.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoString.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoStruct.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoUint8.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoUint256.selector, true);
        proxy.setPermission(users.envoy, address(targets.echo), targets.echo.echoUint256Array.selector, true);
        _;
    }

    /// @dev This modifier runs the test twice, once with the owner as the caller, and once with the envoy.
    modifier callerOwnerAndEnvoy() {
        _;
        changePrank(users.envoy);
        _;
    }

    /// @dev it should return the address.
    function testFuzz_Execute_ReturnAddress(
        address input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoAddress, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the bytes array.
    function testFuzz_Execute_ReturnBytesArray(
        bytes memory input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytesArray, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the bytes32.
    function testFuzz_Execute_ReturnBytes32(
        bytes32 input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoBytes32, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnString(
        string memory input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoString, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnStruct(
        TargetEcho.Struct memory input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoStruct, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnUint8(
        uint8 input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint8, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnUint256(
        uint256 input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }

    /// @dev it should return the string.
    function testFuzz_Execute_ReturnUint256Array(
        uint256[] memory input
    )
        external
        callerAuthorized
        targetContract
        gasStipendCalculationDoesNotUnderflow
        ownerNotChangedDuringDelegateCall
        delegateCallDoesNotRevert
        noEtherSent
        targetDoesNotSelfDestruct
        callerOwnerAndEnvoy
    {
        bytes memory data = abi.encodeCall(targets.echo.echoUint256Array, (input));
        bytes memory actualResponse = proxy.execute(address(targets.echo), data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse);
    }
}
