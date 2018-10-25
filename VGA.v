module VGA (	input clk,	 				//clock from FPGA – 50MHz
					input mode,					//selects the resolution we want the image to be displayed on 
														//(800 X 600 or 640 X 480)
					input rst, 
					output [10:0] xpos, 		//horizontal position
					output [10:0] ypos,		//vertical position
					output disp_active,		//synchronization signal that indicates if the displayed pixel is in the 
														//active area of the display or in the back or front porch
					output [7:0] R, G, B,	//4 bit output for the red, green and blue pixel which dictates the color 
														//of the displayed object
					output hsync, 				//horizontal sync – it activates after the active and the front porch areas 
														//of pixels were displayed horizontally and stays active until it reaches 
														//the back porch area
					output vsync,				//vertical sync – it activates after the active and the front porch areas 
														//of pixels were displayed vertically and stays active until it reaches the 
														//back porch area
					//output hsync_neg, 		//to be removed; has the same functionality as hsync, but it functions in 
														//direct logic
					//output vsync_neg,			//to be removed; has the same functionality as vsync, but it functions in 
														//direct logic
					input clk_fft_l,
					input clk_fft_r,
				input [15:0] source_real_l,
				input [15:0] source_imag_l,
				input [15:0] source_real_r,
				input [15:0] source_imag_r,
				input source_ready_l,
				input source_valid_l,
				input source_sop_l,
				input source_eop_l,
				input source_ready_r,
				input source_valid_r,
				input source_sop_r,
				input source_eop_r,
				input source_real_l_div,
				input source_real_r_div,
				input source_imag_l_div,
				input source_imag_r_div
					);

/////////////LOCAL REGISTERS////////////////					
reg [10:0] vertical, horizontal;

/*reg [15:0] memorie_real_l [0:127];
reg [15:0] memorie_imag_l [0:127];
reg [15:0] memorie_real_r [0:127];
reg [15:0] memorie_imag_r [0:127];*/
reg [15:0] memorie_real_l_out [0:127];
reg [15:0] memorie_imag_l_out [0:127];
reg [15:0] memorie_real_r_out [0:127];
reg [15:0] memorie_imag_r_out [0:127];

reg [13:0] counter_l=0, counter_r=0;			//counts the number of samples sent by fft, total of 128 in a frame
reg full_load_l, full_load_r;
//wire [31:0] step_calc;

localparam [2:0] step = 4;
reg [10:0] i = 0;
reg [7:0] R_set = 8'b0101_0000;
reg [7:0] G_set = 8'b1001_0000;
reg [7:0] B_set = 8'b1101_0000;
localparam [10:0] start = 1;
localparam [10:0] fin = 3;

wire [7:0] R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, 
				R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31, R32, R33, R34, R35, R36, R37, R38, R39, R40, 
				R41, R42, R43, R44, R45, R46, R47, R48, R49, R50, R51, R52, R53, R54, R55, R56, R57, R58, R59, R60,
				R61, R62, R63, R64, R65;
wire [7:0] G1, G2, G3, G4, G5, G6, G7, G8, G9, G10, G11, G12, G13, G14, G15, G16, G17, G18, G19, G20, 
				G21, G22, G23, G24, G25, G26, G27, G28, G29, G30, G31, G32, G33, G34, G35, G36, G37, G38, G39, G40, 
				G41, G42, G43, G44, G45, G46, G47, G48, G49, G50, G51, G52, G53, G54, G55, G56, G57, G58, G59, G60,
				G61, G62, G63, G64, G65;
wire [7:0] B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, B11, B12, B13, B14, B15, B16, B17, B18, B19, B20, 
				B21, B22, B23, B24, B25, B26, B27, B28, B29, B30, B31, B32, B33, B34, B35, B36, B37, B38, B39, B40, 
				B41, B42, B43, B44, B45, B46, B47, B48, B49, B50, B51, B52, B53, B54, B55, B56, B57, B58, B59, B60,
				B61, B62, B63, B64, B65;

wire clock;

wire [39:0] fft_1, fft_2, fft_3, fft_4, fft_5, fft_6, fft_7, fft_8, fft_9, fft_10, 				//mathematic result of amplitude before sqrt
				fft_11, fft_12, fft_13, fft_14, fft_15, fft_16, fft_17, fft_18, fft_19, fft_20, 
				fft_21, fft_22, fft_23, fft_24, fft_25, fft_26, fft_27, fft_28, fft_29, fft_30, 
				fft_31, fft_32, fft_33, fft_34, fft_35, fft_36, fft_37, fft_38, fft_39, fft_40, 
				fft_41, fft_42, fft_43, fft_44, fft_45, fft_46, fft_47, fft_48, fft_49, fft_50, 
				fft_51, fft_52, fft_53, fft_54, fft_55, fft_56, fft_57, fft_58, fft_59, fft_60, 
				fft_61, fft_62, fft_63, fft_64;
				
wire [19:0] ampl_1, ampl_2, ampl_3, ampl_4, ampl_5, ampl_6, ampl_7, ampl_8, ampl_9, ampl_10, 				//mathematic result of amplitude before sqrt
				ampl_11, ampl_12, ampl_13, ampl_14, ampl_15, ampl_16, ampl_17, ampl_18, ampl_19, ampl_20, 
				ampl_21, ampl_22, ampl_23, ampl_24, ampl_25, ampl_26, ampl_27, ampl_28, ampl_29, ampl_30, 
				ampl_31, ampl_32, ampl_33, ampl_34, ampl_35, ampl_36, ampl_37, ampl_38, ampl_39, ampl_40, 
				ampl_41, ampl_42, ampl_43, ampl_44, ampl_45, ampl_46, ampl_47, ampl_48, ampl_49, ampl_50, 
				ampl_51, ampl_52, ampl_53, ampl_54, ampl_55, ampl_56, ampl_57, ampl_58, ampl_59, ampl_60, 
				ampl_61, ampl_62, ampl_63, ampl_64;
				
