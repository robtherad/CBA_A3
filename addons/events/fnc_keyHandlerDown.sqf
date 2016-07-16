/* ----------------------------------------------------------------------------
Internal Function: CBA_events_fnc_keyHandlerDown
Description:
    Executes the key's handler
Author:
    Sickboy, commy2
---------------------------------------------------------------------------- */
// #define DEBUG_MODE_FULL
#include "script_component.hpp"
SCRIPT(keyHandlerDown);

params ["", "_inputKey"];

if (_inputKey == 0) exitWith {};

private _inputSettings = _this select [2,3];

private _blockInput = false;

{
    private _keybindParams = GVAR(keyHandlersDown) getVariable _x;

    _keybindParams params ["", "_keybindSettings", "_code", "_allowHold", "_holdDelay"];

    // Verify if the required modifier keys are present
    if (_keybindSettings isEqualTo _inputSettings) then {
        private _xUp = _x + "_cbadefaultuphandler";
        private _execute = true;
        private _holdTime = 0;

        if (_holdDelay > 0) then {
            _holdTime = GVAR(keyHoldTimers) getVariable _xUp;

            if (isNil "_holdTime") then {
                _holdTime = diag_tickTime + _holdDelay;
                GVAR(keyHoldTimers) setVariable [_xUp, _holdTime];
            };

            if (diag_tickTime < _holdTime) then {
                _execute = false;
            };
        };

        // check if either holding down a key is enabled or if the key wasn't already held down
        #ifndef LINUX_BUILD
            if (_execute && {_allowHold || {GVAR(keyUpActiveList) pushBackUnique _xUp != -1}}) then {
        #else
            if (_execute && {_allowHold || {!(_xUp in GVAR(keyUpActiveList))}}) then {
                GVAR(keyUpActiveList) pushBack _xUp;
        #endif
            private _params = + _this;
            _params pushBack + _keybindParams;
            _params pushBack _x;

            _blockInput = _params call _code;

            #ifdef DEBUG_MODE_FULL
                if ((isNil "_blockInput") || {!(_blockInput isEqualType false)}) then {
                    LOG(PFORMAT_2("Keybind Handler returned nil or non-bool", _x, _blockInput));
                };
            #endif
        };

        if (_blockInput isEqualTo true) exitWith {};
    };
} forEach (GVAR(keyDownStates) param [_inputKey, []]);

// To have a valid key up we first need to have a valid key down of the same combo!
// If we do, we add it to a list of pressed key up combos, then on key up we check that list to see if we have a valid key up.
{
    private _keybindParams = GVAR(keyHandlersUp) getVariable _x;

    _keybindParams params ["", "_keybindSettings"];

    // Verify if the required modifier keys are present
    if (_keybindSettings isEqualTo _inputSettings) then {
        #ifndef LINUX_BUILD
            GVAR(keyDownActiveList) pushBackUnique _x;
        #else
            if !(_x in GVAR(keyDownActiveList)) then {
                GVAR(keyDownActiveList) pushBack _x;
            };
        #endif
    };
} forEach (GVAR(keyUpStates) param [_inputKey, []]);

//Only return true if _blockInput is defined and is type bool (handlers could return anything):
(!isNil "_blockInput") && {_blockInput isEqualTo true}
