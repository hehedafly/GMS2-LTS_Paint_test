// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_array_last(array){
	if(is_array(array) && array_length(array)){return(array_get(array, array_length(array)-1))}
	else{return(undefined)}
}