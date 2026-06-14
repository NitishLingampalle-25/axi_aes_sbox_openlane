// ==============================================================================
// Module Name: aes_sbox_gf
// Description: High-Performance AES S-Box using GF((2^4)^2) Composite Field Math.
//              Optimized for low-area and high-frequency physical implementation.
// ==============================================================================

module aes_sbox_gf (
    input  [7:0] sbox_in,
    output [7:0] sbox_out
);

    // Isomorphic mapping signals from GF(2^8) to GF((2^4)^2)
    wire [3:0] q_h, q_l;
    
    // Intermediate inversion signals
    wire [3:0] q_h_sq;
    wire [3:0] q_h_l_prod;
    wire [3:0] q_l_sq_scl;
    wire [3:0] inv_core_in;
    wire [3:0] inv_core_out;
    
    // Matrix outputs before final affine transformation
    wire [3:0] p_h, p_l;
    wire [7:0] inv_byte;

    // --------------------------------------------------------------------------
    // STAGE 1: Isomorphic Mapping Matrix (delta)
    // Converts 8-bit input to two 4-bit elements in the composite field
    // --------------------------------------------------------------------------
    assign q_h[3] = sbox_in[7] ^ sbox_in[5];
    assign q_h[2] = sbox_in[7] ^ sbox_in[6] ^ sbox_in[4] ^ sbox_in[3];
    assign q_h[1] = sbox_in[6] ^ sbox_in[5] ^ sbox_in[4];
    assign q_h[0] = sbox_in[7] ^ sbox_in[5] ^ sbox_in[3] ^ sbox_in[2];

    assign q_l[3] = sbox_in[7] ^ sbox_in[6] ^ sbox_in[5] ^ sbox_in[1];
    assign q_l[2] = sbox_in[6] ^ sbox_in[2];
    assign q_l[1] = sbox_in[6] ^ sbox_in[4] ^ sbox_in[1];
    assign q_l[0] = sbox_in[6] ^ sbox_in[1] ^ sbox_in[0];

    // --------------------------------------------------------------------------
    // STAGE 2: GF(2^4) Inversion Core Logic
    // Formula: Inv = (q_h^2 * Lambda) + (q_h * q_l) + q_l^2
    // --------------------------------------------------------------------------

    // 1. Squaring Unit for High Nibble: q_h^2 in GF(2^4)
    assign q_h_sq[3] = q_h[3];
    assign q_h_sq[2] = q_h[3] ^ q_h[2];
    assign q_h_sq[1] = q_h[2] ^ q_h[1];
    assign q_h_sq[0] = q_h[2] ^ q_h[1] ^ q_h[0];

    // 2. Scale by Scale Constant Lambda (0x8 in standard Canright basis)
    assign q_l_sq_scl[3] = q_h_sq[2] ^ q_h_sq[0];
    assign q_l_sq_scl[2] = q_h_sq[3];
    assign q_l_sq_scl[1] = q_h_sq[3] ^ q_h_sq[2];
    assign q_l_sq_scl[0] = q_h_sq[1];

    // 3. GF(2^4) Multiplier: q_h * q_l
    wire a32 = q_h[3] ^ q_h[2];
    wire a10 = q_h[1] ^ q_h[0];
    wire b32 = q_l[3] ^ q_l[2];
    wire b10 = q_l[1] ^ q_l[0];
    
    assign q_h_l_prod[3] = (q_h[3] & q_l[3]) ^ (a32 & b32) ^ (q_h[2] & q_l[2]) ^ (q_h[1] & q_l[1]) ^ (a10 & b10);
    assign q_h_l_prod[2] = (a32 & b32) ^ (q_h[2] & q_l[2]) ^ (q_h[0] & q_l[0]);
    assign q_h_l_prod[1] = (q_h[3] & q_l[3]) ^ (q_h[2] & q_l[2]) ^ (q_h[1] & q_l[1]) ^ (q_h[0] & q_l[0]) ^ (a10 & b10);
    assign q_h_l_prod[0] = (q_h[2] & q_l[2]) ^ (q_h[0] & q_l[0]) ^ (a10 & b10);

    // 4. Combine terms to form the input to the 4-bit inverter core
    // inv_core_in = q_l^2 + (q_h * q_l) + (q_h^2 * Lambda)
    wire [3:0] q_l_sq;
    assign q_l_sq[3] = q_l[3];
    assign q_l_sq[2] = q_l[3] ^ q_l[2];
    assign q_l_sq[1] = q_l[2] ^ q_l[1];
    assign q_l_sq[0] = q_l[2] ^ q_l[1] ^ q_l[0];

    assign inv_core_in = q_l_sq ^ q_h_l_prod ^ q_l_sq_scl;

    // 5. Explicit 4-Bit Inverter Core Matrix
    assign inv_core_out[3] = inv_core_in[3] ^ (inv_core_in[3] & inv_core_in[2] & inv_core_in[1]) ^ (inv_core_in[3] & inv_core_in[0]) ^ (inv_core_in[2]);
    assign inv_core_out[2] = (inv_core_in[3] & inv_core_in[2] & inv_core_in[1]) ^ (inv_core_in[3] & inv_core_in[2] & inv_core_in[0]) ^ (inv_core_in[3] & inv_core_in[0]) ^ (inv_core_in[2]) ^ (inv_core_in[2] & inv_core_in[1]);
    assign inv_core_out[1] = inv_core_in[3] ^ (inv_core_in[3] & inv_core_in[2] & inv_core_in[0]) ^ (inv_core_in[2]) ^ (inv_core_in[1]) ^ (inv_core_in[1] & inv_core_in[0]);
    assign inv_core_out[0] = (inv_core_in[3] & inv_core_in[2] & inv_core_in[1]) ^ (inv_core_in[3] & inv_core_in[1] & inv_core_in[0]) ^ (inv_core_in[2]) ^ (inv_core_in[2] & inv_core_in[0]) ^ (inv_core_in[1]) ^ (inv_core_in[0]);

    // 6. Cross-multiply out back to high/low nibble formats
    // p_h = q_h * inv_core_out
    // p_l = (q_h + q_l) * inv_core_out
    wire [3:0] q_sum = q_h ^ q_l;
    
    // Multiplier for p_h
    wire ah32 = q_h[3] ^ q_h[2]; wire ah10 = q_h[1] ^ q_h[0];
    wire inv32 = inv_core_out[3] ^ inv_core_out[2]; wire inv10 = inv_core_out[1] ^ inv_core_out[0];
    assign p_h[3] = (q_h[3] & inv_core_out[3]) ^ (ah32 & inv32) ^ (q_h[2] & inv_core_out[2]) ^ (q_h[1] & inv_core_out[1]) ^ (ah10 & inv10);
    assign p_h[2] = (ah32 & inv32) ^ (q_h[2] & inv_core_out[2]) ^ (q_h[0] & inv_core_out[0]);
    assign p_h[1] = (q_h[3] & inv_core_out[3]) ^ (q_h[2] & inv_core_out[2]) ^ (q_h[1] & inv_core_out[1]) ^ (q_h[0] & inv_core_out[0]) ^ (ah10 & inv10);
    assign p_h[0] = (q_h[2] & inv_core_out[2]) ^ (q_h[0] & inv_core_out[0]) ^ (ah10 & inv10);

    // Multiplier for p_l
    wire as32 = q_sum[3] ^ q_sum[2]; wire as10 = q_sum[1] ^ q_sum[0];
    assign p_l[3] = (q_sum[3] & inv_core_out[3]) ^ (as32 & inv32) ^ (q_sum[2] & inv_core_out[2]) ^ (q_sum[1] & inv_core_out[1]) ^ (as10 & inv10);
    assign p_l[2] = (as32 & inv32) ^ (q_sum[2] & inv_core_out[2]) ^ (q_sum[0] & inv_core_out[0]);
    assign p_l[1] = (q_sum[3] & inv_core_out[3]) ^ (q_sum[2] & inv_core_out[2]) ^ (q_sum[1] & inv_core_out[1]) ^ (q_sum[0] & inv_core_out[0]) ^ (as10 & inv10);
    assign p_l[0] = (q_sum[2] & inv_core_out[2]) ^ (q_sum[0] & inv_core_out[0]) ^ (as10 & inv10);

    // Recombine nibbles to byte before final transform
    assign inv_byte = {p_h, p_l};

    // --------------------------------------------------------------------------
    // STAGE 3: Inverse Isomorphic Mapping & AES Affine Transformation
    // Combines inverse matrix with standard AES additive constant (0x63)
    // --------------------------------------------------------------------------
    assign sbox_out[7] = inv_byte[7] ^ inv_byte[6] ^ inv_byte[5] ^ inv_byte[1];
    assign sbox_out[6] = inv_byte[6] ^ inv_byte[2] ^ inv_byte[1] ^ inv_byte[0];
    assign sbox_out[5] = inv_byte[6] ^ inv_byte[5] ^ inv_byte[1] ^ inv_byte[0];
    assign sbox_out[4] = inv_byte[6] ^ inv_byte[5] ^ inv_byte[4] ^ inv_byte[2] ^ inv_byte[1] ^ inv_byte[0];
    assign sbox_out[3] = inv_byte[5] ^ inv_byte[4] ^ inv_byte[3] ^ inv_byte[2] ^ inv_byte[1] ^ inv_byte[0];
    assign sbox_out[2] = inv_byte[7] ^ inv_byte[4] ^ inv_byte[3] ^ inv_byte[2] ^ inv_byte[1];
    assign sbox_out[1] = inv_byte[4] ^ inv_byte[3] ^ inv_byte[0];
    assign sbox_out[0] = inv_byte[7] ^ inv_byte[6] ^ inv_byte[5] ^ inv_byte[4] ^ inv_byte[0];

endmodule
