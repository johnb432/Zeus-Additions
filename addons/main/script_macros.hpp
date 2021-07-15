#include "\x\cba\addons\main\script_macros_common.hpp"

//This part includes parts of the CBA and ACE3 macro libraries
#define GETPRVAR(var1,var2) (profileNamespace getVariable [ARR_2(var1,var2)])
#define SETPRVAR(var1,var2) (profileNamespace setVariable [ARR_2(var1,var2)])

#define GETMVAR(var1,var2) (missionNamespace getVariable [ARR_2(var1,var2)])
#define SETMVAR(var1,var2,var3) (missionNamespace setVariable [ARR_3(var1,var2,var3)])

#define ARR_10(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8,ARG9,ARG10) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8, ARG9, ARG10

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

#define IDC_CANCEL 2
#define IDD_MISSION 46
#define IDD_INTERRUPT 49
#define IDD_RSCDISPLAYCURATOR 312

#define RESUPPLY_TEXT "Spawns in x amount of predefined magazines (not x total!)."
#define RESUPPLY_DESC "Used for the 'Spawn Ammo Resupply Crate' module. Must be an array of strings."

#define MAGAZINES_DESC "Magazines"

#define PARADROP_UNITS 0
#define PARADROP_VEHICLES 1
#define PARADROP_ALL 2

#define ICON_CHANNEL "x\zen\addons\modules\ui\chat_ca.paa"
#define ICON_DEATH_STARE "x\zen\addons\modules\ui\target_ca.paa"
#define ICON_DELETE "\A3\ui_f\data\igui\cfg\commandbar\unitcombatmode_ca.paa"
#define ICON_DOCUMENTS "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"
#define ICON_DOG "\a3\Modules_F_Curator\Data\portraitAnimalsGoats_ca.paa"
#define ICON_DOOR "\a3\ui_f\data\igui\cfg\actions\open_door_ca.paa"
#define ICON_END "\a3\Modules_F_Curator\Data\portraitEndMission_ca.paa"
#define ICON_EXPLOSION "x\zen\addons\modules\ui\explosion_ca.paa"
#define ICON_INVENTORY "\a3\Modules_F_Curator\Data\portraitRespawnInventory_ca.paa"
#define ICON_MEDICAL "x\zen\addons\context_actions\ui\medical_cross_ca.paa"
#define ICON_PARADROP "\z\ace\addons\zeus\ui\Icon_Module_Zeus_ParadropCargo_ca.paa"
#define ICON_PERSON "x\zen\addons\modules\ui\person_ca.paa"
#define ICON_RADIO "\a3\Modules_F_Curator\Data\portraitRadio_ca.paa"
#define ICON_REMOTECONTROL "\a3\modules_f_curator\data\portraitremotecontrol_ca.paa"
#define ICON_TIME "\a3\Modules_F_Curator\Data\portraitTimeAcceleration_ca.paa"
#define ICON_TRUCK "x\zen\addons\modules\ui\truck_ca.paa"
#define ICON_UNCONSCIOUS "\z\ace\addons\zeus\ui\Icon_Module_Zeus_Unconscious_ca.paa"
#define ICON_WEATHER "\a3\3DEN\Data\Displays\Display3DEN\ToolBar\intel_ca.paa"
