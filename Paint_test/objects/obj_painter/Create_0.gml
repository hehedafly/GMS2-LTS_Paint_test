srf_background=-1;
srf_templayer=-1
srf_templayer_keep=0;//0:free srf_templayer each step, used in bool_select
temp_pos=0;
temp_pos2=room_height;

paint_pen=0;//0:round, 1:cube, 2:rectange, 3:ellipse, 4:circle
paint_pen_recpos0x=-1;
paint_pen_recpos0y=-1;
paint_pen_recpos01x=-1;
paint_pen_recpos01y=-1;
paint_pen_recpos1x=-1;
paint_pen_recpos1y=-1;
paint_pen_size=5;
paint_painting=1;//0 or 1, 受别的obj控制时设为负等
paint_color=c_black;
paint_color_selecting=0;//0:select gui present, 1:close

withdraw_max=10;//最大撤回次数
withdraw_surface=-1;
stroke_penup=0;//抬起瞬间为1，多人用于记录
stroke_withdraw_rec_num=0;
stroke_full_withdraw_rec_arr=[];//笔画数列表
stroke_arr=[];//3d array, d1按笔画顺序排列, d2按同性质笔画排列, d3存储信息，arr[n][0]存储pen, size, color信息，其他为笔画
stroke_pre_arr=[];//3d array, d1按笔画顺序排列, d2按同性质笔画排列, d3存储信息，arr[n][0]存储pen, size, color信息，其他为笔画 联网发出后可删除
//stroke_all_map=ds_map_create();//key: username, value:stroke_arr
stroke_all_arr=[];//4d array，按时间排列
stroke_all_arr_draw_rec=-1;//标记绘制至何处，意指最后已经绘制的stroke_arr的index, 最大值为arr_length-1;
stroke_all_name_arr=[];//对应all_arr记录所在用户名
stroke_all_stroke_num_map=ds_map_create();//name_arr中名字对应笔画arr，不包括自己	key:username  value:array (form: [stroke_num])
stroke_all_temp_name="";
//surface应共用，整合时删除
stroke_all_surface=-1;
stroke_all_withdraw_surface=-1;
stroke_self_temp_surface=-1;//连续画笔绘制时(pen==0/ pen==1)临时绘制于最上层
//stroke_all_name_rec=ds_map_create();
stroke_smooth=1;//0,1,插值绘制
stroke_smooth_temp_stock=[];

multiplayer=instance_number(obj_connecter);//多人时设为1
username="";
if(multiplayer){username=obj_connecter.username;}
stroke_network_rec_num=0;
stroke_network_rec_pos=0;
//stroke_pre_network_rec_num=0;
stroke_network_synchronize=-1;
stroke_network_synchronize_check=floor(room_speed*0.25);//此传输间隔应小于手绘最大撤回次数笔画所需时间
command_rec="";
stroke_withdraw_refresh=0;//为正时将在联机绘制事件中重绘撤回后的状态

function recpos_clear(){
	paint_pen_recpos0x=-1;
	paint_pen_recpos0y=-1;
	paint_pen_recpos01x=-1;
	paint_pen_recpos01y=-1;
	paint_pen_recpos1x=-1;
	paint_pen_recpos1y=-1;
}

globalvar paint_arr;
paint_arr=[];

function drawing(pen, pen_size, pen_color, pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y, force){
	if(force==undefined){force=0;}
	if(pen>=2){
		if(_paint_pen_recpos1x!=-1 || _paint_pen_recpos1y!=-1){
			if(pen==2){draw_rectangle_color(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y, pen_color, pen_color, pen_color, pen_color, false)}
			if(pen==3){draw_ellipse_color(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y, pen_color, pen_color, false);}
			if(pen==4){draw_circle_color(_paint_pen_recpos0x, _paint_pen_recpos0y, point_distance(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y), pen_color, pen_color, false);}
			recpos_clear();
		}
	}
	else{
		if(mouse_check_button(mb_left) || force){
			if(pen==0){draw_circle_color(pen_x, pen_y, pen_size*0.5, pen_color, pen_color, false)}
			else if(pen==1){draw_rectangle_color(pen_x-pen_size*0.5, pen_y-pen_size*0.5, pen_x+pen_size*0.5, pen_y+pen_size*0.5, pen_color, pen_color, pen_color, pen_color, false)}
		}
	}
}

