---
title: 07. Interface
tags:
   -huff
   -interface
   - bytecode
---

# WTF Huff Minimalist Introduction: 07. Interface

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce the interface in Huff, which can be used to generate Solidity interface contracts/ABIs and facilitate us to use function selectors and event hashes in contracts.

## Interface

Similar to Solidity, you can define functions `functions`, events `events`, and errors `errors` in the Huff contract interface. The interface has two main functions:

1. After defining the interface, the function name can be used as a parameter of the built-in functions `__FUNC_SIG` (get function selector), `__EVENT_HASH` (event selector), and `__ERROR` (error selector)
2. Generate Solidity interface/contract ABI.

Functions in the interface can be of type `view`, `pure`, `payable` or `nonpayable`. Moreover, only externally visible functions need to be defined in the interface, not internal functions. Events in the interface can contain indexed values (using the `indexed` keyword) and non-indexed values.

Example of Huff interface:

```c
#define function testFunction(uint256, bytes32) view returns (bytes memory)

#define event TestEvent(address indexed, uint256)
```

## Simple Store Contract

Now, let us review the `Simple Store` contract introduced in the first lecture. After learning this, you should be able to understand it.

We divide the contract into two parts. The first part defines the interface and storage slot of the contract, and uses macros to implement the `SET_VALUE()` and `GET_VALUE` methods defined in the interface.

- `SET_VALUE()`: First use `calldataload` to read the new value from `calldata`, and then use `sstore` to save the value in the storage slot `VALUE_LOCATION`. Note that when the first line `0x04 calldataload` reads the value, the first `4` bytes are omitted because they are function selectors.

- `GET_VALUE()`: First use `sload` to read the value of the storage slot `VALUE_LOCATION`, use `mstore` to store the value into the memory, and then use `return` to return.

> Note, be sure to ensure that each method is ended correctly, and the code ends with `return`, `revert`, `stop`, `invalid` instructions, otherwise there may be loopholes.

```c
/* interface */
#define function setValue(uint256) nonpayable returns ()
#define function getValue() view returns (uint256)

/* Storage slot */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()

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

The second part is the Main macro, the main entry of the contract, which determines which function is called externally.

```c
//The main entrance of the contract, determine which function is called
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

1. In the first line, we use `0x00 calldataload 0xE0 shr` to read the first `4` bytes in `calldata`, which is the function selector. We will use this code often, so you can think about how it works.

2. After obtaining `selector`, we need to jump by comparing `setValue()` and `getValue()`. If there is no matching function, `revert`. Since we defined these two functions in the interface, we can use the built-in function `__FUNC_SIG()` to get their `selector` and push it onto the stack, and then use `eq` for comparison. Otherwise, you have to use `__FUNC_SIG("function setValue(uint256) nonpayable returns ()")`, which is very cumbersome.

3. After the two jump tags `set` and `get`, we run the `SET_VALUE()` and `GET_VALUE()` methods respectively to execute the corresponding logic.

## Output Solidity interface/ABI

We can use the `huffc -g` command to convert the Huff contract interface to the Solidity contract interface/ABI:

```shell
huffc src/07_Interface.huff -g
```

The output interface will be saved in the same folder as `07_Interface.huff`, for example, `src/I07_Iterface.sol`, content:
```solidity
interface I07_Interface {
	function getValue() external view returns (uint256);
	function setValue(uint256) external;
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/07_Interface.huff -r
```

The printed bytecode is:
```
5f3560e01c8063552410771461001e5780632096525514610025575f5ffd5b6004355f55005b5f545f5260205ff3
```

Convert to formatted table:

| pc   | op     | opcode         | stack              |
|------|--------|----------------|--------------------|
| [00] | 5f     | PUSH0          | 0x00               |
| [01] | 35     | CALLDATALOAD   | calldata           |
| [02] | 60e0 | PUSH1 0xE0     | 0xE0 calldata      |
| [04] | 1c     | SHR            | selector           |
| [05] | 80     | DUP1           | selector selector |
| [06] | 63 55241077 | PUSH4 0x55241077 | 0x55241077 selector selector |
| [0a] | 14     | EQ             | suc selector  |
| [0b] | 61 001e| PUSH2 0x001E   | 0x001E suc selector |
| [0e] | 57     | JUMPI          | selector      |
| [0f] | 80     | DUP1           | selector selector |
| [10] | 63 209652 | PUSH4 0x20965255 | 0x20965255 selector selector |
| [14] | 14     | EQ             | suc selector  |
| [15] | 61 0024| PUSH2 0x0024   | 0x0024 suc selector |
| [18] | 57     | JUMPI          | selector      |
| [19] | 5f     | PUSH0          | 0x00 selector              |
| [1a] | 5f     | PUSH0          | 0x00 0x00 selector          |
| [1b] | fd     | REVERT         | selector                   |
| [1c] | 5b     | JUMPDEST       | selector                   |
| [1d] | 60 04  | PUSH1 0x04     | 0x04 selector              |
| [1f] | 35     | CALLDATALOAD   | calldata@0x04 selector           |
| [20] | 5f     | PUSH0          | 0x00 calldata@0x04 selector     |
| [21] | 55     | SSTORE         | selector                |
| [22] | 00     | STOP           | selector                |
| [23] | 5b     | JUMPDEST       | selector                   |
| [24] | 5f     | PUSH0          | 0x00 selector              |
| [25] | 54     | SLOAD          | value selector             |
| [26] | 5f     | PUSH0          | 0x00 value selector        |
| [27] | 52     | MSTORE         | selector                   |
| [28] | 60 20  | PUSH1 0x20     | 0x20 selector               |
| [2a] | 5f     | PUSH0          | 0x00 0x20 selector         |
| [2b] | f3     | RETURN         | selector                  |

We can see that the function of this bytecode is:

1. Use `CALLDATALOAD` to read the value from `calldata`, and then use `SHR` to get the first 4` bytes of the function selector.
2. Use `EQ` to compare whether the function selector in `calldata` is `0x55241077` or `0x20965255`. If it matches, jump the PC to the corresponding `JUMPDEST` and execute `SET_VALUE()` or `GET_VALUE( )`method.


## Summary

In this lecture, we introduced the interface in Huff, which can be used to generate Solidity interface contracts/ABIs and help us use function selectors and event hashes in contracts.
