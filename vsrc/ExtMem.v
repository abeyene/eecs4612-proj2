//---------------------------------------------------------
//  File:   Mem.v
//  Author: Abel Beyene
//  Date:   March 6, 2023
//
//  Description:
//
//  RoCC wrapper for 1RW synchronous SRAM 
//  
//  Name                    I/O     Width     Description
//  -------------------------------------------------------
//  clk                     input   1         clock
//  rst                     input   1         reset
//  mem_req_ready           input   1         control
//  mem_req_valid           input   1         control
//  mem_req_bits_addr       output  40        memory address
//  mem_req_bits_cmd        output  5         memory operation
//  mem_req_bits_size       output  3         operation size
//  mem_req_bits_data       output  64        operation data
//  mem_resp_ready          input   1         control
//  mem_resp_valid          output  1         control
//  mem_resp_bits_addr      output  40        memory address 
//  mem_resp_bits_cmd       output  5         memory operation
//  mem_resp_bits_size      output  3         operation size
//  mem_resp_bits_data      output  64        operation data
//---------------------------------------------------------

`include "AsicDefines.vh"

module  ExtMem
(
  input   logic        clk,
  input   logic        reset,

  // MEM REQ Interface

  output  logic        mem_req_ready,
  input   logic        mem_req_valid,
  input   logic [39:0] mem_req_bits_addr,
  input   logic [7:0]  mem_req_bits_tag,
  input   logic        mem_req_bits_phys,
  input   logic [4:0]  mem_req_bits_cmd,
  input   logic [1:0]  mem_req_bits_size,
  input   logic [63:0] mem_req_bits_data,
  input   logic        mem_req_bits_signed,
  input   logic [7:0]  mem_req_bits_mask,

  // MEM RESP Interface

  output  logic        mem_resp_valid,
  output  logic [39:0] mem_resp_bits_addr,
  output  logic [7:0]  mem_resp_bits_tag,
  output  logic [4:0]  mem_resp_bits_cmd,
  output  logic [1:0]  mem_resp_bits_size,
  output  logic [63:0] mem_resp_bits_data,
  output  logic        mem_resp_bits_signed,
  output  logic [7:0]  mem_resp_bits_mask,
  output  logic        mem_resp_bits_replay,
  output  logic        mem_resp_bits_has_data,
  output  logic [63:0] mem_resp_bits_data_raw,
  output  logic [63:0] mem_resp_bits_store_data
);

  localparam read_cmd_lp  = 3'b0;
  localparam write_cmd_lp = 3'b1;

  typedef enum logic [3:0] {IDLE, MEM_READ_REQ, MEM_READ_RESP, MEM_WRITE_REQ, MEM_WRITE_RESP} state_t;

  state_t state, state_n;

  // Read port (synchronous read)

  logic                         read_en;
  logic [`EXTMEM_ADDR_SIZE-1:0] read_addr;
  logic [63:0]                  read_data;

  // Write port (sampled on the rising clock edge)

  logic                         write_en;
  logic [7:0]                   write_byte_en;
  logic [`EXTMEM_ADDR_SIZE-1:0] write_addr;
  logic [63:0]                  write_data;

  always @(*)
  begin
    case (state)
      IDLE :
      begin
          if (mem_req_ready & mem_req_valid)
          begin
            if (mem_req_bits_cmd == read_cmd_lp)
              state_n = MEM_READ_REQ;
            else if (mem_req_bits_cmd == write_cmd_lp)
              state_n = MEM_WRITE_REQ;
            read_en       = 1'b0;
            read_addr     = `EXTMEM_ADDR_SIZE'b0;
            write_en      = 1'b0;
            write_byte_en = 8'b0;
            write_addr    = `EXTMEM_ADDR_SIZE'b0;
            write_data    = 64'b0;
          end
         else
         begin
           mem_req_ready              = 1'b1;
           mem_resp_valid             = 1'b0;
           mem_resp_bits_addr         = 40'b0;
           mem_resp_bits_tag          = 8'b0;
           mem_resp_bits_cmd          = 5'b0;
           mem_resp_bits_size         = 2'b0;
           mem_resp_bits_data         = 64'b0;
           mem_resp_bits_signed       = 1'b0;
           mem_resp_bits_mask         = 8'b0;
           mem_resp_bits_replay       = 64'b0;
           mem_resp_bits_has_data     = 64'b0;
           mem_resp_bits_data_raw     = 64'b0;
           mem_resp_bits_store_data   = 64'b0;

           read_en             = 1'b0;
           read_addr           = `EXTMEM_ADDR_SIZE'b0;
           write_en            = 1'b0;
           write_byte_en       = 8'b0;
           write_addr          = `EXTMEM_ADDR_SIZE'b0;
           write_data          = 64'b0;
           state_n             = IDLE;
         end
      end
      MEM_READ_REQ :
      begin
        mem_req_ready         = 1'b0;
        read_en               = 1'b1;
        read_addr             = mem_req_bits_addr[`EXTMEM_ADDR_SIZE-1:0] >> 3;
        state_n               = MEM_READ_RESP;
      end
      MEM_READ_RESP :
      begin
        mem_resp_valid            = 1'b1;
        mem_resp_bits_addr        = mem_req_bits_addr[`EXTMEM_ADDR_SIZE-1:0];
        mem_resp_bits_tag         = mem_req_bits_tag;
        mem_resp_bits_cmd         = mem_req_bits_cmd;
        mem_resp_bits_size        = mem_req_bits_size;
        mem_resp_bits_signed      = mem_req_bits_signed;
        mem_resp_bits_mask        = mem_req_bits_mask;
        mem_resp_bits_replay      = 1'b0;
        mem_resp_bits_has_data    = 1'b1;
        mem_resp_bits_data_raw    = 64'b0;
        mem_resp_bits_store_data  = 64'b0;
        case (mem_req_bits_size)
          0 : mem_resp_bits_data = read_data;
          1 : mem_resp_bits_data = read_data & 64'hff;
          2 : mem_resp_bits_data = read_data & 64'hffff;
          3 : mem_resp_bits_data = read_data & 64'hffffff;
          4 : mem_resp_bits_data = read_data & 64'hffffffff;
          5 : mem_resp_bits_data = read_data & 64'hffffffffff;
          6 : mem_resp_bits_data = read_data & 64'hffffffffffff;
          7 : mem_resp_bits_data = read_data & 64'hffffffffffffff;
        endcase
        state_n               = IDLE;
      end
      MEM_WRITE_REQ :
      begin
        mem_req_ready         = 1'b0;
        write_en              = 1'b1;
        write_addr            = mem_req_bits_addr[`EXTMEM_ADDR_SIZE-1:0] >> 3;
        write_data            = mem_req_bits_data;
        state_n               = MEM_WRITE_RESP;
        case (mem_req_bits_size)
          0 : write_byte_en   = 8'b11111111;
          1 : write_byte_en   = 8'b00000001;
          2 : write_byte_en   = 8'b00000011;
          3 : write_byte_en   = 8'b00000111;
          4 : write_byte_en   = 8'b00001111;
          5 : write_byte_en   = 8'b00011111;
          6 : write_byte_en   = 8'b00111111;
          7 : write_byte_en   = 8'b01111111;
        endcase
      end
      MEM_WRITE_RESP :
      begin
        mem_resp_valid            = 1'b1;
        mem_resp_bits_addr        = mem_req_bits_addr[`EXTMEM_ADDR_SIZE-1:0];
        mem_resp_bits_tag         = mem_req_bits_tag;
        mem_resp_bits_cmd         = mem_req_bits_cmd;
        mem_resp_bits_size        = mem_req_bits_size;
        mem_resp_bits_data        = mem_req_bits_data;
        mem_resp_bits_signed      = mem_req_bits_signed;
        mem_resp_bits_mask        = mem_req_bits_mask;
        mem_resp_bits_replay      = 1'b0;
        mem_resp_bits_has_data    = 1'b0;
        mem_resp_bits_data_raw    = 64'b0;
        mem_resp_bits_store_data  = 64'b0;
        state_n                   = IDLE;
     end
     default :
     begin
       mem_req_ready          = 1'b1;
       mem_resp_valid         = 1'b0;
       mem_resp_bits_addr     = 40'b0;
       mem_resp_bits_cmd      = 5'b0;
       mem_resp_bits_size     = 2'b0;
       mem_resp_bits_data     = 64'b0;

       read_en                = 1'b0;
       read_addr              = `EXTMEM_ADDR_SIZE'b0;
       write_en               = 1'b0;
       write_byte_en          = 8'b0;
       write_addr             = `EXTMEM_ADDR_SIZE'b0;
       write_data             = 64'b0;
     end
    endcase
  end

  always @(posedge clk)
  begin
    if (~reset)
      state <= IDLE;
    else
      state <= state_n;
  end
    
  SynchronousSRAM_1rw #(.p_data_nbits(64), .p_num_entries(2**`EXTMEM_ADDR_SIZE))
    sram (  
          .clk(clk),
          .reset(reset),
          .read_en(read_en),  
          .read_addr(read_addr),  
          .read_data(read_data),  
          .write_en(write_en),    
          .write_byte_en(write_byte_en),  
          .write_addr(write_addr),    
          .write_data(write_data)
        );
endmodule   
