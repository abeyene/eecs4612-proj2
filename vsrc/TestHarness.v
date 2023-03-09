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

  logic [6:0]   a,  k,  M,  N;
  logic [39:0]	Waddr, Xaddr, Raddr;
  logic         ReLu;
  logic [63:0]	R[63:0];
  logic 	go;
  logic [63:0]	rd_data;
  logic [63:0]	trace_count;
  logic [255:0] desc;

  integer i;	

  `include "Proc.vfrag"

  reg exit;
  reg [1023:0] 	vcdplusfile = 0;
  reg [1023:0] 	vcdfile = 0;
  reg          	stats_active = 0;
  reg          	stats_tracking = 0;
  reg          	verbose = 0;
  reg [31:0]   	max_cycles = 0;
  integer      	stderr = 32'h80000002;

  initial
  begin
    clk	  = 1'b0;
    reset = 1'b0;
    exit  = 0;
    go 	  = 1'b0;
    #10;
    $display("\n");
    $display("==========================================================");
    $display("\n");
    $display("4612 Project 2 ASIC Test Suite");
    $display("Description: Process an arbitrary matrix/vector stream set");
    $display("\n");
    $display("==========================================================");
    if (!verbose)
        $display("\n");
    //		 a  k   M   N  ReLu
    run_test(0, 1, 2, 2);
`ifdef DEBUG
  $vcdplusclose;
`endif
    $display("\n");
    $finish;
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
    if (~reset)
      trace_count = 0;
    else
      trace_count = trace_count + 1;
  end

  always @(posedge clk)
  begin
    if (max_cycles > 0 && trace_count > max_cycles)
	begin
	  $fdisplay(stderr, "\n** TIMEOUT **\n\n");
	  $finish(1);
	end
  end

  always @(posedge clk)
  begin
    if (resp_valid)
      rd_data <= resp_data;
  end

  task run_test
  (
    input logic [6:0] 	arg1, 
    input logic [6:0] 	arg2, 
    input logic [6:0] 	arg3, 
    input logic [6:0] 	arg4
  );
  begin
    $readmemb("ExtMem.bin", extmem.sram.mem);
    exit = 0;
    if (verbose)
        $display("\n\nTest: a=%0d k=%0d M=%0d N=%0d\n", arg1, arg2, arg3, arg4);

    #2 a = arg1; k = arg2; M = arg3; N = arg4; ReLu = 1'b0; Waddr = 40'h0; Xaddr = Waddr + (arg3 * arg4) << 3; Raddr = Xaddr + (arg4 << 3);
    #2 reset = 1'b1;
    #2 go = 1;

    wait (resp_valid == 1'b1);

    $readmemb("R.bin", R);
    if (rd_data != 63'h0)
    begin
      if (verbose)
        $display("[clock=%2t][rd_data=%8h]\n", $time, rd_data);
      $display("[ failed ] %0s", desc);
      $finish(rd_data);
    end
    else
    begin
      for (i = 0; i < M * N; i = i + 1)
      begin
        if (extmem.sram.mem[Raddr + i*8] != ReLu ? ((R[i][7:0])>0 ? R[i][7:0] : 0) : R[i][7:0])
        begin
          exit = 1;
          $display("R[%0d]=%2d. Expecting %2d]\n", i, extmem.sram.mem[Raddr + i*8], R[i]);
        end
      end
    end

    if (exit == 1)
        $display("[ failed ] %0s", desc);
    else
        $display("[ passed ] %0s", desc);
  end
  endtask
endmodule