---
title: 05. Main Macro
tags:
   -huff
   - macro
   - main macro
   - bytecode
---

# WTF Huff Minimalist Introduction: 05. Main Macro

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce the `MAIN` macro in Huff, which is the main entry of the contract.

## Main Macro

The `Main` macro is a special macro. As the main entry of the contract, each Huff contract must have one. Its role is similar to the `fallback` function in Solidity. When an external call is made to the contract, this code is run to determine which function should be called.

You need to use the `MAIN()` keyword when declaring:

```c
#define macro MAIN() = takes (0) returns (0) {
     // ...
}
```

Next we write a simple contract:

```c
#define macro PUSH_69() = takes(0) returns(1) {
     push1 0x69 // [0x69]
}

#define macro SAVE() = takes(1) returns(0) {
     // [0x69]
     [STORAGE_SLOT0] // [value_slot0_pointer, 0x69]
     sstore // []

}

#define macro MAIN() = takes(0) returns(0) {
     PUSH_69() // []
     SAVE()
}
```

The `PUSH_69()` macro in the above contract will push `0x69` onto the stack (`returns(1)`), while the `SAVE()` macro (`takes(1)`) will save the value at the top of the stack to storage slot `STORAGE_SLOT0`. In the `Main` macro, we call `PUSH_69()` and `SAVE()` once.


## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/05_Main.huff -r
```

The printed bytecode is:

```
60695f55
```

Convert to formatted table:

| pc | op | opcode | stack |
|------|--------|----------------|---------------- ----|
| [00] | 60 69 | PUSH2 0x69 | 0x69 |
| [02] | 5f | PUSH0 | 0 0x69 |
| [03] | 55 | SSTORE | |

We can see that what this contract actually does is store `0x69` in storage slot `0` using the `SSTORE` instruction.

## Summary

In this lecture, we introduced the `Main` macro and `MAIN` keyword in Huff. The `Main` macro in Huff is the main entry of the contract. Each contract must contain it. Its function is similar to the `fallback` function in Solidity.
