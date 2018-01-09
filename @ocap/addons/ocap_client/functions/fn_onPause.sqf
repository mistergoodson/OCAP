/*
    Author: BaerMitUmlaut

    Description:
    Adds the save button to the escape menu for admins in multiplayer.

    Parameters:
    _this select 0: DISPLAY - Escape menu display.
*/
params ["_display"];

// Filter non admins, allow SP for debug mode
if !(serverCommandAvailable "#logout" || {!isMultiplayer}) exitWith {};

private _debugConsole = _display displayCtrl 13184;

// First, hide the useless GUI editor button
private _buttonGUIEditor = _debugConsole controlsGroupCtrl 13292;
_buttonGUIEditor ctrlShow false;
_buttonGUIEditor ctrlEnable false;

// Next, create the OCAP export button where the GUI editor button was
private _buttonOCAPExport = _display ctrlCreate ["RscButtonMenu", -1, _debugConsole];
_buttonOCAPExport ctrlSetText "OCAP EXPORT";
_buttonOCAPExport ctrlSetPosition (ctrlPosition _buttonGUIEditor);
_buttonOCAPExport ctrlSetBackgroundColor [
    profilenamespace getvariable ["GUI_BCG_RGB_R", 0.77],
    profilenamespace getvariable ["GUI_BCG_RGB_G", 0.51],
    profilenamespace getvariable ["GUI_BCG_RGB_B", 0.08],
    profilenamespace getvariable ["GUI_BCG_RGB_A", 0.8]
];
_buttonOCAPExport ctrlCommit 0;

// And finally make it do stuff
_buttonOCAPExport ctrlAddEventHandler ["onButtonClick", {
    [] remoteExecCall ["ocap_fnc_exportData", 2];
}];
