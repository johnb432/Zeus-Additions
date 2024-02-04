#include "..\script_component.hpp"
/*
 * Author: PabstMirror (idea from Dystopian), johnb43
 * CBA_fnc_removeGlobalEventJIP, but adjusted for Zeus Additions.
 *
 * Arguments:
 * 0: A unique ID from FUNC(globalEventJIP) <STRING>
 * 1: Will remove JIP EH when object is deleted or immediately if omitted <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * "jipid" call zeus_additions_main_fnc_removeGlobalEventJIP;
 *
 * Public: No
 */

params [["_jipID", "", [""]], ["_object", objNull, [objNull]]];

[QGVAR(removeEventJIP), [_jipID, _object]] call CBA_fnc_serverEvent;
