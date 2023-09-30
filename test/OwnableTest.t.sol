// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract OwnerTest is Test {
    /// @dev Address of the I16_Ownable contract.
    I16_Ownable public i16_Ownable;
    address owner;
    address alice = address(1);

    /// @dev Setup the testing environment.
    function setUp() public {
        i16_Ownable = I16_Ownable(HuffDeployer.deploy("16_Ownable"));
        owner = i16_Ownable.owner();
    }

    /// @dev Test when caller is not owner
    function testGetOwner() public {
        console.log(i16_Ownable.owner());
        assertEq(owner, i16_Ownable.owner());
    }

    /// @dev Test when caller is not owner
    function testNotOwner() public {
        vm.expectRevert();
        vm.prank(alice);
        i16_Ownable.changeOwner(alice);
    }

    /// @dev Test when caller is not owner
    function testOwner() public {
        vm.prank(owner);
        i16_Ownable.changeOwner(alice);
        assertEq(alice, i16_Ownable.owner());
    }


}

interface I16_Ownable {
	event OwnerUpdated(address indexed, address indexed);
	function changeOwner(address) external;
	function owner() external view returns (address);
}