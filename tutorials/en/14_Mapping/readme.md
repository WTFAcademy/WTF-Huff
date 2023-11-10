---
title: 14. Mapping
tags:
   -huff
   -interface
   -mapping
   - bytecode
---

# WTF Huff Minimalist Introduction: 14. Mapping

I'm re-learning Huff recently, consolidating the details, and writing a "Minimalist Introduction to Huff" for novices (programming experts can find another tutorial). I will update 1-3 lectures every week.

Twitter: [@0xAA_Science](https://twitter.com/0xAA_Science)

Community: [Discord](https://discord.gg/5akcruXrsk)｜[WeChat Group](https://docs.google.com/forms/d/e/1FAIpQLSe4KGT8Sh6sJ7hedQRuIYirOoZK_85miz3dw7vA1-YjodgJ-A/viewform?usp=sf_link) |[Official website wtf.academy](https://wtf.academy)

All codes and tutorials are open source on github: [github.com/AmazingAng/WTF-Huff](https://github.com/AmazingAng/WTF-Huff)

-----

In this lecture, we introduce how to use mapping (`mapping`) in Huff, including saving it to a state variable and returning it in a function.

## Mapping

In Solidity contracts, we often use mapping variables. Huff does not natively support mapping types, but we can implement it in Huff based on Solidity's storage layout.

Solidity contract to be implemented:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Mapping {
    mapping(uint => uint) map;


    function setMap(uint key, uint value) external{
        map[key] = value;
    }

    function getMap(uint key) external view returns(uint value){
        value = map[key];
    }
}
```

## Mapping type advanced

Let's take the `mapping(uint => uint)` type as an example to introduce how Solidity's `mapping` type variables are laid out in storage. For more information about storage layout, please refer to [Solidity Documentation](https://docs.soliditylang.org/zh/v0.8.20/internals/layout_in_storage.html). Since the `mapping` type will not be used as the content of `calldata` or `returndata`, we do not need to consider them.

### Storage layout

The storage layout of the `mapping` type is similar to that of a dynamic array. Suppose we start to store a `mapping(uint => uint)` type data `map` starting from storage slot `p`, then slot `p` does not directly contain any mapped content. The value corresponding to map key `k` is located in `keccak256(h(k) . p)`, where `.` is the concatenator and `h` is a function that is applied to the key according to its type.

- For value types, function `h` will fill the value to `32` bytes in the same way as it stores the value in memory. For example, `1` of type `uint8` will be filled with `000000000000000000000000000000000000000000000000000000000000001`.

- For strings and byte arrays, `h(k)` is just unfilled data.

That is, if a map key is `1` and the storage slot is `0`, the storage slot where its value resides is represented by `keccak256(000000000000000000000000000000000000000000000 000000000000000000000000000000000)` result is given, which is slot `0xad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5`.

## Implement mapping type in Huff

### setMap

Next, we use Huff to implement the `setMap()` function and store the `uint` type key-value pair in the state variable. Its logic is:

- Read the value of key-value pair from `calldata`.
- The storage slot where the calculated value is located.
- Store the value into the corresponding storage slot.

```c
/* interface */
#define function setMap(uint256 key, uint256 value) nonpayable returns ()
#define function getMap(uint256 key) view returns (uint256 value)

/* method */
#define macro SET_MAP() = takes (0) returns (0) {
	// Suppose we save the mapping in slot 0, and the key-value pair is k-v
    0x24 calldataload   // [v]
    0x04 calldataload   // [k, v]

    0x00 mstore         // [v] memory: [0x00: k]
    0x40 0x00 sha3      // [sha3(k.0), v] memory: [0x00: k]

    sstore              // [] memory: [0x00: k] storage [sha3(k.0): v]

    stop
}
```

Below we implement the `getMap()` function, its main logic:
- Read keys from `calldata`.
- The storage slot where the calculated value is located.
- Read the value corresponding to the key through `sload`.
- Store the value in memory and return it via `return`.

```c
#define macro GET_MAP() = takes (0) returns (0) {
    // Suppose we save the mapping in slot 0
    0x04 calldataload   // [k]
    0x00 mstore         // [] memory: [0x00: k]
    0x40 0x00 sha3      // [sha3(k.0)] memory: [0x00: k]

    sload               // [v] memory: [0x00: k]

    // Store value in memory
    0x00 mstore         // [] memory: [0x00: v]

    // return value
    0x20 0x00 return
}
```

Finally, we use the selector in the MAIN macro to determine which function to call.

```c
#define macro MAIN() = takes (0) returns (0) {
    // Determine which function to call through selector
    0x00 calldataload 0xE0 shr
    dup1 __FUNC_SIG(setMap) eq set_map jumpi
    dup1 __FUNC_SIG(getMap) eq get_map jumpi

    //If there is no matching function, revert
    0x00 0x00 revert

    set_map:
        SET_MAP()
    get_map:
        GET_MAP()
}
```

## Analyze contract bytecode

We can use the `huffc` command to obtain the runtime code of the above contract:

```shell
huffc src/14_Mapping.huff -r
```

The printed bytecode is:

```
5f3560e01c80636c4668ea1461001e578063025799f01461002d575f5ffd5b6024356004355f5260405f2055005b6004355f5260405f20545f5260205ff3
```

Copy this bytecode to [evm.codes playground](https://www.evm.codes/playground?fork=shanghai). First, we call the `setMap()` function. Set `Calldata` to `0x6c4668ea000000000000000000000000000000000000000000000000000000000000000000000000000 00000000000000000000002` (call the `setMap` function, key is `1`, value is `2`) and click Run. The `Storage` in the lower right corner was changed accordingly and the operation was successful.

![](./img/14-1.png)

Next, we call the `getMap()` function to read the value corresponding to the key. Set `Calldata` to `0x025799f0000000000000000000000000000000000000000000000000000000000000001` (call the `getMap` function, the queried key is `1`), and run. As you can see, the `RETURN VALUE` in the lower right corner is `00000000000000000000000000000000000000000000000000000000000002`, which is consistent with expectations and the operation was successful.

![](./img/14-2.png)

## Test using Foundry

We can use Foundry to write a test and use Solidity to verify whether the Huff contract we wrote can work properly.

Test contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract MappingTest is Test {
    /// @dev Address of the I14_Mapping contract.
    I14_Mapping public i14_Mapping;

    /// @dev Setup the testing environment.
    function setUp() public {
        i14_Mapping = I14_Mapping(HuffDeployer.deploy("14_Mapping"));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetMapping() public {
        uint k = 1;
        uint v = 2;
        i14_Mapping.setMap(k, v);
        assertEq(v, i14_Mapping.getMap(k));
    }
}

interface I14_Mapping {
	function getMap(uint256) external view returns (uint256);
	function setMap(uint256, uint256) external;
}
```

Enter `forge test` in the command line input to run the test contract, and you can see that the test passes!

![](./img/14-3.png)

## Summary

In this lecture, we introduced how to write and read `mapping` type mapping in Huff, and successfully run the contract on `evm.codes`.
