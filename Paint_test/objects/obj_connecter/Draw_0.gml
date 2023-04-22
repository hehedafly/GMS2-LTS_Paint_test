//draw_text_color(16,48,"ip: "+string(ipadress)+"; username: "+username, c_black, c_black, c_black, c_black, 1);
//draw_text_color(16,72,"uuid: "+string(uuid), c_black, c_black, c_black, c_black, 1);
//draw_text_color(16,96,"port: "+string(port), c_black, c_black, c_black, c_black, 1);
//for(var i=0; i<array_length(client_online_status); i++){draw_text_color(16+i*32,122,client_online_status[i], c_black, c_black, c_black, c_black, 1);}
////for(var i=0; i<ds_map_size(client_socket_map); i++){if(client_socket_map[? i]!=undefined){draw_text_color(16+i*16,134,client_socket_map[? i], c_black, c_black, c_black, c_black, 1);}}
//draw_text_color(16,150,"delay_value: "+string(delay_value), c_black, c_black, c_black, c_black, 1);
//draw_text_color(16,166,"delay: "+string(delay), c_black, c_black, c_black, c_black, 1);
//draw_text_color(16,182,"player_num_online: "+string(player_num_online), c_black, c_black, c_black, c_black, 1);
//draw_text_color(16,196,"player_num_online"+string(player_name_arr), c_black, c_black, c_black, c_black, 1);

if(type=="client"){draw_text_color(16,16,"delay: "+string(delay_value)+"ms", c_black, c_black, c_black, c_black, 1);}
draw_text_color(16+bool(type=="client")*128,16,"在线玩家数: "+string(array_length(player_name_arr)), c_black, c_black, c_black, c_black, 1);
draw_text_color(16,48,"在线玩家"+string(player_name_arr), c_black, c_black, c_black, c_black, 1);

if(ds_map_size(client_apply_map)){
	var temp_y=80;
	for(var i=0; i<array_length(player_name_arr); i++){
		if((client_apply_map[? player_name_arr[i]])!=undefined && scr_read_cut(client_apply_map[? player_name_arr[i]], 0)=="room_goto"){
			if(scr_read_cut(client_apply_map[? player_name_arr[i]], 1)=="Room_paint"){
				draw_text_color(16,temp_y,player_name_arr[i]+"已经准备好", c_black, c_black, c_black, c_black, 1);
				temp_y+=20;
			}
		}
	}
}

if(talk_status>=1 && (room==Room_hall || room==Room_paint)){
	var temp_talkbox_x=0;
	var otemp_talkbox_y=room_height*1;//以y为基底向上绘制文字以及背景框
	var temp_talkbox_y=room_height*1;//以y为基底向上绘制文字以及背景框
	var temp_talkbox_width=room_width*0.4;
	var temp_talkbox_min_height=room_height*0.3;
	var temp_talkbox_max_height=room_height*0.6;
	var temp_talkbox_full_height=room_height*0.9;
	var temp_text_editbox_height=32;
	
	var temp_transparent_surface=surface_create(temp_talkbox_width, 1);
	surface_set_target(temp_transparent_surface);
	draw_clear(c_black);
	surface_reset_target();
	if(talk_status!=2){draw_surface_ext(temp_transparent_surface, temp_talkbox_x, temp_talkbox_y, 1, -1*(clamp((ds_list_size(talk_message_ls)/talk_message_recnum_show)*temp_talkbox_max_height, temp_talkbox_min_height, temp_talkbox_max_height)), 0, c_white, 0.5);}
	else{draw_surface_ext(temp_transparent_surface, temp_talkbox_x, temp_talkbox_y, 1, -1*temp_talkbox_full_height, 0, c_white, 0.5);}
	surface_free(temp_transparent_surface);
	
	if(ds_list_size(talk_message_ls)){
		var temp_drawtext_y=temp_talkbox_y-8;
		if(talk_status==2){temp_drawtext_y-=temp_text_editbox_height;}
		for(var i=0; i<ds_list_size(talk_message_ls); i++){
			//var temp_time=scr_time_format(real(scr_read_cut(talk_message_ls[| i], 1)));
			var temp_string_array=[scr_read_cut(talk_message_ls[| i], 0), scr_read_cut(talk_message_ls[| i], 1), scr_read_cut(talk_message_ls[| i], 2)];
			temp_drawtext_y-=string_height_ext(temp_string_array[2], 2, temp_talkbox_width-32)+5;
			draw_text_ext(temp_talkbox_x+16, temp_drawtext_y, temp_string_array[2], 0, temp_talkbox_width-32);
			temp_drawtext_y-=string_height(temp_string_array[0])-5;		
			draw_text(temp_talkbox_x+16, temp_drawtext_y, temp_string_array[0]+"    "+temp_string_array[1]);		
			
			if(talk_status==1 && temp_drawtext_y<otemp_talkbox_y-temp_talkbox_max_height+32){break;}
			else if(talk_status==2 && temp_drawtext_y<otemp_talkbox_y-temp_talkbox_full_height+32){break;}
		}
	}
	
	if(talk_status==2){
		with(obj_UI_manager){
			var tt=draw_text_block(temp_talkbox_x, temp_talkbox_y-temp_text_editbox_height, temp_talkbox_x+temp_talkbox_width, temp_talkbox_y, obj_connecter.talk_text_temp, 1, 1);
			if(tt=-1){with(obj_connecter){talk_get_async_id=get_string_async("输入内容", talk_text_temp);}}
		}
	}
}