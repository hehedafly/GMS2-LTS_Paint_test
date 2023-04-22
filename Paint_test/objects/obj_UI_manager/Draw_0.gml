//"multiplayer", "singleplayer", "host", "enter", "cancel", "back"
//if(mouse_check_button(mb_none) && click==1){click=0;click_recordpos=[mouse_x, mouse_y];}
if(mouse_check_button_pressed(mb_left)){click=1;click_recordpos=[mouse_x, mouse_y];}
if(mouse_check_button_released(mb_left)){if(click==1){array_insert(click_recordpos, 2, mouse_x, mouse_y);click=0;}}
var temp_name_text="username: "+username_record
draw_text_color(room_width-64-string_width(temp_name_text), 16, temp_name_text, c_black, c_black, c_black, c_black, 1);


if(room==Room_start){
	draw_text_ext_transformed_color(16, 48, "F1 打开帮助", 1, 1000, 4, 4, -15, c_black,c_red, c_red, c_black, 1);
	
	
	var button_pos_map=ds_map_create();
	var size=64;
	ds_map_add(button_pos_map, 0, [room_width*0.5-128, room_height*0.5, 9999, 9999])
	ds_map_add(button_pos_map, 1, [room_width*0.5+128, room_height*0.5, 9999, 9999])
	draw_new_button(button_pos_map[? 0][0], button_pos_map[? 0][1], 0, size, button_pos_map, 0);
	draw_new_button(button_pos_map[? 1][0], button_pos_map[? 1][1], 1, size, button_pos_map, 1);
	
	if(array_length(click_recordpos)==4){	
		if(button_pos_map[? 0][2]<size && button_pos_map[? 0][3]< size){//multi
			mouse_init();
			username_record=get_text("username", username_record,  username_record);
			if(username_record!=""){room_goto(Room_connecting);}
		}
		else if(button_pos_map[? 1][2]<size && button_pos_map[? 1][3]< size){//single
			mouse_init();
			room_goto(Room_paint);
			if(instance_number(obj_connecter)){with(obj_connecter){instance_destroy(self);}}
		}
	}
	ds_map_destroy(button_pos_map);
}
if(room==Room_connecting){
	if(!instance_number(obj_connecter)){synchronization(instance_create_depth(0,0,1,obj_connecter))}
	else if(obj_connecter.username!=username_record || obj_connecter.uuid!=uuid_record){synchronization(obj_connecter, 1);}
	
	var button_pos_map=ds_map_create();
	var size=64;
	ds_map_add(button_pos_map, 0, [room_width*0.5-192,	room_height*0.5+128, 9999, 9999])
	ds_map_add(button_pos_map, 1, [room_width*0.5,		room_height*0.5+128, 9999, 9999])
	ds_map_add(button_pos_map, 2, [room_width*0.5+192,	room_height*0.5+128, 9999, 9999])
	draw_new_button(button_pos_map[? 0][0], button_pos_map[? 0][1], 2, size, button_pos_map, 0);
	draw_new_button(button_pos_map[? 1][0], button_pos_map[? 1][1], 3, size, button_pos_map, 1);
	draw_new_button(button_pos_map[? 2][0], button_pos_map[? 2][1], 4, size, button_pos_map, 2);
	
	uuid_record=draw_text_block(room_width*0.5-64, room_height*0.2,room_width*0.5+64, room_height*0.2+32, uuid_record, 0, "uuid", "UUID: ");
	ip_record=draw_text_block(room_width*0.5-128, room_height*0.3,room_width*0.5+128, room_height*0.3+32, ip_record, 0, "ip", "IP: ");
	port_record=draw_text_block(room_width*0.5-64, room_height*0.45-32,room_width*0.5+64, room_height*0.45, port_record, 0, "port", "Port: ");
	if(is_string(port_record)){port_record=real(port_record);}

	if(array_length(click_recordpos)==4){
		if(button_pos_map[? 0][2]<size && button_pos_map[? 0][3]< size){//host
			mouse_init();
			room_goto(Room_hall);
			//show_message("hosting")
			if(instance_number(obj_connecter)){
				//synchronization(obj_connecter);
				with(obj_connecter){
					network_init();
					ipadress=obj_UI_manager.ip_record;
					port=obj_UI_manager.port_record;
					type="server";
					server_create();
				}
			}
			else{show_message("failed to create server, game reboot needed"); game_restart();}
		}
		else if(button_pos_map[? 1][2]<size && button_pos_map[? 1][3]< size){//enter
			mouse_init();
			if(ip_record==""){ip_record=get_text("ip", username_record,  ip_record);}
			//show_message("connecting")
			if(instance_number(obj_connecter)){
				//synchronization(obj_connecter);
				with(obj_connecter){
					network_init();
					ipadress=obj_UI_manager.ip_record;
					port=obj_UI_manager.port_record;
					type="client";
					client_connect();
				}
			}
			else{show_message("failed to connect, game reboot needed"); game_restart();}
			
		}
		else if(button_pos_map[? 2][2]<size && button_pos_map[? 2][3]< size){//cancel
			mouse_init();
			with(obj_connecter){network_init();instance_destroy();}
			room_goto(Room_start);
		}
	}
	ds_map_destroy(button_pos_map);
}
if(room==Room_hall){
	var button_pos_map=ds_map_create();
	var size=64;
	ds_map_add(button_pos_map, 0, [room_width*0.5-128, room_height*0.5, 9999, 9999]);
	ds_map_add(button_pos_map, 1, [room_width*0.5+128, room_height*0.5, 9999, 9999]);
	draw_new_button(button_pos_map[? 0][0], button_pos_map[? 0][1], 3, size, button_pos_map, 0);
	draw_new_button(button_pos_map[? 1][0], button_pos_map[? 1][1], 5, size, button_pos_map, 1);
	
	if(array_length(click_recordpos)==4){
		if(button_pos_map[? 0][2]<size && button_pos_map[? 0][3]< size){//enter
			mouse_init();
			with(obj_connecter){
				if(type=="server"){
					data_send_all(["room_goto;Room_paint"], json_stringify([buffer_string]), 0);
					room_goto(Room_paint);
				}
				else if(type=="client"){
					data_send(uuid, username, server_socket, ["room_goto;Room_paint"], json_stringify([buffer_string]), 0)
				}
			}
			//room_goto(Room_paint);
		}
		if(button_pos_map[? 1][2]<size && button_pos_map[? 1][3]< size){//cancel
			mouse_init();
			room_goto(Room_connecting);
			with(obj_connecter){network_init()}
		}
	}
	ds_map_destroy(button_pos_map);
}
