random_set_seed(2);

string_to_utf8=function(_string, _array){
	for(var i=0; i<string_length(_string); i++){
		_array[i]=ord(string_char_at(_string, i+1));
	}
}

key_summon=function(){
	var temp_praoba=0;
	var temp_key=0;
	var temp_irandom=0;
	for(var i=4; i>=0; i--){
		temp_irandom=irandom(1);
		if(temp_irandom==0 &&i>2){temp_praoba+=0.34;}
		if(temp_praoba>=1){temp_irandom=1; temp_praoba=0;}
		temp_key+=temp_irandom*power(10, i);
	}
	temp_key=scr_string_complete(string(temp_key), "0", 5, 5, 0)
	return(temp_key)
}

string_code=function(_source, key){
	var temp_arr=[];
	var temp_string_res=""
	var temp_res=[];
	var temp_num_arr=["5", "6", "7", "8", "9", "0", "1", "2", "3", "4"];
	
	if(is_string(_source)){
		string_to_utf8(_source, temp_arr);
		for(var j=0; j<array_length(temp_arr); j++){
			var temp_num_str=scr_string_complete(string(temp_arr[j]), "0", 5, 5, 0);
			for(var i=4; i>=0; i--){
				if(string_char_at(key, i)==1){
					temp_string_res+=temp_num_arr[(real(string_char_at(temp_num_str, 5-i)))]
				}
				else{temp_string_res+=string_char_at(temp_num_str, 5-i)}
			}
			array_push(temp_res, temp_string_res);
			temp_string_res="";
		}
		return(temp_res);
	}
	else if(is_array(_source)){
		
		for(var j=0; j<array_length(_source); j++){
			for(var i=4; i>=0; i--){
				if(string_char_at(key, i)==1){
					temp_string_res+=temp_num_arr[(real(string_char_at(_source[j], 5-i)))]
				}
				else{temp_string_res+=string_char_at(_source[j], 5-i)}
			}
			array_push(temp_res, temp_string_res);
			temp_string_res="";
		}
		for(var k=0; k<array_length(temp_res); k++){
			show_debug_message(real(temp_res[k]))
			temp_string_res+=chr(real(temp_res[k]))
		}
		return(temp_string_res);
	}
	return([]);
}
var temp_key_arr=[]
repeat(10){array_push(temp_key_arr, key_summon())}

var temp_stirng_arr=string_code("1234567890abcde哈解决掉瑟吉欧大呼", temp_key_arr[0]);
show_debug_message(temp_stirng_arr);
temp_stirng_arr=string_code(temp_stirng_arr, temp_key_arr[0])
show_debug_message(temp_stirng_arr);
