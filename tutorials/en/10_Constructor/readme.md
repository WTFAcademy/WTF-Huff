---
title: 10. Constructor
tags:
   -huff
   -interface
   - constructor
   - bytecode
---

# WTF Huff Minimalist Introduction: 10. Constructor

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we introduce the `Constructor` in Huff, which can be used to initialize the contract during deployment.

## Constructor

The `CONSTRUCTOR` macro in Huff is similar to the constructor of Solidity. It is not required, but can be used to initialize contract state variables during deployment. If you don’t understand how Ethereum creates contracts through transactions, you can read [WTF EVM Opcodes Lecture 21](https://github.com/WTFAcademy/WTF-EVM-Opcodes/tree/main/21_Create).

In the following example, we use the `CONSTRUCTOR` macro to initialize the value of the storage slot `VALUE_LOCATION` to `0x69` when the contract is deployed.

```c
/* interface */
#define function getValue() view returns (uint256)

/* Storage slot */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()

/* method */
// Constructor
#define macro CONSTRUCTOR() = takes (0) returns (0) {
    0x69
    [VALUE_LOCATION]
    sstore              // []
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

// The main entrance of the contract to determine which function is called
#define macro MAIN() = takes (0) returns (0) {
     // Determine which function to call through selector
     0x00 calldataload 0xE0 shr
     dup1 __FUNC_SIG(getValue) eq get jumpi
     // If there is no matching function, revert
     0x00 0x00 revert

    get:
        GET_VALUE()
}
```


## Analyze contract bytecode

We can use the `huffc` command to obtain the creation code of the above contract:

```shell
huffc src/10_Constructor.huff -b
```

The printed bytecode is:

```
60695f55601c80600d3d393df35f3560e01c80632096525514610013575f5ffd5b5f545f5260205ff3
```

Copy this bytecode to [evm.codes playground](https://www.evm.codes/playground?fork=shanghai) and click Run. You can see that the storage slot `0` is initialized to `69`, and the runtime code of the contract is returned: `5f3560e01c80632096525514610013575f5ffd5b5f545f5260205ff3`, indicating that the contract is initialized successfully!

![](./img/10-1.png)

## Summary

In this lecture, we introduced how to use the `Constructor` macro in Huff. It is similar to the constructor in Solidity and can be used to initialize the contract during deployment.
