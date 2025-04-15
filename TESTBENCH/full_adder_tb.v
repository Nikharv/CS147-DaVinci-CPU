// Name: full_adder_tb.v
// Module: FULL_ADDER_TB
//
// Notes: - Testbench for full adder
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
`include "../prj_definition.v"

module FULL_ADDER_TB;
reg A, B, CI;
wire S, CO;

reg [`DATA_INDEX_LIMIT:0] result[0:17];

integer i;

FULL_ADDER fa_inst(.S(S), .CO(CO), .A(A), .B(B), .CI(CI));

initial
begin
A=0; B=0; CI=0;
#1 result[0] = 32'h00000000 | {CO,S};

for(i=1; i<8; i=i+1) 
begin
#1 CI=i[2]; A=i[1]; B=i[0];
#1 result[i] = 32'h00000000 | {CO,S};
end

#1 CI=0; A=0; B=1;
#1 result[8] = 32'h00000000 | {CO,S};

#1 CI=1; A=0; B=0;
#1 result[9] = 32'h00000000 | {CO,S};

#1 CI=1; A=1; B=1;
#1 result[10] = 32'h00000000 | {CO,S};

#1 CI=0; A=1; B=0;
#1 result[11] = 32'h00000000 | {CO,S};

#1 CI=1; A=1; B=0;
#1 result[12] = 32'h00000000 | {CO,S};

#1 CI=0; A=0; B=0;
#1 result[13] = 32'h00000000 | {CO,S};

#1 CI=1; A=0; B=1;
#1 result[14] = 32'h00000000 | {CO,S};

#1 CI=0; A=1; B=1;
#1 result[15] = 32'h00000000 | {CO,S};

#1 CI=0; A=1; B=0;
#1 result[16] = 32'h00000000 | {CO,S};

#1 CI=1; A=0; B=0;
#1 result[17] = 32'h00000000 | {CO,S};

#1 
$writememh("./OUTPUT/full_adder.out",result);
$stop;

end
endmodule
