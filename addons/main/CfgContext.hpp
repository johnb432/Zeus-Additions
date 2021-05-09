class zen_context_menu_actions {
    class GVAR(openMedicalMenu) {
        condition = QUOTE(_hoveredEntity isKindOf 'CAManBase');
        displayName = "Open ACE Medical Menu";
        icon = ICON_MEDICAL;
        priority = 50;
        statement = QUOTE(_hoveredEntity call FUNC(openMedicalMenu););
    };

    class GVAR(selectParadropMenu) {
        condition = QUOTE(_objects findIf {_x isKindOf 'LandVehicle' || {_x isKindOf 'Ship'} || {_x isKindOf 'CAManBase'}} isNotEqualTo -1);
        displayName = "Select units/vehicles for paradrop";
        icon = ICON_PARADROP;
        priority = 10;

        class GVAR(selectParadropUnitsMenu) {
            displayName = "Select units only";
            condition = QUOTE(_objects findIf {_x isKindOf 'CAManBase'} isNotEqualTo -1);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_UNITS)] call FUNC(unitParadropContextMenu));
        };
        class GVAR(selectParadropVehiclesMenu) {
            displayName = "Select vehicles only";
            condition = QUOTE(_objects findIf {_x isKindOf 'LandVehicle' || {_x isKindOf 'Ship'}} isNotEqualTo -1);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_VEHICLES)] call FUNC(unitParadropContextMenu));
        };
        class GVAR(selectParadropAllMenu) {
            displayName = "Select all";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_ALL)] call FUNC(unitParadropContextMenu));
        };
    };
};
