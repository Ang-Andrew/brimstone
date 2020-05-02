`timescale 1ns/1ps
module test_core#(
)();
  // local parameters
  localparam DATA_WIDTH_P = 32;
  localparam DATA_ADDR_WIDTH_P = 32;
  localparam ADDR_WIDTH_P = 5;
  localparam CNTRL_WIDTH_P = 3;
  localparam ALU_CNTRL_WIDTH_P = 3;
  localparam FUNCT_WIDTH_P = 6;
  localparam OP_WIDTH_P = 6;
  localparam DATA_MEM_INIT_FILE = "data_memory_test.mem";

  // duration for each bit -> 25 MHz -> 40ns
  reg clk;
  localparam period = 40;
  localparam half_period = period/2;

  reg reset = 1'b0;

  wire [DATA_WIDTH_P-1:0] pc;
  reg [DATA_WIDTH_P-1:0] instr;
  reg [DATA_WIDTH_P-1:0] rd_data = {DATA_WIDTH_P{1'b0}};
  wire [DATA_WIDTH_P-1:0] mem_rd_data;
  wire mem_wr_en;
  wire [DATA_ADDR_WIDTH_P-1:0] mem_addr;
  wire [DATA_WIDTH_P-1:0] mem_wr_data;

  reg [DATA_WIDTH_P-1:0] data_memory [0:1023];
  
  // clock generator
  always 
  begin
    clk = 1'b0; 
    #half_period;
    clk = 1'b1;
    #half_period;
  end

  core #(
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
    .i_instr(instr),

    // instruction memory interface
    .o_pc(pc),
    
    // data memory interface
    .i_mem_rd_data(mem_rd_data),
    .o_mem_wr_en(mem_wr_en),
    .o_mem_addr(mem_addr),
    .o_mem_wr_data(mem_wr_data)
  );

  // data memory emulator
  initial begin
    if (DATA_MEM_INIT_FILE != "") begin
      $readmemh(DATA_MEM_INIT_FILE, data_memory);
    end
  end

  always @(*) begin
    // if (mem_wr_en) begin
      // data_memory[mem_addr] = mem_wr_data;
    // end else begin
      // rd_data = data_memory[mem_addr];
    // end;
    rd_data = data_memory[mem_addr];
  end

  // assign mem_rd_data = rd_data;

  initial begin
    #period
    //--------------------------------------------------------------------------
    // test core
    //--------------------------------------------------------------------------
    @(posedge clk)
    $display ("TEST: lw");
    // lw $s3, -24($s4)
    // lw 0d19, -24(0d20)
    // op       rs      rt      imm
    // 0d35     0d20    0d19    -24
    // 100011   10100   10011   1111111111101000 (2's coplement)
    //  |         |         |         | 
    // 10987654321098765432109876543210
    // 10001110100100111111111111101000
    // 32'h8E93FFE8
    @(posedge clk)
    instr = 32'h8E93FFE8;

    $display ("TEST: add");
    // add $t0, $s4, $s5
    // add 0d8, 0d20, 0d21
    // op       rs      rt      rd      shamt   funct
    // 0d0      0d20    0d21    0d8     0d0     0d32
    // 000000   10100   10101   01000   00000   100000
    // 00000010100101010100000000100000
    @(posedge clk)
    instr = 32'h2954020;
     
    @(posedge clk);


    //--------------------------------------------------------------------------

    #400
    $display("done");
    $stop;   // end of simulation
  end

endmodule
