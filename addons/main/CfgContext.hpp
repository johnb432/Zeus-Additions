class zen_context_menu_actions {
    class GVAR(disablePathingContextMenu) {
        condition = QUOTE(_objects findIf {!isPlayer _x && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}} isNotEqualTo -1);
        displayName = "Disable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE({[ARR_3('zen_common_disableAI',[ARR_2(_x,'PATH')],_x)] call CBA_fnc_targetEvent} forEach (_objects select {!isPlayer _x && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}}));
    };

    class GVAR(enablePathingContextMenu) {
        condition = QUOTE(_objects findIf {!isPlayer _x && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}} isNotEqualTo -1);
        displayName = "Enable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE({[ARR_3('zen_common_enableAI',[ARR_2(_x,'PATH')],_x)] call CBA_fnc_targetEvent} forEach (_objects select {!isPlayer _x && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}}));
    };

    class GVAR(openMedicalMenuContextMenu) {
        condition = QUOTE(_hoveredEntity isEqualType objNull && {(effectiveCommander _hoveredEntity) isKindOf 'CAManBase'});
        displayName = "Open ACE Medical Menu";
        icon = ICON_MEDICAL;
        priority = 50;
        statement = QUOTE((effectiveCommander _hoveredEntity) call FUNC(openMedicalMenuContextMenu));
    };

    class GVAR(selectParadropContextMenu) {
        condition = QUOTE(_objects findIf {_x isKindOf 'LandVehicle' || {_x isKindOf 'Ship'} || {_x isKindOf 'CAManBase'}} isNotEqualTo -1);
        displayName = "Select units/vehicles for paradrop";
        icon = ICON_PARADROP;
        priority = 10;

        class GVAR(selectParadropUnitsContextMenu) {
            condition = QUOTE(_objects findIf {_x isKindOf 'CAManBase'} isNotEqualTo -1);
            displayName = "Select units only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_UNITS)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropVehiclesContextMenu) {
            condition = QUOTE(_objects findIf {_x isKindOf 'LandVehicle' || {_x isKindOf 'Ship'}} isNotEqualTo -1);
            displayName = "Select vehicles only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_VEHICLES)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropAllContextMenu) {
            displayName = "Select all";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_ALL)] call FUNC(unitParadropContextMenu));
        };
    };

    class RemoteControl {
        class GVAR(switchPlayerContextMenu){
            condition = QUOTE(_hoveredEntity isEqualType objNull && {(effectiveCommander _hoveredEntity) isKindOf 'CAManBase'});
            displayName = "Switch Player";
            icon = ICON_REMOTECONTROL;
            statement = QUOTE((effectiveCommander _hoveredEntity) call FUNC(remoteControlContextMenu));
        };
    };
};
