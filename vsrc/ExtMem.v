//---------------------------------------------------------
//  File: Mem.v
//  Date: March 6, 2023
//
//  Description:
//
//  RoCC wrapper for 1RW synchronous SRAM 
//  
//  Name                    I/O     Width     Description
//  -------------------------------------------------------
//  clk                     input   1         Clock
//  rst                     input   1         Reset
//  mem_req_ready_o         input   128       Control
//  mem_req_valid_i         input   1         Control
//  mem_req_addr_i          output  32        Memory Address
//  mem_req_cmd_i           output  5         Memory Operation
//  mem_req_typ_i           output  3         Operation Size
//  mem_req_data_i          output  64        Operation Data
//  mem_resp_ready_i        input   128       Control
//  mem_resp_valid_o        output  1         Control
//  mem_resp_addr_o         output  32        Memory Address 
//  mem_resp_cmd_o          output  5         Memory Operation
//  mem_resp_typ_o          output  3         Operation Size
//  mem_resp_data_o         output  64        Operation Data
//
//---------------------------------------------------------

`include "AsicDefines.vh"

module  ExtMem
(
  input   logic        clk,
  input   logic        reset,

  output  logic        mem_req_ready_o,
  input   logic        mem_req_valid_i,
  input   logic [39:0] mem_req_addr_i,
  input   logic [4:0]  mem_req_cmd_i,
  input   logic [2:0]  mem_req_typ_i,
  input   logic [63:0] mem_req_data_i,

    // MEM RESP Interface

  output  logic        mem_resp_valid_o,
  output  logic [39:0] mem_resp_addr_o,
  output  logic [4:0]  mem_resp_cmd_o,
  output  logic [2:0]  mem_resp_typ_o,
  output  logic [63:0] mem_resp_data_o
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
          if (mem_req_ready_o & mem_req_valid_i)
          begin
            mem_req_ready_o     = 1'b0;
            if (mem_req_cmd_i == read_cmd_lp)
              state_n = MEM_READ_REQ;
            else if (mem_req_cmd_i == write_cmd_lp)
              state_n = MEM_WRITE_REQ;
            read_en       = 1'b0;
            read_addr     = `EXTMEM_ADDR_SIZE'b0;
            write_en      = 1'b0;
            write_byte_en = 1'b0;
            write_addr    = `EXTMEM_ADDR_SIZE'b0;
            write_data    = 63'b0;
          end
      end
      MEM_READ_REQ :
      begin
        read_en               = 1'b1;
        read_addr             = mem_req_addr_i[`EXTMEM_ADDR_SIZE-1:0];
        state_n               = MEM_READ_RESP;
      end
      MEM_READ_RESP :
      begin
        mem_resp_valid_o      = 1'b1;
        mem_resp_addr_o       = mem_req_addr_i[`EXTMEM_ADDR_SIZE-1:0];
        mem_resp_cmd_o        = mem_req_cmd_i;
        mem_resp_typ_o        = mem_req_typ_i;
        case (mem_req_typ_i)
          0 : mem_resp_data_o = read_data;
          1 : mem_resp_data_o = read_data & 64'hff;
          2 : mem_resp_data_o = read_data & 64'hffff;
          3 : mem_resp_data_o = read_data & 64'hffffff;
          4 : mem_resp_data_o = read_data & 64'hffffffff;
          5 : mem_resp_data_o = read_data & 64'hffffffffff;
          6 : mem_resp_data_o = read_data & 64'hffffffffffff;
          7 : mem_resp_data_o = read_data & 64'hffffffffffffff;
        endcase
        state_n               = IDLE;
      end
      MEM_WRITE_REQ :
      begin
        write_en              = 1'b1;
        write_addr            = mem_req_addr_i[`EXTMEM_ADDR_SIZE-1:0];
        write_data            = mem_req_data_i;
        state_n                     = MEM_READ_RESP;
        case (mem_req_typ_i)
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
        mem_resp_valid_o   = 1'b1;
        mem_resp_addr_o    = mem_req_addr_i[`EXTMEM_ADDR_SIZE-1:0];
        mem_resp_cmd_o     = mem_req_cmd_i;
        mem_resp_typ_o     = mem_req_typ_i;
        mem_resp_data_o    = mem_req_data_i;   
        state_n            = IDLE;
     end
     default :
     begin
       mem_req_ready_o     = 1'b1;
       mem_resp_valid_o    = 1'b0;
       mem_resp_addr_o     = 1'b0;
       mem_resp_cmd_o      = 1'b0;
       mem_resp_typ_o      = 1'b0;
       mem_resp_data_o     = 1'b0;

       read_en             = 1'b0;
       read_addr           = `EXTMEM_ADDR_SIZE'b0;
       write_en            = 1'b0;
       write_byte_en       = 1'b0;
       write_addr          = `EXTMEM_ADDR_SIZE'b0;
       write_data          = 63'b0;
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
