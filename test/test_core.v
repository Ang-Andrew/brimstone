`timescale 1ns/1ps
module test_core();
  // local parameters
  localparam DATA_WIDTH_P = 32;
  localparam DATA_ADDR_WIDTH_P = 32;
  localparam ADDR_WIDTH_P = 5;
  localparam CNTRL_WIDTH_P = 3;
  localparam ALU_CNTRL_WIDTH_P = 3;
  localparam FUNCT_WIDTH_P = 6;
  localparam OP_WIDTH_P = 6;
  localparam DATA_MEM_INIT_FILE = "data_memory_test.mem";
  localparam PROGRAM_MEMORY_P = "test_program_memory.mem";
  localparam DEBUG_P = 0;

  // duration for each bit -> 25 MHz -> 40ns
  reg clk;
  localparam period = 40;
  localparam half_period = period/2;

  reg reset = 1'b0;

  wire [DATA_WIDTH_P-1:0] pc;
  reg [DATA_WIDTH_P-1:0] rd_data = {DATA_WIDTH_P{1'b0}};
  reg [DATA_WIDTH_P-1:0] mem_rd_data;
  wire mem_wr_en;
  wire [DATA_ADDR_WIDTH_P-1:0] mem_addr;
  wire [DATA_WIDTH_P-1:0] mem_wr_data;

  reg [DATA_WIDTH_P-1:0] data_memory [0:255];

  reg enable = 1'b0;

  reg [DATA_WIDTH_P-1:0] address_84 = {DATA_WIDTH_P{1'b0}};
  
  // clock generator
  always 
  begin
    clk = 1'b0; 
    #half_period;
    clk = 1'b1;
    #half_period;
  end

  core #(
    .PROGRAM_MEMORY_P(PROGRAM_MEMORY_P),
    .DATA_WIDTH_P(DATA_WIDTH_P),
    .DATA_ADDR_WIDTH_P(DATA_ADDR_WIDTH_P),
    .ADDR_WIDTH_P(ADDR_WIDTH_P),
    .CNTRL_WIDTH_P(CNTRL_WIDTH_P),
    .ALU_CNTRL_WIDTH_P(ALU_CNTRL_WIDTH_P),
    .FUNCT_WIDTH_P(FUNCT_WIDTH_P),
    .OP_WIDTH_P(OP_WIDTH_P))
  UUT(
    .clk(clk),
    .reset(reset),
    .i_enable(enable),

    // data memory interface
    .i_mem_rd_data(mem_rd_data),
    .o_mem_wr_en(mem_wr_en),
    .o_mem_addr(mem_addr),
    .o_mem_wr_data(mem_wr_data)
  );

  // data memory emulator
  integer j;
  initial begin
    if (DATA_MEM_INIT_FILE != "") begin
      $readmemh(DATA_MEM_INIT_FILE, data_memory);
    end else begin
      for(j=0;j<256;j=j+1) begin
        data_memory[j] <= {DATA_WIDTH_P{1'b0}};
      end;
    end
  end

  // write process
  always @(posedge clk) begin
    if (mem_wr_en) begin
      data_memory[mem_addr] <= mem_wr_data;
    end;
  end

  // read process
  always @(*) begin
    mem_rd_data = data_memory[mem_addr];
    address_84 = data_memory[84];
  end

  initial begin
    if (DEBUG_P == 1) begin
      $dumpfile ("test_core.vcd");
      $dumpvars(0, test_core); 
    end;
    $display("Starting MIPs test");
    #period
    //--------------------------------------------------------------------------
    // # Test the MIPS processor.
    //      add, sub, and, or, slt, addi, lw, sw, beq, j
    //      If successful, it should write the value 7 to address 84
    // # mipstest.asm
    // # David_Harris@hmc.edu 9 November 2005
    //-------------------------------------------------------------------------
    @(posedge clk)
    #0.001
    enable = 1'b1;

    //--------------------------------------------------------------------------

    #741.400

    if (address_84 == 7) begin
      $display("test passed");
      $finish;
    end else begin
      $display("test failed, address 84 : %b",address_84);
      $stop;
    end;
    // $display("done");
    // $finish;   // end of simulation
  end

endmodule
