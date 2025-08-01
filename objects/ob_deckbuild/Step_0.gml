if reorder_type>-1 {
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	//ORDER BY SERIAL
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	var i=0, card_pos_replace;
	repeat (deck_build_all_total) {
		card_pos_replace[i]=-1;
		i++;
	}
	//
	var i=0, serial_check=0;
	do {
		var ii=0;
		repeat (deck_build_all_total) {
			if instance_exists(deck_card_all[ii]) {
				if (reorder_type=0 or reorder_type=5) and deck_card_all[ii].card_serial=serial_check and card_pos_replace[i]=-1 {
					card_pos_replace[i]=deck_card_all[ii];
					i++;
				}
				else if (reorder_type>=1 and reorder_type<=4) and deck_card_all[ii].card_serial=serial_check and card_pos_replace[deck_build_all_total-i-1]=-1 {
					card_pos_replace[deck_build_all_total-i-1]=deck_card_all[ii];
					i++;
				}
			}
			ii++;
		}
		serial_check++;
	} until (i=deck_build_all_total or (reorder_type=5 and i=deck_build_all_total-1));
	//
	var i=0;
	repeat (deck_build_all_total) {
		deck_card_all[i]=card_pos_replace[i];
		i++;
	}
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	if reorder_type=5 {
		deck_build_all_total--;
	}
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	//ORDER BY STATS
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	var order_grid=ds_grid_create(2,deck_build_all_total);
	//
	for (var i=0; i<deck_build_all_total; i++;) {
		ds_grid_set(order_grid,0,i,deck_card_all[i]); //instance id
		//
		var order_number=0;
		if reorder_type=0 or reorder_type=5 { order_number=deck_card_all[i].card_id; }
		else if reorder_type=1 { order_number=deck_card_all[i].card_level; }
		else if reorder_type=2 { order_number=deck_card_all[i].card_full_atk; }
		else if reorder_type=3 { order_number=deck_card_all[i].card_full_def; }
		else if reorder_type=4 { order_number=deck_card_all[i].card_full_hp; }
		//
		order_number+=(deck_card_all[i].card_serial/(ob_main.serial_count+1)); //never adds +1, always only decimal
		ds_grid_set(order_grid,1,i,order_number);
	}
	//
	if reorder_type=0 or reorder_type=5 { ds_grid_sort(order_grid,1,true); }
	else { ds_grid_sort(order_grid,1,false); }
	//
	for (var i=0; i<deck_build_all_total; i++;) {
		deck_card_all[i]=ds_grid_get(order_grid,0,i);
	}
	//
	ds_grid_destroy(order_grid);
	//————————————————————————————————————————————————————————————————————————————————————————————————————
	if reorder_type=5 {
		for (var i=0; i<ob_main.serial_count; i++;) {
			for (var ii=1; ii<=deck_setup_max; ii++;) { //clear all decks
				ob_main.serial_card_indeck[i][ii]=false;
			}
		}
		//
		for (var i=0; i<deck_build_all_total; i++;) {
			for (var ii=1; ii<=deck_setup_max; ii++;) { //re-save decks
				ob_main.serial_card_indeck[deck_card_all[i].card_serial][ii]=deck_card_all[i].card_indeck[ii];
			}
		}
	}
	//
	reorder_type=-1;
}
//
if reorder_swap_standby!=0 {
	reorder_selected=reorder_swap_standby;
	reorder_type=reorder_selected;
	reorder_swap_standby=0;
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
//LOAD DECKS
if deck_setup_load>-1 {
	var i=0;
	repeat (deck_build_all_total) {
		deck_card_all[i].card_indeck[0]=ob_main.serial_card_indeck[deck_card_all[i].card_serial][deck_setup_load];
		i++;
	}
	//
	var i=0;
	repeat (4) {
		deck_berry_used[i]=ob_main.berry_num_used[i][deck_setup_load];
		i++;
	}
	//
	deck_setup_load=-1;
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
deck_build_stored_total=0;
deck_build_used_total=0;
//
var i=0, ii=0, iii=0;
repeat (deck_build_all_total) {
	if deck_card_all[i].card_indeck[0]=false {
		deck_card_stored[ii]=deck_card_all[i];
		deck_build_stored_total++;
		ii++;
	}
	else {
		deck_card_used[iii]=deck_card_all[i];
		deck_build_used_total++;
		iii++;
	}
	i++;
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
//SAVE DECKS
ob_main.maindeck_total=deck_build_all_total;
ob_main.maindeck_used_total=deck_build_used_total;
//
var i=0;
repeat (deck_build_all_total) {
	ob_main.main_card_id[i]=deck_card_all[i].card_id;
	ob_main.main_card_nickname[i]=deck_card_all[i].card_nickname;
	ob_main.main_card_level[i]=deck_card_all[i].card_level;
	ob_main.main_card_glyph_a[i]=deck_card_all[i].card_glyph_a;
	ob_main.main_card_glyph_b[i]=deck_card_all[i].card_glyph_b;
	ob_main.main_card_glyph_c[i]=deck_card_all[i].card_glyph_c;
	ob_main.main_card_innate[i]=deck_card_all[i].card_innate;
	ob_main.main_card_form_value[i]=deck_card_all[i].card_form_value;
	ob_main.main_card_shiny[i]=deck_card_all[i].card_shiny;
	ob_main.main_card_serial[i]=deck_card_all[i].card_serial;
	//
	ob_main.serial_card_indeck[ob_main.main_card_serial[i]][0]=deck_card_all[i].card_indeck[0];
	if deck_setup_save>-1 {
		deck_card_all[i].card_indeck[deck_setup_save]=deck_card_all[i].card_indeck[0];
		ob_main.serial_card_indeck[ob_main.main_card_serial[i]][deck_setup_save]=deck_card_all[i].card_indeck[deck_setup_save];
	}
	//
	i++;
}
//
ob_main.berrydeck_total=card_berrydeck_total;
var i=0;
repeat (4) {
	ob_main.berry_num_used[i][0]=deck_berry_used[i];
	if deck_setup_save>-1 {
		ob_main.berry_num_used[i][deck_setup_save]=deck_berry_used[i];
	}
	//
	i++;
}
//
deck_setup_save=-1;
//————————————————————————————————————————————————————————————————————————————————————————————————————
var i=0;
repeat (deck_build_stored_total) {
	deck_card_stored[i].potential_x=screen_deck_x+stored_x+(60*i);
	deck_card_stored[i].potential_y=screen_main_y+stored_y;
	i++;
}
//
var i=0;
repeat (deck_build_used_total) {
	deck_card_used[i].potential_x=screen_deck_x+used_x+(60*i);
	deck_card_used[i].potential_y=screen_main_y+used_y;
	i++;
}
//
var i=0;
repeat (4) {
	if deck_berry_total[i]>0 {
		deck_card_berry[i].potential_x=screen_deck_x+(69*i)+124;
		deck_card_berry[i].potential_y=screen_main_y+104;
	}
	i++;
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
// NEEDED BERRY COUNT
for (var i=0; i<=3; i++;) {
	berries_needed_deck[i]=0;
}
//
for (var i=0; i<deck_build_used_total; i++;) {
	for (var ii=0; ii<=3; ii++;) {
		berries_needed_deck[ii]+=deck_card_used[i].card_cost_total_type[ii];
	}
}
//————————————————————————————————————————————————————————————————————————————————————————————————————
// MULTICOLOR REWARD BONUS CALCULATION
var mc_need_a=berries_needed_deck[0], mc_need_b=berries_needed_deck[1], mc_need_c=berries_needed_deck[2];
//
var mc_need_higher=mc_need_a; //get higher
if mc_need_b>mc_need_higher { mc_need_higher=mc_need_b; }
if mc_need_c>mc_need_higher { mc_need_higher=mc_need_c; }
//
var mc_summed_rest=(mc_need_higher-mc_need_a)+(mc_need_higher-mc_need_b)+(mc_need_higher-mc_need_c); //summed rests
var mc_rest_perc=(mc_summed_rest*100)/(mc_need_a+mc_need_b+mc_need_c); //get percentage of rest from total needed, max 200%
//
var mc_total=ceil((200-mc_rest_perc)/2.5)+20; //200-percentage, divided by 2.5 (max total 80%), +20
if mc_need_a=0 { mc_total-=10; }
if mc_need_b=0 { mc_total-=10; }
if mc_need_c=0 { mc_total-=10; }
if mc_total<0 { mc_total=0; }
//
ob_main.multiberry_bonus=(mc_total/100)+1;
//————————————————————————————————————————————————————————————————————————————————————————————————————
// SCROLL BARS (ob_event & ob_deckbuild)
if mouse_y>=screen_main_y+stored_y and mouse_y<screen_main_y+stored_y+80+8 and ob_main.cursor_hide=false {
	if mouse_wheel_up() {
		stored_x+=32;
		if stored_x>4 { stored_x=4; }
	}
	else if mouse_wheel_down() and cam_w<(deck_build_stored_total*60) {
		stored_x-=32;
		if stored_x<cam_w-(deck_build_stored_total*60)-1 { stored_x=cam_w-(deck_build_stored_total*60)-1; }
	}
}
else if mouse_y>=screen_main_y+used_y-8 and mouse_y<screen_main_y+used_y+80 and ob_main.cursor_hide=false {
	if mouse_wheel_up() {
		used_x+=32;
		if used_x>4 { used_x=4; }
	}
	else if mouse_wheel_down() and cam_w<(deck_build_used_total*60) {
		used_x-=32;
		if used_x<cam_w-(deck_build_used_total*60)-1 { used_x=cam_w-(deck_build_used_total*60)-1; }
	}
}
//
if mouse_check_button(mb_left) and ob_main.cursor_hide=false and cam_w<(deck_build_stored_total*60) and hold_used_bar=false and
((mouse_y>=screen_main_y+stored_y+82 and mouse_y<screen_main_y+stored_y+86) or hold_stored_bar=true) {
	var mouse_pos=mouse_x-screen_deck_x-8-4, mouse_pos_max=cam_w-16-10, stored_pos_max=cam_w-(deck_build_stored_total*60)-5;
	var stored_x_percent=mouse_pos*100/mouse_pos_max;
	stored_x=round(stored_x_percent*stored_pos_max/100)+4;
	if stored_x>4 { stored_x=4; }
	else if stored_x<cam_w-(deck_build_stored_total*60)-1 { stored_x=cam_w-(deck_build_stored_total*60)-1; }
	hold_stored_bar=true;
}
else if mouse_check_button(mb_left) and ob_main.cursor_hide=false and cam_w<(deck_build_used_total*60) and hold_stored_bar=false and
((mouse_y>=screen_main_y+used_y-8 and mouse_y<screen_main_y+used_y-4) or hold_used_bar=true) {
	var mouse_pos=mouse_x-screen_deck_x-8-4, mouse_pos_max=cam_w-16-10, used_pos_max=cam_w-(deck_build_used_total*60)-5;
	var used_x_percent=mouse_pos*100/mouse_pos_max;
	used_x=round(used_x_percent*used_pos_max/100)+4;
	if used_x>4 { used_x=4; }
	else if used_x<cam_w-(deck_build_used_total*60)-1 { used_x=cam_w-(deck_build_used_total*60)-1; }
	hold_used_bar=true;
}
else if !mouse_check_button(mb_left) or ob_main.cursor_hide=true {
	hold_stored_bar=false;
	hold_used_bar=false;
}
//
if cam_w<(deck_build_stored_total*60) { //when moving last cards in list
	if stored_x<cam_w-(deck_build_stored_total*60)-1 { stored_x=cam_w-(deck_build_stored_total*60)-1; }
}
else { stored_x=4; }
if cam_w<(deck_build_used_total*60) { //when moving last cards in list
	if used_x<cam_w-(deck_build_used_total*60)-1 { used_x=cam_w-(deck_build_used_total*60)-1; }
}
else { used_x=4; }