---
title: 15. Import
tags:
   -huff
   -interface
   -mapping
   - bytecode
---

# WTF Huff Minimalist Introduction: 15. Import

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we introduce how to import other contracts into the Huff contract and reuse code.

## Introduction

Huff supports using the `#include` keyword in a contract to introduce other contracts to facilitate code reuse. Below we introduce the introduced rules.

### 1. The order of importing contracts

When a Huff contract (such as `C.huff`) imports other contracts, these imported contracts will be inserted above the current contract in the order in which they were introduced.

For example, if you have a `C.huff` contract that first imports `A.huff` and then `B.huff`, then this is the same as having `A`, `B` directly in the same contract in order. , `C` is the same.

This means that the logical structure of the contract content will be like this:
```
Content from A.huff
----------
Content from B.huff
----------
Content from C.huff
```

### 2. Overwriting of functions or constants

If a function or constant is overwritten by a subsequent contract in the imported contract sequence, the last overridden version will take effect.

For example, if `A.huff` has a function `MAIN()`, `B.huff` also has a function `MAIN()`, and `C.huff` again has a function `MAIN()`, then the final effect will be the `MAIN()` function in `C.huff`. This is the same as the result of not having the `MAIN()` function in `A.huff` and `B.huff`.

### 3. How to import contracts into Huff

In Huff, you can use the `#include` directive to import other Huff contracts. The format is as follows:
```c
#include "Contract path/contract name.huff"
```
For example, to import a contract named `ContractName.huff` in the current folder, you can write:
```c
#include "./ContractName.huff"
```

## Example

We can divide the [07_Interface.huff](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/07_Interface.huff) contract in WTF Huff Lecture 7 into two contracts, and then use the import way to bring the two parts together.

The first part `15_Imported.huff` contains interfaces, storage slots, and Main macro:

```c
/* interface */
#define function setValue(uint256) nonpayable returns ()
#define function getValue() view returns (uint256)

/* storage slot */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()

// The main entrance of the contract to determine which function is called
#define macro MAIN() = takes (0) returns (0) {
     // Determine which function to call through selector
     0x00 calldataload 0xE0 shr
     dup1 __FUNC_SIG(setValue) eq set jumpi
     dup1 __FUNC_SIG(getValue) eq get jumpi
     // If there is no matching function, revert
     0x00 0x00 revert

    set:
        SET_VALUE()
    get:
        GET_VALUE()
}
```

The second part contains the two methods `SET_VALUE()` and `GET_VALUE`, and introduces the first part:

```c
#include "./15_Imported.huff"

/* method */
#define macro SET_VALUE() = takes (0) returns (0) {
    0x04 calldataload   // [value]
    [VALUE_LOCATION]    // [ptr, value]
    sstore              // []
    stop                // []
}

#define macro GET_VALUE() = takes (0) returns (0) {
    // Load value from storage
    [VALUE_LOCATION]   // [ptr]
    sload                // [value]

    // Store value in memory
    0x00 mstore

    // return value
    0x20 0x00 return
}
```

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/15_Import.huff -r
```

The printed bytecode is:

```
5f3560e01c8063552410771461001e5780632096525514610025575f5ffd5b6004355f55005b5f545f5260205ff3
```

This is consistent with the contract bytecode in Lecture 7, indicating that we have successfully imported the first part of the contract.

## Summary

It is very important to understand Huff's introduction rules, because it determines the structure of the code and which functions/constants will take effect in the contract. We need to take these rules into account when writing or analyzing Huff contracts.
