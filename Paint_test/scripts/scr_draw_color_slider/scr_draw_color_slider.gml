function scr_draw_color_slider(xx,yy,width,length,record_pos, assign_arr){
	if(array_length(assign_arr)>=2){
		var unit=length/(array_length(assign_arr)-1);
		for(var i=0; i<array_length(assign_arr)-1; i++){draw_rectangle_color(xx,yy+unit*i,xx+width,yy+unit*(i+1),assign_arr[i],assign_arr[i],assign_arr[i+1],assign_arr[i+1],false);}
		var temp_yy=record_pos-yy;
		temp_yy=clamp(temp_yy,0,length);
		var slider_r, slider_g, slider_b;
		var temp_color_pos_int=floor(temp_yy/(length/(array_length(assign_arr)-1)));
		var temp_color_pos_frac=frac(temp_yy/(length/(array_length(assign_arr)-1)));
		if(temp_yy==length){temp_color_pos_int--;temp_color_pos_frac=1;}
		slider_r=color_get_red(assign_arr[temp_color_pos_int])	*(1-temp_color_pos_frac)+temp_color_pos_frac*color_get_red(assign_arr[temp_color_pos_int+1]);
		slider_g=color_get_green(assign_arr[temp_color_pos_int])*(1-temp_color_pos_frac)+temp_color_pos_frac*color_get_green(assign_arr[temp_color_pos_int+1]);
		slider_b=color_get_blue(assign_arr[temp_color_pos_int])	*(1-temp_color_pos_frac)+temp_color_pos_frac*color_get_blue(assign_arr[temp_color_pos_int+1]);
			
		draw_sprite_ext(spr_matters_triangle,0,xx,clamp(record_pos,yy,yy+length),1,1,0,c_white,1);
		draw_circle_color(xx+width*0.5,yy+length+width*0.5+16,width*0.5+4,c_white,c_black,false);
		draw_circle_color(xx+width*0.5,yy+length+width*0.5+16,width*0.5,make_color_rgb(slider_r,slider_g,slider_b),make_color_rgb(slider_r,slider_g,slider_b),false);
		return(make_color_rgb(slider_r,slider_g,slider_b))
	}
}