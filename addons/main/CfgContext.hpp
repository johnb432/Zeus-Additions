class zen_context_menu_actions {
    class GVAR(disablePathing) {
        condition = QUOTE(_objects findIf {!isPlayer _x && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}} isNotEqualTo -1);
        displayName = "Disable AI Pathing";
        icon = "";
        priority = 50;
        statement = QUOTE({[ARR_3('zen_common_disableAI',[ARR_2(_x,'PATH')],_x)] call CBA_fnc_targetEvent} forEach (_objects select {!isPlayer _x && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}}));
    };

    class GVAR(enablePathing) {
        condition = QUOTE(_objects findIf {!isPlayer _x && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}} isNotEqualTo -1);
        displayName = "Enable AI Pathing";
        icon = "";
        priority = 50;
        statement = QUOTE({[ARR_3('zen_common_enableAI',[ARR_2(_x,'PATH')],_x)] call CBA_fnc_targetEvent} forEach (_objects select {!isPlayer _x && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}}));
    };

    class GVAR(openMedicalMenu) {
        condition = QUOTE(_hoveredEntity isEqualType objNull && {_hoveredEntity isKindOf 'CAManBase'});
        displayName = "Open ACE Medical Menu";
        icon = ICON_MEDICAL;
        priority = 50;
        statement = QUOTE(_hoveredEntity call FUNC(openMedicalMenu));
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
