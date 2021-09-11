#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows Zeus to remove grenades from AI.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_removeGrenades;
 *
 * Public: No
 */

 ["Zeus Additions - AI", "[WIP] Remove Grenades from AI", {
     params ["", "_unit"];

     ["[WIP] Remove Grenades from AI", [
         ["SIDES", ["AI selected", "Select AI from the list to remove grenades from."], []],
         ["TOOLBOX:YESNO", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false]
     ],
     {
         params ["_results", "_unit"];
         _results params ["_sides", "_doGroup"];

         if (_sides isEqualTo [] && {isNull _unit}) exitWith {
             ["Select a side!"] call zen_common_fnc_showMessage;
             playSound "FD_Start_F";
         };

         private _magazines = [];

         if (isNull _unit) then {
             {
                 {
                     _unit = _x;

                     if (!isPlayer _unit) then {
                         _magazines = magazines _unit;

                         {
                             if (_x call BIS_fnc_isThrowable) then {
                                 _unit removeMagazines _x;
                             };
                         } forEach (_magazines arrayIntersect _magazines);
                     };
                 } forEach (units _x);
             } forEach _sides;

             ["Removed grenades from units"] call zen_common_fnc_showMessage;
         } else {
             if (_doGroup) exitWith {
                 {
                     _unit = _x;
                     _magazines = magazines _unit;

                     if (!isPlayer _unit) then {
                         {
                             if (_x call BIS_fnc_isThrowable) then {
                                 _unit removeMagazines _x;
                             };
                         } forEach (_magazines arrayIntersect _magazines);
                     };
                 } forEach (units (group _unit));

                 ["Removed grenades from units in group"] call zen_common_fnc_showMessage;
             };

             if (!isPlayer _unit) then {
                 _magazines = magazines _unit;

                 {
                     if (_x call BIS_fnc_isThrowable) then {
                         _unit removeMagazines _x;
                     };
                 } forEach (_magazines arrayIntersect _magazines);

                 ["Removed grenades from unit"] call zen_common_fnc_showMessage;
             } else {
                 ["Select an AI unit!"] call zen_common_fnc_showMessage;
                 playSound "FD_Start_F";
             };
         };
     }, {
         ["Aborted"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
     }, _unit] call zen_dialog_fnc_create;
 }, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
