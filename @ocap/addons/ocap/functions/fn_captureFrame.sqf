/*
	Author: MisterGoodson

	Description:
	Captures unit/vehicle data (including dynamically spawned AI/JIP players) during a mission for playback.
	Compatible with dynamically spawned AI and JIP players.

	Structure of entitiesData:
	[
		// Unit 1 (OCAP id 0)
		[
			[startFrameNo, "unit", id, name, group, side, isPlayer] // Doesn't change
			[[pos, dir, alive, isInVehicle], [pos, dir, alive, isInVehicle], ...]
			[[frameNum, projectileLandingPos], [frameNum, projectileLandingPos] ...] // Frame number fired, landing pos of projectile
		]

		// Unit 2 (OCAP id 1)
		[
			[startFrameNo, "unit", id, name, group, side, isPlayer] // Doesn't change
			[[pos, dir, alive, isInVehicle], [pos, dir, alive, isInVehicle], ...]
			[[frameNum, projectileLandingPos], [frameNum, projectileLandingPos] ...] // Frame number fired, landing pos of projectile
		]

		// Vehicle 1 (OCAP id 2)
		[
			[startFrameNo, "vehicle", id, classname] // Doesn't change
			[[pos, dir, alive, crew], [pos, dir, alive, crew], ...] // position, direction, alive, crew IDs
		]

		etc...
	]
*/
#include "\x\ocap\addons\main\script_component.hpp"

if (!ocap_main_capture) exitWith {};

_sT = diag_tickTime;
{
	if (!(_x getVariable ["ocap_main_exclude", false])) then {
		if (_x isKindOf "Logic") exitWith {
			_x setVariable ["ocap_main_exclude", true];
		};

		_pos = getPosATL _x;
		_pos = [_pos select 0, _pos select 1];
		_dir = getDir _x;
		_alive = alive _x;
		_isUnit = _x isKindOf "CAManBase";

		if (!(_x getVariable ["ocap_main_isInitialised", false])) then { // Setup entity if not initialised
			if (_alive) then { // Only init alive entities
				_x setVariable ["ocap_main_exclude", false];
				_x setVariable ["ocap_main_id", ocap_main_id];

				if (_isUnit) then {
						ocap_main_entitiesData pushBack [
							[ocap_main_FrameNo, "unit", ocap_main_id, name _x, groupID (group _x), str(side _x), isPlayer _x], // Properties
							[[_pos, _dir, _alive, (vehicle _x) != _x]], // Positions
							[] // Frames fired
						];
				} else { // Else vehicle
					_vehType = typeOf _x;
					ocap_main_entitiesData pushBack [
						[ocap_main_FrameNo, "vehicle", ocap_main_id, _vehType, getText (configFile >> "CfgVehicles" >> _vehType >> "displayName")], // Properties
						[[_pos, _dir,_alive, []]] // Positions
					];
				};

				_x call ocap_fnc_addEventHandlers;
				ocap_main_id = ocap_main_id + 1;

				_x setVariable ["ocap_main_isInitialised", true];
				if (ocap_main_debug) then {systemChat format["Initialised %1.", str(_x)]};
			};
		} else { // Update position data for this entity
			if (_isUnit) then {
				// Get entity data from entitiesData array, select positions entry, push new data to it
				((ocap_main_entitiesData select (_x getVariable "ocap_main_id")) select 1) pushBack [_pos, _dir, _alive, (vehicle _x) != _x];
			} else {
				// Get ID for each crew member
				_crew = [];
				{
					if (_x getVariable [ocap_main_isInitialised, false]) then {
						_crew pushBack (_x getVariable ocap_main_id);
					};
				} forEach (crew _x);

				// Get entity data from entitiesData array, select positions entry, push new data to it
				((ocap_main_entitiesData select (_x getVariable "ocap_main_id")) select 1) pushBack [_pos, _dir, _alive, _crew];
			};
		};
	};
} forEach (allUnits + allDead + (entities "LandVehicle") + (entities "Ship") + (entities "Air"));


_string = format["Captured frame %1 (%2ms).", ocap_main_FrameNo, (diag_tickTime - _sT)*1000];
if (ocap_main_debug) then {
	systemChat _string;
};

// Write to log file every 10 frames
if ((ocap_main_FrameNo % 10) == 0) then {
	[_string, false] call ocap_fnc_log;
};

ocap_main_FrameNo = ocap_main_FrameNo + 1;

// If option enabled, end capture if all players have disconnected
if (ocap_endCaptureOnNoPlayers && {count(allPlayers) == 0}) exitWith {
	["Players no longer present, ending capture."] call ocap_fnc_log;
	[] call ocap_fnc_exportData;
};