function pre_drawing(pen, pen_size, pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y){
	if(pen==0){draw_circle_color(pen_x, pen_y, pen_size*0.5, c_black, c_black, true)}
	else if(pen==1){draw_rectangle_color(pen_x-pen_size*0.5, pen_y-pen_size*0.5, pen_x+pen_size*0.5, pen_y+pen_size*0.5, c_black, c_black, c_black, c_black, true)}
	else if(pen==2 && (_paint_pen_recpos0x!=-1 || _paint_pen_recpos0y!=-1)){draw_rectangle_color(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y, c_black, c_black, c_black, c_black, true)}
	else if(pen==3 && (_paint_pen_recpos0x!=-1 || _paint_pen_recpos0y!=-1)){draw_ellipse_color(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y, c_black, c_black, true);}
	else if(pen==4 && (_paint_pen_recpos0x!=-1 || _paint_pen_recpos0y!=-1)){draw_circle_color(_paint_pen_recpos0x, _paint_pen_recpos0y, point_distance(_paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y), c_black, c_black, true);}
}

//pre_draw时不记录pen=0/1时情况
function stroke_stock(drawing_or_pre, pen, pen_size, pen_color, pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y){
	if(!drawing_or_pre && (pen==0 || pen==1)){return(-1);}
	if(drawing_or_pre){//存储笔画信息
		if(!array_length(stroke_arr)){//新建笔画
			var temp_new_arr=[];
			array_push(temp_new_arr, [pen, pen_size, pen_color]);
			array_push(temp_new_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);
			array_push(stroke_arr, temp_new_arr);
			stroke_withdraw_rec_num++;
			stroke_network_rec_num++;
			return(1);
		}
		else{
			var temp_arr=array_pop(stroke_arr);//可能需要更改，使用pop
			if(array_equals([pen, pen_size, pen_color], temp_arr[0])){//笔画属性相同，检查笔画位置是否记录新笔画
				var temp_pos_arr=scr_array_last(temp_arr);
				if(array_equals(temp_pos_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y])){array_push(stroke_arr, temp_arr);return(0);}
				else{array_push(temp_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);array_push(stroke_arr, temp_arr);stroke_withdraw_rec_num++;stroke_network_rec_num++;return(1);} 
			}
			else{//笔画属性不同，创建新2darray
				array_push(stroke_arr, temp_arr);
				var temp_new_arr=[];
				array_push(temp_new_arr, [pen, pen_size, pen_color]);
				array_push(temp_new_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);
				array_push(stroke_arr, temp_new_arr);
				stroke_withdraw_rec_num++;
				stroke_network_rec_num++;
				return(2);
			}
		}
	}
	else if(multiplayer){//多人时存储pre_draw信息
		if(!array_length(stroke_pre_arr)){//新建笔画
			var temp_new_arr=[];
			array_push(temp_new_arr, [pen, pen_size, pen_color]);
			array_push(temp_new_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);
			array_push(stroke_pre_arr, temp_new_arr);
			return(1);
		}
		else{
			var temp_arr=array_pop(stroke_pre_arr);//可能需要更改，使用pop
			if(array_equals([pen, pen_size, pen_color], temp_arr[0])){//笔画属性相同，检查笔画位置是否记录新笔画
				var temp_pos_arr=scr_array_last(temp_arr);
				if(array_equals(temp_pos_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y])){array_push(stroke_arr, temp_arr);return(0);}
				else{array_push(temp_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);array_push(stroke_arr, temp_arr);return(1);} 
			
			}
			else{//笔画属性不同，创建新2darray
				array_push(stroke_pre_arr, temp_arr);
				var temp_new_arr=[];
				array_push(temp_new_arr, [pen, pen_size, pen_color]);
				array_push(temp_new_arr, [pen_x, pen_y, _paint_pen_recpos0x, _paint_pen_recpos0y, _paint_pen_recpos1x, _paint_pen_recpos1y]);
				return(2);
			}
		}
	}
}

