---
title: 09. Error
tags:
   -huff
   -interface
   - error
   - bytecode
---

# WTF Huff Minimalist Introduction: 09. Error

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

Huff allows you to customize the error `Error` in the contract, we will introduce it in this lecture.

## Error

There are three methods of throwing exceptions in Solidity: `error`, `require` and `assert`. They are all based on the `revert` instruction of `EVM`. In Huff, we can directly use the `revert` instruction to throw errors and return error information.

### Definition error

You can define errors in the contract interface:

```c
/* interface */
#define function getError() view returns (uint256)
#define error CustomError(uint256)
```

### Usage errors

Within a method, you can use the built-in function __ERROR() to push the error selector onto the stack.

```c
#define macro GET_ERROR() = takes (0) returns (0) {
    __ERROR(PanicError)   // [panic_error_selector, panic_code]
    0x00 mstore           // [panic_code]
    0x04 mstore           // []
    0x24 0x00 revert
}
```

Then we write a Main macro as the entry point of the contract:

```c
//The main entrance of the contract determines which function is called
#define macro MAIN() = takes (0) returns (0) {
     // Determine which function to call through selector
     0x00 calldataload 0xE0 shr
     dup1 __FUNC_SIG(GET_ERROR) eq get_error jumpi
     // If there is no matching function, revert
     0x00 0x00 revert

     get_error:
         GET_ERROR()
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/09_Error.huff -r
```

The printed bytecode is:

```
5f3560e01c8063ee23e35814610013575f5ffd5b60697f110b3655000000000000000000000000000000000000000000000000000000005f5260045260245ffd
```

Convert to a formatted table (the second half omits an unused `selector` in `stack`):

| pc   | op         | opcode                   | stack                             |
|------|------------|--------------------------|-----------------------------------|
| [00] | 5f         | PUSH0                    | 0x00                              |
| [01] | 35         | CALLDATALOAD             | calldata                          |
| [02] | 60 e0      | PUSH1 0xE0               | 0xE0 calldata                     |
| [04] | 1c         | SHR                      | selector                          |
| [05] | 80         | DUP1                     | selector selector                 |
| [06] | 63 ee23e358| PUSH4 0xEE23E358         | 0xEE23E358 selector selector      |
| [0b] | 14         | EQ                       | suc selector                      |
| [0c] | 61 0013    | PUSH2 0x0013             | 0x0013 suc selector               |
| [0f] | 57         | JUMPI                    | selector                          |
| [10] | 5f         | PUSH0                    | 0x00 selector                     |
| [11] | 5f         | PUSH0                    | 0x00 0x00 selector                |
| [12] | fd         | REVERT                   | selector                          |
| [13] | 5b         | JUMPDEST                 |                                   |
| [14] | 60 69      | PUSH1 0x69               | 0x69                              |
| [16] | 7f 0x110b... | PUSH32 0x110b...       | 0x69  0x110b...                   |
| [2d] | 5f         | PUSH0                    | 0x00 0x69  0x110b...              |
| [2e] | 52         | MSTORE                   | 0x110b...                         |
| [2f] | 60 04      | PUSH1 0x04               | 0x04 0x110b...                    |
| [31] | 52         | MSTORE                   |                                   |
| [32] | 60 24      | PUSH1 0x24               | 0x24                              |
| [34] | 5f         | PUSH0                    | 0x00 0x24                         |
| [35] | fd         | REVERT                   |                                   |

As can be seen from `[16]`, the current built-in function `__ERROR` is not optimized very well, because it will first calculate the `4` byte `error selector` (here `0x110b3655`), and then Then convert it to the data of the `32` bytes (fill in the right, change to` 110B365500000000000000000000000000000000000000000000000000 `), and finally use the` push32` to press into the stack. But in fact, all we need is the first 4 bytes, which causes a waste of gas.

## Summary

In this tutorial, we introduced how to customize errors and use them in Huff. Huff provides the built-in function `__ERROR` to get error selectors, but it is not well optimized.
