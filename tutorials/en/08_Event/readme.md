---
title: 08. Event
tags:
   -huff
   -interface
   - event
   - bytecode
---

#WTF Huff Minimalist Introduction: 08. Event

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce events in Huff, which, like events in Solidity, can store data in the log of `EVM`.

## event

In Solidity, we often use `event` to define and trigger events. When these events are triggered, they generate logs that permanently store the data on the blockchain. Logs are divided into topics (`topic`) and data (`data`). The first topic is usually the hash of the event signature, and the following topics are the event parameters modified by `indexed`. If you don’t know about `event`, please read the [corresponding chapter] of WTF Solidity(https://github.com/AmazingAng/WTF-Solidity/tree/main/12_Event).

The `LOG` directive in the EVM is used to create these logs. Instructions `LOG0` through `LOG4` differ in the number of topics they contain. For example, `LOG0` has no topics, while `LOG4` has four topics. If you don't know them, please read [WTF EVM Opcodes Lecture 15](https://github.com/WTFAcademy/WTF-EVM-Opcodes/blob/main/15_LogOp/readme.md).

## Events in Huff

Next, we modify the `Simple Store` contract in the previous lecture. When the `SET_VALUE()` method is called to change the value, a `ValueChanged` event will be released and the new value will be recorded in the EVM log.

First, you can define the contract's events in the Huff interface:

```c
#define event ValueChanged(uint256 indexed)
```

Next we release the `ValueChanged` event in the `SET_VALUE()` method. First, we need to determine which `LOG` directive we want to use to release the event. Because our event only has one indexed data, plus the event hash, there are `2` topics, `log2` should be used, and the input stack is `[0, 0, sig, value]`. Next, we only need to construct the required stack in the method, and then use `log2` to output the log at the end. We can push the event hash onto the stack using the built-in function `__EVENT_HASH()`.
```c
#define macro SET_VALUE() = takes (0) returns (0) {
    0x04 calldataload   // [value]
    dup1                // [value, value]
    [VALUE_LOCATION]    // [ptr, value, value]
    sstore              // [value]
    // release event
    __EVENT_HASH(ValueChanged) // [sig, value]
    push0 push0         // [0, 0, sig, value]
    log2                // []
    stop                // []
}
```

## Output Solidity interface/ABI

We can use the `huffc -g` command to convert the Huff contract interface to the Solidity contract interface/ABI:

```shell
huffc src/08_Event.huff -g
```

The output interface will be saved in the same folder as `08_Event.huff`, for example `src/I08_Event.sol`. As you can see, the events we defined have been included in the interface:

```solidity
interface I08_Event {
	event ValueChanged(uint256 indexed);
	function getValue() external view returns (uint256);
	function setValue(uint256) external;
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/08_Events.huff -r
```

The printed bytecode is:

```
5f3560e01c8063552410771461001e578063209652551461004a575f5ffd5b600435805f557fd9ce50fb8c432a73c4ed7e62e6128c95e62f29d3ee56042781a0368f192ccdb45f5fa2005b5f545f5260205ff3
```

Convert to a formatted table (the second half omits an unused `selector` in `stack`):

| pc   | op         | opcode                   | stack                          |
|------|------------|--------------------------|--------------------------------|
| [00] | 5f         | PUSH0                    | 0x00                           |
| [01] | 35         | CALLDATALOAD             | calldata                       |
| [02] | 60 e0      | PUSH1 0xE0               | 0xE0 calldata                  |
| [04] | 1c         | SHR                      | selector                       |
| [05] | 80         | DUP1                     | selector selector              |
| [06] | 63 55241077| PUSH4 0x55241077         | 0x55241077 selector selector   |
| [0a] | 14         | EQ                       | suc selector                   |
| [0b] | 61 001e    | PUSH2 0x001E             | 0x001E suc selector            |
| [0e] | 57         | JUMPI                    | selector                       |
| [0f] | 80         | DUP1                     | selector selector              |
| [10] | 63 209652  | PUSH4 0x20965255         | 0x20965255 selector selector   |
| [14] | 14         | EQ                       | suc selector                   |
| [15] | 61 0049    | PUSH2 0x0049             | 0x0049 suc selector            |
| [18] | 57         | JUMPI                    | selector                       |
| [19] | 5f         | PUSH0                    | 0x00                           |
| [1a] | 5f         | PUSH0                    | 0x00 0x00                      |
| [1b] | fd         | REVERT                   |                                |
| [1c] | 5b         | JUMPDEST                 |                                |
| [1d] | 60 04      | PUSH1 0x04               | 0x04                           |
| [1f] | 35         | CALLDATALOAD             | calldata@0x04                  |
| [20] | 5f         | PUSH0                    | 0x00 calldata@0x04             |
| [21] | 55         | SSTORE                   |                                |
| [22] | 5b         | JUMPDEST                 |                                |
| [23] | 60 04      | PUSH1 0x04               | 0x04                           |
| [25] | 35         | CALLDATALOAD             | calldata@0x04                  |
| [26] | 80         | DUP1                     | calldata@0x04 calldata@0x04    |
| [27] | 5f         | PUSH0                    | 0x00 calldata@0x04 calldata@0x04 |
| [28] | 55         | SSTORE                   | calldata@0x04                  |
| [29] | 7f d9ce50. | PUSH32 0xd9ce50..        | 0xd9ce50.. calldata@0x04       |
| [46] | 5f         | PUSH0                    | 0x00 0xd9ce50 calldata@0x04    |
| [47] | 5f         | PUSH0                    | 0x00 0x00 0xd9ce50 calldata@0x04 |
| [48] | a2         | LOG2                     |                                |
| [49] | 00         | STOP                     |                                |
| [4a] | 5b         | JUMPDEST                 |                                |
| [4b] | 5f         | PUSH0                    | 0x00                           |
| [4c] | 54         | SLOAD                    | value                          |
| [4d] | 5f         | PUSH0                    | 0x00 value                     |
| [4e] | 52         | MSTORE                   |                                |
| [4f] | 60 20      | PUSH1 0x20               | 0x20                           |
| [51] | 5f         | PUSH0                    | 0x00 0x20                      |
| [52] | f3         | RETURN                   |                                |

Among them, `[22]-[49]` is the bytecode of the `SET_VALUE()` method. We can see that this code uses `log2` to release the event after preparing the stack `[0x00 0x00 0xd9ce50 calldata@0x04]`.

## Summary

In this lecture, we introduced events in Huff, which, like Solidity events, can record data in the EVM log. Huff provides the built-in method `__EVENT_HASH()`, which allows us to calculate the event hash and push it onto the stack.
