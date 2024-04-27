#pragma hemtt flag pe23_ignore_has_include

class zen_context_menu_actions {
    class GVAR(disablePathingContextMenu) {
        condition = QUOTE([ARR_2(_objects,'disableAI')] call FUNC(pathingCondition));
        displayName = CSTRING(disablePathingContextMenu);
        icon = "\a3\3den\Data\CfgWaypoints\hold_ca.paa";
        priority = 50;
        statement = QUOTE([ARR_2(_objects,'disableAI')] call FUNC(pathingStatement));
    };

    class GVAR(enablePathingContextMenu) {
        condition = QUOTE([ARR_2(_objects,'enableAI')] call FUNC(pathingCondition));
        displayName = CSTRING(enablePathingContextMenu);
        icon = "\a3\3den\Data\Displays\Display3DEN\PanelRight\modeWaypoints_ca.paa";
        priority = 50;
        statement = QUOTE([ARR_2(_objects,'enableAI')] call FUNC(pathingStatement));
    };

    #if __has_include("\z\ace\addons\medical_gui\script_component.hpp")
        class GVAR(openMedicalMenuContextMenu) {
            condition = QUOTE(_hoveredEntity isEqualType objNull && {private _object = ([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity)); _object isKindOf 'CAManBase' && {[ARR_2(objNull,_object)] call ace_medical_gui_fnc_canOpenMenu}});
            displayName = CSTRING_ACE(medical_GUI,openMedicalMenu);
            icon = ICON_MEDICAL;
            priority = 50;
            statement = QUOTE(([ARR_2(_hoveredEntity,effectiveCommander _hoveredEntity)] select (alive _hoveredEntity)) call ace_medical_gui_fnc_openMenu);
        };
    #endif

    class GVAR(selectParadropContextMenu) {
        condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_4('LandVehicle','Ship','CAManBase','Thing')] findIf {_object isKindOf _x} != -1} != -1);
        displayName = CSTRING(selectParadropContextMenu);
        icon = ICON_PARADROP;
        priority = 10;

        class GVAR(selectParadropUnitsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'CAManBase'} && {getNumber ((configOf _x) >> 'isPlayableLogic') == 0}} != -1);
            displayName = CSTRING(selectParadropUnitsContextMenu);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_UNITS)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropVehiclesContextMenu) {
            condition = QUOTE(private _object = objNull; (_objects select {alive _x}) findIf {_object = _x; [ARR_2('LandVehicle','Ship')] findIf {_object isKindOf _x} != -1} != -1);
            displayName = CSTRING(selectParadropVehiclesContextMenu);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_VEHICLES)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropObjectsContextMenu) {
            condition = QUOTE(_objects findIf {alive _x && {_x isKindOf 'Thing'}} != -1);
            displayName = CSTRING(selectParadropObjectsContextMenu);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_MISC)] call FUNC(unitParadropContextMenu));
        };

        class GVAR(selectParadropAllContextMenu) {
            displayName = CSTRING(selectParadropAllContextMenu);
            icon = ICON_PARADROP;
            statement = QUOTE([ARR_2(_objects,PARADROP_ALL)] call FUNC(unitParadropContextMenu));
        };
    };

    class RemoteControl {
        class GVAR(switchUnitContextMenu) {
            displayName = CSTRING(switchUnitModuleName);
            icon = ICON_REMOTECONTROL;
            statement = QUOTE(_hoveredEntity call FUNC(switchUnitStart));
        };
    };
};
