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
    if (!isNil "ace_dragging") then {
        #include "modules\module_dragBodies.sqf"
    };
}] call CBA_fnc_addEventHandlerArgs;

// Add functionality
#include "modules\functionality_dragBodies.sqf"

// Add modules
#include "modules\module_behaviourCrew.sqf"
#include "modules\module_captive.sqf"
#include "modules\module_carBomb.sqf"
#include "modules\module_channelVisibility.sqf"
#include "modules\module_configureDoors.sqf"
#include "modules\module_createResupply.sqf"
#include "modules\module_deleteObjectForced.sqf"
#include "modules\module_deleteZeus.sqf"
#include "modules\module_dogAttack.sqf"
#include "modules\module_dustStorm.sqf"
#include "modules\module_garrisonBuilding.sqf"
#include "modules\module_gearScript.sqf"
#include "modules\module_grassRender.sqf"
#include "modules\module_mapMarkers.sqf"
#include "modules\module_missionEndModifier.sqf"
#include "modules\module_missionObjectCounter.sqf"
#include "modules\module_pauseTime.sqf"
#include "modules\module_removeGrenades.sqf"
#include "modules\module_suicideBomber.sqf"
#include "modules\module_switchUnit.sqf"
#include "modules\module_toggleConsciousnessForced.sqf"
#include "modules\module_trackUnitDeath.sqf"
#include "modules\module_unitParadrop.sqf"
#include "modules\module_unitParadropAction.sqf"
#include "modules\module_vehicleExplosionPrevention.sqf"

// Optionals
private _cfgPatches = configFile >> "CfgPatches";
GVAR(ACEClipboardLoaded) = isClass (configFile >> "ACE_Extensions" >> "ace_clipboard");

// Check if ACE Dragging is loaded
if (!isNil "ace_dragging") then {
    #include "modules\module_dragAndCarry.sqf"
};

// Check if ACE Medical components are loaded
if (!isNil "ace_medical_damage") then {
    #include "modules\module_createInjuries.sqf"
};

if (zen_common_aceMedicalTreatment) then {
    #include "modules\module_createResupplyMedical.sqf"
};

// Check if TFAR is loaded
if (isClass (_cfgPatches >> "tfar_core") || {isClass (_cfgPatches >> "task_force_radio")}) then {
    #include "modules\module_tfarRadioRange.sqf"
};

// Check if RHS AFRF is loaded
if (isClass (_cfgPatches >> "rhs_main_loadorder")) then {
    #include "modules\module_rhsAps.sqf"
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
    if (!zen_common_aceMedical) then {
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
