#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "zen_context_actions",
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
