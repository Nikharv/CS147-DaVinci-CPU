// Name: mult.v
// Module: MULT32 , MULT32_U
//
// Output: HI: 32 higher bits
//         LO: 32 lower bits
//         
//
// Input: A : 32-bit input
//        B : 32-bit input
//
// Notes: 32-bit multiplication
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

// 32-bit buffer
module BUF32_1x1(Y,A);
//output 
output [31:0] Y;
//input
input [31:0] A;

// TBD

genvar i; 

generate
	for (i=0; i<32; i=i+1) 
	begin : buf32_gen_loop
		buf buf_inst(Y[i], A[i]);
	end
endgenerate

endmodule

module BUF64_1x1(Y,A);
//output 
output [63:0] Y;
//input
input [63:0] A;

// TBD

genvar i; 

generate
	for (i=0; i<64; i=i+1) 
	begin : buf64_gen_loop
		buf buf_inst(Y[i], A[i]);
	end
endgenerate

endmodule

module MUX64_2x1(Y, I0, I1, S);
// output list
output [63:0] Y;
//input list
input [63:0] I0;
input [63:0] I1;
input S;

// TBD

genvar i; 

generate
	for (i=0; i<64; i=i+1) 
	begin : mux64_gen_loop
		MUX1_2x1 mux1_2X1_inst(Y[i], I0[i], I1[i], S);
	end
endgenerate

endmodule

module MULT32(HI, LO, A, B);
// output list
output [31:0] HI;
output [31:0] LO;
// input list
input [31:0] A;
input [31:0] B;

// TBD

wire [31:0] A_comp;
wire [31:0] B_comp;
wire [31:0] A_mux;
wire [31:0] B_mux;
wire XOR;
wire [31:0] unsign_HI;
wire [31:0] unsign_LO;
wire [63:0] mux64_unsign;
wire [63:0] mux64_sign;
wire [63:0] mux64_prod;

TWOSCOMP32 complement1_inst(A_comp, A);
TWOSCOMP32 complement2_inst(B_comp, B);

MUX32_2x1 mux32_inst1(A_mux, A, A_comp, A[31]);
MUX32_2x1 mux32_inst2(B_mux,  B, B_comp, B[31]);

MULT32_U multiU_inst(unsign_HI, unsign_LO, A_mux, B_mux);
xor xor_inst(XOR, A[31], B[31]);
BUF64_1x1 buf64_inst1(mux64_unsign, {unsign_HI, unsign_LO});

TWOSCOMP64 compl64_inst(mux64_sign, mux64_unsign);
MUX64_2x1 mux64_inst(mux64_prod, mux64_unsign, mux64_sign, XOR);


BUF32_1x1 buf32_inst3(LO, mux64_prod[31:0]);
BUF32_1x1 buf32_inst2(HI, mux64_prod[63:32]);
endmodule

module MULT32_U(HI, LO, A, B);
// output list
output [31:0] HI;
output [31:0] LO;
// input list
input [31:0] A; // MCND
input [31:0] B; // MPLR

// TBD
wire [31:0] left_addr [31:0];
wire [31:0] CO_WIRE;
genvar i;

AND32_2x1 and32_inst1(left_addr[0], A, {32{B[0]}});
buf buf_inst1(LO[0], left_addr[0][0]);
buf buf_inst3(CO_WIRE[0], 1'b0);

generate
for(i = 1; i < 32; i=i+1)
begin
	wire [31:0] right_addr;
	AND32_2x1 and32_inst(right_addr, A, {32{B[i]}});
	RC_ADD_SUB_32 addsub_inst(left_addr[i], CO_WIRE[i], right_addr,{CO_WIRE[i-1], left_addr[i-1][31:1]}, 1'b0);
	buf buf_inst2(LO[i], left_addr[i][0]);
end
endgenerate

BUF32_1x1 buf32_inst1(HI, {CO_WIRE[31], left_addr[31][31:1]});

endmodule
