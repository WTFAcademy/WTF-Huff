// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract StringTest is Test {
    /// @dev Address of the I12_String contract.
    I12_String public i12_String;

    /// @dev Setup the testing environment.
    function setUp() public {
        i12_String = I12_String(HuffDeployer.deploy("I12_String"));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetValue() public {
        string memory str_ = "WTF";
        i12_String.setString(str_);
        string memory str_get = i12_String.getString();
        console.log(str_get);
        console.log(str_);
        // assertEq(str_, i12_String.getString());
    }
}

interface I12_String {
	function getString() external view returns (string memory);
	function setString(string memory) external;
}