////////////////resolution/////////////////
always @ (posedge clock)
	case (mode)
		0: begin vertical <= 640; horizontal <= 480; end
		1: begin vertical <= 800; horizontal <= 600; end
		default: begin vertical <= 800; horizontal <= 600; end
	endcase
	/*
/////////////////initialize memory//////////////
initial begin
	////out left real and imag
			memorie_imag_l_out[0] = 16'h0000;
		    memorie_real_l_out[0] = 16'h0000;
		    memorie_imag_l_out[1] = 16'h0000;
		    memorie_real_l_out[1] = 16'h0000;
		    memorie_imag_l_out[2] = 16'h0000;
		    memorie_real_l_out[2] = 16'h0000;
		    memorie_imag_l_out[3] = 16'h0000;
		    memorie_real_l_out[3] = 16'h0000;
		    memorie_imag_l_out[4] = 16'h0000;
		    memorie_real_l_out[4] = 16'h0000;
		    memorie_imag_l_out[5] = 16'h0000;
		    memorie_real_l_out[5] = 16'h0000;
		    memorie_imag_l_out[6] = 16'h0000;
		    memorie_real_l_out[6] = 16'h0000;
		    memorie_imag_l_out[7] = 16'h0000;
		    memorie_real_l_out[7] = 16'h0000;
		    memorie_imag_l_out[8] = 16'h0000;
		    memorie_real_l_out[8] = 16'h0000;
		    memorie_imag_l_out[9] = 16'h0000;
		    memorie_real_l_out[9] = 16'h0000;
		    memorie_imag_l_out[10] = 16'h0000;
		    memorie_real_l_out[10] = 16'h0000;
		    memorie_imag_l_out[11] = 16'h0000;
		    memorie_real_l_out[11] = 16'h0000;
		    memorie_imag_l_out[12] = 16'h0000;
		    memorie_real_l_out[12] = 16'h0000;
		    memorie_imag_l_out[13] = 16'h0000;
		    memorie_real_l_out[13] = 16'h0000;
		    memorie_imag_l_out[14] = 16'h0000;
		    memorie_real_l_out[14] = 16'h0000;
		    memorie_imag_l_out[15] = 16'h0000;
		    memorie_real_l_out[15] = 16'h0000;
		    memorie_imag_l_out[16] = 16'h0000;
		    memorie_real_l_out[16] = 16'h0000;
		    memorie_imag_l_out[17] = 16'h0000;
		    memorie_real_l_out[17] = 16'h0000;
		    memorie_imag_l_out[18] = 16'h0000;
		    memorie_real_l_out[18] = 16'h0000;
		    memorie_imag_l_out[19] = 16'h0000;
		    memorie_real_l_out[19] = 16'h0000;
		    memorie_imag_l_out[20] = 16'h0000;
		    memorie_real_l_out[20] = 16'h0000;
		    memorie_imag_l_out[21] = 16'h0000;
		    memorie_real_l_out[21] = 16'h0000;
		    memorie_imag_l_out[22] = 16'h0000;
		    memorie_real_l_out[22] = 16'h0000;
		    memorie_imag_l_out[23] = 16'h0000;
		    memorie_real_l_out[23] = 16'h0000;
		    memorie_imag_l_out[24] = 16'h0000;
		    memorie_real_l_out[24] = 16'h0000;
		    memorie_imag_l_out[25] = 16'h0000;
		    memorie_real_l_out[25] = 16'h0000;
		    memorie_imag_l_out[26] = 16'h0000;
		    memorie_real_l_out[26] = 16'h0000;
		    memorie_imag_l_out[27] = 16'h0000;
		    memorie_real_l_out[27] = 16'h0000;
		    memorie_imag_l_out[28] = 16'h0000;
		    memorie_real_l_out[28] = 16'h0000;
		    memorie_imag_l_out[29] = 16'h0000;
		    memorie_real_l_out[29] = 16'h0000;
		    memorie_imag_l_out[30] = 16'h0000;
		    memorie_real_l_out[30] = 16'h0000;
		    memorie_imag_l_out[31] = 16'h0000;
		    memorie_real_l_out[31] = 16'h0000;
		    memorie_imag_l_out[32] = 16'h0000;
		    memorie_real_l_out[32] = 16'h0000;
			 memorie_imag_l_out[33] = 16'h0000;
		    memorie_real_l_out[33] = 16'h0000;
			 memorie_imag_l_out[34] = 16'h0000;
		    memorie_real_l_out[34] = 16'h0000;
			 memorie_imag_l_out[35] = 16'h0000;
		    memorie_real_l_out[35] = 16'h0000;
			 memorie_imag_l_out[36] = 16'h0000;
		    memorie_real_l_out[36] = 16'h0000;
			 memorie_imag_l_out[37] = 16'h0000;
		    memorie_real_l_out[37] = 16'h0000;
			 memorie_imag_l_out[38] = 16'h0000;
		    memorie_real_l_out[38] = 16'h0000;
			 memorie_imag_l_out[39] = 16'h0000;
		    memorie_real_l_out[39] = 16'h0000;
			 memorie_imag_l_out[40] = 16'h0000;
		    memorie_real_l_out[40] = 16'h0000;
			 memorie_imag_l_out[41] = 16'h0000;
		    memorie_real_l_out[41] = 16'h0000;
			 memorie_imag_l_out[42] = 16'h0000;
		    memorie_real_l_out[42] = 16'h0000;
			 memorie_imag_l_out[43] = 16'h0000;
		    memorie_real_l_out[43] = 16'h0000;
			 memorie_imag_l_out[44] = 16'h0000;
		    memorie_real_l_out[44] = 16'h0000;
			 memorie_imag_l_out[45] = 16'h0000;
		    memorie_real_l_out[45] = 16'h0000;
			 memorie_imag_l_out[46] = 16'h0000;
		    memorie_real_l_out[46] = 16'h0000;
			 memorie_imag_l_out[47] = 16'h0000;
		    memorie_real_l_out[47] = 16'h0000;
			 memorie_imag_l_out[48] = 16'h0000;
		    memorie_real_l_out[48] = 16'h0000;
			 memorie_imag_l_out[49] = 16'h0000;
		    memorie_real_l_out[49] = 16'h0000;
			 memorie_imag_l_out[50] = 16'h0000;
		    memorie_real_l_out[50] = 16'h0000;
			 memorie_imag_l_out[51] = 16'h0000;
		    memorie_real_l_out[51] = 16'h0000;
			 memorie_imag_l_out[52] = 16'h0000;
		    memorie_real_l_out[52] = 16'h0000;
			 memorie_imag_l_out[53] = 16'h0000;
		    memorie_real_l_out[53] = 16'h0000;
			 memorie_imag_l_out[54] = 16'h0000;
		    memorie_real_l_out[54] = 16'h0000;
			 memorie_imag_l_out[55] = 16'h0000;
		    memorie_real_l_out[55] = 16'h0000;
			 memorie_imag_l_out[56] = 16'h0000;
		    memorie_real_l_out[56] = 16'h0000;
			 memorie_imag_l_out[57] = 16'h0000;
		    memorie_real_l_out[57] = 16'h0000;
			 memorie_imag_l_out[58] = 16'h0000;
		    memorie_real_l_out[58] = 16'h0000;
			 memorie_imag_l_out[59] = 16'h0000;
		    memorie_real_l_out[59] = 16'h0000;
			 memorie_imag_l_out[60] = 16'h0000;
		    memorie_real_l_out[60] = 16'h0000;
			 memorie_imag_l_out[61] = 16'h0000;
		    memorie_real_l_out[61] = 16'h0000;
			 memorie_imag_l_out[62] = 16'h0000;
		    memorie_real_l_out[62] = 16'h0000;
			 memorie_imag_l_out[63] = 16'h0000;
		    memorie_real_l_out[63] = 16'h0000;
			 memorie_imag_l_out[64] = 16'h0000;
		    memorie_real_l_out[64] = 16'h0000;
			 memorie_imag_l_out[65] = 16'h0000;
		    memorie_real_l_out[65] = 16'h0000;
			 memorie_imag_l_out[66] = 16'h0000;
		    memorie_real_l_out[66] = 16'h0000;
			 memorie_imag_l_out[67] = 16'h0000;
		    memorie_real_l_out[67] = 16'h0000;
			 memorie_imag_l_out[68] = 16'h0000;
		    memorie_real_l_out[68] = 16'h0000;
			 memorie_imag_l_out[69] = 16'h0000;
		    memorie_real_l_out[69] = 16'h0000;
			 memorie_imag_l_out[70] = 16'h0000;
		    memorie_real_l_out[70] = 16'h0000;
			 memorie_imag_l_out[71] = 16'h0000;
		    memorie_real_l_out[71] = 16'h0000;
			 memorie_imag_l_out[72] = 16'h0000;
		    memorie_real_l_out[72] = 16'h0000;
			 memorie_imag_l_out[73] = 16'h0000;
		    memorie_real_l_out[73] = 16'h0000;
			 memorie_imag_l_out[74] = 16'h0000;
		    memorie_real_l_out[74] = 16'h0000;
			 memorie_imag_l_out[75] = 16'h0000;
		    memorie_real_l_out[75] = 16'h0000;
			 memorie_imag_l_out[76] = 16'h0000;
		    memorie_real_l_out[76] = 16'h0000;
			 memorie_imag_l_out[77] = 16'h0000;
		    memorie_real_l_out[77] = 16'h0000;
			 memorie_imag_l_out[78] = 16'h0000;
		    memorie_real_l_out[78] = 16'h0000;
			 memorie_imag_l_out[79] = 16'h0000;
		    memorie_real_l_out[79] = 16'h0000;
			 memorie_imag_l_out[80] = 16'h0000;
		    memorie_real_l_out[80] = 16'h0000;
			 memorie_imag_l_out[81] = 16'h0000;
		    memorie_real_l_out[81] = 16'h0000;
			 memorie_imag_l_out[82] = 16'h0000;
		    memorie_real_l_out[82] = 16'h0000;
			 memorie_imag_l_out[83] = 16'h0000;
		    memorie_real_l_out[83] = 16'h0000;
			 memorie_imag_l_out[84] = 16'h0000;
		    memorie_real_l_out[84] = 16'h0000;
			 memorie_imag_l_out[85] = 16'h0000;
		    memorie_real_l_out[85] = 16'h0000;
			 memorie_imag_l_out[86] = 16'h0000;
		    memorie_real_l_out[86] = 16'h0000;
			 memorie_imag_l_out[87] = 16'h0000;
		    memorie_real_l_out[87] = 16'h0000;
			 memorie_imag_l_out[88] = 16'h0000;
		    memorie_real_l_out[88] = 16'h0000;
			 memorie_imag_l_out[89] = 16'h0000;
		    memorie_real_l_out[89] = 16'h0000;
			 memorie_imag_l_out[90] = 16'h0000;
		    memorie_real_l_out[90] = 16'h0000;
			 memorie_imag_l_out[91] = 16'h0000;
		    memorie_real_l_out[91] = 16'h0000;
			 memorie_imag_l_out[92] = 16'h0000;
		    memorie_real_l_out[92] = 16'h0000;
			 memorie_imag_l_out[93] = 16'h0000;
		    memorie_real_l_out[93] = 16'h0000;
			 memorie_imag_l_out[94] = 16'h0000;
		    memorie_real_l_out[94] = 16'h0000;
			 memorie_imag_l_out[95] = 16'h0000;
		    memorie_real_l_out[95] = 16'h0000;
			 memorie_imag_l_out[96] = 16'h0000;
		    memorie_real_l_out[96] = 16'h0000;
			 memorie_imag_l_out[97] = 16'h0000;
		    memorie_real_l_out[97] = 16'h0000;
			 memorie_imag_l_out[98] = 16'h0000;
		    memorie_real_l_out[98] = 16'h0000;
			 memorie_imag_l_out[99] = 16'h0000;
		    memorie_real_l_out[99] = 16'h0000;
			 memorie_imag_l_out[100] = 16'h0000;
		    memorie_real_l_out[100] = 16'h0000;
			 memorie_imag_l_out[101] = 16'h0000;
		    memorie_real_l_out[101] = 16'h0000;
			 memorie_imag_l_out[102] = 16'h0000;
		    memorie_real_l_out[102] = 16'h0000;
			 memorie_imag_l_out[103] = 16'h0000;
		    memorie_real_l_out[103] = 16'h0000;
			 memorie_imag_l_out[104] = 16'h0000;
		    memorie_real_l_out[104] = 16'h0000;
			 memorie_imag_l_out[105] = 16'h0000;
		    memorie_real_l_out[105] = 16'h0000;
			 memorie_imag_l_out[106] = 16'h0000;
		    memorie_real_l_out[106] = 16'h0000;
			 memorie_imag_l_out[107] = 16'h0000;
		    memorie_real_l_out[107] = 16'h0000;
			 memorie_imag_l_out[108] = 16'h0000;
		    memorie_real_l_out[108] = 16'h0000;
			 memorie_imag_l_out[109] = 16'h0000;
		    memorie_real_l_out[109] = 16'h0000;
			 memorie_imag_l_out[110] = 16'h0000;
		    memorie_real_l_out[110] = 16'h0000;
			 memorie_imag_l_out[111] = 16'h0000;
		    memorie_real_l_out[111] = 16'h0000;
			 memorie_imag_l_out[112] = 16'h0000;
		    memorie_real_l_out[112] = 16'h0000;
			 memorie_imag_l_out[113] = 16'h0000;
		    memorie_real_l_out[113] = 16'h0000;
			 memorie_imag_l_out[114] = 16'h0000;
		    memorie_real_l_out[114] = 16'h0000;
			 memorie_imag_l_out[115] = 16'h0000;
		    memorie_real_l_out[115] = 16'h0000;
			 memorie_imag_l_out[116] = 16'h0000;
		    memorie_real_l_out[116] = 16'h0000;
			 memorie_imag_l_out[117] = 16'h0000;
		    memorie_real_l_out[117] = 16'h0000;
			 memorie_imag_l_out[118] = 16'h0000;
		    memorie_real_l_out[118] = 16'h0000;
			 memorie_imag_l_out[119] = 16'h0000;
		    memorie_real_l_out[119] = 16'h0000;
			 memorie_imag_l_out[120] = 16'h0000;
		    memorie_real_l_out[120] = 16'h0000;
			 memorie_imag_l_out[121] = 16'h0000;
		    memorie_real_l_out[121] = 16'h0000;
			 memorie_imag_l_out[122] = 16'h0000;
		    memorie_real_l_out[122] = 16'h0000;
			 memorie_imag_l_out[123] = 16'h0000;
		    memorie_real_l_out[123] = 16'h0000;
			 memorie_imag_l_out[124] = 16'h0000;
		    memorie_real_l_out[124] = 16'h0000;
			 memorie_imag_l_out[125] = 16'h0000;
		    memorie_real_l_out[125] = 16'h0000;
			 memorie_imag_l_out[126] = 16'h0000;
		    memorie_real_l_out[126] = 16'h0000;
			 memorie_imag_l_out[127] = 16'h0000;
		    memorie_real_l_out[127] = 16'h0000;
		//out right real and imag
			memorie_imag_r_out[0] = 16'h0000;
		    memorie_real_r_out[0] = 16'h0000;
		    memorie_imag_r_out[1] = 16'h0000;
		    memorie_real_r_out[1] = 16'h0000;
		    memorie_imag_r_out[2] = 16'h0000;
		    memorie_real_r_out[2] = 16'h0000;
		    memorie_imag_r_out[3] = 16'h0000;
		    memorie_real_r_out[3] = 16'h0000;
		    memorie_imag_r_out[4] = 16'h0000;
		    memorie_real_r_out[4] = 16'h0000;
		    memorie_imag_r_out[5] = 16'h0000;
		    memorie_real_r_out[5] = 16'h0000;
		    memorie_imag_r_out[6] = 16'h0000;
		    memorie_real_r_out[6] = 16'h0000;
		    memorie_imag_r_out[7] = 16'h0000;
		    memorie_real_r_out[7] = 16'h0000;
		    memorie_imag_r_out[8] = 16'h0000;
		    memorie_real_r_out[8] = 16'h0000;
		    memorie_imag_r_out[9] = 16'h0000;
		    memorie_real_r_out[9] = 16'h0000;
		    memorie_imag_r_out[10] = 16'h0000;
		    memorie_real_r_out[10] = 16'h0000;
		    memorie_imag_r_out[11] = 16'h0000;
		    memorie_real_r_out[11] = 16'h0000;
		    memorie_imag_r_out[12] = 16'h0000;
		    memorie_real_r_out[12] = 16'h0000;
		    memorie_imag_r_out[13] = 16'h0000;
		    memorie_real_r_out[13] = 16'h0000;
		    memorie_imag_r_out[14] = 16'h0000;
		    memorie_real_r_out[14] = 16'h0000;
		    memorie_imag_r_out[15] = 16'h0000;
		    memorie_real_r_out[15] = 16'h0000;
		    memorie_imag_r_out[16] = 16'h0000;
		    memorie_real_r_out[16] = 16'h0000;
		    memorie_imag_r_out[17] = 16'h0000;
		    memorie_real_r_out[17] = 16'h0000;
		    memorie_imag_r_out[18] = 16'h0000;
		    memorie_real_r_out[18] = 16'h0000;
		    memorie_imag_r_out[19] = 16'h0000;
		    memorie_real_r_out[19] = 16'h0000;
		    memorie_imag_r_out[20] = 16'h0000;
		    memorie_real_r_out[20] = 16'h0000;
		    memorie_imag_r_out[21] = 16'h0000;
		    memorie_real_r_out[21] = 16'h0000;
		    memorie_imag_r_out[22] = 16'h0000;
		    memorie_real_r_out[22] = 16'h0000;
		    memorie_imag_r_out[23] = 16'h0000;
		    memorie_real_r_out[23] = 16'h0000;
		    memorie_imag_r_out[24] = 16'h0000;
		    memorie_real_r_out[24] = 16'h0000;
		    memorie_imag_r_out[25] = 16'h0000;
		    memorie_real_r_out[25] = 16'h0000;
		    memorie_imag_r_out[26] = 16'h0000;
		    memorie_real_r_out[26] = 16'h0000;
		    memorie_imag_r_out[27] = 16'h0000;
		    memorie_real_r_out[27] = 16'h0000;
		    memorie_imag_r_out[28] = 16'h0000;
		    memorie_real_r_out[28] = 16'h0000;
		    memorie_imag_r_out[29] = 16'h0000;
		    memorie_real_r_out[29] = 16'h0000;
		    memorie_imag_r_out[30] = 16'h0000;
		    memorie_real_r_out[30] = 16'h0000;
		    memorie_imag_r_out[31] = 16'h0000;
		    memorie_real_r_out[31] = 16'h0000;
		    memorie_imag_r_out[32] = 16'h0000;
		    memorie_real_r_out[32] = 16'h0000;
			 memorie_imag_r_out[33] = 16'h0000;
		    memorie_real_r_out[33] = 16'h0000;
			 memorie_imag_r_out[34] = 16'h0000;
		    memorie_real_r_out[34] = 16'h0000;
			 memorie_imag_r_out[35] = 16'h0000;
		    memorie_real_r_out[35] = 16'h0000;
			 memorie_imag_r_out[36] = 16'h0000;
		    memorie_real_r_out[36] = 16'h0000;
			 memorie_imag_r_out[37] = 16'h0000;
		    memorie_real_r_out[37] = 16'h0000;
			 memorie_imag_r_out[38] = 16'h0000;
		    memorie_real_r_out[38] = 16'h0000;
			 memorie_imag_r_out[39] = 16'h0000;
		    memorie_real_r_out[39] = 16'h0000;
			 memorie_imag_r_out[40] = 16'h0000;
		    memorie_real_r_out[40] = 16'h0000;
			 memorie_imag_r_out[41] = 16'h0000;
		    memorie_real_r_out[41] = 16'h0000;
			 memorie_imag_r_out[42] = 16'h0000;
		    memorie_real_r_out[42] = 16'h0000;
			 memorie_imag_r_out[43] = 16'h0000;
		    memorie_real_r_out[43] = 16'h0000;
			 memorie_imag_r_out[44] = 16'h0000;
		    memorie_real_r_out[44] = 16'h0000;
			 memorie_imag_r_out[45] = 16'h0000;
		    memorie_real_r_out[45] = 16'h0000;
			 memorie_imag_r_out[46] = 16'h0000;
		    memorie_real_r_out[46] = 16'h0000;
			 memorie_imag_r_out[47] = 16'h0000;
		    memorie_real_r_out[47] = 16'h0000;
			 memorie_imag_r_out[48] = 16'h0000;
		    memorie_real_r_out[48] = 16'h0000;
			 memorie_imag_r_out[49] = 16'h0000;
		    memorie_real_r_out[49] = 16'h0000;
			 memorie_imag_r_out[50] = 16'h0000;
		    memorie_real_r_out[50] = 16'h0000;
			 memorie_imag_r_out[51] = 16'h0000;
		    memorie_real_r_out[51] = 16'h0000;
			 memorie_imag_r_out[52] = 16'h0000;
		    memorie_real_r_out[52] = 16'h0000;
			 memorie_imag_r_out[53] = 16'h0000;
		    memorie_real_r_out[53] = 16'h0000;
			 memorie_imag_r_out[54] = 16'h0000;
		    memorie_real_r_out[54] = 16'h0000;
			 memorie_imag_r_out[55] = 16'h0000;
		    memorie_real_r_out[55] = 16'h0000;
			 memorie_imag_r_out[56] = 16'h0000;
		    memorie_real_r_out[56] = 16'h0000;
			 memorie_imag_r_out[57] = 16'h0000;
		    memorie_real_r_out[57] = 16'h0000;
			 memorie_imag_r_out[58] = 16'h0000;
		    memorie_real_r_out[58] = 16'h0000;
			 memorie_imag_r_out[59] = 16'h0000;
		    memorie_real_r_out[59] = 16'h0000;
			 memorie_imag_r_out[60] = 16'h0000;
		    memorie_real_r_out[60] = 16'h0000;
			 memorie_imag_r_out[61] = 16'h0000;
		    memorie_real_r_out[61] = 16'h0000;
			 memorie_imag_r_out[62] = 16'h0000;
		    memorie_real_r_out[62] = 16'h0000;
			 memorie_imag_r_out[63] = 16'h0000;
		    memorie_real_r_out[63] = 16'h0000;
			 memorie_imag_r_out[64] = 16'h0000;
		    memorie_real_r_out[64] = 16'h0000;
			 memorie_imag_r_out[65] = 16'h0000;
		    memorie_real_r_out[65] = 16'h0000;
			 memorie_imag_r_out[66] = 16'h0000;
		    memorie_real_r_out[66] = 16'h0000;
			 memorie_imag_r_out[67] = 16'h0000;
		    memorie_real_r_out[67] = 16'h0000;
			 memorie_imag_r_out[68] = 16'h0000;
		    memorie_real_r_out[68] = 16'h0000;
			 memorie_imag_r_out[69] = 16'h0000;
		    memorie_real_r_out[69] = 16'h0000;
			 memorie_imag_r_out[70] = 16'h0000;
		    memorie_real_r_out[70] = 16'h0000;
			 memorie_imag_r_out[71] = 16'h0000;
		    memorie_real_r_out[71] = 16'h0000;
			 memorie_imag_r_out[72] = 16'h0000;
		    memorie_real_r_out[72] = 16'h0000;
			 memorie_imag_r_out[73] = 16'h0000;
		    memorie_real_r_out[73] = 16'h0000;
			 memorie_imag_r_out[74] = 16'h0000;
		    memorie_real_r_out[74] = 16'h0000;
			 memorie_imag_r_out[75] = 16'h0000;
		    memorie_real_r_out[75] = 16'h0000;
			 memorie_imag_r_out[76] = 16'h0000;
		    memorie_real_r_out[76] = 16'h0000;
			 memorie_imag_r_out[77] = 16'h0000;
		    memorie_real_r_out[77] = 16'h0000;
			 memorie_imag_r_out[78] = 16'h0000;
		    memorie_real_r_out[78] = 16'h0000;
			 memorie_imag_r_out[79] = 16'h0000;
		    memorie_real_r_out[79] = 16'h0000;
			 memorie_imag_r_out[80] = 16'h0000;
		    memorie_real_r_out[80] = 16'h0000;
			 memorie_imag_r_out[81] = 16'h0000;
		    memorie_real_r_out[81] = 16'h0000;
			 memorie_imag_r_out[82] = 16'h0000;
		    memorie_real_r_out[82] = 16'h0000;
			 memorie_imag_r_out[83] = 16'h0000;
		    memorie_real_r_out[83] = 16'h0000;
			 memorie_imag_r_out[84] = 16'h0000;
		    memorie_real_r_out[84] = 16'h0000;
			 memorie_imag_r_out[85] = 16'h0000;
		    memorie_real_r_out[85] = 16'h0000;
			 memorie_imag_r_out[86] = 16'h0000;
		    memorie_real_r_out[86] = 16'h0000;
			 memorie_imag_r_out[87] = 16'h0000;
		    memorie_real_r_out[87] = 16'h0000;
			 memorie_imag_r_out[88] = 16'h0000;
		    memorie_real_r_out[88] = 16'h0000;
			 memorie_imag_r_out[89] = 16'h0000;
		    memorie_real_r_out[89] = 16'h0000;
			 memorie_imag_r_out[90] = 16'h0000;
		    memorie_real_r_out[90] = 16'h0000;
			 memorie_imag_r_out[91] = 16'h0000;
		    memorie_real_r_out[91] = 16'h0000;
			 memorie_imag_r_out[92] = 16'h0000;
		    memorie_real_r_out[92] = 16'h0000;
			 memorie_imag_r_out[93] = 16'h0000;
		    memorie_real_r_out[93] = 16'h0000;
			 memorie_imag_r_out[94] = 16'h0000;
		    memorie_real_r_out[94] = 16'h0000;
			 memorie_imag_r_out[95] = 16'h0000;
		    memorie_real_r_out[95] = 16'h0000;
			 memorie_imag_r_out[96] = 16'h0000;
		    memorie_real_r_out[96] = 16'h0000;
			 memorie_imag_r_out[97] = 16'h0000;
		    memorie_real_r_out[97] = 16'h0000;
			 memorie_imag_r_out[98] = 16'h0000;
		    memorie_real_r_out[98] = 16'h0000;
			 memorie_imag_r_out[99] = 16'h0000;
		    memorie_real_r_out[99] = 16'h0000;
			 memorie_imag_r_out[100] = 16'h0000;
		    memorie_real_r_out[100] = 16'h0000;
			 memorie_imag_r_out[101] = 16'h0000;
		    memorie_real_r_out[101] = 16'h0000;
			 memorie_imag_r_out[102] = 16'h0000;
		    memorie_real_r_out[102] = 16'h0000;
			 memorie_imag_r_out[103] = 16'h0000;
		    memorie_real_r_out[103] = 16'h0000;
			 memorie_imag_r_out[104] = 16'h0000;
		    memorie_real_r_out[104] = 16'h0000;
			 memorie_imag_r_out[105] = 16'h0000;
		    memorie_real_r_out[105] = 16'h0000;
			 memorie_imag_r_out[106] = 16'h0000;
		    memorie_real_r_out[106] = 16'h0000;
			 memorie_imag_r_out[107] = 16'h0000;
		    memorie_real_r_out[107] = 16'h0000;
			 memorie_imag_r_out[108] = 16'h0000;
		    memorie_real_r_out[108] = 16'h0000;
			 memorie_imag_r_out[109] = 16'h0000;
		    memorie_real_r_out[109] = 16'h0000;
			 memorie_imag_r_out[110] = 16'h0000;
		    memorie_real_r_out[110] = 16'h0000;
			 memorie_imag_r_out[111] = 16'h0000;
		    memorie_real_r_out[111] = 16'h0000;
			 memorie_imag_r_out[112] = 16'h0000;
		    memorie_real_r_out[112] = 16'h0000;
			 memorie_imag_r_out[113] = 16'h0000;
		    memorie_real_r_out[113] = 16'h0000;
			 memorie_imag_r_out[114] = 16'h0000;
		    memorie_real_r_out[114] = 16'h0000;
			 memorie_imag_r_out[115] = 16'h0000;
		    memorie_real_r_out[115] = 16'h0000;
			 memorie_imag_r_out[116] = 16'h0000;
		    memorie_real_r_out[116] = 16'h0000;
			 memorie_imag_r_out[117] = 16'h0000;
		    memorie_real_r_out[117] = 16'h0000;
			 memorie_imag_r_out[118] = 16'h0000;
		    memorie_real_r_out[118] = 16'h0000;
			 memorie_imag_r_out[119] = 16'h0000;
		    memorie_real_r_out[119] = 16'h0000;
			 memorie_imag_r_out[120] = 16'h0000;
		    memorie_real_r_out[120] = 16'h0000;
			 memorie_imag_r_out[121] = 16'h0000;
		    memorie_real_r_out[121] = 16'h0000;
			 memorie_imag_r_out[122] = 16'h0000;
		    memorie_real_r_out[122] = 16'h0000;
			 memorie_imag_r_out[123] = 16'h0000;
		    memorie_real_r_out[123] = 16'h0000;
			 memorie_imag_r_out[124] = 16'h0000;
		    memorie_real_r_out[124] = 16'h0000;
			 memorie_imag_r_out[125] = 16'h0000;
		    memorie_real_r_out[125] = 16'h0000;
			 memorie_imag_r_out[126] = 16'h0000;
		    memorie_real_r_out[126] = 16'h0000;
			 memorie_imag_r_out[127] = 16'h0000;
		    memorie_real_r_out[127] = 16'h0000;
		//in right real and imag
			memorie_imag_r[0] = 16'h0000;
		    memorie_real_r[0] = 16'h0000;
		    memorie_imag_r[1] = 16'h0000;
		    memorie_real_r[1] = 16'h0000;
		    memorie_imag_r[2] = 16'h0000;
		    memorie_real_r[2] = 16'h0000;
		    memorie_imag_r[3] = 16'h0000;
		    memorie_real_r[3] = 16'h0000;
		    memorie_imag_r[4] = 16'h0000;
		    memorie_real_r[4] = 16'h0000;
		    memorie_imag_r[5] = 16'h0000;
		    memorie_real_r[5] = 16'h0000;
		    memorie_imag_r[6] = 16'h0000;
		    memorie_real_r[6] = 16'h0000;
		    memorie_imag_r[7] = 16'h0000;
		    memorie_real_r[7] = 16'h0000;
		    memorie_imag_r[8] = 16'h0000;
		    memorie_real_r[8] = 16'h0000;
		    memorie_imag_r[9] = 16'h0000;
		    memorie_real_r[9] = 16'h0000;
		    memorie_imag_r[10] = 16'h0000;
		    memorie_real_r[10] = 16'h0000;
		    memorie_imag_r[11] = 16'h0000;
		    memorie_real_r[11] = 16'h0000;
		    memorie_imag_r[12] = 16'h0000;
		    memorie_real_r[12] = 16'h0000;
		    memorie_imag_r[13] = 16'h0000;
		    memorie_real_r[13] = 16'h0000;
		    memorie_imag_r[14] = 16'h0000;
		    memorie_real_r[14] = 16'h0000;
		    memorie_imag_r[15] = 16'h0000;
		    memorie_real_r[15] = 16'h0000;
		    memorie_imag_r[16] = 16'h0000;
		    memorie_real_r[16] = 16'h0000;
		    memorie_imag_r[17] = 16'h0000;
		    memorie_real_r[17] = 16'h0000;
		    memorie_imag_r[18] = 16'h0000;
		    memorie_real_r[18] = 16'h0000;
		    memorie_imag_r[19] = 16'h0000;
		    memorie_real_r[19] = 16'h0000;
		    memorie_imag_r[20] = 16'h0000;
		    memorie_real_r[20] = 16'h0000;
		    memorie_imag_r[21] = 16'h0000;
		    memorie_real_r[21] = 16'h0000;
		    memorie_imag_r[22] = 16'h0000;
		    memorie_real_r[22] = 16'h0000;
		    memorie_imag_r[23] = 16'h0000;
		    memorie_real_r[23] = 16'h0000;
		    memorie_imag_r[24] = 16'h0000;
		    memorie_real_r[24] = 16'h0000;
		    memorie_imag_r[25] = 16'h0000;
		    memorie_real_r[25] = 16'h0000;
		    memorie_imag_r[26] = 16'h0000;
		    memorie_real_r[26] = 16'h0000;
		    memorie_imag_r[27] = 16'h0000;
		    memorie_real_r[27] = 16'h0000;
		    memorie_imag_r[28] = 16'h0000;
		    memorie_real_r[28] = 16'h0000;
		    memorie_imag_r[29] = 16'h0000;
		    memorie_real_r[29] = 16'h0000;
		    memorie_imag_r[30] = 16'h0000;
		    memorie_real_r[30] = 16'h0000;
		    memorie_imag_r[31] = 16'h0000;
		    memorie_real_r[31] = 16'h0000;
		    memorie_imag_r[32] = 16'h0000;
		    memorie_real_r[32] = 16'h0000;
			 memorie_imag_r[33] = 16'h0000;
		    memorie_real_r[33] = 16'h0000;
			 memorie_imag_r[34] = 16'h0000;
		    memorie_real_r[34] = 16'h0000;
			 memorie_imag_r[35] = 16'h0000;
		    memorie_real_r[35] = 16'h0000;
			 memorie_imag_r[36] = 16'h0000;
		    memorie_real_r[36] = 16'h0000;
			 memorie_imag_r[37] = 16'h0000;
		    memorie_real_r[37] = 16'h0000;
			 memorie_imag_r[38] = 16'h0000;
		    memorie_real_r[38] = 16'h0000;
			 memorie_imag_r[39] = 16'h0000;
		    memorie_real_r[39] = 16'h0000;
			 memorie_imag_r[40] = 16'h0000;
		    memorie_real_r[40] = 16'h0000;
			 memorie_imag_r[41] = 16'h0000;
		    memorie_real_r[41] = 16'h0000;
			 memorie_imag_r[42] = 16'h0000;
		    memorie_real_r[42] = 16'h0000;
			 memorie_imag_r[43] = 16'h0000;
		    memorie_real_r[43] = 16'h0000;
			 memorie_imag_r[44] = 16'h0000;
		    memorie_real_r[44] = 16'h0000;
			 memorie_imag_r[45] = 16'h0000;
		    memorie_real_r[45] = 16'h0000;
			 memorie_imag_r[46] = 16'h0000;
		    memorie_real_r[46] = 16'h0000;
			 memorie_imag_r[47] = 16'h0000;
		    memorie_real_r[47] = 16'h0000;
			 memorie_imag_r[48] = 16'h0000;
		    memorie_real_r[48] = 16'h0000;
			 memorie_imag_r[49] = 16'h0000;
		    memorie_real_r[49] = 16'h0000;
			 memorie_imag_r[50] = 16'h0000;
		    memorie_real_r[50] = 16'h0000;
			 memorie_imag_r[51] = 16'h0000;
		    memorie_real_r[51] = 16'h0000;
			 memorie_imag_r[52] = 16'h0000;
		    memorie_real_r[52] = 16'h0000;
			 memorie_imag_r[53] = 16'h0000;
		    memorie_real_r[53] = 16'h0000;
			 memorie_imag_r[54] = 16'h0000;
		    memorie_real_r[54] = 16'h0000;
			 memorie_imag_r[55] = 16'h0000;
		    memorie_real_r[55] = 16'h0000;
			 memorie_imag_r[56] = 16'h0000;
		    memorie_real_r[56] = 16'h0000;
			 memorie_imag_r[57] = 16'h0000;
		    memorie_real_r[57] = 16'h0000;
			 memorie_imag_r[58] = 16'h0000;
		    memorie_real_r[58] = 16'h0000;
			 memorie_imag_r[59] = 16'h0000;
		    memorie_real_r[59] = 16'h0000;
			 memorie_imag_r[60] = 16'h0000;
		    memorie_real_r[60] = 16'h0000;
			 memorie_imag_r[61] = 16'h0000;
		    memorie_real_r[61] = 16'h0000;
			 memorie_imag_r[62] = 16'h0000;
		    memorie_real_r[62] = 16'h0000;
			 memorie_imag_r[63] = 16'h0000;
		    memorie_real_r[63] = 16'h0000;
			 memorie_imag_r[64] = 16'h0000;
		    memorie_real_r[64] = 16'h0000;
			 memorie_imag_r[65] = 16'h0000;
		    memorie_real_r[65] = 16'h0000;
			 memorie_imag_r[66] = 16'h0000;
		    memorie_real_r[66] = 16'h0000;
			 memorie_imag_r[67] = 16'h0000;
		    memorie_real_r[67] = 16'h0000;
			 memorie_imag_r[68] = 16'h0000;
		    memorie_real_r[68] = 16'h0000;
			 memorie_imag_r[69] = 16'h0000;
		    memorie_real_r[69] = 16'h0000;
			 memorie_imag_r[70] = 16'h0000;
		    memorie_real_r[70] = 16'h0000;
			 memorie_imag_r[71] = 16'h0000;
		    memorie_real_r[71] = 16'h0000;
			 memorie_imag_r[72] = 16'h0000;
		    memorie_real_r[72] = 16'h0000;
			 memorie_imag_r[73] = 16'h0000;
		    memorie_real_r[73] = 16'h0000;
			 memorie_imag_r[74] = 16'h0000;
		    memorie_real_r[74] = 16'h0000;
			 memorie_imag_r[75] = 16'h0000;
		    memorie_real_r[75] = 16'h0000;
			 memorie_imag_r[76] = 16'h0000;
		    memorie_real_r[76] = 16'h0000;
			 memorie_imag_r[77] = 16'h0000;
		    memorie_real_r[77] = 16'h0000;
			 memorie_imag_r[78] = 16'h0000;
		    memorie_real_r[78] = 16'h0000;
			 memorie_imag_r[79] = 16'h0000;
		    memorie_real_r[79] = 16'h0000;
			 memorie_imag_r[80] = 16'h0000;
		    memorie_real_r[80] = 16'h0000;
			 memorie_imag_r[81] = 16'h0000;
		    memorie_real_r[81] = 16'h0000;
			 memorie_imag_r[82] = 16'h0000;
		    memorie_real_r[82] = 16'h0000;
			 memorie_imag_r[83] = 16'h0000;
		    memorie_real_r[83] = 16'h0000;
			 memorie_imag_r[84] = 16'h0000;
		    memorie_real_r[84] = 16'h0000;
			 memorie_imag_r[85] = 16'h0000;
		    memorie_real_r[85] = 16'h0000;
			 memorie_imag_r[86] = 16'h0000;
		    memorie_real_r[86] = 16'h0000;
			 memorie_imag_r[87] = 16'h0000;
		    memorie_real_r[87] = 16'h0000;
			 memorie_imag_r[88] = 16'h0000;
		    memorie_real_r[88] = 16'h0000;
			 memorie_imag_r[89] = 16'h0000;
		    memorie_real_r[89] = 16'h0000;
			 memorie_imag_r[90] = 16'h0000;
		    memorie_real_r[90] = 16'h0000;
			 memorie_imag_r[91] = 16'h0000;
		    memorie_real_r[91] = 16'h0000;
			 memorie_imag_r[92] = 16'h0000;
		    memorie_real_r[92] = 16'h0000;
			 memorie_imag_r[93] = 16'h0000;
		    memorie_real_r[93] = 16'h0000;
			 memorie_imag_r[94] = 16'h0000;
		    memorie_real_r[94] = 16'h0000;
			 memorie_imag_r[95] = 16'h0000;
		    memorie_real_r[95] = 16'h0000;
			 memorie_imag_r[96] = 16'h0000;
		    memorie_real_r[96] = 16'h0000;
			 memorie_imag_r[97] = 16'h0000;
		    memorie_real_r[97] = 16'h0000;
			 memorie_imag_r[98] = 16'h0000;
		    memorie_real_r[98] = 16'h0000;
			 memorie_imag_r[99] = 16'h0000;
		    memorie_real_r[99] = 16'h0000;
			 memorie_imag_r[100] = 16'h0000;
		    memorie_real_r[100] = 16'h0000;
			 memorie_imag_r[101] = 16'h0000;
		    memorie_real_r[101] = 16'h0000;
			 memorie_imag_r[102] = 16'h0000;
		    memorie_real_r[102] = 16'h0000;
			 memorie_imag_r[103] = 16'h0000;
		    memorie_real_r[103] = 16'h0000;
			 memorie_imag_r[104] = 16'h0000;
		    memorie_real_r[104] = 16'h0000;
			 memorie_imag_r[105] = 16'h0000;
		    memorie_real_r[105] = 16'h0000;
			 memorie_imag_r[106] = 16'h0000;
		    memorie_real_r[106] = 16'h0000;
			 memorie_imag_r[107] = 16'h0000;
		    memorie_real_r[107] = 16'h0000;
			 memorie_imag_r[108] = 16'h0000;
		    memorie_real_r[108] = 16'h0000;
			 memorie_imag_r[109] = 16'h0000;
		    memorie_real_r[109] = 16'h0000;
			 memorie_imag_r[110] = 16'h0000;
		    memorie_real_r[110] = 16'h0000;
			 memorie_imag_r[111] = 16'h0000;
		    memorie_real_r[111] = 16'h0000;
			 memorie_imag_r[112] = 16'h0000;
		    memorie_real_r[112] = 16'h0000;
			 memorie_imag_r[113] = 16'h0000;
		    memorie_real_r[113] = 16'h0000;
			 memorie_imag_r[114] = 16'h0000;
		    memorie_real_r[114] = 16'h0000;
			 memorie_imag_r[115] = 16'h0000;
		    memorie_real_r[115] = 16'h0000;
			 memorie_imag_r[116] = 16'h0000;
		    memorie_real_r[116] = 16'h0000;
			 memorie_imag_r[117] = 16'h0000;
		    memorie_real_r[117] = 16'h0000;
			 memorie_imag_r[118] = 16'h0000;
		    memorie_real_r[118] = 16'h0000;
			 memorie_imag_r[119] = 16'h0000;
		    memorie_real_r[119] = 16'h0000;
			 memorie_imag_r[120] = 16'h0000;
		    memorie_real_r[120] = 16'h0000;
			 memorie_imag_r[121] = 16'h0000;
		    memorie_real_r[121] = 16'h0000;
			 memorie_imag_r[122] = 16'h0000;
		    memorie_real_r[122] = 16'h0000;
			 memorie_imag_r[123] = 16'h0000;
		    memorie_real_r[123] = 16'h0000;
			 memorie_imag_r[124] = 16'h0000;
		    memorie_real_r[124] = 16'h0000;
			 memorie_imag_r[125] = 16'h0000;
		    memorie_real_r[125] = 16'h0000;
			 memorie_imag_r[126] = 16'h0000;
		    memorie_real_r[126] = 16'h0000;
			 memorie_imag_r[127] = 16'h0000;
		    memorie_real_r[127] = 16'h0000;
		//in left real and imag
			memorie_imag_l[0] = 16'h0000;
		    memorie_real_l[0] = 16'h0000;
		    memorie_imag_l[1] = 16'h0000;
		    memorie_real_l[1] = 16'h0000;
		    memorie_imag_l[2] = 16'h0000;
		    memorie_real_l[2] = 16'h0000;
		    memorie_imag_l[3] = 16'h0000;
		    memorie_real_l[3] = 16'h0000;
		    memorie_imag_l[4] = 16'h0000;
		    memorie_real_l[4] = 16'h0000;
		    memorie_imag_l[5] = 16'h0000;
		    memorie_real_l[5] = 16'h0000;
		    memorie_imag_l[6] = 16'h0000;
		    memorie_real_l[6] = 16'h0000;
		    memorie_imag_l[7] = 16'h0000;
		    memorie_real_l[7] = 16'h0000;
		    memorie_imag_l[8] = 16'h0000;
		    memorie_real_l[8] = 16'h0000;
		    memorie_imag_l[9] = 16'h0000;
		    memorie_real_l[9] = 16'h0000;
		    memorie_imag_l[10] = 16'h0000;
		    memorie_real_l[10] = 16'h0000;
		    memorie_imag_l[11] = 16'h0000;
		    memorie_real_l[11] = 16'h0000;
		    memorie_imag_l[12] = 16'h0000;
		    memorie_real_l[12] = 16'h0000;
		    memorie_imag_l[13] = 16'h0000;
		    memorie_real_l[13] = 16'h0000;
		    memorie_imag_l[14] = 16'h0000;
		    memorie_real_l[14] = 16'h0000;
		    memorie_imag_l[15] = 16'h0000;
		    memorie_real_l[15] = 16'h0000;
		    memorie_imag_l[16] = 16'h0000;
		    memorie_real_l[16] = 16'h0000;
		    memorie_imag_l[17] = 16'h0000;
		    memorie_real_l[17] = 16'h0000;
		    memorie_imag_l[18] = 16'h0000;
		    memorie_real_l[18] = 16'h0000;
		    memorie_imag_l[19] = 16'h0000;
		    memorie_real_l[19] = 16'h0000;
		    memorie_imag_l[20] = 16'h0000;
		    memorie_real_l[20] = 16'h0000;
		    memorie_imag_l[21] = 16'h0000;
		    memorie_real_l[21] = 16'h0000;
		    memorie_imag_l[22] = 16'h0000;
		    memorie_real_l[22] = 16'h0000;
		    memorie_imag_l[23] = 16'h0000;
		    memorie_real_l[23] = 16'h0000;
		    memorie_imag_l[24] = 16'h0000;
		    memorie_real_l[24] = 16'h0000;
		    memorie_imag_l[25] = 16'h0000;
		    memorie_real_l[25] = 16'h0000;
		    memorie_imag_l[26] = 16'h0000;
		    memorie_real_l[26] = 16'h0000;
		    memorie_imag_l[27] = 16'h0000;
		    memorie_real_l[27] = 16'h0000;
		    memorie_imag_l[28] = 16'h0000;
		    memorie_real_l[28] = 16'h0000;
		    memorie_imag_l[29] = 16'h0000;
		    memorie_real_l[29] = 16'h0000;
		    memorie_imag_l[30] = 16'h0000;
		    memorie_real_l[30] = 16'h0000;
		    memorie_imag_l[31] = 16'h0000;
		    memorie_real_l[31] = 16'h0000;
		    memorie_imag_l[32] = 16'h0000;
		    memorie_real_l[32] = 16'h0000;
			 memorie_imag_l[33] = 16'h0000;
		    memorie_real_l[33] = 16'h0000;
			 memorie_imag_l[34] = 16'h0000;
		    memorie_real_l[34] = 16'h0000;
			 memorie_imag_l[35] = 16'h0000;
		    memorie_real_l[35] = 16'h0000;
			 memorie_imag_l[36] = 16'h0000;
		    memorie_real_l[36] = 16'h0000;
			 memorie_imag_l[37] = 16'h0000;
		    memorie_real_l[37] = 16'h0000;
			 memorie_imag_l[38] = 16'h0000;
		    memorie_real_l[38] = 16'h0000;
			 memorie_imag_l[39] = 16'h0000;
		    memorie_real_l[39] = 16'h0000;
			 memorie_imag_l[40] = 16'h0000;
		    memorie_real_l[40] = 16'h0000;
			 memorie_imag_l[41] = 16'h0000;
		    memorie_real_l[41] = 16'h0000;
			 memorie_imag_l[42] = 16'h0000;
		    memorie_real_l[42] = 16'h0000;
			 memorie_imag_l[43] = 16'h0000;
		    memorie_real_l[43] = 16'h0000;
			 memorie_imag_l[44] = 16'h0000;
		    memorie_real_l[44] = 16'h0000;
			 memorie_imag_l[45] = 16'h0000;
		    memorie_real_l[45] = 16'h0000;
			 memorie_imag_l[46] = 16'h0000;
		    memorie_real_l[46] = 16'h0000;
			 memorie_imag_l[47] = 16'h0000;
		    memorie_real_l[47] = 16'h0000;
			 memorie_imag_l[48] = 16'h0000;
		    memorie_real_l[48] = 16'h0000;
			 memorie_imag_l[49] = 16'h0000;
		    memorie_real_l[49] = 16'h0000;
			 memorie_imag_l[50] = 16'h0000;
		    memorie_real_l[50] = 16'h0000;
			 memorie_imag_l[51] = 16'h0000;
		    memorie_real_l[51] = 16'h0000;
			 memorie_imag_l[52] = 16'h0000;
		    memorie_real_l[52] = 16'h0000;
			 memorie_imag_l[53] = 16'h0000;
		    memorie_real_l[53] = 16'h0000;
			 memorie_imag_l[54] = 16'h0000;
		    memorie_real_l[54] = 16'h0000;
			 memorie_imag_l[55] = 16'h0000;
		    memorie_real_l[55] = 16'h0000;
			 memorie_imag_l[56] = 16'h0000;
		    memorie_real_l[56] = 16'h0000;
			 memorie_imag_l[57] = 16'h0000;
		    memorie_real_l[57] = 16'h0000;
			 memorie_imag_l[58] = 16'h0000;
		    memorie_real_l[58] = 16'h0000;
			 memorie_imag_l[59] = 16'h0000;
		    memorie_real_l[59] = 16'h0000;
			 memorie_imag_l[60] = 16'h0000;
		    memorie_real_l[60] = 16'h0000;
			 memorie_imag_l[61] = 16'h0000;
		    memorie_real_l[61] = 16'h0000;
			 memorie_imag_l[62] = 16'h0000;
		    memorie_real_l[62] = 16'h0000;
			 memorie_imag_l[63] = 16'h0000;
		    memorie_real_l[63] = 16'h0000;
			 memorie_imag_l[64] = 16'h0000;
		    memorie_real_l[64] = 16'h0000;
			 memorie_imag_l[65] = 16'h0000;
		    memorie_real_l[65] = 16'h0000;
			 memorie_imag_l[66] = 16'h0000;
		    memorie_real_l[66] = 16'h0000;
			 memorie_imag_l[67] = 16'h0000;
		    memorie_real_l[67] = 16'h0000;
			 memorie_imag_l[68] = 16'h0000;
		    memorie_real_l[68] = 16'h0000;
			 memorie_imag_l[69] = 16'h0000;
		    memorie_real_l[69] = 16'h0000;
			 memorie_imag_l[70] = 16'h0000;
		    memorie_real_l[70] = 16'h0000;
			 memorie_imag_l[71] = 16'h0000;
		    memorie_real_l[71] = 16'h0000;
			 memorie_imag_l[72] = 16'h0000;
		    memorie_real_l[72] = 16'h0000;
			 memorie_imag_l[73] = 16'h0000;
		    memorie_real_l[73] = 16'h0000;
			 memorie_imag_l[74] = 16'h0000;
		    memorie_real_l[74] = 16'h0000;
			 memorie_imag_l[75] = 16'h0000;
		    memorie_real_l[75] = 16'h0000;
			 memorie_imag_l[76] = 16'h0000;
		    memorie_real_l[76] = 16'h0000;
			 memorie_imag_l[77] = 16'h0000;
		    memorie_real_l[77] = 16'h0000;
			 memorie_imag_l[78] = 16'h0000;
		    memorie_real_l[78] = 16'h0000;
			 memorie_imag_l[79] = 16'h0000;
		    memorie_real_l[79] = 16'h0000;
			 memorie_imag_l[80] = 16'h0000;
		    memorie_real_l[80] = 16'h0000;
			 memorie_imag_l[81] = 16'h0000;
		    memorie_real_l[81] = 16'h0000;
			 memorie_imag_l[82] = 16'h0000;
		    memorie_real_l[82] = 16'h0000;
			 memorie_imag_l[83] = 16'h0000;
		    memorie_real_l[83] = 16'h0000;
			 memorie_imag_l[84] = 16'h0000;
		    memorie_real_l[84] = 16'h0000;
			 memorie_imag_l[85] = 16'h0000;
		    memorie_real_l[85] = 16'h0000;
			 memorie_imag_l[86] = 16'h0000;
		    memorie_real_l[86] = 16'h0000;
			 memorie_imag_l[87] = 16'h0000;
		    memorie_real_l[87] = 16'h0000;
			 memorie_imag_l[88] = 16'h0000;
		    memorie_real_l[88] = 16'h0000;
			 memorie_imag_l[89] = 16'h0000;
		    memorie_real_l[89] = 16'h0000;
			 memorie_imag_l[90] = 16'h0000;
		    memorie_real_l[90] = 16'h0000;
			 memorie_imag_l[91] = 16'h0000;
		    memorie_real_l[91] = 16'h0000;
			 memorie_imag_l[92] = 16'h0000;
		    memorie_real_l[92] = 16'h0000;
			 memorie_imag_l[93] = 16'h0000;
		    memorie_real_l[93] = 16'h0000;
			 memorie_imag_l[94] = 16'h0000;
		    memorie_real_l[94] = 16'h0000;
			 memorie_imag_l[95] = 16'h0000;
		    memorie_real_l[95] = 16'h0000;
			 memorie_imag_l[96] = 16'h0000;
		    memorie_real_l[96] = 16'h0000;
			 memorie_imag_l[97] = 16'h0000;
		    memorie_real_l[97] = 16'h0000;
			 memorie_imag_l[98] = 16'h0000;
		    memorie_real_l[98] = 16'h0000;
			 memorie_imag_l[99] = 16'h0000;
		    memorie_real_l[99] = 16'h0000;
			 memorie_imag_l[100] = 16'h0000;
		    memorie_real_l[100] = 16'h0000;
			 memorie_imag_l[101] = 16'h0000;
		    memorie_real_l[101] = 16'h0000;
			 memorie_imag_l[102] = 16'h0000;
		    memorie_real_l[102] = 16'h0000;
			 memorie_imag_l[103] = 16'h0000;
		    memorie_real_l[103] = 16'h0000;
			 memorie_imag_l[104] = 16'h0000;
		    memorie_real_l[104] = 16'h0000;
			 memorie_imag_l[105] = 16'h0000;
		    memorie_real_l[105] = 16'h0000;
			 memorie_imag_l[106] = 16'h0000;
		    memorie_real_l[106] = 16'h0000;
			 memorie_imag_l[107] = 16'h0000;
		    memorie_real_l[107] = 16'h0000;
			 memorie_imag_l[108] = 16'h0000;
		    memorie_real_l[108] = 16'h0000;
			 memorie_imag_l[109] = 16'h0000;
		    memorie_real_l[109] = 16'h0000;
			 memorie_imag_l[110] = 16'h0000;
		    memorie_real_l[110] = 16'h0000;
			 memorie_imag_l[111] = 16'h0000;
		    memorie_real_l[111] = 16'h0000;
			 memorie_imag_l[112] = 16'h0000;
		    memorie_real_l[112] = 16'h0000;
			 memorie_imag_l[113] = 16'h0000;
		    memorie_real_l[113] = 16'h0000;
			 memorie_imag_l[114] = 16'h0000;
		    memorie_real_l[114] = 16'h0000;
			 memorie_imag_l[115] = 16'h0000;
		    memorie_real_l[115] = 16'h0000;
			 memorie_imag_l[116] = 16'h0000;
		    memorie_real_l[116] = 16'h0000;
			 memorie_imag_l[117] = 16'h0000;
		    memorie_real_l[117] = 16'h0000;
			 memorie_imag_l[118] = 16'h0000;
		    memorie_real_l[118] = 16'h0000;
			 memorie_imag_l[119] = 16'h0000;
		    memorie_real_l[119] = 16'h0000;
			 memorie_imag_l[120] = 16'h0000;
		    memorie_real_l[120] = 16'h0000;
			 memorie_imag_l[121] = 16'h0000;
		    memorie_real_l[121] = 16'h0000;
			 memorie_imag_l[122] = 16'h0000;
		    memorie_real_l[122] = 16'h0000;
			 memorie_imag_l[123] = 16'h0000;
		    memorie_real_l[123] = 16'h0000;
			 memorie_imag_l[124] = 16'h0000;
		    memorie_real_l[124] = 16'h0000;
			 memorie_imag_l[125] = 16'h0000;
		    memorie_real_l[125] = 16'h0000;
			 memorie_imag_l[126] = 16'h0000;
		    memorie_real_l[126] = 16'h0000;
			 memorie_imag_l[127] = 16'h0000;
		    memorie_real_l[127] = 16'h0000;
	end
*/
/////////////////write in memory/////////////
always @ (negedge clk_fft_l)
	if (source_ready_l == 1 && source_valid_l == 1)
		begin
			if (source_sop_l == 1) begin
				counter_l <= 0;
				full_load_l <= 1;
				counter_l <= counter_l + 1;
				end
			else if (counter_l == 127) begin
				full_load_l <= 0;			//active on 0
				counter_l <= counter_l + 1;
				end
			else begin
				counter_l <= counter_l + 1;
				full_load_l <= 1;
				end
			memorie_real_l_out [counter_l] <= source_real_l;
			memorie_imag_l_out [counter_l] <= source_imag_l;
		end

