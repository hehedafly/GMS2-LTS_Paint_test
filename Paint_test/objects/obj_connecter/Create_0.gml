depth=-1;
globalvar client;
globalvar server;
client=-1;
server=-1;
type="";//"server" 或 "client"
ipadress="127.0.0.1";
port=2333;
player_num_online=0;

talk_message_ls=ds_list_create();//string格式： username;time;content, 时间格式:u16, date_current_time, date_compare_datetime 1比2早返回-1
talk_message_recnum=20;
talk_message_recnum_show=10;
talk_status=0;//0:不显示, 1:显示, 2:等待输入+显示
talk_get_async_id=-1;
talk_text_temp="";
talk_showing_time=room_speed*3;//聊天信息显示3秒
talk_showing_time_real=-1;
//paint_map=ds_map_create();		ds_map_add(paint_map, username, []);
room_asset=[Room_start, Room_connecting, Room_hall, Room_paint];
player_name_arr=[];//存储在线玩家用户名，不包括自己
buffer_keep=0;

#region server init
playernum_limit=20;
stroke_send_able=1;//0:正在解包整理，不能发包	1:正常发包
player_temp_uuid_ls=ds_list_create();
client_map=ds_map_create();//key:uuid; value: username;
client_name_ls=ds_list_create();	repeat(playernum_limit){ds_list_add(client_name_ls, "")}
client_socket_map=ds_map_create();//key:uuid; value: socket;
client_pre_socket_map=ds_map_create();//key:pre_uuid; value: socket
client_online_status=array_create(playernum_limit, -1);//<0: unsigned or already offline, >=0, <client_online_timeout:online, =client_online_timeout:offline waitting on  每次确认时使数值设为断连时限，每步-1.若离线等待到期，则设为-1并删除相关信息
//在线时1l2m均有数据，且status处于0-online_timeout之内，离线等待时1l2m亦均有数据，但status处于oneline_timeout-offline_timeout之内，完全离线后全部清除	可能以后要改变离线等待时的数据情况
client_online_timeout_check=room_speed//每秒确认一次
client_online_timeout=room_speed*3//断连时限，超过三秒确认失败则设为离线（设为check整倍方便计算）
client_offline_timeout=client_online_timeout+room_speed*15//30s等待重连时间,client_online_timeout为offset
client_apply_map=ds_map_create();

talk_message_ls_raw=ds_list_create();//存储message current_time信息
client_paint_stroke_rec_map=ds_map_create();//存储临时的笔画数信息，key:username  value:array (form: [num, num...]<sum<=15>)
paint_stock_temp=ds_map_create();
paint_stock_temp_server=ds_map_create();
//globalvar paint_stock_temp_server;
//paint_stock_temp_server=ds_map_create();

//0-	room_speed:接收到信息后收集1s内信息发送至客户端	-1时暂停，0时开始计数，到达check则发送
//1-	room_speed*0.5:有绘画信息接入0.5s内	-1时暂停，0时开始计数，到达check则发送
synchronize_arr=[[room_speed, -1, 0], [room_speed*0.5, -1, 0]];//2d array,  0:talk_message, 1:paint_arr		inner_format:[[check, real, num], [check, real, num],......]
stroke_collected=[];//临时收集客户端发来的绘画信息
while(ds_list_size(player_temp_uuid_ls)<playernum_limit*1.5){
	var temp_num=(irandom(9)+1)*100+irandom(99);
	if(ds_list_find_index(player_temp_uuid_ls, temp_num)==-1){ds_list_add(player_temp_uuid_ls, temp_num);}
}
#endregion
#region client init
server_socket=-1;
client_socket_self=-1;//记录在服务端自己的socket记录
username="";
uuid=-1;
pre_uuid=-1;
delay_value=-1.0//ms
delay=-1;//-1时停止延迟计算
delay_check=room_speed;//每1s判断一次，若正常收到延迟, 收到时delay=delay_check*2;
delay_timeout=delay_check*2+room_speed*2;//2s后无回应判断为断连
#endregion
#region network create and clear
function client_connect(_ipadress, _port){
	if(type=="client"){
		if(_ipadress==undefined){_ipadress=ipadress;}
		if(_port==undefined){_port=port;}
		client = network_create_socket(network_socket_tcp);
		network_set_config(network_config_connect_timeout, 5000);
		network_set_config(network_config_use_non_blocking_socket, 1);
		network_connect(client,_ipadress,_port);
		//show_message("try to connect to server");
		//show_message(string(_ipadress)+";"+string(_port));
	}
}