function stroke_redo(_stroke_arr, drawing_or_pre){//每次重做必定在一列（一个笔画）之内
	for(var i=0; i<array_length(_stroke_arr); i++){
		var pen, pen_size, pen_color;
		pen				=_stroke_arr[i][0][0];
		pen_size		=_stroke_arr[i][0][1];
		pen_color		=_stroke_arr[i][0][2];
		for(var j=1; j<array_length(_stroke_arr[i]); j++){
			var temp_arr_pos=_stroke_arr[i][j];
			if(drawing_or_pre){
				drawing(pen, pen_size, pen_color, temp_arr_pos[0], temp_arr_pos[1], temp_arr_pos[2], temp_arr_pos[3], temp_arr_pos[4], temp_arr_pos[5], 1);
				if(stroke_smooth==1 && pen<2 && j>2){//插入中间笔画
					var temp_arr_pos_next=_stroke_arr[i][j-1];
					drawing(pen, pen_size, pen_color, (temp_arr_pos[0]+temp_arr_pos_next[0])*0.5, (temp_arr_pos[1]+temp_arr_pos_next[1])*0.5, temp_arr_pos[2], temp_arr_pos[3], temp_arr_pos[4], temp_arr_pos[5], 1);
				}
			}
			else{pre_drawing(pen, pen_size, temp_arr_pos[0], temp_arr_pos[1], temp_arr_pos[2], temp_arr_pos[3], temp_arr_pos[4], temp_arr_pos[5])}
		}	
	}
}

function stroke_stock_delete(_stroke_arr, num, order){//返回剩余未删除步数， 默认删除最早笔画
	var temp_num=0;
	if(order==undefined || order){//默认删除最早笔画
		if(array_length(_stroke_arr[0])==0){array_delete(_stroke_arr, 0, 1)}
		while(temp_num!=num){
			if(array_length(_stroke_arr)){
				var temp_arr=_stroke_arr[0];
				if(array_length(temp_arr)==1){//若删除至笔画属性列，删除后进位
					array_delete(_stroke_arr, 0, 1); 
					if(array_length(_stroke_arr)){temp_arr=_stroke_arr[0];}
					else{break;}
				}
				array_delete(temp_arr, 1, 1);
				array_set(_stroke_arr, 0, temp_arr);
				temp_num++;
				
				if(temp_num==num && array_length(temp_arr)==1){array_delete(_stroke_arr, 0, 1);}
			}
			else{break;}
		}
	}
	else{
		if(array_length(scr_array_last(_stroke_arr))==0){array_pop(_stroke_arr)}
		while(temp_num!=num){//撤回删除最后笔画
			if(array_length(_stroke_arr)){
				var temp_column=array_length(_stroke_arr)-1;
				var temp_arr=_stroke_arr[temp_column];
				if(array_length(temp_arr)==1){
					array_delete(_stroke_arr, temp_column, 1); 
					if(temp_column>0){temp_column=array_length(_stroke_arr)-1;temp_arr=_stroke_arr[temp_column];}
					else{break;}
				}
				array_pop(temp_arr);
				temp_num++;
				
				if(temp_num==num && array_length(temp_arr)==1){array_delete(_stroke_arr, temp_column, 1);}
			}
			else{break;}
		}
	}
	return(num-temp_num);
}

function stroke_add(_stroke_arr, array_add){
	var temp_end_column=array_length(_stroke_arr)-1;
	var temp_array_add=[];
	array_copy(temp_array_add, 0, array_add, 0, array_length(array_add));
	//var temp_start_column=0;
	if(array_equals(temp_array_add[0][0], _stroke_arr[temp_end_column][0])){
		array_delete(temp_array_add[0], 0, 1);
		array_copy(_stroke_arr[temp_end_column], array_length(_stroke_arr[temp_end_column]), temp_array_add[0], 0, array_length(temp_array_add[0]));
		array_delete(temp_array_add, 0, 1)
	}
	if(array_length(temp_array_add)==0){return(1)}
	for(var i=0; i<array_length(temp_array_add); i++){
		array_push(_stroke_arr, temp_array_add[i])
	}
	return(1);
}

