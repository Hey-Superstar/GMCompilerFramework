module {
  // 循环左移 (x << n) | (x >> (32-n))
func.func @rotl(%x: i32, %n: i32) -> i32 {
  %c32 = arith.constant 32 : i32
  %c0 = arith.constant 0 : i32
  %n_mod = arith.remui %n, %c32 : i32
  %cmp_eq = arith.cmpi eq, %n_mod, %c0 : i32
  %result = scf.if %cmp_eq -> i32 {
    scf.yield %x : i32
  } else {
    %sub = arith.subi %c32, %n_mod : i32
    %left = arith.shli %x, %n_mod : i32
    %right = arith.shrui %x, %sub : i32
    %or = arith.ori %left, %right : i32
    scf.yield %or : i32
  }
  return %result : i32
}

  // 置换函数 P1(X) = X ^ rotl(X,15) ^ rotl(X,23)
  func.func @P1(%x: i32) -> i32 {
    %c15 = arith.constant 15 : i32
    %c23 = arith.constant 23 : i32
    %rot15 = func.call @rotl(%x, %c15) : (i32, i32) -> i32
    %rot23 = func.call @rotl(%x, %c23) : (i32, i32) -> i32
    %xor1 = arith.xori %x, %rot15 : i32
    %xor2 = arith.xori %xor1, %rot23 : i32
    return %xor2 : i32
  }

  // 置换函数 P0(X) = X ^ rotl(X,9) ^ rotl(X,17)
  func.func @P0(%x: i32) -> i32 {
    %c9 = arith.constant 9 : i32
    %c17 = arith.constant 17 : i32
    %rot9 = func.call @rotl(%x, %c9) : (i32, i32) -> i32
    %rot17 = func.call @rotl(%x, %c17) : (i32, i32) -> i32
    %xor1 = arith.xori %x, %rot9 : i32
    %xor2 = arith.xori %xor1, %rot17 : i32
    return %xor2 : i32
  }

  // 布尔函数 FF_j(X,Y,Z)
  func.func @FF(%j: i32, %x: i32, %y: i32, %z: i32) -> i32 {
    %c16 = arith.constant 16 : i32
    %cmp = arith.cmpi ult, %j, %c16 : i32
    // j < 16 : X^Y^Z
    %xor1 = arith.xori %x, %y : i32
    %xor2 = arith.xori %xor1, %z : i32
    // j >= 16 : (X&Y)|(X&Z)|(Y&Z)
    %and_xy = arith.andi %x, %y : i32
    %and_xz = arith.andi %x, %z : i32
    %and_yz = arith.andi %y, %z : i32
    %or1 = arith.ori %and_xy, %and_xz : i32
    %or2 = arith.ori %or1, %and_yz : i32
    %result = arith.select %cmp, %xor2, %or2 : i32
    return %result : i32
  }

  // 布尔函数 GG_j(X,Y,Z)
  func.func @GG(%j: i32, %x: i32, %y: i32, %z: i32) -> i32 {
    %c16 = arith.constant 16 : i32
    %cmp = arith.cmpi ult, %j, %c16 : i32
    // j < 16 : X^Y^Z
    %xor1 = arith.xori %x, %y : i32
    %xor2 = arith.xori %xor1, %z : i32
    // j >= 16 : (X&Y)|(~X&Z)
    %minus1 = arith.constant -1 : i32             
    %not_x = arith.xori %x, %minus1 : i32
    %and_xy = arith.andi %x, %y : i32
    %and_notx_z = arith.andi %not_x, %z : i32
    %or = arith.ori %and_xy, %and_notx_z : i32
    %result = arith.select %cmp, %xor2, %or : i32
    return %result : i32
  }
  func.func @sm3(%input: memref<?xi8>, %input_len: i64, %output: memref<32xi8>) {
    %c0 = arith.constant 0 : i64
    %c1 = arith.constant 1 : i64
    %c4 = arith.constant 4 : i64
    %c8 = arith.constant 8 : i64
    %c16 = arith.constant 16 : i64
    %c24 = arith.constant 24 : i64
    %c32 = arith.constant 32 : i64
    %c40 = arith.constant 40 : i64
    %c48 = arith.constant 48 : i64
    %c56 = arith.constant 56 : i64
    %c64 = arith.constant 64 : i64
    %c128 = arith.constant 128 : i8
    %c0_i8 = arith.constant 0 : i8
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c16_i32 = arith.constant 16 : i32
    %c24_i32 = arith.constant 24 : i32
    %c16_i32_shift = arith.constant 16 : i32
    %c8_i32 = arith.constant 8 : i32
    %c7_i32 = arith.constant 7 : i32
    %c9_i32 = arith.constant 9 : i32
    %c12_i32 = arith.constant 12 : i32
    %c15_i32 = arith.constant 15 : i32
    %c19_i32 = arith.constant 19 : i32
    %c23_i32 = arith.constant 23 : i32
    %c512 = arith.constant 512 : i64
    %c511 = arith.constant 511 : i64
    %c72 = arith.constant 72 : i64

    %c0_idx = arith.constant 0 : index
    %c1_idx = arith.constant 1 : index
    %c2_idx = arith.constant 2 : index
    %c3_idx = arith.constant 3 : index
    %c4_idx = arith.constant 4 : index
    %c6_idx = arith.constant 6 : index
    %c7_idx = arith.constant 7 : index
    %c8_idx = arith.constant 8 : index
    %c9_idx = arith.constant 9 : index
    %c12_idx = arith.constant 12 : index
    %c13_idx = arith.constant 13 : index
    %c15_idx = arith.constant 15 : index
    %c16_idx = arith.constant 16 : index
    %c17_idx = arith.constant 17 : index
    %c23_idx = arith.constant 23 : index
    %c24_idx = arith.constant 24 : index
    %c32_idx = arith.constant 32 : index
    %c40_idx = arith.constant 40 : index
    %c48_idx = arith.constant 48 : index
    %c56_idx = arith.constant 56 : index
    %c64_idx = arith.constant 64 : index
    %c68_idx = arith.constant 68 : index

    %A_iv = arith.constant 0x7380166f : i32
    %B_iv = arith.constant 0x4914b2b9 : i32
    %C_iv = arith.constant 0x172442d7 : i32
    %D_iv = arith.constant 0xda8a0600 : i32
    %E_iv = arith.constant 0xa96f30bc : i32
    %F_iv = arith.constant 0x163138aa : i32
    %G_iv = arith.constant 0xe38dee4d : i32
    %H_iv = arith.constant 0xb0fb0e4e : i32

    %T_low = arith.constant 0x79cc4519 : i32
    %T_high = arith.constant 0x7a879d8a : i32

    // 消息填充
    %bit_len = arith.muli %input_len, %c8 : i64
    %t1 = arith.addi %bit_len, %c64 : i64
    %t2 = arith.addi %t1, %c511 : i64
    %n_blocks = arith.divui %t2, %c512 : i64
    %total_bytes = arith.muli %n_blocks, %c64 : i64

    %input_len_idx = arith.index_cast %input_len : i64 to index
    %total_bytes_idx = arith.index_cast %total_bytes : i64 to index
    %n_blocks_idx = arith.index_cast %n_blocks : i64 to index

    %padded = memref.alloc(%total_bytes_idx) : memref<?xi8>

    scf.for %i = %c0_idx to %input_len_idx step %c1_idx {
      %val = memref.load %input[%i] : memref<?xi8>
      memref.store %val, %padded[%i] : memref<?xi8>
    }

    memref.store %c128, %padded[%input_len_idx] : memref<?xi8>

    %last_len_start = arith.subi %total_bytes, %c8 : i64
    %last_len_start_idx = arith.index_cast %last_len_start : i64 to index

    %input_len_plus1 = arith.addi %input_len, %c1 : i64
    %input_len_plus1_idx = arith.index_cast %input_len_plus1 : i64 to index
    scf.for %j = %input_len_plus1_idx to %last_len_start_idx step %c1_idx {
      memref.store %c0_i8, %padded[%j] : memref<?xi8>
    }

    %b0 = arith.shrui %bit_len, %c56 : i64
    %b0_trunc = arith.trunci %b0 : i64 to i8
    %b1 = arith.shrui %bit_len, %c48 : i64
    %b1_trunc = arith.trunci %b1 : i64 to i8
    %b2 = arith.shrui %bit_len, %c40 : i64
    %b2_trunc = arith.trunci %b2 : i64 to i8
    %b3 = arith.shrui %bit_len, %c32 : i64
    %b3_trunc = arith.trunci %b3 : i64 to i8
    %b4 = arith.shrui %bit_len, %c24 : i64
    %b4_trunc = arith.trunci %b4 : i64 to i8
    %b5 = arith.shrui %bit_len, %c16 : i64
    %b5_trunc = arith.trunci %b5 : i64 to i8
    %b6 = arith.shrui %bit_len, %c8 : i64
    %b6_trunc = arith.trunci %b6 : i64 to i8
    %b7 = arith.trunci %bit_len : i64 to i8  

    memref.store %b0_trunc, %padded[%last_len_start_idx] : memref<?xi8>
    %idx1 = arith.addi %last_len_start_idx, %c1_idx : index
    memref.store %b1_trunc, %padded[%idx1] : memref<?xi8>
    %idx2 = arith.addi %idx1, %c1_idx : index
    memref.store %b2_trunc, %padded[%idx2] : memref<?xi8>
    %idx3 = arith.addi %idx2, %c1_idx : index
    memref.store %b3_trunc, %padded[%idx3] : memref<?xi8>
    %idx4 = arith.addi %idx3, %c1_idx : index
    memref.store %b4_trunc, %padded[%idx4] : memref<?xi8>
    %idx5 = arith.addi %idx4, %c1_idx : index
    memref.store %b5_trunc, %padded[%idx5] : memref<?xi8>
    %idx6 = arith.addi %idx5, %c1_idx : index
    memref.store %b6_trunc, %padded[%idx6] : memref<?xi8>
    %idx7 = arith.addi %idx6, %c1_idx : index
    memref.store %b7, %padded[%idx7] : memref<?xi8> 

    // 迭代压缩每个 512 位块
    %final:8 = scf.for %blk = %c0_idx to %n_blocks_idx step %c1_idx
        iter_args(%A = %A_iv, %B = %B_iv, %C = %C_iv, %D = %D_iv,
                  %E = %E_iv, %F = %F_iv, %G = %G_iv, %H = %H_iv)
        -> (i32, i32, i32, i32, i32, i32, i32, i32) {

      %blk_i64 = arith.index_cast %blk : index to i64
      %blk_offset_val = arith.muli %blk_i64, %c64 : i64
      %blk_offset = arith.index_cast %blk_offset_val : i64 to index

      %W = memref.alloca() : memref<68xi32>
      %W1 = memref.alloca() : memref<64xi32>

      // 加载 16 个字
      scf.for %k = %c0_idx to %c16_idx step %c1_idx {
        %k_i64 = arith.index_cast %k : index to i64
        %k_times_4 = arith.muli %k_i64, %c4 : i64
        %byte_off_val = arith.addi %blk_offset_val, %k_times_4 : i64
        %byte_off = arith.index_cast %byte_off_val : i64 to index

        %byte0 = memref.load %padded[%byte_off] : memref<?xi8>
        %off1 = arith.addi %byte_off, %c1_idx : index
        %byte1 = memref.load %padded[%off1] : memref<?xi8>
        %off2 = arith.addi %byte_off, %c2_idx : index
        %byte2 = memref.load %padded[%off2] : memref<?xi8>
        %off3 = arith.addi %byte_off, %c3_idx : index
        %byte3 = memref.load %padded[%off3] : memref<?xi8>

        %b0_ext = arith.extui %byte0 : i8 to i32
        %b1_ext = arith.extui %byte1 : i8 to i32
        %b2_ext = arith.extui %byte2 : i8 to i32
        %b3_ext = arith.extui %byte3 : i8 to i32

        %s0 = arith.shli %b0_ext, %c24_i32 : i32
        %s1 = arith.shli %b1_ext, %c16_i32_shift : i32
        %s2 = arith.shli %b2_ext, %c8_i32 : i32
        %or1 = arith.ori %s0, %s1 : i32
        %or2 = arith.ori %or1, %s2 : i32
        %word = arith.ori %or2, %b3_ext : i32
        memref.store %word, %W[%k] : memref<68xi32>
      }

      // 消息扩展 W[16..67]
      scf.for %j = %c16_idx to %c68_idx step %c1_idx {
        %jm16 = arith.subi %j, %c16_idx : index
        %jm9  = arith.subi %j, %c9_idx  : index
        %jm3  = arith.subi %j, %c3_idx  : index
        %jm13 = arith.subi %j, %c13_idx : index
        %jm6  = arith.subi %j, %c6_idx  : index

        %w_jm16 = memref.load %W[%jm16] : memref<68xi32>
        %w_jm9  = memref.load %W[%jm9]  : memref<68xi32>
        %w_jm3  = memref.load %W[%jm3]  : memref<68xi32>
        %w_jm13 = memref.load %W[%jm13] : memref<68xi32>
        %w_jm6  = memref.load %W[%jm6]  : memref<68xi32>

        %rot15 = func.call @rotl(%w_jm3, %c15_i32) : (i32,i32)->i32
        %xor1 = arith.xori %w_jm16, %w_jm9 : i32
        %xor2 = arith.xori %xor1, %rot15 : i32

        %p1tmp = func.call @P1(%xor2) : (i32)->i32

        %rot7 = func.call @rotl(%w_jm13, %c7_i32) : (i32,i32)->i32

        %xor3 = arith.xori %p1tmp, %rot7 : i32
        %wj = arith.xori %xor3, %w_jm6 : i32
        memref.store %wj, %W[%j] : memref<68xi32>
      }

      // 生成 W1[0..63]
      scf.for %j = %c0_idx to %c64_idx step %c1_idx {
        %jp4 = arith.addi %j, %c4_idx : index
        %wj   = memref.load %W[%j]   : memref<68xi32>
        %wjp4 = memref.load %W[%jp4] : memref<68xi32>
        %w1j = arith.xori %wj, %wjp4 : i32
        memref.store %w1j, %W1[%j] : memref<64xi32>
      }

      // 64 轮压缩
      %c64_i32 = arith.constant 64 : i32
      %c64_idx_loop = arith.constant 64 : index
      %round_res:8 = scf.for %r = %c0_idx to %c64_idx_loop step %c1_idx
          iter_args(%A_r = %A, %B_r = %B, %C_r = %C, %D_r = %D,
                    %E_r = %E, %F_r = %F, %G_r = %G, %H_r = %H)
          -> (i32, i32, i32, i32, i32, i32, i32, i32) {

        %r_i32 = arith.index_cast %r : index to i32

        %cmp_r = arith.cmpi ult, %r_i32, %c16_i32 : i32
        %T_j = arith.select %cmp_r, %T_low, %T_high : i32

        %rotA12 = func.call @rotl(%A_r, %c12_i32) : (i32,i32)->i32
        %rotTj = func.call @rotl(%T_j, %r_i32) : (i32,i32)->i32

        %sum1 = arith.addi %rotA12, %E_r : i32
        %sum2 = arith.addi %sum1, %rotTj : i32
        %SS1 = func.call @rotl(%sum2, %c7_i32) : (i32,i32)->i32

        %SS2 = arith.xori %SS1, %rotA12 : i32

        %w1j = memref.load %W1[%r] : memref<64xi32>
        %ff = func.call @FF(%r_i32, %A_r, %B_r, %C_r) : (i32,i32,i32,i32)->i32
        %tt1p1 = arith.addi %ff, %D_r : i32
        %tt1p2 = arith.addi %tt1p1, %SS2 : i32
        %TT1 = arith.addi %tt1p2, %w1j : i32

        %wj = memref.load %W[%r] : memref<68xi32>
        %gg = func.call @GG(%r_i32, %E_r, %F_r, %G_r) : (i32,i32,i32,i32)->i32
        %tt2p1 = arith.addi %gg, %H_r : i32
        %tt2p2 = arith.addi %tt2p1, %SS1 : i32
        %TT2 = arith.addi %tt2p2, %wj : i32

        // 更新寄存器（直接计算所需新值）
        %new_C = func.call @rotl(%B_r, %c9_i32) : (i32,i32)->i32
        %new_G = func.call @rotl(%F_r, %c19_i32) : (i32,i32)->i32
        %new_E = func.call @P0(%TT2) : (i32)->i32

        scf.yield %TT1, %A_r, %new_C, %C_r,
                  %new_E, %E_r, %new_G, %G_r : i32, i32, i32, i32, i32, i32, i32, i32
      }

	%A_next = arith.xori %A, %round_res#0 : i32
	%B_next = arith.xori %B, %round_res#1 : i32
	%C_next = arith.xori %C, %round_res#2 : i32
	%D_next = arith.xori %D, %round_res#3 : i32
	%E_next = arith.xori %E, %round_res#4 : i32
	%F_next = arith.xori %F, %round_res#5 : i32
	%G_next = arith.xori %G, %round_res#6 : i32
	%H_next = arith.xori %H, %round_res#7 : i32

      scf.yield %A_next, %B_next, %C_next, %D_next,
                %E_next, %F_next, %G_next, %H_next : i32, i32, i32, i32, i32, i32, i32, i32
    }

    // 输出哈希值（大端）
    %c0_out = arith.constant 0 : index
    %c1_out = arith.constant 1 : index
    %c2_out = arith.constant 2 : index
    %c3_out = arith.constant 3 : index
    %c4_out = arith.constant 4 : index
    %c5_out = arith.constant 5 : index
    %c6_out = arith.constant 6 : index
    %c7_out = arith.constant 7 : index

    // A
    %b0_A = arith.shrui %final#0, %c24_i32 : i32
    %b0_A_trunc = arith.trunci %b0_A : i32 to i8
    %b1_A = arith.shrui %final#0, %c16_i32_shift : i32
    %b1_A_trunc = arith.trunci %b1_A : i32 to i8
    %b2_A = arith.shrui %final#0, %c8_i32 : i32
    %b2_A_trunc = arith.trunci %b2_A : i32 to i8
    %b3_A = arith.trunci %final#0 : i32 to i8   // 直接得到 i8
    memref.store %b0_A_trunc, %output[%c0_out] : memref<32xi8>
    memref.store %b1_A_trunc, %output[%c1_out] : memref<32xi8>
    memref.store %b2_A_trunc, %output[%c2_out] : memref<32xi8>
    memref.store %b3_A, %output[%c3_out] : memref<32xi8>   // 使用 %b3_A

    // B
    %b0_B = arith.shrui %final#1, %c24_i32 : i32
    %b0_B_trunc = arith.trunci %b0_B : i32 to i8
    %b1_B = arith.shrui %final#1, %c16_i32_shift : i32
    %b1_B_trunc = arith.trunci %b1_B : i32 to i8
    %b2_B = arith.shrui %final#1, %c8_i32 : i32
    %b2_B_trunc = arith.trunci %b2_B : i32 to i8
    %b3_B = arith.trunci %final#1 : i32 to i8
    memref.store %b0_B_trunc, %output[%c4_out] : memref<32xi8>
    memref.store %b1_B_trunc, %output[%c5_out] : memref<32xi8>
    memref.store %b2_B_trunc, %output[%c6_out] : memref<32xi8>
    memref.store %b3_B, %output[%c7_out] : memref<32xi8>

    // C
    %b0_C = arith.shrui %final#2, %c24_i32 : i32
    %b0_C_trunc = arith.trunci %b0_C : i32 to i8
    %b1_C = arith.shrui %final#2, %c16_i32_shift : i32
    %b1_C_trunc = arith.trunci %b1_C : i32 to i8
    %b2_C = arith.shrui %final#2, %c8_i32 : i32
    %b2_C_trunc = arith.trunci %b2_C : i32 to i8
    %b3_C = arith.trunci %final#2 : i32 to i8
    %c8_out = arith.constant 8 : index
    %c9_out = arith.constant 9 : index
    %c10_out = arith.constant 10 : index
    %c11_out = arith.constant 11 : index
    memref.store %b0_C_trunc, %output[%c8_out] : memref<32xi8>
    memref.store %b1_C_trunc, %output[%c9_out] : memref<32xi8>
    memref.store %b2_C_trunc, %output[%c10_out] : memref<32xi8>
    memref.store %b3_C, %output[%c11_out] : memref<32xi8>

    // D
    %b0_D = arith.shrui %final#3, %c24_i32 : i32
    %b0_D_trunc = arith.trunci %b0_D : i32 to i8
    %b1_D = arith.shrui %final#3, %c16_i32_shift : i32
    %b1_D_trunc = arith.trunci %b1_D : i32 to i8
    %b2_D = arith.shrui %final#3, %c8_i32 : i32
    %b2_D_trunc = arith.trunci %b2_D : i32 to i8
    %b3_D = arith.trunci %final#3 : i32 to i8
    %c12_out = arith.constant 12 : index
    %c13_out = arith.constant 13 : index
    %c14_out = arith.constant 14 : index
    %c15_out = arith.constant 15 : index
    memref.store %b0_D_trunc, %output[%c12_out] : memref<32xi8>
    memref.store %b1_D_trunc, %output[%c13_out] : memref<32xi8>
    memref.store %b2_D_trunc, %output[%c14_out] : memref<32xi8>
    memref.store %b3_D, %output[%c15_out] : memref<32xi8>

    // E
    %b0_E = arith.shrui %final#4, %c24_i32 : i32
    %b0_E_trunc = arith.trunci %b0_E : i32 to i8
    %b1_E = arith.shrui %final#4, %c16_i32_shift : i32
    %b1_E_trunc = arith.trunci %b1_E : i32 to i8
    %b2_E = arith.shrui %final#4, %c8_i32 : i32
    %b2_E_trunc = arith.trunci %b2_E : i32 to i8
    %b3_E = arith.trunci %final#4 : i32 to i8
    %c16_out = arith.constant 16 : index
    %c17_out = arith.constant 17 : index
    %c18_out = arith.constant 18 : index
    %c19_out = arith.constant 19 : index
    memref.store %b0_E_trunc, %output[%c16_out] : memref<32xi8>
    memref.store %b1_E_trunc, %output[%c17_out] : memref<32xi8>
    memref.store %b2_E_trunc, %output[%c18_out] : memref<32xi8>
    memref.store %b3_E, %output[%c19_out] : memref<32xi8>

    // F
    %b0_F = arith.shrui %final#5, %c24_i32 : i32
    %b0_F_trunc = arith.trunci %b0_F : i32 to i8
    %b1_F = arith.shrui %final#5, %c16_i32_shift : i32
    %b1_F_trunc = arith.trunci %b1_F : i32 to i8
    %b2_F = arith.shrui %final#5, %c8_i32 : i32
    %b2_F_trunc = arith.trunci %b2_F : i32 to i8
    %b3_F = arith.trunci %final#5 : i32 to i8
    %c20_out = arith.constant 20 : index
    %c21_out = arith.constant 21 : index
    %c22_out = arith.constant 22 : index
    %c23_out = arith.constant 23 : index
    memref.store %b0_F_trunc, %output[%c20_out] : memref<32xi8>
    memref.store %b1_F_trunc, %output[%c21_out] : memref<32xi8>
    memref.store %b2_F_trunc, %output[%c22_out] : memref<32xi8>
    memref.store %b3_F, %output[%c23_out] : memref<32xi8>

    // G
    %b0_G = arith.shrui %final#6, %c24_i32 : i32
    %b0_G_trunc = arith.trunci %b0_G : i32 to i8
    %b1_G = arith.shrui %final#6, %c16_i32_shift : i32
    %b1_G_trunc = arith.trunci %b1_G : i32 to i8
    %b2_G = arith.shrui %final#6, %c8_i32 : i32
    %b2_G_trunc = arith.trunci %b2_G : i32 to i8
    %b3_G = arith.trunci %final#6 : i32 to i8
    %c24_out = arith.constant 24 : index
    %c25_out = arith.constant 25 : index
    %c26_out = arith.constant 26 : index
    %c27_out = arith.constant 27 : index
    memref.store %b0_G_trunc, %output[%c24_out] : memref<32xi8>
    memref.store %b1_G_trunc, %output[%c25_out] : memref<32xi8>
    memref.store %b2_G_trunc, %output[%c26_out] : memref<32xi8>
    memref.store %b3_G, %output[%c27_out] : memref<32xi8>

    // H
    %b0_H = arith.shrui %final#7, %c24_i32 : i32
    %b0_H_trunc = arith.trunci %b0_H : i32 to i8
    %b1_H = arith.shrui %final#7, %c16_i32_shift : i32
    %b1_H_trunc = arith.trunci %b1_H : i32 to i8
    %b2_H = arith.shrui %final#7, %c8_i32 : i32
    %b2_H_trunc = arith.trunci %b2_H : i32 to i8
    %b3_H = arith.trunci %final#7 : i32 to i8
    %c28_out = arith.constant 28 : index
    %c29_out = arith.constant 29 : index
    %c30_out = arith.constant 30 : index
    %c31_out = arith.constant 31 : index
    memref.store %b0_H_trunc, %output[%c28_out] : memref<32xi8>
    memref.store %b1_H_trunc, %output[%c29_out] : memref<32xi8>
    memref.store %b2_H_trunc, %output[%c30_out] : memref<32xi8>
    memref.store %b3_H, %output[%c31_out] : memref<32xi8>

    return
  }
}
