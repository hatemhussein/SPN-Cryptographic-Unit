`ifndef __TESTBENCH_SV__
`define __TESTBENCH_SV__

import uvm_pkg::*;
`include "uvm_macros.svh"

// DUT and reference model interface and modules
`include "enc_dec_if.sv"
`include "enc_dec_ref_model_if.sv"
`include "spn_cu.sv"
`include "enc_dec_ref_model.sv"

// UVM Environment and Tests
`include "enc_dec_env.sv"
`include "enc_dec_seq_item.sv"
`include "enc_dec_seq.sv"
`include "enc_dec_main_test.sv"
//`include "enc_dec_test.sv"
//`include "noop_test.sv"
 `include "random_test.sv"

module tb_top();

  // Clock and reset
  logic clk;
  logic reset;

  // Instantiate interfaces
  enc_dec_if dut_if_inst (clk, reset);
  enc_dec_ref_model_if ref_if_inst (clk, reset);

  // Virtual interfaces
  virtual enc_dec_if dut_if;
  virtual enc_dec_ref_model_if ref_if;

  // DUT instantiation
  spn_cu dut (
    .clk(clk),
    .reset(reset),
    .opcode(dut_if_inst.command),
    .data_in(dut_if_inst.data_in),
    .secret_key(dut_if_inst.secret_key),
    .out_data(dut_if_inst.out_data),
    .valid(dut_if_inst.valid)
  );

  // Reference model instantiation
  enc_dec_ref_model ref_model (
    .clk(clk),
    .reset(reset),
    .opcode(ref_if_inst.command),
    .in_data(ref_if_inst.data_in),
    .secret_key(ref_if_inst.secret_key),
    .out_data(ref_if_inst.out_data),
    .valid(ref_if_inst.valid)
  );

  // Assign virtual interfaces to UVM config DB
  initial begin
    dut_if = dut_if_inst;
    ref_if = ref_if_inst;

    uvm_config_db#(virtual enc_dec_if)::set(uvm_root::get(), "*", "dut_if", dut_if);
    uvm_config_db#(virtual enc_dec_ref_model_if)::set(uvm_root::get(), "*", "ref_if", ref_if);

    // Optional: fine-grained interface configuration
    uvm_config_db#(virtual enc_dec_if)::set(null, "test_env.agt.mon", "dut_if", dut_if);
    uvm_config_db#(virtual enc_dec_ref_model_if)::set(null, "test_env.agt.mon", "ref_if", ref_if);
    uvm_config_db#(virtual enc_dec_if)::set(null, "test_env.cov_collector", "dut_if", dut_if);
  end

  // Clock generation: 100 MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset logic
  initial begin
    reset = 1;
    #20 reset = 0;
  end

  // VCD dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  // Start UVM test
  initial begin
    run_test("random_test"); // Change to "no_op_test" or "random_tests" as needed
  end

endmodule


`endif // __TESTBENCH_SV__
