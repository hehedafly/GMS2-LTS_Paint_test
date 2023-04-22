//if(keyboard_check(vk_control) && keyboard_check_pressed(vk_tab)){
//	if(visible_stock==0){with(all){visible=1};visible_stock=1}
//	else{with(all){visible=0};visible_stock=0}
//}
//if(restart_clock<restart_clock_max){restart_clock++;}
//else{if(instance_number(obj_connecter)){
//	with(obj_connecter){if(type=="server" && ds_map_size(client_map)){game_restart()}}
//	}
//	restart_clock=0;
//}
if(keyboard_check_pressed(vk_f1)){show_message_async("除非断线重连，请设置uuid为-1\n若不能连接，请按照提示更改，或退回上一界面检查ip与端口\nEsc为通用退出键\n进入绘图界面后，左键绘制，鼠标滚轮改变画笔大小，按住ctrl精细调节\n按下Tab，拖动选择画笔颜色，按下Ctrl+Z以撤回，按shift改变画笔\n进入大厅后即可聊天，按下T打开聊天窗口,按下Enter发送消息\n待大厅内所有人准备好后才能进入联机绘画\n按Esc离开，同样所有人准备好离开时将关闭当前房间\n不能中途加入")}
/*

*/