always @ (negedge clk_fft_r)
	if (source_ready_r == 1 && source_valid_r == 1)
		begin
			if (source_sop_r == 1) begin
				counter_r <= 0;
				full_load_r <= 1;
				counter_r <= counter_r + 1;
				end
			else if (counter_r == 127) begin
				full_load_r <= 0;			//active on 0
				counter_r <= counter_r + 1;
				end
			else begin
				counter_r <= counter_r + 1;
				full_load_r <= 1;
				end
			memorie_real_r_out [counter_r] <= source_real_r;
			memorie_imag_r_out [counter_r] <= source_imag_r;
		end
	/*	
		always @ (*)
		  if (full_load_l == 0)////////////////
		   begin
		    memorie_imag_l_out[0] = memorie_imag_l[0];
		    memorie_real_l_out[0] = memorie_real_l[0];
		    memorie_imag_l_out[1] = memorie_imag_l[1];
		    memorie_real_l_out[1] = memorie_real_l[1];
		    memorie_imag_l_out[2] = memorie_imag_l[2];
		    memorie_real_l_out[2] = memorie_real_l[2];
		    memorie_imag_l_out[3] = memorie_imag_l[3];
		    memorie_real_l_out[3] = memorie_real_l[3];
		    memorie_imag_l_out[4] = memorie_imag_l[4];
		    memorie_real_l_out[4] = memorie_real_l[4];
		    memorie_imag_l_out[5] = memorie_imag_l[5];
		    memorie_real_l_out[5] = memorie_real_l[5];
		    memorie_imag_l_out[6] = memorie_imag_l[6];
		    memorie_real_l_out[6] = memorie_real_l[6];
		    memorie_imag_l_out[7] = memorie_imag_l[7];
		    memorie_real_l_out[7] = memorie_real_l[7];
		    memorie_imag_l_out[8] = memorie_imag_l[8];
		    memorie_real_l_out[8] = memorie_real_l[8];
		    memorie_imag_l_out[9] = memorie_imag_l[9];
		    memorie_real_l_out[9] = memorie_real_l[9];
		    memorie_imag_l_out[10] = memorie_imag_l[10];
		    memorie_real_l_out[10] = memorie_real_l[10];
		    memorie_imag_l_out[11] = memorie_imag_l[11];
		    memorie_real_l_out[11] = memorie_real_l[11];
		    memorie_imag_l_out[12] = memorie_imag_l[12];
		    memorie_real_l_out[12] = memorie_real_l[12];
		    memorie_imag_l_out[13] = memorie_imag_l[13];
		    memorie_real_l_out[13] = memorie_real_l[13];
		    memorie_imag_l_out[14] = memorie_imag_l[14];
		    memorie_real_l_out[14] = memorie_real_l[14];
		    memorie_imag_l_out[15] = memorie_imag_l[15];
		    memorie_real_l_out[15] = memorie_real_l[15];
		    memorie_imag_l_out[16] = memorie_imag_l[16];
		    memorie_real_l_out[16] = memorie_real_l[16];
		    memorie_imag_l_out[17] = memorie_imag_l[17];
		    memorie_real_l_out[17] = memorie_real_l[17];
		    memorie_imag_l_out[18] = memorie_imag_l[18];
		    memorie_real_l_out[18] = memorie_real_l[18];
		    memorie_imag_l_out[19] = memorie_imag_l[19];
		    memorie_real_l_out[19] = memorie_real_l[19];
		    memorie_imag_l_out[20] = memorie_imag_l[20];
		    memorie_real_l_out[20] = memorie_real_l[20];
		    memorie_imag_l_out[21] = memorie_imag_l[21];
		    memorie_real_l_out[21] = memorie_real_l[21];
		    memorie_imag_l_out[22] = memorie_imag_l[22];
		    memorie_real_l_out[22] = memorie_real_l[22];
		    memorie_imag_l_out[23] = memorie_imag_l[23];
		    memorie_real_l_out[23] = memorie_real_l[23];
		    memorie_imag_l_out[24] = memorie_imag_l[24];
		    memorie_real_l_out[24] = memorie_real_l[24];
		    memorie_imag_l_out[25] = memorie_imag_l[25];
		    memorie_real_l_out[25] = memorie_real_l[25];
		    memorie_imag_l_out[26] = memorie_imag_l[26];
		    memorie_real_l_out[26] = memorie_real_l[26];
		    memorie_imag_l_out[27] = memorie_imag_l[27];
		    memorie_real_l_out[27] = memorie_real_l[27];
		    memorie_imag_l_out[28] = memorie_imag_l[28];
		    memorie_real_l_out[28] = memorie_real_l[28];
		    memorie_imag_l_out[29] = memorie_imag_l[29];
		    memorie_real_l_out[29] = memorie_real_l[29];
		    memorie_imag_l_out[30] = memorie_imag_l[30];
		    memorie_real_l_out[30] = memorie_real_l[30];
		    memorie_imag_l_out[31] = memorie_imag_l[31];
		    memorie_real_l_out[31] = memorie_real_l[31];
		    memorie_imag_l_out[32] = memorie_imag_l[32];
		    memorie_real_l_out[32] = memorie_real_l[32];
			 memorie_imag_l_out[33] = memorie_imag_l[33];
		    memorie_real_l_out[33] = memorie_real_l[33];
			 memorie_imag_l_out[34] = memorie_imag_l[34];
		    memorie_real_l_out[34] = memorie_real_l[34];
			 memorie_imag_l_out[35] = memorie_imag_l[35];
		    memorie_real_l_out[35] = memorie_real_l[35];
			 memorie_imag_l_out[36] = memorie_imag_l[36];
		    memorie_real_l_out[36] = memorie_real_l[36];
			 memorie_imag_l_out[37] = memorie_imag_l[37];
		    memorie_real_l_out[37] = memorie_real_l[37];
			 memorie_imag_l_out[38] = memorie_imag_l[38];
		    memorie_real_l_out[38] = memorie_real_l[38];
			 memorie_imag_l_out[39] = memorie_imag_l[39];
		    memorie_real_l_out[39] = memorie_real_l[39];
			 memorie_imag_l_out[40] = memorie_imag_l[40];
		    memorie_real_l_out[40] = memorie_real_l[40];
			 memorie_imag_l_out[41] = memorie_imag_l[41];
		    memorie_real_l_out[41] = memorie_real_l[41];
			 memorie_imag_l_out[42] = memorie_imag_l[42];
		    memorie_real_l_out[42] = memorie_real_l[42];
			 memorie_imag_l_out[43] = memorie_imag_l[43];
		    memorie_real_l_out[43] = memorie_real_l[43];
			 memorie_imag_l_out[44] = memorie_imag_l[44];
		    memorie_real_l_out[44] = memorie_real_l[44];
			 memorie_imag_l_out[45] = memorie_imag_l[45];
		    memorie_real_l_out[45] = memorie_real_l[45];
			 memorie_imag_l_out[46] = memorie_imag_l[46];
		    memorie_real_l_out[46] = memorie_real_l[46];
			 memorie_imag_l_out[47] = memorie_imag_l[47];
		    memorie_real_l_out[47] = memorie_real_l[47];
			 memorie_imag_l_out[48] = memorie_imag_l[48];
		    memorie_real_l_out[48] = memorie_real_l[48];
			 memorie_imag_l_out[49] = memorie_imag_l[49];
		    memorie_real_l_out[49] = memorie_real_l[49];
			 memorie_imag_l_out[50] = memorie_imag_l[50];
		    memorie_real_l_out[50] = memorie_real_l[50];
			 memorie_imag_l_out[51] = memorie_imag_l[51];
		    memorie_real_l_out[51] = memorie_real_l[51];
			 memorie_imag_l_out[52] = memorie_imag_l[52];
		    memorie_real_l_out[52] = memorie_real_l[52];
			 memorie_imag_l_out[53] = memorie_imag_l[53];
		    memorie_real_l_out[53] = memorie_real_l[53];
			 memorie_imag_l_out[54] = memorie_imag_l[54];
		    memorie_real_l_out[54] = memorie_real_l[54];
			 memorie_imag_l_out[55] = memorie_imag_l[55];
		    memorie_real_l_out[55] = memorie_real_l[55];
			 memorie_imag_l_out[56] = memorie_imag_l[56];
		    memorie_real_l_out[56] = memorie_real_l[56];
			 memorie_imag_l_out[57] = memorie_imag_l[57];
		    memorie_real_l_out[57] = memorie_real_l[57];
			 memorie_imag_l_out[58] = memorie_imag_l[58];
		    memorie_real_l_out[58] = memorie_real_l[58];
			 memorie_imag_l_out[59] = memorie_imag_l[59];
		    memorie_real_l_out[59] = memorie_real_l[59];
			 memorie_imag_l_out[60] = memorie_imag_l[60];
		    memorie_real_l_out[60] = memorie_real_l[60];
			 memorie_imag_l_out[61] = memorie_imag_l[61];
		    memorie_real_l_out[61] = memorie_real_l[61];
			 memorie_imag_l_out[62] = memorie_imag_l[62];
		    memorie_real_l_out[62] = memorie_real_l[62];
			 memorie_imag_l_out[63] = memorie_imag_l[63];
		    memorie_real_l_out[63] = memorie_real_l[63];
			 memorie_imag_l_out[64] = memorie_imag_l[64];
		    memorie_real_l_out[64] = memorie_real_l[64];
			 memorie_imag_l_out[65] = memorie_imag_l[65];
		    memorie_real_l_out[65] = memorie_real_l[65];
			 memorie_imag_l_out[66] = memorie_imag_l[66];
		    memorie_real_l_out[66] = memorie_real_l[66];
			 memorie_imag_l_out[67] = memorie_imag_l[67];
		    memorie_real_l_out[67] = memorie_real_l[67];
			 memorie_imag_l_out[68] = memorie_imag_l[68];
		    memorie_real_l_out[68] = memorie_real_l[68];
			 memorie_imag_l_out[69] = memorie_imag_l[69];
		    memorie_real_l_out[69] = memorie_real_l[69];
			 memorie_imag_l_out[70] = memorie_imag_l[70];
		    memorie_real_l_out[70] = memorie_real_l[70];
			 memorie_imag_l_out[71] = memorie_imag_l[71];
		    memorie_real_l_out[71] = memorie_real_l[71];
			 memorie_imag_l_out[72] = memorie_imag_l[72];
		    memorie_real_l_out[72] = memorie_real_l[72];
			 memorie_imag_l_out[73] = memorie_imag_l[73];
		    memorie_real_l_out[73] = memorie_real_l[73];
			 memorie_imag_l_out[74] = memorie_imag_l[74];
		    memorie_real_l_out[74] = memorie_real_l[74];
			 memorie_imag_l_out[75] = memorie_imag_l[75];
		    memorie_real_l_out[75] = memorie_real_l[75];
			 memorie_imag_l_out[76] = memorie_imag_l[76];
		    memorie_real_l_out[76] = memorie_real_l[76];
			 memorie_imag_l_out[77] = memorie_imag_l[77];
		    memorie_real_l_out[77] = memorie_real_l[77];
			 memorie_imag_l_out[78] = memorie_imag_l[78];
		    memorie_real_l_out[78] = memorie_real_l[78];
			 memorie_imag_l_out[79] = memorie_imag_l[79];
		    memorie_real_l_out[79] = memorie_real_l[79];
			 memorie_imag_l_out[80] = memorie_imag_l[80];
		    memorie_real_l_out[80] = memorie_real_l[80];
			 memorie_imag_l_out[81] = memorie_imag_l[81];
		    memorie_real_l_out[81] = memorie_real_l[81];
			 memorie_imag_l_out[82] = memorie_imag_l[82];
		    memorie_real_l_out[82] = memorie_real_l[82];
			 memorie_imag_l_out[83] = memorie_imag_l[83];
		    memorie_real_l_out[83] = memorie_real_l[83];
			 memorie_imag_l_out[84] = memorie_imag_l[84];
		    memorie_real_l_out[84] = memorie_real_l[84];
			 memorie_imag_l_out[85] = memorie_imag_l[85];
		    memorie_real_l_out[85] = memorie_real_l[85];
			 memorie_imag_l_out[86] = memorie_imag_l[86];
		    memorie_real_l_out[86] = memorie_real_l[86];
			 memorie_imag_l_out[87] = memorie_imag_l[87];
		    memorie_real_l_out[87] = memorie_real_l[87];
			 memorie_imag_l_out[88] = memorie_imag_l[88];
		    memorie_real_l_out[88] = memorie_real_l[88];
			 memorie_imag_l_out[89] = memorie_imag_l[89];
		    memorie_real_l_out[89] = memorie_real_l[89];
			 memorie_imag_l_out[90] = memorie_imag_l[90];
		    memorie_real_l_out[90] = memorie_real_l[90];
			 memorie_imag_l_out[91] = memorie_imag_l[91];
		    memorie_real_l_out[91] = memorie_real_l[91];
			 memorie_imag_l_out[92] = memorie_imag_l[92];
		    memorie_real_l_out[92] = memorie_real_l[92];
			 memorie_imag_l_out[93] = memorie_imag_l[93];
		    memorie_real_l_out[93] = memorie_real_l[93];
			 memorie_imag_l_out[94] = memorie_imag_l[94];
		    memorie_real_l_out[94] = memorie_real_l[94];
			 memorie_imag_l_out[95] = memorie_imag_l[95];
		    memorie_real_l_out[95] = memorie_real_l[95];
			 memorie_imag_l_out[96] = memorie_imag_l[96];
		    memorie_real_l_out[96] = memorie_real_l[96];
			 memorie_imag_l_out[97] = memorie_imag_l[97];
		    memorie_real_l_out[97] = memorie_real_l[97];
			 memorie_imag_l_out[98] = memorie_imag_l[98];
		    memorie_real_l_out[98] = memorie_real_l[98];
			 memorie_imag_l_out[99] = memorie_imag_l[99];
		    memorie_real_l_out[99] = memorie_real_l[99];
			 memorie_imag_l_out[100] = memorie_imag_l[100];
		    memorie_real_l_out[100] = memorie_real_l[100];
			 memorie_imag_l_out[101] = memorie_imag_l[101];
		    memorie_real_l_out[101] = memorie_real_l[101];
			 memorie_imag_l_out[102] = memorie_imag_l[102];
		    memorie_real_l_out[102] = memorie_real_l[102];
			 memorie_imag_l_out[103] = memorie_imag_l[103];
		    memorie_real_l_out[103] = memorie_real_l[103];
			 memorie_imag_l_out[104] = memorie_imag_l[104];
		    memorie_real_l_out[104] = memorie_real_l[104];
			 memorie_imag_l_out[105] = memorie_imag_l[105];
		    memorie_real_l_out[105] = memorie_real_l[105];
			 memorie_imag_l_out[106] = memorie_imag_l[106];
		    memorie_real_l_out[106] = memorie_real_l[106];
			 memorie_imag_l_out[107] = memorie_imag_l[107];
		    memorie_real_l_out[107] = memorie_real_l[107];
			 memorie_imag_l_out[108] = memorie_imag_l[108];
		    memorie_real_l_out[108] = memorie_real_l[108];
			 memorie_imag_l_out[109] = memorie_imag_l[109];
		    memorie_real_l_out[109] = memorie_real_l[109];
			 memorie_imag_l_out[110] = memorie_imag_l[110];
		    memorie_real_l_out[110] = memorie_real_l[110];
			 memorie_imag_l_out[111] = memorie_imag_l[111];
		    memorie_real_l_out[111] = memorie_real_l[111];
			 memorie_imag_l_out[112] = memorie_imag_l[112];
		    memorie_real_l_out[112] = memorie_real_l[112];
			 memorie_imag_l_out[113] = memorie_imag_l[113];
		    memorie_real_l_out[113] = memorie_real_l[113];
			 memorie_imag_l_out[114] = memorie_imag_l[114];
		    memorie_real_l_out[114] = memorie_real_l[114];
			 memorie_imag_l_out[115] = memorie_imag_l[115];
		    memorie_real_l_out[115] = memorie_real_l[115];
			 memorie_imag_l_out[116] = memorie_imag_l[116];
		    memorie_real_l_out[116] = memorie_real_l[116];
			 memorie_imag_l_out[117] = memorie_imag_l[117];
		    memorie_real_l_out[117] = memorie_real_l[117];
			 memorie_imag_l_out[118] = memorie_imag_l[118];
		    memorie_real_l_out[118] = memorie_real_l[118];
			 memorie_imag_l_out[119] = memorie_imag_l[119];
		    memorie_real_l_out[119] = memorie_real_l[119];
			 memorie_imag_l_out[120] = memorie_imag_l[120];
		    memorie_real_l_out[120] = memorie_real_l[120];
			 memorie_imag_l_out[121] = memorie_imag_l[121];
		    memorie_real_l_out[121] = memorie_real_l[121];
			 memorie_imag_l_out[122] = memorie_imag_l[122];
		    memorie_real_l_out[122] = memorie_real_l[122];
			 memorie_imag_l_out[123] = memorie_imag_l[123];
		    memorie_real_l_out[123] = memorie_real_l[123];
			 memorie_imag_l_out[124] = memorie_imag_l[124];
		    memorie_real_l_out[124] = memorie_real_l[124];
			 memorie_imag_l_out[125] = memorie_imag_l[125];
		    memorie_real_l_out[125] = memorie_real_l[125];
			 memorie_imag_l_out[126] = memorie_imag_l[126];
		    memorie_real_l_out[126] = memorie_real_l[126];
			 memorie_imag_l_out[127] = memorie_imag_l[127];
		    memorie_real_l_out[127] = memorie_real_l[127];
			end
		else ;
	
always @(*)
		if(full_load_r == 0)
			begin
			 memorie_imag_r_out[0] = memorie_imag_r[0];
		    memorie_real_r_out[0] = memorie_real_r[0];
		    memorie_imag_r_out[1] = memorie_imag_r[1];
		    memorie_real_r_out[1] = memorie_real_r[1];
		    memorie_imag_r_out[2] = memorie_imag_r[2];
		    memorie_real_r_out[2] = memorie_real_r[2];
		    memorie_imag_r_out[3] = memorie_imag_r[3];
		    memorie_real_r_out[3] = memorie_real_r[3];
		    memorie_imag_r_out[4] = memorie_imag_r[4];
		    memorie_real_r_out[4] = memorie_real_r[4];
		    memorie_imag_r_out[5] = memorie_imag_r[5];
		    memorie_real_r_out[5] = memorie_real_r[5];
		    memorie_imag_r_out[6] = memorie_imag_r[6];
		    memorie_real_r_out[6] = memorie_real_r[6];
		    memorie_imag_r_out[7] = memorie_imag_r[7];
		    memorie_real_r_out[7] = memorie_real_r[7];
		    memorie_imag_r_out[8] = memorie_imag_r[8];
		    memorie_real_r_out[8] = memorie_real_r[8];
		    memorie_imag_r_out[9] = memorie_imag_r[9];
		    memorie_real_r_out[9] = memorie_real_r[9];
		    memorie_imag_r_out[10] = memorie_imag_r[10];
		    memorie_real_r_out[10] = memorie_real_r[10];
		    memorie_imag_r_out[11] = memorie_imag_r[11];
		    memorie_real_r_out[11] = memorie_real_r[11];
		    memorie_imag_r_out[12] = memorie_imag_r[12];
		    memorie_real_r_out[12] = memorie_real_r[12];
		    memorie_imag_r_out[13] = memorie_imag_r[13];
		    memorie_real_r_out[13] = memorie_real_r[13];
		    memorie_imag_r_out[14] = memorie_imag_r[14];
		    memorie_real_r_out[14] = memorie_real_r[14];
		    memorie_imag_r_out[15] = memorie_imag_r[15];
		    memorie_real_r_out[15] = memorie_real_r[15];
		    memorie_imag_r_out[16] = memorie_imag_r[16];
		    memorie_real_r_out[16] = memorie_real_r[16];
		    memorie_imag_r_out[17] = memorie_imag_r[17];
		    memorie_real_r_out[17] = memorie_real_r[17];
		    memorie_imag_r_out[18] = memorie_imag_r[18];
		    memorie_real_r_out[18] = memorie_real_r[18];
		    memorie_imag_r_out[19] = memorie_imag_r[19];
		    memorie_real_r_out[19] = memorie_real_r[19];
		    memorie_imag_r_out[20] = memorie_imag_r[20];
		    memorie_real_r_out[20] = memorie_real_r[20];
		    memorie_imag_r_out[21] = memorie_imag_r[21];
		    memorie_real_r_out[21] = memorie_real_r[21];
		    memorie_imag_r_out[22] = memorie_imag_r[22];
		    memorie_real_r_out[22] = memorie_real_r[22];
		    memorie_imag_r_out[23] = memorie_imag_r[23];
		    memorie_real_r_out[23] = memorie_real_r[23];
		    memorie_imag_r_out[24] = memorie_imag_r[24];
		    memorie_real_r_out[24] = memorie_real_r[24];
		    memorie_imag_r_out[25] = memorie_imag_r[25];
		    memorie_real_r_out[25] = memorie_real_r[25];
		    memorie_imag_r_out[26] = memorie_imag_r[26];
		    memorie_real_r_out[26] = memorie_real_r[26];
		    memorie_imag_r_out[27] = memorie_imag_r[27];
		    memorie_real_r_out[27] = memorie_real_r[27];
		    memorie_imag_r_out[28] = memorie_imag_r[28];
		    memorie_real_r_out[28] = memorie_real_r[28];
		    memorie_imag_r_out[29] = memorie_imag_r[29];
		    memorie_real_r_out[29] = memorie_real_r[29];
		    memorie_imag_r_out[30] = memorie_imag_r[30];
		    memorie_real_r_out[30] = memorie_real_r[30];
		    memorie_imag_r_out[31] = memorie_imag_r[31];
		    memorie_real_r_out[31] = memorie_real_r[31];
		    memorie_imag_r_out[32] = memorie_imag_r[32];
		    memorie_real_r_out[32] = memorie_real_r[32];
			 memorie_imag_r_out[33] = memorie_imag_r[33];
		    memorie_real_r_out[33] = memorie_real_r[33];
			 memorie_imag_r_out[34] = memorie_imag_r[34];
		    memorie_real_r_out[34] = memorie_real_r[34];
			 memorie_imag_r_out[35] = memorie_imag_r[35];
		    memorie_real_r_out[35] = memorie_real_r[35];
			 memorie_imag_r_out[36] = memorie_imag_r[36];
		    memorie_real_r_out[36] = memorie_real_r[36];
			 memorie_imag_r_out[37] = memorie_imag_r[37];
		    memorie_real_r_out[37] = memorie_real_r[37];
			 memorie_imag_r_out[38] = memorie_imag_r[38];
		    memorie_real_r_out[38] = memorie_real_r[38];
			 memorie_imag_r_out[39] = memorie_imag_r[39];
		    memorie_real_r_out[39] = memorie_real_r[39];
			 memorie_imag_r_out[40] = memorie_imag_r[40];
		    memorie_real_r_out[40] = memorie_real_r[40];
			 memorie_imag_r_out[41] = memorie_imag_r[41];
		    memorie_real_r_out[41] = memorie_real_r[41];
			 memorie_imag_r_out[42] = memorie_imag_r[42];
		    memorie_real_r_out[42] = memorie_real_r[42];
			 memorie_imag_r_out[43] = memorie_imag_r[43];
		    memorie_real_r_out[43] = memorie_real_r[43];
			 memorie_imag_r_out[44] = memorie_imag_r[44];
		    memorie_real_r_out[44] = memorie_real_r[44];
			 memorie_imag_r_out[45] = memorie_imag_r[45];
		    memorie_real_r_out[45] = memorie_real_r[45];
			 memorie_imag_r_out[46] = memorie_imag_r[46];
		    memorie_real_r_out[46] = memorie_real_r[46];
			 memorie_imag_r_out[47] = memorie_imag_r[47];
		    memorie_real_r_out[47] = memorie_real_r[47];
			 memorie_imag_r_out[48] = memorie_imag_r[48];
		    memorie_real_r_out[48] = memorie_real_r[48];
			 memorie_imag_r_out[49] = memorie_imag_r[49];
		    memorie_real_r_out[49] = memorie_real_r[49];
			 memorie_imag_r_out[50] = memorie_imag_r[50];
		    memorie_real_r_out[50] = memorie_real_r[50];
			 memorie_imag_r_out[51] = memorie_imag_r[51];
		    memorie_real_r_out[51] = memorie_real_r[51];
			 memorie_imag_r_out[52] = memorie_imag_r[52];
		    memorie_real_r_out[52] = memorie_real_r[52];
			 memorie_imag_r_out[53] = memorie_imag_r[53];
		    memorie_real_r_out[53] = memorie_real_r[53];
			 memorie_imag_r_out[54] = memorie_imag_r[54];
		    memorie_real_r_out[54] = memorie_real_r[54];
			 memorie_imag_r_out[55] = memorie_imag_r[55];
		    memorie_real_r_out[55] = memorie_real_r[55];
			 memorie_imag_r_out[56] = memorie_imag_r[56];
		    memorie_real_r_out[56] = memorie_real_r[56];
			 memorie_imag_r_out[57] = memorie_imag_r[57];
		    memorie_real_r_out[57] = memorie_real_r[57];
			 memorie_imag_r_out[58] = memorie_imag_r[58];
		    memorie_real_r_out[58] = memorie_real_r[58];
			 memorie_imag_r_out[59] = memorie_imag_r[59];
		    memorie_real_r_out[59] = memorie_real_r[59];
			 memorie_imag_r_out[60] = memorie_imag_r[60];
		    memorie_real_r_out[60] = memorie_real_r[60];
			 memorie_imag_r_out[61] = memorie_imag_r[61];
		    memorie_real_r_out[61] = memorie_real_r[61];
			 memorie_imag_r_out[62] = memorie_imag_r[62];
		    memorie_real_r_out[62] = memorie_real_r[62];
			 memorie_imag_r_out[63] = memorie_imag_r[63];
		    memorie_real_r_out[63] = memorie_real_r[63];
			 memorie_imag_r_out[64] = memorie_imag_r[64];
		    memorie_real_r_out[64] = memorie_real_r[64];
			 memorie_imag_r_out[65] = memorie_imag_r[65];
		    memorie_real_r_out[65] = memorie_real_r[65];
			 memorie_imag_r_out[66] = memorie_imag_r[66];
		    memorie_real_r_out[66] = memorie_real_r[66];
			 memorie_imag_r_out[67] = memorie_imag_r[67];
		    memorie_real_r_out[67] = memorie_real_r[67];
			 memorie_imag_r_out[68] = memorie_imag_r[68];
		    memorie_real_r_out[68] = memorie_real_r[68];
			 memorie_imag_r_out[69] = memorie_imag_r[69];
		    memorie_real_r_out[69] = memorie_real_r[69];
			 memorie_imag_r_out[70] = memorie_imag_r[70];
		    memorie_real_r_out[70] = memorie_real_r[70];
			 memorie_imag_r_out[71] = memorie_imag_r[71];
		    memorie_real_r_out[71] = memorie_real_r[71];
			 memorie_imag_r_out[72] = memorie_imag_r[72];
		    memorie_real_r_out[72] = memorie_real_r[72];
			 memorie_imag_r_out[73] = memorie_imag_r[73];
		    memorie_real_r_out[73] = memorie_real_r[73];
			 memorie_imag_r_out[74] = memorie_imag_r[74];
		    memorie_real_r_out[74] = memorie_real_r[74];
			 memorie_imag_r_out[75] = memorie_imag_r[75];
		    memorie_real_r_out[75] = memorie_real_r[75];
			 memorie_imag_r_out[76] = memorie_imag_r[76];
		    memorie_real_r_out[76] = memorie_real_r[76];
			 memorie_imag_r_out[77] = memorie_imag_r[77];
		    memorie_real_r_out[77] = memorie_real_r[77];
			 memorie_imag_r_out[78] = memorie_imag_r[78];
		    memorie_real_r_out[78] = memorie_real_r[78];
			 memorie_imag_r_out[79] = memorie_imag_r[79];
		    memorie_real_r_out[79] = memorie_real_r[79];
			 memorie_imag_r_out[80] = memorie_imag_r[80];
		    memorie_real_r_out[80] = memorie_real_r[80];
			 memorie_imag_r_out[81] = memorie_imag_r[81];
		    memorie_real_r_out[81] = memorie_real_r[81];
			 memorie_imag_r_out[82] = memorie_imag_r[82];
		    memorie_real_r_out[82] = memorie_real_r[82];
			 memorie_imag_r_out[83] = memorie_imag_r[83];
		    memorie_real_r_out[83] = memorie_real_r[83];
			 memorie_imag_r_out[84] = memorie_imag_r[84];
		    memorie_real_r_out[84] = memorie_real_r[84];
			 memorie_imag_r_out[85] = memorie_imag_r[85];
		    memorie_real_r_out[85] = memorie_real_r[85];
			 memorie_imag_r_out[86] = memorie_imag_r[86];
		    memorie_real_r_out[86] = memorie_real_r[86];
			 memorie_imag_r_out[87] = memorie_imag_r[87];
		    memorie_real_r_out[87] = memorie_real_r[87];
			 memorie_imag_r_out[88] = memorie_imag_r[88];
		    memorie_real_r_out[88] = memorie_real_r[88];
			 memorie_imag_r_out[89] = memorie_imag_r[89];
		    memorie_real_r_out[89] = memorie_real_r[89];
			 memorie_imag_r_out[90] = memorie_imag_r[90];
		    memorie_real_r_out[90] = memorie_real_r[90];
			 memorie_imag_r_out[91] = memorie_imag_r[91];
		    memorie_real_r_out[91] = memorie_real_r[91];
			 memorie_imag_r_out[92] = memorie_imag_r[92];
		    memorie_real_r_out[92] = memorie_real_r[92];
			 memorie_imag_r_out[93] = memorie_imag_r[93];
		    memorie_real_r_out[93] = memorie_real_r[93];
			 memorie_imag_r_out[94] = memorie_imag_r[94];
		    memorie_real_r_out[94] = memorie_real_r[94];
			 memorie_imag_r_out[95] = memorie_imag_r[95];
		    memorie_real_r_out[95] = memorie_real_r[95];
			 memorie_imag_r_out[96] = memorie_imag_r[96];
		    memorie_real_r_out[96] = memorie_real_r[96];
			 memorie_imag_r_out[97] = memorie_imag_r[97];
		    memorie_real_r_out[97] = memorie_real_r[97];
			 memorie_imag_r_out[98] = memorie_imag_r[98];
		    memorie_real_r_out[98] = memorie_real_r[98];
			 memorie_imag_r_out[99] = memorie_imag_r[99];
		    memorie_real_r_out[99] = memorie_real_r[99];
			 memorie_imag_r_out[100] = memorie_imag_r[100];
		    memorie_real_r_out[100] = memorie_real_r[100];
			 memorie_imag_r_out[101] = memorie_imag_r[101];
		    memorie_real_r_out[101] = memorie_real_r[101];
			 memorie_imag_r_out[102] = memorie_imag_r[102];
		    memorie_real_r_out[102] = memorie_real_r[102];
			 memorie_imag_r_out[103] = memorie_imag_r[103];
		    memorie_real_r_out[103] = memorie_real_r[103];
			 memorie_imag_r_out[104] = memorie_imag_r[104];
		    memorie_real_r_out[104] = memorie_real_r[104];
			 memorie_imag_r_out[105] = memorie_imag_r[105];
		    memorie_real_r_out[105] = memorie_real_r[105];
			 memorie_imag_r_out[106] = memorie_imag_r[106];
		    memorie_real_r_out[106] = memorie_real_r[106];
			 memorie_imag_r_out[107] = memorie_imag_r[107];
		    memorie_real_r_out[107] = memorie_real_r[107];
			 memorie_imag_r_out[108] = memorie_imag_r[108];
		    memorie_real_r_out[108] = memorie_real_r[108];
			 memorie_imag_r_out[109] = memorie_imag_r[109];
		    memorie_real_r_out[109] = memorie_real_r[109];
			 memorie_imag_r_out[110] = memorie_imag_r[110];
		    memorie_real_r_out[110] = memorie_real_r[110];
			 memorie_imag_r_out[111] = memorie_imag_r[111];
		    memorie_real_r_out[111] = memorie_real_r[111];
			 memorie_imag_r_out[112] = memorie_imag_r[112];
		    memorie_real_r_out[112] = memorie_real_r[112];
			 memorie_imag_r_out[113] = memorie_imag_r[113];
		    memorie_real_r_out[113] = memorie_real_r[113];
			 memorie_imag_r_out[114] = memorie_imag_r[114];
		    memorie_real_r_out[114] = memorie_real_r[114];
			 memorie_imag_r_out[115] = memorie_imag_r[115];
		    memorie_real_r_out[115] = memorie_real_r[115];
			 memorie_imag_r_out[116] = memorie_imag_r[116];
		    memorie_real_r_out[116] = memorie_real_r[116];
			 memorie_imag_r_out[117] = memorie_imag_r[117];
		    memorie_real_r_out[117] = memorie_real_r[117];
			 memorie_imag_r_out[118] = memorie_imag_r[118];
		    memorie_real_r_out[118] = memorie_real_r[118];
			 memorie_imag_r_out[119] = memorie_imag_r[119];
		    memorie_real_r_out[119] = memorie_real_r[119];
			 memorie_imag_r_out[120] = memorie_imag_r[120];
		    memorie_real_r_out[120] = memorie_real_r[120];
			 memorie_imag_r_out[121] = memorie_imag_r[121];
		    memorie_real_r_out[121] = memorie_real_r[121];
			 memorie_imag_r_out[122] = memorie_imag_r[122];
		    memorie_real_r_out[122] = memorie_real_r[122];
			 memorie_imag_r_out[123] = memorie_imag_r[123];
		    memorie_real_r_out[123] = memorie_real_r[123];
			 memorie_imag_r_out[124] = memorie_imag_r[124];
		    memorie_real_r_out[124] = memorie_real_r[124];
			 memorie_imag_r_out[125] = memorie_imag_r[125];
		    memorie_real_r_out[125] = memorie_real_r[125];
			 memorie_imag_r_out[126] = memorie_imag_r[126];
		    memorie_real_r_out[126] = memorie_real_r[126];
			 memorie_imag_r_out[127] = memorie_imag_r[127];
		    memorie_real_r_out[127] = memorie_real_r[127]; 
		   end
		  else;*/
		
