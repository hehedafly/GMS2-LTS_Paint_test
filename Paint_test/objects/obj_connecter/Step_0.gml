if(room==Room_paint && keyboard_check_pressed(vk_escape) && talk_status!=2){
	if(type=="server"){data_send_all(["room_goto;Room_hall"], json_stringify([buffer_string]), 0);room_goto(Room_hall);}
	else if(type=="client"){data_send(uuid, username, server_socket, ["room_goto;Room_hall"], json_stringify([buffer_string]), 0)}
}

#region server
if(type=="server"){//更新客户端连接状态
	player_name_arr=[];
	for(var i=0; i<playernum_limit; i++){var temp_name=client_name_ls[| i]; if(temp_name!=""){array_push(player_name_arr, temp_name)}}
	
	for(var i=0; i<array_length(client_online_status); i++){//登录确认
		var temp_num=client_online_status[i];
		temp_num=(temp_num+abs(temp_num))*0.5-1;
		array_set(client_online_status, i, temp_num);
		
		if(temp_num==0){array_set(client_online_status, i, client_offline_timeout)}//设置离线等待
		else if((temp_num mod client_online_timeout_check)==0 && player_num_online){connection_confirm(client_socket_map[? i], 0, i, client_name_ls[| i])}//发送确认信息
		
		if(temp_num==client_online_timeout){user_clear(i)}//设置离线删除
	}
	
	if(talk_status==2){//聊天信息输入
		if(instance_number(obj_painter)){with(obj_painter){paint_painting=-1;}}
		talk_text_temp=keyboard_string;
		if(talk_text_temp!="" && keyboard_check_pressed(vk_enter)){
			ds_list_insert(talk_message_ls, 0, string_to_talkmsg(username, talk_text_temp));
			ds_list_insert(talk_message_ls_raw, 0, string_format(date_current_datetime(), 8, 16));
			if(synchronize_arr[0][1]==-1){synchronize_arr[0][1]++;}
			synchronize_arr[0][2]++;
			talk_text_temp="";
			keyboard_string="";
		}
	}
	else{if(instance_number(obj_painter) && obj_painter.paint_painting==-1){with(obj_painter){paint_painting=1;}}}
	
	if(synchronize_arr[0][1]>=0){//聊天信息同步发送
		synchronize_arr[0][1]++;
		if(synchronize_arr[0][1]==synchronize_arr[0][0]){
			var temp_array_m=[];
			var temp_array_t=[];
			var ii=0;
			repeat(synchronize_arr[0][2]){array_push(temp_array_m, talk_message_ls[| ii]); array_push(temp_array_t, buffer_string); ii++}
			data_send_all(temp_array_m, json_stringify(temp_array_t), 1);
			synchronize_arr[0][2]=0;
			synchronize_arr[0][1]=-1;
		}
	}
	
	if(synchronize_arr[1][1]>=0 && room==Room_paint){//绘画状态发送
		synchronize_arr[1][1]++;
		if(synchronize_arr[1][1]==synchronize_arr[1][0] && (ds_map_size(paint_stock_temp) || array_length(stroke_collected)) && stroke_send_able){
			var temp_array_p=[];
			var temp_array_t=[];
			var ii=0;
			var temp_name_arr=[];
			
			for(var i=0; i<ds_list_size(client_name_ls); i++){if(client_name_ls[| i]!="" && ds_map_find_value(paint_stock_temp, client_name_ls[| i])!=undefined){array_push(temp_name_arr, client_name_ls[|i]);}}
			if(ds_map_find_value(paint_stock_temp, username)!=undefined){array_push(temp_name_arr, username);}//记录所有需要发送信息的player以供检索
			
			for(var j=0; j<array_length(temp_name_arr); j++){
				array_push(temp_array_p, temp_name_arr[j]+";"+json_stringify(ds_map_find_value(paint_stock_temp, temp_name_arr[j]))+";"+json_stringify(client_paint_stroke_rec_map[? temp_name_arr[j]]));
				array_push(temp_array_t, buffer_string);
			}
			
			//array_copy(temp_array_p, array_length(temp_array_p), stroke_collected, 0, array_length(stroke_collected))
			//repeat(array_length(stroke_collected)){array_push(temp_array_t, buffer_string)}
			var temp_stroke_collected=[]
			for(var k=0; k<array_length(stroke_collected); k++){
				if(k<array_length(stroke_collected)-1){
					var temp_arr=json_parse(scr_read_cut(stroke_collected[k], 1));
					var temp_arr_next=json_parse(scr_read_cut(stroke_collected[k+1], 1));
					if(array_length(temp_arr)==1 && array_length(temp_arr[0])<4){
						stroke_add(temp_arr, temp_arr_next);
						array_push(temp_stroke_collected, scr_read_cut(stroke_collected[k], 0)+";"+json_stringify(temp_arr)+";"+scr_read_cut(stroke_collected[k], 2));
						k++;
					}
					else{array_push(temp_stroke_collected, stroke_collected[k]);}
				}
				else{array_push(temp_stroke_collected, stroke_collected[k]);}
			}
			array_copy(temp_array_p, array_length(temp_array_p), temp_stroke_collected, 0, array_length(temp_stroke_collected))
			repeat(array_length(temp_stroke_collected)){array_push(temp_array_t, buffer_string)}
			stroke_collected=[];
			
			data_send_all(temp_array_p, json_stringify(temp_array_t), 2);
			ds_map_clear(paint_stock_temp);
			//synchronize_arr[1][2]=0;
			synchronize_arr[1][1]=-1;
			ds_map_clear(client_paint_stroke_rec_map);
		}
	}
	
	if(ds_map_size(client_apply_map)){//客户端请求分析
		var temp_command_stand="room_goto";
		var temp_command_array=[];
		for(var i=0; i<array_length(player_name_arr); i++){
			if((client_apply_map[? player_name_arr[i]])!=undefined && scr_read_cut(client_apply_map[? player_name_arr[i]], 0)==temp_command_stand){array_push(temp_command_array, scr_read_cut(client_apply_map[? player_name_arr[i]], 1))}	
		}
		if(ds_map_size(client_apply_map)>=2 && ds_map_size(client_apply_map)==array_length(player_name_arr)){//多人时判断是否准备完成
			for(var i=0; i<array_length(temp_command_array); i++){
				if(i==array_length(temp_command_array)-1){
					var temp_room=temp_command_array[0];
					//for(var j=0; j<array_length(room_asset); j++){if(room_get_name(room_asset[j])==temp_command_array[0]){temp_room=room_get_name(room_asset[j])}}
					data_send_all(["room_goto;"+temp_room], json_stringify([buffer_string]), 0);ds_map_clear(client_apply_map);
					for(var j=0; j<array_length(room_asset); j++){if(room_get_name(room_asset[j])==temp_command_array[0]){room_goto(room_asset[j])}}
					break;
				}
				if(temp_command_array[i]!=temp_command_array[i+1]){break;}
			}
		}
		else if(ds_map_size(client_apply_map)==1 && array_length(player_name_arr)==1){
			data_send_all(["room_goto;"+temp_command_array[0]], json_stringify([buffer_string]), 0);ds_map_clear(client_apply_map);
			for(var j=0; j<array_length(room_asset); j++){if(room_get_name(room_asset[j])==temp_command_array[0]){room_goto(room_asset[j])}}
		}
		
		//以下注释为可复制内容，后接处理
		//var temp_command_stand="room_goto";
		//var temp_command_array=[];
		//for(var i=0; i<array_length(player_name_arr); i++){
		//	if(scr_read_cut(client_apply_map[? player_name_arr[i]], 0)==temp_command_stand){array_push(temp_command_array, scr_read_cut(temp_command, 1))}//以上四行为模板，可复制	
		//}
	}
}
#endregion server

