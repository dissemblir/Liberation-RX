private _marked_players = [];
private _marked_vehicles = [];
private _marked_squadmates = [];
private _marker_objs = [];
private _color = "";
private _cfg = configFile >> "cfgVehicles";

if ( side player == GRLIB_side_friendly ) then {
	_color = GRLIB_color_friendly;
} else {
	_color = GRLIB_color_enemy;
};

while { true } do {
	waitUntil { sleep 0.5; show_teammates };
	while { show_teammates } do {

		{
			private _nextmarker = _x select 0;
			private _nextobj = _x select 1;
			if ( (isNull _nextobj) || !(alive _nextobj) ) then {
				deleteMarkerLocal _nextmarker;
			};
		} foreach _marker_objs;

		private _playableunits = [];
		if ( count playableUnits > 0 ) then {
			_playableunits = playableUnits;
		} else {
			_playableunits = [ player ];
		};

		{
			if ( vehicle _x == _x ) then {
				_marked_players pushbackUnique _x;
			} else {
				_marked_vehicles pushbackUnique (vehicle _x);
			};
		} foreach _playableunits;

		{
			if ( alive _x && !(isPlayer _x) ) then {
				if ( vehicle _x == _x ) then {
					_marked_squadmates pushbackUnique _x;
				} else {
					_marked_vehicles pushbackUnique (vehicle _x);
				};
			};
		} foreach (units (group player));

		private _stuff_to_unmark = [];
		{
			if ( (vehicle _x != _x) || !(alive _x) || (side group _x != GRLIB_side_friendly) ) then {
				_stuff_to_unmark pushback _x;
				_marked_players = _marked_players - [_x];
			};
		} foreach _marked_players;

		{
			if ( (vehicle _x != _x) || !(alive _x) || (side group _x != GRLIB_side_friendly) ) then {
				_stuff_to_unmark pushback _x;
				_marked_squadmates = _marked_squadmates - [_x];
			};
		} foreach _marked_squadmates;

		{
			if ( !(alive _x) || (count (crew _x) == 0) || (typeOf _x in (uavs + static_vehicles_AI)) ) then {
				_stuff_to_unmark pushback _x;
				_marked_vehicles = _marked_vehicles - [_x];
			};
		} foreach _marked_vehicles;

		{
			private _nextmarker = _x getVariable [ "spotmarker", "" ];
			if ( _nextmarker != "" ) then {
				deleteMarkerLocal _nextmarker;
				_x setVariable [ "spotmarker", "" ];
			};
		} foreach _stuff_to_unmark;

		{
			private _nextplayer = _x;
			private _marker = _nextplayer getVariable [ "spotmarker", "" ];
			if ( _marker == "" ) then {
				_marker = ( createMarkerLocal [ format [ "playermarker%1", (time % 1000) * (floor (random 100)) ], getPosATL _nextplayer ] );
				_marker_objs pushback [ _marker, _nextplayer ];
				_nextplayer setVariable [ "spotmarker", _marker ];

				_playername = [_nextplayer] call get_player_name;
				_marker setMarkerTextLocal _playername;
				_marker setMarkerSizeLocal [ 0.75, 0.75 ];
				_marker setMarkerColorLocal _color;
			};

			private _markertype = "mil_start";
			if (_nextplayer getVariable ["PAR_isUnconscious", false]) then {
				_markertype = "MinefieldAP";
			};
			_marker setMarkerTypeLocal _markertype;
		} foreach _marked_players;

		{
			private _nextai = _x;
			private _marker = _nextai getVariable [ "spotmarker", "" ];

			if ( _marker == "" ) then {
				_marker = ( createMarkerLocal [ format [ "squadaimarker%1", (time % 1000) * (floor (random 10000)) ], getPosATL _nextai ] );
				_marker_objs pushback [ _marker, _nextai ];
				_nextai setVariable [ "spotmarker", _marker ];
				_marker setMarkerTypeLocal "mil_triangle";
				_marker setMarkerSizeLocal [ 0.6, 0.6 ];
				_marker setMarkerColorLocal _color;
			};

			_marker setMarkerTextLocal format [ "%1. %2", [_nextai] call F_getUnitPositionId, name _x];
		} foreach _marked_squadmates;

		{
			private _nextvehicle = _x;
			private _marker = _nextvehicle getVariable [ "spotmarker", "" ];
			if ( _marker == "" ) then {
				_marker = ( createMarkerLocal [ format [ "vehiclemarker%1", (time % 1000) * (floor (random 10000)) ], getPosATL _nextvehicle ] );
				_marker_objs pushback [ _marker, _nextvehicle ];
				_nextvehicle setVariable [ "spotmarker", _marker ];
				_marker setMarkerTypeLocal "mil_arrow2";
				_marker setMarkerSizeLocal [0.75,0.75];
				_marker setMarkerColorLocal _color;
			};

			private _datcrew = crew _nextvehicle;
			private _vehiclename = "";
			{
				if (isPlayer _x) then {
					_vehiclename = _vehiclename + (name _x);
				} else {
					_vehiclename = _vehiclename + (format [ "%1", [_x] call F_getUnitPositionId]);
				};

				if( (_datcrew find _x) != ((count _datcrew) - 1) ) then {
					_vehiclename = _vehiclename + ",";
				};
				_vehiclename = _vehiclename + " ";
			} foreach  _datcrew;

			_vehiclename = _vehiclename + "(" + ([typeOf _nextvehicle] call F_getLRXName) + ")";
			_marker setMarkerTextLocal _vehiclename;
		} foreach _marked_vehicles;

		private _markerunits = [] + _marked_players + _marked_squadmates + _marked_vehicles;
		{
			private _nextunit = _x;
			private _marker = _nextunit getVariable [ "spotmarker", "" ];
			if ( _marker != "" ) then {
				_marker setMarkerPosLocal (getPosATL _nextunit);
				private _mrkdir = getDir _nextunit;
				if ( isPlayer _nextunit ) then {
					if (_nextunit getVariable ["PAR_isUnconscious", false]) then {
						_mrkdir = 0;
					};
				};
				_marker setMarkerDirLocal _mrkdir;
			};
		} foreach _markerunits;

		sleep 1;
	};

	{
		private _nextunit = _x;
		private _marker =  _nextunit getVariable [ "spotmarker", "" ];
		if ( _marker != "" ) then {
			deleteMarkerLocal _marker;
			_nextunit setVariable [ "spotmarker", "" ];
		};
	} forEach ((units GRLIB_side_friendly) + vehicles);
};