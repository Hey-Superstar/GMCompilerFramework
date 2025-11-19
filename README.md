# GMCompilerFramework

基于MLIR的国密算法编译框架（MLIR-based compilation framework for Chinese cryptographic algorithms）

GMCompilerFramework 致力于构建一个基于 MLIR 的国密算法（SM2 / SM9）中间层编译框架。

项目的核心思想是：让编译器能够理解国密算法的语义，从而实现跨平台、可优化的自动化生成。

本项目在 MLIR 中 定义国密算法方言（Dialect），将普通算术 IR 转换为国密算子，中间层获得算法语义后，编译器可以进一步进行领域特定优化

