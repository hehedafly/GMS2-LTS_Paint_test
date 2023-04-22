function scr_string_complete(ostring, cha_complete, full_length, left_num, right_num){//若补齐元素为长字符串，则...
	var left_complete, right_complete, string_output;
	string_output=ostring;
	if(left_num<0){left_complete=floor((full_length-string_length(ostring))/string_length(cha_complete)); right_complete=0}
	else if(right_num<0){right_complete=floor((full_length-string_length(ostring))/string_length(cha_complete)); left_complete=0}
	else {left_complete=left_num; right_complete=right_num}
	
	var mean_num=0;//左右平均补齐
	while((left_complete+right_complete)*string_length(cha_complete)+string_length(ostring)>full_length){
		if(left_complete==0 && right_complete==0){return(ostring)}
		if(right_complete>0 && mean_num==0){right_complete-=1; mean_num=1;}
		else if(left_complete>0 && mean_num==1){left_complete-=1; mean_num=0;}
		else{mean_num=abs(mean_num-1)}
	}
	
	repeat(left_complete){string_output=cha_complete+string_output;}
	repeat(right_complete){string_output=string_output+cha_complete;}
	return(string_output);
	//if(string_length(cha_complete)==1){repeat(left_complete){string_output=cha_complete+string_output};repeat(right_complete){string_output=string_output+cha_complete}}
	//else if(string_length(cha_complete)>1){repeat(left_complete){string_output=cha_complete+string_output};repeat(right_complete){string_output=string_output+cha_complete}}
	
}