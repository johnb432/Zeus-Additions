class zen_context_menu_actions {
    class GVAR(disablePathingContextMenu) {
        condition = QUOTE([ARR_2(_objects,'disableAI')] call FUNC(pathingCondition));
        displayName = "Disable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE([ARR_2(_objects,'disableAI')] call FUNC(pathingStatement));
    };

    class GVAR(enablePathingContextMenu) {
        condition = QUOTE([ARR_2(_objects,'enableAI')] call FUNC(pathingCondition));
        displayName = "Enable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE([ARR_2(_objects,'enableAI')] call FUNC(pathingStatement));
    };

    class GVAR(openMedicalMenuContextMenu) {
        condition = QUOTE(zen_common_aceMedical && {_hoveredEntity isEqualType objNull} && {([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity)) isKindOf 'CAManBase'});
        displayName = "Open ACE Medical Menu";
        icon = ICON_MEDICAL;
        priority = 50;
        statement = QUOTE([ARR_2([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity),MEDICAL_MENU)] call FUNC(openACEMenu));
    };

    class GVAR(selectParadropContextMenu) {
        condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_4('LandVehicle','Ship','CAManBase','Thing')] findIf {_object isKindOf _x} != -1} != -1);
        displayName = "Select objects for paradrop";
        icon = ICON_PARADROP;
        priority = 10;

        class GVAR(selectParadropUnitsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'CAManBase'} && {!(_x isKindOf 'VirtualCurator_F')}} != -1);
            displayName = "Select units only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_UNITS)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropVehiclesContextMenu) {
            condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_2('LandVehicle','Ship')] findIf {_object isKindOf _x} != -1} != -1);
            displayName = "Select vehicles only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_VEHICLES)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropObjectsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'Thing'}} != -1);
            displayName = "Select misc objects only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_MISC)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropAllContextMenu) {
            displayName = "Select all";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_ALL)] call FUNC(unitParadropContextMenu));
        };
    };

    class RemoteControl {
        class GVAR(switchPlayerContextMenu) {
            displayName = "Switch Unit";
            icon = ICON_REMOTECONTROL;
            statement = QUOTE(_hoveredEntity call FUNC(remoteControlContextMenu));
        };
    };
};
