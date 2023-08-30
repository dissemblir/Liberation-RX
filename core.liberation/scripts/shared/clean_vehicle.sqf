params ["_vehicle", ["_delete", true]];

if (isNull _vehicle) exitWith {};
private _towed = !(isNull (_vehicle getVariable ["R3F_LOG_est_transporte_par", objNull]));
private _server_owned = (_vehicle getVariable ["GRLIB_vehicle_owner", ""] == "server");
private _blu_inside = ({(alive _x && side group _x == GRLIB_side_friendly)} count (crew _vehicle) > 0);
if (_towed || _server_owned || (_blu_inside && !(typeOf _vehicle in uavs))) exitWith {};

diag_log format [ "Cleanup vehicle %1 at %2", typeOf _vehicle, time ];

// unTow
[_vehicle] call untow_vehicle;

// Delete R3F Cargo
{ deleteVehicle _x } forEach (_vehicle getVariable ["R3F_LOG_objets_charges", []]);
_vehicle setVariable ["R3F_LOG_objets_charges", [], true];

// Delete GRLIB Cargo
private _truck_load = _vehicle getVariable ["GRLIB_ammo_truck_load", []];
if ( count _truck_load >= 1 ) then {
	{
		if (typeOf _x in [ammobox_b_typename, ammobox_o_typename, ammobox_i_typename, fuelbarrel_typename]) then {
			detach _x;
			sleep 0.2;
			_x setVelocity [([] call F_getRND), ([] call F_getRND), 10];
			sleep (0.5 + floor(random 3));
			_x setDamage 1;
		} else {
			deleteVehicle _x;
		};
	} foreach _truck_load;
};

//Delete A3 Cargo
clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

// Delete Crew
{ moveOut _x; deleteVehicle _x } forEach (crew _vehicle);
_vehicle removeAllEventHandlers "HandleDamage";

// Delete Vehicle
if (_delete) then { deleteVehicle _vehicle };
