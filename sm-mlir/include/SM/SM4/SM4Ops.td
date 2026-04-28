// 定义 SM4 的基础类
class SM4_Op<string mnemonic, list<Trait> traits = []> :
    Op<SM4_Dialect, mnemonic, traits>;

// 定义轮函数 Op: [X0, X1, X2, X3] + RK -> X4
def SM4_RoundOp : SM4_Op<"round"> {
    let summary = "SM4 single round transformation";
    
    // 输入：4个32位字（状态）和一个32位轮密钥
    let arguments = (ins I32:$x0, I32:$x1, I32:$x2, I32:$x3, I32:$rk);
    
    // 输出：产生下一个32位状态
    let results = (outs I32:$next_x);

    let assemblyFormat = "$x0 `,` $x1 `,` $x2 `,` $x3 `with` $rk attr-dict `:` type($rk)";
}