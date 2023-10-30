#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "A3_Data_F_AoW_Loadorder",
            "cba_main",
            "cba_xeh",
            "zen_main",
            "zen_modules"
        };
        author = "johnb43";
        authors[] = {
            "johnb43"
        };
        url = "https://github.com/johnb432/Zeus-Additions";
        skipWhenMissingDependencies = 1;
        VERSION_CONFIG;
    };
};

#include "CfgContext.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgVersioning.hpp"
#include "gui.hpp"
