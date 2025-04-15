// Name: data_path.v
// Module: DATA_PATH
// Output:  DATA : Data to be written at address ADDR
//          ADDR : Address of the memory location to be accessed
//
// Input:   DATA : Data read out in the read operation
//          CLK  : Clock signal
//          RST  : Reset signal
//
// Notes: - 32 bit processor implementing cs147sec05 instruction set
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"
module DATA_PATH(DATA_OUT, ADDR, ZERO, INSTRUCTION, DATA_IN, CTRL, CLK, RST);

// output list
output [`ADDRESS_INDEX_LIMIT:0] ADDR;
output ZERO;
output [`DATA_INDEX_LIMIT:0] DATA_OUT, INSTRUCTION;

// input list
input [`CTRL_WIDTH_INDEX_LIMIT:0]  CTRL;
input CLK, RST;
input [`DATA_INDEX_LIMIT:0] DATA_IN;

wire no_carry_out;
wire [31:0] rs_select_mux_output;
wire [31:0] write_addr_select_1_mux_output;
wire [31:0] write_addr_select_2_mux_output;
wire [31:0] write_addr_select_3_mux_output;
wire [31:0] operand_1_select_mux_output;
wire [31:0] operand_2_select_1_mux_output;
wire [31:0] operand_2_select_2_mux_output;
wire [31:0] operand_2_select_3_mux_output;
wire [31:0] operand_2_select_4_mux_output;
wire [31:0] stack_pointer_output;
wire [31:0] program_counter_output;
wire [31:0] alu_output;
wire [31:0] instruction_output;
wire [31:0] read_register_1_data_output;
wire [31:0] read_register_2_data_output;
wire [31:0] write_data_select_1_mux_output;
wire [31:0] write_data_select_2_mux_output;
wire [31:0] write_data_select_3_mux_output;
wire [31:0] memory_data_select_1_mux_output;
wire [31:0] memory_addr_select_1_mux_output;
wire [31:0] memory_addr_select_2_mux_output;
wire [31:0] pc_select_1_mux_output;
wire [31:0] pc_select_2_mux_output;
wire [31:0] pc_select_3_mux_output;
wire [31:0] pc_increment_adder_output;
wire [31:0] pc_increment_plus_sign_extended_imm_output;

