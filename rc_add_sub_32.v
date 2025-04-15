// Name: rc_add_sub_32.v
// Module: RC_ADD_SUB_32
//
// Output: Y : Output 32-bit
//         CO : Carry Out
//         
//
// Input: A : 32-bit input
//        B : 32-bit input
//        SnA : if SnA=0 it is add, subtraction otherwise
//
// Notes: 32-bit adder / subtractor implementaiton.
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

module RC_ADD_SUB_64(Y, CO, A, B, SnA);
// output list
output [63:0] Y;
output CO;
// input list
input [63:0] A;
input [63:0] B;
input SnA;

// TBD

wire [63:0] xorB;
wire [63:0] CO_OUT;

genvar i; 

generate
	for (i=0; i<= 63; i=i+1) 
	begin : xorB_gen_loop
		xor xorB_inst(xorB[i], SnA, B[i]);
		if(i == 0) begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], A[i], xorB[i], SnA);
		end
		else begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], A[i], xorB[i], CO_OUT[i-1]);
		end
		
	end
endgenerate


buf buf_inst(CO, CO_OUT[63]);

endmodule

module RC_ADD_SUB_32(Y, CO, A, B, SnA);
// output list
output [`DATA_INDEX_LIMIT:0] Y;
output CO;
// input list
input [`DATA_INDEX_LIMIT:0] A;
input [`DATA_INDEX_LIMIT:0] B;
input SnA;

// TBD

wire [31:0] xorB; 
wire [31:0] CO_OUT;

genvar i; 

generate
	for (i=0; i < 32; i=i+1) 
	begin : xorB_gen_loop
		xor xorB_inst(xorB[i], SnA, B[i]);
		if(i == 0) begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], A[i], xorB[i], SnA);
		end
		else begin
			FULL_ADDER full_addr_inst(Y[i], CO_OUT[i], A[i], xorB[i], CO_OUT[i-1]);
		end
		
	end
endgenerate


buf buf_inst(CO, CO_OUT[31]);

endmodule

