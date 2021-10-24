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
                    text = "SELECT MAGAZINES";
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
                    text = "Categories";
                    tooltip = "Allows you select different categories of magazines.";
                };

                class GVAR(listCategories): RscListBox {
                    idc = IDC_LIST_CATEGORIES;
                    x = POS_X(7.8);
                    y = POS_Y(1.5);
                    w = POS_W(12.5);
                    h = POS_H(18);
                    colorBackground[] = {0, 0, 0, 0.6};
                };

                class GVAR(listMagazines): RscListBoxMulti {
                    idc = IDC_LIST_MAGAZINES;
                    x = POS_X(20.5);
                    y = POS_Y(1.5);
                    w = POS_W(12.5);
                    h = POS_H(18);
                    colorBackground[] = {0, 0, 0, 0.6};
                };

                class GVAR(listSelected): RscListBoxMulti {
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

                class GVAR(buttonMoveInto): RscButtonMenu {
                    idc = IDC_BUTTON_INTO;
                    x = POS_X(33.2);
                    y = POS_Y(10);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = ">";
                    tooltip = "Move into selected";
                };

                class GVAR(buttonMoveOutOf): RscButtonMenu {
                    idc = IDC_BUTTON_OUTOF;
                    x = POS_X(33.2);
                    y = POS_Y(12);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    tooltip = "Move out of selected";
                };

                class GVAR(buttonClear): ctrlButtonPicture {
                    idc = IDC_BUTTON_CLR;
                    x = POS_X(33.2);
                    y = POS_Y(8);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    text = "\a3\3den\data\cfg3den\history\deleteitems_ca.paa";
                    tooltip = "Clear all selected magazines.";
                };

                class GVAR(buttonIncrement): RscButtonMenu {
                    idc = IDC_BUTTON_INC;
                    x = POS_X(33.2);
                    y = POS_Y(1.5);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = "+";
                    tooltip = "Shift = +5, Ctrl = +10, Shift + Ctrl = +50";
                };

                class GVAR(buttonDecrement): RscButtonMenu {
                    idc = IDC_BUTTON_DEC;
                    x = POS_X(33.2);
                    y = POS_Y(3);
                    w = POS_W(1.2);
                    h = POS_H(1.2);
                    colorBackground[] = {0, 0, 0, 0.7};
                    sytle = ST_CENTER;
                    text = "-";
                    tooltip = "Shift = -5, Ctrl = -10, Shift + Ctrl = -50";
                };
            };
        };
    };
};
