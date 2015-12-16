/* ----------------------------------------------------------------------------
Function: CBA_xeh_fnc_dumpXehCounters

Description:
    Dumps the XEH performance counters.

Parameters:
    _showEachIndex - [Bool, defaults to true]
    _showCode - [Bool, defaults to true]
    _filterClass - [String, defaults to ""]

Returns:
    None (debug written to RPT)

Examples:
(begin code)
    [] call CBA_xeh_fnc_dumpXehCounters;
    [true, true, (typeOf player)] call CBA_xeh_fnc_dumpXehCounters;
(end code)

Author:
    PabstMirror (based on ACE's Performance Counters)
---------------------------------------------------------------------------- */

#include "script_component.hpp"

params [["_showEachIndex", true, [false]], ["_showCode", true, [false]], ["_filterClass", "", [""]]];

diag_log text format ["CBA COUNTER RESULTS"];
diag_log text format ["-------------------------------------------"];

if (isNil "CBA_COUNTERS") exitWith {
    diag_log text format ["Counters not enabled (nil CBA_COUNTERS)"];
};

{
    _x params ["_typeName", "_eventName", "_xehIndexs"];

    if ((_filterClass == "") || {_typeName == _filterClass}) then {
        {
            if (_x isEqualTo []) exitWith {
                diag_log text format ["%1: No results", _name];
            };

            private _total = 0;
            private _count = 0;
            {
                _total = _total + _x;
                _count = _count + 1;
            } forEach _x;

            private _averageResult = (_total / _count) * 1000;

            if (_forEachIndex == 0) then {
                diag_log text format ["%1: Overall Average: %2s / %3 = %4ms", [_typeName, _eventName], _total, _count, _averageResult];
            } else {
                private _code = "";
                if (_showCode) then {
                    _near = player nearEntities [(typeOf player), 10000000];
                    if (_near isEqualTo []) exitWith {};
                    _code = format [" - CODE: %1", (((_near select 0) getVariable _eventName) select (_forEachIndex - 1))];
                };
                if (_showEachIndex) then {
                    diag_log text format [" - (#%1): %2ms %3", (_forEachIndex - 1), _averageResult, _code];
                };
            };
        } forEach _xehIndexs;
    };

    false
} count CBA_COUNTERS;

diag_log text format ["-------------------------------------------"];
