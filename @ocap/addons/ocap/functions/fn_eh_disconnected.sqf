
/*
	Author: MisterGoodson

	Description:
	Adds new "disconnected" event, marking the current frame number and name of
	connecting entity.

	Parameters:
	_this: OBJECT - Entity that disconnected.
*/
#include "\x\ocap\addons\main\script_component.hpp"

_name = _this;
ocap_main_eventsData pushBack [
	ocap_main_FrameNo,
	"disconnected",
	_name
];
