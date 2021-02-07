#define MAINPREFIX x
#define PREFIX zeus_additions

#include "script_version.hpp"

#define VERSION     MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR  MAJOR,MINOR,PATCHLVL,BUILD

#define ZEUS_ADDITIONS_TAG ZEUS_ADDITIONS

// MINIMAL required version for the Mod. Components can specify others..
#define REQUIRED_VERSION 1.96
#define REQUIRED_CBA_VERSION {3,12,2}

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(Zeus Additions - COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(Zeus Additions - COMPONENT)
#endif
