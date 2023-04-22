if(!surface_exists(srf_background)){
	srf_background=surface_create(room_width, room_height);
	surface_set_target(srf_background);
	draw_clear(c_white);
	surface_reset_target();
}
if(!surface_exists(srf_templayer)){srf_templayer=surface_create(room_width, room_height);}
if(!surface_exists(withdraw_surface)){withdraw_surface=surface_create(surface_get_width(srf_background), surface_get_height(srf_background));surface_set_target(withdraw_surface);draw_clear(c_white);surface_reset_target();}
//multiplayer
if(!surface_exists(stroke_all_surface) && multiplayer){stroke_all_surface=surface_create(room_width, room_height);surface_set_target(stroke_all_surface);draw_clear(c_white);surface_reset_target();}
if(!surface_exists(stroke_all_withdraw_surface) && multiplayer){stroke_all_withdraw_surface=surface_create(surface_get_width(stroke_all_surface), surface_get_height(stroke_all_surface));surface_copy(stroke_all_withdraw_surface, 0, 0, stroke_all_surface)};
if(!surface_exists(stroke_self_temp_surface) && multiplayer){stroke_self_temp_surface=surface_create(surface_get_width(stroke_all_surface), surface_get_height(stroke_all_surface));}

if(!mouse_check_button(mb_left) && keyboard_check(vk_control) && keyboard_check_pressed(ord("Z")) && array_length(stroke_full_withdraw_rec_arr)){//主动删除
	if(multiplayer){
		surface_copy(stroke_all_surface, 0, 0, stroke_all_withdraw_surface);
		
		with(obj_connecter){if(type=="client"){data_send(uuid, username, server_socket, ["stroke_withdraw;"+username+";"+string(scr_array_last(obj_painter.stroke_full_withdraw_rec_arr))], json_stringify([buffer_string]), 0);}else if(type=="server"){data_send_all(["stroke_withdraw;"+username+";"+string(scr_array_last(obj_painter.stroke_full_withdraw_rec_arr))], json_stringify([buffer_string]), 0);}}
		var temp_function=function(element){return(element==username)}
		var temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function, -1);//最后一个位置
		if(temp_pos!=-1){
			var temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], scr_array_last(stroke_full_withdraw_rec_arr), 0);//stroke_all_arr一次存储最多一个笔画
			array_delete(stroke_all_arr, temp_pos, 1);
			array_delete(stroke_all_name_arr, temp_pos, 1);
			stroke_all_arr_draw_rec--;
		
			while(temp_delete>0){
				var temp_function=function(element){return(element==username)}
				temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function, -1);if(temp_pos==-1){break;}
				temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], scr_array_last(stroke_full_withdraw_rec_arr), 0);
				array_delete(stroke_all_arr, temp_pos, 1)
				array_delete(stroke_all_name_arr, temp_pos, 1);
				stroke_all_arr_draw_rec--;
			}
			
			surface_set_target(stroke_all_surface);
			for(var i=0; i<array_length(stroke_all_arr); i++){
				stroke_redo(stroke_all_arr[i], 1);
			}
			
			stroke_network_rec_pos-=scr_array_last(stroke_full_withdraw_rec_arr);
			surface_reset_target();
			array_delete(stroke_all_stroke_num_map[? username], 0, 1);
			stroke_stock_delete(stroke_arr, scr_array_last(stroke_full_withdraw_rec_arr), 0);
			array_pop(stroke_full_withdraw_rec_arr);
		}
	}
	else{
		surface_copy(srf_background, 0, 0, withdraw_surface);
		stroke_stock_delete(stroke_arr, scr_array_last(stroke_full_withdraw_rec_arr), 0);
		surface_set_target(srf_background);
		stroke_redo(stroke_arr, 1);
		surface_reset_target();
		
		array_pop(stroke_full_withdraw_rec_arr);
	}
}

