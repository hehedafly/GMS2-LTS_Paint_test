// input: current_time  output: format like 2023/02/06  22:37:10
function scr_time_format(_current_time){//real
		_current_time=string(date_get_year(_current_time))+"/"+	
  scr_string_complete(string(date_get_month(_current_time))		,"0", 2, -1, 0)+"/"+
  scr_string_complete(string(date_get_day(_current_time))		,"0", 2, -1, 0)+"  "+
  scr_string_complete(string(date_get_hour(_current_time))		,"0", 2, -1, 0)+":"+
  scr_string_complete(string(date_get_minute(_current_time))	,"0", 2, -1, 0)+":"+
  scr_string_complete(string(date_get_second(_current_time))	,"0", 2, -1, 0);
	return(_current_time);
}