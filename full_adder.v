// Name: full_adder.v
// Module: FULL_ADDER
//
// Output: S : Sum
//         CO : Carry Out
//
// Input: A : Bit 1
//        B : Bit 2
//        CI : Carry In
//
// Notes: 1-bit full adder implementaiton.
// 
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "prj_definition.v"

module FULL_ADDER(S,CO,A,B, CI);
output S,CO;
input A,B, CI;

//TBD

wire OUT_Y, OUT_C1, OUT_C2;

HALF_ADDER inst1(OUT_Y, OUT_C1, A, B);

HALF_ADDER inst2(S, OUT_C2, OUT_Y, CI);

xor inst3(CO, OUT_C2, OUT_C1);
 



endmodule;
