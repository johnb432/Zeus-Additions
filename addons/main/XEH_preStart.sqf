#include "script_component.hpp"

#include "XEH_PREP.hpp"

if (hasInterface) then {
    // Get magazines for resupply module
    private _magazinesHashmap = createHashMap;
    private _magazinesList = createHashMap;
    private _cfgMagazines = configFile >> "CfgMagazines";

    {
        _magazinesList = createHashMap;

        {
            // Remove non-existent magazines; Then get case-senstive names of magazines to avoid problems
            _magazinesList insert [true, ((getArray _x) select {isClass (_cfgMagazines >> _x)}) apply {configName (_cfgMagazines >> _x)}, []];
        } forEach configProperties [_x, "isArray _x", true];

        // Add magazinewells and magazines themselves to hashmap only if it has items
        if (_magazinesList isNotEqualTo createHashMap) then {
            _magazinesHashmap set [toLowerANSI configName _x, keys _magazinesList];
        };
    } forEach configProperties [configFile >> "CfgMagazineWells", "isClass _x", true];

    // Store hashmap with all info necessary
    SETUVAR(QGVAR(magazinesHashmap),_magazinesHashmap);

    private _keys = keys _magazinesHashmap;

    // Sort alphabetically
    _keys sort true;

    SETUVAR(QGVAR(sortedKeys),_keys);
};
