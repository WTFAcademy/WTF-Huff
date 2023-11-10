---
title: 04. Macro
tags:
   -huff
   - macro
   - bytecode
---

# WTF Huff Minimalist Introduction: 04. Macros

I'm re-learning Huff recently, consolidating the details, and writing a "Simplified Introduction to Huff" for novices (programmers can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce the macros and `macro` keyword in Huff.

## Macro

There are two ways to combine bytecodes in Huff, one is called macros `Macros` and the other is called functions `Functions`. There are some differences between the two, but most of the time developers should use macros rather than functions. You need to use the `macro` keyword when defining a macro. The rules are as follows:

```c
#define macro MACRO_NAME(arguments) = takes (1) returns (3) {
    // ...
}
```

in:

- `MACRO_NAME`: The name of the macro.
- `arguments`: Macro parameters, optional.
- `takes (1)`: Specifies the number of stack inputs accepted by the macro/function, optional, default is `0`.
- `returns (3)`: Specifies the number of stack elements output by the macro/function, optional, default is `0`.

> What is strange is that the current huff compiler does not check the number of `takes` and `returns`, so they are just a decoration at present. Maybe checks will be added in future versions?

In the following example, the `SAVE()` macro accepts a parameter `value` and stores its value in storage slot `STORAGE_SLOT0`. In macros, we use `<value>` to use the value of the parameter.
```c
#define constant STORAGE_SLOT0 = FREE_STORAGE_POINTER()

// This macro accepts a parameter value and stores its value in STORAGE_SLOT0
#define macro SAVE(value) = takes(0) returns(0) {
    <value>                 // [value]
    [STORAGE_SLOT0]         // [value_slot0_pointer, value]
    sstore          // []
}

#define macro MAIN() = takes(0) returns(0) {
    SAVE(0x420)          // []
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/04_Macro.huff -r
```

The printed bytecode is:

```
6104205f55
```

Convert to formatted table:

| pc | op | opcode | stack |
|------|--------|----------------|---------------- ----|
| [00] | 61 0420 | PUSH2 0x0420 | 0x0420 |
| [03] | 5f | PUSH0 | 0 0x0420 |
| [04] | 55 | SSTORE | |

We can see that what this contract does is store `0x0420` in storage slot `0` using the `SSTORE` instruction.

## Summary

In this lecture, we introduced the macros and `macro` keyword in Huff. Macros and functions in Huff are very similar, but developers should use macros rather than functions most of the time.
