module hsync #(parameter a=800, //activ
								x=856,          //activ+front
								x_back=976,     //total-back
								x_total=1040)     //total
								(input clk, output [10:0] xpos, output reg hsync, disp_active, newline);

   
   reg [10:0] count = 11'b000_0000_0000;

   always @(posedge clk)
		if (count < x_total)
		  count  <= count + 1;
		else
		  count  <= 0;
   
   always @(posedge clk)
		if (count == x_total)
		  newline <= 1;
		else
		  newline <= 0;
		  
   always @(posedge clk)
		if (count < a)
		   disp_active  <= 1;   //activ pe 1
		else
		   disp_active  <= 0;

   always @(posedge clk)
		if (count < x)
		  hsync <= 1;
		else 
		  if (count >= x && count < x_back)
		    hsync <= 0;
		  else 
		    if (count >= x_back)
		      hsync <= 1;
				 
   assign xpos = count;
   
endmodule