function scr_draw_dotted_line(startx,starty,aimx,aimy,length_part){
	var length=point_distance(startx,starty,aimx,aimy)
	if(length_part==undefined){length_part=20;}
	for(var i=0;i<length;i+=length_part){
		if(i>length){i=length}
		var potion=(i+length_part)/length;
		var potion_before=i/length
		if(potion>=1){potion=1}

		if((i/length_part mod 2)==0){draw_line_color(startx+potion_before*(aimx-startx),starty+potion_before*(aimy-starty),startx+potion*(aimx-startx),starty+potion*(aimy-starty),c_black,c_black)}
	}
	if((floor(length/length_part) mod 2)==1){draw_line_color(startx+((length-length_part/2)/length)*(aimx-startx),starty+((length-length_part/2)/length)*(aimy-starty),aimx,aimy,c_black,c_black)}
	return(true)
}
