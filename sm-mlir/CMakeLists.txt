find_package(MLIR REQUIRED CONFIG HINTS 
    "~/workspace/GMCompilerFramework/llvm-project/build/lib/cmake/mlir"
)
find_package(LLVM REQUIRED CONFIG HINTS 
    "~/workspace/GMCompilerFramework/llvm-project/build/lib/cmake/llvm"
)

include(AddMLIR)