if(paint_painting){//个人笔画记录与绘制
	var pen_x=clamp(mouse_x, 0, room_width); 
	var pen_y=clamp(mouse_y, 0, room_height);
	
	var drawing_or_pre=0;
	if(mouse_check_button(mb_left)){
		if(paint_pen<2 || paint_pen_recpos1x!=-1){drawing_or_pre=1;stroke_stock(drawing_or_pre, paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y);}
		//if(paint_pen_recpos1x==-1 && paint_pen_recpos01x!=-1){stroke_stock(drawing_or_pre, paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos01x, paint_pen_recpos01y);}
		if(stroke_network_synchronize>stroke_network_synchronize_check){stroke_network_synchronize--;}
	}
	if(mouse_check_button_released(mb_left) && (stroke_withdraw_rec_num|| paint_pen>=2)){
		stroke_penup=1;//置于笔画记录前，防止新单步笔画被误送
		if(paint_pen<2 || paint_pen_recpos1x!=-1){drawing_or_pre=1;stroke_stock(drawing_or_pre, paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y)}
		//if(paint_pen_recpos1x==-1 && paint_pen_recpos01x!=-1){stroke_stock(drawing_or_pre, paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos01x, paint_pen_recpos01y)}
		
		if(multiplayer && drawing_or_pre){
			var temp_all_arr=[];temp_all_arr=stroke_read(stroke_arr, 0, stroke_withdraw_rec_num, -1);
			array_push(stroke_all_arr, temp_all_arr); array_push(stroke_all_name_arr, username);//平行记录自身笔画，多人时直接记录当前笔画
			
			if(ds_map_find_value(stroke_all_stroke_num_map, username)!=undefined){array_push(stroke_all_stroke_num_map[? username], stroke_withdraw_rec_num)}
			else{ds_map_add(stroke_all_stroke_num_map, username, [stroke_withdraw_rec_num])}
		}
		array_push(stroke_full_withdraw_rec_arr, stroke_withdraw_rec_num); stroke_withdraw_rec_num=0;
	}
		
	if(!multiplayer){
		surface_set_target(srf_background);
		drawing(paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y, 0);
		if(paint_pen<2 && stroke_smooth && array_length(stroke_smooth_temp_stock)==5){
			if(paint_pen==stroke_smooth_temp_stock[0] && paint_pen_size==stroke_smooth_temp_stock[1] && paint_color==stroke_smooth_temp_stock[2]){
				drawing(paint_pen, paint_pen_size, paint_color, (pen_x+stroke_smooth_temp_stock[3])*0.5, (pen_y+stroke_smooth_temp_stock[4])*0.5, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y, 0);
			}
		}
		stroke_smooth_temp_stock=[paint_pen, paint_pen_size, paint_color, pen_x, pen_y];
		surface_reset_target();
	}
	else{
		surface_set_target(stroke_self_temp_surface);
		drawing(paint_pen, paint_pen_size, paint_color, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y, 0);
		if(paint_pen<2 && stroke_smooth && array_length(stroke_smooth_temp_stock)==5){
			if(paint_pen==stroke_smooth_temp_stock[0] && paint_pen_size==stroke_smooth_temp_stock[1] && paint_color==stroke_smooth_temp_stock[2]){
				drawing(paint_pen, paint_pen_size, paint_color, (pen_x+stroke_smooth_temp_stock[3])*0.5, (pen_y+stroke_smooth_temp_stock[4])*0.5, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos1x, paint_pen_recpos1y, 0);
			}
		}
		stroke_smooth_temp_stock=[paint_pen, paint_pen_size, paint_color, pen_x, pen_y];
		surface_reset_target();
	}
		
	surface_set_target(srf_templayer);
	pre_drawing(paint_pen, paint_pen_size, pen_x, pen_y, paint_pen_recpos0x, paint_pen_recpos0y, paint_pen_recpos01x, paint_pen_recpos01y)
	surface_reset_target();
}

if(multiplayer){//需要时绘制所有笔画
	if(stroke_withdraw_refresh){
		surface_copy(stroke_all_surface, 0, 0, stroke_all_withdraw_surface);
		stroke_all_arr_draw_rec=-1;//需完全重绘，设为-1
		stroke_withdraw_refresh=0;
	}
	
	surface_set_target(stroke_all_surface);
	while(array_length(stroke_all_arr) && stroke_all_arr_draw_rec<array_length(stroke_all_arr)-1){
		stroke_all_arr_draw_rec++;
		stroke_redo(stroke_all_arr[stroke_all_arr_draw_rec], 1);
		
	}
	surface_reset_target()
}

