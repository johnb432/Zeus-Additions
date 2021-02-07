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

class CfgMods {
    class PREFIX {
        name = "Zeus Additions";
        hideName = "true";
        actionName = "GitHub";
        action = "https://github.com/johnb432/Zeus-Additions";
        description = "Zeus Additions";
    };
};

#include "CfgEventHandlers.hpp"