function server_create(){
	if(type=="server"){
		while (server < 0 && port < 65535){
			server = network_create_server(network_socket_tcp,port, playernum_limit);
			if(server>=0){break;}
			port++;
		}
		if(port>=65535){show_message("failed to create, all ports are occupied");}
		else{
			if(instance_number(obj_UI_manager)){with(obj_UI_manager){port_record=obj_connecter.port;}}
			show_debug_message("server created");
			//show_debug_message("port: "+string(port));
		}
	}
	return(port);
}

function network_init(){
	if(client!=-1){network_destroy(client);client=-1;}
	if(server!=-1){network_destroy(server);server=-1;}
	ipadress="127.0.0.1";
	port=2333;
	client=-1;
	server=-1;
	ds_map_clear(client_map);
	ds_list_clear(client_name_ls);	repeat(playernum_limit){ds_list_add(client_name_ls, "")}
	ds_map_clear(client_socket_map);
	ds_map_clear(client_pre_socket_map);
	ds_list_clear(talk_message_ls);
	ds_list_clear(talk_message_ls_raw);
	ds_map_clear(client_paint_stroke_rec_map);
	ds_map_clear(paint_stock_temp);
	ds_map_clear(paint_stock_temp_server);
	ds_map_clear(client_apply_map);

	client_online_status=array_create(playernum_limit, -1);
	
	uuid=-1;
	pre_uuid=-1;
	delay=-1;
	delay_value=-1;
	player_name_arr=[];
	server_socket=-1;
	//client_socket_self=-1;	client_socket_self作为断线重连重要存储依据不能直接删除
	talk_status=0;
	buffer_keep=0;
	synchronize_arr[0][1]=-1;	synchronize_arr[0][2]=0;
	synchronize_arr[1][1]=-1;	synchronize_arr[1][2]=0;
}
#endregion
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
#region C->S && S->C pck send
//C->S
//uuid: 0-limit
//pck_type: 0-初次连接及预登录 1-登录 2-确认状态/计算延迟 3-数据
//后同

//S->C																		write	read
//uuid: ____-确认																0	0
//pck_type: 0-初次连接分配 1-登录 2-确认状态/计算延迟 3-数据						1	1
//confirm: 用户名/数据类型														2	2
//data_size		3 or 3+															3	3
//data_mark		0:log or command  1:talk  2:paint								4	4
//data_type(json)	array(in json)												5	/
//data...																		6+	5+
//
//command: room_goto, stroke_withdraw
function pre_allo(C_socket, _pre_uuid){
	if(C_socket==undefined){return(-1);}
	var pck_log_pre=buffer_create(256, buffer_fixed, 1);
	buffer_seek(pck_log_pre, buffer_seek_start, 0);
	buffer_write(pck_log_pre, buffer_s16, _pre_uuid);//提供预uuid
	buffer_write(pck_log_pre, buffer_u8, 0);//初次连接
	buffer_write(pck_log_pre, buffer_string, "_");//初次连接
	buffer_write(pck_log_pre, buffer_u16, 3)//信息量
	network_send_packet(C_socket, pck_log_pre, buffer_get_size(pck_log_pre));
	buffer_delete(pck_log_pre);
	return(1);
}

function sign_or_log(_uuid, log, socket_send){//注册log为0，登录log为1
	var log_status=0;
	if(log==1){log_status=1;}
	var pck_log=buffer_create(256, buffer_fixed, 1);
	buffer_seek(pck_log, buffer_seek_start, 0);
	buffer_write(pck_log, buffer_s16, _uuid);//申请uuid
	buffer_write(pck_log, buffer_u8, log_status);//初次连接
	buffer_write(pck_log, buffer_string, username);//初次连
	if(socket_send!=undefined){
		buffer_write(pck_log, buffer_u16, 4);
		buffer_write(pck_log, buffer_u8, 0);//mark
		var temp_json=json_stringify([buffer_u8]);
		buffer_write(pck_log, buffer_string, temp_json);
		buffer_write(pck_log, buffer_u16, socket_send);
	}//socket
	else{buffer_write(pck_log, buffer_u16, 3)}
	if(server_socket==undefined){return(-1);}
	network_send_packet(server_socket, pck_log, buffer_get_size(pck_log));
	buffer_delete(pck_log);
	return(1);
}

