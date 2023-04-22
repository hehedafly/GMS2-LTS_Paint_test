if(ttx!=-1 || tty!=-1){
	if(mouse_x-ttx>-25 && mouse_x-ttx<length+25 && mouse_y-tty>0 && mouse_y-tty<width){
		if(mouse_check_button_pressed(mb_left)){mb_hold=1;}
	}
	if(mb_hold){
		record_value=clamp(mouse_x-ttx, 0, length)/length*100;
		slider0=record_value;	
		if(mouse_check_button_released(mb_left)){mb_hold=0;}
	}
}