#region clear old strokes and final surface drawing
if(multiplayer){
	var temp_player_name_arr=[];
	array_copy(temp_player_name_arr, 0, obj_connecter.player_name_arr, 0, array_length(obj_connecter.player_name_arr));//多人删除撤回次数外笔画
	array_push(temp_player_name_arr, username);
	
	surface_set_target(stroke_all_withdraw_surface);
	
	for(var i=0; i<array_length(temp_player_name_arr); i++){
		var temp_rec_num_arr=stroke_all_stroke_num_map[? temp_player_name_arr[i]];
		if(array_length(temp_rec_num_arr)>withdraw_max){
			stroke_all_temp_name=temp_player_name_arr[i];
			var temp_function=function(element){return(element==stroke_all_temp_name)}
			var temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function);//得到stroke_all_arr中当前名字第一个位置
			
			if(temp_pos!=-1){
				stroke_redo(stroke_all_arr[temp_pos], 1);
			
				var temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], temp_rec_num_arr[0], 1);//stroke_all_arr一次存储最多一个笔画
				array_delete(stroke_all_arr, temp_pos, 1);
				array_delete(stroke_all_name_arr, temp_pos, 1);
				stroke_all_arr_draw_rec--;
		
				while(temp_delete>0){
					var temp_function=function(element){return(element==stroke_all_temp_name)}
					temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function);if(temp_pos==-1){break;}
					stroke_redo(stroke_all_arr[temp_pos], 1);
					temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], temp_delete, 1);
					array_delete(stroke_all_arr, temp_pos, 1);
					array_delete(stroke_all_name_arr, temp_pos, 1);
					stroke_all_arr_draw_rec--;
				}
				
				array_delete(stroke_all_stroke_num_map[? stroke_all_temp_name], 0, 1);
				stroke_all_temp_name="";
			}
		}
	}
	surface_reset_target();
	
	draw_surface(stroke_all_surface, 0, 0);
	//draw_surface_ext(stroke_all_withdraw_surface, 0, 0, 0.4, 0.4, 0, c_blue, 1);
	draw_surface(stroke_self_temp_surface, 0, 0);
	draw_surface(srf_templayer, 0, 0);
	
	if(mouse_check_button_released(mb_left)){if(surface_exists(stroke_self_temp_surface)){surface_free(stroke_self_temp_surface)}}
	if(!srf_templayer_keep){surface_free(srf_templayer);}
	
	if(array_length(stroke_full_withdraw_rec_arr)>withdraw_max){//部分删除撤回次数外笔画
		var temp_withdraw_arr=[]
		array_copy(temp_withdraw_arr, 0, stroke_arr[0], 0, 1+stroke_full_withdraw_rec_arr[0]);
		stroke_stock_delete(stroke_arr, stroke_full_withdraw_rec_arr[0], 1);
		stroke_network_rec_pos-=stroke_full_withdraw_rec_arr[0];
		array_delete(stroke_full_withdraw_rec_arr, 0, 1);
	}
}
else{//single player
	if(array_length(stroke_full_withdraw_rec_arr)>withdraw_max){//单人删除撤回次数外笔画
		if(!surface_exists(withdraw_surface)){withdraw_surface=surface_create(surface_get_width(srf_background), surface_get_height(srf_background));surface_set_target(withdraw_surface);draw_clear(c_white);surface_reset_target();}
		var temp_withdraw_arr=[]
		array_copy(temp_withdraw_arr, 0, stroke_arr[0], 0, 1+stroke_full_withdraw_rec_arr[0]);
		
		surface_set_target(withdraw_surface);
		stroke_redo([temp_withdraw_arr], 1);
		surface_reset_target();
		
		stroke_stock_delete(stroke_arr, stroke_full_withdraw_rec_arr[0], 1);
		//stroke_network_rec_pos-=stroke_full_withdraw_rec_arr[0];
		array_delete(stroke_full_withdraw_rec_arr, 0, 1);
	}
	draw_surface(srf_background, 0, 0);
	draw_surface(srf_templayer, 0, 0);
	//draw_surface_ext(withdraw_surface, 0, 0, 0.4, 0.4, 0, c_blue, 1);
	if(!srf_templayer_keep){surface_free(srf_templayer);}
}
#endregion