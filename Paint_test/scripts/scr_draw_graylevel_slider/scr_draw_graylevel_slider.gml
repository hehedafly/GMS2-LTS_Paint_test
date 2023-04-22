function scr_draw_graylevel_slider(xx,yy,width,length,record_pos){
	draw_rectangle_color(xx-2,yy-2,xx+width+2,yy+length+2,c_gray,c_gray,c_gray,c_gray,false);
	draw_rectangle_color(xx,yy,xx+width,yy+length,c_white,c_white,c_black,c_black,false);
	
	var temp_yy=record_pos-yy;
	temp_yy=clamp(temp_yy,0,length);
	var graylevel=255-temp_yy/length*255;
	graylevel=clamp(graylevel,0,255)
	
	var scale=100/length;
	draw_sprite_ext(spr_matters_triangle,0,xx-scale*sprite_get_width(spr_matters_triangle),clamp(record_pos,yy,yy+length),scale,scale,0,c_white,1);
	return(make_color_rgb(graylevel,graylevel,graylevel));
}