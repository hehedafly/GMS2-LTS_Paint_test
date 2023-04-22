length=300;
width=20
max_value=100;
record_value=50;
globalvar slider0;
slider0=record_value;
mb_hold=0;

ttx=-1;
tty=-1;


function draw_slider(length, width, xx, yy, recpos){
	draw_rectangle_color(xx-2, yy-2, xx+length+2, yy+width+2, c_black, c_black, c_black, c_black, false);
	draw_rectangle_color(xx, yy, xx+length, yy+width, c_gray, c_gray, c_gray, c_gray, false);
	draw_rectangle_color(xx+recpos*length-15, yy-2, xx+recpos*length+15, yy+width+2, c_gray, c_gray, c_gray, c_gray, false);
	draw_rectangle_color(xx+recpos*length-15, yy, xx+recpos*length+15, yy+width, c_white, c_white, c_white, c_white, false);
	ttx=xx;
	tty=yy;
}