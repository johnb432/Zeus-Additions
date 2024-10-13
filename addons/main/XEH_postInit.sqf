#include "script_component.hpp"

// Macros don't like commas in strings
INFO_2("PostInit: didJIP: %1 - Functions sent: %2",didJIP,!isNil QGVAR(functionsSent));

// Execute init for everyone and JIP
if (isNil QGVAR(functionsSent)) then {
    ["zen_common_execute", [FUNC(init), []], QGVAR(initJipID)] call CBA_fnc_globalEventJIP;
};

if (!hasInterface) exitWith {};

// Add mission counter only if player is curator; However, check every time the zeus interface is opened
["zen_curatorDisplayLoaded", {
    // Wait until CBA settings have been initialised
    [FUNC(objectsCounterMissionEH), []] call zen_common_fnc_runAfterSettingsInit;
}] call CBA_fnc_addEventHandler;

// Add drag bodies and JIP functions only if player is curator
["zen_curatorDisplayLoaded", {
    [_thisType, _thisId] call CBA_fnc_removeEventHandler;

    // Add the building destruction functionality; If CBA settings haven't been initialised yet, just let CBA settings handle reason changing
    if (GETMVAR("CBA_settings_ready",false)) then {
        [QGVAR(buildingDestruction), getPlayerUID player, GVAR(enableBuildingDestructionHandling), QFUNC(handleBuildingDestruction)] call FUNC(changeReason);
    };

    // Add Drag Bodies module
    if (!isNil "ace_dragging" && {getNumber (_cfgPatches >> "ace_main" >> "version") < 3.18}) then {
        #include "modules\module_dragBodies.inc.sqf"
    };
}] call CBA_fnc_addEventHandlerArgs;

// Add functionality
#include "modules\functionality_dragBodies.inc.sqf"

// Add modules
#include "modules\module_behaviourCrew.inc.sqf"
#include "modules\module_captive.inc.sqf"
#include "modules\module_carBomb.inc.sqf"
#include "modules\module_channelVisibility.inc.sqf"
#include "modules\module_configureDoors.inc.sqf"
#include "modules\module_createResupply.inc.sqf"
#include "modules\module_deleteObjectForced.inc.sqf"
#include "modules\module_deleteZeus.inc.sqf"
#include "modules\module_dogAttack.inc.sqf"
#include "modules\module_dustStorm.inc.sqf"
#include "modules\module_garrisonBuilding.inc.sqf"
#include "modules\module_gearScript.inc.sqf"
#include "modules\module_grassRender.inc.sqf"
#include "modules\module_mapMarkers.inc.sqf"
#include "modules\module_missionEndModifier.inc.sqf"
#include "modules\module_missionObjectCounter.inc.sqf"
#include "modules\module_pauseTime.inc.sqf"
#include "modules\module_removeGrenades.inc.sqf"
#include "modules\module_suicideBomber.inc.sqf"
#include "modules\module_switchUnit.inc.sqf"
#include "modules\module_toggleConsciousnessForced.inc.sqf"
#include "modules\module_trackUnitDeath.inc.sqf"
#include "modules\module_unitParadrop.inc.sqf"
#include "modules\module_unitParadropAction.inc.sqf"
#include "modules\module_vehicleExplosionPrevention.inc.sqf"

// Optionals
private _cfgPatches = configFile >> "CfgPatches";
GVAR(ACEClipboardLoaded) = if (getNumber (_cfgPatches >> "ace_main" >> "version") >= 3.18) then {
    [0, 2] select (("ace" callExtension ["version", []]) params [["_versionEx", "", [""]], ["_returnCode", -1, [-1]]])
} else {
    parseNumber (isClass (configFile >> "ACE_Extensions" >> "ace_clipboard"))
};

// Check if ACE Dragging is loaded
if (!isNil "ace_dragging") then {
    #include "modules\module_dragAndCarry.inc.sqf"
};

// Check if ACE Medical components are loaded
if (!isNil "ace_medical_damage") then {
    #include "modules\module_createInjuries.inc.sqf"
};

if (zen_common_aceMedicalTreatment) then {
    #include "modules\module_createResupplyMedical.inc.sqf"
};

// Check if TFAR is loaded
if (isClass (_cfgPatches >> "tfar_core") || {isClass (_cfgPatches >> "task_force_radio")}) then {
    #include "modules\module_tfarRadioRange.inc.sqf"
};

// Check if RHS AFRF is loaded
if (isClass (_cfgPatches >> "rhs_main_loadorder")) then {
    #include "modules\module_rhsAps.inc.sqf"
};
// Optionals finished

// Hint what is missing once CBA settings have been loaded
["CBA_settingsInitialized", {
    private _cfgPatches = configFile >> "CfgPatches";
    private _notificationArray = [];

    // Check if ACE Dragging is loaded
    if (isNil "ace_dragging") then {
        private _string = LLSTRING(aceDraggingMissing);
        INFO(_string);

        if (GVAR(enableACEDragHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if ACE Medical is loaded
    if !(GETMVAR("ace_medical_enabled",zen_common_aceMedical)) then {
        private _string = LLSTRING(aceMedicalMissing);
        INFO(_string);

        if (GVAR(enableACEMedicalHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if TFAR is loaded
    if (!isClass (_cfgPatches >> "tfar_core") && {!isClass (_cfgPatches >> "task_force_radio")}) then {
        private _string = LLSTRING(tfarMissing);
        INFO(_string);

        if (GVAR(enableTFARHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Check if RHS AFRF is loaded
    if (!isClass (_cfgPatches >> "rhs_main_loadorder")) then {
        private _string = LLSTRING(rhsMissing);
        INFO(_string);

        if (GVAR(enableRHSHint)) then {
            _notificationArray pushBack _string;
        };
    };

    // Hint what is missing if wanted
    if (_notificationArray isEqualTo []) exitWith {};

    _notificationArray insert [0, ["[Zeus Additions]:"]];

    {
        systemChat _x;
    } forEach _notificationArray;
}] call CBA_fnc_addEventHandler;