function log_feedback(aim_socket, _username, temp_uuid, log, socket_feedback){//注册log为0，登录log为1
	if(aim_socket==undefined || temp_uuid==undefined){return(-1);}
	var log_status=0;
	if(log==1){log_status=1;}
	var pck_log_feedback=buffer_create(256, buffer_fixed, 1);
	//var  temp_uuid=uuid_find(_username);
	buffer_seek(pck_log_feedback, buffer_seek_start, 0);
	buffer_write(pck_log_feedback, buffer_s16, temp_uuid);//分配uuid或返回-1
	buffer_write(pck_log_feedback, buffer_u8, log_status);
	buffer_write(pck_log_feedback, buffer_string, _username);
	
	if(socket_feedback==undefined){buffer_write(pck_log_feedback, buffer_u16, 3)}
	else{
		buffer_write(pck_log_feedback, buffer_u16, 4);
		buffer_write(pck_log_feedback, buffer_u8, 0);//mark
		var temp_json=json_stringify([buffer_u8]);
		buffer_write(pck_log_feedback, buffer_string, temp_json);
		buffer_write(pck_log_feedback, buffer_u16, socket_feedback);
	}
	network_send_packet(aim_socket, pck_log_feedback, buffer_get_size(pck_log_feedback));
	buffer_delete(pck_log_feedback);
	return(temp_uuid);
}

function data_send(_uuid, _username, aim_socket, temp_data_content, temp_data_type, data_mark){//temp_data_content格式为array; temp_data_type为json形式array,并写入下一行内容
	if(aim_socket==undefined || _uuid==undefined){return(-1);}
	if(_username==undefined || temp_data_content==undefined || temp_data_type==undefined|| data_mark==undefined){return(-1);}

	var pck_data=buffer_create(256, buffer_grow, 1);
	buffer_seek(pck_data, buffer_seek_start, 0);
	buffer_write(pck_data, buffer_s16, _uuid);
	buffer_write(pck_data, buffer_u8, 3);
	buffer_write(pck_data, buffer_string, _username);
	buffer_write(pck_data, buffer_u16, 4+array_length(temp_data_content))//数据信息量, 3+1(type:json)+data_content
	buffer_write(pck_data, buffer_u8, data_mark);//mark
	
	buffer_write(pck_data, buffer_string, temp_data_type);//写入buffer_type内容的json
	var temp_array=json_parse(temp_data_type);//从json中读取buffer_type为内容的array
	for(var i=0; i<array_length(temp_data_content); i++){buffer_write(pck_data, temp_array[i], temp_data_content[i])}
	
	network_send_packet(aim_socket, pck_data, buffer_get_size(pck_data));
	buffer_delete(pck_data);
	return(1);
}

function data_send_all(temp_data_content, temp_data_type, data_mark){
	for(var i=0; i<playernum_limit; i++){
		if(client_socket_map[? i]!=undefined){data_send(i, client_map[? i], client_socket_map[? i], temp_data_content, temp_data_type, data_mark);}
	}
}

