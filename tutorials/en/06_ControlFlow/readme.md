---
title: 06. Control flow
tags:
   -huff
   - control flow
   -jumpi
   -jumpdest
   - bytecode
---

# WTF Huff Minimalist Introduction: 06. Control Flow

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce the control flow in Huff, including jump labels and `JUMPDEST` instructions.

## Control flow

The bottom layer of EVM mainly uses jump instructions `JUMP`, `JUMPI`, and `JUMPDEST` to control the flow of code. If you don’t know about them, it is recommended to read [WTF EVM Opcodes Tutorial Lecture 9](https://github.com/WTFAcademy/WTF-EVM-Opcodes/tree/main/09_FlowOp).

In order to facilitate developers to use jump instructions, Huff provides jump labels, which can be defined in macros or functions and are represented by a colon followed by a word. Note that although it may appear that labels are scoped to blocks of code due to indentation, they are actually just jump destinations in the bytecode. If there are operations under the label, they will be executed unless the program counter is changed or execution is interrupted by the `revert`, `return`, `stop` or `selfdestruct` opcodes.

```
#define macro MAIN() = takes (0) returns (0) {
     //Read value from calldata
     0x00 calldataload // [calldata @ 0x00]
     0 eq
     jump_one jumpi

     // If this point is reached, revert
     0x00 0x00 revert

     // Jump to label 1
     jump_one:
         jump_two jump
         // If this point is reached, revert
         0x00 0x00 revert

     // Jump to label 2
     jump_two:
         0x00 0x00 return
}
```

In the contract, the `Main` macro will first read the called `calldata`. If it is `0`, it will first jump to `jump_one` and then jump to `jump_two`; if it is not `0`, it will not Will jump and continue running to `revert` to roll back the transaction.

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/06_ControlFlow.huff -r
```

The printed bytecode is:

```
5f355f1461000b575f5ffd5b610013565f5ffd5b5f5ff3
```

Convert to formatted table:

| pc | op | opcode | stack |
|------|--------|----------------|---------------- ----|
| [00] | 5f | PUSH0 | 0x00 |
| [01] | 35 | CALLDATALOAD | calldata |
| [02] | 5f | PUSH0 | 0x00 calldata |
| [03] | 14 | EQ | suc |
| [04] | 61 000b| PUSH2 0x000b | 0x000b suc |
| [07] | 57 | JUMPI | |
| [08] | 5f | PUSH0 | 0x00 |
| [09] | 5f | PUSH0 | 0x00 0x00 |
| [0a] | fd | REVERT | |
| [0b] | 5b | JUMPDEST | |
| [0c] | 61 0013| PUSH2 0x0013 | 0x0013 |
| [0e] | 56 | JUMP | |
| [10] | 5f | PUSH0 | 0x00 |
| [11] | 5f | PUSH0 | 0x00 0x00 |
| [12] | fd | REVERT | |
| [13] | 5b | JUMPDEST | |
| [14] | 5f | PUSH0 | 0x00 |
| [15] | 5f | PUSH0 | 0x00 0x00 |
| [16] | f3 | RETURN | |

We can see that the function of this bytecode is:

1. `CALLDATALOAD` reads the value from `calldata`
2. Use `EQ` to compare whether the data is `0`. If `calldata` is `0`, `suc = 1`, the program counter (PC) jumps to the `0x0b` position through `JUMPI`, which is the place marked by the jump label `jump_one`. If `calldata` is not `0`, it will continue to run until the `REVERT` instruction in `0xfd` rolls back the transaction.
3. Continue running at `0x0b`, the program will encounter the `JUMP` instruction, and the PC jumps to the `0x13` position, which is where the jump label `jump_two` is marked.
4. Continue running at `0x13`, see `RETURN`, return data and end the transaction.

It can be seen that Huff's compiler is not optimal here, because the position of `JUMPDEST` in the contract can be represented by `1` byte, but it uses `2` bytes, `0x000b` and `0x0013 `, a waste of gas.

## Summary

In this lecture, we introduced the control flow in Huff. Huff provides jump tags to facilitate developers to use `JUMP` and `JUMPI` for process control.
