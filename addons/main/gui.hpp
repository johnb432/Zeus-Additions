class RscText;
class RscTextMulti;
class RscButton;
class RscStructuredText;
class RscButtonMenu;
class RscButtonMenuOK;
class RscButtonMenuCancel;
class RscControlsGroupNoHScrollbars;
class RscListBox;
class RscListBoxMulti;
class ctrlButtonPicture;

class GVAR(RscDisplay) {
    idd = -1;
    movingEnable = 1;
    onLoad = QUOTE(SETUVAR(QQGVAR(display),_this select 0));
    class controls {
        class GVAR(displayGroup): RscControlsGroupNoHScrollbars {
            idc = -1;
            x = POS_X(-2);
            y = 0;
            w = POS_W(44.2);
            h = POS_H(21.3);
            colorBackground[] = {0, 0, 0, 0};
            colorText[] = {1, 1, 1, 1};
            font = "PuristaMedium";
            sizeEx = 0;
            shadow = 0;
            text = "";

            class controls {
                class Title: RscText {
                    idc = -1;
                    x = 0;
                    y = 0;
                    w = POS_W(44.2);
                    h = POS_H(1);
                    colorBackground[] = {QUOTE(GETPRVAR('GUI_BCG_RGB_R',0.13)), QUOTE(GETPRVAR('GUI_BCG_RGB_G',0.54)), QUOTE(GETPRVAR('GUI_BCG_RGB_B',0.21)), QUOTE(GETPRVAR('GUI_BCG_RGB_A',0.8))};
                    text = CSTRING(selectMagazines);
                };
                class Background: RscText {
                    idc = -1;
                    x = 0;
                    y = POS_Y(1.1);
                    w = POS_W(44.2);
                    h = POS_H(18.9);
                    colorBackground[] = {0, 0, 0, 0.5};
                };
                class BackgroundCategories: RscTextMulti {
                    idc = -1;
                    x = POS_X(4);
                    y = POS_Y(1.5);
                    w = POS_W(3.7);
                    h = POS_H(18);
                    onLoad = QUOTE((_this select 0) ctrlEnable false);
                    colorBackground[] = {0, 0, 0, 0.6};
                    text = CSTRING(categories);
                    tooltip = CSTRING(categoriesDesc);
                };
                class ListCategories: RscListBox {
                    idc = IDC_LIST_CATEGORIES;
                    x = POS_X(7.8);
                    y = POS_Y(1.5);
                    w = POS_W(12.5);
                    h = POS_H(18);
                    colorBackground[] = {0, 0, 0, 0.6};
                };
                class ListMagazines: RscListBoxMulti {
                    idc = IDC_LIST_MAGAZINES;
                    x = POS_X(20.5);
                    y = POS_Y(1.5);
                    w = POS_W(12.5);
                    h = POS_H(18);
                    colorBackground[] = {0, 0, 0, 0.6};
                };
                class ListSelected: RscListBoxMulti {
                    idc = IDC_LIST_SELECTED;
                    x = POS_X(34.5);
                    y = POS_Y(1.5);
                    w = POS_W(12.5);
                    h = POS_H(18);
                    colorBackground[] = {0, 0, 0, 0.6};
                };
                class ButtonOK: RscButtonMenuOK {
                    x = POS_X(42.75);
                    y = POS_Y(20.1);
                    w = POS_W(5);
                    h = POS_H(1);
                };
                class ButtonCancel: RscButtonMenuCancel {
                    x = POS_X(3.3);
                    y = POS_Y(20.1);
                    w = POS_W(5);
                    h = POS_H(1);
                };
                class ButtonMoveInto: RscButtonMenu {
                    idc = IDC_BUTTON_INTO;
                    x = POS_X(33.2);
                    y = POS_Y(10);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = ">";
                    tooltip = CSTRING(moveIntoSelected);
                };
                class ButtonMoveOutOf: RscButtonMenu {
                    idc = IDC_BUTTON_OUTOF;
                    x = POS_X(33.2);
                    y = POS_Y(12);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    tooltip = CSTRING(moveOutOfSelected);
                };
                class ButtonClear: ctrlButtonPicture {
                    idc = IDC_BUTTON_CLR;
                    x = POS_X(33.2);
                    y = POS_Y(8);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    text = "\a3\3den\data\cfg3den\history\deleteitems_ca.paa";
                    tooltip = CSTRING(clearAllDesc);
                };
                class ButtonIncrement: RscButtonMenu {
                    idc = IDC_BUTTON_INC;
                    x = POS_X(33.2);
                    y = POS_Y(1.5);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = "+";
                    tooltip = CSTRING(increaseDesc);
                };
                class ButtonDecrement: RscButtonMenu {
                    idc = IDC_BUTTON_DEC;
                    x = POS_X(33.2);
                    y = POS_Y(3);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = "-";
                    tooltip = CSTRING(decreaseDesc);
                };
            };
        };
    };
};

