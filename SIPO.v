module SIPO (	input clock,
					input din, 
					input ADCLRC, 
					input BCLK,
					input reset, 
					output reg [31:0] dout,
					output reg data_ok,
					output reg sink_valid,
					output reg sink_eop,
					output reg sink_sop,
					output reg reset_n,
					output reg clock_fft_int,
					output clock_fft
					);

					
reg [31:0] s;					//register
reg [4:0] counter_samples =31;			//counter for the number of shifts, how many bits enter the register in one go
reg [6:0] counter_frames = 127;	//sample counter to separate frames

localparam [1:0] q_idle=0, q0 = 1, q1 = 2;
reg [1:0] state, next_state;

always @ (*)
		state <= next_state;
		
always @ (negedge BCLK)
	case (state)
		q_idle: begin
				reset_n <=1;
				next_state <= q0;
				sink_valid <= 0;
				data_ok <= 0;
			end
		q0: begin
				dout[31:0] <= s[31:0];
				next_state <= (ADCLRC == 1) ? q1 : q0;
				data_ok <= 0;
			end
		q1: begin 
				if (BCLK == 0 && counter_samples >= 0)
					begin 
						if (counter_samples == 0)
							begin
								data_ok <= 1;
								counter_frames <= counter_frames + 1;			//number of sample in frame
								sink_valid <= 1;
							end
						else ;
						s[31] <= din;
						s[30] <= s[31];
						s[29] <= s[30];
						s[28] <= s[29];
						s[27] <= s[28];
						s[26] <= s[27];
						s[25] <= s[26];
						s[24] <= s[25];
						s[23] <= s[24];
						s[22] <= s[23];
						s[21] <= s[22];
						s[20] <= s[21];
						s[19] <= s[20];
						s[18] <= s[19];
						s[17] <= s[18];
						s[16] <= s[17];
						s[15] <= s[16];
						s[14] <= s[15];
						s[13] <= s[14];
						s[12] <= s[13];
						s[11] <= s[12];
						s[10] <= s[11];
						s[9] <= s[10];
						s[8] <= s[9];
						s[7] <= s[8];
						s[6] <= s[7];
						s[5] <= s[6];
						s[4] <= s[5];
						s[3] <= s[4];
						s[2] <= s[3];
						s[1] <= s[2];
						s[0] <= s[1];
						counter_samples <= counter_samples - 1;
					end
				next_state <= (counter_samples==0) ? q0 : q1;
			end
		default: next_state <= q0;
	endcase
				
///////////////////SOP AND EOP//////////////////				
always @ (posedge data_ok)
	if(counter_frames == 0)
		begin 
			sink_sop <= 1;
			sink_eop <= 0;
		end
	else if (counter_frames == 127)
		begin
			sink_eop <= 1;
			sink_sop <= 0;
		end	
	else 
		begin
			sink_eop <= 0;
			sink_sop <= 0;
		end

always @ (posedge data_ok)
	if (counter_frames[0] == 0)
		clock_fft_int <= 1;
	else 
		clock_fft_int <= 0;

initial begin 
	reset_n = 0;
	@(posedge BCLK)
	reset_n = 1;
end


endmodule
