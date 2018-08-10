/*
	Author: MisterGoodson

	Description:
	Captures unit/vehicle data (including dynamically spawned AI/JIP players) during a mission for playback.
	Compatible with dynamically spawned AI and JIP players.
*/

if (!ocap_capture) exitWith {};

private _sT = diag_tickTime;
private _secondsPerFrame = 1 / diag_fps;
private _entities = allUnits + allDead + (entities "LandVehicle") + (entities "Ship") + (entities "Air");
{
	if (
		(!(_x isKindOf "Logic")) &&
		(!(_x getVariable ["ocap_exclude", false]))
	) then {
		_pos = getPosATL _x;
		_pos = [_pos select 0, _pos select 1];
		_dir = round(getDir _x);
		_isAlive = alive _x;
		_isUnit = _x isKindOf "CAManBase";

		private _isAliveInt = 0; if (_isAlive) then {_isAliveInt = 1};
		private _isUnitInt = 0; if (_isUnit) then {_isUnitInt = 1};

		if (!(_x getVariable ["ocap_isInitialised", false])) then { // Setup entity if not initialised
			if (_isAlive) then { // Only init alive entities
				_x setVariable ["ocap_exclude", false];
				_x setVariable ["ocap_id", ocap_entity_id];

				if (_isUnit) then {
					private _isInVehicleInt = 0; if ((vehicle _x) != _x) then {_isInVehicleInt = 1};
					private _isPlayerInt = 0; if (isPlayer _x) then {_isPlayerInt = 1};

					ocap_entitiesData pushBack [
						[ocap_captureFrameNo, _isUnitInt, ocap_entity_id, name _x, groupID (group _x), str(side _x), _isPlayerInt], // Header
						[[_pos, _dir, _isAliveInt, _isInVehicleInt]], // States
						[] // Frames fired
					];
				} else { // Else vehicle
					_vehType = typeOf _x;
					ocap_entitiesData pushBack [
						[ocap_captureFrameNo, _isUnitInt, ocap_entity_id, getText (configFile >> "CfgVehicles" >> _vehType >> "displayName"), _vehType], // Header
						[[_pos, _dir, _isAliveInt, []]] // States
					];
				};

				_x call ocap_fnc_addEventHandlers;
				ocap_entity_id = ocap_entity_id + 1;

				_x setVariable ["ocap_isInitialised", true];
			};
		} else { // Update states data for this entity
			if (_isUnit) then {
				private _isInVehicleInt = 0; if ((vehicle _x) != _x) then {_isInVehicleInt = 1};

				// Get entity data from entitiesData array, select states entry, push new data to it
				((ocap_entitiesData select (_x getVariable "ocap_id")) select 1) pushBack [_pos, _dir, _isAliveInt, _isInVehicleInt];
			} else {
				// Get ID for each crew member
				_crewIds = [];
				{
					if (_x getVariable ["ocap_isInitialised", false]) then {
						_crewIds pushBack (_x getVariable "ocap_id");
					};
				} forEach (crew _x);

				// Get entity data from entitiesData array, select states entry, push new data to it
				((ocap_entitiesData select (_x getVariable "ocap_id")) select 1) pushBack [_pos, _dir, _isAliveInt, _crewIds];
			};
		};
	};
} forEach _entities;

private _runTime = diag_tickTime - _sT;
private _frameCost = _runTime / _secondsPerFrame; // Number of equivalent (real) frames this took to run
private _string = format[
	"Captured frame %1 (%2 entities in %3ms / %4 frames).",
	ocap_captureFrameNo,
	count _entities,
	round (_runTime * 1000),
	_frameCost toFixed 1
];

// Log export time
if ((ocap_captureFrameNo % 10) == 0) then {
	// Log to rpt
	[_string] call ocap_fnc_log;
} else {
	// Log in-game
	[_string, false, true, false] call ocap_fnc_log;
};


// Export data if reached frame limit
if ((ocap_captureFrameNo % ocap_captureFrameLimit) == 0 &&
		{ocap_captureFrameNo > 0}) then {
	_sT = diag_tickTime;
	[] call ocap_fnc_exportData;

	private _runTime = diag_tickTime - _sT;
	private _frameCost = _runTime / _secondsPerFrame;
	[format[
		"Exported frame %1 (%2 entities in %3ms / %4 frames).",
		ocap_captureFrameNo,
		count _entities,
		round (_runTime * 1000),
		_frameCost toFixed 1
	], false, true] call ocap_fnc_log;
};

ocap_captureFrameNo = ocap_captureFrameNo + 1;
//sleep ocap_frameCaptureDelay;

// If option enabled, end capture if all players have disconnected
// if (ocap_endCaptureOnNoPlayers && {count(allPlayers) == 0}) exitWith {
// 	["Players no longer present, ending capture."] call ocap_fnc_log;
// 	[] call ocap_fnc_exportData;

// 	// Reset vars
// 	ocap_entitiesData = [];
// 	ocap_eventsData = [];
// 	ocap_captureFrameNo = 0;
// 	ocap_endFrameNo = 0;

// 	// Recommence capture (as new file) once minimum player count is met
// 	waitUntil{sleep 1; (count(allPlayers) >= ocap_minPlayerCount)};
// 	diag_log "OCAP: Min player count reached, restarting capture.";
// };