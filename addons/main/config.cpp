#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "cba_main",
            "cba_xeh",
            "zen_main",
            "zen_modules"
        };
        author = "johnb43";
        authors[] = {"johnb43", "cineafx"};
        url = "https://github.com/johnb432/Zeus-Additions";
        VERSION_CONFIG;
    };
};

#include "CfgContext.hpp"
#include "CfgEventHandlers.hpp"
#include "gui.hpp"