function connection_confirm(socket, _type, _uuid, _username){//0-确认socket状态 其他-延迟计算	返回-1或正值 使用：C: c_c(S_socket, 0/current_time, uuid, username); S: c_c(C_socket, 0/_type. C_uuid, C_username)
	var temp_status=0;
	if(socket==undefined || _uuid==undefined || _type==undefined){return(-1)}
	
	var pck_log=buffer_create(256, buffer_fixed, 1);
	buffer_write(pck_log, buffer_u16, _uuid);
	buffer_write(pck_log, buffer_u8, 2);
	buffer_write(pck_log, buffer_string, _username);
	if(type=="client" && _type==0){buffer_write(pck_log, buffer_u16, 3)}//客户端登录确认
	else if(type=="client" && _type!=0){//客户端计算延迟
		buffer_write(pck_log, buffer_u16, 4)
		buffer_write(pck_log, buffer_u8, 0);//mark
		buffer_write(pck_log, buffer_string, json_stringify([buffer_u32]))
		buffer_write(pck_log, buffer_u32, _type);
	}
	else if(type=="server" && _type==0){//服务端登录确认
		buffer_write(pck_log, buffer_u16, 3)
	}
	else if(type=="server" && _type!=0){//服务端返回延迟
		buffer_write(pck_log, buffer_u16, 5);
		buffer_write(pck_log, buffer_u8, 0);//mark
		buffer_write(pck_log, buffer_string, json_stringify([buffer_u32, buffer_string]))
		buffer_write(pck_log, buffer_u32, _type);
		
		var temp_username_arr=[username];
		for(var i=0; i<playernum_limit; i++){var temp_name=client_name_ls[| i]; if(temp_name!=""){array_push(temp_username_arr, temp_name)}}
		buffer_write(pck_log, buffer_string, json_stringify(temp_username_arr));
	}
	temp_status=network_send_packet(socket, pck_log, buffer_get_size(pck_log));
	buffer_delete(pck_log);
	
	if(temp_status<0){temp_status=-1;}
	return(temp_status);
}

#endregion
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
#region user or server rule
function uuid_find(_username){//若新建，则返回正值，若已有，返回已有的负值对应(0对-1， 1对-2)
	var temp_uuid=0;
	if(_username==undefined){return(undefined);}//不执行
	else if(_username!=undefined && ds_list_find_index(client_name_ls, _username)==-1){//新用户名注册，分配新uuid并记录
		while(ds_map_find_value(client_map, temp_uuid)!=undefined && ds_map_find_value(client_map, temp_uuid)!=""){
			temp_uuid++;
			//show_debug_message("uuid_find进位，当前temp_uuid为"+string(temp_uuid))
		}
		if(temp_uuid>=playernum_limit){return(undefined)}
	}
	else if(_username!=undefined && ds_list_find_index(client_name_ls, _username)!=-1){//用户名已被注册，或验证登录，或返回
		temp_uuid=ds_list_find_index(client_name_ls, _username);
		temp_uuid=(temp_uuid+1)*(-1);
	}
	return(temp_uuid);
}

function buffer_read_type1(buffer, temp_ls, data_add){//读取数据文件则返回1，否则0, data_add指定1/0，为读取数据类型的形式为buffer内部存储，为json形式array，且不写入总读取数据内
	buffer_seek(buffer, buffer_seek_start, 0);
	ds_list_add(temp_ls, buffer_read(buffer, buffer_s16));//读uuid
	ds_list_add(temp_ls, buffer_read(buffer, buffer_u8));//读包分类
	ds_list_add(temp_ls, buffer_read(buffer, buffer_string));//读用户名
	ds_list_add(temp_ls, buffer_read(buffer, buffer_u16));//读数据量
	
	if(data_add!=undefined && temp_ls[| 3]>3){
		ds_list_add(temp_ls, buffer_read(buffer, buffer_u8));//读mark
		var temp_array=json_parse(buffer_read(buffer, buffer_string));
		for(var i=0; i<array_length(temp_array); i++){ds_list_add(temp_ls ,buffer_read(buffer, temp_array[ i]))}
	}
	return(1)
}

function user_clear(_uuid){
	ds_map_delete(client_paint_stroke_rec_map, client_name_ls[| _uuid]);
	ds_map_delete(client_apply_map, client_name_ls[| _uuid]);
	//后续再加
	
	ds_list_replace(client_name_ls, _uuid, "");
	ds_map_replace(client_map, _uuid, "");
	ds_map_replace(client_socket_map, _uuid, -1);
	array_set(client_online_status, _uuid, -1);
}

function string_to_talkmsg(_username, str, _time){
	if(_time==undefined){_time=real(string_format(date_current_datetime(), 8, 16));}
	return(string(_username)+";"+scr_time_format(_time)+";"+str);
}
#endregion

#region painting related