////////////calculation of amplitude///////////////
//assign fft_1 = 2524921;
assign fft_1 = (((memorie_real_r_out[64] + memorie_real_l_out[64])>>1)**2) + (((memorie_imag_r_out[64] + memorie_imag_l_out[64])>>1)**2);
assign fft_2 = (((memorie_real_r_out[65] + memorie_real_l_out[65])>>1)**2) + (((memorie_imag_r_out[65] + memorie_imag_l_out[65])>>1)**2);
assign fft_3 = (((memorie_real_r_out[66] + memorie_real_l_out[66])>>1)**2) + (((memorie_imag_r_out[66] + memorie_imag_l_out[66])>>1)**2);
assign fft_4 = (((memorie_real_r_out[67] + memorie_real_l_out[67])>>1)**2) + (((memorie_imag_r_out[67] + memorie_imag_l_out[67])>>1)**2);
assign fft_5 = (((memorie_real_r_out[68] + memorie_real_l_out[68])>>1)**2) + (((memorie_imag_r_out[68] + memorie_imag_l_out[68])>>1)**2);
assign fft_6 = (((memorie_real_r_out[69] + memorie_real_l_out[69])>>1)**2) + (((memorie_imag_r_out[69] + memorie_imag_l_out[69])>>1)**2);
assign fft_7 = (((memorie_real_r_out[70] + memorie_real_l_out[70])>>1)**2) + (((memorie_imag_r_out[70] + memorie_imag_l_out[70])>>1)**2);
assign fft_8 = (((memorie_real_r_out[71] + memorie_real_l_out[71])>>1)**2) + (((memorie_imag_r_out[71] + memorie_imag_l_out[71])>>1)**2);
assign fft_9 = (((memorie_real_r_out[72] + memorie_real_l_out[72])>>1)**2) + (((memorie_imag_r_out[72] + memorie_imag_l_out[72])>>1)**2);
assign fft_10 = (((memorie_real_r_out[73] + memorie_real_l_out[73])>>1)**2) + (((memorie_imag_r_out[73] + memorie_imag_l_out[73])>>1)**2);
assign fft_11 = (((memorie_real_r_out[74] + memorie_real_l_out[74])>>1)**2) + (((memorie_imag_r_out[74] + memorie_imag_l_out[74])>>1)**2);
assign fft_12 = (((memorie_real_r_out[75] + memorie_real_l_out[75])>>1)**2) + (((memorie_imag_r_out[75] + memorie_imag_l_out[75])>>1)**2);
assign fft_13 = (((memorie_real_r_out[76] + memorie_real_l_out[76])>>1)**2) + (((memorie_imag_r_out[76] + memorie_imag_l_out[76])>>1)**2);
assign fft_14 = (((memorie_real_r_out[77] + memorie_real_l_out[77])>>1)**2) + (((memorie_imag_r_out[77] + memorie_imag_l_out[77])>>1)**2);
assign fft_15 = (((memorie_real_r_out[78] + memorie_real_l_out[78])>>1)**2) + (((memorie_imag_r_out[78] + memorie_imag_l_out[78])>>1)**2);
assign fft_16 = (((memorie_real_r_out[79] + memorie_real_l_out[79])>>1)**2) + (((memorie_imag_r_out[79] + memorie_imag_l_out[79])>>1)**2);
assign fft_17 = (((memorie_real_r_out[80] + memorie_real_l_out[80])>>1)**2) + (((memorie_imag_r_out[80] + memorie_imag_l_out[80])>>1)**2);
assign fft_18 = (((memorie_real_r_out[81] + memorie_real_l_out[81])>>1)**2) + (((memorie_imag_r_out[81] + memorie_imag_l_out[81])>>1)**2);
assign fft_19 = (((memorie_real_r_out[82] + memorie_real_l_out[82])>>1)**2) + (((memorie_imag_r_out[82] + memorie_imag_l_out[82])>>1)**2);
assign fft_20 = (((memorie_real_r_out[83] + memorie_real_l_out[83])>>1)**2) + (((memorie_imag_r_out[83] + memorie_imag_l_out[83])>>1)**2);
assign fft_21 = (((memorie_real_r_out[84] + memorie_real_l_out[84])>>1)**2) + (((memorie_imag_r_out[84] + memorie_imag_l_out[84])>>1)**2);
assign fft_22 = (((memorie_real_r_out[85] + memorie_real_l_out[85])>>1)**2) + (((memorie_imag_r_out[85] + memorie_imag_l_out[85])>>1)**2);
assign fft_23 = (((memorie_real_r_out[86] + memorie_real_l_out[86])>>1)**2) + (((memorie_imag_r_out[86] + memorie_imag_l_out[86])>>1)**2);
assign fft_24 = (((memorie_real_r_out[87] + memorie_real_l_out[87])>>1)**2) + (((memorie_imag_r_out[87] + memorie_imag_l_out[87])>>1)**2);
assign fft_25 = (((memorie_real_r_out[88] + memorie_real_l_out[88])>>1)**2) + (((memorie_imag_r_out[88] + memorie_imag_l_out[88])>>1)**2);
assign fft_26 = (((memorie_real_r_out[89] + memorie_real_l_out[89])>>1)**2) + (((memorie_imag_r_out[89] + memorie_imag_l_out[89])>>1)**2);
assign fft_27 = (((memorie_real_r_out[90] + memorie_real_l_out[90])>>1)**2) + (((memorie_imag_r_out[90] + memorie_imag_l_out[90])>>1)**2);
assign fft_28 = (((memorie_real_r_out[91] + memorie_real_l_out[91])>>1)**2) + (((memorie_imag_r_out[91] + memorie_imag_l_out[91])>>1)**2);
assign fft_29 = (((memorie_real_r_out[92] + memorie_real_l_out[92])>>1)**2) + (((memorie_imag_r_out[92] + memorie_imag_l_out[92])>>1)**2);
assign fft_30 = (((memorie_real_r_out[93] + memorie_real_l_out[93])>>1)**2) + (((memorie_imag_r_out[93] + memorie_imag_l_out[93])>>1)**2);
assign fft_31 = (((memorie_real_r_out[94] + memorie_real_l_out[94])>>1)**2) + (((memorie_imag_r_out[94] + memorie_imag_l_out[94])>>1)**2);
assign fft_32 = (((memorie_real_r_out[95] + memorie_real_l_out[95])>>1)**2) + (((memorie_imag_r_out[95] + memorie_imag_l_out[95])>>1)**2);
assign fft_33 = (((memorie_real_r_out[96] + memorie_real_l_out[96])>>1)**2) + (((memorie_imag_r_out[96] + memorie_imag_l_out[96])>>1)**2);
assign fft_34 = (((memorie_real_r_out[97] + memorie_real_l_out[97])>>1)**2) + (((memorie_imag_r_out[97] + memorie_imag_l_out[97])>>1)**2);
assign fft_35 = (((memorie_real_r_out[98] + memorie_real_l_out[98])>>1)**2) + (((memorie_imag_r_out[98] + memorie_imag_l_out[98])>>1)**2);
assign fft_36 = (((memorie_real_r_out[99] + memorie_real_l_out[99])>>1)**2) + (((memorie_imag_r_out[99] + memorie_imag_l_out[99])>>1)**2);
assign fft_37 = (((memorie_real_r_out[100] + memorie_real_l_out[100])>>1)**2) + (((memorie_imag_r_out[100] + memorie_imag_l_out[100])>>1)**2);
assign fft_38 = (((memorie_real_r_out[101] + memorie_real_l_out[101])>>1)**2) + (((memorie_imag_r_out[101] + memorie_imag_l_out[101])>>1)**2);
assign fft_39 = (((memorie_real_r_out[102] + memorie_real_l_out[102])>>1)**2) + (((memorie_imag_r_out[102] + memorie_imag_l_out[102])>>1)**2);
assign fft_40 = (((memorie_real_r_out[103] + memorie_real_l_out[103])>>1)**2) + (((memorie_imag_r_out[103] + memorie_imag_l_out[103])>>1)**2);
assign fft_41 = (((memorie_real_r_out[104] + memorie_real_l_out[104])>>1)**2) + (((memorie_imag_r_out[104] + memorie_imag_l_out[104])>>1)**2);
assign fft_42 = (((memorie_real_r_out[105] + memorie_real_l_out[105])>>1)**2) + (((memorie_imag_r_out[105] + memorie_imag_l_out[105])>>1)**2);
assign fft_43 = (((memorie_real_r_out[106] + memorie_real_l_out[106])>>1)**2) + (((memorie_imag_r_out[106] + memorie_imag_l_out[106])>>1)**2);
assign fft_44 = (((memorie_real_r_out[107] + memorie_real_l_out[107])>>1)**2) + (((memorie_imag_r_out[107] + memorie_imag_l_out[107])>>1)**2);
assign fft_45 = (((memorie_real_r_out[108] + memorie_real_l_out[108])>>1)**2) + (((memorie_imag_r_out[108] + memorie_imag_l_out[108])>>1)**2);
assign fft_46 = (((memorie_real_r_out[109] + memorie_real_l_out[109])>>1)**2) + (((memorie_imag_r_out[109] + memorie_imag_l_out[109])>>1)**2);
assign fft_47 = (((memorie_real_r_out[110] + memorie_real_l_out[110])>>1)**2) + (((memorie_imag_r_out[110] + memorie_imag_l_out[110])>>1)**2);
assign fft_48 = (((memorie_real_r_out[111] + memorie_real_l_out[111])>>1)**2) + (((memorie_imag_r_out[111] + memorie_imag_l_out[111])>>1)**2);
assign fft_49 = (((memorie_real_r_out[112] + memorie_real_l_out[112])>>1)**2) + (((memorie_imag_r_out[112] + memorie_imag_l_out[112])>>1)**2);
assign fft_50 = (((memorie_real_r_out[113] + memorie_real_l_out[113])>>1)**2) + (((memorie_imag_r_out[113] + memorie_imag_l_out[113])>>1)**2);
assign fft_51 = (((memorie_real_r_out[114] + memorie_real_l_out[114])>>1)**2) + (((memorie_imag_r_out[114] + memorie_imag_l_out[114])>>1)**2);
assign fft_52 = (((memorie_real_r_out[115] + memorie_real_l_out[115])>>1)**2) + (((memorie_imag_r_out[115] + memorie_imag_l_out[115])>>1)**2);
assign fft_53 = (((memorie_real_r_out[116] + memorie_real_l_out[116])>>1)**2) + (((memorie_imag_r_out[116] + memorie_imag_l_out[116])>>1)**2);
assign fft_54 = (((memorie_real_r_out[117] + memorie_real_l_out[117])>>1)**2) + (((memorie_imag_r_out[117] + memorie_imag_l_out[117])>>1)**2);
assign fft_55 = (((memorie_real_r_out[118] + memorie_real_l_out[118])>>1)**2) + (((memorie_imag_r_out[118] + memorie_imag_l_out[118])>>1)**2);
assign fft_56 = (((memorie_real_r_out[119] + memorie_real_l_out[119])>>1)**2) + (((memorie_imag_r_out[119] + memorie_imag_l_out[119])>>1)**2);
assign fft_57 = (((memorie_real_r_out[120] + memorie_real_l_out[120])>>1)**2) + (((memorie_imag_r_out[120] + memorie_imag_l_out[120])>>1)**2);
assign fft_58 = (((memorie_real_r_out[121] + memorie_real_l_out[121])>>1)**2) + (((memorie_imag_r_out[121] + memorie_imag_l_out[121])>>1)**2);
assign fft_59 = (((memorie_real_r_out[122] + memorie_real_l_out[122])>>1)**2) + (((memorie_imag_r_out[122] + memorie_imag_l_out[122])>>1)**2);
assign fft_60 = (((memorie_real_r_out[123] + memorie_real_l_out[123])>>1)**2) + (((memorie_imag_r_out[123] + memorie_imag_l_out[123])>>1)**2);
assign fft_61 = (((memorie_real_r_out[124] + memorie_real_l_out[124])>>1)**2) + (((memorie_imag_r_out[124] + memorie_imag_l_out[124])>>1)**2);
assign fft_62 = (((memorie_real_r_out[125] + memorie_real_l_out[125])>>1)**2) + (((memorie_imag_r_out[125] + memorie_imag_l_out[125])>>1)**2);
assign fft_63 = (((memorie_real_r_out[126] + memorie_real_l_out[126])>>1)**2) + (((memorie_imag_r_out[126] + memorie_imag_l_out[126])>>1)**2);
assign fft_64 = (((memorie_real_r_out[127] + memorie_real_l_out[127])>>1)**2) + (((memorie_imag_r_out[127] + memorie_imag_l_out[127])>>1)**2);

