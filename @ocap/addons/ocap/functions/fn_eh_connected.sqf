/*
	Author: MisterGoodson

	Description:
	Adds new "connected" event, marking the current frame number and name of
	connecting entity.

	Parameters:
	_this: OBJECT - Entity that connected.
*/
#include "\x\ocap\addons\main\script_component.hpp"

_name = _this;
ocap_main_eventsData pushBack [
	ocap_main_FrameNo,
	"connected",
	_name
];
