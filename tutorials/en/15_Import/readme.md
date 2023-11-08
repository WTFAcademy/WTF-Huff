---
title: 15. 引用
tags:
  - huff
  - interface
  - mapping
  - bytecode
---

# WTF Huff极简入门: 15. 引用

我最近在重新学Huff，巩固一下细节，也写一个“Huff极简入门”，供小白们使用（编程大佬可以另找教程），每周更新1-3讲。

推特：[@0xAA_Science](https://twitter.com/0xAA_Science)

社区：[Discord](https://discord.gg/5akcruXrsk)｜[微信群](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link)｜[官网 wtf.academy](https://wtf.academy)

所有代码和教程开源在github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

这一讲，我们介绍如何在Huff合约中引入其他合约，复用代码。

## 引入

Huff支持在合约中使用`#include`关键字引入其他合约，方便复用代码。下面我们介绍引入的规则。

### 1. 引入合约的顺序

当一个Huff合约（例如`C.huff`）引入了其他合约时，这些被引入的合约将按照它们被引入的顺序插入到当前的合约上方。

例如，如果你有一个`C.huff`合约，它首先引入了`A.huff`，然后引入了`B.huff`，那么这与直接在一个合约中按顺序有`A`、`B`、`C`是一样的。

这意味着合约内容的逻辑结构将是这样的：
```
内容来自A.huff
----------
内容来自B.huff
----------
内容来自C.huff
```

### 2. 函数或常量的覆盖

如果在引入的合约序列中，某个函数或常量被后续的合约覆盖，那么最后覆盖的版本会生效。

例如，如果`A.huff`有一个函数`MAIN()`，`B.huff`也有一个函数`MAIN()`，并且`C.huff`再次有一个函数`MAIN()`，那么最终生效的将是`C.huff`中的`MAIN()`函数。这与`A.huff`和`B.huff`中没有`MAIN()`函数的结果是相同的。

### 3. 如何在Huff中引入合约

在Huff中，你可以使用`#include`指令来引入其他Huff合约。格式如下：
```c
#include "合约路径/合约名.huff"
```
例如，要引入当前文件夹下名为`ContractName.huff`的合约，你可以这样写：
```c
#include "./ContractName.huff"
```

## 示例

我们可以将WTF Huff第7讲中的[07_Interface.huff](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/07_Interface.huff)合约分成两个合约，然后用引入的方式将两部分并在一起。

第一部分`15_Imported.huff`包含接口、存储槽，和Main宏：

```c
/* 接口 */
#define function setValue(uint256) nonpayable returns ()
#define function getValue() view returns (uint256)

/* 存储槽位 */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()

// 合约的主入口，判断调用的是哪个函数
#define macro MAIN() = takes (0) returns (0) {
    // 通过selector判断要调用哪个函数
    0x00 calldataload 0xE0 shr
    dup1 __FUNC_SIG(setValue) eq set jumpi
    dup1 __FUNC_SIG(getValue) eq get jumpi
    // 如果没有匹配的函数，就revert
    0x00 0x00 revert

    set:
        SET_VALUE()
    get:
        GET_VALUE()
}
```

第二部分包含`SET_VALUE()`和`GET_VALUE`两个方法，并且引入了第一部分：

```c
#include "./15_Imported.huff"

/* 方法 */
#define macro SET_VALUE() = takes (0) returns (0) {
    0x04 calldataload   // [value]
    [VALUE_LOCATION]    // [ptr, value]
    sstore              // []
    stop                // []
}

#define macro GET_VALUE() = takes (0) returns (0) {
    // 从存储中加载值
    [VALUE_LOCATION]   // [ptr]
    sload                // [value]

    // 将值存入内存
    0x00 mstore

    // 返回值
    0x20 0x00 return
}
```

我们可以使用`huffc`命令获取上面合约的runtime code:

```shell
huffc src/15_Import.huff -r
```

打印出的bytecode为：

```
5f3560e01c8063552410771461001e5780632096525514610025575f5ffd5b6004355f55005b5f545f5260205ff3
```

这与第7讲的合约字节码一致，说明我们成功引入了第一部分的合约。

## 总结

理解Huff的引入规则是非常重要的，因为它决定了代码的结构以及哪些函数/常量会在合约中生效。在编写或分析Huff合约时，我们需要考虑到这些规则。
