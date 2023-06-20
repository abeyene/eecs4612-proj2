`include "Asic.v"

module TestHarness;
  reg         clk, reset;

  wire        cmd_ready;
  reg         cmd_valid;
  reg [6:0]	  cmd_bits_inst_funct;
  reg [4:0]   cmd_bits_inst_rs1;
  reg [4:0]   cmd_bits_inst_rs2;
  reg		      cmd_bits_inst_xd;
  reg		      cmd_bits_inst_xs1;
  reg		      cmd_bits_inst_xs2;
  reg [4:0]	  cmd_bits_inst_rd;
  reg [6:0]	  cmd_bits_inst_opcode;
  reg [63:0]  cmd_bits_rs1;
  reg [63:0]  cmd_bits_rs2;

  // PROC RESP Interface

  reg		      resp_ready;
  reg		      resp_valid;
  wire [4:0]	resp_bits_rd;
  wire [63:0] resp_bits_data;

    // MEM REQ Interface

  reg		      mem_req_ready;
  wire		    mem_req_valid;
  wire [39:0]	mem_req_bits_addr;
  wire [7:0]	mem_req_bits_tag;
  wire        mem_req_bits_phys;
  wire [4:0]	mem_req_bits_cmd;
  wire [1:0]	mem_req_bits_size;
  wire [63:0]	mem_req_bits_data;
  wire        mem_req_bits_signed;
  wire [7:0]	mem_req_bits_mask;

  reg		      mem_resp_valid;
  reg [39:0]	mem_resp_bits_addr;
  reg [7:0]	  mem_resp_bits_tag;
  reg [4:0]	  mem_resp_bits_cmd;
  reg [1:0]	  mem_resp_bits_size;
  reg [63:0]	mem_resp_bits_data;
  reg         mem_resp_bits_signed;
  reg [7:0]	  mem_resp_bits_mask;
  reg         mem_resp_bits_replay;
  reg         mem_resp_bits_has_data;
  reg [63:0]	mem_resp_bits_data_raw;
  reg [63:0]	mem_resp_bits_store_data;

  Asic #(
    .xLen(64),
    .mem_req_bits_size_width(2),
    .coreMaxAddrBits(40),
    .fLen(64),
    .dcacheReqTagBits(8),
    .M_SZ(5),
    .FPConstants_FLAGS_SZ(5),
    .paddrBits(32),
    .vaddrBitsExtended(40),
    .coreDataBytes(8),
    .FPConstants_RM_SZ(3),
    .coreDataBits(64),
    .PRV_SZ(2)
  ) dut (
    .clock(clk),
    .reset(reset),

    // PROC CMD Interface

    .rocc_cmd_ready(cmd_ready),
    .rocc_cmd_valid(cmd_valid),
    .rocc_cmd_bits_inst_funct(cmd_bits_inst_funct),
    .rocc_cmd_bits_inst_rs2(cmd_bits_inst_rs2),
    .rocc_cmd_bits_inst_rs1(cmd_bits_inst_rs1),
    .rocc_cmd_bits_inst_xd(cmd_bits_inst_xd),
    .rocc_cmd_bits_inst_xs1(cmd_bits_inst_xs1),
    .rocc_cmd_bits_inst_xs2(cmd_bits_inst_xs2),
    .rocc_cmd_bits_inst_rd(cmd_bits_inst_rd),
    .rocc_cmd_bits_inst_opcode(cmd_bits_inst_opcode),
    .rocc_cmd_bits_rs1(cmd_bits_rs1),

    // PROC RESP Interface

    .rocc_resp_ready(resp_ready),
    .rocc_resp_valid(resp_valid),
    .rocc_resp_bits_rd(resp_bits_rd),
    .rocc_resp_bits_data(resp_bits_data),

    // MEM REQ Interface

    .rocc_mem_req_ready(mem_req_ready),
    .rocc_mem_req_valid(mem_req_valid),
    .rocc_mem_req_bits_addr(mem_req_bits_addr),
    .rocc_mem_req_bits_tag(mem_req_bits_tag),
    .rocc_mem_req_bits_phys(mem_req_bits_phys),
    .rocc_mem_req_bits_cmd(mem_req_bits_cmd),
    .rocc_mem_req_bits_size(mem_req_bits_size),
    .rocc_mem_req_bits_data(mem_req_bits_data),
    .rocc_mem_req_bits_signed(mem_req_bits_signed),
    .rocc_mem_req_bits_mask(mem_req_bits_mask),

    // MEM RESP Interface

    .rocc_mem_resp_valid(mem_resp_valid),
    .rocc_mem_resp_bits_addr(mem_resp_bits_addr),
    .rocc_mem_resp_bits_tag(mem_resp_bits_tag),
    .rocc_mem_resp_bits_cmd(mem_resp_bits_cmd),
    .rocc_mem_resp_bits_size(mem_resp_bits_size),
    .rocc_mem_resp_bits_data(mem_resp_bits_data),
    .rocc_mem_resp_bits_signed(mem_resp_bits_signed),
    .rocc_mem_resp_bits_mask(mem_resp_bits_mask),
    .rocc_mem_resp_bits_replay(mem_resp_bits_replay),
    .rocc_mem_resp_bits_has_data(mem_resp_bits_has_data),
    .rocc_mem_resp_bits_data_raw(mem_resp_bits_data_raw),
    .rocc_mem_resp_bits_store_data(mem_resp_bits_store_data)
  );

  ExtMem extmem
  (
    .clk(clk),
    .reset(reset),

    // MEM REQ Interface

    .mem_req_ready(mem_req_ready),
    .mem_req_valid(mem_req_valid),
    .mem_req_bits_addr(mem_req_bits_addr),
    .mem_req_bits_tag(mem_req_bits_tag),
    .mem_req_bits_phys(mem_req_bits_phys),
    .mem_req_bits_cmd(mem_req_bits_cmd),
    .mem_req_bits_size(mem_req_bits_size),
    .mem_req_bits_data(mem_req_bits_data),
    .mem_req_bits_signed(mem_req_bits_signed),
    .mem_req_bits_mask(mem_req_bits_mask),

    // MEM RESP Interface

    .mem_resp_valid(mem_resp_valid),
    .mem_resp_bits_addr(mem_resp_bits_addr),
    .mem_resp_bits_tag(mem_resp_bits_tag),
    .mem_resp_bits_cmd(mem_resp_bits_cmd),
    .mem_resp_bits_size(mem_resp_bits_size),
    .mem_resp_bits_data(mem_resp_bits_data),
    .mem_resp_bits_signed(mem_resp_bits_signed),
    .mem_resp_bits_mask(mem_resp_bits_mask),
    .mem_resp_bits_replay(mem_resp_bits_replay),
    .mem_resp_bits_has_data(mem_resp_bits_has_data),
    .mem_resp_bits_data_raw(mem_resp_bits_data_raw),
    .mem_resp_bits_store_data(mem_resp_bits_store_data)
  );

  logic [39:0]	src_addr, dst_addr;
  logic 	go;
  logic [4:0]	  resp_bits_rd_r;
  logic [63:0]	resp_bits_data_r;
  logic [63:0]	trace_count;
  logic [255:0] desc;

  logic [63:0] asic_result;
  logic [63:0] exp_result;

  integer i;
  integer rsize = 1;
  integer csize = 1025;

  reg exit, fail;
  reg [1023:0] 	vcdplusfile = 0;
  reg [1023:0] 	vcdfile = 0;
  reg          	stats_active = 0;
  reg          	stats_tracking = 0;
  reg          	verbose = 0;
  reg [31:0]   	max_cycles = 0;
  integer      	stderr = 32'h80000002;
 
  `include "Proc.vfrag"

  assign asic_result = extmem.sram.mem[i];
  assign exp_result = 64'h0;

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
    // run_test(src_addr, dst_addr)
    //
    // Argument             Type            Values
    // --------------------------------------------------------------
    // src_addr             logic [39:0]    40-bit address of scores
    // dst_addr             logic [39:0]    40-bit address of output
     

    run_test(0, 0);

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
      resp_bits_rd_r   <= resp_bits_rd;
      resp_bits_data_r <= resp_bits_data;
    end
  end

  always @(posedge clk)
  begin
    if (exit == 1)
    begin
      $display("-------------------------------------");
      $display("address       data                   ");
      $display("-------------------------------------");
      for (i = 0; i < (8); i = i + 1)
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
    input logic [39:0]  arg1,
    input logic [39:0] 	arg2
  );
  begin
    //$readmemb("ExtMem.bin", extmem.sram.mem);
    if (verbose)
        $display("\nTest Parameters: N/A\n");

    #2 src_addr = arg1; dst_addr = arg2;

    #2 reset = 1'b1;
    #2 go = 1;
    $display("Start ...");

    wait (resp_valid == 1'b1);
    #4 $display("Finished.");

    $display("\nResults:\n");
    //$readmemb("R.bin", R); #2;

    if (resp_bits_rd_r !== 5'h1 || resp_bits_data_r !== 64'h1)
    begin
      fail = 1; exit = 1;
      if (verbose)
        $display("[resp_valid=1][resp_rd=%2h][resp_data=%8h]\n", resp_bits_rd_r, resp_bits_data_r);
    end
    else
    begin
      for (i = 0; i < csize * rsize; i = i + 1)
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
