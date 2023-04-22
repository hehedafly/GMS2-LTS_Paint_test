if(!multiplayer && keyboard_check_pressed(vk_escape)){room_goto(Room_start)}

if(keyboard_check_pressed(vk_lshift)){paint_pen=((paint_pen+1) mod 5);}
if(keyboard_check_pressed(ord("S"))){stroke_smooth=abs(stroke_smooth-1);stroke_smooth_temp_stock=[]}
//if(keyboard_check_pressed(vk_lshift)){paint_pen+=1;}
//if(mouse_wheel_down()){if(keyboard_check(vk_lcontrol)){paint_pen_size+=1;}else{paint_pen_size+=10;}}
//if(mouse_wheel_up()){if(keyboard_check(vk_lcontrol)){paint_pen_size-=1;}else{paint_pen_size-=10;}}
paint_pen_size+=(mouse_wheel_up()-mouse_wheel_down())*(10-bool(keyboard_check(vk_lcontrol))*9)
paint_pen_size=clamp(paint_pen_size, 1, 500);

if(keyboard_check_pressed(vk_tab) && paint_painting>=0){paint_color_selecting=abs(paint_color_selecting-1); paint_painting=1-paint_color_selecting;}

if(paint_painting && paint_pen>=2){
	if(mouse_check_button_pressed(mb_left)){paint_pen_recpos0x=clamp(mouse_x, 0, room_width); paint_pen_recpos0y=clamp(mouse_y, 0, room_height);}//basic points
	if(paint_pen_recpos0x!=-1 || paint_pen_recpos0y!=-1){paint_pen_recpos01x=clamp(mouse_x, 0, room_width); paint_pen_recpos01y=clamp(mouse_y, 0, room_height);}//pre_drawing added points
	if(mouse_check_button_released(mb_left) && (paint_pen_recpos0x!=-1 || paint_pen_recpos0y!=-1)){//drawing added points
		paint_pen_recpos1x=clamp(mouse_x, 0, room_width); 
		paint_pen_recpos1y=clamp(mouse_y, 0, room_height);
	}
}

if(multiplayer){
	if(stroke_network_synchronize<0){stroke_network_synchronize=stroke_network_synchronize_check;}
	else if(stroke_network_synchronize==0){
		if(stroke_network_rec_num){
			var temp_arr=stroke_read(stroke_arr, stroke_network_rec_pos, stroke_network_rec_num, 1);
			paint_arr=temp_arr;
			with(obj_connecter){
				var temp_penup=-1;//仅用于发送笔画数量，在时间段内更换新笔画没有影响
				if(obj_painter.stroke_penup){temp_penup=scr_array_last(obj_painter.stroke_full_withdraw_rec_arr); with(obj_painter){stroke_penup=0;}}//penup在draw和step中没有被打断，其位置不影响笔画存储和读取，
				
				if(type=="client"){data_send(uuid, username, server_socket, [username+";"+json_stringify(paint_arr), temp_penup], json_stringify([buffer_string, buffer_s32]), 2)}
				else if(type=="server"){
					if(ds_map_find_value(paint_stock_temp, username)!=undefined){stroke_add(paint_stock_temp[? username], paint_arr)}
					else{ds_map_add(paint_stock_temp, username, paint_arr)}
					
					if(ds_map_find_value(client_paint_stroke_rec_map, username)==undefined){ds_map_add(client_paint_stroke_rec_map, username, [])}
					if(temp_penup){
						array_push(client_paint_stroke_rec_map[? username], temp_penup);
					}
					if(synchronize_arr[1][1]==-1){synchronize_arr[1][1]++;}
					//synchronize_arr[1][2]++;
				}
			}
			stroke_network_rec_pos+=stroke_network_rec_num;
			stroke_network_rec_num=0;
			paint_arr=[];
		}
		stroke_network_synchronize=stroke_network_synchronize_check+1;
	}
	else if(stroke_network_synchronize<=stroke_network_synchronize_check){stroke_network_synchronize--;}
}
