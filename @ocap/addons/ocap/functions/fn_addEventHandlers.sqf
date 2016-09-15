/*
	Author: MisterGoodson

	Description:
	Adds fired/hit event handlers to given entity (unit/vehicle).

	Parameters:
	_this: OBJECT - Entity to add event handlers to.
*/

_entity = _this;
_firedEH = _entity addEventHandler ["Fired", {_this call ocap_fnc_eh_fired}];
_hitEH = _entity addEventHandler ["Hit", {_this call ocap_fnc_eh_hit}];
