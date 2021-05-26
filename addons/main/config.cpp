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
            "ace_common",
            "ace_medical",
            "zen_main",
            "zen_modules"
        };
        authors[] = {"johnb43", "cineafx"};
        VERSION_CONFIG;
    };
};

class CfgMods {
    class PREFIX {
        name = "Zeus Additions";
        hideName = 1;
        actionName = "GitHub";
        action = "https://github.com/johnb432/Zeus-Additions";
        description = "Zeus Additions";
    };
};

#include "CfgContext.hpp"
#include "CfgEventHandlers.hpp"
