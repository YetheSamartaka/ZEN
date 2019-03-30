/*
 * Author: mharis001
 * Initiates the process of remote controlling the given unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call zen_remote_control_fnc_start
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

_unit setVariable [VAR_OWNER, player, true];
missionNamespace setVariable [VAR_UNIT, _unit];

(findDisplay IDD_RSCDISPLAYCURATOR) closeDisplay 2;

[{
    params ["_unit"];

    private _vehicle = vehicle _unit;
    private _vehicleRole = assignedVehicleRole _unit;

    player remoteControl _unit;

    if (cameraOn != _vehicle) then {
        _vehicle switchCamera cameraView;
    };

    private _handle = player addEventHandler ["HandleRating", {0}];
    player setVariable [QGVAR(handle), _handle];

    [{
        [{
            params ["_unit", "_vehicle", "_vehicleRole"];

            if (alive _unit && {vehicle _unit != _vehicle || {!(assignedVehicleRole _unit isEqualTo _vehicleRole)}}) then {
                player remoteControl _unit;
                _this set [1, vehicle _unit];
                _this set [2, assignedVehicleRole _unit];
            };

            !alive _unit
            || {!alive player}
            || {!isNull curatorCamera}
            || {cameraOn == vehicle player}
            || {isNull getAssignedCuratorLogic player}
        }, {
            params ["_unit"];

            objNull remoteControl _unit;
            player switchCamera cameraView;

            _unit setVariable [VAR_OWNER, nil, true];
            missionNamespace setVariable [VAR_UNIT, nil];

            private _handle = player getVariable [QGVAR(handle), -1];
            player removeEventHandler ["HandleRating", _handle];

            {openCuratorInterface} call CBA_fnc_execNextFrame;
        }, _this] call CBA_fnc_waitUntilAndExecute;
    }, [_unit, _vehicle, _vehicleRole]] call CBA_fnc_execNextFrame;
}, _unit] call CBA_fnc_execNextFrame;
