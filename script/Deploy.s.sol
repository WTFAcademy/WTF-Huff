// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface SimpleStore {
  function setValue(uint256) external;
  function getValue() external returns (uint256);
}

interface I12_String {
	function getString() external view returns (string memory);
	function setString(string memory) external;
}

contract Deploy is Script {
  function run() public returns (SimpleStore simpleStore, I12_String i12_String) {
    simpleStore = SimpleStore(HuffDeployer.deploy("SimpleStore"));
    i12_String = I12_String(HuffDeployer.deploy("I12_String"));
  }
}
