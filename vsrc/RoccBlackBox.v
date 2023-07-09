// See LICENSE.SiFive for license details.

module RoccBlackBox
  #( parameter xLen = 64,
     PRV_SZ = 2,
     coreMaxAddrBits = 40,
     dcacheReqTagBits = 9,
     M_SZ = 5,
     mem_req_bits_size_width = 2,
     coreDataBits = 64,
     coreDataBytes = 8,
     paddrBits = 32,
     vaddrBitsExtended = 40,
     FPConstants_RM_SZ = 3,
     fLen = 64,
     FPConstants_FLAGS_SZ  = 5)
  ( input clock,
    input reset,
    output rocc_cmd_ready,
    input rocc_cmd_valid,
    input [6:0] rocc_cmd_bits_inst_funct,
    input [4:0] rocc_cmd_bits_inst_rs2,
    input [4:0] rocc_cmd_bits_inst_rs1,
    input rocc_cmd_bits_inst_xd,
    input rocc_cmd_bits_inst_xs1,
    input rocc_cmd_bits_inst_xs2,
    input [4:0] rocc_cmd_bits_inst_rd,
    input [6:0] rocc_cmd_bits_inst_opcode,
    input [xLen-1:0] rocc_cmd_bits_rs1,
    input [xLen-1:0] rocc_cmd_bits_rs2,
    input rocc_cmd_bits_status_debug,
    input rocc_cmd_bits_status_cease,
    input rocc_cmd_bits_status_wfi,
    input [31:0] rocc_cmd_bits_status_isa,
    input [PRV_SZ-1:0] rocc_cmd_bits_status_dprv,
    input rocc_cmd_bits_status_dv,
    input [PRV_SZ-1:0] rocc_cmd_bits_status_prv,
    input rocc_cmd_bits_status_v,
    input rocc_cmd_bits_status_sd,
    input [22:0] rocc_cmd_bits_status_zero2,
    input rocc_cmd_bits_status_mpv,
    input rocc_cmd_bits_status_gva,
    input rocc_cmd_bits_status_mbe,
    input rocc_cmd_bits_status_sbe,
    input [1:0] rocc_cmd_bits_status_sxl,
    input [1:0] rocc_cmd_bits_status_uxl,
    input rocc_cmd_bits_status_sd_rv32,
    input [7:0] rocc_cmd_bits_status_zero1,
    input rocc_cmd_bits_status_tsr,
    input rocc_cmd_bits_status_tw,
    input rocc_cmd_bits_status_tvm,
    input rocc_cmd_bits_status_mxr,
    input rocc_cmd_bits_status_sum,
    input rocc_cmd_bits_status_mprv,
    input [1:0] rocc_cmd_bits_status_xs,
    input [1:0] rocc_cmd_bits_status_fs,
    input [1:0] rocc_cmd_bits_status_vs,
    input [1:0] rocc_cmd_bits_status_mpp,
    input [0:0] rocc_cmd_bits_status_spp,
    input rocc_cmd_bits_status_mpie,
    input rocc_cmd_bits_status_ube,
    input rocc_cmd_bits_status_spie,
    input rocc_cmd_bits_status_upie,
    input rocc_cmd_bits_status_mie,
    input rocc_cmd_bits_status_hie,
    input rocc_cmd_bits_status_sie,
    input rocc_cmd_bits_status_uie,
    input rocc_resp_ready,
    output rocc_resp_valid,
    output [4:0] rocc_resp_bits_rd,
    output [xLen-1:0] rocc_resp_bits_data,
    input rocc_mem_req_ready,
    output rocc_mem_req_valid,
    output [coreMaxAddrBits-1:0] rocc_mem_req_bits_addr,
    output [dcacheReqTagBits-1:0] rocc_mem_req_bits_tag,
    output [M_SZ-1:0] rocc_mem_req_bits_cmd,
    output [mem_req_bits_size_width-1:0] rocc_mem_req_bits_size,
    output rocc_mem_req_bits_signed,
    output rocc_mem_req_bits_phys,
    output rocc_mem_req_bits_no_alloc,
    output rocc_mem_req_bits_no_xcpt,
    output [1:0] rocc_mem_req_bits_dprv,
    output rocc_mem_req_bits_dv,
    output [coreDataBits-1:0] rocc_mem_req_bits_data,
    output [coreDataBytes-1:0] rocc_mem_req_bits_mask,
    output rocc_mem_s1_kill,
    output [coreDataBits-1:0] rocc_mem_s1_data_data,
    output [coreDataBytes-1:0] rocc_mem_s1_data_mask,
    input rocc_mem_s2_nack,
    input rocc_mem_s2_nack_cause_raw,
    output rocc_mem_s2_kill,
    input rocc_mem_s2_uncached,
    input [paddrBits-1:0] rocc_mem_s2_paddr,
    input [vaddrBitsExtended-1:0] rocc_mem_s2_gpa,
    input rocc_mem_s2_gpa_is_pte,
    input rocc_mem_resp_valid,
    input [coreMaxAddrBits-1:0] rocc_mem_resp_bits_addr,
    input [dcacheReqTagBits-1:0] rocc_mem_resp_bits_tag,
    input [M_SZ-1:0] rocc_mem_resp_bits_cmd,
    input [mem_req_bits_size_width-1:0] rocc_mem_resp_bits_size,
    input rocc_mem_resp_bits_signed,
    input [coreDataBits-1:0] rocc_mem_resp_bits_data,
    input [coreDataBytes-1:0] rocc_mem_resp_bits_mask,
    input rocc_mem_resp_bits_replay,
    input rocc_mem_resp_bits_has_data,
    input [coreDataBits-1:0] rocc_mem_resp_bits_data_word_bypass,
    input [coreDataBits-1:0] rocc_mem_resp_bits_data_raw,
    input [coreDataBits-1:0] rocc_mem_resp_bits_store_data,
    input [1:0] rocc_mem_resp_bits_dprv,
    input rocc_mem_resp_bits_dv,
    input rocc_mem_replay_next,
    input rocc_mem_s2_xcpt_ma_ld,
    input rocc_mem_s2_xcpt_ma_st,
    input rocc_mem_s2_xcpt_pf_ld,
    input rocc_mem_s2_xcpt_pf_st,
    input rocc_mem_s2_xcpt_gf_ld,
    input rocc_mem_s2_xcpt_gf_st,
    input rocc_mem_s2_xcpt_ae_ld,
    input rocc_mem_s2_xcpt_ae_st,
    input rocc_mem_ordered,
    input rocc_mem_perf_acquire,
    input rocc_mem_perf_release,
    input rocc_mem_perf_grant,
    input rocc_mem_perf_tlbMiss,
    input rocc_mem_perf_blocked,
    input rocc_mem_perf_canAcceptStoreThenLoad,
    input rocc_mem_perf_canAcceptStoreThenRMW,
    input rocc_mem_perf_canAcceptLoadThenLoad,
    input rocc_mem_perf_storeBufferEmptyAfterLoad,
    input rocc_mem_perf_storeBufferEmptyAfterStore,
    output rocc_mem_keep_clock_enabled,
    input rocc_mem_clock_enabled,
    output rocc_busy,
    output rocc_interrupt,
    input rocc_exception,
    input rocc_fpu_req_ready,
    output rocc_fpu_req_valid,
    output rocc_fpu_req_bits_ldst,
    output rocc_fpu_req_bits_wen,
    output rocc_fpu_req_bits_ren1,
    output rocc_fpu_req_bits_ren2,
    output rocc_fpu_req_bits_ren3,
    output rocc_fpu_req_bits_swap12,
    output rocc_fpu_req_bits_swap23,
    output [1:0] rocc_fpu_req_bits_typeTagIn,
    output [1:0] rocc_fpu_req_bits_typeTagOut,
    output rocc_fpu_req_bits_fromint,
    output rocc_fpu_req_bits_toint,
    output rocc_fpu_req_bits_fastpipe,
    output rocc_fpu_req_bits_fma,
    output rocc_fpu_req_bits_div,
    output rocc_fpu_req_bits_sqrt,
    output rocc_fpu_req_bits_wflags,
    output [FPConstants_RM_SZ-1:0] rocc_fpu_req_bits_rm,
    output [1:0] rocc_fpu_req_bits_fmaCmd,
    output [1:0] rocc_fpu_req_bits_typ,
    output [1:0] rocc_fpu_req_bits_fmt,
    output [fLen:0] rocc_fpu_req_bits_in1,
    output [fLen:0] rocc_fpu_req_bits_in2,
    output [fLen:0] rocc_fpu_req_bits_in3,
    output rocc_fpu_resp_ready,
    input rocc_fpu_resp_valid,
    input [fLen:0] rocc_fpu_resp_bits_data,
    input [FPConstants_FLAGS_SZ-1:0] rocc_fpu_resp_bits_exc );

  assign rocc_cmd_ready = 1'b1;

  assign rocc_mem_req_valid = 1'b0;
  assign rocc_mem_s1_kill = 1'b0;
  assign rocc_mem_s2_kill = 1'b0;

  assign rocc_busy = 1'b0;
  assign rocc_interrupt = 1'b0;

  assign rocc_fpu_req_valid = 1'b0;
  assign rocc_fpu_resp_ready = 1'b1;

  /* Accumulate rs1 and rs2 into an accumulator */
  reg doResp;
  reg [4:0] rocc_cmd_bits_inst_rd_r;
  reg [xLEN-1:0] seq1_addr;
  reg [xLEN-1:0] seq2_addr;

  always @ (posedge clock) begin
    if (reset) begin
      doResp <= 1'b0;
      rocc_cmd_bits_inst_rd_d <= 5'b0;
      state <= IDLE:
    end
    else
    begin
      doResp                  <= rocc_cmd_bits_inst_xd;
      rocc_cmd_bits_inst_rd_d <= rocc_cmd_bits_inst_rd;
      state <= state_n:
      if (state == IDLE)
        seq1_addr 
    end
    else begin
      doResp <= 1'b0;
    end
  end

  always_comb
  begin
    case (state)
      IDLE :
        if (rocc_cmd_valid && rocc_cmd_ready):
           state_n = CMD_INIT;
      CMD_SEQ1_ADDR
  end

  assign rocc_resp_valid = doResp;
  assign rocc_resp_bits_rd = rocc_cmd_bits_inst_rd_d;
  assign rocc_resp_bits_data = acc;

  typedef enum logic [3:0] {IDLE, WAIT, CMD_SEQ1_ADDR, CMD_SEQ1_LEN, CMD_SEQ2_ADDR, CMD_SEQ2_LEN, CALCULATE} state_t;

  state_t state, state_n, state_p;


  input         clock,
  input         reset,
  input         io_start,
  input  [15:0] io_str1,
  input  [15:0] io_str1_len,
  input  [15:0] io_str2,
  input  [15:0] io_str2_len,
  output [3:0]  io_result,
  output        io_result_ready


  Toplevel edit_distance_calculator
              (.clock(clock)
              ,.reset(reset)
              ,.io_start()
              ,.io_str1()
              ,.io_str1_len()
              ,.io_str2()
              ,.io_str2_len()
              ,.io_result()
              ,.io_result_ready()
              );

