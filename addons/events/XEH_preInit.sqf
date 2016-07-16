#include "script_component.hpp"

ADDON = false;

// Initialisation required by CBA events.
GVAR(eventNamespace) = call CBA_fnc_createNamespace;
GVAR(eventHashes) = call CBA_fnc_createNamespace;

if (isServer) then {
    GVAR(eventNamespaceJIP) = (sideLogic call CBA_fnc_getSharedGroup) createUnit ["Logic", [0,0,0], [], 0, "NONE"]; // createVehicle fails on game logics. Have to use createUnit instead.
    publicVariable QGVAR(eventNamespaceJIP);
};

// can't add at preInit
0 spawn {
    EVENT_PVAR_STR addPublicVariableEventHandler {(_this select 1) call CBA_fnc_localEvent};

    if (isServer) then {
        TEVENT_PVAR_STR addPublicVariableEventHandler {(_this select 1) call CBA_fnc_targetEvent};
    };
};

#include "backwards_comp.sqf"

ADDON = true;

if (!hasInterface) exitWith {};

// Display Event Handlers
// Pressing "Restart" in the editor starts a completely new mission (preInit etc. are executed). The main display is never deleted though!
// This would cause douplicate display events to be added, because the old ones carry over while the new ones are added again.
// If we detect an already existing main display we remove all display events that were previously defined.
if (!isNull (uiNamespace getVariable ["CBA_missionDisplay", displayNull])) then {
    GVAR(handlerHash) = (uiNamespace getVariable "CBA_missionDisplay") getVariable QGVAR(handlerHash);
    [GVAR(handlerHash), {
        {
            (uiNamespace getVariable "CBA_missionDisplay") displayRemoveEventHandler [_key, _x param [0, -1]];
        } forEach _value;
    }] call CBA_fnc_hashEachPair;

    // to carry the hash over into a restarted game, we store the hashes array reference in the mission display namespace.
    GVAR(handlerHash) = [[], []] call CBA_fnc_hashCreate;
    (uiNamespace getVariable "CBA_missionDisplay") setVariable [QGVAR(handlerHash), GVAR(handlerHash)];
} else {
    GVAR(handlerHash) = [[], []] call CBA_fnc_hashCreate;
};

PREP(keyHandler);
#ifndef LINUX_BUILD
    PREP(keyHandlerDown);
#else
    PREP(keyHandlerDown_Linux);
    FUNC(keyHandlerDown) = FUNC(keyHandlerDown_Linux);
#endif
PREP(keyHandlerUp);

["keyDown", FUNC(keyHandlerDown)] call CBA_fnc_addDisplayHandler;
["keyUp", FUNC(keyHandlerUp)] call CBA_fnc_addDisplayHandler;

private _keyHandlers = [];
_keyHandlers resize 250;

#ifndef LINUX_BUILD
    GVAR(keyDownStates) = _keyHandlers apply {[]};
#else
    GVAR(keyDownStates) = [_keyHandlers, {[]}] call CBA_fnc_filter;
#endif
GVAR(keyUpStates) = + GVAR(keyDownStates);

GVAR(keyHandlersDown) = call CBA_fnc_createNamespace;
GVAR(keyHandlersUp) = call CBA_fnc_createNamespace;

GVAR(keyDownActiveList) = [];
GVAR(keyUpActiveList) = [];

GVAR(keyHoldTimers) = call CBA_fnc_createNamespace;

FUNC(handleKeyDownUp) = {
    private _xUp = _this select (count _this - 1);

    GVAR(keyUpActiveList) deleteAt (GVAR(keyUpActiveList) find _xUp);
    GVAR(keyHoldTimers) setVariable [_xUp, nil];

    false
};