class RscPicture;
class RscControlsGroupNoScrollbars;

class ctrlXSliderH;
class ctrlTree;
class ctrlListbox;
class ctrlToolbox;
class ctrlCheckbox;
class ctrlButtonPictureKeepAspect;

class zen_common_RscLabel;
class zen_common_RscBackground;
class zen_common_RscEdit;
class zen_modules_RscSidesCombo;

class zen_common_RscDisplay {
    class controls {
        class Title;
        class Background;
        class Content;
        class ButtonOK;
        class ButtonCancel;
    };
};
class zen_modules_RscDisplay: zen_common_RscDisplay {};

class GVAR(rscSpawnGarrison): zen_modules_RscDisplay {
    onLoad = QUOTE(SETUVAR(QQGVAR(display),_this select 0));
    class controls: controls {
        class Title: Title {
            text = CSTRING(garrisonBuildingModuleName);
        };
        class Background: Background {
            y = POS_H(1.1);
            h = POS_H(21.8);
        };
        class Content: Content {
            h = POS_H(22.5);

            class controls {
                class SideLabel: zen_common_RscLabel {
                    text = "$STR_eval_typeside";
                    y = POS_H(1.5);
                };
                class Side: zen_modules_RscSidesCombo {
                    idc = IDC_SPAWNGARRISON_SIDE;
                    y = POS_H(1.5);
                };
                class GroupSelect: RscControlsGroupNoScrollbars {
                    idc = -1;
                    x = 0;
                    y = POS_H(2.6);
                    w = POS_W(26);
                    h = POS_H(14.2);

                    class controls {
                        class Title: zen_common_RscLabel {
                            text = "$STR_zen_modules_GroupSelect";
                            w = POS_W(26);
                        };
                        class Background: zen_common_RscBackground {
                            x = 0;
                            y = POS_H(1);
                            w = POS_W(26);
                            h = POS_H(13.2);
                        };
                        class TreeMode: ctrlToolbox {
                            idc = IDC_SPAWNGARRISON_TREE_MODE;
                            x = POS_W(0.1);
                            y = POS_H(1.1);
                            w = POS_W(13);
                            h = POS_H(1);
                            rows = 1;
                            columns = 2;
                            strings[] = {"$STR_zen_common_Premade", "$STR_Radio_Custom"};
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                        class TreeGroups: ctrlTree {
                            idc = IDC_SPAWNGARRISON_TREE_GROUPS;
                            x = POS_W(0.1);
                            y = QUOTE(2.1 * GUI_GRID_H - pixelH);
                            w = POS_W(13);
                            h = POS_H(12);
                            sizeEx = QUOTE(3.96 * (1 / (getResolution select 3)) * pixelGrid * 0.5);
                            colorBackground[] = {0, 0, 0, 0.3};
                            colorBorder[] = {0, 0, 0, 0};
                            disableKeyboardSearch = 1;
                        };
                        class TreeUnits: TreeGroups {
                            idc = IDC_SPAWNGARRISON_TREE_UNITS;
                        };
                        class Label: zen_common_RscLabel {
                            text = "$STR_zen_modules_CurrentGroup";
                            x = POS_W(13.2);
                            y = POS_H(1.1);
                            w = POS_W(12.7);
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                        class UnitCount: Label {
                            idc = IDC_SPAWNGARRISON_UNIT_COUNT;
                            style = ST_RIGHT;
                            text = "0";
                            w = POS_W(11.1);
                            colorBackground[] = {0, 0, 0, 0};
                        };
                        class UnitList: ctrlListbox {
                            idc = IDC_SPAWNGARRISON_UNIT_LIST;
                            x = POS_W(13.2);
                            y = QUOTE(2.1 * GUI_GRID_H - pixelH);
                            w = POS_W(12.7);
                            h = POS_H(12);
                            colorBackground[] = {0, 0, 0, 0.3};
                        };
                        class UnitIcon: RscPicture {
                            idc = -1;
                            text = ICON_PERSON;
                            x = POS_W(24);
                            y = POS_H(1.1);
                            w = POS_W(1);
                            h = POS_H(1);
                        };
                        class UnitClear: ctrlButtonPictureKeepAspect {
                            idc = IDC_SPAWNGARRISON_UNIT_CLEAR;
                            text = "\a3\3den\data\cfg3den\history\deleteitems_ca.paa";
                            x = POS_W(24.9);
                            y = POS_H(1.1);
                            w = POS_W(1);
                            h = POS_H(1);
                            colorBackground[] = {0, 0, 0, 0};
                            offsetPressedX = 0;
                            offsetPressedY = 0;
                        };
                    };
                };
                class Properties: RscControlsGroupNoScrollbars {
                    idc = -1;
                    x = 0;
                    y = POS_H(16.9);
                    w = POS_W(26);
                    h = POS_H(5.5);

