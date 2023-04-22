var text_rec_map = ds_map_find_value(async_load, "id");
if(text_rec_map == talk_get_async_id){
    if ds_map_find_value(async_load, "status"){
        if(ds_map_find_value(async_load, "result") != ""){
            talk_text_temp=ds_map_find_value(async_load, "result");
			keyboard_string=talk_text_temp;
        }
    }
}