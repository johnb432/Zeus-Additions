/*
 * Author: johnb43
 * Spawns a module that allows Zeus to remove grenades from AI.
 */

 ["Zeus Additions - AI", "Remove Grenades from AI", {
     params ["", "_unit"];

     ["Remove Grenades from AI", [
         ["SIDES", ["AI selected", "Select AI from the list to remove grenades from."], []],
         ["TOOLBOX:YESNO", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false]
     ],
     {
         params ["_results", "_unit"];
         _results params ["_sides", "_doGroup"];

         // If no units are selected at all
         if (isNull _unit && {_sides isEqualTo []}) exitWith {
             ["Select a side or place on unit!"] call zen_common_fnc_showMessage;
             playSound "FD_Start_F";
         };

         // If module was placed on a player
         if (!_doGroup && {isPlayer _unit}) exitWith {
             ["Select AI units!"] call zen_common_fnc_showMessage;
             playSound "FD_Start_F";
         };

         private _units = [];

         private _string = if (isNull _unit) then {
             {
                 _units append units _x;
             } forEach _sides;

             "Removed grenades from units";
         } else {
             if (_doGroup) exitWith {
                 _units = units _unit;

                 "Removed grenades from units in group";
             };

             _units pushBack _unit;

             "Removed grenades from unit";
         };

         _units = _units select {!isPlayer _x};

         if (_units isEqualTo []) exitWith {
             ["No AI units were found!"] call zen_common_fnc_showMessage;
         };

         private _magazines = [];

         // Remove grenades from all AI units
         {
             _unit = _x;
             _magazines = magazines _unit;

             {
                 if (_x call BIS_fnc_isThrowable) then {
                     _unit removeMagazines _x;
                 };
             } forEach (_magazines arrayIntersect _magazines);
         } forEach _units;

         [_string] call zen_common_fnc_showMessage;
     }, {
         ["Aborted"] call zen_common_fnc_showMessage;
         playSound "FD_Start_F";
     }, _unit] call zen_dialog_fnc_create;
 }, ICON_GRENADE] call zen_custom_modules_fnc_register;
