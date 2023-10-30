#include "..\script_component.hpp"
/*
 * Author: johnb43, BadGuy (from CLib)
 * Removes headers and strips all whitespaces in code.
 *
 * Arguments:
 * 0: Code <CODE> <STRING> (default: "")
 * 1: Return as code <BOOL> (default: true)
 * 2: If returned code is final <BOOL> (default: false)
 *
 * Return Value:
 * Sanitised function <CODE> <STRING>
 *
 * Example:
 * {nil} call zeus_additions_main_fnc_sanitiseFunction
 *
 * Public: No
 */

params [["_function", "", ["", {}]], ["_returnAsCode", true], ["_isFinal", false]];

if (_function isEqualType {}) then {
    _function = toString _function;
};

if (_function == "") exitWith {};

private _index = -1;

// Remove headers (#line)
while {_function regexFind ["#line"] isNotEqualTo []} do {
    _function = _function regexReplace ["#line[^\n\r]*(\n|\r)", ""];
    _function = trim _function;
};

// Strips all whitespaces in code
private _singleQuoteString = false;
private _doubleQuoteString = false;
private _inPreProcessor = false;
private _lastChar = 0;
private _operator = toArray "+-*/%&|<>=:,;";
private _braces = toArray "(){}[]""'";
private _allSpecialChar = WHITESPACE + _operator + _braces;
private _operatorAndBraces = _operator + _braces;
private _token = [];
private _outArray = [];

{
    if (_singleQuoteString || _doubleQuoteString || _inPreProcessor) then {
        if (_doubleQuoteString && {_x == SINGLE_QUOTE} && {_lastChar != SINGLE_QUOTE}) then {
            _doubleQuoteString = false;
        };

        if (_singleQuoteString && {_x == DOUBLE_QUOTE} && {_lastChar != DOUBLE_QUOTE}) then {
            _singleQuoteString = false;
        };

        if (_inPreProcessor && {_x == LINE_FEED} && {_lastChar != REVERSE_SOLIDUS}) then {
            _inPreProcessor = false;
        };

        _outArray pushBack toString [_x];
        _lastChar = _x;
    } else {
        _doubleQuoteString = _x == SINGLE_QUOTE;
        _singleQuoteString = _x == DOUBLE_QUOTE;
        _inPreProcessor = _x == NUMBER_SIGN;

        if (_singleQuoteString || _doubleQuoteString || _inPreProcessor) then {
            _outArray pushBack toString _token;
            _token = [];

            if (_inPreProcessor) then {
                _outArray pushBack toString [LINE_FEED];
            };

            _outArray pushBack toString [_x];
            _lastChar = 0;
        } else {
            if (_x in _allSpecialChar) then {
                _outArray pushBack toString _token;
                _token = [];

                if (_x in _operatorAndBraces) then {
                    _outArray pushBack toString [_x];
                    _lastChar = _x;
                };
            } else {
                if (_token isEqualTo [] && {_lastChar > 0} && {!(_lastChar in _operatorAndBraces)}) then {
                    _outArray pushBack " ";
                };

                _lastChar = _x;
                _token pushBack _x;
            };
        };
    };
} forEach toArray _function;

_outArray pushBack toString _token;
_function = _outArray joinString "";

// Return
if (_returnAsCode) then {
    if (_isFinal) then {
        compile _function
    } else {
        compileFinal _function
    };
} else {
    _function
};
