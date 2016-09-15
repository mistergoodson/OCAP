#include "\x\ocap\addons\main\script_component.hpp"
private _dead = [];
{
    _x params ["_projectile","_unit","_frame","_lastPos"];
    if(!alive _projectile) then {
        _unitData = (ocap_main_entitiesData select (_unit getVariable "ocap_main_id"));
        (_unitData select 2) pushBack [_frame, [_lastPos select 0, _lastPos select 1]];
        _dead pushBack _forEachIndex;
    }
    else {
        _x set [3,getpos _projectile];
    };
} foreach ocap_main_projectiles;

{
    ocap_main_projectiles set [_x,0];
} foreach _dead;

ocap_main_projectiles = ocap_main_projectiles - 0;