function stroke_read(_stroke_arr, index, num, order){//index为以order为方向判断基础的记录点序号（数值上无关笔画）, 默认从0开始读
	var temp_index=0;
	var temp_num=0;
	var temp_column=0;
	var temp_arr=[];
	if(order==undefined || order>0){order=1;}else{order=0;temp_column=array_length(_stroke_arr)-1}
	
	while(temp_num!=num){
		if(order){
			var now_column=array_length(temp_arr);
			if(temp_index==index){array_push(temp_arr, []);array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);}
			for(var i=1; i<array_length(_stroke_arr[temp_column]); i++){
				if(temp_num==num){break;}
				if(temp_index==index){
					if(array_length(temp_arr)==0){
						array_push(temp_arr, []);
						array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);
					}
					array_push(temp_arr[now_column], _stroke_arr[temp_column][i]);temp_num++;
				}
				else {temp_index++;}
			}
			temp_column++;
			if(temp_column==array_length(_stroke_arr)){break;}
		}
		else{//从后向前读
			temp_column=array_length(_stroke_arr)-1;
			var now_column=array_length(temp_arr);
			if(temp_index==index){array_push(temp_arr, []);if(array_length(temp_arr[now_column])==0){array_push(temp_arr[now_column], _stroke_arr[temp_column][0]);}}
			for(var i=array_length(_stroke_arr[temp_column])-1; i>0; i--){
				if(temp_num==num){break;}
				if(temp_index==index){
					if(array_length(temp_arr)==0){array_push(temp_arr, []);array_push(temp_arr[now_column],  _stroke_arr[temp_column][0]);}
					//if(array_length(temp_arr[now_column])==0){array_push(temp_arr[now_column], _stroke_arr[temp_column][0]);}
					array_push(temp_arr[now_column], _stroke_arr[temp_column][i]);
					temp_num++;
				}
				else {temp_index++;}
			}
			temp_column--;
			if(temp_column==-1){break;}
		}
	}
	return(temp_arr);
}
	
function command_resolve(command){
	if(command==""){return(-1);}
	//"stroke_withdraw;"+username+";"+string(scr_array_last(obj_painter.stroke_full_withdraw_rec_arr))
	stroke_all_temp_name=scr_read_cut(command, 1);
	var temp_withdraw_rec=real(scr_read_cut(command, 2));
	var temp_function=function(element){return(element==stroke_all_temp_name)}
	var temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function, -1);//得到stroke_all_arr中当前名字第一个位置
	if(temp_pos==-1){return(-1)}
	stroke_withdraw_refresh++;
	var temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], temp_withdraw_rec, 0);//stroke_all_arr一次存储最多一个笔画
	array_delete(stroke_all_arr, temp_pos, 1);
	array_delete(stroke_all_name_arr, temp_pos, 1);
	stroke_all_arr_draw_rec--;
						
	while(temp_delete>0){
		var temp_function=function(element){return(element==stroke_all_temp_name)}
		temp_pos=scr_array_find_index(stroke_all_name_arr, temp_function, -1);if(temp_pos<0){break;}
		temp_delete=stroke_stock_delete(stroke_all_arr[temp_pos], temp_delete, 0);
		
		array_delete(stroke_all_arr, temp_pos, 1);
		array_delete(stroke_all_name_arr, temp_pos, 1);
		stroke_all_arr_draw_rec--;
	}
	
	if(is_array(stroke_all_stroke_num_map[? stroke_all_temp_name])){array_pop(stroke_all_stroke_num_map[? stroke_all_temp_name]);}else{ds_map_delete(stroke_all_stroke_num_map, stroke_all_temp_name)}
	stroke_all_temp_name="";
}