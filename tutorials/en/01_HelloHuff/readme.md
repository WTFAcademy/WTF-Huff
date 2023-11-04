---
title: 01. Hello Huff
tags:
  - huff
  - template
  - evm
  - bytecode
---

# Minimalist introduction to WTF Huff: 01. Hello Huff

I'm re-learning Huff recently, consolidating the details, and writing a "Minimal Introduction to Huff" for novices (programmers can find another tutorial). I will update 1-3 lectures every week.

Twitter：[@0xAA_Science](https://twitter.com/0xAA_Science)

Community：[Discord](https://discord.gg/5akcruXrsk)｜WeChat Group(https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link)｜[Official Website wtf.academy](https://wtf.academy)

All code and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we will introduce the Huff language and use Foundry to run template contracts.

## Huff

You may be familiar with Solidity, but have almost never heard of Huff. Huff is a low-level programming language designed for Ethereum smart contracts that allows developers to write highly optimized EVM bytecode. Huff’s two major features:

1. Difficult to learn: Unlike Solidity, Huff abstracts the underlying working principles of EVM, but allows developers to directly operate the stack, memory, and storage of EVM.

2. Efficiency: Huff seems to have put a shell on EVM Opcodes, writing contracts almost directly at the bytecode level, with gas optimization to the extreme.

Therefore, you need to be familiar with the working principles of Solidity and EVM before learning Huff. Recommended prerequisite courses:
1. [WTF Solidity](https://github.com/WTFAcademy/WTF-Solidity)
2. [WTF EVM Opcodes](https://github.com/WTFAcademy/WTF-EVM-Opcodes)

## Hello Huff

Below we use a simple contract `SimpleStore.huff` to learn the structure of the Huff contract.

```c
/* Interface */
#define function setValue(uint256) nonpayable returns ()
#define function getValue() view returns (uint256)

/* Storage slot */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()

/* Method */
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

    // Return value
    0x20 0x00 return
}

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

Next, we will learn this huff contract in sections.

First, you need to define the interface of the contract. Like the interface of Solidity, you need to use the `#define` keyword.

```c
/* Interface */
#define function setValue(uint256) nonpayable returns ()
#define function getValue() view returns (uint256)
```

Next, you need to declare the storage slot, just like you declare state variables in the Solidity contract.
`FREE_STORAGE_POINTER()`Points to an unused storage slot in the contract（free storage）。

```c
/* Storage slot */
#define constant VALUE_LOCATION = FREE_STORAGE_POINTER()
```

The last part is to write the methods (functions) in the contract. This contract has `3` methods.

1. `SET_VALUE()`: Change the value stored in `VALUE_LOCATION`. It first uses `calldataload` to read the new value of the variable from calldata, and then uses `sstore` to store the new value into `VALUE_LOCATION`.
2. `GET_VALUE()`: Read the value stored in `VALUE_LOCATION`. It uses `sload` to push the value stored in `VALUE_LOCATION` onto the stack, then uses `mstore` to store the value into memory, and finally uses `return` to return.
3. `MAIN()`: Main macro, which defines the main entry of the contract. When an external call is made to the contract, this code is run to determine which function should be called. He first reads the function selector in calldata with `0x00 calldataload 0xE0 shr`, and then checks whether it matches `SET_VALUE()` or `GET_VALUE()`. If it matches, call the corresponding function; otherwise, roll back the transaction.

```c
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

## Run template project

Next, we introduce how to use Foundry’s plug-in foundry-huff to run the template project.

### Configuration Environment

First, you need to install the following locally:

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    - If you can run `git --version`, you have installed it correctly.
- [Foundry / Foundryup](https://github.com/gakonst/foundry)
    - This will install `forge`, `cast` and `anvil`
     - You can check if it has been installed correctly by running `forge --version` and getting output like `forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`.
     - To get the latest version of each tool, just run `foundryup`.
- [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    - If you can run `huffc --version` and get output similar to `huffc 0.3.0`, you have installed it correctly.

### Quick Start

1. Clone [https://github.com/WTFAcademy/WTF-Huff] or [Huff template repository](https://github.com/huff-language/huff-project-template).

run:

```
git clone https://github.com/WTFAcademy/WTF-Huff
cd WTF-Huff
```

2. Install dependencies

After cloning and entering your repository, you need to install the necessary dependencies. To do this, just run:

```shell
forge install
```

3. Build & Test

To build and test your contract, you can run:

```shell
forge build
forge test
```

![](./img/1-1.png)

4. Use `huffc` to print the bytecode of the huff contract:

```shell
huffc src/SimpleStore.huff -b
```

The console output will output the bytecode of the contract（creation code）:

```
602e8060093d393df35f3560e01c8063552410771461001e5780632096525514610025575f5ffd5b6004355f55005b5f545f5260205ff3
```

If you want to get the runtime code, you can use `huffc -r`.

For more information on how to use Foundry, check out the [Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge) and the [foundry-huff library repository](https:// github.com/huff-language/foundry-huff)

### Project structure diagram

```ml
lib
├─ forge-std — https://github.com/foundry-rs/forge-std
├─ foundry-huff — https://github.com/huff-language/foundry-huff
scripts
├─ Deploy.s.sol — department script
src
├─ SimpleStore — Simple storage contract in Huff
test
└─ SimpleStore.t — SimpleStore test
```

## Summary

In this lecture, we introduced the Huff language, learned the Huff contract structure, and ran a template project. Huff is a low-level programming language designed for Ethereum smart contracts. Learning it will not only allow you to write more optimized contracts, but also give you a deeper understanding of the EVM.
