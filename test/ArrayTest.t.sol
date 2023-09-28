// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract ArrayTest is Test {
    /// @dev Address of the I13_Array contract.
    I13_Array public i13_Array;

    /// @dev Setup the testing environment.
    function setUp() public {
        i13_Array = I13_Array(HuffDeployer.deploy("13_Array"));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetArray() public {
        uint[] memory arr_ = new uint[](3);
        arr_[0] = 1;
        arr_[1] = 2;
        arr_[2] = 3;
        i13_Array.setArray(arr_);
        assertEq(arr_, i13_Array.getArray());
    }
}

interface I13_Array {
	function getArray() external view returns (uint256[] memory);
	function setArray(uint256[] memory) external;
}