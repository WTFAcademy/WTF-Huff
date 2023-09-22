# WTF Huff

我最近在重新学Huff，巩固一下细节，也写一个“WTF Huff极简入门”，供小白们使用（编程大佬可以另找教程），每周更新1-3讲。

> Huff 是一种低级编程语言，旨在开发在以太坊虚拟机（EVM）上运行的高度优化的智能合约。Huff 并没有隐藏 EVM 的内部工作原理，而是将其编程堆栈暴露给开发人员进行手动操作。

先修课程：
1. [WTF Solidity](https://github.com/AmazingAng/WTF-Solidity)
2. [WTF EVM Opcodes](https://github.com/WTFAcademy/WTF-EVM-Opcodes)

## 教程

**第01讲：Hello Huff**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/SimpleStore.huff) | [文章](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/01_HelloHuff/readme.md) 

**第02讲：存储**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/02_Storage.huff) | [文章](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/02_Storage/readme.md) 

**第03讲：常量**：[Code](https://github.com/WTFAcademy/WTF-Huff/blob/main/src/03_Constant.huff) | [文章](https://github.com/WTFAcademy/WTF-Huff/blob/main/tutorials/03_Constant/readme.md) 

## 运行模版项目

### 配置环境

要使用此模板，您需要安装以下内容。请按照链接和指示操作。

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    - 如果您可以运行`git --version`，则说明您已正确安装。
- [Foundry / Foundryup](https://github.com/gakonst/foundry)
    - 这将会安装`forge`，`cast`和`anvil`
    - 通过运行`forge --version`并获取类似`forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`的输出，您可以检测是否已正确安装。
    - 要获取每个工具的最新版本，只需运行`foundryup`。
- [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    - 如果您可以运行`huffc --version`并获取类似`huffc 0.3.0`的输出，则说明您已正确安装。

### 快速开始

1. 克隆[https://github.com/WTFAcademy/WTF-Huff]或[Huff模版仓库](https://github.com/huff-language/huff-project-template)。

运行：

```
git clone https://github.com/WTFAcademy/WTF-Huff
cd WTF-Huff
```

2. 安装依赖

克隆并进入您的仓库后，您需要安装必要的依赖项。为此，只需运行：

```shell
forge install
```

3. 构建 & 测试

要构建并测试您的合约，您可以运行：

```shell
forge build
forge test
```

有关如何使用Foundry的更多信息，请查看[Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge)和[foundry-huff library repository](https://github.com/huff-language/foundry-huff)。

## 参考

- [huff-project-template](https://github.com/huff-language/huff-project-template)
- [huff-doc](https://docs.huff.sh/)