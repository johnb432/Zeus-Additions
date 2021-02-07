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
        VERSION_CONFIG;
    };
};

/*
class CfgMods {
    class PREFIX {
        dir = "@tao";
        name = "Tao's folding map";
        hideName = "true";
        actionName = "GitHub";
        action = "https://github.com/johnb432/TAO_rewrite";
        description = "Tao's folding map";
    };
};
*/

#include "CfgEventHandlers.hpp"
