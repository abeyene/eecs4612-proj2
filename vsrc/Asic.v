//========================================================================
// 4612 Project 2
// MxN Systolic Array Multiplier
//========================================================================

`include "AsicDefines.vh"

module Asic
(
  input     logic             clk,
  input     logic             reset,

  // PROC CMD Interface
                                
  output	logic             cmd_ready_o,
  input		logic       	  cmd_valid_i,
  input		logic [6:0]       cmd_inst_funct_i,
  input		logic [4:0]       cmd_inst_rs2_i,
  input		logic [4:0]       cmd_inst_rs1_i,
  input		logic        	  cmd_inst_xd_i,
  input		logic        	  cmd_inst_xs1_i,
  input		logic        	  cmd_inst_xs2_i,
  input		logic [4:0]       cmd_inst_rd_i,
  input		logic [6:0]       cmd_inst_opcode_i,
  input		logic [`XLEN-1:0] cmd_rs1_i,

  // PROC RESP Interface

  input		logic        	  resp_ready_i,
  output	logic        	  resp_valid_o,
  output	logic [4:0]       resp_rd_o,
  output	logic [`XLEN-1:0] resp_data_o,

  // MEM REQ Interface

  input  	logic       	  mem_req_ready_i,
  output 	logic       	  mem_req_valid_o,
  output 	logic [39:0]      mem_req_addr_o,
  output 	logic [4:0]		  mem_req_cmd_o,
  output 	logic [2:0]       mem_req_typ_o,
  output 	logic [`XLEN-1:0] mem_req_data_o,

  // MEM RESP Interface

  input 	logic        	  mem_resp_valid_i,
  input 	logic [39:0]      mem_resp_addr_i,
  input 	logic [4:0]       mem_resp_cmd_i,
  input 	logic [2:0]       mem_resp_typ_i,
  input 	logic [`XLEN-1:0] mem_resp_data_i
);
  	
endmodule
