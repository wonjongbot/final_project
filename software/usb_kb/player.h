/*
 * player.h
 *
 *  Created on: Dec 6, 2022
 *      Author: wonjo
 */

#ifndef PLAYER_H_
#define PLAYER_H_

#define STATE_COUNTER 35
#define PLAYER_ANIM_COUNTER 45
#define UI_ANIM_COUNTER 70
#define PLAYER_MOTION_COUNTER 15
struct player
{
	int* x_loc;
	int* y_loc;
	int x_loc_prev;
	int y_loc_prev;
	int motion_x;
	int motion_y;
	uint8_t* dir;
	uint8_t dir_prev;
	int* anim_enum;
	int* missile_x;
	int* missile_y;
	int missile_motion_x;
	int missile_motion_y;
	int* collision;
	int collision_prev;
	int left;
	int left_prev;
	int right;
	int right_prev;
};

struct Game
{
	int* ui_anim_enum;
	int ui_anim_enum_prev;
	int* score_p1;
	int* score_p2;
	int* hit_p1;
	int hit_p1_prev;
	int* hit_p2;
	int hit_p2_prev;
	int curr_game_state;
};

struct counters
{
	int ui_anim_counter;	// previously countermarine
	int state_counter;
	int motion_counter;
	int sprite_anim_counter;
	int missile_motion_counter;
};


#endif /* PLAYER_H_ */