sqrt sqrt_inst_1(
	fft_1,
	ampl_1,
	remainder_1);
sqrt sqrt_inst_2(
	fft_2,
	ampl_2,
	remainder_2);	
sqrt sqrt_inst_3(
	fft_3,
	ampl_3,
	remainder_3);	
sqrt sqrt_inst_4(
	fft_4,
	ampl_4,
	remainder_4);	
sqrt sqrt_inst_5(
	fft_5,
	ampl_5,
	remainder_5);	
sqrt sqrt_inst_6(
	fft_6,
	ampl_6,
	remainder_6);	
sqrt sqrt_inst_7(
	fft_7,
	ampl_7,
	remainder_7);	
sqrt sqrt_inst_8(
	fft_8,
	ampl_8,
	remainder_8);	
sqrt sqrt_inst_9(
	fft_9,
	ampl_9,
	remainder_9);	
sqrt sqrt_inst_10(
	fft_10,
	ampl_10,
	remainder_10);	
sqrt sqrt_inst_11(
	fft_11,
	ampl_11,
	remainder_11);	
sqrt sqrt_inst_12(
	fft_12,
	ampl_12,
	remainder_12);	
sqrt sqrt_inst_13(
	fft_13,
	ampl_13,
	remainder_13);	
sqrt sqrt_inst_14(
	fft_14,
	ampl_14,
	remainder_14);	
