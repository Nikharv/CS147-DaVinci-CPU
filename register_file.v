// Name: register_file.v
// Module: REGISTER_FILE_32x32
// Input:  DATA_W : Data to be written at address ADDR_W
//         ADDR_W : Address of the memory location to be written
//         ADDR_R1 : Address of the memory location to be read for DATA_R1
//         ADDR_R2 : Address of the memory location to be read for DATA_R2
//         READ    : Read signal
//         WRITE   : Write signal
//         CLK     : Clock signal
//         RST     : Reset signal
// Output: DATA_R1 : Data at ADDR_R1 address
//         DATA_R2 : Data at ADDR_R1 address
//
// Notes: - 32 bit word accessible dual read register file having 32 regsisters.
//        - Reset is done at -ve edge of the RST signal
//        - Rest of the operation is done at the +ve edge of the CLK signal
//        - Read operation is done if READ=1 and WRITE=0
//        - Write operation is done if WRITE=1 and READ=0
//        - X is the value at DATA_R* if both READ and WRITE are 0 or 1
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
//
`include "prj_definition.v"

// This is going to be +ve edge clock triggered register file.
// Reset on RST=0
module REGISTER_FILE_32x32(DATA_R1, DATA_R2, ADDR_R1, ADDR_R2, 
                            DATA_W, ADDR_W, READ, WRITE, CLK, RST);

// input list
input READ, WRITE, CLK, RST;
input [`DATA_INDEX_LIMIT:0] DATA_W;
input [`REG_ADDR_INDEX_LIMIT:0] ADDR_R1, ADDR_R2, ADDR_W;

// output list
output [`DATA_INDEX_LIMIT:0] DATA_R1;
output [`DATA_INDEX_LIMIT:0] DATA_R2;

// TBD

wire [31:0] decoder_5x32_out;
wire [31:0] decoder_and_out;
wire [31:0] reg_32_out [31:0];
wire [31:0] mux_R1_addr_out;
wire [31:0] mux_R2_addr_out;

DECODER_5x32 decoder_5x32_inst(decoder_5x32_out, ADDR_W);

genvar i; 

generate
	for (i=0; i<32; i=i+1) 
	begin : decoder_and_out_gen_loop
		and and_inst(decoder_and_out[i], decoder_5x32_out[i], WRITE);
	end

	for (i=0; i<32; i=i+1) 
	begin : reg_32_out_gen_loop
		REG32 reg_32_inst(reg_32_out[i], DATA_W, decoder_and_out[i], CLK, RST);
	end
endgenerate

MUX32_32x1 mux_32x1_inst1(mux_R1_addr_out, reg_32_out[0], reg_32_out[1], reg_32_out[2], reg_32_out[3], 
						reg_32_out[4], reg_32_out[5], reg_32_out[6], reg_32_out[7], 
						reg_32_out[8], reg_32_out[9], reg_32_out[10], reg_32_out[11], 
						reg_32_out[12], reg_32_out[13], reg_32_out[14], reg_32_out[15], 
						reg_32_out[16], reg_32_out[17], reg_32_out[18], reg_32_out[19], 
						reg_32_out[20], reg_32_out[21], reg_32_out[22], reg_32_out[23], 
						reg_32_out[24], reg_32_out[25], reg_32_out[26], reg_32_out[27], 
						reg_32_out[28], reg_32_out[29], reg_32_out[30], reg_32_out[31], 
						ADDR_R1);

MUX32_32x1 mux_32x1_inst2(mux_R2_addr_out, reg_32_out[0], reg_32_out[1], reg_32_out[2], reg_32_out[3], 
						reg_32_out[4], reg_32_out[5], reg_32_out[6], reg_32_out[7], 
						reg_32_out[8], reg_32_out[9], reg_32_out[10], reg_32_out[11], 
						reg_32_out[12], reg_32_out[13], reg_32_out[14], reg_32_out[15], 
						reg_32_out[16], reg_32_out[17], reg_32_out[18], reg_32_out[19], 
						reg_32_out[20], reg_32_out[21], reg_32_out[22], reg_32_out[23], 
						reg_32_out[24], reg_32_out[25], reg_32_out[26], reg_32_out[27], 
						reg_32_out[28], reg_32_out[29], reg_32_out[30], reg_32_out[31], 
						ADDR_R2);

MUX32_2x1 mux_2x1_inst1(DATA_R1, 32'bz, mux_R1_addr_out, READ);
MUX32_2x1 mux_2x1_inst2(DATA_R2, 32'bz, mux_R2_addr_out, READ);


endmodule
