#define COMPONENT main
#include "script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
#define DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_ZEUS_ADDITIONS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_ZEUS_ADDITIONS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_ZEUS_ADDITIONS
#endif

#include "script_macros.hpp"

// Include BI DIK codes
#include "\a3\ui_f\hpp\defineDIKCodes.inc"
#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineResincl.inc"
