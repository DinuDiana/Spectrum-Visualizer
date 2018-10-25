module fft_divider(
			input clock_50,
			input clock_fft,
			input [15:0] data_in_real,
			output reg [15:0] data_out_real,
			input [15:0] data_in_imag,
			output reg [15:0] data_out_imag
			);

reg [6:0]	counter_samples = 0;
reg [7:0] 	counter_frames = 0;

always @ (posedge clock_fft)
	if (clock_fft == 1)
		begin 
			if (counter_samples == 127) 
				begin 
					counter_frames <= counter_frames + 1;
				end
			counter_samples <= counter_samples + 1;
		end

always @ (negedge clock_fft)	
	if (counter_frames == 0)
		begin
			data_out_real <= data_in_real;
			data_out_imag <= data_in_imag;
		end
		
		
endmodule

		
	