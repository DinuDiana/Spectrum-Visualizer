module VGA_2(	input clk,	 				//clock from FPGA – 50MHz
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
//reg [15:0] memorie_real_l_out [0:127];
//reg [15:0] memorie_imag_l_out [0:127];
reg [15:0] memorie_real_r_out [0:127];
//reg [15:0] memorie_imag_r_out [0:127];
reg [7:0] R_set = 8'b0101_0000;
reg [7:0] G_set = 8'b1001_0000;
reg [7:0] B_set = 8'b1101_0000;

reg [13:0] counter_l=0, counter_r=0;			//counts the number of samples sent by fft, total of 128 in a frame
reg full_load_l, full_load_r;

wire [16:0] Ampl1, Ampl2, Ampl3, Ampl4, Ampl5, Ampl6, Ampl7, Ampl8, Ampl9, Ampl10, Ampl11, Ampl12, Ampl13, Ampl14, Ampl15, Ampl16, Ampl17, Ampl18, Ampl19, Ampl20, 
				Ampl21, Ampl22, Ampl23, Ampl24, Ampl25, Ampl26, Ampl27, Ampl28, Ampl29, Ampl30, Ampl31, Ampl32, Ampl33, Ampl34, Ampl35, Ampl36, Ampl37, Ampl38, Ampl39, Ampl40, 
				Ampl41, Ampl42, Ampl43, Ampl44, Ampl45, Ampl46, Ampl47, Ampl48, Ampl49, Ampl50, Ampl51, Ampl52, Ampl53, Ampl54, Ampl55, Ampl56, Ampl57, Ampl58, Ampl59, Ampl60,
				Ampl61, Ampl62, Ampl63, Ampl64, Ampl65;
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
				
////////////////resolution/////////////////
always @ (posedge clock)
	case (mode)
		0: begin vertical <= 640; horizontal <= 480; end
		1: begin vertical <= 800; horizontal <= 600; end
		default: begin vertical <= 800; horizontal <= 600; end
	endcase
				/*
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
			//memorie_imag_l_out [counter_l] <= source_imag_l;
		end
*/
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
			//memorie_imag_r_out [counter_r] <= source_imag_r;
		end

assign Ampl1 = memorie_real_r_out[64]; 
assign Ampl2 = memorie_real_r_out[65]; 
assign Ampl3 = memorie_real_r_out[66]; 
assign Ampl4 = memorie_real_r_out[67]; 
assign Ampl5 = memorie_real_r_out[68]; 
assign Ampl6 = memorie_real_r_out[69]; 
assign Ampl7 = memorie_real_r_out[70]; 
assign Ampl8 = memorie_real_r_out[71]; 
assign Ampl9 = memorie_real_r_out[72]; 
assign Ampl10 = memorie_real_r_out[73]; 
assign Ampl11 = memorie_real_r_out[74]; 
assign Ampl12 = memorie_real_r_out[75]; 
assign Ampl13 = memorie_real_r_out[76]; 
assign Ampl14 = memorie_real_r_out[77]; 
assign Ampl15 = memorie_real_r_out[78]; 
assign Ampl16 = memorie_real_r_out[79]; 
assign Ampl17 = memorie_real_r_out[80]; 
assign Ampl18 = memorie_real_r_out[81]; 
assign Ampl19 = memorie_real_r_out[82]; 
assign Ampl20 = memorie_real_r_out[83]; 
assign Ampl21 = memorie_real_r_out[84]; 
assign Ampl22 = memorie_real_r_out[85]; 
assign Ampl23 = memorie_real_r_out[86]; 
assign Ampl24 = memorie_real_r_out[87]; 
assign Ampl25 = memorie_real_r_out[88]; 
assign Ampl26 = memorie_real_r_out[89]; 
assign Ampl27 = memorie_real_r_out[90]; 
assign Ampl28 = memorie_real_r_out[91]; 
assign Ampl29 = memorie_real_r_out[92]; 
assign Ampl30 = memorie_real_r_out[93]; 
assign Ampl31 = memorie_real_r_out[94]; 
assign Ampl32 = memorie_real_r_out[95]; 
assign Ampl33 = memorie_real_r_out[96]; 
assign Ampl34 = memorie_real_r_out[97]; 
assign Ampl35 = memorie_real_r_out[98]; 
assign Ampl36 = memorie_real_r_out[99]; 
assign Ampl37 = memorie_real_r_out[100]; 
assign Ampl38 = memorie_real_r_out[101]; 
assign Ampl39 = memorie_real_r_out[102]; 
assign Ampl40 = memorie_real_r_out[103]; 
assign Ampl41 = memorie_real_r_out[104]; 
assign Ampl42 = memorie_real_r_out[105]; 
assign Ampl43 = memorie_real_r_out[106]; 
assign Ampl44 = memorie_real_r_out[107]; 
assign Ampl45 = memorie_real_r_out[108]; 
assign Ampl46 = memorie_real_r_out[109]; 
assign Ampl47 = memorie_real_r_out[110]; 
assign Ampl48 = memorie_real_r_out[111]; 
assign Ampl49 = memorie_real_r_out[112]; 
assign Ampl50 = memorie_real_r_out[113]; 
assign Ampl51 = memorie_real_r_out[114]; 
assign Ampl52 = memorie_real_r_out[115]; 
assign Ampl53 = memorie_real_r_out[116]; 
assign Ampl54 = memorie_real_r_out[117]; 
assign Ampl55 = memorie_real_r_out[118]; 
assign Ampl56 = memorie_real_r_out[119]; 
assign Ampl57 = memorie_real_r_out[120]; 
assign Ampl58 = memorie_real_r_out[121]; 
assign Ampl59 = memorie_real_r_out[122]; 
assign Ampl60 = memorie_real_r_out[123];
assign Ampl61 = memorie_real_r_out[124]; 
assign Ampl62 = memorie_real_r_out[125]; 
assign Ampl63 = memorie_real_r_out[126]; 
assign Ampl64 = memorie_real_r_out[127];
/*{5'b0,ypos} > (450 - memorie_real_l_out[5])*/
///////////////////////display//////////////////////
assign R1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - Ampl1[16:6])/*(450 - Ampl1[10:0])*/) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - Ampl1[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B1 = (disp_active == 1 ) ? ( (xpos < 20 && xpos > 11 && ypos > (450 - Ampl1[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && ypos > (450 - Ampl2[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && ypos > (450 - Ampl2[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B2 = (disp_active == 1 ) ? ( (xpos < 31 && xpos > 21 && ypos > (450 - Ampl2[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - Ampl3[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - Ampl3[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B3 = (disp_active == 1 ) ? ( (xpos < 42 && xpos > 32 && ypos > (450 - Ampl3[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - Ampl4[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - Ampl4[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B5 = (disp_active == 1 ) ? ( (xpos < 53 && xpos > 43 && ypos > (450 - Ampl4[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - Ampl5[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - Ampl5[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B6 = (disp_active == 1 ) ? ( (xpos < 64 && xpos > 54 && ypos > (450 - Ampl5[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - Ampl6[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - Ampl6[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B7 = (disp_active == 1 ) ? ( (xpos < 75 && xpos > 65 && ypos > (450 - Ampl6[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - Ampl7[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - Ampl7[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B8 = (disp_active == 1 ) ? ( (xpos < 86 && xpos > 76 && ypos > (450 - Ampl7[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - Ampl8[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - Ampl8[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B9 = (disp_active == 1 ) ? ( (xpos < 97 && xpos > 87 && ypos > (450 - Ampl8[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - Ampl9[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - Ampl9[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B10 = (disp_active == 1 ) ? ( (xpos < 108 && xpos > 98 && ypos > (450 - Ampl9[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - Ampl10[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - Ampl10[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B11 = (disp_active == 1 ) ? ( (xpos < 119 && xpos > 109 && ypos > (450 - Ampl10[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - Ampl11[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - Ampl11[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B12 = (disp_active == 1 ) ? ( (xpos < 130 && xpos > 120 && ypos > (450 - Ampl11[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - Ampl12[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - Ampl12[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B13 = (disp_active == 1 ) ? ( (xpos < 141 && xpos > 131 && ypos > (450 - Ampl12[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - Ampl13[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - Ampl13[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B14 = (disp_active == 1 ) ? ( (xpos < 152 && xpos > 142 && ypos > (450 - Ampl13[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - Ampl14[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - Ampl14[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B15 = (disp_active == 1 ) ? ( (xpos < 163 && xpos > 153 && ypos > (450 - Ampl14[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - Ampl15[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - Ampl15[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B16 = (disp_active == 1 ) ? ( (xpos < 174 && xpos > 164 && ypos > (450 - Ampl15[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - Ampl16[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - Ampl16[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B17 = (disp_active == 1 ) ? ( (xpos < 185 && xpos > 175 && ypos > (450 - Ampl16[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - Ampl17[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - Ampl17[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B18 = (disp_active == 1 ) ? ( (xpos < 196 && xpos > 186 && ypos > (450 - Ampl17[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - Ampl18[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - Ampl18[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B19 = (disp_active == 1 ) ? ( (xpos < 207 && xpos > 197 && ypos > (450 - Ampl18[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - Ampl19[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - Ampl19[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B20 = (disp_active == 1 ) ? ( (xpos < 218 && xpos > 208 && ypos > (450 - Ampl19[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - Ampl20[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - Ampl20[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B21 = (disp_active == 1 ) ? ( (xpos < 229 && xpos > 219 && ypos > (450 - Ampl20[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - Ampl21[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - Ampl21[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B22 = (disp_active == 1 ) ? ( (xpos < 240 && xpos > 230 && ypos > (450 - Ampl21[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - Ampl22[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - Ampl22[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B23 = (disp_active == 1 ) ? ( (xpos < 251 && xpos > 241 && ypos > (450 - Ampl22[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - Ampl23[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - Ampl23[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B24 = (disp_active == 1 ) ? ( (xpos < 262 && xpos > 252 && ypos > (450 - Ampl23[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - Ampl24[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - Ampl24[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B25 = (disp_active == 1 ) ? ( (xpos < 273 && xpos > 263 && ypos > (450 - Ampl24[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - Ampl25[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - Ampl25[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B26 = (disp_active == 1 ) ? ( (xpos < 284 && xpos > 274 && ypos > (450 - Ampl25[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - Ampl26[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - Ampl26[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B27 = (disp_active == 1 ) ? ( (xpos < 295 && xpos > 285 && ypos > (450 - Ampl26[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - Ampl27[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - Ampl27[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B28 = (disp_active == 1 ) ? ( (xpos < 306 && xpos > 296 && ypos > (450 - Ampl27[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - Ampl28[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - Ampl28[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B29 = (disp_active == 1 ) ? ( (xpos < 317 && xpos > 307 && ypos > (450 - Ampl28[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - Ampl29[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - Ampl29[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B30 = (disp_active == 1 ) ? ( (xpos < 328 && xpos > 318 && ypos > (450 - Ampl29[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - Ampl30[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - Ampl30[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B31 = (disp_active == 1 ) ? ( (xpos < 339 && xpos > 329 && ypos > (450 - Ampl30[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - Ampl31[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - Ampl31[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B32 = (disp_active == 1 ) ? ( (xpos < 350 && xpos > 340 && ypos > (450 - Ampl31[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - Ampl32[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - Ampl32[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B33 = (disp_active == 1 ) ? ( (xpos < 361 && xpos > 351 && ypos > (450 - Ampl32[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - Ampl33[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - Ampl33[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B34 = (disp_active == 1 ) ? ( (xpos < 372 && xpos > 362 && ypos > (450 - Ampl33[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - Ampl34[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - Ampl34[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B35 = (disp_active == 1 ) ? ( (xpos < 383 && xpos > 373 && ypos > (450 - Ampl34[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - Ampl35[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - Ampl35[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B36 = (disp_active == 1 ) ? ( (xpos < 394 && xpos > 384 && ypos > (450 - Ampl35[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - Ampl36[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - Ampl36[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B37 = (disp_active == 1 ) ? ( (xpos < 405 && xpos > 395 && ypos > (450 - Ampl36[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - Ampl37[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - Ampl37[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B38 = (disp_active == 1 ) ? ( (xpos < 416 && xpos > 406 && ypos > (450 - Ampl37[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - Ampl38[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - Ampl38[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B39 = (disp_active == 1 ) ? ( (xpos < 427 && xpos > 417 && ypos > (450 - Ampl38[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - Ampl39[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - Ampl39[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B40 = (disp_active == 1 ) ? ( (xpos < 438 && xpos > 428 && ypos > (450 - Ampl39[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - Ampl40[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - Ampl40[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B41 = (disp_active == 1 ) ? ( (xpos < 449 && xpos > 439 && ypos > (450 - Ampl40[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - Ampl41[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - Ampl41[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B42 = (disp_active == 1 ) ? ( (xpos < 460 && xpos > 450 && ypos > (450 - Ampl41[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - Ampl42[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - Ampl42[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B43 = (disp_active == 1 ) ? ( (xpos < 471 && xpos > 461 && ypos > (450 - Ampl42[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - Ampl43[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - Ampl43[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B44 = (disp_active == 1 ) ? ( (xpos < 482 && xpos > 472 && ypos > (450 - Ampl43[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - Ampl44[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - Ampl44[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B45 = (disp_active == 1 ) ? ( (xpos < 493 && xpos > 483 && ypos > (450 - Ampl44[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - Ampl45[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - Ampl45[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B46 = (disp_active == 1 ) ? ( (xpos < 504 && xpos > 494 && ypos > (450 - Ampl45[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - Ampl46[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - Ampl46[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B47 = (disp_active == 1 ) ? ( (xpos < 515 && xpos > 505 && ypos > (450 - Ampl46[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - Ampl47[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - Ampl47[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B48 = (disp_active == 1 ) ? ( (xpos < 526 && xpos > 516 && ypos > (450 - Ampl47[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - Ampl48[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - Ampl48[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B49 = (disp_active == 1 ) ? ( (xpos < 537 && xpos > 527 && ypos > (450 - Ampl48[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - Ampl49[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - Ampl49[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B50 = (disp_active == 1 ) ? ( (xpos < 548 && xpos > 538 && ypos > (450 - Ampl49[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - Ampl50[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - Ampl50[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B51 = (disp_active == 1 ) ? ( (xpos < 559 && xpos > 549 && ypos > (450 - Ampl50[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - Ampl51[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - Ampl51[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B52 = (disp_active == 1 ) ? ( (xpos < 570 && xpos > 560 && ypos > (450 - Ampl51[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - Ampl52[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - Ampl52[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B53 = (disp_active == 1 ) ? ( (xpos < 581 && xpos > 571 && ypos > (450 - Ampl52[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - Ampl53[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - Ampl53[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B54 = (disp_active == 1 ) ? ( (xpos < 592 && xpos > 582 && ypos > (450 - Ampl53[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - Ampl54[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - Ampl54[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B55 = (disp_active == 1 ) ? ( (xpos < 603 && xpos > 593 && ypos > (450 - Ampl54[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - Ampl55[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - Ampl55[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B56 = (disp_active == 1 ) ? ( (xpos < 614 && xpos > 604 && ypos > (450 - Ampl55[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - Ampl56[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - Ampl56[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B57 = (disp_active == 1 ) ? ( (xpos < 625 && xpos > 615 && ypos > (450 - Ampl56[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - Ampl57[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - Ampl57[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B58 = (disp_active == 1 ) ? ( (xpos < 636 && xpos > 626 && ypos > (450 - Ampl57[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - Ampl58[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - Ampl58[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B59 = (disp_active == 1 ) ? ( (xpos < 647 && xpos > 637 && ypos > (450 - Ampl58[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - Ampl59[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - Ampl59[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B60 = (disp_active == 1 ) ? ( (xpos < 658 && xpos > 648 && ypos > (450 - Ampl59[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - Ampl60[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - Ampl60[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B61 = (disp_active == 1 ) ? ( (xpos < 669 && xpos > 659 && ypos > (450 - Ampl60[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - Ampl61[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - Ampl61[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B62 = (disp_active == 1 ) ? ( (xpos < 680 && xpos > 670 && ypos > (450 - Ampl61[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - Ampl62[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - Ampl62[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B63 = (disp_active == 1 ) ? ( (xpos < 691 && xpos > 681 && ypos > (450 - Ampl62[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - Ampl63[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - Ampl63[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B64 = (disp_active == 1 ) ? ( (xpos < 702 && xpos > 692 && ypos > (450 - Ampl63[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;

assign R65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - Ampl64[10:0])) ? R_set : 8'b0000_0000) : 8'b0000_0000;
assign G65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - Ampl64[10:0])) ? G_set : 8'b0000_0000) : 8'b0000_0000;
assign B65 = (disp_active == 1 ) ? ( (xpos < 713 && xpos > 703 && ypos > (450 - Ampl64[10:0])) ? B_set : 8'b0000_0000) : 8'b0000_0000;



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
//clock_divider #(17) clk_div_vga (clk, clock_movement);
choose_sync sincr_vga(clock, rst, mode, xpos, ypos, vsync, hsync, disp_active);

endmodule
		
				
				
				