---
title: 03. Constant
tags:
   -huff
   -storage
   - FREE_STORAGE_POINTER
   - bytecode
---

# WTF Huff Minimalist Introduction: 03. Constants

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link)｜[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce constants and the `constant` keyword in Huff.

## Constants

Huff's constants are similar to those in Solidity. They are not included in storage, but are called within the contract at compile time (included in the bytecode). Constants can be up to 32 bytes of data or the `FREE_STORAGE_POINTER()` keyword (representing an unused storage slot in the contract).

### Declare constants

You can declare constants in a contract using the `constant` keyword:

```c
#define constant NUM = 0x69
#define constant STORAGE_SLOT0 = FREE_STORAGE_POINTER()
```

### Use constants

You can push constants onto the stack using the bracket notation `[CONSTANT]`.

```c
#define macro MAIN() = takes(0) returns(0) {
    [NUM]             // [0x69] 
    [STORAGE_SLOT0]         // [value_slot0_pointer, 0x69]
    sstore          // []
}
```

In the `MAIN()` macro above, we push the constants `NUM` (value `0x69`) and `STORAGE_SLOT0` (value `0`) onto the stack, and then use the `sstore` instruction to store `0x69` into storage slot `0`.

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/03_Constant.huff -r
```

The printed bytecode is:

```
60695f55
```

Convert to formatted table:

| pc   | op     | opcode         | stack              |
|------|--------|----------------|--------------------|
| [00] | 60 69  | PUSH1 0x69     | 0x69               |
| [02] | 5f     | PUSH0          | 0 0x69             | 
| [03] | 55     | SSTORE         |                    |

We can see that what this contract does is store `0x69` in storage slot `0` using the `SSTORE` instruction.

## Summary

In this lecture, we introduced the constants and `constant` keyword in Huff. Constants do not occupy storage, but are called at compile time.
