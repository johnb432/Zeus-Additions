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

class CfgMods {
    class PREFIX {
        name = "Zeus Additions";
        author = "johnb43";
        tooltipOwned = "Zeus Additions";
        hideName = 0;
        hidePicture = 0;
        actionName = "Github";
        action = "https://github.com/johnb432/Zeus-Additions";
        description = "A small mod that adds Zeus modules, made by johnb43.";
        overview = "A small mod that adds Zeus modules, made by johnb43.";
        picture = "\x\zeus_additions\addons\main\ui\logo_zeus_additions.paa";
        logo = "\x\zeus_additions\addons\main\ui\logo_zeus_additions.paa";
        overviewPicture = "\x\zeus_additions\addons\main\ui\logo_zeus_additions.paa";
    };
};

#include "CfgContext.hpp"
#include "CfgEventHandlers.hpp"
#include "gui.hpp"