endmodule

module SRAM2P(
  input         clock,
  input  [4:0]  io_addr1,
  input  [4:0]  io_addr2,
  input  [15:0] io_dataIn1,
  input  [15:0] io_dataIn2,
  output [15:0] io_dataOut1,
  output [15:0] io_dataOut2,
  input         io_writeEnable1,
  input         io_writeEnable2
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [15:0] mem [0:19]; // @[Toplevel.scala 290:24]
  wire  mem_io_dataOut1_MPORT_en; // @[Toplevel.scala 290:{24,24} 300:{26,26}]
  reg [4:0] mem_io_dataOut1_MPORT_addr; // @[Toplevel.scala 290:24]
  wire [15:0] mem_io_dataOut1_MPORT_data; // @[Toplevel.scala 290:24]
  wire  mem_io_dataOut2_MPORT_en; // @[Toplevel.scala 290:{24,24} 300:{26,26}]
  reg [4:0] mem_io_dataOut2_MPORT_addr; // @[Toplevel.scala 290:24]
  wire [15:0] mem_io_dataOut2_MPORT_data; // @[Toplevel.scala 290:24]
  wire [15:0] mem_MPORT_data; // @[Toplevel.scala 290:24 292:26]
  wire [4:0] mem_MPORT_addr; // @[Toplevel.scala 290:24 292:26]
  wire  mem_MPORT_mask; // @[Toplevel.scala 290:24 292:26]
  wire  mem_MPORT_en; // @[Toplevel.scala 290:{24,24} 292:26]
  wire [15:0] mem_MPORT_1_data; // @[Toplevel.scala 290:24 296:26]
  wire [4:0] mem_MPORT_1_addr; // @[Toplevel.scala 290:24 296:26]
  wire  mem_MPORT_1_mask; // @[Toplevel.scala 290:24 296:26]
  wire  mem_MPORT_1_en; // @[Toplevel.scala 290:{24,24} 296:26]
  assign mem_io_dataOut1_MPORT_en = 1'h1; // @[Toplevel.scala 290:24 300:{26,26}]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_io_dataOut1_MPORT_data = mem[mem_io_dataOut1_MPORT_addr]; // @[Toplevel.scala 290:24]
  `else
  assign mem_io_dataOut1_MPORT_data = mem_io_dataOut1_MPORT_addr >= 5'h14 ? _RAND_1[15:0] :
    mem[mem_io_dataOut1_MPORT_addr]; // @[Toplevel.scala 290:24]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_io_dataOut2_MPORT_en = 1'h1; // @[Toplevel.scala 290:24 300:{26,26}]
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_io_dataOut2_MPORT_data = mem[mem_io_dataOut2_MPORT_addr]; // @[Toplevel.scala 290:24]
  `else
  assign mem_io_dataOut2_MPORT_data = mem_io_dataOut2_MPORT_addr >= 5'h14 ? _RAND_3[15:0] :
    mem[mem_io_dataOut2_MPORT_addr]; // @[Toplevel.scala 290:24]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_MPORT_data = io_dataIn1; // @[Toplevel.scala 292:26]
  assign mem_MPORT_addr = io_addr1; // @[Toplevel.scala 292:26]
  assign mem_MPORT_mask = 1'h1; // @[Toplevel.scala 292:26]
  assign mem_MPORT_en = io_writeEnable1; // @[Toplevel.scala 290:24 292:26]
  assign mem_MPORT_1_data = io_dataIn2; // @[Toplevel.scala 296:26]
  assign mem_MPORT_1_addr = io_addr2; // @[Toplevel.scala 296:26]
  assign mem_MPORT_1_mask = 1'h1; // @[Toplevel.scala 296:26]
  assign mem_MPORT_1_en = io_writeEnable2; // @[Toplevel.scala 290:24 296:26]
  assign io_dataOut1 = mem_io_dataOut1_MPORT_data; // @[Toplevel.scala 300:15]
  assign io_dataOut2 = mem_io_dataOut2_MPORT_data; // @[Toplevel.scala 301:15]
  always @(posedge clock) begin
    if (mem_io_dataOut1_MPORT_en) begin
      mem_io_dataOut1_MPORT_addr <= io_addr1; // @[Toplevel.scala 300:26]
    end
    if (mem_io_dataOut2_MPORT_en) begin
      mem_io_dataOut2_MPORT_addr <= io_addr2; // @[Toplevel.scala 301:26]
    end
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[Toplevel.scala 290:24]
    end
    if (mem_MPORT_1_en & mem_MPORT_1_mask) begin
      mem[mem_MPORT_1_addr] <= mem_MPORT_1_data; // @[Toplevel.scala 290:24]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_1 = {1{`RANDOM}};
  _RAND_3 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  mem_io_dataOut1_MPORT_addr = _RAND_0[4:0];
  _RAND_2 = {1{`RANDOM}};
  mem_io_dataOut2_MPORT_addr = _RAND_2[4:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Comparator3(
  input  [15:0] io_in0,
  input  [15:0] io_in1,
  input  [15:0] io_in2,
  output [15:0] io_out
);
  wire [15:0] _GEN_0 = io_in1 < io_in0 & io_in1 < io_in2 ? io_in1 : io_in2; // @[Toplevel.scala 249:52 250:12 252:12]
  assign io_out = io_in0 < io_in1 & io_in0 < io_in2 ? io_in0 : _GEN_0; // @[Toplevel.scala 247:45 248:12]
endmodule
module Toplevel(
  input         clock,
  input         reset,
  input         io_start,
  input  [15:0] io_str1,
  input  [15:0] io_str1_len,
  input  [15:0] io_str2,
  input  [15:0] io_str2_len,
  output [3:0]  io_result,
  output        io_result_ready
);
  wire  str_clock; // @[Toplevel.scala 54:19]
  wire [4:0] str_io_addr1; // @[Toplevel.scala 54:19]
  wire [4:0] str_io_addr2; // @[Toplevel.scala 54:19]
  wire [15:0] str_io_dataIn1; // @[Toplevel.scala 54:19]
  wire [15:0] str_io_dataIn2; // @[Toplevel.scala 54:19]
  wire [15:0] str_io_dataOut1; // @[Toplevel.scala 54:19]
  wire [15:0] str_io_dataOut2; // @[Toplevel.scala 54:19]
  wire  str_io_writeEnable1; // @[Toplevel.scala 54:19]
  wire  str_io_writeEnable2; // @[Toplevel.scala 54:19]
  wire [15:0] comp_io_in0; // @[Toplevel.scala 84:20]
  wire [15:0] comp_io_in1; // @[Toplevel.scala 84:20]
  wire [15:0] comp_io_in2; // @[Toplevel.scala 84:20]
  wire [15:0] comp_io_out; // @[Toplevel.scala 84:20]
  reg [3:0] state; // @[Toplevel.scala 34:22]
  reg [15:0] result_reg; // @[Toplevel.scala 37:27]
  reg  result_ready_reg; // @[Toplevel.scala 43:33]
  reg [3:0] m; // @[Toplevel.scala 49:18]
  reg [3:0] n; // @[Toplevel.scala 50:18]
  reg [15:0] dp_0; // @[Toplevel.scala 57:15]
  reg [15:0] dp_1; // @[Toplevel.scala 57:15]
  reg [15:0] dp_2; // @[Toplevel.scala 57:15]
  reg [15:0] dp_3; // @[Toplevel.scala 57:15]
  reg [15:0] dp_4; // @[Toplevel.scala 57:15]
  reg [15:0] dp_5; // @[Toplevel.scala 57:15]
  reg [15:0] dp_6; // @[Toplevel.scala 57:15]
  reg [15:0] dp_7; // @[Toplevel.scala 57:15]
  reg [15:0] dp_8; // @[Toplevel.scala 57:15]
  reg [15:0] dp_9; // @[Toplevel.scala 57:15]
  reg [15:0] i; // @[Toplevel.scala 60:18]
  reg [15:0] j; // @[Toplevel.scala 61:18]
  reg [15:0] prev; // @[Toplevel.scala 68:21]
  reg [15:0] temp; // @[Toplevel.scala 69:21]
  reg [15:0] addr1_reg; // @[Toplevel.scala 73:26]
  reg [15:0] addr2_reg; // @[Toplevel.scala 74:26]
  reg [15:0] str_i_reg; // @[Toplevel.scala 76:26]
  reg [15:0] str_j_reg; // @[Toplevel.scala 77:26]
  reg [15:0] str_i_minus_1_reg; // @[Toplevel.scala 80:34]
  reg [15:0] str_j_minus_1_reg; // @[Toplevel.scala 81:34]
  reg [15:0] comp_in0_reg; // @[Toplevel.scala 86:29]
  reg [15:0] comp_in1_reg; // @[Toplevel.scala 87:29]
  reg [15:0] comp_in2_reg; // @[Toplevel.scala 88:29]
  wire  _str_io_writeEnable1_T = state == 4'h1; // @[Toplevel.scala 92:33]
  wire [15:0] _GEN_182 = {{12'd0}, m}; // @[Toplevel.scala 92:59]
  wire  _str_io_writeEnable1_T_1 = addr1_reg < _GEN_182; // @[Toplevel.scala 92:59]
  wire [15:0] _GEN_183 = {{12'd0}, n}; // @[Toplevel.scala 93:59]
  wire  _str_io_writeEnable2_T_1 = addr2_reg < _GEN_183; // @[Toplevel.scala 93:59]
  wire [15:0] _str_io_addr2_T_1 = _GEN_182 + addr2_reg; // @[Toplevel.scala 95:21]
  wire [15:0] _GEN_0 = io_start ? io_str1_len : {{12'd0}, m}; // @[Toplevel.scala 128:23 130:13 49:18]
  wire [15:0] _GEN_1 = io_start ? io_str2_len : {{12'd0}, n}; // @[Toplevel.scala 128:23 131:13 50:18]
  wire [15:0] _GEN_2 = io_start ? io_str1 : 16'h0; // @[Toplevel.scala 122:17 128:23 133:21]
  wire [15:0] _GEN_3 = io_start ? io_str2 : 16'h0; // @[Toplevel.scala 123:17 128:23 134:21]
  wire [3:0] _GEN_4 = io_start ? 4'h1 : state; // @[Toplevel.scala 128:23 136:17 34:22]
  wire [15:0] _GEN_5 = state == 4'h0 ? 16'h0 : i; // @[Toplevel.scala 113:26 115:9 60:18]
  wire [15:0] _GEN_6 = state == 4'h0 ? 16'h0 : j; // @[Toplevel.scala 113:26 116:9 61:18]
  wire  _GEN_7 = state == 4'h0 ? 1'h0 : result_ready_reg; // @[Toplevel.scala 113:26 117:24 43:33]
  wire [15:0] _GEN_8 = state == 4'h0 ? 16'h0 : addr1_reg; // @[Toplevel.scala 113:26 119:17 73:26]
  wire [15:0] _GEN_9 = state == 4'h0 ? 16'h0 : addr2_reg; // @[Toplevel.scala 113:26 120:17 74:26]
  wire [15:0] _GEN_10 = state == 4'h0 ? _GEN_2 : str_i_reg; // @[Toplevel.scala 113:26 76:26]
  wire [15:0] _GEN_11 = state == 4'h0 ? _GEN_3 : str_j_reg; // @[Toplevel.scala 113:26 77:26]
  wire [15:0] _GEN_14 = state == 4'h0 ? _GEN_0 : {{12'd0}, m}; // @[Toplevel.scala 113:26 49:18]
  wire [15:0] _GEN_15 = state == 4'h0 ? _GEN_1 : {{12'd0}, n}; // @[Toplevel.scala 113:26 50:18]
  wire [3:0] _GEN_16 = state == 4'h0 ? _GEN_4 : state; // @[Toplevel.scala 113:26 34:22]
  wire [15:0] _addr1_reg_T_1 = addr1_reg + 16'h1; // @[Toplevel.scala 142:34]
  wire [15:0] _addr2_reg_T_1 = addr2_reg + 16'h1; // @[Toplevel.scala 147:34]
  wire [3:0] _GEN_21 = addr1_reg == _GEN_182 & addr2_reg == _GEN_183 ? 4'h2 : _GEN_16; // @[Toplevel.scala 151:49 152:17]
  wire [3:0] _GEN_26 = _str_io_writeEnable1_T ? _GEN_21 : _GEN_16; // @[Toplevel.scala 139:27]
  wire [15:0] _GEN_27 = 4'h0 == i[3:0] ? i : dp_0; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_28 = 4'h1 == i[3:0] ? i : dp_1; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_29 = 4'h2 == i[3:0] ? i : dp_2; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_30 = 4'h3 == i[3:0] ? i : dp_3; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_31 = 4'h4 == i[3:0] ? i : dp_4; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_32 = 4'h5 == i[3:0] ? i : dp_5; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_33 = 4'h6 == i[3:0] ? i : dp_6; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_34 = 4'h7 == i[3:0] ? i : dp_7; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_35 = 4'h8 == i[3:0] ? i : dp_8; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _GEN_36 = 4'h9 == i[3:0] ? i : dp_9; // @[Toplevel.scala 158:{17,17} 57:15]
  wire [15:0] _i_T_1 = i + 16'h1; // @[Toplevel.scala 159:18]
  wire [15:0] _GEN_37 = i <= _GEN_183 ? _GEN_27 : dp_0; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_38 = i <= _GEN_183 ? _GEN_28 : dp_1; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_39 = i <= _GEN_183 ? _GEN_29 : dp_2; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_40 = i <= _GEN_183 ? _GEN_30 : dp_3; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_41 = i <= _GEN_183 ? _GEN_31 : dp_4; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_42 = i <= _GEN_183 ? _GEN_32 : dp_5; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_43 = i <= _GEN_183 ? _GEN_33 : dp_6; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_44 = i <= _GEN_183 ? _GEN_34 : dp_7; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_45 = i <= _GEN_183 ? _GEN_35 : dp_8; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_46 = i <= _GEN_183 ? _GEN_36 : dp_9; // @[Toplevel.scala 157:21 57:15]
  wire [15:0] _GEN_47 = i <= _GEN_183 ? _i_T_1 : 16'h1; // @[Toplevel.scala 157:21 159:13 161:13]
  wire [15:0] _GEN_48 = i <= _GEN_183 ? _GEN_6 : 16'h1; // @[Toplevel.scala 157:21 162:13]
  wire [3:0] _GEN_49 = i <= _GEN_183 ? _GEN_26 : 4'h3; // @[Toplevel.scala 157:21 163:17]
  wire [15:0] _GEN_50 = state == 4'h2 ? _GEN_37 : dp_0; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_51 = state == 4'h2 ? _GEN_38 : dp_1; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_52 = state == 4'h2 ? _GEN_39 : dp_2; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_53 = state == 4'h2 ? _GEN_40 : dp_3; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_54 = state == 4'h2 ? _GEN_41 : dp_4; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_55 = state == 4'h2 ? _GEN_42 : dp_5; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_56 = state == 4'h2 ? _GEN_43 : dp_6; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_57 = state == 4'h2 ? _GEN_44 : dp_7; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_58 = state == 4'h2 ? _GEN_45 : dp_8; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_59 = state == 4'h2 ? _GEN_46 : dp_9; // @[Toplevel.scala 156:26 57:15]
  wire [15:0] _GEN_60 = state == 4'h2 ? _GEN_47 : _GEN_5; // @[Toplevel.scala 156:26]
  wire [15:0] _GEN_61 = state == 4'h2 ? _GEN_48 : _GEN_6; // @[Toplevel.scala 156:26]
  wire [3:0] _GEN_62 = state == 4'h2 ? _GEN_49 : _GEN_26; // @[Toplevel.scala 156:26]
  wire [15:0] _addr1_reg_T_3 = i - 16'h1; // @[Toplevel.scala 168:21]
  wire [3:0] _GEN_64 = state == 4'h3 ? 4'h4 : _GEN_62; // @[Toplevel.scala 167:26 169:13]
  wire [15:0] _GEN_66 = state == 4'h4 ? i : _GEN_50; // @[Toplevel.scala 172:31 174:13]
  wire [3:0] _GEN_68 = state == 4'h4 ? 4'h5 : _GEN_64; // @[Toplevel.scala 172:31 176:13]
  wire [15:0] _addr2_reg_T_3 = j - 16'h1; // @[Toplevel.scala 182:21]
  wire [3:0] _GEN_70 = state == 4'h5 ? 4'h6 : _GEN_68; // @[Toplevel.scala 179:31 183:13]
  wire [15:0] _GEN_72 = 4'h1 == j[3:0] ? dp_1 : dp_0; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_73 = 4'h2 == j[3:0] ? dp_2 : _GEN_72; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_74 = 4'h3 == j[3:0] ? dp_3 : _GEN_73; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_75 = 4'h4 == j[3:0] ? dp_4 : _GEN_74; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_76 = 4'h5 == j[3:0] ? dp_5 : _GEN_75; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_77 = 4'h6 == j[3:0] ? dp_6 : _GEN_76; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_78 = 4'h7 == j[3:0] ? dp_7 : _GEN_77; // @[Toplevel.scala 189:{12,12}]
  wire [15:0] _GEN_81 = 4'h0 == j[3:0] ? prev : _GEN_66; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_82 = 4'h1 == j[3:0] ? prev : _GEN_51; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_83 = 4'h2 == j[3:0] ? prev : _GEN_52; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_84 = 4'h3 == j[3:0] ? prev : _GEN_53; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_85 = 4'h4 == j[3:0] ? prev : _GEN_54; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_86 = 4'h5 == j[3:0] ? prev : _GEN_55; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_87 = 4'h6 == j[3:0] ? prev : _GEN_56; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_88 = 4'h7 == j[3:0] ? prev : _GEN_57; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_89 = 4'h8 == j[3:0] ? prev : _GEN_58; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_90 = 4'h9 == j[3:0] ? prev : _GEN_59; // @[Toplevel.scala 192:{17,17}]
  wire [15:0] _GEN_91 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_81 : _GEN_66; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_92 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_82 : _GEN_51; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_93 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_83 : _GEN_52; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_94 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_84 : _GEN_53; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_95 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_85 : _GEN_54; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_96 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_86 : _GEN_55; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_97 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_87 : _GEN_56; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_98 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_88 : _GEN_57; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_99 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_89 : _GEN_58; // @[Toplevel.scala 190:54]
  wire [15:0] _GEN_100 = str_i_minus_1_reg == str_j_minus_1_reg ? _GEN_90 : _GEN_59; // @[Toplevel.scala 190:54]
  wire [3:0] _GEN_101 = str_i_minus_1_reg == str_j_minus_1_reg ? 4'h8 : 4'h7; // @[Toplevel.scala 190:54 193:17 196:17]
  wire [15:0] _GEN_104 = state == 4'h6 ? _GEN_91 : _GEN_66; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_105 = state == 4'h6 ? _GEN_92 : _GEN_51; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_106 = state == 4'h6 ? _GEN_93 : _GEN_52; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_107 = state == 4'h6 ? _GEN_94 : _GEN_53; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_108 = state == 4'h6 ? _GEN_95 : _GEN_54; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_109 = state == 4'h6 ? _GEN_96 : _GEN_55; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_110 = state == 4'h6 ? _GEN_97 : _GEN_56; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_111 = state == 4'h6 ? _GEN_98 : _GEN_57; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_112 = state == 4'h6 ? _GEN_99 : _GEN_58; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_113 = state == 4'h6 ? _GEN_100 : _GEN_59; // @[Toplevel.scala 186:31]
  wire [3:0] _GEN_114 = state == 4'h6 ? _GEN_101 : _GEN_70; // @[Toplevel.scala 186:31]
  wire [15:0] _GEN_116 = 4'h1 == _addr2_reg_T_3[3:0] ? dp_1 : dp_0; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_117 = 4'h2 == _addr2_reg_T_3[3:0] ? dp_2 : _GEN_116; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_118 = 4'h3 == _addr2_reg_T_3[3:0] ? dp_3 : _GEN_117; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_119 = 4'h4 == _addr2_reg_T_3[3:0] ? dp_4 : _GEN_118; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_120 = 4'h5 == _addr2_reg_T_3[3:0] ? dp_5 : _GEN_119; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_121 = 4'h6 == _addr2_reg_T_3[3:0] ? dp_6 : _GEN_120; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _GEN_122 = 4'h7 == _addr2_reg_T_3[3:0] ? dp_7 : _GEN_121; // @[Toplevel.scala 203:{20,20}]
  wire [15:0] _dp_T_1 = comp_io_out + 16'h1; // @[Toplevel.scala 205:28]
  wire [15:0] _j_T_1 = j + 16'h1; // @[Toplevel.scala 213:18]
  wire [3:0] _GEN_161 = i <= _GEN_182 ? 4'h3 : 4'h9; // @[Toplevel.scala 216:26 219:21 221:21]
  wire [15:0] _GEN_170 = 4'h1 == n ? dp_1 : dp_0; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_171 = 4'h2 == n ? dp_2 : _GEN_170; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_172 = 4'h3 == n ? dp_3 : _GEN_171; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_173 = 4'h4 == n ? dp_4 : _GEN_172; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_174 = 4'h5 == n ? dp_5 : _GEN_173; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_175 = 4'h6 == n ? dp_6 : _GEN_174; // @[Toplevel.scala 228:{18,18}]
  wire [15:0] _GEN_176 = 4'h7 == n ? dp_7 : _GEN_175; // @[Toplevel.scala 228:{18,18}]
  wire  _GEN_180 = state == 4'h9 | _GEN_7; // @[Toplevel.scala 227:26 229:24]
  wire [15:0] _GEN_192 = reset ? 16'h0 : _GEN_14; // @[Toplevel.scala 49:{18,18}]
  wire [15:0] _GEN_193 = reset ? 16'h0 : _GEN_15; // @[Toplevel.scala 50:{18,18}]
  SRAM2P str ( // @[Toplevel.scala 54:19]
    .clock(str_clock),
    .io_addr1(str_io_addr1),
    .io_addr2(str_io_addr2),
    .io_dataIn1(str_io_dataIn1),
    .io_dataIn2(str_io_dataIn2),
    .io_dataOut1(str_io_dataOut1),
    .io_dataOut2(str_io_dataOut2),
    .io_writeEnable1(str_io_writeEnable1),
    .io_writeEnable2(str_io_writeEnable2)
  );
  Comparator3 comp ( // @[Toplevel.scala 84:20]
    .io_in0(comp_io_in0),
    .io_in1(comp_io_in1),
    .io_in2(comp_io_in2),
    .io_out(comp_io_out)
  );
  assign io_result = result_reg[3:0]; // @[Toplevel.scala 40:13]
  assign io_result_ready = result_ready_reg; // @[Toplevel.scala 45:19]
  assign str_clock = clock;
  assign str_io_addr1 = addr1_reg[4:0]; // @[Toplevel.scala 94:16]
  assign str_io_addr2 = _str_io_addr2_T_1[4:0]; // @[Toplevel.scala 95:16]
  assign str_io_dataIn1 = str_i_reg; // @[Toplevel.scala 96:18]
  assign str_io_dataIn2 = str_j_reg; // @[Toplevel.scala 97:18]
  assign str_io_writeEnable1 = state == 4'h1 & addr1_reg < _GEN_182; // @[Toplevel.scala 92:45]
  assign str_io_writeEnable2 = _str_io_writeEnable1_T & addr2_reg < _GEN_183; // @[Toplevel.scala 93:45]
  assign comp_io_in0 = comp_in0_reg; // @[Toplevel.scala 99:15]
  assign comp_io_in1 = comp_in1_reg; // @[Toplevel.scala 100:15]
  assign comp_io_in2 = comp_in2_reg; // @[Toplevel.scala 101:15]
  always @(posedge clock) begin
    if (reset) begin // @[Toplevel.scala 34:22]
      state <= 4'h0; // @[Toplevel.scala 34:22]
    end else if (state == 4'h9) begin // @[Toplevel.scala 227:26]
      state <= 4'h0; // @[Toplevel.scala 230:13]
    end else if (state == 4'h8) begin // @[Toplevel.scala 210:28]
      if (j <= _GEN_183) begin // @[Toplevel.scala 212:21]
        state <= 4'h5; // @[Toplevel.scala 214:17]
      end else begin
        state <= _GEN_161;
      end
    end else if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      state <= 4'h8; // @[Toplevel.scala 207:13]
    end else begin
      state <= _GEN_114;
    end
    if (reset) begin // @[Toplevel.scala 37:27]
      result_reg <= 16'h0; // @[Toplevel.scala 37:27]
    end else if (state == 4'h9) begin // @[Toplevel.scala 227:26]
      if (4'h9 == n) begin // @[Toplevel.scala 228:18]
        result_reg <= dp_9; // @[Toplevel.scala 228:18]
      end else if (4'h8 == n) begin // @[Toplevel.scala 228:18]
        result_reg <= dp_8; // @[Toplevel.scala 228:18]
      end else begin
        result_reg <= _GEN_176;
      end
    end
    if (reset) begin // @[Toplevel.scala 43:33]
      result_ready_reg <= 1'h0; // @[Toplevel.scala 43:33]
    end else begin
      result_ready_reg <= _GEN_180;
    end
    m <= _GEN_192[3:0]; // @[Toplevel.scala 49:{18,18}]
    n <= _GEN_193[3:0]; // @[Toplevel.scala 50:{18,18}]
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h0 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_0 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_0 <= _GEN_104;
      end
    end else begin
      dp_0 <= _GEN_104;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h1 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_1 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_1 <= _GEN_105;
      end
    end else begin
      dp_1 <= _GEN_105;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h2 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_2 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_2 <= _GEN_106;
      end
    end else begin
      dp_2 <= _GEN_106;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h3 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_3 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_3 <= _GEN_107;
      end
    end else begin
      dp_3 <= _GEN_107;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h4 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_4 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_4 <= _GEN_108;
      end
    end else begin
      dp_4 <= _GEN_108;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h5 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_5 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_5 <= _GEN_109;
      end
    end else begin
      dp_5 <= _GEN_109;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h6 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_6 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_6 <= _GEN_110;
      end
    end else begin
      dp_6 <= _GEN_110;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h7 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_7 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_7 <= _GEN_111;
      end
    end else begin
      dp_7 <= _GEN_111;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h8 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_8 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_8 <= _GEN_112;
      end
    end else begin
      dp_8 <= _GEN_112;
    end
    if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h9 == j[3:0]) begin // @[Toplevel.scala 205:13]
        dp_9 <= _dp_T_1; // @[Toplevel.scala 205:13]
      end else begin
        dp_9 <= _GEN_113;
      end
    end else begin
      dp_9 <= _GEN_113;
    end
    if (reset) begin // @[Toplevel.scala 60:18]
      i <= 16'h0; // @[Toplevel.scala 60:18]
    end else if (state == 4'h8) begin // @[Toplevel.scala 210:28]
      if (j <= _GEN_183) begin // @[Toplevel.scala 212:21]
        i <= _GEN_60;
      end else if (i <= _GEN_182) begin // @[Toplevel.scala 216:26]
        i <= _i_T_1; // @[Toplevel.scala 217:17]
      end else begin
        i <= _GEN_60;
      end
    end else begin
      i <= _GEN_60;
    end
    if (reset) begin // @[Toplevel.scala 61:18]
      j <= 16'h0; // @[Toplevel.scala 61:18]
    end else if (state == 4'h8) begin // @[Toplevel.scala 210:28]
      if (j <= _GEN_183) begin // @[Toplevel.scala 212:21]
        j <= _j_T_1; // @[Toplevel.scala 213:13]
      end else if (i <= _GEN_182) begin // @[Toplevel.scala 216:26]
        j <= 16'h1; // @[Toplevel.scala 218:17]
      end else begin
        j <= _GEN_61;
      end
    end else begin
      j <= _GEN_61;
    end
    if (reset) begin // @[Toplevel.scala 68:21]
      prev <= 16'h0; // @[Toplevel.scala 68:21]
    end else if (state == 4'h8) begin // @[Toplevel.scala 210:28]
      prev <= temp; // @[Toplevel.scala 211:12]
    end else if (state == 4'h4) begin // @[Toplevel.scala 172:31]
      prev <= dp_0; // @[Toplevel.scala 173:12]
    end
    if (reset) begin // @[Toplevel.scala 69:21]
      temp <= 16'h0; // @[Toplevel.scala 69:21]
    end else if (state == 4'h6) begin // @[Toplevel.scala 186:31]
      if (4'h9 == j[3:0]) begin // @[Toplevel.scala 189:12]
        temp <= dp_9; // @[Toplevel.scala 189:12]
      end else if (4'h8 == j[3:0]) begin // @[Toplevel.scala 189:12]
        temp <= dp_8; // @[Toplevel.scala 189:12]
      end else begin
        temp <= _GEN_78;
      end
    end
    if (reset) begin // @[Toplevel.scala 73:26]
      addr1_reg <= 16'h0; // @[Toplevel.scala 73:26]
    end else if (state == 4'h3) begin // @[Toplevel.scala 167:26]
      addr1_reg <= _addr1_reg_T_3; // @[Toplevel.scala 168:17]
    end else if (_str_io_writeEnable1_T) begin // @[Toplevel.scala 139:27]
      if (_str_io_writeEnable1_T_1) begin // @[Toplevel.scala 141:28]
        addr1_reg <= _addr1_reg_T_1; // @[Toplevel.scala 142:21]
      end else begin
        addr1_reg <= _GEN_8;
      end
    end else begin
      addr1_reg <= _GEN_8;
    end
    if (reset) begin // @[Toplevel.scala 74:26]
      addr2_reg <= 16'h0; // @[Toplevel.scala 74:26]
    end else if (state == 4'h5) begin // @[Toplevel.scala 179:31]
      addr2_reg <= _addr2_reg_T_3; // @[Toplevel.scala 182:17]
    end else if (_str_io_writeEnable1_T) begin // @[Toplevel.scala 139:27]
      if (_str_io_writeEnable2_T_1) begin // @[Toplevel.scala 146:28]
        addr2_reg <= _addr2_reg_T_1; // @[Toplevel.scala 147:21]
      end else begin
        addr2_reg <= _GEN_9;
      end
    end else begin
      addr2_reg <= _GEN_9;
    end
    if (reset) begin // @[Toplevel.scala 76:26]
      str_i_reg <= 16'h0; // @[Toplevel.scala 76:26]
    end else if (_str_io_writeEnable1_T) begin // @[Toplevel.scala 139:27]
      if (_str_io_writeEnable1_T_1) begin // @[Toplevel.scala 141:28]
        str_i_reg <= io_str1; // @[Toplevel.scala 143:21]
      end else begin
        str_i_reg <= _GEN_10;
      end
    end else begin
      str_i_reg <= _GEN_10;
    end
    if (reset) begin // @[Toplevel.scala 77:26]
      str_j_reg <= 16'h0; // @[Toplevel.scala 77:26]
    end else if (_str_io_writeEnable1_T) begin // @[Toplevel.scala 139:27]
      if (_str_io_writeEnable2_T_1) begin // @[Toplevel.scala 146:28]
        str_j_reg <= io_str2; // @[Toplevel.scala 148:21]
      end else begin
        str_j_reg <= _GEN_11;
      end
    end else begin
      str_j_reg <= _GEN_11;
    end
    if (reset) begin // @[Toplevel.scala 80:34]
      str_i_minus_1_reg <= 16'h0; // @[Toplevel.scala 80:34]
    end else if (state == 4'h4) begin // @[Toplevel.scala 172:31]
      str_i_minus_1_reg <= str_io_dataOut1; // @[Toplevel.scala 175:25]
    end else if (state == 4'h0) begin // @[Toplevel.scala 113:26]
      str_i_minus_1_reg <= 16'h0; // @[Toplevel.scala 125:25]
    end
    if (reset) begin // @[Toplevel.scala 81:34]
      str_j_minus_1_reg <= 16'h0; // @[Toplevel.scala 81:34]
    end else if (state == 4'h6) begin // @[Toplevel.scala 186:31]
      str_j_minus_1_reg <= str_io_dataOut2; // @[Toplevel.scala 187:25]
    end else if (state == 4'h0) begin // @[Toplevel.scala 113:26]
      str_j_minus_1_reg <= 16'h0; // @[Toplevel.scala 126:25]
    end
    if (reset) begin // @[Toplevel.scala 86:29]
      comp_in0_reg <= 16'h0; // @[Toplevel.scala 86:29]
    end else if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      comp_in0_reg <= prev; // @[Toplevel.scala 202:20]
    end
    if (reset) begin // @[Toplevel.scala 87:29]
      comp_in1_reg <= 16'h0; // @[Toplevel.scala 87:29]
    end else if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h9 == _addr2_reg_T_3[3:0]) begin // @[Toplevel.scala 203:20]
        comp_in1_reg <= dp_9; // @[Toplevel.scala 203:20]
      end else if (4'h8 == _addr2_reg_T_3[3:0]) begin // @[Toplevel.scala 203:20]
        comp_in1_reg <= dp_8; // @[Toplevel.scala 203:20]
      end else begin
        comp_in1_reg <= _GEN_122;
      end
    end
    if (reset) begin // @[Toplevel.scala 88:29]
      comp_in2_reg <= 16'h0; // @[Toplevel.scala 88:29]
    end else if (state == 4'h7) begin // @[Toplevel.scala 201:29]
      if (4'h9 == j[3:0]) begin // @[Toplevel.scala 189:12]
        comp_in2_reg <= dp_9; // @[Toplevel.scala 189:12]
      end else if (4'h8 == j[3:0]) begin // @[Toplevel.scala 189:12]
        comp_in2_reg <= dp_8; // @[Toplevel.scala 189:12]
      end else begin
        comp_in2_reg <= _GEN_78;
      end
    end
  end
endmodule
