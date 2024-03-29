`include "Asic.v"

module TestHarness;
  reg           clk, reset;

  wire          cmd_ready;
  reg           cmd_valid;
  reg [6:0]	cmd_inst_funct;
  reg [4:0] 	cmd_inst_rs2;
  reg [4:0] 	cmd_inst_rs1;
  reg		cmd_inst_xd;
  reg		cmd_inst_xs1;
  reg		cmd_inst_xs2;
  reg [4:0]	cmd_inst_rd;
  reg [6:0]	cmd_inst_opcode;
  reg [63:0]	cmd_rs1;

  // PROC RESP Interface

  reg		resp_ready;
  reg		resp_valid;
  wire [4:0]	resp_rd;
  wire [63:0]   resp_data;

    // MEM REQ Interface

  reg		mem_req_ready;
  wire		mem_req_valid;
  wire [39:0]	mem_req_addr;
  wire [4:0]	mem_req_cmd;
  wire [2:0]	mem_req_typ;
  wire [63:0]	mem_req_data;

  // MEM RESP Interface

  reg		mem_resp_valid;
  reg [39:0]	mem_resp_addr;
  reg [4:0]	mem_resp_cmd;
  reg [2:0]	mem_resp_typ;
  reg [63:0]	mem_resp_data;

  Asic dut
  (
    .clk(clk),
    .reset(reset),

    // PROC CMD Interface

    .cmd_ready_o(cmd_ready),
    .cmd_valid_i(cmd_valid),
    .cmd_inst_funct_i(cmd_inst_funct),
    .cmd_inst_rs2_i(cmd_inst_rs2),
    .cmd_inst_rs1_i(cmd_inst_rs1),
    .cmd_inst_xd_i(cmd_inst_xd),
    .cmd_inst_xs1_i(cmd_inst_xs1),
    .cmd_inst_xs2_i(cmd_inst_xs2),
    .cmd_inst_rd_i(cmd_inst_rd),
    .cmd_inst_opcode_i(cmd_inst_opcode),
    .cmd_rs1_i(cmd_rs1),

    // PROC RESP Interface

    .resp_ready_i(resp_ready),
    .resp_valid_o(resp_valid),
    .resp_rd_o(resp_rd),
    .resp_data_o(resp_data),

    // MEM REQ Interface

    .mem_req_ready_i(mem_req_ready),
    .mem_req_valid_o(mem_req_valid),
    .mem_req_addr_o(mem_req_addr),
    .mem_req_cmd_o(mem_req_cmd),
    .mem_req_typ_o(mem_req_typ),
    .mem_req_data_o(mem_req_data),

    // MEM RESP Interface

    .mem_resp_valid_i(mem_resp_valid),
    .mem_resp_addr_i(mem_resp_addr),
    .mem_resp_cmd_i(mem_resp_cmd),
    .mem_resp_typ_i(mem_resp_typ),
    .mem_resp_data_i(mem_resp_data)
  );

  ExtMem extmem
  (
    .clk(clk),
    .reset(reset),

    // MEM REQ Interface

    .mem_req_ready_o(mem_req_ready),
    .mem_req_valid_i(mem_req_valid),
    .mem_req_addr_i(mem_req_addr),
    .mem_req_cmd_i(mem_req_cmd),
    .mem_req_typ_i(mem_req_typ),
    .mem_req_data_i(mem_req_data),

    // MEM RESP Interface

    .mem_resp_valid_o(mem_resp_valid),
    .mem_resp_addr_o(mem_resp_addr),
    .mem_resp_cmd_o(mem_resp_cmd),
    .mem_resp_typ_o(mem_resp_typ),
    .mem_resp_data_o(mem_resp_data)
  );

  logic [5:0]   a, k;
  logic [6:0]   M,  N;
  logic         bitwidth; 
  logic [1:0]   actfun;
  logic [39:0]	Waddr, Xaddr, Raddr;
  logic [63:0]	R[63:0];
  logic 	go;
  logic [4:0]	resp_rd_r;
  logic [63:0]	resp_data_r;
  logic [63:0]	trace_count;
  logic [255:0] desc;

  logic [15:0]  exp_subword, exp_result;
  logic [15:0]  asic_subword, asic_result;
  logic [63:0]  asic_word;

  integer i;

  logic [63:0] wblocks, xblocks, rblocks;

  reg exit, fail;
  reg [1023:0] 	vcdplusfile = 0;
  reg [1023:0] 	vcdfile = 0;
  reg          	stats_active = 0;
  reg          	stats_tracking = 0;
  reg          	verbose = 0;
  reg [31:0]   	max_cycles = 0;
  integer      	stderr = 32'h80000002;
 
  `include "Proc.vfrag"

  assign exp_subword  = R[i]>>a;
  assign asic_word = extmem.sram.mem[(Raddr>>3) + (i / (k ? k : bitwidth ? 4 : 8))];

  always_comb
  begin
    if (bitwidth)
    begin
      case (actfun)
        2'b00 : exp_result = exp_subword[15:0];
        2'b01 : exp_result = exp_subword[15] == 1 ? 0 : exp_subword[15:0];
        2'b10 : exp_result = $tanh(exp_subword[15] == 1 ? 0 : exp_subword[15:0]);
        default : exp_result = 16'hxxxx;
      endcase
    end
    else
    begin
      case (actfun)
        2'b00 : exp_result = exp_subword[7:0];
        2'b01 : exp_result = exp_subword[7] == 1 ? 0 : exp_subword[7:0];
        2'b10 : exp_result = $tanh(exp_subword[7] == 1 ? 0 : exp_subword[7:0]);
        default : exp_result = 8'hxxxx;
      endcase
    end
  end

  assign asic_subword = asic_word>>((i % (k ? k : bitwidth ? 4 : 8))*(bitwidth ? 16 : 8));
  assign asic_result = bitwidth ? asic_subword[15:0] : asic_subword[7:0];

  assign wblocks = k ? ((M*N) % k) != 0 ? (M*N) / k + 1 : (M*N) / k : ((M*N) % (bitwidth ? 4 : 8)) != 0 ? (M*N) / (bitwidth ? 4 : 8) + 1 : (M*N) / (bitwidth ? 4 : 8);
  assign xblocks = k ? (N % k) != 0 ? N / k + 1 : N / k : (N % (bitwidth ? 4 : 8)) != 0 ? N / (bitwidth ? 4 : 8) + 1 : N / (bitwidth ? 4 : 8);
  assign rblocks = k ? (M % k) != 0 ? M / k + 1 : M / k : (M % (bitwidth ? 4 : 8)) != 0 ? M / (bitwidth ? 4 : 8) + 1 : M / (bitwidth ? 4 : 8);

  initial
  begin
    clk	  = 1'b0;
    reset = 1'b0;
    exit  = 0;
    fail  = 0;
    go 	  = 1'b0;
    trace_count = 0;
    #200;
    $display("\n");
    $display("==========================================================");
    $display("\n");
    $display("EECS 4612 Project 2 ASIC Test Suite");
    $display("Description: Process an arbitrary matrix/vector stream set");
    $display("\n");
    $display("==========================================================");
    if (!verbose)
        $display("\n");

    // Unit Tests
    //
    // run_test(element bitwidth, activation function, a, k, M, N)
    //
    // Argument             Type            Values
    // --------------------------------------------------------------
    // element bitwidth     boolean         0 -> 8 bits, 1 -> 16 bits
    // activation function  logic [1:0]     0 -> SWS, 1 -> ReLU, 2 -> arctan
    // a                    logic [6:0]     0 - 24
    // k                    logic [6:0]     0 - 7
    // M                    logic [6:0]     1 - 64
    // N                    logic [6:0]     1 - 64

    run_test(0, 0, 0, 1, 1, 1);

