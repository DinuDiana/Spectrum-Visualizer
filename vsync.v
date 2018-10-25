module vsync#(parameter b=600, //activ
								y=637,          //activ+front
								y_back=643,     //total-back
								y_total=666)     //total
								(input newline_clk, output [10:0] ypos, output reg vsync, output reg disp_active);
   
   reg [10:0] count = 11'b00000000000;

   always @(posedge newline_clk)
	 if (count < y_total)
	   count <= count + 1;
	 else
	   count <= 0;
   
   always @(posedge newline_clk)
	 if (count < b)
	   disp_active 		<= 1;     //activ pe 1
	 else
	   disp_active 		<= 0;
      
   always @(posedge newline_clk)
	 begin
		if (count < y)
		  vsync 	<= 1;
		else if (count >= y && count < y_back)      //activ pe 0
		  vsync 	<= 0;
		else if (count >= y_back)
		  vsync 	<= 1;
	 end

   assign ypos = count;
   
endmodule 