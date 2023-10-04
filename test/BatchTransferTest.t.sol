// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ArrayTest is Test {
    IBatchTransfer iBatch;
    MyToken token;
    address address0 = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address[] recipients;
    uint[] amounts;
    uint total;

    /// @dev Setup the testing environment.
    function setUp() public {
        token = new MyToken("Token","TKN");
        iBatch = IBatchTransfer(HuffDeployer.deploy("BatchTransfer"));
        for(uint i; i < 500; i++){
            recipients.push(address(uint(address0)+i));
            amounts.push(i);
            total += i;
        }
        token.mint(address0, total);
        vm.prank(address0);
        token.approve(address(iBatch), total);
    }

    function testBatchTransferERC20() public {
        vm.prank(address0);
        IBatchTransfer.batchTransferETH(recipients, amounts);
    }

}

interface IBatchTransfer {
	function batchTransferERC20(address token, uint256 total, address[] memory recipients, uint256[] memory amounts) external;
    function batchTransferETH(address[] memory recipients, uint256[] memory amounts) external payable;
}

contract MyToken is ERC20{

    constructor (string memory _name, string memory _symbol) ERC20 (_name,_symbol){
    }

    function mint(address to, uint256 amount) public virtual {
        _mint(to,amount);
    }

    function burn(address form, uint amount) public virtual {
        _burn(form, amount);
    }
}
