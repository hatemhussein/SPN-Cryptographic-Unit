`ifndef __ENC_DEC_REF_MODEL_SV__
`define __ENC_DEC_REF_MODEL_SV__

module enc_dec_ref_model (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  opcode,        // 00: NOP, 01: Encrypt, 10: Decrypt
    input  logic [15:0] in_data,
    input  logic [31:0] secret_key,

    output logic [15:0] out_data,
    output logic [1:0]  valid
);

  // Round key storage
  logic [15:0] round_key [0:2];
  logic [15:0] temp;

  // ---------- S-box ----------
  function automatic logic [3:0] sbox(input logic [3:0] in);
    case (in)
      4'h0: sbox = 4'hA;  4'h1: sbox = 4'h5;  4'h2: sbox = 4'h8;  4'h3: sbox = 4'h2;
      4'h4: sbox = 4'h6;  4'h5: sbox = 4'hC;  4'h6: sbox = 4'h4;  4'h7: sbox = 4'h3;
      4'h8: sbox = 4'h1;  4'h9: sbox = 4'h0;  4'hA: sbox = 4'hB;  4'hB: sbox = 4'h9;
      4'hC: sbox = 4'hF;  4'hD: sbox = 4'hD;  4'hE: sbox = 4'h7;  4'hF: sbox = 4'hE;
    endcase
  endfunction

  // ---------- Inverse S-box ----------
  function automatic logic [3:0] inv_sbox(input logic [3:0] in);
    case (in)
      4'hA: inv_sbox = 4'h0;  4'h5: inv_sbox = 4'h1;  4'h8: inv_sbox = 4'h2;  4'h2: inv_sbox = 4'h3;
      4'h6: inv_sbox = 4'h4;  4'hC: inv_sbox = 4'h5;  4'h4: inv_sbox = 4'h6;  4'h3: inv_sbox = 4'h7;
      4'h1: inv_sbox = 4'h8;  4'h0: inv_sbox = 4'h9;  4'hB: inv_sbox = 4'hA;  4'h9: inv_sbox = 4'hB;
      4'hF: inv_sbox = 4'hC;  4'hD: inv_sbox = 4'hD;  4'h7: inv_sbox = 4'hE;  4'hE: inv_sbox = 4'hF;
    endcase
  endfunction

  // ---------- Rotate ----------
  function automatic logic [15:0] rotate_left(input logic [15:0] d);
    return {d[7:0], d[15:8]};
  endfunction

  function automatic logic [15:0] rotate_right(input logic [15:0] d);
    return {d[7:0], d[15:8]};
  endfunction

  // ---------- Apply S-box ----------
  function automatic logic [15:0] apply_sbox(input logic [15:0] d, input bit inverse);
    logic [15:0] o;
    o[15:12] = inverse ? inv_sbox(d[15:12]) : sbox(d[15:12]);
    o[11:8]  = inverse ? inv_sbox(d[11:8])  : sbox(d[11:8]);
    o[7:4]   = inverse ? inv_sbox(d[7:4])   : sbox(d[7:4]);
    o[3:0]   = inverse ? inv_sbox(d[3:0])   : sbox(d[3:0]);
    return o;
  endfunction

  // ---------- Sequential Behavior ----------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      out_data <= 16'd0;
      valid    <= 2'b00;
    end else begin
      // Generate round keys every cycle (for simplicity)
      round_key[0] = {secret_key[7:0],  secret_key[23:16]};
      round_key[1] = secret_key[15:0];
      round_key[2] = {secret_key[7:0],  secret_key[31:24]};

      case (opcode)
        2'b00: begin // NOP
          out_data <= 16'd0;
          valid    <= 2'b00;
        end

        2'b01: begin // ENCRYPT
          temp = in_data ^ round_key[0];
          temp = apply_sbox(temp, 0);
          temp = rotate_left(temp);

          temp = temp ^ round_key[1];
          temp = apply_sbox(temp, 0);
          temp = rotate_left(temp);

          temp = temp ^ round_key[2];
          temp = apply_sbox(temp, 0); // No rotation in last round

          out_data <= temp;
          valid    <= 2'b01;
        end

        2'b10: begin // DECRYPT
          temp = apply_sbox(in_data, 1);
          temp = temp ^ round_key[2];
          temp = rotate_right(temp);

          temp = apply_sbox(temp, 1);
          temp = temp ^ round_key[1];
          temp = rotate_right(temp);

          temp = apply_sbox(temp, 1);
          temp = temp ^ round_key[0];

          out_data <= temp;
          valid    <= 2'b10;
        end

        default: begin // INVALID
          out_data <= 16'd0;
          valid    <= 2'b11;
        end
      endcase
    end
  end

endmodule


`endif // __ENC_DEC_REF_MODEL_SV__
