// Name: logic.v
// Module: 
// Input: 
// Output: 
//
// Notes: Common definitions
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 02, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
// 64-bit two's complement
module TWOSCOMP64(Y,A);
//output list
output [63:0] Y;
//input list
input [63:0] A;

// TBD

wire [63:0] INV_A;
wire [63:0] CO_OUT;

genvar i; 

generate
	for (i=0; i< 64; i=i+1) 
	begin : two_comp_gen_loop
		not invA_inst(INV_A[i], A[i]);

		if(i == 0) begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], INV_A[i], 1'b0, 1'b1);
		end
		else begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], INV_A[i], 1'b0, CO_OUT[i-1]);
		end
		
	end
endgenerate

endmodule

// 32-bit two's complement
module TWOSCOMP32(Y,A);
//output list
output [31:0] Y;
//input list
input [31:0] A;

// TBD

wire [31:0] INV_A;
wire [31:0] CO_OUT;

genvar i; 

generate
	for (i=0; i< 32; i=i+1) 
	begin : two_comp_gen_loop
		not invA_inst(INV_A[i], A[i]);

		if(i == 0) begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], INV_A[i], 1'b0, 1'b1);
		end
		else begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], INV_A[i], 1'b0, CO_OUT[i-1]);
		end
		
	end
endgenerate

endmodule

// 32-bit registere +ve edge, Reset on RESET=0
module REG32(Q, D, LOAD, CLK, RESET);
output [31:0] Q;

input CLK, LOAD;
input [31:0] D;
input RESET;

// TBD
wire [31:0] Qbar;
wire clock_INV;


genvar i; 

generate
	for (i=0; i<32; i=i+1) 
	begin : reg32_gen_loop
		REG1 REG1_inst(Q[i], Qbar[i], D[i], LOAD, CLK, 1'b1, RESET);
	end
endgenerate

endmodule

// 1 bit register +ve edge, 
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module REG1(Q, Qbar, D, L, C, nP, nR);
input D, C, L;
input nP, nR;
output Q,Qbar;

// TBD
wire mux1_2x1_out;

MUX1_2x1 MUX1_2x1_inst1(mux1_2x1_out, Q, D, L);
D_FF D_FF_inst1(Q, Qbar, mux1_2x1_out, C, nP, nR);


endmodule

// 1 bit flipflop +ve edge, 
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module D_FF(Q, Qbar, D, C, nP, nR);
input D, C;
input nP, nR;
output Q,Qbar;

// TBD

wire D_LATCH_Q;
wire D_LATCH_Qbar;
wire clock_INV;

not not_inst1(clock_INV, C);

D_LATCH D_LATCH_inst1(D_LATCH_Q, D_LATCH_Qbar, D, clock_INV, nP, nR);
SR_LATCH SR_LATCH_inst1(Q,Qbar, D_LATCH_Q, D_LATCH_Qbar, C, nP, nR);

endmodule

// 1 bit D latch
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module D_LATCH(Q, Qbar, D, C, nP, nR);
input D, C;
input nP, nR;
output Q,Qbar;

// TBD

wire nand_out1;
wire nand_out3;
wire D_INV_out;

not not_inst2(D_INV_out, D);
nand nand_inst1(nand_out1, D, C);
nand nand_inst3(nand_out3, D_INV_out, C);
nand nand_inst2(Q, nP, nand_out1, Qbar);
nand nand_inst4(Qbar, nR, nand_out3, Q);

endmodule

// 1 bit SR latch
// Preset on nP=0, nR=1, reset on nP=1, nR=0;
// Undefined nP=0, nR=0
// normal operation nP=1, nR=1
module SR_LATCH(Q,Qbar, S, R, C, nP, nR);
input S, R, C;
input nP, nR;
output Q,Qbar;

// TBD

wire nand_out1;
wire nand_out3;

nand nand_inst1(nand_out1, S, C);
nand nand_inst3(nand_out3, R, C);
nand nand_inst2(Q, nand_out1, nP, Qbar);
nand nand_inst4(Qbar, nand_out3, nR, Q);

endmodule

// 5x32 Line decoder
module DECODER_5x32(D,I);
// output
output [31:0] D;
// input
input [4:0] I;

// TBD

wire [15:0] decoder_4x16_out;
wire not_I4;

DECODER_4x16 decoder_4x16_inst(decoder_4x16_out, I[3:0]);
not not_inst1(not_I4, I[4]);

genvar i; 

generate
	for (i=0; i<16; i=i+1) 
	begin : decoder_5x32_gen_loop

		and and_inst1(D[i], not_I4, decoder_4x16_out[i]);
		and and_inst2(D[i+16], I[4], decoder_4x16_out[i]);
	end
endgenerate

endmodule

// 4x16 Line decoder
module DECODER_4x16(D,I);
// output
output [15:0] D;
// input
input [3:0] I;

// TBD

wire [7:0] decoder_3x8_out;
wire not_I3;

DECODER_3x8 decoder_3x8_inst(decoder_3x8_out, I[2:0]);
not not_inst1(not_I3, I[3]);

genvar i; 

generate
	for (i=0; i<8; i=i+1) 
	begin : decoder_4x16_gen_loop

		and and_inst1(D[i], not_I3, decoder_3x8_out[i]);
		and and_inst2(D[i+8], I[3], decoder_3x8_out[i]);
	end
endgenerate


endmodule

// 3x8 Line decoder
module DECODER_3x8(D,I);
// output
output [7:0] D;
// input
input [2:0] I;

//TBD

wire [3:0] decoder_2x4_out;
wire not_I2;

DECODER_2x4 decoder_2x4_inst(decoder_2x4_out, I[1:0]);

not not_inst1(not_I2, I[2]);

genvar i; 

generate
	for (i=0; i<4; i=i+1) 
	begin : decoder_2x4_gen_loop

		and and_inst1(D[i], not_I2, decoder_2x4_out[i]);
		and and_inst2(D[i+4], I[2], decoder_2x4_out[i]);
	end
endgenerate

endmodule

// 2x4 Line decoder
module DECODER_2x4(D,I);
// output
output [3:0] D;
// input
input [1:0] I;

// TBD

wire not_I0;
wire not_I1;


not not_inst1(not_I0, I[0]);
not not_inst2(not_I1, I[1]);

and and_inst1(D[0], not_I0, not_I1);
and and_inst2(D[1], not_I1, I[0]);
and and_inst3(D[2], not_I0, I[1]);
and and_inst4(D[3], I[0], I[1]);

endmodule
