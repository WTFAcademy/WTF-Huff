// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract MappingTest is Test {
    /// @dev Address of the I14_Mapping contract.
    I14_Mapping public i14_Mapping;

    /// @dev Setup the testing environment.
    function setUp() public {
        i14_Mapping = I14_Mapping(HuffDeployer.deploy("14_Mapping"));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetMapping() public {
        uint k = 1;
        uint v = 2;
        i14_Mapping.setMap(k, v);
        assertEq(v, i14_Mapping.getMap(k));
    }
}

interface I14_Mapping {
	function getMap(uint256) external view returns (uint256);
	function setMap(uint256, uint256) external;
}