function scr_read_cut(tempstr, number) {
	var nowstr="";
	if(number<=string_count(";",tempstr)){
		if(string_count(";",tempstr)!=0){
			repeat(number){
				tempstr=string_copy(tempstr, string_pos(";",tempstr)+1 , string_length(tempstr));
			}
			if(string_count(";",tempstr)!=0){nowstr=string_copy(tempstr,1,string_pos(";",tempstr)-1);return(nowstr)}
			else{nowstr=tempstr;return(nowstr)}
		}
		else{return(tempstr)}
	}
	else{return("error")}//"error"为给值超过长度
}
