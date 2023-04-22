//if(server!=-1){instance_destroy()}
x=clamp(random(room_width), 32, room_width-32);
y=clamp(random(room_height), 32, room_height-32);
//synchronize data: x, y, 
visible=0;
synchronize_ls=ds_list_create();
//全数字格式，十六进位，百十取余，对应类型表，固定某位对应buffer_type表
//[buffer_u8, buffer_s8, buffer_u16, buffer_s16, buffer_u32, buffer_s32, buffer_f16, buffer_f32, buffer_f64, buffer_bool, buffer_string, buffer_u64, buffer_text]	——[1-13]