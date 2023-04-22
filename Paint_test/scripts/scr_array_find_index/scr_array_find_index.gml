// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_array_find_index(array, methods, offset){
	if(offset==undefined){offset=0;}
	var i=0;
	if(offset>=0 && offset>array_length(array)-1){return(-1)}//正向offset超过array_length视为没过
	else if(offset<0 && abs(offset)>array_length(array)){return(-1)}//反向offset视-1为反向起点，-2为反向没过第一个

	if(sign(offset)>=0){i=offset}
	else if(sign(offset)==-1){i=array_length(array)+offset}
	for(var ii=i; (ii>=0 && ii<array_length(array)); ii+=sign(offset+0.5)){
		show_debug_message("scr_array_find_index: "+string(array)+";"+ string(ii))
		if(methods(array[ii])){return(ii)};
	}
	show_debug_message("scr_array_find_index: "+string(array)+";"+ string(-1))
	return(-1);
}