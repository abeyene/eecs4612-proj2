//---------------------------------------------------------
//  File:   Asic.v
//  Author: Abel Beyene
//  Date:   March 6, 2023
//
//  Description:
//
//  Top-level module for matrix-vector multiplier
//  
//  Interface:  
//  
//  Name                    I/O     Width     Description
//  -------------------------------------------------------
//  clk                     input   1         clock
//  rst                     input   1         reset
//  cmd_ready_o             output  1         control
//  cmd_valid_i             input   1         control
//  cmd_inst_funct_i        input   7         function code
//  cmd_inst_rs2_i          input   5         rs2 register
//  cmd_inst_rs1_i          input   5         rs1 register
//  cmd_inst_xd_i           input   1         valid rd
//  cmd_inst_xrs1_i         input   1         valid rs2
//  cmd_inst_xrs2_i         input   1         valid rs1
//  cmd_inst_rd_i           input   5         rd register
//  cmd_inst_opcode_i       input   7         opcode
//  cmd_rs1_i               input   64        rs1 data
//  mem_req_ready_o         input   128       control
//  mem_req_valid_i         input   1         control
//  mem_req_addr_i          output  32        memory address
//  mem_req_cmd_i           output  5         memory operation
//  mem_req_typ_i           output  3         operation size
//  mem_req_data_i          output  64        operation data
//  mem_resp_ready_i        input   128       control
//  mem_resp_valid_o        output  1         control
//  mem_resp_addr_o         output  32        memory address 
//  mem_resp_cmd_o          output  5         memory operation
//  mem_resp_typ_o          output  3         operation size
//  mem_resp_data_o         output  64        operation data
//---------------------------------------------------------

`include "AsicDefines.vh"

module Asic
(
  input         logic             clk,
  input         logic             reset,

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
  output 	logic [4:0]	  mem_req_cmd_o,
  output 	logic [2:0]       mem_req_typ_o,
  output 	logic [`XLEN-1:0] mem_req_data_o,

  // MEM RESP Interface

  input 	logic        	  mem_resp_valid_i,
  input 	logic [39:0]      mem_resp_addr_i,
  input 	logic [4:0]       mem_resp_cmd_i,
  input 	logic [2:0]       mem_resp_typ_i,
  input 	logic [`XLEN-1:0] mem_resp_data_i
);

  // ************ PUT YOUR RTL HERE ************ //
  	
endmodule
