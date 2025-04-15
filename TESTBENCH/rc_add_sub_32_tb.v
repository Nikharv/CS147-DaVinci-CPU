// Name: rc_add_sub_32_tb.v
// Module: RC_ADD_SUB_32_TB
//
// Notes: - Testbench for RC adder/asubtractor
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "../prj_definition.v"

module RC_ADD_SUB_32_TB;
// driver
reg [`DATA_INDEX_LIMIT:0] A;
reg [`DATA_INDEX_LIMIT:0] B;
reg SnA;
// outputs to observe
wire CO;
wire [`DATA_INDEX_LIMIT:0] Y;

integer i;
reg [`DATA_INDEX_LIMIT:0] result[0:14];

RC_ADD_SUB_32 rc_add_sub_inst(.Y(Y), .CO(CO), .A(A), .B(B), .SnA(SnA));

initial
begin
i=0;
A=10; B=20; SnA=1'b0; // Y = 10 + 20 = 30
#1 result[i] = Y; i=i+1;
#1 A=10; B=20; SnA=1'b1; // Y = 10 - 20 = -10
#1 result[i] = Y; i=i+1;
#1 A=15; B=12; SnA=1'b1; // Y = 15 - 12 = 3
#1 result[i] = Y; i=i+1;
#1 A=0; B=4; SnA=1'b0; // Y = 0 + 4 = 4
#1 result[i] = Y; i=i+1;
#1 A=32'h00000001; B=32'h00000002; SnA=1'b0;
#1 result[i] = Y; i=i+1;
#1 A=32'hDEADBEEF; B=32'hCAFEBABE; SnA=1'b1;
#1 result[i] = Y; i=i+1;
#1 A=32'h11111111; B=32'h22222222; SnA=1'b0;
#1 result[i] = Y; i=i+1;
#1 A=32'hAAAAAAAA; B=32'h55555555; SnA=1'b1;
#1 result[i] = Y; i=i+1;
#1 A=32'h0ABCDEF0; B=32'hFEDCBA09; SnA=1'b0;
#1 result[i] = Y; i=i+1;
#1 A=32'h12345678; B=32'h9ABCDEF0; SnA=1'b1;
#1 result[i] = Y; i=i+1;
#1 A=32'h7FFFFFFF; B=32'hFFFFFFFF; SnA=1'b0;
#1 result[i] = Y; i=i+1;
#1 A=32'h0000AAAA; B=32'hAAAA0000; SnA=1'b1;
#1 result[i] = Y; i=i+1;
#1 A=32'h33333333; B=32'hCCCCCCCC; SnA=1'b0;
#1 result[i] = Y; i=i+1;
#1 A=32'h98765432; B=32'h12345678; SnA=1'b1;
#1 result[i] = Y; i=i+1;
#1 
$writememh("./OUTPUT/rc_add_sub_32.out",result);
$stop;
end

endmodule