#region client
else{
	if(delay>=0 && uuid!=-1){//计算延迟
		if(delay==delay_check){
			connection_confirm(server_socket, current_time, uuid, username);
		}//发出延迟计算包
		if(delay==delay_check*2+1){network_init(); room_goto(Room_connecting)}//判断为断连
		if(delay==0){delay=delay_timeout;}//定为断连等待
		
		delay-=1;
	}
	
	if(talk_status==2){
		talk_text_temp=keyboard_string;
		if(talk_text_temp!="" && keyboard_check_pressed(vk_enter)){
			var temp_time=date_current_datetime();
			data_send(uuid, username, server_socket, [string(username)+";"+string_format(temp_time, 8, 16)+";"+talk_text_temp], json_stringify([buffer_string]), 1);//送出带有raw time的内容
			ds_list_insert(talk_message_ls, 0, string(username)+";"+scr_time_format(temp_time)+";"+talk_text_temp);
			talk_text_temp="";
			keyboard_string="";
		}
	}
}
#endregion client
//输入状态的切换
if(talk_status!=2){if(keyboard_check_pressed(ord("T"))){talk_status=2;keyboard_string="";};if(talk_status==1 && talk_showing_time_real==0){talk_status=0;talk_showing_time_real--}else if(talk_status==1 && talk_showing_time_real>0){talk_showing_time_real-=1;}else if(talk_status==1 && talk_showing_time_real<0){talk_showing_time_real=talk_showing_time}}else{if(keyboard_check_pressed(vk_escape)){talk_status=1}}