// Increment PC by 1
RC_ADD_SUB_32 pc_increment_adder(
    .Y(pc_increment_adder_output), 
    .CO(no_carry_out), 
    .A(program_counter_output), 
    .B(32'b1), 
    .SnA(1'b0)
);

// Incremented PC + sign extended 16 bit immediate
RC_ADD_SUB_32 pc_increment_plus_sign_ext_imm_adder(
    .Y(pc_increment_plus_sign_extended_imm_output),
    .CO(no_carry_out),
    .A(pc_increment_adder_output),
    .B({{16{instruction_output[15]}}, instruction_output[15:0]}),
    .SnA(1'b0)
);

// Program Counter
defparam program_counter.PATTERN = `INST_START_ADDR;
REG32_PP program_counter(
    .Q(program_counter_output),
    .D(pc_select_3_mux_output),
    .LOAD(CTRL[0]),
    .CLK(CLK),
    .RESET(RST)
);

// Select between R1 data and PC+1
MUX32_2x1 select_between_r1_and_pc_increment(
    .Y(pc_select_1_mux_output),
    .I0(read_register_1_data_output),
    .I1(pc_increment_adder_output),
    .S(CTRL[1])
);

// Select between pc_select_1 and PC+1+16-bit sign extended immediate
MUX32_2x1 select_between_pc_select_1_and_sign_extended_imm(
    .Y(pc_select_2_mux_output),
    .I0(pc_select_1_mux_output),
    .I1(pc_increment_plus_sign_extended_imm_output),
    .S(CTRL[2])
);

// Select between pc_select_2 and 6 bit zero extended address
MUX32_2x1 select_final_next_pc_address(
    .Y(pc_select_3_mux_output),
    .I0({6'b0, instruction_output[25:0]}),
    .I1(pc_select_2_mux_output),
    .S(CTRL[3])
);

// Stack Pointer
defparam stack_pointer.PATTERN = `INIT_STACK_POINTER;
REG32_PP stack_pointer(
    .Q(stack_pointer_output),
    .D(alu_output),
    .LOAD(CTRL[8]),
    .CLK(CLK),
    .RESET(RST)
);

// Sets up the instruction register
D_LATCH32 instruction_register(
    .Q(instruction_output),
    .Qbar(instruction_qbar),
    .D(DATA_IN),
    .C(CTRL[4]),
    .nR(RST)
);

// Copy the instruction from memory into the output INSTRUCTION
BUF32_1x1 instruction_copy(
    .Y(INSTRUCTION),
    .A(DATA_IN)
);

// Select between the zero extended content of the RS register or 32 zeroes.
MUX32_2x1 select_rs_or_zero(
    .Y(rs_select_mux_output),
    .I0({27'b0, instruction_output[25:21]}),
    .I1(32'd0),
    .S(CTRL[5])
);

// Select between rt and rd registers for storing the result.
MUX32_2x1 select_result_dest_reg_rt_or_rd(
    .Y(write_addr_select_1_mux_output),
    .I0({27'b0, instruction_output[15:11]}),
    .I1({27'b0, instruction_output[20:16]}),
    .S(CTRL[26])
);

// Select between registers 0 and 31 for destination.
MUX32_2x1 select_result_dest_reg_0_or_31(
    .Y(write_addr_select_2_mux_output),
    .I0(32'd0), // Register 0
    .I1(32'd31), // Register 31 (5 LSB all 1s)
    .S(CTRL[27])
);

// Select the final destination register
MUX32_2x1 select_final_result_dest_reg(
    .Y(write_addr_select_3_mux_output),
    .I0(write_addr_select_2_mux_output),
    .I1(write_addr_select_1_mux_output),
    .S(CTRL[28])
);

// Select WB data between ALU and Memory
MUX32_2x1 select_wb_data_alu_or_mem(
    .Y(write_data_select_1_mux_output),
    .I0(alu_output),
    .I1(DATA_IN),
    .S(CTRL[23])
);

// Select between registers 0 and 31 for destination.
MUX32_2x1 select_16bit_lsb_extend_imm_or_wd1(
    .Y(write_data_select_2_mux_output),
    .I0(write_data_select_1_mux_output),
    .I1({instruction_output[15:0], 16'b0}), // 16 bit immediate LSB zero extended
    .S(CTRL[24])
);

// Select the final destination register
MUX32_2x1 select_final_wb_data(
    .Y(write_data_select_3_mux_output),
    .I0(pc_increment_adder_output),
    .I1(write_data_select_2_mux_output),
    .S(CTRL[25])
);

// Set up the register file
REGISTER_FILE_32x32 register_file(
    .DATA_R1(read_register_1_data_output),
    .DATA_R2(read_register_2_data_output),
    .ADDR_R1(rs_select_mux_output[4:0]), // Either rs register or 0
    .ADDR_R2(instruction_output[20:16]), // rt register
    .DATA_W(write_data_select_3_mux_output),
    .ADDR_W(write_addr_select_3_mux_output[4:0]),
    .READ(CTRL[6]),
    .WRITE(CTRL[7]),
    .CLK(CLK),
    .RST(RST)
);

// Select between shamt and 1
MUX32_2x1 select_imm_shamt_or_1(
    .Y(operand_2_select_1_mux_output),
    .I0(32'b1),
    .I1({27'b0, instruction_output[10:6]}), // 27-bit zero extended shamt
    .S(CTRL[10])
);

// Select between sign or zero extended immediate
MUX32_2x1 select_sign_or_zero_extended_imm(
    .Y(operand_2_select_2_mux_output),
    .I0({16'b0, instruction_output[15:0]}), // 16-bit zero extended immediate
    .I1({{16{instruction_output[15]}}, instruction_output[15:0]}), // 16-bit sign extended immediate
    .S(CTRL[11])
);

// Select the final destination register
MUX32_2x1 select_final_immediate(
    .Y(operand_2_select_3_mux_output),
    .I0(operand_2_select_2_mux_output),
    .I1(operand_2_select_1_mux_output),
    .S(CTRL[12])
);

// Select ALU operand 1
MUX32_2x1 select_alu_operand1(
    .Y(operand_1_select_mux_output),
    .I0(read_register_1_data_output),
    .I1(stack_pointer_output),
    .S(CTRL[9])
);

// Select ALU operand 2
MUX32_2x1 select_alu_operand2(
    .Y(operand_2_select_4_mux_output),
    .I0(operand_2_select_3_mux_output),
    .I1(read_register_2_data_output),
    .S(CTRL[13])
);

// Select between R1 data and R2 data for memory data out
MUX32_2x1 select_mem_data_output(
    .Y(DATA_OUT),
    .I0(read_register_2_data_output),
    .I1(read_register_1_data_output),
    .S(CTRL[22])
);

// Initialize the ALU 
ALU arithmetic_logic_unit(
    .OUT(alu_output),
    .ZERO(ZERO), 
    .OP1(operand_1_select_mux_output), 
    .OP2(operand_2_select_4_mux_output), 
    .OPRN(CTRL[19:14])
);

// Select where the memory address comes out between SP and ALU output.
MUX32_2x1 select_sp_or_alu_for_mem_addr(
    .Y(memory_addr_select_1_mux_output),
    .I0(alu_output),
    .I1(stack_pointer_output),
    .S(CTRL[20])
);

BUF32_1x1 pass_next_memory_addr(
    .Y(ADDR),
    .A(memory_addr_select_2_mux_output)
);

// Select where the memory address comes out between memory_addr_select_1 and PC.
MUX32_2x1 select_memory_addr_source(
    .Y(memory_addr_select_2_mux_output),
    .I0(memory_addr_select_1_mux_output),
    .I1(program_counter_output),
    .S(CTRL[21])
);

endmodule

// Used for PC and SP. Usage as such in data path:
// PC: defparam pc_inst.PATTERN = `INST_START_ADDR;
// REG32_PP  pc_inst(.Q(pc), .D(pc_3), .LOAD(pc_load), .CLK(CLK), .RESET(RST));
//
// SP: defparam sp_inst.PATTERN = `INIT_STACK_POINTER;
// REG32_PP  sp_inst(.Q(sp), .D(alu_out), .LOAD(sp_load), .CLK(CLK), .RESET(RST));
module REG32_PP(Q, D, LOAD, CLK, RESET);
parameter PATTERN = 32'h00000000;
output [31:0] Q;

input CLK, LOAD;
input [31:0] D;
input RESET;

wire [31:0] qbar;

genvar i;
generate 
    for(i=0; i<32; i=i+1)
    begin : reg32_gen_loop
       if (PATTERN[i] == 0)
              REG1 reg_inst(.Q(Q[i]), .Qbar(qbar[i]), .D(D[i]), .L(LOAD), .C(CLK), .nP(1'b1), .nR(RESET));    
        else
              REG1 reg_inst(.Q(Q[i]), .Qbar(qbar[i]), .D(D[i]), .L(LOAD), .C(CLK), .nP(RESET), .nR(1'b1));
    end 
endgenerate

endmodule

module D_LATCH32(Q, Qbar, D, C, nR);
input [31:0] D;
input C;
input nR;

output [31:0] Q;
output [31:0] Qbar;

wire [31:0] Qbar;

genvar bit;
generate 
    for (bit = 0; bit < 32; bit = bit + 1) begin
       D_LATCH d_latch_inst(.Q(Q[bit]), .Qbar(Qbar[bit]), .D(D[bit]), .C(C), .nP(1'b1), .nR(nR));
    end 
endgenerate

endmodule

module BUF32_1x1(Y, A);
input [31:0] A; // The instruction to copy

output [31:0] Y; // Where to copy the instruction to

genvar bit;
generate
	for (bit = 0; bit < 32; bit = bit + 1) begin
		buf instruction_copy_inst(Y[bit], A[bit]);
	end
endgenerate

endmodule
