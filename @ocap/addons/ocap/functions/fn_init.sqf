/*
	Author: MisterGoodson

	Description:
	Initialises OCAP variables and mission-wide eventhandlers.
	Capture loop is automatically started once init complete.
*/
#include "\x\ocap\addons\main\script_component.hpp"
//if (!isServer) exitWith {};

// Define global vars
#include "\userconfig\ocap\config.hpp";
ocap_main_entitiesData = [];  // Data on all units + vehicles that appear throughout the mission.
ocap_main_eventsData = []; // Data on all events (involving 2+ units) that occur throughout the mission.
ocap_main_FrameNo = 0; // Frame number for current capture
ocap_main_endFrameNo = 0; // Frame number at end of mission
ocap_main_id = 0; // ID assigned to each entity (auto increments). Also acts as an index for each entity in entitiesData.

// Add mission EHs
addMissionEventHandler ["EntityKilled", {
    params ["_victim","_killer"];
	// Check entity is initiliased with OCAP
	// TODO: Set ocap_exclude to true if unit is not going to respawn (e.g. AI)
	if (_victim getVariable ["ocap_main_isInitialised", false]) then {
		[_victim, _killer] call ocap_fnc_eh_killed;
	};
}];

// Transfer ID from old unit to new unit
// Mark old body to now be excluded from capture
addMissionEventHandler ["EntityRespawned", {
    params ["_newEntity","_oldEntity"];
	if (_oldEntity getVariable ["ocap_main_isInitialised", false]) then {
		_newEntity setVariable ["ocap_main_isInitialised", true];
		_id = _oldEntity getVariable "ocap_main_id";
		_newEntity setVariable ["ocap_main_id", _id];
		_newEntity setVariable ["ocap_main_exclude", false];
		_oldEntity setVariable ["ocap_main_exclude", true]; // Exclude old body from capture

		_newEntity call ocap_fnc_addEventHandlers;
	};
}];

addMissionEventHandler["HandleDisconnect", {
	_unit = _this select 0;
	_name = _this select 3;
	if (_unit getVariable ["ocap_main_isInitialised", false]) then {
		_unit setVariable ["ocap_main_exclude", true];
	};

	_name call ocap_fnc_eh_disconnected;
}];

addMissionEventHandler["PlayerConnected", {
	_name = _this select 2;

	_name call ocap_fnc_eh_connected;
}];

/*addMissionEventHandler ["Ended", {
	// Output data to file
	[] call ocap_fnc_exportData;
}];*/


if (ocap_main_debug) then {
	player addAction ["Write saved data", {[] call ocap_fnc_exportData}];
	player addEventHandler ["Respawn", {
		player addAction ["Write saved data", {[] call ocap_fnc_exportData}];
	}];
};

[{[] call ocap_fnc_captureFrame}, ocap_main_frameCaptureDelay] call CBA_fnc_addPerFrameHandler;
[{[] call ocap_fnc_handleProjectiles}, ocap_main_frameCaptureDelay] call CBA_fnc_addPerFrameHandler;
