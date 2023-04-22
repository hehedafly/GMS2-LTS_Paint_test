if(paint_color_selecting){	
	var slider_x1=16;
	var slider_x2=64;
	var slider_width=16;
	if(mouse_check_button(mb_left)){
		if(mouse_x>slider_x1-slider_width && mouse_x<slider_x1+slider_width){temp_pos=clamp(mouse_y, 0, room_height);}
		else if(mouse_x>slider_x2-slider_width && mouse_x<slider_x2+slider_width){temp_pos2=clamp(mouse_y, 0, room_height);}
	}
	var return_color=scr_draw_color_slider(slider_x1,64,slider_width,600,temp_pos, [c_red, make_color_rgb(255, 255, 0), c_green, make_color_rgb(0, 255, 255), c_blue, make_color_rgb(255, 0, 255), c_red]);
	var return_color2=scr_draw_color_slider(slider_x2,64,slider_width,200,temp_pos2, [c_white, return_color, c_black]);

	paint_color=return_color2;
}


if(multiplayer){
			//draw_text_color(16,24,"stroke_all_namee_arr: "+string(array_length(stroke_all_name_arr)), c_black, c_black, c_black, c_black, 1);
			//draw_text_color(16,4,"stroke_all_namee_arr: "+string(stroke_all_name_arr), c_black, c_black, c_black, c_black, 1);
			//draw_text_color(256,24,"stroke_all_arr: "+string(array_length(stroke_all_arr)), c_black, c_black, c_black, c_black, 1);
			//draw_text_color(16,48,"stroke_all_arr_draw_rec: "+string(stroke_full_withdraw_rec_arr), c_black, c_black, c_black, c_black, 1);
			//for(var i=0; i<array_length(stroke_all_arr); i++){draw_text_color(16+i*32,72,array_length(stroke_all_arr[i][0])-1, c_black, c_black, c_black, c_black, 1);}
			//for(var i=0; i<array_length(stroke_all_arr); i++){
			//	for(var k=0; k<array_length(stroke_all_arr[i]); k++){
			//		for(var j=0; j<array_length(stroke_all_arr[i][k]); j++){
			//			draw_text_color(16+i*128+k*32,108+j*16,stroke_all_arr[i][k][j], c_black, c_black, c_black, c_black, 1);
			//		}
			//	}
			//}
			
//	for(var i=0; i<array_length(stroke_all_arr); i++){draw_text_color(16+i*72,24,stroke_all_arr[i][0][0], c_black, c_black, c_black, c_black, 1);}
//	draw_text_color(16,48,stroke_all_name_arr, c_black, c_black, c_black, c_black, 1);
//}
//else{
//	for(var i=0; i<array_length(stroke_arr); i++){draw_text_color(16+i*72,24,stroke_arr[i][0], c_black, c_black, c_black, c_black, 1);}
//	for(var i=0; i<array_length(stroke_arr); i++){draw_text_color(16+i*72,48,array_length(stroke_arr[i]), c_black, c_black, c_black, c_black, 1);}
}