sqrt sqrt_inst_15(
	fft_15,
	ampl_15,
	remainder_15);	
sqrt sqrt_inst_16(
	fft_16,
	ampl_16,
	remainder_16);	
sqrt sqrt_inst_17(
	fft_17,
	ampl_17,
	remainder_17);	
sqrt sqrt_inst_18(
	fft_18,
	ampl_18,
	remainder_18);	
sqrt sqrt_inst_19(
	fft_19,
	ampl_19,
	remainder_19);	
sqrt sqrt_inst_20(
	fft_20,
	ampl_20,
	remainder_20);	
sqrt sqrt_inst_21(
	fft_21,
	ampl_21,
	remainder_21);	
sqrt sqrt_inst_22(
	fft_22,
	ampl_22,
	remainder_22);	
sqrt sqrt_inst_23(
	fft_23,
	ampl_23,
	remainder_23);	
sqrt sqrt_inst_24(
	fft_24,
	ampl_24,
	remainder_24);	
sqrt sqrt_inst_25(
	fft_25,
	ampl_25,
	remainder_25);	
sqrt sqrt_inst_26(
	fft_26,
	ampl_26,
	remainder_26);	
sqrt sqrt_inst_27(
	fft_27,
	ampl_27,
	remainder_27);	
sqrt sqrt_inst_28(
	fft_28,
	ampl_28,
	remainder_28);	
