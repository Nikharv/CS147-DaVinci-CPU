// Name: barrel_shifter.v
// Module: SHIFT32_L , SHIFT32_R, SHIFT32
//
// Notes: 32-bit barrel shifter
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

// 32-bit shift amount shifter
module SHIFT32(Y,D,S, LnR);
// output list
output [31:0] Y;
// input list
input [31:0] D;
input [31:0] S;
input LnR;

// TBD

wire [31:0] BARREL_OUT;
wire OR_S_out;
wire [27:0] OR_wire_res;
genvar i; 

generate
	or or_inst1(OR_wire_res[0], S[5], S[6]);

	for (i=1; i<28; i=i+1)
	begin : for_gen_loop_OR
		or or_inst2(OR_wire_res[i], S[i+5], OR_wire_res[i-1]);
	end

	buf buf_inst1(OR_S_out, OR_wire_res[26]);
endgenerate


BARREL_SHIFTER32 barrel_shifter32_inst(BARREL_OUT, D, S[4:0], LnR);
MUX32_2x1 mux32_inst(Y, BARREL_OUT, 32'b0, OR_S_out);

endmodule

// Shift with control L or R shift
module BARREL_SHIFTER32(Y,D,S, LnR);
// output list
output [31:0] Y;
// input list
input [31:0] D;
input [4:0] S;
input LnR;

// TBD
wire [31:0] RIGHT_OUT;
wire [31:0] LEFT_OUT;

SHIFT32_R shiftR32_inst(RIGHT_OUT, D, S);
SHIFT32_L shiftL32_inst(LEFT_OUT, D, S);
MUX32_2x1 mux32_inst(Y, RIGHT_OUT, LEFT_OUT, LnR);

endmodule

// Right shifter
module SHIFT32_R(Y,D,S);
// output list
output [31:0] Y;
// input list
input [31:0] D;
input [4:0] S;

// TBD

wire [31:0] B1_OUT;
wire [31:0] B2_OUT;
wire [31:0] B3_OUT;
wire [31:0] B4_OUT;

genvar i; 

generate
	for (i=0; i<32; i=i+1) 
	begin : Right_shifter32_gen_loop_S0
		if (i == 31) begin MUX1_2x1 mux1_2X1_inst1(B1_OUT[i], D[i], 1'b0, S[0]); end
		else MUX1_2x1 mux1_2X1_inst2(B1_OUT[i], D[i], D[i+1], S[0]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Right_shifter32_gen_loop_S1
		if (i > 29) begin MUX1_2x1 mux1_2X1_inst3(B2_OUT[i], B1_OUT[i], 1'b0, S[1]); end
		else MUX1_2x1 mux1_2X1_inst4(B2_OUT[i], B1_OUT[i], B1_OUT[i+2], S[1]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Right_shifter32_gen_loop_S2
		if (i > 27) begin MUX1_2x1 mux1_2X1_inst5(B3_OUT[i], B2_OUT[i], 1'b0, S[2]); end
		else MUX1_2x1 mux1_2X1_inst6(B3_OUT[i], B2_OUT[i], B2_OUT[i+4], S[2]); begin end
	end

	for (i=0; i<32; i=i+1)
	begin : Right_shifter32_gen_loop_S3
		if (i > 23) begin MUX1_2x1 mux1_2X1_inst7(B4_OUT[i], B3_OUT[i], 1'b0, S[3]); end
		else MUX1_2x1 mux1_2X1_inst8(B4_OUT[i], B3_OUT[i], B3_OUT[i+8], S[3]); begin end
	end
 
	for (i=0; i<32; i=i+1)
	begin : Right_shifter32_gen_loop_S4
		if (i > 15) begin MUX1_2x1 mux1_2X1_inst9(Y[i], B4_OUT[i], 1'b0, S[4]); end
		else MUX1_2x1 mux1_2X1_inst10(Y[i], B4_OUT[i], B4_OUT[i+16], S[4]); begin end
	end
endgenerate

endmodule

// Left shifter
module SHIFT32_L(Y,D,S);
// output list
output [31:0] Y;
// input list
input [31:0] D;
input [4:0] S;

// TBD

wire [31:0] B1_OUT;
wire [31:0] B2_OUT;
wire [31:0] B3_OUT;
wire [31:0] B4_OUT;

genvar i; 

generate
	for (i=0; i<32; i=i+1) 
	begin : Left_shifter32_gen_loop_S0
		if (i == 0) begin MUX1_2x1 mux1_2X1_inst11(B1_OUT[i], D[i], 1'b0, S[0]); end
		else MUX1_2x1 mux1_2X1_inst12(B1_OUT[i], D[i], D[i-1], S[0]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Left_shifter32_gen_loop_S1
		if (i < 2) begin MUX1_2x1 mux1_2X1_inst13(B2_OUT[i], B1_OUT[i], 1'b0, S[1]); end
		else MUX1_2x1 mux1_2X1_inst14(B2_OUT[i], B1_OUT[i], B1_OUT[i-2], S[1]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Left_shifter32_gen_loop_S2
		if (i < 4) begin MUX1_2x1 mux1_2X1_inst15(B3_OUT[i], B2_OUT[i], 1'b0, S[2]); end
		else MUX1_2x1 mux1_2X1_inst16(B3_OUT[i], B2_OUT[i], B2_OUT[i-4], S[2]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Left_shifter32_gen_loop_S3
		if (i < 8) begin MUX1_2x1 mux1_2X1_inst17(B4_OUT[i], B3_OUT[i], 1'b0, S[3]); end
		else MUX1_2x1 mux1_2X1_inst18(B4_OUT[i], B3_OUT[i], B3_OUT[i-8], S[3]); begin end
	end

	for (i=0; i<32; i=i+1) 
	begin : Left_shifter32_gen_loop_S4
		if (i < 16) begin MUX1_2x1 mux1_2X1_inst19(Y[i], B4_OUT[i], 1'b0, S[4]); end
		else MUX1_2x1 mux1_2X1_inst20(Y[i], B4_OUT[i], B4_OUT[i-16], S[4]); begin end
	end
endgenerate

endmodule

