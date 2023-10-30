#include "\x\cba\addons\main\script_macros_common.hpp"

// This part includes parts of the CBA and ACE3 macro libraries
#define GETPRVAR(var1,var2) (profileNamespace getVariable [ARR_2(var1,var2)])
#define GETUVAR(var1,var2) (uiNamespace getVariable [ARR_2(var1,var2)])
#define GETMVAR(var1,var2) (missionNamespace getVariable [ARR_2(var1,var2)])

#define SETPRVAR(var1,var2) (profileNamespace setVariable [ARR_2(var1,var2)])
#define SETUVAR(var1,var2) (uiNamespace setVariable [ARR_2(var1,var2)])
#define SETMVAR(var1,var2,var3) (missionNamespace setVariable [ARR_3(var1,var2,var3)])

#define OPTION_ARRAY [1, 1, 4, [LSTRING_ZEN(common,disabled), "STR_A3_Multiplayer_Text1", "str_usract_voice_over_net", LSTRING_ZEN(common,enabled)]]

#define MAGAZINES_DESC localize "STR_GEAR_MAGAZINES"

#define PARADROP_UNITS 0
#define PARADROP_VEHICLES 1
#define PARADROP_ALL 2
#define PARADROP_MISC 3

#define MEDICAL_MENU 0
#define CARGO_MENU 1

#define ICON_EXPLOSION "x\zen\addons\modules\ui\explosion_ca.paa"
#define ICON_INVENTORY "\a3\Modules_F_Curator\Data\portraitRespawnInventory_ca.paa"
#define ICON_MEDICAL "x\zen\addons\context_actions\ui\medical_cross_ca.paa"
#define ICON_OBJECT "x\zen\addons\modules\ui\edit_obj_ca.paa"
#define ICON_PERSON "x\zen\addons\modules\ui\person_ca.paa"
#define ICON_RADIO "\a3\Modules_F_Curator\Data\portraitRadio_ca.paa"
#define ICON_REMOTECONTROL "\a3\modules_f_curator\data\portraitremotecontrol_ca.paa"
#define ICON_TRUCK "x\zen\addons\modules\ui\truck_ca.paa"

#define GRAVITY 9.8066

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

#define POS_W(var1) QUOTE(var1 * W_OFF)
#define POS_H(var1) QUOTE(var1 * H_OFF)
#define POS_X(var1) QUOTE(var1 * W_OFF + X_OFF)
#define POS_Y(var1) QUOTE(var1 * H_OFF + Y_OFF)

#define SINGLE_QUOTE    34 // '
#define DOUBLE_QUOTE    39 // "
#define LINE_FEED       10 //
#define NUMBER_SIGN     35 // #
#define REVERSE_SOLIDUS 92 // \

#define CARRIAGE_RETURN 13
#define TAB             9
#define SPACE           32
#define WHITESPACE [LINE_FEED, CARRIAGE_RETURN, TAB, SPACE]

#define LSTRING_BASE(prefix,var1,var2) QUOTE(TRIPLES(prefix,var1,var2))

#define LSTRING_ACE(var1,var2) LSTRING_BASE(STR_ACE,var1,var2)
#define LSTRING_CBA(var1,var2) LSTRING_BASE(STR_CBA,var1,var2)
#define LSTRING_ZEN(var1,var2) LSTRING_BASE(STR_ZEN,var1,var2)

#define LLSTRING_ACE(var1,var2) localize LSTRING_ACE(var1,var2)
#define LLSTRING_CBA(var1,var2) localize LSTRING_CBA(var1,var2)
#define LLSTRING_ZEN(var1,var2) localize LSTRING_ZEN(var1,var2)

#define CSTRING_ACE(var1,var2) LSTRING_BASE($STR_ACE,var1,var2)

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)
#define LINKFUNC(x) {_this call FUNC(x)}

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #undef PREP_MP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
    #define PREP_MP(fncName) DFUNC(fncName) = [preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)] call FUNC(sanitiseFunction)
#else
    #undef PREP
    #undef PREP_MP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
    #define PREP_MP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call FUNC(compileSanitisedFunction)
#endif

// INFO macro fails sometimes
#define INFO_ZA(message) diag_log text FORMAT_4("[%1] (%2) %3: %4",toUpper QUOTE(PREFIX),QUOTE(COMPONENT),"INFO",message)

#define SEND_MP(fncName)\
SETMVAR(QFUNC(fncName),FUNC(fncName),true);\
INFO_ZA(FORMAT_1("Sent function to all: %1",QFUNC(fncName)))

#define SEND_SERVER(fncName)\
SETMVAR(QFUNC(fncName),FUNC(fncName),2);\
INFO_ZA(FORMAT_1("Sent function to server: %1",QFUNC(fncName)))

#define PREP_SEND_MP(fncName)\
PREP_MP(fncName);\
SEND_MP(fncName)