sqrt sqrt_inst_29(
	fft_29,
	ampl_29,
	remainder_29);	
sqrt sqrt_inst_30(
	fft_30,
	ampl_30,
	remainder_30);	
sqrt sqrt_inst_31(
	fft_31,
	ampl_31,
	remainder_31);	
sqrt sqrt_inst_32(
	fft_32,
	ampl_32,
	remainder_32);	
sqrt sqrt_inst_33(
	fft_33,
	ampl_33,
	remainder_33);	
sqrt sqrt_inst_34(
	fft_34,
	ampl_34,
	remainder_34);	
sqrt sqrt_inst_35(
	fft_35,
	ampl_35,
	remainder_35);	
sqrt sqrt_inst_36(
	fft_36,
	ampl_36,
	remainder_36);	
sqrt sqrt_inst_37(
	fft_37,
	ampl_37,
	remainder_37);	
sqrt sqrt_inst_38(
	fft_38,
	ampl_38,
	remainder_38);	
sqrt sqrt_inst_39(
	fft_39,
	ampl_39,
	remainder_39);	
sqrt sqrt_inst_40(
	fft_40,
	ampl_40,
	remainder_40);	
sqrt sqrt_inst_41(
	fft_41,
	ampl_41,
	remainder_41);	
sqrt sqrt_inst_42(
	fft_42,
	ampl_42,
	remainder_42);	