                    class controls {
                        class Title: zen_common_RscLabel {
                            text = "$STR_A3_RscDisplayLogin_Properties";
                            w = POS_W(26);
                        };
                        class Background: zen_common_RscBackground {
                            x = 0;
                            y = POS_H(1);
                            w = POS_W(26);
                            h = POS_H(6.7);
                        };
                        class DynamicSimulationLabel: zen_common_RscLabel {
                            text = "$STR_3DEN_DynamicSimulation_textSingular";
                            x = POS_W(3);
                            y = POS_H(1.1);
                            w = POS_W(8.9);
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                        class DynamicSimulation: ctrlCheckbox {
                            idc = IDC_SPAWNGARRISON_DYNAMIC_SIMULATION;
                            x = POS_W(12);
                            y = POS_H(1.1);
                            w = POS_W(1);
                            h = POS_H(1);
                        };
                        class TriggerLabel: zen_common_RscLabel {
                            text = "$STR_3DEN_CfgVehicles_EmptyDetector";
                            x = POS_W(3);
                            y = POS_H(2.2);
                            w = POS_W(8.9);
                            colorBackground[] = {0, 0, 0, 0.7};
                            tooltip = "$STR_3den_attributes_triggeractivation_anyplayer_text";
                        };
                        class Trigger: ctrlCheckbox {
                            idc = IDC_SPAWNGARRISON_TRIGGER;
                            x = POS_W(12);
                            y = POS_H(2.2);
                            w = POS_W(1);
                            h = POS_H(1);
                        };
                        class TriggerRadiusLabel: zen_common_RscLabel {
                            text = "$STR_3den_trigger_attribute_size_displayname";
                            x = POS_W(3);
                            y = POS_H(3.3);
                            w = POS_W(8.9);
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                        class TriggerRadius: ctrlXSliderH {
                            idc = IDC_SPAWNGARRISON_TRIGGER_RADIUS;
                            x = POS_W(12);
                            y = POS_H(3.3);
                            w = POS_W(11);
                            h = POS_H(1);
                            lineSize = 25;
                            pageSize = 5;
                            sliderStep = 5;
                            sliderRange[] = {0, 500};
                            sliderPosition = 0;
                        };
                        class UnitBehaviourLabel: zen_common_RscLabel {
                            text = "$STR_zen_modules_UnitBehaviour";
                            x = POS_W(3);
                            y = POS_H(4.4);
                            w = POS_W(8.9);
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                        class UnitBehaviour: ctrlToolbox {
                            idc = IDC_SPAWNGARRISON_UNIT_BEHAVIOUR;
                            x = POS_W(12);
                            y = POS_H(4.4);
                            w = POS_W(11);
                            h = POS_H(1);
                            rows = 1;
                            columns = 4;
                            strings[] = {
                                "$STR_Disp_Default",
                                "$STR_zen_common_Relaxed",
                                "$STR_zen_common_Cautious",
                                "$STR_Combat"
                            };
                            colorBackground[] = {0, 0, 0, 0.7};
                        };
                    };
                };
            };
        };
        class ButtonOK: ButtonOK {
            y = POS_H(23);
        };
        class ButtonCancel: ButtonCancel {
            y = POS_H(23);
        };
    };
};
