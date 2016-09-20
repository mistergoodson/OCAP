/*
	Author: MisterGoodson

	Description:
	Called when a unit is killed.
	Logs this event and adds it to ocap_eventsData array.
	Information logged includes:
		- Current frame number
		- Event type (in this case "killed")
		- Victim's OCAP ID
		- Killer's OCAP ID
		- Killer's weapon (if killer is a unit)
		- Distance between victim and killer

	Parameters:
	_this select 0: OBJECT - Victim
	_this select 1: OBJECT - Killer
*/

private _victim = _this select 0;
private _killer = _this select 1;

if (_victim getVariable ["ocap_exclude", false]) exitWith {}; // Just in case

private _victimId = _victim getVariable "ocap_id";

private _eventData = [ocap_captureFrameNo, "killed", _victimId, ["null"], -1];

// If killer is null, then unit likely killed by fire/collision/exploding vehicle/ACE3
private _aceLastSourceOfDamage = _victim getVariable ["ace_medical_lastDamageSource", objNull];
if (!isNull _aceLastSourceOfDamage) then {
	_killer = _aceLastSourceOfDamage;
};

if (!isNull _killer) then {
	private _killerInfo = [];
	if (_killer isKindOf "CAManBase") then {
		_killerInfo = [
			_killer getVariable "ocap_id",
			getText (configFile >> "CfgWeapons" >> currentWeapon _killer >> "displayName")
		];
	} else {
		_killerInfo = [_killer getVariable "ocap_id"];
	};

	_eventData = [
		ocap_captureFrameNo,
		"killed",
		_victimId,
		_killerInfo,
		_killer distance _victim
	];
};

// Add event to eventsData
ocap_eventsData pushBack _eventData;

if (ocap_debug) then {systemChat format["%1 was killed by %2", name _victim, name _killer]};
