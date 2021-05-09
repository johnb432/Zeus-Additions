#include "\x\cba\addons\main\script_macros_common.hpp"
#include "\x\cba\addons\xeh\script_xeh.hpp"

//This part includes parts of the CBA and ACE3 macro libraries
#define GETPRVAR(var1,var2) (profileNamespace getVariable [ARR_2(var1,var2)])
#define SETPRVAR(var1,var2) (profileNamespace setVariable [ARR_2(var1,var2)])

#define FUNC_PATHTO_SYS(var1,var2,var3) \MAINPREFIX\var1\SUBPREFIX\var2\functions\var3.sqf

#undef PATHTO_FNC
#define PATHTO_FNC(func) \
class func {\
    file = QUOTE(FUNC_PATHTO_SYS(PREFIX,COMPONENT,DOUBLES(fnc,func)));\
    CFGFUNCTION_HEADER;\
    RECOMPILE;\
}

#ifdef DISABLE_COMPILE_CACHE
    #define PREPFNC(var1) TRIPLES(ADDON,fnc,var1) = compile preProcessFileLineNumbers 'FUNC_PATHTO_SYS(PREFIX,COMPONENT,DOUBLES(fnc,var1))'
#else
    #define PREPFNC(var1) ['FUNC_PATHTO_SYS(PREFIX,COMPONENT,DOUBLES(fnc,var1))', 'TRIPLES(ADDON,fnc,var1)'] call SLX_XEH_COMPILE_NEW
#endif

#define RESUPPLY_TEXT "Spawns in x amount of predefined magazines (not x total!)."
#define RESUPPLY_DESC "Used for the 'Spawn Ammo Resupply Crate' module. Must be an array of strings."

#define MAGAZINES_DESC "Magazines"

#define PARADROP_UNITS 0
#define PARADROP_VEHICLES 1
#define PARADROP_ALL 2

#define ICON_PARADROP "\z\ace\addons\zeus\ui\Icon_Module_Zeus_ParadropCargo_ca.paa"
#define ICON_MEDICAL "x\zen\addons\context_actions\ui\medical_cross_ca.paa"
#define ICON_DEATH_STARE "x\zen\addons\modules\ui\target_ca.paa"
