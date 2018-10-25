module syncro#(parameter a=800, //activ     //orizontal
								x=856,          //activ+front
								x_back=976,     //total-back
								x_total=1040,   //total
								b=600,          //activ       //vrtical
								y=637,          //activ+front
								y_back=643,     //total-back
								y_total=666)     //total
								( input clock, output [10:0] xpos, output hsync, output [10:0] ypos, output vsync, output reg disp_active);

wire newline;

always@(posedge clock)
  if(xpos<a & ypos<b)
    disp_active <=1;
  else
    disp_active <=0;

hsync #(a, x, x_back, x_total) horiz_sync(clock, xpos, hsync, disp_active_h, newline); 
vsync #(b, y, y_back, y_total) vert_sync(newline, ypos, vsync, disp_active_v);

endmodule