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
  reg [DATA_WIDTH_P-1:0] mem_rd_data;
  wire mem_wr_en;
  wire [DATA_ADDR_WIDTH_P-1:0] mem_addr;
  wire [DATA_WIDTH_P-1:0] mem_wr_data;

  reg [DATA_WIDTH_P-1:0] data_memory [0:255];
  
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

  always @(data_memory,mem_addr) begin
    if (mem_wr_en) begin
      data_memory[mem_addr] = mem_wr_data;
    end else begin
      mem_rd_data = data_memory[mem_addr];
    end;
  end

  initial begin
    #period
    //--------------------------------------------------------------------------
    // # Test the MIPS processor.
    //      add, sub, and, or, slt, addi, lw, sw, beq, j
    //      If successful, it should write the value 7 to address 84
    // # mipstest.asm
    // # David_Harris@hmc.edu 9 November 2005
    //-------------------------------------------------------------------------
    @(posedge clk)
    instr = 32'h20020005; // main:   addi  $2, $0, 5              initialize $2 = 5
    @(posedge clk)
    instr = 32'h2003000c; //         addi  $3, $0, 12             initialize $3 = 12
    @(posedge clk)
    instr = 32'h2067fff7; //         addi  $7, $3, -9             initialize $7 = 3
    @(posedge clk)
    instr = 32'h00e22025; //         or    $4, $7, $2             $4 <= 3 or 5 = 7
    @(posedge clk)
    instr = 32'h00642824; //         and   $5, $3, $4             $5 <= 12 and 7 = 4
    @(posedge clk)
    instr = 32'h00a42820; //         add   $5, $5, $4             $5 = 4 + 7 < 11
    @(posedge clk)
    instr = 32'h10a7000a; //         beq   $5, $7, end            shouldn’t be taken
    @(posedge clk)
    instr = 32'h0064202a; //         slt   $4, $3, $4             $4 = 12 < 7 = 0
    @(posedge clk)
    instr = 32'h10800001; //         beq   $4, $0, around         should be taken
    @(posedge clk)
    instr = 32'h20050000; //         addi  $5, $0, 0              shouldn’t happen  
    @(posedge clk)
    instr = 32'h00e2202a; // around: slt   $4, $7, $2             $4 = 3 < 5 = 1    
    @(posedge clk)
    instr = 32'h00853820; //         add   $7, $4, $5             $7 = 1 + 11 = 12  
    @(posedge clk)
    instr = 32'h00e23822; //         sub   $7, $7, $2             $7 = 12 - 5 = 7   
    @(posedge clk)
    instr = 32'hac670044; //         sw    $7, 68($3)             [80] = 7          
    @(posedge clk)
    instr = 32'h8c020050; //         lw    $2, 80($0)             $2 = [80] = 7     
    @(posedge clk)
    instr = 32'h08000011; //         j     end                    should be taken   
    @(posedge clk)
    instr = 32'h20020001; //         addi  $2, $0, 1              shouldn’t happen  
    @(posedge clk)
    instr = 32'hac020054; // end:    sw    $2, 84($0)             write adr 84 = 7  

    //--------------------------------------------------------------------------

    #400
    $display("done");
    $stop;   // end of simulation
  end

endmodule