`ifdef DEBUG
  $vcdplusclose;
`endif
  end

  initial
  begin
    $value$plusargs("max-cycles=%d", max_cycles);
    verbose = $test$plusargs("verbose");
`ifdef DEBUG
  if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
  begin
    $vcdplusfile(vcdplusfile);
    $vcdpluson(0);
    $vcdplusmemon(0);
  end
`endif
  end

  always	
  begin
      #1 clk = 1; #1 clk = 0;
  end

  always @(posedge clk)
  begin
      trace_count = trace_count + 1;
  end

  always @(posedge clk)
  begin
    if (max_cycles > 0 && trace_count > max_cycles && exit == 0)
	begin
	  $fdisplay(stderr, "\n** TIMEOUT **\n");
          fail = 1;
          exit = 1;
	end
  end

  always @(posedge clk)
  begin
    if (resp_valid) 
    begin
      resp_rd_r <= resp_rd;
      resp_data_r <= resp_data;
    end
  end

  always @(posedge clk)
  begin
    if (exit == 1)
    begin
      $display("-------------------------------------");
      $display("address       data                   ");
      $display("-------------------------------------");
      for (i = 0; i < (wblocks + xblocks + rblocks); i = i + 1)
        #2 $display("%-14h%1h%1h_%1h%1h_%1h%1h_%1h%1h_%1h%1h_%1h%1h_%1h%1h_%1h%1h", i*8, 
                                    extmem.sram.mem[i][63:60],
                                    extmem.sram.mem[i][59:56],
                                    extmem.sram.mem[i][55:52],
                                    extmem.sram.mem[i][51:48],
                                    extmem.sram.mem[i][47:44],
                                    extmem.sram.mem[i][43:40],
                                    extmem.sram.mem[i][39:36],
                                    extmem.sram.mem[i][35:32],
                                    extmem.sram.mem[i][31:28],
                                    extmem.sram.mem[i][27:24],
                                    extmem.sram.mem[i][23:20],
                                    extmem.sram.mem[i][19:16],
                                    extmem.sram.mem[i][15:12],
                                    extmem.sram.mem[i][11:8],
                                    extmem.sram.mem[i][7:4],
                                    extmem.sram.mem[i][3:0]);
      $display("-------------------------------------");
      $display("");
      if (fail == 1)
        $display("[ failed ]");
      else
        $display("[ passed ]");
      $display("");
      $finish();
    end
  end

  task run_test
  (
    input logic  	arg1,
    input logic [1:0] 	arg2,
    input logic [6:0] 	arg3,
    input logic [6:0] 	arg4,
    input logic [7:0] 	arg5,
    input logic [7:0] 	arg6
  );
  begin
    $readmemb("ExtMem.bin", extmem.sram.mem);
    if (verbose)
        $display("\nTest Parameters: bitwidth=%0d actfun=%0d a=%0d k'=%0d M=%0d N=%0d\n", arg1 ? 16 : 8, arg2, arg3, arg4, arg5, arg6);

    #2 bitwidth = arg1; actfun = arg2;
    #2 a = arg3; k = arg4; M = arg5; N = arg6; 
    #2 Waddr = 40'h0; Xaddr = Waddr + (wblocks) << 3; Raddr = Xaddr + (xblocks << 3);

    #2 reset = 1'b1;
    #2 go = 1;
    $display("Start ...");

    wait (resp_valid == 1'b1);
    #4 $display("Finished.");

    $display("\nResults:\n");
    $readmemb("R.bin", R); #2;

    if (resp_rd_r !== 5'h1 || resp_data_r !== 64'h1)
    begin
      fail = 1; exit = 1;
      if (verbose)
        $display("[resp_valid=1][resp_rd=%2h][resp_data=%8h]\n", resp_rd_r, resp_data_r);
    end
    else
    begin
      for (i = 0; i < M; i = i + 1)
      begin
        #2;
        if (exp_result !== asic_result)
          fail = 1;
      end
      exit = 1;
    end
  end
  endtask
endmodule
