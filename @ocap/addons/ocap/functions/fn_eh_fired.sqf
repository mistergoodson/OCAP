/*
	Author: MisterGoodson

	Description:
	Called when a unit fires their weapon.
	Captures the landing position of the fired projectile and
	logs this event to the unit's 'framesFired' data.

	Information logged includes:
		- Current frame number
		- Landing position (x,y) of projectile

	This is used in playback to display when this unit fired, and what
	they fired at.

	Parameters:
	_this select 0: OBJECT - Unit that fired
	_this select 6: OBJECT - Projectile that was fired
*/
#include "\x\ocap\addons\main\script_component.hpp"
ocap_main_projectiles pushback [_this select 6,_this select 0,ocap_main_FrameNo,getPos (_this select 6)];
