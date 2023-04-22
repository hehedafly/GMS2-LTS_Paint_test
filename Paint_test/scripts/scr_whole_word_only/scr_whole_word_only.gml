//if pos_return is true, script will return an array(not empty) or false; else script will just return true or false
function scr_whole_word_only(sub_str,str,pos_return){
	var letters="abcdefghijklmnopqrstuvwxyz";
	//var char_substitue="_"
	letters+=string_upper(letters);
	var length_pass=string_length(sub_str)-1;
	
	show_debug_message(str);
	var num=string_count(sub_str,str);
	if(num==0){return(false)}
	else if(num==1){
		//if(string_length(str)-string_length(sub_str)<=1){return(false);}
		
		var tof;
		if(string_pos(sub_str,str)==1){tof=sign(string_count(string_char_at(str,string_pos(sub_str,str)+length_pass+1),letters));}
		else if(string_last_pos(sub_str,str)==string_length(str)){tof=sign(string_count(string_char_at(str,string_pos(sub_str,str)-1),letters));}
		else{tof=sign(string_count(string_char_at(str,string_pos(sub_str,str)-1),letters)+string_count(string_char_at(str,string_pos(sub_str,str)+length_pass+1),letters));}
		
		if(!tof){return (pos_return==undefined || pos_return==false)? true: [string_pos(sub_str,str)];}
		else{return(false)}
	}
	else if(num>1){
		if(string_length(str)-string_length(sub_str)<=2){
			if(string_length(sub_str)==1 && !string_count(string_char_at(str, 2) , letters)){}
			else{return(false)}
		}//最终退出条件： 若不为 i_i 形式，则为X[aim]_或_[aim]X。 若X为字母，则其长度 必定长于[aim]至少2，防止单字母替换出错。
		
		var char_list=ds_list_create();
		//var str_pass_debut,str_pass_fin;//小分段再递归，如 "ii-ii","asd def"
		var pos_pass_debut,pos_pass_fin;//分段起始点与结束点
		//var temp_pos;//分段位置记录或是否含sub_str
		var pos_return_array=[];
		//var pos_return_bool=undefined;
		for(var i =1; i<string_length(str)+1;i++){
			ds_list_add(char_list,string_char_at(str,i));
		}
		
		for(var ii=1;ii<ds_list_size(char_list)+1; ii++){
			if(!string_count(char_list[| ii-1],letters)){
				pos_pass_debut=clamp(ii-length_pass-2,1,ds_list_size(char_list));
				pos_pass_fin=clamp(ii+length_pass+2,1,ds_list_size(char_list));		// form: X[aimlength]_[aimlength]X
																					//		debut		ii			fin
				if(pos_return==undefined || pos_return==false){//返回布尔
					if(scr_whole_word_only(sub_str,string_copy(str,pos_pass_debut,ii-pos_pass_debut+1)) || scr_whole_word_only(sub_str,string_copy(str,ii,pos_pass_fin-ii+1))){	//form:X[aimlength]_, _[aimlength]X
						ds_list_destroy(char_list);
						return(true);//有即退出
					}
				}
				else{//需返回位置
					var pos_debut=is_array(scr_whole_word_only(sub_str,string_copy(str,pos_pass_debut,ii-pos_pass_debut+1),1))? array_pop(scr_whole_word_only(sub_str,string_copy(str,pos_pass_debut,ii-pos_pass_debut+1),1)): 0;
					var pos_fin=is_array(scr_whole_word_only(sub_str,string_copy(str,ii,pos_pass_fin-ii+1),1))? array_pop(scr_whole_word_only(sub_str,string_copy(str,ii,pos_pass_fin-ii+1),1)): 0;
					if(pos_debut){
						var temp_num=(pos_debut-(ii-pos_pass_debut+1))+ii;
						var temp_pop=array_pop(pos_return_array);if(temp_pop!=undefined){array_push(pos_return_array,temp_pop);}
						if(temp_pop!=temp_num){array_push(pos_return_array,temp_num);}
					}
					if(pos_fin){
						var temp_num=pos_fin-1+ii;;
						var temp_pop=array_pop(pos_return_array);if(temp_pop!=undefined){array_push(pos_return_array,temp_pop);}
						if(temp_pop!=temp_num){array_push(pos_return_array,temp_num);}
					}
				}
			}
		}
		
		if(array_length(pos_return_array)!=0){
			ds_list_destroy(char_list);
			return(pos_return_array)
		}
		
		ds_list_destroy(char_list);
		return(false);//结束退出，即为无整词
	}
}