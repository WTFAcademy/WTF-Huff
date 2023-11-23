# WTF Huff

:globe_with_meridians:	**[中文 Version](https://github.com/WTFAcademy/WTF-Huff/blob/main/README.md)** :globe_with_meridians:	


Recently, I have been relearning Huff, consolidating the finer details, and writing a "WTF Huff Tutorial" for newbies. Lectures are updated 1~3 times weekly.

Prerequisite:
1. [WTF Solidity](https://github.com/AmazingAng/WTF-Solidity)
2. [WTF EVM Opcodes](https://github.com/WTFAcademy/WTF-EVM-Opcodes)

## Tutorial

### Intro 101

**Chapter 01: Hello Huff**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/SimpleStore.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/01_HelloHuff/readme.md) 

**Chapter 02: Storage**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/02_Storage.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/02_Storage/readme.md) 

**Chapter 03: Constant**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/03_Constant.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/03_Constant/readme.md) 

**Chapter 04: Macro**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/04_Macro.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/04_Macro/readme.md) 

**Chapter 05: Main Macro**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/05_Main.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/05_Main/readme.md) 

**Chapter 06: Control Flow**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/06_ControlFlow.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/06_ControlFlow/readme.md) 

**Chapter 07: Interface**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/07_Interface.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/07_Interface/readme.md) 

**Chapter 08: Event**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/08_Event.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/08_Event/readme.md) 

**Chapter 09: Error**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/09_Error.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/09_Error/readme.md) 

**Chapter 10: Constructor**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/10_Constructor.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/10_Constructor/readme.md) 

### Advanced 102

**Chapter 11: Loop**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/11_Loop.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/11_Loop/readme.md) 

**Chapter 12: String**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/12_String.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/12_String/readme.md) 

**Chapter 13: Array**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/13_Array.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/13_Array/readme.md) 

**Chapter 14: Mapping**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/14_Mapping.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/14_Mapping/readme.md) 

**Chapter 15: Import**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/15_Import.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/15_Import/readme.md) 

**Chapter 16: Access Control**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/16_Ownable.huff) | [Tutorial](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/en/16_Ownable/readme.md) 

## How to run Huff code

### Requirements

The following will need to be installed in order to use this template. Please follow the links and instructions.

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`
    -   To get the latest of each, just run `foundryup`
-   [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    -   You'll know you've done it right if you can run `huffc --version` and get an output like: `huffc 0.3.0`

### Quick Start

1. Clone [WTF Huff](https://github.com/WTFAcademy/WTF-Huff) or [Huff Template repo](https://github.com/huff-language/huff-project-template)。

Run:

```
git clone https://github.com/WTFAcademy/WTF-Huff
cd WTF-Huff
```

2. Install dependencies

Once you've cloned and entered into your repository, you need to install the necessary dependencies. In order to do so, simply run:

```shell
forge install
```

3. Build & Test

To build and test your contracts, you can run:

```shell
forge build
forge test
```

For more information on how to use Foundry, check out the [Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge) and the [foundry-huff library repository](https://github.com/huff-language/foundry-huff).

## Reference

- [huff-project-template](https://github.com/huff-language/huff-project-template)
- [huff-doc](https://docs.huff.sh/)