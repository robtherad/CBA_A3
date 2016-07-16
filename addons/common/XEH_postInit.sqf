// #define DEBUG_MODE_FULL
#include "script_component.hpp"

//Install PFEH:
if (isNil {canSuspend}) then {
    // pre 1.58
    ["CBA_PFH", "onEachFrame", {
        call FUNC(onFrame);
        GVAR(lastFrameRender) = diag_frameNo;
    }] call BIS_fnc_addStackedEventHandler;

    FUNC(monitorFrameRender) = {
        if (abs (diag_frameno - GVAR(lastFrameRender)) > DELAY_MONITOR_THRESHOLD) then {
            // Restores the onEachFrame handler
            ["CBA_PFH", "onEachFrame", {
                call FUNC(onFrame);
                GVAR(lastFrameRender) = diag_frameNo;
            }] call BIS_fnc_addStackedEventHandler;
            TRACE_1("PFH restored",nil);
        };
    };

    // Use a trigger, runs every 0.5s, unscheduled execution
    GVAR(perFrameTrigger) = createTrigger ["EmptyDetector", [0,0,0], false];
    GVAR(perFrameTrigger) setTriggerStatements ['FUNC(monitorFrameRender) call CBA_fnc_directCall', "", ""];
} else {
    // 1.58 and later
    addMissionEventHandler ["EachFrame", FUNC(onFrame)];
};

LOG(MSG_INIT);

// NOTE: Due to the way the BIS functions initializations work, and the requirement of BIS_functions_mainscope to be a unit (in a group)
//       the logic is created locally on MP dedicated client, to still allow this early, called precompilation of the functions.
//       But initialization doesn't officially finish until the official (server created / mission.sqm included) logic is available.
//         In SP or as server (dedicated or clientServer), the logic is created with group and createUnit.
0 spawn {
    waitUntil {!isNil "bis_functions_mainscope"};
    waitUntil {!isNull bis_functions_mainscope};
    CBA_logic = bis_functions_mainscope;
    #ifdef DEBUG_MODE_FULL
        diag_log [diag_frameNo, diag_tickTime, time, "BLA: Function module init true!"];
    #endif
};

// Upgrade check - Registry for removed addons, warn the user if found
// TODO: Evaluate registry of 'current addons' and verifying that against available CfgPatches
TRACE_1("Upgrade Check",nil);
#define CFG configFile >> "CfgSettings" >> "CBA" >> "registry"
private ["_entry"];
for "_i" from 0 to ((count (CFG)) - 1) do {
    _entry = (CFG) select _i;
    if (isClass(_entry) && {isArray(_entry >> "removed")}) then {
        {
            if (isClass(configFile >> "CfgPatches" >> _x)) then {
                format["WARNING: Found addon that should be removed: %1; Please remove and restart game", _x] call FUNC(log);
            };
        } forEach (getArray(_entry >> "removed"));
    };
};

// system to synch team colors
PREP(onTeamColorChanged);
PREP(synchTeamColors);

["CBA_teamColorChanged", FUNC(onTeamColorChanged)] call CBA_fnc_addEventHandler;

if (hasInterface) then {
    [FUNC(synchTeamColors), 1, []] call CBA_fnc_addPerFrameHandler;

    if (didJIP) then {
        {
            private _team = _x getVariable [QGVAR(synchedTeam), ""];
            if (_team != "") then {
                _x assignTeam _team;
            };
            true
        } count allUnits;
    };
};

//Event for switching vehicle var names from CBA_fnc_switchPlayer
["CBA_setVehicleVarName", {
    params ["_oldVeh", "_newVeh", "_vehName"];
    _oldVeh setVehicleVarName "";
    _newVeh setVehicleVarName _vehName;
}] call CBA_fnc_addEventHandler;
