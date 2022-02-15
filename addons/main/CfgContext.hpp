class zen_context_menu_actions {
    class GVAR(disablePathingContextMenu) {
        condition = QUOTE(_objects findIf {alive _x && {!isPlayer _x} && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}} isNotEqualTo -1);
        displayName = "Disable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE({[ARR_2(_x,'PATH')] remoteExecCall [ARR_2('disableAI',_x)]} forEach (_objects select {alive _x && {!isPlayer _x} && {_x isKindOf 'CAManBase'} && {_x checkAIFeature 'PATH'}}));
    };

    class GVAR(enablePathingContextMenu) {
        condition = QUOTE(_objects findIf {alive _x && {!isPlayer _x} && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}} isNotEqualTo -1);
        displayName = "Enable AI Pathing";
        icon = ICON_PERSON;
        priority = 50;
        statement = QUOTE({[ARR_2(_x,'PATH')] remoteExecCall [ARR_2('enableAI',_x)]} forEach (_objects select {alive _x && {!isPlayer _x} && {_x isKindOf 'CAManBase'} && {!(_x checkAIFeature 'PATH')}}));
    };

    class GVAR(openMedicalMenuContextMenu) {
        condition = QUOTE(zen_common_aceMedical && {_hoveredEntity isEqualType objNull && {([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity)) isKindOf 'CAManBase'}});
        displayName = "Open ACE Medical Menu";
        icon = ICON_MEDICAL;
        priority = 50;
        statement = QUOTE([ARR_2([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity),MEDICAL_MENU)] call FUNC(openACEMenu));
    };

    class GVAR(selectParadropContextMenu) {
        condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_4('LandVehicle','Ship','CAManBase','Thing')] findIf {_object isKindOf _x} isNotEqualTo -1} isNotEqualTo -1);
        displayName = "Select objects for paradrop";
        icon = ICON_PARADROP;
        priority = 10;

        class GVAR(selectParadropUnitsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'CAManBase'}} isNotEqualTo -1);
            displayName = "Select units only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_UNITS)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropVehiclesContextMenu) {
            condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_2('LandVehicle','Ship')] findIf {_object isKindOf _x} isNotEqualTo -1} isNotEqualTo -1);
            displayName = "Select vehicles only";
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_VEHICLES)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropObjectsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'Thing'}} isNotEqualTo -1);
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
        class GVAR(switchPlayerContextMenu){
            condition = QUOTE(_hoveredEntity isEqualType objNull && {(effectiveCommander _hoveredEntity) isKindOf 'CAManBase'});
            displayName = "Switch Unit";
            icon = ICON_REMOTECONTROL;
            statement = QUOTE((effectiveCommander _hoveredEntity) call FUNC(remoteControlContextMenu));
        };
    };
};
