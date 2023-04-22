ls_points=ds_list_create();
map_points_manage=ds_map_create();
ls_fourier=ds_list_create();
ox=400;
oy=300;
draw_mode=1;//0:fourier series; 1: free draw

function free_points_add(xx, yy, relative){
	var temp_array;
	if(relative){
		var temp_ls_array=ds_list_find_value(ls_points,ds_list_size(ls_points)-1);
		if(is_array(temp_ls_array)){
			temp_array=[temp_ls_array[0]+xx,temp_ls_array[1]+yy]
		}
		else{temp_array=[ox+xx,oy+yy]}
	}
	else{temp_array=[xx, yy];}
	
	ds_list_add(ls_points, temp_array);
}

function fourier_points_add(rr, vv){
	var temp_array;
	temp_array=[rr, vv]
	
	ds_list_add(ls_fourier, temp_array);
}

function draw_fourier_series(phase){
	
}

function draw_free_points(){

}

function edit_free_points(xx, yy){
	//xx=mouse_x, yy=mouse_y
	var temp_
}