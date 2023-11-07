---
title: 02. Storage
tags:
  - huff
  - storage
  - FREE_STORAGE_POINTER
  - bytecode
---

# WTF Huff Minimalist Introduction: 02. Storage

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter：[@0xAA_Science](https://twitter.com/0xAA_Science)

Community：[Discord](https://discord.gg/5akcruXrsk)｜WeChat](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link)｜[Official website wtf.academy](https://wtf.academy)

All code and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce storage in Huff, especially the `FREE_STORAGE_POINTER` keyword.

## Storage in Huff

Storage in EVM is a persistent storage space in which data can be maintained between transactions. It is part of the EVM state and supports reading and writing in 256 bit units.

![](./img/2-1.png)

### Declare storage slot

Storage in Huff is not complicated. You can track unused storage slots (free storage) in the contract through the `FREE_STORAGE_POINTER()` keyword. Below, we declare `2` storage slots `STORAGE_SLOT0` and `STORAGE_SLOT1`:

```c
#define constant STORAGE_SLOT0 = FREE_STORAGE_POINTER()
#define constant STORAGE_SLOT1 = FREE_STORAGE_POINTER()
```

EVM's storage uses key-value pairs to store data, and the storage slot is the key. In Huff, the compiler will allocate free memory slots starting from 0 at compile time. In the above example, `0` will be assigned to `STORAGE_SLOT0` and `1` will be assigned to `STORAGE_SLOT1`.

## Use storage slots

We can reference a storage slot in code by enclosing it in square brackets - like this `[STORAGE_SLOT0]`. In the code below, we store `0x69` into `STORAGE_SLOT0` and then `0x420` into `STORAGE_SLOT1` in the `MAIN()` macro.

```c
#define macro MAIN() = takes(0) returns(0) {
    0x69             // [0x69] 
    [STORAGE_SLOT0]         // [value_slot0_pointer, 0x69]
    sstore          // []

    0x420             // [0x420] 
    [STORAGE_SLOT1]         // [value_slot1_pointer, 0x420]
    sstore          // []
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/02_Storage.huff -r
```

The printed bytecode is:

```
60695f55610420600155
```

Looking at the bytecode directly may be a bit confusing, so we convert it into the following table:

| pc   | op     | opcode         | stack              |
|------|--------|----------------|--------------------|
| [00] | 60 69  | PUSH1 0x69     | 0x69               |
| [02] | 5f     | PUSH0          | 0 0x69                  | 
| [03] | 55     | SSTORE         |                    |
| [04] | 61 0420     | PUSH2 0x420        | 0x0420             |
| [07] | 60 01   | PUSH1 0x01         | 0x01               |
| [09] | 55     | SSTORE         |                    |

As you can see, the bytecode uses `SSTORE` twice, storing `0x69` and `0x420` into storage slots `0` and `1` respectively.

## Summary

In this lecture, we introduced how to use storage in Huff, specifically the `FREE_STORAGE_POINTER()` keyword, which can track unused storage slots in the contract and allocate them at compile time.