function stroke_stock_delete(_stroke_arr, num, order){//返回剩余未删除步数， 默认删除最早笔画
	var temp_num=0;
	if(order==undefined || order){//默认删除最早笔画
		if(array_length(_stroke_arr[0])==0){array_delete(_stroke_arr, 0, 1)}
		while(temp_num!=num){
			if(array_length(_stroke_arr)){
				var temp_arr=_stroke_arr[0];
				if(array_length(temp_arr)==1){//若删除至笔画属性列，删除后进位
					array_delete(_stroke_arr, 0, 1); 
					if(array_length(_stroke_arr)){temp_arr=_stroke_arr[0];}
					else{break;}
				}
				array_delete(temp_arr, 1, 1);
				array_set(_stroke_arr, 0, temp_arr);
				temp_num++;
				
				if(temp_num==num && array_length(temp_arr)==1){array_delete(_stroke_arr, 0, 1);}
			}
			else{break;}
		}
	}
	else{
		if(array_length(scr_array_last(_stroke_arr))==0){array_pop(_stroke_arr)}
		while(temp_num!=num){//撤回删除最后笔画
			if(array_length(_stroke_arr)){
				var temp_column=array_length(_stroke_arr)-1;
				var temp_arr=_stroke_arr[temp_column];
				if(array_length(temp_arr)==1){
					array_delete(_stroke_arr, temp_column, 1); 
					if(temp_column>0){temp_column=array_length(_stroke_arr)-1;temp_arr=_stroke_arr[temp_column];}
					else{break;}
				}
				array_pop(temp_arr);
				temp_num++;
				
				if(temp_num==num && array_length(temp_arr)==1){array_delete(_stroke_arr, temp_column, 1);}
			}
			else{break;}
		}
	}
	return(num-temp_num);
}

function stroke_add(_stroke_arr, array_add){
	var temp_end_column=array_length(_stroke_arr)-1;
	var temp_array_add=[];
	array_copy(temp_array_add, 0, array_add, 0, array_length(array_add));
	if(array_equals(temp_array_add[0][0], _stroke_arr[temp_end_column][0])){
		array_delete(temp_array_add[0], 0, 1);
		array_copy(_stroke_arr[temp_end_column], array_length(_stroke_arr[temp_end_column]), temp_array_add[0], 0, array_length(temp_array_add[0]));
		array_delete(temp_array_add, 0, 1)
	}
	if(array_length(temp_array_add)==0){return(1)}
	for(var i=0; i<array_length(temp_array_add); i++){
		array_push(_stroke_arr, temp_array_add[i])
	}
	return(1);
}

function stroke_read(_stroke_arr, index, num, order){//index为以order为方向判断基础的记录点序号（数值上无关笔画）, 默认从0开始读
	var temp_index=0;
	var temp_num=0;
	var temp_column=0;
	var temp_arr=[];
	if(order==undefined || order>0){order=1;}else{order=0;temp_column=array_length(_stroke_arr)-1}
	
	while(temp_num!=num){
		if(order){
			var now_column=array_length(temp_arr);
			if(temp_index==index){array_push(temp_arr, []);array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);}
			for(var i=1; i<array_length(_stroke_arr[temp_column]); i++){
				if(temp_num==num){break;}
				if(temp_index==index){
					if(array_length(temp_arr)==0){
						array_push(temp_arr, []);
						array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);
					}
					array_push(temp_arr[now_column], _stroke_arr[temp_column][i]);temp_num++;
				}
				else {temp_index++;}
			}
			temp_column++;
			if(temp_column==array_length(_stroke_arr)){break;}
		}
		else{//从后向前读
			temp_column=array_length(_stroke_arr)-1;
			var now_column=array_length(temp_arr);
			if(temp_index==index){array_push(temp_arr, []);if(array_length(temp_arr[now_column])==0){array_push(temp_arr[now_column], _stroke_arr[temp_column][0]);}}
			for(var i=array_length(_stroke_arr[temp_column])-1; i>0; i--){
				if(temp_num==num){break;}
				if(temp_index==index){
					if(array_length(temp_arr)==0){array_push(temp_arr, []);array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);}
					//if(array_length(temp_arr[now_column])==0){array_push(temp_arr[now_column], _stroke_arr[temp_column][0]);}
					array_push(temp_arr[now_column], _stroke_arr[temp_column][i]);
					temp_num++;
				}
				else {temp_index++;}
			}
			temp_column--;
			if(temp_column==-1){break;}
		}
	}
	return(temp_arr);
}

#endregion