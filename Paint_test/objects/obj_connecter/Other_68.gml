#region server
if(type=="server"){
//if(ds_map_find_value(async_load, "id") == server){
#region log in and confirm
if(ds_map_find_value(async_load,"type")=network_type_connect){
	if(ds_map_size(client_map)<playernum_limit){
		show_debug_message("one joined the game");
		var temp_client_socket=ds_map_find_value(async_load, "socket");
		var temp_pre_uuid=player_temp_uuid_ls[| ds_map_size(client_pre_socket_map)]
		pre_allo(temp_client_socket, temp_pre_uuid);//分配pre_uuid
		ds_map_replace(client_pre_socket_map, temp_pre_uuid, temp_client_socket);
		//ds_list_add(client_name_ls, temp_pre_uuid);
		show_debug_message("0 pre_uuid分配完成，并发送至对应客户端 当前pre_uuid:"+string(temp_pre_uuid));
	}
}
else{
	if(ds_map_find_value(async_load,"type")=network_type_disconnect){
		var temp_client_socket=ds_map_find_value(async_load, "socket");
		for(var i=0; i<playernum_limit; i++){
			if(client_socket_map[? i]==temp_client_socket){
				array_set(client_online_status, i, client_offline_timeout);
				player_num_online-=1;
				show_debug_message("uuid_"+string(i)+" left the game");
			}//断连时设为等待
		}
	}
}
if(ds_map_find_value(async_load, "type")=network_type_data){
	var data=ds_map_find_value(async_load, "buffer");
	var temp_head_ls=ds_list_create();
	var temp_status=buffer_read_type1(data, temp_head_ls, 1);//完整读取
	//预登录确认环节
	if(temp_status && temp_head_ls[| 1]==0 && ds_list_find_index(player_temp_uuid_ls, temp_head_ls[| 0])>=0){//pre_allo后客户端发来pre_uuid与username信息
		if(ds_map_find_value(client_pre_socket_map, temp_head_ls[| 0])!=undefined){//接受pre_uuid以及username，验证该pre_uuid-socket仍正常对应
			var temp_uuid=uuid_find(temp_head_ls[| 2]);//第一次uuid_find，应分配新uuid，若重名，则告知
			if(temp_head_ls[| 2]==username){temp_uuid=playernum_limit*(-1);}
			if(temp_uuid!=undefined && temp_uuid>=0 && (ds_map_find_value(client_socket_map, temp_uuid)==undefined) || ds_map_find_value(client_socket_map, temp_uuid)==-1){//uuid为新建
				ds_list_replace(client_name_ls, temp_uuid, temp_head_ls[| 2]);//此两行应写好对应删除删除方案
				ds_map_replace(client_map, temp_uuid, temp_head_ls[| 2]);
				ds_map_replace(client_socket_map, temp_uuid, ds_map_find_value(client_pre_socket_map, temp_head_ls[| 0]));//根据pre_uuid对对应username分配uuid,并记录uuid-socket
				log_feedback(client_socket_map[? temp_uuid], temp_head_ls[| 2], temp_uuid, 0, client_socket_map[? temp_uuid]);//发送uuid
				ds_map_delete(client_pre_socket_map, temp_head_ls[| 0])//pre_uuid弃用
				show_debug_message("3 收到客户端以pre_uuid登录的请求，反馈分配uuid，当前uuid为 "+string(temp_uuid));
			}
			else if(temp_uuid!=undefined && temp_uuid<0){//根据pre_socket_map回传占用信息
				log_feedback(client_pre_socket_map[? (temp_head_ls[| 0])], temp_head_ls[| 2], -1, 0);//发送占用信息
				show_debug_message("当前用户名已被被注册，此pre_uuid-socket已失效"+string((temp_uuid+1)*-1));
				ds_map_delete(client_pre_socket_map, temp_head_ls[| 0]);
			}
		}
	}
	//正常确认，登录以及延迟计算部分
	else if(temp_status && temp_head_ls[| 1]==1){
		var temp_uuid=temp_head_ls[| 0];
		var temp_username=temp_head_ls[| 2];
		if(client_map[? temp_uuid]==temp_username && ds_list_find_index(client_name_ls, temp_username)>=0){//接受直接登录时通过原有uuid-username验证该username是否占用
			if(ds_list_size(temp_head_ls)>4){
				ds_map_replace(client_socket_map, temp_uuid, temp_head_ls[| 5]);//更换socket
				show_debug_message("用户socket已更换，当前socket为"+string(temp_head_ls[| 5]));
			}
			log_feedback(client_socket_map[? temp_uuid], temp_username, temp_uuid, 1);//确认uuid登录
			ds_map_add(client_map, temp_uuid, temp_head_ls[| 2]);
			array_set(client_online_status, temp_uuid, client_online_timeout);
			show_debug_message("5 uuid登录确认完成");
			player_num_online+=1;
				
			for(var i=0; i<ds_map_size(client_pre_socket_map); i++){
				if(client_socket_map[? temp_uuid]==client_pre_socket_map[? (player_temp_uuid_ls[| i])]){ds_map_delete(client_pre_socket_map, player_temp_uuid_ls[| i])}
			}
		}
		else if(client_map[? temp_uuid]!=temp_username && ds_list_find_index(client_name_ls, temp_username)>=0){//被占用
			log_feedback(temp_head_ls[| 5], temp_username, -1, 1);//反馈占用信息
		}
	}
		
	if(temp_status && temp_head_ls[| 1]==2){//confirm
		var temp_uuid=temp_head_ls[| 0];
		var temp_username=temp_head_ls[| 2];
		if(temp_head_ls[| 3]==3){array_set(client_online_status, temp_uuid, client_online_timeout)}//登录状态确认
		else{
			connection_confirm(client_socket_map[? temp_uuid], temp_head_ls[| 5], temp_uuid, temp_username);
		}//延迟返回
	}
#endregion log in and confirm

#region data_collect and send
//正常收件环节
if(temp_status && temp_head_ls[| 1]==3){
	var temp_uuid=temp_head_ls[| 0];
	var temp_username=temp_head_ls[| 2];
	var temp_data_mark=temp_head_ls[| 4];
	
	if(temp_data_mark==0){//命令接收
		var temp_command=temp_head_ls[| 5];
		var temp_command_head=scr_read_cut(temp_command, 0);
		if(temp_command_head=="room_goto"){
			if(ds_map_find_value(client_apply_map, temp_username)!=undefined){
				if(temp_command!=client_apply_map[temp_username]){ds_map_replace(client_apply_map, temp_username, temp_command);}
			}
			else{ds_map_add(client_apply_map, temp_username, temp_command)}
			
			if(scr_read_cut(temp_command, 1)=="Room_paint"){data_send_all([string_to_talkmsg(username, temp_username+"已经准备好")], json_stringify([buffer_string]), 1)}
			else if(scr_read_cut(temp_command, 1)=="Room_hall"){data_send_all([string_to_talkmsg(username, temp_username+"想要离开")], json_stringify([buffer_string]), 1)}
		}
		else if(temp_command_head=="stroke_withdraw" && instance_number(obj_painter)){
			//data_send(uuid, username, server_socket, ["stroke_withdraw;"+username+";"+string(scr_array_last(obj_painter.stroke_full_withdraw_rec_arr))], json_stringify([buffer_string]), 0);
			obj_painter.command_rec=temp_command;
			with(obj_painter){command_resolve(command_rec)}
			data_send_all([temp_command], json_stringify([buffer_string]), 0);
		}
	}
	
	else if(temp_data_mark==1){//聊天内容接收
		var temp_time=real(scr_read_cut(temp_head_ls[| 5], 1));
		var temp_string=scr_read_cut(temp_head_ls[| 5], 0)+";"+scr_time_format(temp_time)+";"+scr_read_cut(temp_head_ls[| 5], 2);
		if(ds_list_size(talk_message_ls_raw)){
			for(var i=0; i<ds_list_size(talk_message_ls_raw); i++){
				if(date_compare_datetime(temp_time, talk_message_ls_raw[| i])>=0){ds_list_insert(talk_message_ls, i, temp_string);ds_list_insert(talk_message_ls_raw, i, temp_time);break;}
				else if(i==ds_list_size(talk_message_ls_raw)-1){ds_list_add(talk_message_ls, temp_string);ds_list_add(talk_message_ls_raw, temp_time);break;}
			}
		}
		else{ds_list_add(talk_message_ls, temp_string);ds_list_add(talk_message_ls_raw, temp_time)}
		if(ds_list_size(talk_message_ls)>=talk_message_recnum){ds_list_delete(talk_message_ls, 19); ds_list_delete(talk_message_ls_raw, 19)}
		talk_showing_time_real=talk_showing_time;
		if(talk_status==0){talk_status=1;}
		
		if(synchronize_arr[0][1]==-1){synchronize_arr[0][1]++;}
		synchronize_arr[0][2]++;
	}
	
	else if(temp_data_mark==2 && instance_number(obj_painter)){//绘画信息接收
		stroke_send_able=0;
//if(type=="client"){data_send(uuid, username, server_socket, [username+";"+json_stringify(paint_arr), temp_penup], json_stringify([buffer_string, buffer_s32]), 2)}//笔画全部发送，正常
		var temp_arr=json_parse(scr_read_cut(temp_head_ls[| 5], 1));
		var painter_all_arr=obj_painter.stroke_all_arr;
		var painter_all_name_arr=obj_painter.stroke_all_name_arr;
		var painter_all_stroke_num_map=obj_painter.stroke_all_stroke_num_map;
		var temp_name=scr_read_cut(temp_head_ls[| 5], 0);
		var temp_stroke_num=temp_head_ls[| 6];//若不为-1则更新笔画数map
		
		if(is_array(temp_arr) && is_array(scr_array_last(temp_arr))){
			array_push(painter_all_arr, temp_arr);
			array_push(painter_all_name_arr, temp_name);
			var temp_collect_arr=[];
			if(temp_stroke_num){array_push(temp_collect_arr, temp_stroke_num)}
			array_push(stroke_collected, temp_head_ls[|5]+";"+json_stringify(temp_collect_arr));//代替了以下两行
			//if(ds_map_find_value(paint_stock_temp, temp_username)!=undefined){stroke_add(paint_stock_temp[? temp_username], temp_arr);}
			//else{ds_map_add(paint_stock_temp, temp_username, temp_arr);}
			
			if(ds_map_find_value(client_paint_stroke_rec_map, temp_username)==undefined){ds_map_add(client_paint_stroke_rec_map, temp_username, [])}//不连续笔画不为-1的有对应的笔画数状态
		
			if(temp_stroke_num){
				if(ds_map_find_value(painter_all_stroke_num_map, temp_username)!=undefined){array_push(painter_all_stroke_num_map[? temp_username], temp_stroke_num)}
				else{ds_map_add(painter_all_stroke_num_map, temp_username, [temp_stroke_num])}
			
				if(ds_map_find_value(client_paint_stroke_rec_map, temp_username)!=undefined){array_push(client_paint_stroke_rec_map[? temp_username], temp_stroke_num)}
				else{ds_map_add(client_paint_stroke_rec_map, temp_username, [temp_stroke_num])}//所有不连续笔画都有对应的笔画数状态
			}
		
			if(synchronize_arr[1][1]==-1){synchronize_arr[1][1]++;}
		}
		stroke_send_able=1;
	}
}

#endregion data_collect and send
ds_list_destroy(temp_head_ls);
buffer_delete(ds_map_find_value(async_load, "buffer"));
}
//}
}
#endregion

