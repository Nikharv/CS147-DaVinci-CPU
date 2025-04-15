// Name: alu.v
// Module: ALU
// Input: OP1[32] - operand 1
//        OP2[32] - operand 2
//        OPRN[6] - operation code
// Output: OUT[32] - output result for the operation
//
// Notes: 32 bit combinatorial ALU
// 
// Supports the following functions
//	- Integer add (0x1), sub(0x2), mul(0x3)
//	- Integer shift_rigth (0x4), shift_left (0x5)
//	- Bitwise and (0x6), or (0x7), nor (0x8)
//  - set less than (0x9)
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"
module ALU(OUT, ZERO, OP1, OP2, OPRN);
// input list
input [`DATA_INDEX_LIMIT:0] OP1; // operand 1
input [`DATA_INDEX_LIMIT:0] OP2; // operand 2
input [`ALU_OPRN_INDEX_LIMIT:0] OPRN; // operation code

// output list
output [`DATA_INDEX_LIMIT:0] OUT; // result of the operation.
output ZERO;

// TBD

wire and_OPRN;
wire or_OPRN;
wire not_OPRN;


wire [31:0] AND_out;
wire [31:0] OR_out;
wire [31:0] NOR_out;
wire [31:0] ADD_SUB_out;
wire [31:0] SHFT_out;
wire [31:0] MUL_out_LO;
wire [31:0] MUL_out_HI;
wire [31:0] MUX_out;
wire rc_add_sub_CO_WIRE;
wire [31:0] shift32_out;

and and_inst1(and_OPRN, OPRN[0], OPRN[3]);
not not_inst1(not_OPRN, OPRN[0]);
or or_inst1(or_OPRN, not_OPRN, and_OPRN);

AND32_2x1 and32_inst1(AND_out, OP1, OP2);
OR32_2x1 or32_inst1(OR_out, OP1, OP2);
NOR32_2x1 nor32_inst1(NOR_out, OP1, OP2);

RC_ADD_SUB_32 rc_add_sub_inst1(ADD_SUB_out, rc_add_sub_CO_WIRE, OP1, OP2, or_OPRN);

SHIFT32 shift32_inst1(shift32_out, OP1, OP2, OPRN[0]);

MULT32 mult32_inst1(MUL_out_HI, MUL_out_LO, OP1, OP2);

MUX32_16x1 mux32_inst1(OUT, 32'b0, ADD_SUB_out, ADD_SUB_out, MUL_out_LO, shift32_out, shift32_out, AND_out, OR_out, NOR_out, {31'b0, ADD_SUB_out[31]}, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, OPRN);

wire OR_S_out;
wire [31:0] OR_wire_res;
genvar i; 

generate
	or or_inst2(OR_wire_res[0], OUT[0], OUT[1]);

	for (i = 1; i < 32; i = i + 1)
    begin : for_gen_loop_OR
        or or_inst3(OR_wire_res[i], OUT[i + 1], OR_wire_res[i - 1]);
    end

	not not_inst2(ZERO, OR_wire_res[30]);
endgenerate


endmodule