sqrt sqrt_inst_43(
	fft_43,
	ampl_43,
	remainder_43);	
sqrt sqrt_inst_44(
	fft_44,
	ampl_44,
	remainder_44);	
sqrt sqrt_inst_45(
	fft_45,
	ampl_45,
	remainder_45);	
sqrt sqrt_inst_46(
	fft_46,
	ampl_46,
	remainder_46);	
sqrt sqrt_inst_47(
	fft_47,
	ampl_47,
	remainder_47);	
sqrt sqrt_inst_48(
	fft_48,
	ampl_48,
	remainder_48);	
sqrt sqrt_inst_49(
	fft_49,
	ampl_49,
	remainder_49);	
sqrt sqrt_inst_50(
	fft_50,
	ampl_50,
	remainder_50);	
sqrt sqrt_inst_51(
	fft_51,
	ampl_51,
	remainder_51);	
sqrt sqrt_inst_52(
	fft_52,
	ampl_52,
	remainder_52);	
sqrt sqrt_inst_53(
	fft_53,
	ampl_53,
	remainder_53);	
sqrt sqrt_inst_54(
	fft_54,
	ampl_54,
	remainder_54);	
sqrt sqrt_inst_55(
	fft_55,
	ampl_55,
	remainder_55);	
sqrt sqrt_inst_56(
	fft_56,
	ampl_56,
	remainder_56);	
sqrt sqrt_inst_57(
	fft_57,
	ampl_57,
	remainder_57);	
sqrt sqrt_inst_58(
	fft_58,
	ampl_58,
	remainder_58);	
sqrt sqrt_inst_59(
	fft_59,
	ampl_59,
	remainder_59);	
sqrt sqrt_inst_60(
	fft_60,
	ampl_60,
	remainder_60);	
sqrt sqrt_inst_61(
	fft_61,
	ampl_61,
	remainder_61);	
sqrt sqrt_inst_62(
	fft_62,
	ampl_62,
	remainder_62);	
sqrt sqrt_inst_63(
	fft_63,
	ampl_63,
	remainder_63);	
sqrt sqrt_inst_64(
	fft_64,
	ampl_64,
	remainder_64);
	
wire [31:0]result_1;
	
log_10_altbarrel_shift_e0e log_inst_1
	( 
	1'b0,
	1'b1,
	clk,
	{12'b0,ampl_1},
	4'b0001,
	result_1) ;	

	

///////////////////////display//////////////////////
assign R1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - result_1[10:0])/*(450 - ampl_1[10:0])*/) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - ampl_1[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - ampl_1[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && {5'b0,ypos} > (450 - memorie_real_l_out[5])/*(450 - ampl_2[10:0])*/) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && ypos > (450 - ampl_2[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && ypos > (450 - ampl_2[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - ampl_3[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - ampl_3[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - ampl_3[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - ampl_4[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - ampl_4[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - ampl_4[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - ampl_5[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - ampl_5[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - ampl_5[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - ampl_6[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - ampl_6[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - ampl_6[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - ampl_7[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - ampl_7[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - ampl_7[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - ampl_8[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - ampl_8[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - ampl_8[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - ampl_9[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - ampl_9[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - ampl_9[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - ampl_10[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - ampl_10[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - ampl_10[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - ampl_11[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - ampl_11[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - ampl_11[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - ampl_12[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - ampl_12[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - ampl_12[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - ampl_13[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - ampl_13[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - ampl_13[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - ampl_14[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - ampl_14[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - ampl_14[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - ampl_15[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - ampl_15[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - ampl_15[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - ampl_16[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - ampl_16[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - ampl_16[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - ampl_17[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - ampl_17[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - ampl_17[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - ampl_18[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - ampl_18[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - ampl_18[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - ampl_19[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - ampl_19[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - ampl_19[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - ampl_20[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - ampl_20[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - ampl_20[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - ampl_21[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - ampl_21[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - ampl_21[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - ampl_22[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - ampl_22[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - ampl_22[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - ampl_23[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - ampl_23[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - ampl_23[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - ampl_24[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - ampl_24[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - ampl_24[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - ampl_25[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - ampl_25[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - ampl_25[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - ampl_26[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - ampl_26[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - ampl_26[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - ampl_27[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - ampl_27[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - ampl_27[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - ampl_28[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - ampl_28[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - ampl_28[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - ampl_29[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - ampl_29[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - ampl_29[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - ampl_30[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - ampl_30[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - ampl_30[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - ampl_31[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - ampl_31[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - ampl_31[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - ampl_32[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - ampl_32[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - ampl_32[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - ampl_33[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - ampl_33[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - ampl_33[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - ampl_34[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - ampl_34[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - ampl_34[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - ampl_35[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - ampl_35[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - ampl_35[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - ampl_36[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - ampl_36[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - ampl_36[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - ampl_37[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - ampl_37[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - ampl_37[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - ampl_38[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - ampl_38[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - ampl_38[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - ampl_39[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - ampl_39[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - ampl_39[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - ampl_40[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - ampl_40[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - ampl_40[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - ampl_41[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - ampl_41[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - ampl_41[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - ampl_42[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - ampl_42[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - ampl_42[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - ampl_43[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - ampl_43[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - ampl_43[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - ampl_44[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - ampl_44[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - ampl_44[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - ampl_45[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - ampl_45[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - ampl_45[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - ampl_46[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - ampl_46[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - ampl_46[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - ampl_47[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - ampl_47[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - ampl_47[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - ampl_48[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - ampl_48[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - ampl_48[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - ampl_49[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - ampl_49[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - ampl_49[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - ampl_50[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - ampl_50[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - ampl_50[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - ampl_51[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - ampl_51[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - ampl_51[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - ampl_52[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - ampl_52[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - ampl_52[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - ampl_53[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - ampl_53[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - ampl_53[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - ampl_54[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - ampl_54[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - ampl_54[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - ampl_55[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - ampl_55[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - ampl_55[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - ampl_56[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - ampl_56[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - ampl_56[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - ampl_57[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - ampl_57[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - ampl_57[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - ampl_58[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - ampl_58[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - ampl_58[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - ampl_59[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - ampl_59[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - ampl_59[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - ampl_60[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - ampl_60[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - ampl_60[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - ampl_61[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - ampl_61[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - ampl_61[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - ampl_62[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - ampl_62[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - ampl_62[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - ampl_63[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - ampl_63[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - ampl_63[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - ampl_64[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - ampl_64[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - ampl_64[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;



assign R = R1 ^ R2 ^ R3 ^ R5 ^ R6 ^ R7 ^ R8 ^ R9 ^ R10 ^ R11 ^ R12 ^ R13 ^ R14 ^ R15 ^ R16 ^ R17 ^ R18 ^ R19 ^ R20 ^ 
				R21 ^ R22 ^ R23 ^ R24 ^ R25 ^ R26 ^ R27 ^ R28 ^ R29 ^ R30 ^ R31 ^ R32 ^ R33 ^ R34 ^ R35 ^ R36 ^ R37 ^ R38 ^ R39 ^ R40 ^ 
				R41 ^ R42 ^ R43 ^ R44 ^ R45 ^ R46 ^ R47 ^ R48 ^ R49 ^ R50 ^ R51 ^ R52 ^ R53 ^ R54 ^ R55 ^ R56 ^ R57 ^ R58 ^ R59 ^ R60 ^
				R61 ^ R62 ^ R63 ^ R64 ^ R65;
assign G = G1 ^ G2 ^ G3 ^ G5 ^ G6 ^ G7 ^ G8 ^ G9 ^ G10 ^ G11 ^ G12 ^ G13 ^ G14 ^ G15 ^ G16 ^ G17 ^ G18 ^ G19 ^ G20 ^ 
				G21 ^ G22 ^ G23 ^ G24 ^ G25 ^ G26 ^ G27 ^ G28 ^ G29 ^ G30 ^ G31 ^ G32 ^ G33 ^ G34 ^ G35 ^ G36 ^ G37 ^ G38 ^ G39 ^ G40 ^ 
				G41 ^ G42 ^ G43 ^ G44 ^ G45 ^ G46 ^ G47 ^ G48 ^ G49 ^ G50 ^ G51 ^ G52 ^ G53 ^ G54 ^ G55 ^ G56 ^ G57 ^ G58 ^ G59 ^ G60 ^
				G61 ^ G62 ^ G63 ^ G64 ^ G65;
assign B = B1 ^ B2 ^ B3 ^ B5 ^ B6 ^ B7 ^ B8 ^ B9 ^ B10 ^ B11 ^ B12 ^ B13 ^ B14 ^ B15 ^ B16 ^ B17 ^ B18 ^ B19 ^ B20 ^ 
				B21 ^ B22 ^ B23 ^ B24 ^ B25 ^ B26 ^ B27 ^ B28 ^ B29 ^ B30 ^ B31 ^ B32 ^ B33 ^ B34 ^ B35 ^ B36 ^ B37 ^ B38 ^ B39 ^ B40 ^ 
				B41 ^ B42 ^ B43 ^ B44 ^ B45 ^ B46 ^ B47 ^ B48 ^ B49 ^ B50 ^ B51 ^ B52 ^ B53 ^ B54 ^ B55 ^ B56 ^ B57 ^ B58 ^ B59 ^ B60 ^
				B61 ^ B62 ^ B63 ^ B64 ^ B65;				
	
ceas c (clk, mode, clock);
choose_sync sincr_vga(clock, rst, mode, xpos, ypos, vsync, hsync, disp_active);

endmodule