#region	client
if(type=="client"){
//if ds_map_find_value(async_load, "id") == client{ 
#region log in and confirm
if(ds_map_find_value(async_load, "type") == network_type_non_blocking_connect){ 
	success=ds_map_find_value(async_load, "succeeded");
	if(success){
		server_socket=ds_map_find_value(async_load, "socket");
		//sign_or_log(uuid);
		show_debug_message("waiting for response");
	}
	else{show_message("加入失败，请检查uuid(可能需归为-1)等信息")}	
}

if(ds_map_find_value(async_load, "type")=network_type_data){//收件
	var data=ds_map_find_value(async_load, "buffer");
	var temp_head_ls=ds_list_create();
	var temp_status=buffer_read_type1(data, temp_head_ls, 1);
		
	if(temp_status && temp_head_ls[| 1]==0){//得到pre_allo后申请登录或直接尝试登录
		if(temp_head_ls[| 2]=="_" && uuid==-1){//未得到uuid时通过pre_uuid登录
			pre_uuid=temp_head_ls[| 0];
			show_debug_message("1 得到pre_uuid，当前pre_uuid是 "+string(pre_uuid));
			sign_or_log(pre_uuid, 0);
			show_debug_message("2 以pre_uuid登录，再次将pre_uuid与username发出");
		}
		else if(temp_head_ls[| 2]=="_" && uuid!=-1 && client_socket_self!=-1){
			sign_or_log(uuid, 1, client_socket_self);
			show_debug_message("4.1 直接以已有uuid登录");
		}
		else if(temp_head_ls[| 2]==username && uuid==-1){//刚得到uuid后登录或根据uuid登录，或者被告知重名
			if(temp_head_ls[| 0]!=-1){
				uuid=temp_head_ls[| 0];
				client_socket_self=temp_head_ls[| 5];
				sign_or_log(uuid, 1);
				pre_uuid=-1;//成功得到uuid则弃用pre_uuid
				show_debug_message("4 得到pre_uuid登录后分配的uuid,以uuid登录, 当前uuid为"+string(uuid));
				obj_UI_manager.uuid_record=uuid;
			}
			else {network_init();show_message("请更改用户名！");}//若需改名则保留pre_uuid
		}
	}//注册完成
	else if(temp_status && temp_head_ls[| 1]==1 && username==temp_head_ls[| 2]){//确认登录
		if(temp_head_ls[| 0]==uuid){
			if(room==Room_connecting){room_goto(Room_hall);}
			show_debug_message("6 uuid登陆成功")
			delay=delay_check*2;
		}
		else{
			show_message("登陆失败，请更改用户名！")
		}
	}
	else if(temp_status && temp_head_ls[| 1]==2 && username==temp_head_ls[| 2]){//确认连接状态或检测延迟
		if(temp_head_ls[| 3]==3){connection_confirm(server_socket, 0, uuid, username)}//回传服务器确认连接状态
		else{
			var last_time=temp_head_ls[| 5];
			delay_value=current_time-last_time;
			delay=delay_check*2;
			
			player_name_arr=json_parse(temp_head_ls[| 6]);
			array_delete(player_name_arr, scr_array_find_index(player_name_arr, function(_element){return(_element==username)}), 1);
			//可以包含自身
			//array_delete(player_name_arr, scr_array_find_index(player_name_arr, function(_element){return(_element==username)}), 1)
		}//计算延迟
	}
#endregion log in and confirm
	
#region	data_collected_send and recive
//正常收件环节
if(temp_status && temp_head_ls[| 1]==3){
	var temp_uuid=temp_head_ls[| 0];
	var temp_username=temp_head_ls[| 2];
	var temp_data_mark=temp_head_ls[| 4];
	
	if(temp_data_mark==0){//房间切换等信息
		var temp_command=temp_head_ls[| 5];
		var temp_command_head=scr_read_cut(temp_command, 0);
		if(temp_command_head=="room_goto"){
			var temp_command_room_switch=[temp_command_head, scr_read_cut(temp_command, 1)];
			for(var i=0; i<array_length(room_asset); i++){if(room_get_name(room_asset[i])==temp_command_room_switch[1]){if(room!=room_asset[i]){room_goto(room_asset[i])}}}
		}
		else if(temp_command_head=="stroke_withdraw" && instance_number(obj_painter)){
			//data_send_all(["stroke_withdraw;"+username+";"+string(scr_array_last(obj_painter.stroke_full_withdraw_rec_arr))], json_stringify([buffer_string]), 0);
			if(username!=scr_read_cut(temp_command, 1)){
				obj_painter.command_rec=temp_command;
				with(obj_painter){command_resolve(command_rec);}
			}
		}
	}
	
	else if(temp_data_mark==1){//聊天内容接收
		for(var i=ds_list_size(temp_head_ls)-1; i>=5; i--){
			if(scr_read_cut(temp_head_ls[| i], 0)!=username){ds_list_insert(talk_message_ls, 0, temp_head_ls[| i]);if(talk_status==0){talk_status++}else if(talk_status==1){talk_showing_time_real=talk_showing_time}}
		}
	}
	
	else if(temp_data_mark==2  && instance_number(obj_painter)){//绘画信息接收
		
//for(var j=0; j<array_length(temp_name_arr); j++){
//	array_push(temp_array_p, temp_name_arr[j]+";"+json_stringify(ds_map_find_value(paint_stock_temp, temp_name_arr[j]))+";"+json_stringify(client_paint_stroke_rec_map[? temp_name_arr[j]]));
//	array_push(temp_array_t, buffer_string, buffer_string);
//}
//data_send_all(temp_array_p, json_stringify(temp_array_t), 2);
//head_ls后每一条均为 username;(该username所画的)json(stroke_arr);(该username所画的)json([rec_num])

		var painter_all_arr=obj_painter.stroke_all_arr;
		var painter_all_name_arr=obj_painter.stroke_all_name_arr;
		var painter_all_stroke_num_map=obj_painter.stroke_all_stroke_num_map;
		for(var i=5; i<ds_list_size(temp_head_ls); i++){
			var temp_name=scr_read_cut(temp_head_ls[| i], 0);
			var temp_arr=json_parse(scr_read_cut(temp_head_ls[| i], 1));
			var temp_rec_num_arr=json_parse(scr_read_cut(temp_head_ls[| i], 2));
			if(temp_name!=username){
				array_push(painter_all_arr, temp_arr);
				array_push(painter_all_name_arr, temp_name);
				
				if(ds_map_find_value(painter_all_stroke_num_map, temp_name)==undefined){ds_map_add(painter_all_stroke_num_map, temp_name, temp_rec_num_arr);}
				else{for(var j=0; j<array_length(temp_rec_num_arr); j++){array_push(painter_all_stroke_num_map[? temp_name], temp_rec_num_arr[j])}}
			}
			
		}
	}
}

#endregion	data_collected_send and recive

ds_list_destroy(temp_head_ls);
buffer_delete(ds_map_find_value(async_load, "buffer"));
}
//}
}
#endregion	client