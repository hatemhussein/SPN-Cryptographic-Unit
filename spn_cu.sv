`ifndef __SPN_CU_SV__
`define __SPN_CU_SV__

module spn_cu (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  opcode,       // 00: NOP, 01: Encrypt, 10: Decrypt
    input  logic [15:0] data_in,
    input  logic [31:0] secret_key,
    output logic [15:0] out_data,
    output logic [1:0]  valid  // 00: no output, 01: encrypt OK, 10: decrypt OK, 11: error
);

 
      logic [15:0] round_key [0:2];

    always_comb begin
        round_key[0] = {secret_key[7:0],  secret_key[23:16]}; // R0
        round_key[1] = secret_key[15:0];                      // R1
        round_key[2] = {secret_key[7:0],  secret_key[31:24]}; // R2
    end

      function automatic logic [3:0] sbox(input logic [3:0] in);
        case (in)
            4'h0: sbox = 4'hA;  4'h1: sbox = 4'h5;  4'h2: sbox = 4'h8;  4'h3: sbox = 4'h2;
            4'h4: sbox = 4'h6;  4'h5: sbox = 4'hC;  4'h6: sbox = 4'h4;  4'h7: sbox = 4'h3;
            4'h8: sbox = 4'h1;  4'h9: sbox = 4'h0;  4'hA: sbox = 4'hB;  4'hB: sbox = 4'h9;
            4'hC: sbox = 4'hF;  4'hD: sbox = 4'hD;  4'hE: sbox = 4'h7;  4'hF: sbox = 4'hE;
        endcase
    endfunction

      function automatic logic [3:0] inv_sbox(input logic [3:0] in);
        case (in)
            4'hA: inv_sbox = 4'h0;  4'h5: inv_sbox = 4'h1;  4'h8: inv_sbox = 4'h2;  4'h2: inv_sbox = 4'h3;
            4'h6: inv_sbox = 4'h4;  4'hC: inv_sbox = 4'h5;  4'h4: inv_sbox = 4'h6;  4'h3: inv_sbox = 4'h7;
            4'h1: inv_sbox = 4'h8;  4'h0: inv_sbox = 4'h9;  4'hB: inv_sbox = 4'hA;  4'h9: inv_sbox = 4'hB;
            4'hF: inv_sbox = 4'hC;  4'hD: inv_sbox = 4'hD;  4'h7: inv_sbox = 4'hE;  4'hE: inv_sbox = 4'hF;
        endcase
    endfunction

      function automatic logic [15:0] rotate_left_2B(input logic [15:0] data);
        return {data[7:0], data[15:8]};
    endfunction

    function automatic logic [15:0] rotate_right_2B(input logic [15:0] data);
        return {data[7:0], data[15:8]}; // same for 2-byte rotation
    endfunction

      function automatic logic [15:0] apply_sbox(input logic [15:0] data, input bit inverse);
        logic [15:0] out;
        out[15:12] = inverse ? inv_sbox(data[15:12]) : sbox(data[15:12]);
        out[11:8]  = inverse ? inv_sbox(data[11:8])  : sbox(data[11:8]);
        out[7:4]   = inverse ? inv_sbox(data[7:4])   : sbox(data[7:4]);
        out[3:0]   = inverse ? inv_sbox(data[3:0])   : sbox(data[3:0]);
        return out;
    endfunction

      always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_data <= 16'd0;
            valid    <= 2'b00;
        end else begin
            case (opcode)
                2'b01: begin // ENCRYPT
                    logic [15:0] temp;
                    temp = data_in ^ round_key[0];
                    temp = apply_sbox(temp, 0);
                    temp = rotate_left_2B(temp);

                    temp = temp ^ round_key[1];
                    temp = apply_sbox(temp, 0);
                    temp = rotate_left_2B(temp);

                    temp = temp ^ round_key[2];
                    temp = apply_sbox(temp, 0); // NO rotate

                    out_data <= temp;
                    valid    <= 2'b01;
                end

                2'b10: begin // DECRYPT
                    logic [15:0] temp;
                    temp = apply_sbox(data_in, 1);
                    temp = temp ^ round_key[2];
                    temp = rotate_right_2B(temp);

                    temp = apply_sbox(temp, 1);
                    temp = temp ^ round_key[1];
                    temp = rotate_right_2B(temp);

                    temp = apply_sbox(temp, 1);
                    temp = temp ^ round_key[0];

                    out_data <= temp;
                    valid    <= 2'b10;
                end

                2'b00: begin
                    out_data <= 16'd0;
                    valid    <= 2'b00;
                end

                default: begin
                    out_data <= 16'd0;
                    valid    <= 2'b11; // error
                end
            endcase
        end
    end
endmodule

  

`endif // __SPN_CU_SV__
