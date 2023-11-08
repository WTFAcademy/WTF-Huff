---
title: 16. 权限控制
tags:
  - huff
  - interface
  - mapping
  - bytecode
---

# WTF Huff极简入门: 16. 权限控制

我最近在重新学Huff，巩固一下细节，也写一个“Huff极简入门”，供小白们使用（编程大佬可以另找教程），每周更新1-3讲。

推特：[@0xAA_Science](https://twitter.com/0xAA_Science)

社区：[Discord](https://discord.gg/5akcruXrsk)｜[微信群](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link)｜[官网 wtf.academy](https://wtf.academy)

所有代码和教程开源在github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

这一讲，我们介绍如何在Huff中实现类似Solidity中的修饰器（`modifier`），实现权限控制的功能。

## 权限控制

在Solidity中，我们一般使用修饰器实现权限控制，比如包含`onlyOwner`修饰器的函数仅允许合约的`owner`调用。这一讲，我们将用Huff实现下面的`Ownable`合约：

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ownable {
   address public owner; // 定义owner变量
   
   event OwnerUpdated(address indexed oldOwner, address indexed newOwner);

   constructor() {
      owner = msg.sender;
      emit OwnerUpdated(address(0), owner);
   }

   // 定义modifier
   modifier onlyOwner {
      require(msg.sender == owner); // 检查调用者是否为owner地址
      _; // 如果是的话，继续运行函数主体；否则报错并revert交易
   }

   // 定义一个带onlyOwner修饰符的函数
   function changeOwner(address _newOwner) external onlyOwner{
      address oldOwner = owner;
      owner = _newOwner; // 只有owner地址运行这个函数，并改变owner
      emit OwnerUpdated(oldOwner, _newOwner);
   }
}
```

## 实现

我们的实现合约由[huffmate](https://github.com/huff-language/huffmate)中的`Owned.huff`简化而来。它的逻辑很简单：

- 在构造器中，我们初始化`owner`为合约的部署者（`caller`），保存在存储槽`OWNER`中。
- `ONLY_OWNER`宏：实现了`onlyOwner`修饰器的效果。它会检查`msg.sender`与`owner`是否相等：如果相等，则继续执行后面逻辑；如果不想等，则回滚交易。
- `owner()`宏：获取`owner`地址。
- `changeOwner()`宏：修改`owner`地址。它使用了`ONLY_OWNER`宏进行权限控制，只有`owner`能调用它。

```c
// Adapted from <https://github.com/huff-language/huffmate/blob/main/src/auth/Owned.huff>

/* 接口 */
#define function changeOwner(address) nonpayable returns ()
#define function owner() view returns (address)

/* 事件 */
#define event OwnerUpdated(address indexed user, address indexed newOwner)

/* 存储槽位 */
#define constant OWNER = FREE_STORAGE_POINTER()

/* 构造器 */
#define macro CONSTRUCTOR() = takes (0) returns (0) {
    // 初始化时，将部署者设为owner
    caller                      // [caller]
    dup1                        // [caller, caller]
    [OWNER]                     // [OWNER, caller, caller]
    sstore                      // [caller]

    // 释放OwnerUpdated事件
    0x00                      // [0, caller]
    __EVENT_HASH(OwnerUpdated)  // [sig, 0, caller]
    0x00 0x00                   // [0, 0, sig, 0, caller]
    log3                        // []
}

// OnlyOwner修饰器
#define macro ONLY_OWNER() = takes (0) returns (0) {
    // 对比caller和Owner，如果不一样，则revert；如果一样，则跳转到auth，继续接下来的逻辑
    caller                      // [msg.sender]
    [OWNER] sload               // [owner, msg.sender]
    eq authed jumpi             // [authed]

    // 不是owner，就revert
    0x00 0x00 revert

    authed:
}

// 修改Owner
#define macro CHANGE_OWNER() = takes (0) returns (0) {
  // 只有owner可以调用
  ONLY_OWNER()

  // 设置新owner
  0x04 calldataload           // [newOwner]
  dup1                        // [newOwner, newOwner]
  [OWNER] sstore              // [newOwner]

  // 释放OwnerUpdated事件
  caller                      // [from, newOwner]
  __EVENT_HASH(OwnerUpdated)  // [sig, from, newOwner]
  0x00 0x00                   // [0, 32, sig, from, newOwner]
  log3                        // []

  stop
}

// 读取owner地址
#define macro OWNER() = takes (0) returns (0) {
    [OWNER] sload                  // [owner]
    0x00 mstore                    // []
    0x20 0x00 return
}

// 合约的主入口，判断调用的是哪个函数
#define macro MAIN() = takes (0) returns (0) {
    // 通过selector判断要调用哪个函数
    0x00 calldataload 0xE0 shr
    dup1 __FUNC_SIG(changeOwner) eq change_owner jumpi
    dup1 __FUNC_SIG(owner)    eq owner jumpi
    // 如果没有匹配的函数，就revert
    0x00 0x00 revert

    change_owner:
        CHANGE_OWNER()
    owner:
        OWNER()
}
```

## 使用Foundry测试

我们可以使用Foundry写一个测试，用Solidity来验证咱们写的Huff合约是否能正常工作。我们写了三个单元测试

1. `testGetOwner`: 测试`owner()`函数获取的地址是否等于`owner`。
2. `testNotOwner`: 测试非`owner`地址调用`changeOwner()`函数时是否会回滚。
3. `testOwner`: 测试`owner`地址调用`changeOwner()`函数时是否能修改`owner`。

注意，由于Foundry-huff使用`HuffDeployer`和`HuffConfig`合约间接部署Huff合约，因此构造器的`caller`我们没法控制。我们使用了一个折衷的办法，在`setUp()`中，我们在合约部署后记录下`owner`地址，方便之后的测试。

测试合约：

```solidity
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
```

在命令行输入中输入`forge test`运行测试合约，可以看到测试通过！

![](./img/16-1.png)


## 总结

这一讲，我们在Huff中实现了类似Solidity的修饰器功能，进行权限控制。