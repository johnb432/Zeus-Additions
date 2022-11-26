#include "\x\cba\addons\main\script_macros_common.hpp"

// This part includes parts of the CBA and ACE3 macro libraries
#define GETPRVAR(var1,var2) (profileNamespace getVariable [ARR_2(var1,var2)])
#define GETUVAR(var1,var2) (uiNamespace getVariable [ARR_2(var1,var2)])
#define GETMVAR(var1,var2) (missionNamespace getVariable [ARR_2(var1,var2)])

#define SETPRVAR(var1,var2) (profileNamespace setVariable [ARR_2(var1,var2)])
#define SETUVAR(var1,var2) (uiNamespace setVariable [ARR_2(var1,var2)])
#define SETMVAR(var1,var2,var3) (missionNamespace setVariable [ARR_3(var1,var2,var3)])

#define ARR_10(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8,ARG9,ARG10) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8, ARG9, ARG10

#define RESUPPLY_TEXT "Spawns in x amount of predefined magazines (not x total!)."
#define OPTION_ARRAY [1, 1, 4, ["Disabled", "Chat only", "VON only", "Enabled"]]

#define MAGAZINES_DESC "Magazines"

#define PARADROP_UNITS 0
#define PARADROP_VEHICLES 1
#define PARADROP_ALL 2
#define PARADROP_MISC 3

#define MEDICAL_MENU 0
#define CARGO_MENU 1

#define ICON_CARGO "a3\ui_f\data\IGUI\Cfg\Actions\loadVehicle_ca.paa"
#define ICON_CHANNEL "x\zen\addons\modules\ui\chat_ca.paa"
#define ICON_DEATH_STARE "x\zen\addons\modules\ui\target_ca.paa"
#define ICON_DELETE "\A3\ui_f\data\igui\cfg\commandbar\unitcombatmode_ca.paa"
#define ICON_DOCUMENTS "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"
#define ICON_DOG "\a3\Modules_F_Curator\Data\portraitAnimalsGoats_ca.paa"
#define ICON_DOOR "\a3\ui_f\data\igui\cfg\actions\open_door_ca.paa"
#define ICON_END "\a3\Modules_F_Curator\Data\portraitEndMission_ca.paa"
#define ICON_EXPLOSION "x\zen\addons\modules\ui\explosion_ca.paa"
#define ICON_GRENADE "x\zen\addons\context_actions\ui\grenade_ca.paa"
#define ICON_INVENTORY "\a3\Modules_F_Curator\Data\portraitRespawnInventory_ca.paa"
#define ICON_MEDICAL "x\zen\addons\context_actions\ui\medical_cross_ca.paa"
#define ICON_OBJECT "x\zen\addons\modules\ui\edit_obj_ca.paa"
#define ICON_PARADROP "x\zen\addons\modules\ui\heli_ca.paa"//"\z\ace\addons\zeus\ui\Icon_Module_Zeus_ParadropCargo_ca.paa"
#define ICON_PERSON "x\zen\addons\modules\ui\person_ca.paa"
#define ICON_RADIO "\a3\Modules_F_Curator\Data\portraitRadio_ca.paa"
#define ICON_REMOTECONTROL "\a3\modules_f_curator\data\portraitremotecontrol_ca.paa"
#define ICON_TIME "\a3\Modules_F_Curator\Data\portraitTimeAcceleration_ca.paa"
#define ICON_TRUCK "x\zen\addons\modules\ui\truck_ca.paa"
#define ICON_TREE "\a3\modules_f\data\hideterrainobjects\icon32_ca.paa"
#define ICON_UNCONSCIOUS "\z\ace\addons\zeus\ui\Icon_Module_Zeus_Unconscious_ca.paa"
#define ICON_WEATHER "\a3\3DEN\Data\Displays\Display3DEN\ToolBar\intel_ca.paa"

#define ST_CENTER 2

#define IDC_OK 1 // emulate "OK" button
#define IDC_CANCEL 2 // emulate "Cancel" button

#define IDC_BUTTON_CLR 311010
#define IDC_BUTTON_INC 311011
#define IDC_BUTTON_DEC 311012
#define IDC_BUTTON_INTO 311013
#define IDC_BUTTON_OUTOF 311014

#define IDC_LIST_CATEGORIES 311020
#define IDC_LIST_MAGAZINES 311021
#define IDC_LIST_SELECTED 311022

#define IDD_MISSION 46
#define IDD_INTERRUPT 49
#define IDD_RSCDISPLAYCURATOR 312

#define POS_CALC ((safezoneW / safezoneH) min 1.2)
#define X_OFF (safezoneX + (safezoneW - POS_CALC) / 2)
#define Y_OFF (safezoneY + (safezoneH - (POS_CALC / 1.2)) / 2)
#define W_OFF (POS_CALC / 40)
#define H_OFF (POS_CALC / 30) // (POS_CALC / 1.2) / 25

#define POS_W(var1) (var1 * W_OFF)
#define POS_H(var1) (var1 * H_OFF)
#define POS_X(var1) (POS_W(var1) + X_OFF)
#define POS_Y(var1) (POS_H(var1) + Y_OFF)

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif
