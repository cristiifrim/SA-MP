#if defined header
	Ce trebuie sa fac: Separarea adminilor(1-2: Helperi)(3-5:Admini)(6: S.Admin)
					   Separarea VIP: 1-2: VIP(Yellow), 3-4: VIP(Red), 5: S.Vip(red white red)
					   Sistemul de clan in gen RPG
					   Sistemul de Respect Points
					   Sistemul de Factiuni
#endif
//==============================================================================
//Include
//==============================================================================
#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <foreach>
//==============================================================================
//MySQL * Usefull shits
//==============================================================================
#define mysql_host 	"localhost"
#define mysql_user 	"root"
#define mysql_db   	"kogdb"
#define mysql_password 		""
//******************************************************************************
//Dialogs
//******************************************************************************
#define AccD 	1
#define ClanD 	10
#define CarsD   20
#define HouseD  40
#define ServerD 50
#define EventD 60
//------------------------------------------------------------------------------
#pragma tabsize 0
#define MAX_HOUSES                                                              1007
#define MAX_PROPS                                                               134
#define MAX_TERRITORIES                                                         10
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//Colors
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#define                                                 		WHITE       	0xFFFFFFAA
#define                                                 		RED         	0xFF0000AA
#define                                                 		YELLOW      	0xFFFF00AA
#define                                                 		BLUE        	0x0000FFAA
#define                                                 		Blue        	0x0072FFAA
#define                                                 		LBLUE       	0x00BBF6AA
#define                                                 		LIME        	0x00FF00AA
#define                                                 		AQUA        	0x49FFFFAA
#define                                                		 	ORANGE      	0xFF9900AA
#define                                                		 	GREY        	0xCEC8C8AA
#define															Grey			0xAFAFAFAA
#define                                                 		GREEN       	0x33AA33AA
#define                                                         Green           0x05C81FAA
//==============================================================================
//Server & Player Variables
//==============================================================================
enum PlayerInfo
{
	//--------------------------------------------------------------------------
	ID[3],      	Name[24],       	Bank,					Language,       	bool:LoggedIn,
	//--------------------------------------------------------------------------
	SPassword[24],  EMail,              Money,                  Score,              Level,
	//--------------------------------------------------------------------------
	Respect,        Admin,              Vip,                    Coins,              Hours,
	//--------------------------------------------------------------------------
	Minutes,        FailedLogins[3],    Vehicle,                Muted,              MutedTime,
	//--------------------------------------------------------------------------
	Warns,          Float:HousePos[4],  OwnHouse,               Float: PrevPos[4],  AFK,
	//--------------------------------------------------------------------------
	ChatSpam,       CommandSpam,        Month,                  Year,               Day,
	//--------------------------------------------------------------------------
	Line1[150],     Line2[150],         Line3[150],             OwnProp,            Float:PropPos[4],
	//--------------------------------------------------------------------------
	Seconds,        TotalTime,          Job,                	HTDs,				CarTDs
}
//------------------------------------------------------------------------------
enum AdminData
{
	//--------------------------------------------------------------------------
	ID, Bans, Warns, Kicks, Mutes, Jails, Explodes, ChatsCleared, Events, IsRcon
	//--------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
enum HouseData
{
	//--------------------------------------------------------------------------
	ID[3], Locked, Buy, Sell, Owner[24], Text3D: House3d, Float:Pickup[4], Float:Exit[4], Int, Rents
	//--------------------------------------------------------------------------
}
//------------------------------------------------------------------------------
enum PropData
{
	//--------------------------------------------------------------------------
	ID[4], Owner[24], Name[24], Text[24], Text3D: Prop3D, Float: Pickup[4], Float: Exit[4], Int, Income, Buy, Sell, Fare, Class
	//--------------------------------------------------------------------------
}
enum ServerData
{
	bool: InEvent
}
//==============================================================================
new Velocity, String[2048], String2[2048], msQuery[2048], Playa[MAX_PLAYERS][PlayerInfo],
VehicleNames[212][] =
{
	{"Landstalker"},		{"Bravura"},		{"Buffalo"},		{"Linerunner"},
	{"Perrenial"},			{"Sentinel"},		{"Dumper"},			{"Firetruck"},
	{"Trashmaster"},		{"Stretch"},		{"Manana"},			{"Infernus"},
	{"Voodoo"},				{"Pony"},			{"Mule"},			{"Cheetah"},
	{"Ambulance"},			{"Leviathan"},		{"Moonbeam"},		{"Esperanto"},
	{"Taxi"},				{"Washington"},		{"Bobcat"},			{"Mr Whoopee"},
	{"BF Injection"},		{"Hunter"},			{"Premier"},		{"Enforcer"},
	{"Securicar"},			{"Banshee"},		{"Predator"},		{"Bus"},
	{"Rhino"},				{"Barracks"},		{"Hotknife"},		{"Trailer 1"},
	{"Previon"},			{"Coach"},			{"Cabbie"},			{"Stallion"},
	{"Rumpo"},				{"RC Bandit"},		{"Romero"},			{"Packer"},
	{"Monster"},			{"Admiral"},		{"Squalo"},			{"Seasparrow"},
	{"Pizzaboy"},			{"Tram"},			{"Trailer 2"},		{"Turismo"},
	{"Speeder"},			{"Reefer"},			{"Tropic"},			{"Flatbed"},
	{"Yankee"},				{"Caddy"},			{"Solair"},			{"Berkley's RC Van"},
	{"Skimmer"},			{"PCJ-600"},		{"Faggio"},			{"Freeway"},
	{"RC Baron"},			{"RC Raider"},		{"Glendale"},		{"Oceanic"},
	{"Sanchez"},			{"Sparrow"},		{"Patriot"},		{"Quad"},
	{"Coastguard"},			{"Dinghy"},			{"Hermes"},			{"Sabre"},
	{"Rustler"},			{"ZR-350"},			{"Walton"},			{"Regina"},
	{"Comet"},				{"BMX"},			{"Burrito"},		{"Camper"},
	{"Marquis"},			{"Baggage"},		{"Dozer"},			{"Maverick"},
	{"News Chopper"},		{"Rancher"},		{"FBI Rancher"},	{"Virgo"},
	{"Greenwood"},			{"Jetmax"},			{"Hotring"},		{"Sandking"},
	{"Blista Compact"},		{"Police Maverick"},{"Boxville"},		{"Benson"},
	{"Mesa"},				{"RC Goblin"},		{"Hotring Racer A"},{"Hotring Racer B"},
	{"Bloodring Banger"},	{"Rancher"},		{"Super GT"},		{"Elegant"},
	{"Journey"},			{"Bike"},			{"Mountain Bike"},	{"Beagle"},
	{"Cropdust"},			{"Stunt"},			{"Tanker"}, 		{"Roadtrain"},
	{"Nebula"},				{"Majestic"},		{"Buccaneer"},		{"Shamal"},
	{"Hydra"},				{"FCR-900"},		{"NRG-500"},		{"HPV1000"},
	{"Cement Truck"},		{"Tow Truck"},		{"Fortune"},		{"Cadrona"},
	{"FBI Truck"},			{"Willard"},		{"Forklift"},		{"Tractor"},
	{"Combine"},			{"Feltzer"},		{"Remington"},		{"Slamvan"},
	{"Blade"},				{"Freight"},		{"Streak"},			{"Vortex"},
	{"Vincent"},			{"Bullet"},			{"Clover"},			{"Sadler"},
	{"Firetruck LA"},		{"Hustler"},		{"Intruder"},		{"Primo"},
	{"Cargobob"},			{"Tampa"},			{"Sunrise"},		{"Merit"},
	{"Utility"},			{"Nevada"},			{"Yosemite"},		{"Windsor"},
	{"Monster A"},			{"Monster B"},		{"Uranus"},			{"Jester"},
	{"Sultan"},				{"Stratum"},		{"Elegy"},			{"Raindance"},
	{"RC Tiger"},			{"Flash"},			{"Tahoma"},			{"Savanna"},
	{"Bandito"},			{"Freight Flat"},	{"Streak Carriage"},{"Kart"},
	{"Mower"},				{"Duneride"},		{"Sweeper"},		{"Broadway"},
	{"Tornado"},			{"AT-400"},			{"DFT-30"},			{"Huntley"},
	{"Stafford"},			{"BF-400"},			{"Newsvan"},		{"Tug"},
	{"Trailer 3"},			{"Emperor"},		{"Wayfarer"},		{"Euros"},
	{"Hotdog"},				{"Club"},			{"Freight"},		{"Trailer 3"},
	{"Andromada"},			{"Dodo"},			{"RC Cam"},			{"Launch"},
	{"Police Car LSPD"},	{"Police Car SFPD"},{"Police Car LVPD"},{"Police Ranger"},
	{"Picador"},			{"S.W.A.T. Van"},	{"Alpha"},			{"Phoenix"},
	{"Glendale"},			{"Sadler"},			{"Luggage A"},		{"Luggage B"},
	{"Stair Trailer"},		{"Boxville"},		{"Farm Plow"},		{"Utility Trailer"}
}, _Admin[MAX_PLAYERS][AdminData], House[MAX_HOUSES][HouseData], Property[MAX_PROPS][PropData], Server[ServerData], TDString[3][500*3],
Text:Textdraw0,			Text:Textdraw1,			Text:Textdraw2,			Text:Textdraw3,
Text:Textdraw4, 		Text:Textdraw5, 		Text:Textdraw6, 		Text:Textdraw7,
Text:Textdraw8, 		Text:Textdraw9, 		Text:Textdraw10, 		Text:Textdraw11,
Text:Textdraw12, 		Text:ConnectTD,			PlayerText:Textdraw13,  Text:Textdraw14,
Text:Textdraw15,        PlayerText:Textdraw16;
//==============================================================================
//MySQL, Player & Server callbacks
//==============================================================================
forward CheckPlayerLogin(playerid);     forward RegisterHim(playerid, Password[]);      forward SendPlayerID(playerid);
forward KickEx(playerid);               forward CheckPassword(playerid, Password[]);    forward LoadPlayerData(playerid);
forward ReLoadPlayerData(playerid);     forward CheckSPassword(playerid, Password[]);   forward SavePlayerData(playerid);
forward LoadProperties();				forward UnMutePlayer(playerid);                 forward SendMessageToAdmins(mColor, const string[]);
forward LoadHouses();                   forward LoadAdminData(playerid);				forward SendMessageToVips(mColor, const string[]);
forward InsertAdminID(playerid);        forward UpdateTime();
//------------------------------------------------------------------------------
AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}
//------------------------------------------------------------------------------
main(){}
//------------------------------------------------------------------------------
public OnGameModeInit()
{
	new h, m, s, d, mo, y, text[5], str[10]; gettime(h, m, s); getdate(y, d, mo);
	//--------------------------------------------------------------------------
	switch(mo)
	{
	    case 1:  text = "Jan";		case 2:  text = "Feb";		case 3:  text = "Mar";
	    case 4:  text = "Apr";		case 5:  text = "May";	    case 6:  text = "Jun";
	    case 7:  text = "Jul";		case 8:  text = "Aug";		case 9:  text = "Sep";
	    case 10: text = "Oct";		case 11: text = "Nov";		case 12: text = "Dec";
	}
	//==========================================================================
	Velocity = mysql_connect(mysql_host, mysql_user, mysql_db, mysql_password);
	mysql_log(LOG_ALL);
	//==========================================================================
	print("\n::::::::::::::::::::::::::::::::::::\n");  SetWorldTime(14);
	print(":: Romanian Server Name V1 Started ::"	);
	print("\n::::::::::::::::::::::::::::::::::::\n");
	//--------------------------------------------------------------------------
	// -> Server's Settings
	//--------------------------------------------------------------------------
	AntiDeAMX();	  			UsePlayerPedAnims(); 	       SetGameModeText("Stunt-DM-RP-Race-FreeRoam");
	SetWeather(2);       		SendRconCommand("rcon_password 1234");
	AllowInteriorWeapons(true); DisableInteriorEnterExits();   printf("World Time: %d", h);
	SendRconCommand("rcon 0");  EnableStuntBonusForAll(0);     Server[InEvent] = false;
	//--------------------------------------------------------------------------
	//MySQL load
	//--------------------------------------------------------------------------
	for(new hi = 0; hi < MAX_HOUSES; ++hi)
	{
		new clean[HouseData];
		House[hi] = clean;
	}
	//--------------------------------------------------------------------------
	for(new pi = 0; pi < MAX_PROPS; ++pi)
	{
		new clean[PropData];
		Property[pi] = clean;
	}
	//--------------------------------------------------------------------------
	//mysql_tquery(Velocity, "SELECT * FROM `houses`", "LoadHouses", 		"");
	//--------------------------------------------------------------------------
	//mysql_tquery(Velocity, "SELECT * FROM `props`",  "LoadProperties", 	"");
	//--------------------------------------------------------------------------
	// -> Server's Player Class
	//--------------------------------------------------------------------------
	AddPlayerClass(217,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),	AddPlayerClass(122,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(23,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),		AddPlayerClass(28,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(101,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),	AddPlayerClass(115,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(116,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),	AddPlayerClass(53,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(78,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),		AddPlayerClass(134,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(135,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),	AddPlayerClass(137,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(93,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),		AddPlayerClass(192,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(193,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),	AddPlayerClass(12,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(55,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),		AddPlayerClass(91,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    //--------------------------------------------------------------------------
    // -> Server's Textdraws
    //--------------------------------------------------------------------------
    Textdraw0 = TextDrawCreate(17.000000, 420.000000, "Kingdom");	TextDrawBackgroundColor(Textdraw0, 255);
	TextDrawFont(Textdraw0, 0);										TextDrawLetterSize(Textdraw0, 0.619999, 1.800000);
	TextDrawColor(Textdraw0, 7658495);								TextDrawSetOutline(Textdraw0, 0);
	TextDrawSetProportional(Textdraw0, 1);							TextDrawSetShadow(Textdraw0, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw1 = TextDrawCreate(82.000000, 420.000000, "of");		TextDrawBackgroundColor(Textdraw1, 255);
	TextDrawFont(Textdraw1, 0);										TextDrawLetterSize(Textdraw1, 0.619999, 1.800000);
	TextDrawColor(Textdraw1, -65281);								TextDrawSetOutline(Textdraw1, 0);
	TextDrawSetProportional(Textdraw1, 1);							TextDrawSetShadow(Textdraw1, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw2 = TextDrawCreate(102.000000, 420.000000, "Stunt");	TextDrawBackgroundColor(Textdraw2, 255);
	TextDrawFont(Textdraw2, 0);										TextDrawLetterSize(Textdraw2, 0.619999, 1.800000);
	TextDrawColor(Textdraw2, -16776961);							TextDrawSetOutline(Textdraw2, 0);
	TextDrawSetProportional(Textdraw2, 1);							TextDrawSetShadow(Textdraw2, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw3 = TextDrawCreate(29.000000, 437.000000, "]");			TextDrawBackgroundColor(Textdraw3, 255);
	TextDrawFont(Textdraw3, 2);										TextDrawLetterSize(Textdraw3, 0.500000, 1.000000);
	TextDrawColor(Textdraw3, -16776961);							TextDrawSetOutline(Textdraw3, 0);
	TextDrawSetProportional(Textdraw3, 1);							TextDrawSetShadow(Textdraw3, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw4 = TextDrawCreate(48.000000, 437.000000, "Version 1");	TextDrawBackgroundColor(Textdraw4, 255);
	TextDrawFont(Textdraw4, 3);										TextDrawLetterSize(Textdraw4, 0.370000, 1.100000);
	TextDrawColor(Textdraw4, -1);									TextDrawSetOutline(Textdraw4, 0);
	TextDrawSetProportional(Textdraw4, 1);							TextDrawSetShadow(Textdraw4, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw5 = TextDrawCreate(108.000000, 437.000000, "]");		TextDrawBackgroundColor(Textdraw5, 255);
	TextDrawFont(Textdraw5, 2);										TextDrawLetterSize(Textdraw5, 0.500000, 1.000000);
	TextDrawColor(Textdraw5, -16776961);							TextDrawSetOutline(Textdraw5, 0);
	TextDrawSetProportional(Textdraw5, 1);							TextDrawSetShadow(Textdraw5, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw6 = TextDrawCreate(85.000000, 195.000000, "~w~~h~Welcome ~r~~h~on"); TextDrawBackgroundColor(Textdraw6, 255);
	TextDrawFont(Textdraw6, 0);										TextDrawLetterSize(Textdraw6, 0.919999, 1.900000);
	TextDrawColor(Textdraw6, -1);									TextDrawSetOutline(Textdraw6, 0);
	TextDrawSetProportional(Textdraw6, 1);							TextDrawSetShadow(Textdraw6, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw7 = TextDrawCreate(20.000000, 220.000000, "~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]"); TextDrawBackgroundColor(Textdraw7, 255);
	TextDrawFont(Textdraw7, 0);										TextDrawLetterSize(Textdraw7, 0.500000, 1.000000);
	TextDrawColor(Textdraw7, -1);									TextDrawSetOutline(Textdraw7, 0);
	TextDrawSetProportional(Textdraw7, 1);							TextDrawSetShadow(Textdraw7, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw8 = TextDrawCreate(40.000000, 230.000000, "Kingdom");	TextDrawBackgroundColor(Textdraw8, 255);
	TextDrawFont(Textdraw8, 0);										TextDrawLetterSize(Textdraw8, 0.679999, 2.000000);
	TextDrawColor(Textdraw8, 7519231);								TextDrawSetOutline(Textdraw8, 0);
	TextDrawSetProportional(Textdraw8, 1);							TextDrawSetShadow(Textdraw8, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw9 = TextDrawCreate(110.000000, 230.000000, "of");		TextDrawBackgroundColor(Textdraw9, 255);
	TextDrawFont(Textdraw9, 0);										TextDrawLetterSize(Textdraw9, 0.679999, 2.000000);
	TextDrawColor(Textdraw9, -65281);								TextDrawSetOutline(Textdraw9, 0);
	TextDrawSetProportional(Textdraw9, 1);							TextDrawSetShadow(Textdraw9, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw10 = TextDrawCreate(130.000000, 230.000000, "Stunt");	TextDrawBackgroundColor(Textdraw10, 255);
	TextDrawFont(Textdraw10, 0);									TextDrawLetterSize(Textdraw10, 0.679999, 2.000000);
	TextDrawColor(Textdraw10, -16776961);							TextDrawSetOutline(Textdraw10, 0);
	TextDrawSetProportional(Textdraw10, 1);							TextDrawSetShadow(Textdraw10, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw11 = TextDrawCreate(20.000000, 263.000000, "~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]"); TextDrawBackgroundColor(Textdraw11, 255);
	TextDrawFont(Textdraw11, 0);									TextDrawLetterSize(Textdraw11, 0.500000, 1.000000);
	TextDrawColor(Textdraw11, -1);									TextDrawSetOutline(Textdraw11, 0);
	TextDrawSetProportional(Textdraw11, 1);							TextDrawSetShadow(Textdraw11, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Textdraw12 = TextDrawCreate(57.000000, 279.000000, "~w~~h~www.~r~~h~KOS-COMMUNITY~w~~h~.com"); TextDrawBackgroundColor(Textdraw12, 255);
	TextDrawFont(Textdraw12, 2);									TextDrawLetterSize(Textdraw12, 0.360000, 1.400000);
	TextDrawColor(Textdraw12, -1);									TextDrawSetOutline(Textdraw12, 0);
	TextDrawSetProportional(Textdraw12, 1);							TextDrawSetShadow(Textdraw12, 1);
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ConnectTD = TextDrawCreate(249.000000, 417.000000, ""),			TextDrawBackgroundColor(ConnectTD, 255);
	TextDrawFont(ConnectTD, 1),										TextDrawLetterSize(ConnectTD, 0.190000, 1.000000);
	TextDrawColor(ConnectTD, -1),									TextDrawSetOutline(ConnectTD, 0);
	TextDrawSetProportional(ConnectTD, 1),							TextDrawSetShadow(ConnectTD, 1);
	//--------------------------------------------------------------------------
	Textdraw14 = TextDrawCreate(548.000000, 22.000000, "31 Mar");	TextDrawBackgroundColor(Textdraw14, 255);
	TextDrawFont(Textdraw14, 3);									TextDrawLetterSize(Textdraw14, 0.500000, 1.700000);
	TextDrawColor(Textdraw14, -1);                                  TextDrawSetShadow(Textdraw14, 1);
	TextDrawSetOutline(Textdraw14, 0);								TextDrawSetProportional(Textdraw14, 1);
	//--------------------------------------------------------------------------
	Textdraw15 = TextDrawCreate(573.000000, 35.000000, "00:00");	TextDrawBackgroundColor(Textdraw15, 255);
	TextDrawFont(Textdraw15, 2);									TextDrawLetterSize(Textdraw15, 0.500000, 1.700000);
	TextDrawColor(Textdraw15, -1);									TextDrawSetOutline(Textdraw15, 0);
	TextDrawSetProportional(Textdraw15, 1);							TextDrawSetShadow(Textdraw15, 1);
	//--------------------------------------------------------------------------
	format(str, 10, "%02d %s",   d, text);							TextDrawSetString(Textdraw14, str);
	format(str, 6, "%02d:%02d", h, m);								TextDrawSetString(Textdraw15, str);
	//--------------------------------------------------------------------------
	SetTimer("UpdateTime", 60 * 1000, true);
	//--------------------------------------------------------------------------
	return 1;
}

public OnGameModeExit() return mysql_close();

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public OnPlayerRequestClass(playerid, classid)
{
    switch(classid)
	{
	    case 0:  GameTextForPlayer(playerid, "~y~~h~Stunt man", 3000, 6); case 1:  GameTextForPlayer(playerid, "~r~~h~Pirate", 3000, 6); case 2:  GameTextForPlayer(playerid, "~y~~h~Skater", 3000, 6);
	    case 3:  GameTextForPlayer(playerid, "~r~~h~Nigga", 3000, 6);	  case 4:  GameTextForPlayer(playerid, "~y~~h~Civil", 3000, 6);  case 5:  GameTextForPlayer(playerid, "~r~~h~Mafia", 3000, 6);
	    case 6:  GameTextForPlayer(playerid, "~y~~h~Mafia", 3000, 6);     case 7:  GameTextForPlayer(playerid, "~r~~h~Killer", 3000, 6); case 8:  GameTextForPlayer(playerid, "~y~~h~Pops", 3000, 6);
		case 9:  GameTextForPlayer(playerid, "~r~~h~Killer", 3000, 6);    case 10: GameTextForPlayer(playerid, "~y~~h~Killer", 3000, 6); case 11: GameTextForPlayer(playerid, "~y~~h~Z~r~~h~o~y~~h~m~r~~h~b~y~~h~i~r~~h~e", 3000, 6);
	    case 12: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);	  case 13: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);	 case 14: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);
	    case 15: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);	  case 16: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);	 case 17: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);
	}
	//--------------------------------------------------------------------------
    SetPlayerInterior(playerid, 7);							SetPlayerPos(playerid, -1466.5, 1582.0, 1054.3); 			 SetPlayerFacingAngle(playerid, 115.9805);
    SetPlayerCameraPos(playerid, -1471.0, 1579.5, 1055.6);	SetPlayerCameraLookAt(playerid, -1465.5, 1582.5560, 1054.8); ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.0, 1, 0, 0, 0, 0);
    SetPlayerInterior(playerid, 14);                        PlayerPlaySound(playerid, 4204, 0.0, 0.0, 0.0);              SetPlayerAttachedObject(playerid, 0, 19078, 1, 0.329150, -0.072101, 0.156082, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
    //--------------------------------------------------------------------------
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

public OnPlayerConnect(playerid)
{
	new clean[PlayerInfo], rColor = random(9); Playa[playerid] = clean;
	Playa[playerid][Vehicle] = -1;	Playa[playerid][Level] = 1; Playa[playerid][Respect] = 1;
	//==========================================================================
	Textdraw16 = CreatePlayerTextDraw(playerid, 544.000000, 50.000000, "");		PlayerTextDrawBackgroundColor(playerid, Textdraw16, 255);
	PlayerTextDrawFont(playerid, Textdraw16, 2);								PlayerTextDrawLetterSize(playerid, Textdraw16, 0.149999, 1.400000);
	PlayerTextDrawColor(playerid, Textdraw16, -1);								PlayerTextDrawSetOutline(playerid, Textdraw16, 0);
	PlayerTextDrawSetProportional(playerid, Textdraw16, 1);						PlayerTextDrawSetShadow(playerid, Textdraw16, 1);
	//---------------------------------------------------------------------------
	Textdraw13 = CreatePlayerTextDraw(playerid, 150.000000, 250.000000, ""); 	PlayerTextDrawBackgroundColor(playerid, Textdraw13, 255);
	PlayerTextDrawFont(playerid, Textdraw13, 2);								PlayerTextDrawLetterSize(playerid, Textdraw13, 0.320000, 1.300000);
	PlayerTextDrawColor(playerid, Textdraw13, -1);								PlayerTextDrawSetOutline(playerid, Textdraw13, 0);
	PlayerTextDrawSetProportional(playerid, Textdraw13, 1);						PlayerTextDrawSetShadow(playerid, Textdraw13, 1);
    //==========================================================================
	String[0] = '\0';
	format(String, 128, "{FFFFFF}Welcome, {FF0000}%s{FFFFFF}!\nPlease select your language wich you will use to play on this server", SendName(playerid));
	ShowPlayerDialog(playerid, AccD, DIALOG_STYLE_MSGBOX, "Language", String, "Romana", "English");
	//==========================================================================
	switch(rColor)
	{
	    case 0: SetPlayerColor(playerid, 0xFFFFFFAA); case 1: SetPlayerColor(playerid, 0xFF0000AA); case 2: SetPlayerColor(playerid, 0x0072FFAA);
	    case 3: SetPlayerColor(playerid, 0xFFFFFFAA); case 4: SetPlayerColor(playerid, 0x00BBF6AA); case 5: SetPlayerColor(playerid, 0xAFAFAFAA);
	    case 6: SetPlayerColor(playerid, 0xFF9900AA); case 7: SetPlayerColor(playerid, 0xFFEB7BAA); case 8: SetPlayerColor(playerid, 0xFFCC00AA);
	}
	//===========================================================================
	String2[0] = '\0';				format(String2, 30, "%s", SendName(playerid));
	PlayerTextDrawSetString(playerid, Textdraw13, String2); PlayerTextDrawSetString(playerid, Textdraw16, String2);
	//--------------------------------------------------------------------------
	TextDrawShowForPlayer(playerid, Textdraw0);     TextDrawShowForPlayer(playerid, Textdraw1);
	TextDrawShowForPlayer(playerid, Textdraw2);     TextDrawShowForPlayer(playerid, Textdraw3);
	TextDrawShowForPlayer(playerid, Textdraw4);     TextDrawShowForPlayer(playerid, Textdraw5);
	TextDrawShowForPlayer(playerid, Textdraw6);     TextDrawShowForPlayer(playerid, Textdraw7);
	TextDrawShowForPlayer(playerid, Textdraw8);     TextDrawShowForPlayer(playerid, Textdraw9);
	TextDrawShowForPlayer(playerid, Textdraw10);    TextDrawShowForPlayer(playerid, Textdraw11);
	TextDrawShowForPlayer(playerid, Textdraw12);    PlayerTextDrawShow(playerid,	Textdraw13);
	TextDrawShowForPlayer(playerid, Textdraw14);    TextDrawShowForPlayer(playerid, Textdraw15);
	//--------------------------------------------------------------------------
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SendDisconnect(playerid, reason); SavePlayerData(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid, 0), SetPlayerVirtualWorld(playerid, 0), SetPlayerWeather(playerid, 2), SetPlayerHealth(playerid, 100);
    //--------------------------------------------------------------------------
    new rSpawn = random(8); switch(rSpawn)
	{
		case 0: SetPlayerPos(playerid, 404.2386,2453.6709,16.6602		); // AA
		case 1: SetPlayerPos(playerid, 1887.8350,-2625.3059,13.6016		); // LSAir
		case 2: SetPlayerPos(playerid, -1370.0363,-256.3452,18.7700		); // SFAir
		case 3: SetPlayerPos(playerid, 1602.5377,1311.2509,13.6200		); // LVAir
		case 4: SetPlayerPos(playerid, -2345.4111,-1623.9098,483.9355	); // Chilliad
		case 5: SetPlayerPos(playerid, 1420.3746,2773.9958,11.0972      ); // Stunt Golf
		case 6: SetPlayerPos(playerid, -2272.3455,2318.3928,4.5575      ); // Pimps
		case 7: SetPlayerPos(playerid, -2625.1626,1361.3967,7.0816      ); // Jizzy's
	}
	//--------------------------------------------------------------------------
	TextDrawHideForPlayer(playerid, Textdraw6);     TextDrawHideForPlayer(playerid, Textdraw7);
	TextDrawHideForPlayer(playerid, Textdraw8);     TextDrawHideForPlayer(playerid, Textdraw9);
	TextDrawHideForPlayer(playerid, Textdraw10);    TextDrawHideForPlayer(playerid, Textdraw11);
	TextDrawHideForPlayer(playerid, Textdraw12);    PlayerTextDrawHide(playerid,	Textdraw13);
	TextDrawShowForPlayer(playerid, ConnectTD);     PlayerTextDrawShow(playerid,	Textdraw16);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(success == 0)
	{
	    String[0] = '\0'; String2[0] = '\0';
	    //----------------------------------------------------------------------
		format(String,  350, "Comanda {FFFFFF}%s {FF0000}nu exista! Incearca {FFFFFF}/help {FF0000}sau {FFFFFF}/cmds{FF0000}!", cmdtext);
		format(String2, 350, "Command {FFFFFF}%s {FF0000}doesn't exists! Please try {FFFFFF}/help {FF0000}or {FFFFFF}/cmds{FF0000}!", cmdtext);
		//----------------------------------------------------------------------
		return SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? String : String2);
	}
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public OnPlayerCommandReceived(playerid, cmdtext[])
{
	new STime;
	//--------------------------------------------------------------------------
	if(Playa[playerid][AFK] == 1 && !IsPlayerAdmin(playerid) && strcmp(cmdtext, "back", true) == -1)	return GameTextForPlayer(playerid, "~w~~h~Type ~r~~h~/back~n~~w~~h~to use~n~~r~~h~Commands~w~~h~!", 4000, 4), 0;
	if(Playa[playerid][LoggedIn] == false)                                                              return ErrorMessages(playerid, 6), 0;
	//--------------------------------------------------------------------------
	if(Playa[playerid][Vip] <= 5)
	    if(Playa[playerid][Vip] < 3)
	        if(gettime() - Playa[playerid][CommandSpam] < 2)
	        {
				if(gettime() - Playa[playerid][CommandSpam] == 0) 		STime = 2;
				else if(gettime() - Playa[playerid][CommandSpam] == 1) 	STime = 1;
				//--------------------------------------------------------------
	 			format(String, 128, "ERROR: Please wait {FFFFFF}%d {FF0000}second(s) to use a command again!", STime);
				format(String2, 128,"ERROR: Te rog sa astepti {FFFFFF}%d{FF0000}secunde ca sa folosesti iar o comanda!", STime);
			 	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1)?String2:String);
				//--------------------------------------------------------------
				return 0;
			}
			else Playa[playerid][CommandSpam] = gettime();
        else if(Playa[playerid][Vip] < 4)
	        if(gettime() - Playa[playerid][CommandSpam] < 1)
	        {
				if(gettime() - Playa[playerid][CommandSpam] == 0) 	STime = 1;
				//--------------------------------------------------------------
	 			format(String, 128, "ERROR: Please wait {FFFFFF}%d {FF0000}second(s) to use a command again!", STime);
				format(String2, 128,"ERROR: Te rog sa astepti {FFFFFF}%d{FF0000} secund(a/e) ca sa folosesti iar o comanda!", STime);
			 	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1)?String2:String);
				//--------------------------------------------------------------
				return 0;
			}
			else Playa[playerid][CommandSpam] = gettime();
	//--------------------------------------------------------------------------
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public OnPlayerText(playerid, text[])
{
	new STime;
	//--------------------------------------------------------------------------
	if(Playa[playerid][AFK] == 1 || Playa[playerid][LoggedIn] == false || Playa[playerid][Muted] == 1)
	{
		if(Playa[playerid][Muted] == 1) 	return SendClientMessage(playerid, RED, "ERROR: You can't talk, you're muted!");
		else if(Playa[playerid][AFK] == 1)  if(!IsPlayerAdmin(playerid)) return GameTextForPlayer(playerid, "~w~~h~Type ~r~~h~/back~n~~w~~h~to use the~n~~r~~h~Chat~w~~h~!", 4000, 4), 0;
		ErrorMessages(playerid, 6);
	}
	if(Playa[playerid][Vip] <= 5)
	    if(Playa[playerid][Vip] <= 4)
	    	//------------------------------------------------------------------
	        if(Playa[playerid][Vip] <= 3)
	            if(gettime() - Playa[playerid][ChatSpam] < 3)
	            {
	                if(gettime() - Playa[playerid][ChatSpam] == 0) 		STime = 3;
	                else if(gettime() - Playa[playerid][ChatSpam] == 1) STime = 2;
	                else if(gettime() - Playa[playerid][ChatSpam] == 2) STime = 1;
					//----------------------------------------------------------
					format(String, 128, "ERROR: Please wait {FFFFFF}%d {FF0000}second(s) to write something again!", STime);
					format(String2, 128,"ERROR: Te rog sa astepti {FFFFFF}%d {FF0000}secunde ca sa scrii din nou pe chat!", STime);
					SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1)?String2:String);
					//----------------------------------------------------------
					return 0;
				}
				else Playa[playerid][ChatSpam] = gettime();
   			//------------------------------------------------------------------
			else if(Playa[playerid][Vip] <= 4)
   				if(gettime() - Playa[playerid][ChatSpam] < 2)
	            {
	                if(gettime() - Playa[playerid][ChatSpam] == 1) 		STime = 2;
	                else if(gettime() - Playa[playerid][ChatSpam] == 2) STime = 1;
					//----------------------------------------------------------
					format(String, 128, "ERROR: Please wait {FFFFFF}%d {FF0000}second(s) to write something again!", STime);
					format(String2, 128,"ERROR: Te rog sa astepti {FFFFFF}%d {FF0000}secunde ca sa scrii din nou pe chat!", STime);
					SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1)?String2:String);
					//----------------------------------------------------------
					return 0;
				}
				else Playa[playerid][ChatSpam] = gettime();
            //------------------------------------------------------------------
			else if(Playa[playerid][Vip] <= 5)
   				if(gettime() - Playa[playerid][ChatSpam] < 1)
	            {
	                 if(gettime() - Playa[playerid][ChatSpam] == 2) STime = 1;
					//----------------------------------------------------------
					format(String, 128, "ERROR: Please wait {FFFFFF}%d {FF0000}second(s) to write something again!", STime);
					format(String2, 128,"ERROR: Te rog sa astepti {FFFFFF}%d {FF0000}secunde ca sa scrii din nou pe chat!", STime);
					SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1)?String2:String);
					//----------------------------------------------------------
					return 0;
				}
				else Playa[playerid][ChatSpam] = gettime();
	//--------------------------------------------------------------------------
	if(text[0] == '#' && Playa[playerid][Vip] > 1)
	{
	    format(String, 150, "VIP Chat: {FF4400}%s: {15FF00}%s", SendName(playerid), text[1]); SendMessageToVips(ORANGE, String);
	    return 0;
	}
	//--------------------------------------------------------------------------
	else if(text[0] == '@' && Playa[playerid][Admin] > 1)
	{
	    format(String, 150, "Admin Chat: {FF4400}%s: {15FF00}%s", SendName(playerid), text[1]); SendMessageToAdmins(ORANGE, String);
	    return 0;
	}
	//--------------------------------------------------------------------------
	if(strcmp(SendName(playerid), "[KOS]NeaCristy", true) == 0)
	{
	    format(String, 500, "%s{FF0000}({FFFFFF}Owner{FF0000}){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(IsPlayerAdmin(playerid) && Playa[playerid][Admin] > 0)
	{
	    format(String, 500, "%s{FF0000}({FFFFFF}RCON{FF0000}){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Admin] > 0)
	{
	    format(String, 500, "%s{FF0000}(Helper){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Admin] > 2)
	{
	    format(String, 500, "%s{FF0000}(Admin){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Admin] > 5)
	{
	    format(String, 500, "%s{FF0000}(S.Admin){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Vip] > 0)
	{
	    format(String, 500, "%s{FFFF00}(VIP){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Vip] > 2)
	{
	    format(String, 500, "%s{FF0000}(VIP){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	else if(Playa[playerid][Vip] > 4)
	{
	    format(String, 500, "%s{FF0000}({FFFFFF}S.VIP{FF0000}){FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
		return 0;
	}
	//--------------------------------------------------------------------------
	format(String, 500, "%s{FFFFFF}(%d): %s", SendName(playerid), playerid, text); SendClientMessageToAll(GetPlayerColor(playerid), String); SetPlayerChatBubble(playerid, text, RED, 70.0, 5000);
    //--------------------------------------------------------------------------
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case AccD: //Language
	    {
	        if(response)
	        {
        		Playa[playerid][Language] = 1; msQuery[0] = '\0';
				mysql_format(Velocity, msQuery, 256, "SELECT * FROM `accounts` WHERE `Name` = '%s' LIMIT 1", SendName(playerid));
				mysql_tquery(Velocity, msQuery, "CheckPlayerLogin", "d", playerid);
			}
			else
	        {
        		Playa[playerid][Language] = 0; msQuery[0] = '\0';
				mysql_format(Velocity, msQuery, 256, "SELECT * FROM `accounts` WHERE `Name` = '%s' LIMIT 1", SendName(playerid));
				mysql_tquery(Velocity, msQuery, "CheckPlayerLogin", "d", playerid);
			}
		}
	    case AccD + 1:  //Register
	    {
	        if(response)
	        {
	            if(strlen(inputtext) < 5 || strlen(inputtext) > 24)
	                switch(Playa[playerid][Language])
	                {
	                    case 0: ShowPlayerDialog(playerid, AccD + 1, DIALOG_STYLE_PASSWORD, "Account Registration", "{FFFFFF}You have introduced a wrong password!\n Please enter a strong password between {FF0000}5 - 24 {FFFFFF}characters!", "Done", "Cancel");
	                    case 1: ShowPlayerDialog(playerid, AccD + 1, DIALOG_STYLE_PASSWORD, "Inregistrarea Contului", "{FFFFFF}Ai introdus o parola gresita!\ne rugam sa introduci o parola puternica de {FF0000}5 - 24 {FFFFFF}caractere!", "Gata", "Anuleaza");
					}
				RegisterHim(playerid, inputtext);
			}
			else SetTimerEx("KickEx", 50, false, "d", playerid);
		}
		case AccD + 2:  //Login
		{
		    if(response)
		    {   msQuery[0] = '\0';
				mysql_format(Velocity, msQuery, 256, "SELECT * FROM `accounts` WHERE `Name` = '%s' AND `Password` = SHA1('%s')", SendName(playerid), inputtext);
				mysql_pquery(Velocity, msQuery, "CheckPassword", "d", playerid);
			}
			else
				if(Playa[playerid][Language] == 0)
				{   String[0] = '\0'; format(String, 128, "{FFFFFF}Hi, {FF0000}%s{FFFFFF}!\nPlease enter your new name before:\n", SendName(playerid));
				    ShowPlayerDialog(playerid, AccD + 4, DIALOG_STYLE_INPUT, "New Name", String, "Done", "Cancel");
				}
				else if(Playa[playerid][Language] == 1)
				{
				    String[0] = '\0'; format(String, 128, "{FFFFFF}Salut, {FF0000}%s{FFFFFF}!\nTe rog sa-ti introduci noul tau nume inainte:\n", SendName(playerid));
				    ShowPlayerDialog(playerid, AccD + 4, DIALOG_STYLE_INPUT, "Nume Nou", String, "Gata", "Anuleaza");
				}
		}
		case AccD + 4: //New Name
		{
		    if(!response) SetTimerEx("KickEx", 50, false, "d", playerid);
		    else
      			if(strlen(inputtext) < 1 || strlen(inputtext) > 24)
		            if(Playa[playerid][Language] == 0)
					{   String[0] = '\0'; format(String, 128, "{FFFFFF}Hi, {FF0000}%s{FFFFFF}!\nPlease enter your new name before:\n", SendName(playerid));
				    	ShowPlayerDialog(playerid, AccD + 4, DIALOG_STYLE_INPUT, "New Name", String, "Done", "Cancel");
					}
					else if(Playa[playerid][Language] == 1)
					{
					    String[0] = '\0'; format(String, 128, "{FFFFFF}Salut, {FF0000}%s{FFFFFF}!\nTe rog sa-ti introduci noul tau nume inainte:\n", SendName(playerid));
					    ShowPlayerDialog(playerid, AccD + 4, DIALOG_STYLE_INPUT, "Nume Nou", String, "Gata", "Anuleaza");
					}
				else { SetPlayerName(playerid, inputtext); return OnPlayerConnect(playerid); }
		}
		case HouseD:
		{
		    if(!response) return 1;
		    else
		    {
		        switch(listitem)
		        {
		            case 0: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/buy"	);
		            case 1: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/sell"	);
		            case 2: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/lock"	);
		            case 3: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/enter"	);
		            case 4: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/visit"	);
		            case 5: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/exit"	);
		            case 6: CallRemoteFunction("OnPlayerCommandText", "is", playerid, "/myhouse");
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	return 1;
}
//==============================================================================
//Commands
//==============================================================================
CMD:saveall(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	    for(new i = 1, l = GetPlayerPoolSize(); i <= l; ++i)
	        if(IsPlayerConnected(i)) SavePlayerData(i);
	return 1;
}
CMD:querry(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
	    String[0] = '\0';
		format(String, 64, "Unfinalized Queryes: %d\nServer Ticks: %d", mysql_unprocessed_queries(Velocity), GetServerTickRate());
		SendClientMessage(playerid, WHITE, String);
	}
	return 1;
}
CMD:car(playerid, params[])
{
	//--------------------------------------------------------------------------
	new Param1[40], Param2[4], Param3[4], vID[3], Color1, Color2, Float: X, Float: Y, Float: Z, Float:Angle, interior; String[0] = '\0';
	//--------------------------------------------------------------------------
	new RoError1[50]  = "ERROR: Vehicul inexistent!";           new EnError1[50]  = "ERROR: Inexistent vehicle!";
	new RoError2[150] = "ERROR: Nu poti spawna acest vehicul!"; new EnError2[150] = "ERROR: You can't spawn this vehicle!";
 	//--------------------------------------------------------------------------
 	if(sscanf(params, "s[40]S()[4]S()[4]", Param1, Param2, Param3)) return cmd_v(playerid);
	//--------------------------------------------------------------------------
	if(!IsNumeric(Param1))		vID[1] = GetIDFromName(Param1);
	else						vID[1] = strval(Param1);
	//--------------------------------------------------------------------------
	if(vID[1] < 400 || vID[1] > 611) return
	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError1 : EnError1);
	//--------------------------------------------------------------------------
	else if(vID[1] == 432 && !IsPlayerAdmin(playerid)) return
	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError2 : EnError2);
	//--------------------------------------------------------------------------
	else if(vID[1] == 425 && !IsPlayerAdmin(playerid)) return
	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError2 : EnError2);
	//--------------------------------------------------------------------------
	else if(vID[1] == 520 && !IsPlayerAdmin(playerid)) return
	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError2 : EnError2);
	//--------------------------------------------------------------------------
	else if(vID[1] == 447 && !IsPlayerAdmin(playerid)) return
	SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError2 : EnError2);
	//--------------------------------------------------------------------------
	if(!strlen(Param2)) Color1 = random(126); else Color1 = strval(Param2);
	if(!strlen(Param3)) Color2 = random(126); else Color2 = strval(Param3);
	//--------------------------------------------------------------------------
	if(IsPlayerInAnyVehicle(playerid)) return ErrorMessages(playerid, 11);
	if(Playa[playerid][Vehicle] != -1) EraseVeh(Playa[playerid][Vehicle]);
	//--------------------------------------------------------------------------
	GetPlayerPos(playerid, X, Y, Z);    GetPlayerFacingAngle(playerid, Angle);
	interior = GetPlayerInterior(playerid);
	//--------------------------------------------------------------------------
	vID[2] = CreateVehicle(vID[1], X, Y, Z+3, Angle, Color1, Color2, -1);   SetVehicleNumberPlate(vID[2], "{00BB72}K{FFFF00}O{FF0000}S");
	LinkVehicleToInterior(vID[2], interior);    PutPlayerInVehicle(playerid, vID[2], 0);   Playa[playerid][Vehicle] = vID[2];
	//--------------------------------------------------------------------------
	format(String, 1000, "You spawned a {FF0000}%s {FFFFFF}(Model: {FF0000}%d{FFFFFF}) with Colors: {FF0000}%d, %d", VehicleNames[vID[1]-400], vID[1], Color1, Color2);
	SendClientMessage(playerid, WHITE, String);
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:v(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return ErrorMessages(playerid, 11);
	//--------------------------------------------------------------------------
	return ShowPlayerDialog(playerid, CarsD, DIALOG_STYLE_TABLIST_HEADERS, "Vehicles", "Type\tDescription\n{FF0000}Bikes\t{FFFFFF}A list with server's bikes.\n\
																						{FF0000}Cars\t{FFFFFF}A list with server's cars.\n\
																						{FF0000}Helicopters\t{FFFFFF}A list with server's helicopters.\n\
																						{FF0000}Motorbikes\t{FFFFFF}A list with server's motorbikes.\n\
																						{FF0000}Planes\t{FFFFFF}A list with server's planes.\n\
																						{FF0000}Special Vehicles\t{FFFFFF}A list with special vehicles such as RC or custom vehicles", "Select", "Cancel");
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:nrg(playerid)
{
	new color1 = random(126), color2 = random(126), Float: X, Float: Y, Float: Z, Float:Angle, Interior, NRG; String[0] = '\0';
	//--------------------------------------------------------------------------
	if(IsPlayerInAnyVehicle(playerid)) return ErrorMessages(playerid, 11);
	if(Playa[playerid][Vehicle] != -1) EraseVeh(Playa[playerid][Vehicle]);
	//--------------------------------------------------------------------------
	GetPlayerPos(playerid, X, Y, Z); GetPlayerFacingAngle(playerid, Angle); Interior = GetPlayerInterior(playerid);
	//--------------------------------------------------------------------------
	NRG = CreateVehicle(522, X, Y, Z, Angle, color1, color2, -1);   SetVehicleToRespawn(NRG);
	LinkVehicleToInterior(NRG, Interior);   PutPlayerInVehicle(playerid, NRG, 0);  Playa[playerid][Vehicle] = NRG;
	format(String, 1000, "You spawned a {FF0000}NRG {FFFFFF}(Model: {FF0000}522{FFFFFF}) with Colors: {FF0000}%d, %d", color1, color2);
	SendClientMessage(playerid, WHITE, String);
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:stats(playerid, params[])
{
	/*new tID;
	//--------------------------------------------------------------------------
	if(!sscanf(params, "d", tID))
	    if(IsPlayerConnected(tID)) 	return ShowPlayerDialog(playerid, AccD + 7, DIALOG_STYLE_MSGBOX, "Player Statistics", ShowStats(tID), "Close", "");
	    else 						return ERROR_NC(playerid);
	else return ShowPlayerDialog(playerid, AccD + 7, DIALOG_STYLE_MSGBOX, "Player Statistics", ShowStats(playerid), "Close", "Edit");*/
	return GameTextForPlayer(playerid, "Coming Soon", 4000, 1);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:ls(playerid) 		  return TPlayer(playerid, "Los Santos", "ls", 1513.560424,-1661.583984,14.546875, 0);
CMD:sf(playerid)          return TPlayer(playerid, "San Fierro", "sf", -1973.069213,289.765106,36.171875, 0);
CMD:lv(playerid)          return TPlayer(playerid, "Las Venturas", "lv", 2130.4495,1435.5546,10.8203, 0);
CMD:lsair(playerid)       return TPlayer(playerid, "Los Santos Airport", "lsair", 1887.8350,-2625.3059,13.6016, 0);
CMD:sfair(playerid)       return TPlayer(playerid, "San Fierro Airport", "sfair", -1212.1760,11.5719,14.1484, 0);
CMD:lvair(playerid)       return TPlayer(playerid, "Las Venturas Airport", "lvair", 1602.5377,1311.2509,13.6200, 0);
CMD:aa(playerid)          return TPlayer(playerid, "Old Airport", "aa", 404.2386,2453.6709,16.6602, 0);
CMD:vinewood(playerid)    return TPlayer(playerid, "Vinewood", "vinewood", 1413.2775,-871.3857,46.9813, 0);
CMD:grove(playerid)       return TPlayer(playerid, "Grove Street", "grove", 2495.180664,-1686.387329,14.513671, 0);
CMD:mc(playerid)          return TPlayer(playerid, "Mount Chilliad", "mc", -2345.4111,-1623.9098,483.9355, 0);
CMD:pimps(playerid)       return TPlayer(playerid, "Pimps", "pimps", -2272.3455,2318.3928,4.5575, 0);
CMD:vw(playerid)          return cmd_vinewood(playerid);
CMD:beach(playerid)       return TPlayer(playerid, "Santa Maria Beach", "beach", 426.0493,-1905.3248,1.3379, 0);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:help(playerid, params[])
{
    String[0] = '\0'; String2[0] = '\0';
    //--------------------------------------------------------------------------
    format(String2, 200, "{FFFFFF}Hello, {FF0000}%s{FFFFFF}! Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{FFFFFF}.\n\n", SendName(playerid));
    strcat(String, String2);
    strcat(String, "{FF0000}General information:\n\
                    {FFFFFF}Our server is a {FF0000}Stunt{FFFFFF} server combined with {FF0000}RPG{FFFFFF} elements.\n\
                    {FFFFFF}One of them, as you see, is the {FF0000}Account Level {FFFFFF}system, wich is a key system for some of server's systems.\n\
                    {FFFFFF}At level 5 you can have your own {FF0000}personal car {FFFFFF}wich can be bought by {FF0000}coins{FFFFFF}.\n\n", 1900);
    strcat(String, "{FF0000}Account Activity:\n\
                    {FFFFFF}Everytime a hour passes, you'll get your {FF0000}payday{FFFFFF}. What means that?\n\
                    {FFFFFF}You'll get a {FF0000}Respect Point{FFFFFF} wich will help you to advance in level.\n\
                    {FFFFFF}Your online time will be saved from connect time till now.\n\
                    {FFFFFF}You'll recieve some coins and some money!\n\n", 1900);
    strcat(String, "{FF0000}Usefull commands:\n\
                    {FFFFFF}/{FF0000}cmds{FFFFFF}  - Shows you a list with all server's commands.\n\
                    {FFFFFF}/{FF0000}rules{FFFFFF} - Shows you server's rules and allowed programs/mods.\n\
                    {FFFFFF}/{FF0000}teles{FFFFFF} - Shows you a list with all server's zones.\n\
                    {FFFFFF}/{FF0000}car{FFFFFF}(/v) - Shows you a list with all server's cars.\n\n", 1900);
    format(String2, 200, "{FFFFFF}Thank you, {FF0000}%s{FFFFFF} for playing on our server. We're honored to serve you. Be nice and {FF0000}have fun{FFFFFF}!\n", SendName(playerid));
    strcat(String, String2);
    strcat(String, "{FFFFFF}And, don't forget! If you have a dilemma, use {FF0000}/n{FFFFFF} to ask a question to our admins!\n");
    return ShowPlayerDialog(playerid, ServerD + 1, DIALOG_STYLE_MSGBOX, "Server Help", String, "Close", "");
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:credits(playerid, params[])
{
	String[0] = '\0'; String2[0] = '\0';
	//--------------------------------------------------------------------------
	strcat(String, "{FF0000}Owners:\n{FFFFFF}[KOS]NeaCristy\n\n\
	                {FF0000}Developer:\n{FFFFFF}[KOS]NeaCristy\n\n\
	                {FF0000}Mapping:\n{FFFFFF}Still no one\n\n", 500);
	strcat(String, "{FF0000}Website & Forum\n{FFFFFF}Invision Power Board\n[KOS]NeaCristy\n\n\
	                {FF0000}Special Thanks:\n{FFFFFF}SA-MP Team for SA-MP Client.\n\
	                {FFFFFF}ZeeX for ZCMD command processor.\nY_Less for SSCanf and YNI.\n\
	                {FFFFFF}pBlueG for MySQL plugin and include.\n\n", 500);
	format(String2, 200, "{FF0000}%s{FFFFFF} for being the best player and playing on our server.\nWe're honored to serve you! ", SendName(playerid));
	strcat(String, String2);
	strcat(String, "{FFFFFF}Be nice and {FF0000}have fun {FFFFFF}!");
	//--------------------------------------------------------------------------
	return ShowPlayerDialog(playerid, ServerD, DIALOG_STYLE_MSGBOX, "Server Credits", String, "Close", "");
}
//==============================================================================
//House & Property system
//==============================================================================
CMD:buy(playerid)
{
	new hi = IsInHousePickup(playerid), pID = IsInPropertyPickup(playerid); msQuery[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Hours] < 10)                   return ErrorMessages(playerid, 5);
	//--------------------------------------------------------------------------
	if(Playa[playerid][OwnHouse] == 1)                return SendClientMessage(playerid, RED, "ERROR: You already have a house!"	);
	if(Playa[playerid][OwnProp]  == 1)                return SendClientMessage(playerid, RED, "ERROR: You already have a property!"	);
	//--------------------------------------------------------------------------
	if(hi != -1)
	{
	    if(Playa[playerid][Coins] < House[playerid][Buy]) return ErrorMessages(playerid, 5);
	    if(strcmp(House[hi][Owner], "ForSale", true) == 0)
	    {
	        format(House[hi][Owner], 24, SendName(playerid));   DestroyDynamic3DTextLabel(House[hi][House3d]);
	        DestroyPickup(House[hi][ID][2]);					Playa[playerid][OwnHouse] = 1;
	        //------------------------------------------------------------------
	        Playa[playerid][HousePos][1] = House[hi][Pickup][1];    Playa[playerid][HousePos][2] = House[hi][Pickup][2];    Playa[playerid][HousePos][3] = House[hi][Pickup][3];
	        //------------------------------------------------------------------
	        Playa[playerid][Coins] -= House[hi][Buy];
	        //------------------------------------------------------------------
			mysql_format(Velocity, msQuery, 256, "UPDATE `houses` SET `Owner` = '%s' WHERE `ID` = '%d'", SendName(playerid), hi);
			mysql_pquery(Velocity, msQuery);
			//------------------------------------------------------------------
			return UpdateHouse(hi), GameTextForPlayer(playerid, "~w~~h~House ~g~~h~~h~Bought", 4000, 4);
		}
		else return SendClientMessage(playerid, RED, "ERROR: This house is already bought!");
	}
	else if(pID != -1)
	{
	    if(Playa[playerid][Coins] < Property[playerid][Buy]) return ErrorMessages(playerid, 5);
	    if(strcmp(Property[pID][Owner], "ForSale", true) == 0)
	    {
	        format(Property[pID][Owner], 24, SendName(playerid));   DestroyDynamic3DTextLabel(Property[pID][Prop3D]);
	        DestroyPickup(Property[pID][ID][2]);    DestroyDynamicMapIcon(Property[pID][ID][3]);    Playa[playerid][OwnProp] = 1;
	        //------------------------------------------------------------------
	        Playa[playerid][PropPos][1] = Property[pID][Pickup][1];     Playa[playerid][PropPos][2] = Property[pID][Pickup][2];     Playa[playerid][PropPos][3] = Property[pID][Pickup][3];
	        //------------------------------------------------------------------
	        Playa[playerid][Coins] -= Property[pID][Buy];   format(Property[pID][Text], 24, SendName(playerid));
	        //------------------------------------------------------------------
	        mysql_format(Velocity, msQuery, 256, "UPDATE `props` SET `Owner` = '%s', `Text` = '%s' WHERE `ID` = '%d'", SendName(playerid), SendName(playerid), pID);
			mysql_pquery(Velocity, msQuery);
			//------------------------------------------------------------------
			return UpdateProp(pID), GameTextForPlayer(playerid, "~w~~h~Property ~g~~h~~h~Bought", 4000, 4);
		}
		else return SendClientMessage(playerid, RED, "ERROR: This property is already bought!");
	}
	else return ErrorMessages(playerid, 15);
}
CMD:sell(playerid)
{
	new hi = IsInHousePickup(playerid), pID = IsInPropertyPickup(playerid); msQuery[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][OwnHouse] == 0)                	 return SendClientMessage(playerid, RED, "ERROR: You don't own a house!"   );
	if(Playa[playerid][OwnProp]  == 0)               	 return SendClientMessage(playerid, RED, "ERROR: You don't own a property!");
	//--------------------------------------------------------------------------
	if(hi != -1)
	{
	    if(strcmp(House[hi][Owner], SendName(playerid), true) == 0 || IsPlayerAdmin(playerid))
	    {
	        format(House[hi][Owner], 24, "ForSale");   DestroyDynamic3DTextLabel(House[hi][House3d]);
	        DestroyPickup(House[hi][ID][2]);		   Playa[playerid][OwnHouse] = 0;   House[hi][Locked] = 1;
	        //------------------------------------------------------------------
	        Playa[playerid][HousePos][1]  = Playa[playerid][HousePos][2] = Playa[playerid][HousePos][3] = 0;
	        //------------------------------------------------------------------
			Playa[playerid][Coins] += House[hi][Sell];
			//------------------------------------------------------------------
			mysql_format(Velocity, msQuery, 256, "UPDATE `houses` SET `Owner` = 'ForSale', `Locked` = '1' WHERE `ID` = '%d'", hi);
			mysql_pquery(Velocity, msQuery);
			//------------------------------------------------------------------
			return UpdateHouse(hi), GameTextForPlayer(playerid, "~w~~h~House ~g~~h~~h~Sold", 4000, 4);
		}
		else return SendClientMessage(playerid, RED, "ERROR: This house isn't yours!");
	}
	else if(pID != -1)
	{
	    if(strcmp(Property[pID][Owner], SendName(playerid), true) == 0 || IsPlayerAdmin(playerid))
	    {
	        format(Property[pID][Owner], 24, "ForSale");    DestroyDynamic3DTextLabel(Property[pID][Prop3D]);
	        DestroyPickup(Property[pID][ID][2]);    		DestroyDynamicMapIcon(Property[pID][ID][3]); 	Playa[playerid][OwnProp] = 0;
	        //------------------------------------------------------------------
	        Playa[playerid][PropPos][1]     = Playa[playerid][PropPos][2]   = Playa[playerid][PropPos][3]	= 0;
	        //------------------------------------------------------------------
	        Playa[playerid][Coins] += Property[pID][Sell]; format(Property[pID][Text], 24, Property[pID][Name]);
	        //------------------------------------------------------------------
	        mysql_format(Velocity, msQuery, 256, "UPDATE `houses` SET `Owner` = 'ForSale', `Text` = '%s' WHERE `ID` = '%d'", pID, Property[pID][Name]);
			mysql_pquery(Velocity, msQuery);
			//------------------------------------------------------------------
			return UpdateProp(pID), GameTextForPlayer(playerid, "~w~~h~Property ~g~~h~~h~Sold", 4000, 4);
		}
		else return SendClientMessage(playerid, RED, "ERROR: This property isn't yours!");
	}
	else return ErrorMessages(playerid, 15);
}
CMD:house(playerid)
{
	new hi = IsInHousePickup(playerid); String[0] = '\0'; String2[0] = '\0';
	//--------------------------------------------------------------------------
	if(hi != -1)
	{
		if(Playa[playerid][Language] == 1)
		{
		    strcat(String, "Actiune\tComanda\tOptional\n");
		    format(String2, 64, "{FFFFFF}Cumpara casa\t{FF0000}/buy\t{FFFFFF}%d Coins\n", House[hi][Buy]);
		    strcat(String, String2);
		    //------------------------------------------------------------------
		    if(strcmp(House[hi][Owner], SendName(playerid)) == 0)
		    	format(String2, 64, "{FFFFFF}Vinde casa\t{FF0000}/sell\t{FFFFFF}%d Coins\n", House[hi][Sell]),
				strcat(String, String2);
			else
			    strcat(String, "{FFFFFF}Vinde casa\t{FF0000}/sell\n");
			//------------------------------------------------------------------
			strcat(String, "{FFFFFF}Incuie sau descuie casa\t{FF0000}/lock\n");
			strcat(String, "{FFFFFF}Intra in casa\t{FF0000}/enter\n");
			strcat(String, "{FFFFFF}Viziteaza casa\t{FF0000}/visit\n");
			strcat(String, "{FFFFFF}Paraseste casa\t{FF0000}/exit\n");
			strcat(String, "{FFFFFF}Teleporteaza-te la casa ta\t{FF0000}/myhouse\n");
		}
		else
		{
		    strcat(String, "Action\tCommand\tOptional\n");
		    format(String2, 64, "{FFFFFF}Buy house\t{FF0000}/buy\t{FFFFFF}%d Coins\n", House[hi][Buy]);
		    strcat(String, String2);
        	//------------------------------------------------------------------
		    if(strcmp(House[hi][Owner], SendName(playerid)) == 0)
		    	format(String2, 64, "{FFFFFF}Sell house\t{FF0000}/sell\t{FFFFFF}%d Coins\n", House[hi][Sell]),
				strcat(String, String2);
			else
   				strcat(String, "{FFFFFF}Sell house\t{FF0000}/sell\n");
       		//------------------------------------------------------------------
			strcat(String, "{FFFFFF}Lock or unlock house\t{FF0000}/lock\n");
			strcat(String, "{FFFFFF}Enter the house\t{FF0000}/enter\n");
			strcat(String, "{FFFFFF}Visit house\t{FF0000}/visit\n");
			strcat(String, "{FFFFFF}Exit house\t{FF0000}/exit\n");
			strcat(String, "{FFFFFF}Teleport to your house\t{FF0000}/myhouse\n");
		}
		return ShowPlayerDialog(playerid, HouseD, DIALOG_STYLE_TABLIST_HEADERS, "House system", String, "Select", "Close");
	}
	else return ErrorMessages(playerid, 15);
}
CMD:lock(playerid)
{
	new hi = IsInHousePickup(playerid), Ro1[30] = "Ai incuiat casa.", Ro2[30] = "Ai descuiat casa.", En1[30] = "You have locked the house.", En2[30] = "You have unlocked the house";
	//--------------------------------------------------------------------------
	if(Playa[playerid][OwnHouse] == 0)							return SendClientMessage(playerid, RED, "ERROR: You don't own a house!	");
	//--------------------------------------------------------------------------
	if(hi != -1)
	{
	    if(strcmp(House[hi][Owner], SendName(playerid)) == -1)	return SendClientMessage(playerid, RED, "ERROR: This house isn't yours!	");
	    else
	        if(House[hi][Locked] == 1) 	return House[hi][Locked] = 0, SendClientMessage(playerid, WHITE, (Playa[playerid][Language] == 0)?En2:Ro2);
	        else 						return House[hi][Locked] = 1, SendClientMessage(playerid, WHITE, (Playa[playerid][Language] == 0)?En1:Ro1);
	}
	else return ErrorMessages(playerid, 15);
}
CMD:enter(playerid)
{
	new hi = IsInHousePickup(playerid), pID = IsInPropertyPickup(playerid);
	//--------------------------------------------------------------------------
	if(hi != -1)
	    if(House[hi][Locked] == 0 || House[hi][Locked] == 1 && strcmp(House[hi][Owner], SendName(playerid)) == 0)
		{
			SetPlayerInterior(playerid, House[hi][Int]); SetPlayerPos(playerid, House[hi][Exit][1], House[hi][Exit][2], House[hi][Exit][3]);
			return Playa[playerid][PrevPos][1] = House[hi][Pickup][1], Playa[playerid][PrevPos][2] = House[hi][Pickup][2], Playa[playerid][PrevPos][3] = House[hi][Pickup][3], GameTextForPlayer(playerid, "~r~~h~Welcome!", 2000, 4);
		}
		else return SendClientMessage(playerid, RED, "ERROR: This house is locked");
	else if(pID != -1)
	    if(Playa[playerid][Coins] < Property[pID][Fare]) return ErrorMessages(playerid, 14);
	    else
	    {
	        SetPlayerInterior(playerid, Property[pID][Int]); SetPlayerPos(playerid, Property[pID][Exit][1], Property[pID][Exit][2], Property[pID][Exit][3]), Playa[playerid][Coins] -= Property[pID][Fare];
	        return Playa[playerid][PrevPos][1] = Property[pID][Pickup][1], Playa[playerid][PrevPos][2] = Property[pID][Pickup][2], Playa[playerid][PrevPos][3] = Property[pID][Pickup][3], GameTextForPlayer(playerid, "~r~~h~Welcome!", 2000, 4);
		}
	else return ErrorMessages(playerid, 15);
}
CMD:exit(playerid)
{
	if(Playa[playerid][PrevPos][1] == 0 && Playa[playerid][PrevPos][2] == 0 && Playa[playerid][PrevPos][3] == 0) return SendClientMessage(playerid, RED, "You're not in a house/property");
	//--------------------------------------------------------------------------
	else SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, Playa[playerid][PrevPos][1], Playa[playerid][PrevPos][2], Playa[playerid][PrevPos][3]), Playa[playerid][PrevPos][1] = Playa[playerid][PrevPos][2] = Playa[playerid][PrevPos][3] = 0;
	return 1;
}
CMD:visit(playerid)
{
	new hi = IsInHousePickup(playerid);
	//--------------------------------------------------------------------------
	if(hi != -1)
	    if(House[hi][Locked] == 0 || House[hi][Locked] == 1 && strcmp(House[hi][Owner], "ForSale") == 0)
		{
			SetPlayerInterior(playerid, House[hi][Int]); SetPlayerPos(playerid, House[hi][Exit][1], House[hi][Exit][2], House[hi][Exit][3]); Playa[playerid][Coins] -= 10; GivePlayerMoney(playerid, -15000);
			return Playa[playerid][PrevPos][1] = House[hi][Pickup][1], Playa[playerid][PrevPos][2] = House[hi][Pickup][2], Playa[playerid][PrevPos][3] = House[hi][Pickup][3], SendClientMessage(playerid, WHITE, "You have been taxed with 10 coins and 15000 cash for visiting this house before buying it!");
		}
		else return SendClientMessage(playerid, RED, "ERROR: This house is not allowed to be visited.");
	else return ErrorMessages(playerid, 15);
}
CMD:myhouse(playerid)
{
	if(Playa[playerid][OwnHouse] == 1) return SetPlayerPos(playerid, Playa[playerid][HousePos][1], Playa[playerid][HousePos][2], Playa[playerid][HousePos][3]);
	else return SendClientMessage(playerid, RED, "ERROR: You don't own a house!");
}
CMD:myh(playerid) return cmd_myhouse(playerid);
CMD:myproperty(playerid)
{
	if(Playa[playerid][OwnProp] == 1) return SetPlayerPos(playerid, Playa[playerid][PropPos][1], Playa[playerid][PropPos][2], Playa[playerid][PropPos][3]);
	else return SendClientMessage(playerid, RED, "ERROR: You don't own a property!");
}
CMD:myp(playerid) return cmd_myproperty(playerid);
//==============================================================================
//Admin Commands
//==============================================================================
//Level 1
//==============================================================================
CMD:cc(playerid)
{
	if(Playa[playerid][Admin] < 1) return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	for(new i = 0; i <= 20; ++i) SendClientMessageToAll(WHITE, "");
	//--------------------------------------------------------------------------
	++_Admin[playerid][ChatsCleared]; SendCommandToAdmins(playerid, "ClearChat");
	//--------------------------------------------------------------------------
	return 1;
}
CMD:clearchat(playerid) return cmd_cc(playerid);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:mute(playerid, params[])
{
	new targetid, reason[50]; String[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 1) 				   	return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	if(sscanf(params, "uS()[50]", targetid, reason))return SendClientMessage(playerid, LBLUE, "USAGE: /Mute [PlayerID][Reason]");
	//--------------------------------------------------------------------------
	if(!IsPlayerConnected(targetid))                return ERROR_NC(playerid);
	if(Playa[targetid][Admin] != 0)                 return SendClientMessage(playerid, RED, "ERROR: This player is an Admin!");
	if(Playa[targetid][Muted] == 1)                 return SendClientMessage(playerid, RED, "ERROR: This player is all ready muted!");
	//--------------------------------------------------------------------------
	Playa[playerid][MutedTime] = SetTimerEx("UnMutePlayer", 180000, false, "i", targetid); Playa[playerid][Muted] = 1; SendCommandToAdmins(playerid, "Mute");
	++_Admin[playerid][Mutes]; format(String, 389, "Admin {FF0000}%s {FFFFFF}has muted {FF0000}%s {FFFFFF}for 3 minutes. Reason: {FF0000}%s{FFFFFF}.", SendName(playerid), SendName(targetid), reason);
	//--------------------------------------------------------------------------
	return SendClientMessageToAll(WHITE, String);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:unmute(playerid, params[])
{
	new targetid; String[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 1) 				   	return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	if(sscanf(params, "u", targetid))				return SendClientMessage(playerid, LBLUE, "USAGE: /UnMute [PlayerID]");
	//--------------------------------------------------------------------------
	if(!IsPlayerConnected(targetid))                return ERROR_NC(playerid);
	if(Playa[targetid][Muted] == 0)                 return SendClientMessage(playerid, RED, "ERROR: This player is not Muted!");
	//--------------------------------------------------------------------------
	UnMutePlayer(playerid); SendCommandToAdmins(playerid, "UnMute");
	format(String, 389, "Admin {FF0000}%s {FFFFFF}has unmuted {FF0000}%s{FFFFFF}.", SendName(playerid), SendName(targetid));
	//--------------------------------------------------------------------------
	return SendClientMessageToAll(WHITE, String);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CMD:disarm(playerid, params[])
{
	new targetid; String[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 1) 				   	return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	if(sscanf(params, "u", targetid))				return SendClientMessage(playerid, LBLUE, "USAGE: /Disarm [PlayerID]");
	//--------------------------------------------------------------------------
	if(!IsPlayerConnected(targetid))                return ERROR_NC(playerid);
	//--------------------------------------------------------------------------
	SendCommandToAdmins(playerid, "Disarm");        ResetPlayerWeapons(playerid);
	format(String, 64, "{FF0000}%s {FFFFFF}has disarmed you!", SendName(playerid)); SendClientMessage(targetid, WHITE, String);
	return 1;
}
//==============================================================================
//Level 2
//==============================================================================
CMD:warn(playerid, params[])
{
	new targetid, reason[50]; String[0] = '\0'; String2[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 2) 				   	return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	if(sscanf(params, "uS()[50]", targetid, reason))return SendClientMessage(playerid, LBLUE, "USAGE: /Warn [PlayerID][Reason]");
	//--------------------------------------------------------------------------
	if(!IsPlayerConnected(targetid))                return ERROR_NC(playerid);
	if(Playa[targetid][Admin] != 0)                 return ErrorMessages(playerid, 9);
	if(targetid == playerid)                        return ErrorMessages(playerid, 9);
	//--------------------------------------------------------------------------
	++Playa[targetid][Warns]; ++_Admin[playerid][Warns]; SendCommandToAdmins(playerid, "Warn");
	format(String, 389, "Admin {FF0000}%s {FFFFFF}has warned {FF0000}%s {FFFFFF}. Reason: {FF0000}%s{FFFFFF}.({FF0000}%d{FFFFFF}/{FF0000}3{FFFFFF})", SendName(playerid), SendName(targetid), reason, Playa[targetid][Warns]);
	SendClientMessageToAll(WHITE, String2);
	//--------------------------------------------------------------------------
	if(Playa[targetid][Warns] == 3) format(String2, 389, "{FF0000}%s {FFFFFF}has been kicked. Reason: {FF0000}Excesive warnings{FFFFFF}({FF0000}3{FFFFFF}/{FF0000}3{FFFFFF})", SendName(targetid)),
	SendClientMessageToAll(WHITE, String2), SetTimerEx("KickEx", 50, false, "d", targetid);
	return 1;
}
CMD:kick(playerid, params[])
{
	new targetid, reason[50]; String[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 3) 				   	return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	if(sscanf(params, "uS()[50]", targetid, reason))return SendClientMessage(playerid, LBLUE, "USAGE: /Kick [PlayerID][Reason]");
	//--------------------------------------------------------------------------
	if(!IsPlayerConnected(targetid))                return ERROR_NC(playerid);
	if(Playa[targetid][Admin] != 0)                 return ErrorMessages(playerid, 9);
	if(targetid == playerid)                        return ErrorMessages(playerid, 9);
	//--------------------------------------------------------------------------
	++_Admin[playerid][Kicks]; SendCommandToAdmins(playerid, "Kick");
	format(String, 389, "Admin {FF0000}%s {FFFFFF}has kicked {FF0000}%s {FFFFFF}. Reason: {FF0000}%s{FFFFFF}.", SendName(playerid), SendName(targetid), reason); SetTimerEx("KickEx", 50, false, "i", targetid);
	//--------------------------------------------------------------------------
	return SendClientMessageToAll(playerid, String);
}
//==============================================================================
CMD:event(playerid, params[])
{
	String[0] = '\0';
	//--------------------------------------------------------------------------
	if(Playa[playerid][Admin] < 2)              return ErrorMessages(playerid, 3);
	//--------------------------------------------------------------------------
	else return ShowPlayerDialog(playerid, EventD, DIALOG_STYLE_TABLIST_HEADERS, "Event", "Event Type \tDescription\n\
																						  {FFFFFF}Hidden Object\t{FF0000}Place a star and let players find it to win the prize.\n\
																						  {FFFFFF}Plane\t{FF0000}Last Man standing on the plane will win the prize.\n\
																						  {FFFFFF}Reaction Test\t{FF0000}Creates a random text and who will text it first wins.\n\
																						  {FFFFFF}Math test\t{FF0000}Creates a random ecuation that need to be solved to win the prize.\n\
																						  {FF0000}Who makes most Kills\t{FFFFFF}Who makes the most kills at one /dm wins the prize.\n\
																						  {FF0000}Who says first\t{FFFFFF}The winner is that player who says first the word:.\n\
																						  {FF0000}Q&A\t{FFFFFF}Who types the answer of a question wins the prize.", "Select", "Close");
}


CMD:set(playerid, params[])
{
	new pID, rParam[10], Amount; String[0] = '\0'; msQuery[0] = '\0';
	if(sscanf(params, "s[10]ui", rParam, pID, Amount)) return SendClientMessage(playerid, RED, "USAGE: {49FFFF}/set [Time/Weather/Money/Health] [ID] [Amount]");
	//----------------------------------------------------------------------
	else if(!IsPlayerConnected(pID)) 		  	return ERROR_NC(playerid);
	//----------------------------------------------------------------------
	/*if(strcmp(rParam, "time", 		true) 	== 0)   						 SetPlayerTime(pID, Amount, 0), format(String, 200, "Administrator {FF0000}%s {FFFFFF}has setted you {FF0000}Time %d{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Time"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	if(strcmp(rParam, "weather", 	true) 	== 0)   						 SetPlayerWeather(pID, Amount), format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}Weather %d{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Weather"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	if(strcmp(rParam, "coins", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Coins] 	 = 		Amount, format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}%d Coins{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Coins"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	//if(strcmp(rParam, "stunt", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Stunt] 	 = 		Amount, format(String, 200, "Administrator %s has setted you %d Stunt Points!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set StuntP"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	//if(strcmp(rParam, "drift", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Drift] 	 = 		Amount, format(String, 200, "Administrator %s has setted you %d Drift Points!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set DriftP"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	//if(strcmp(rParam, "race", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Race] 		 = 		Amount, format(String, 200, "Administrator %s has setted you %d Race Points!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set RaceP"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	if(strcmp(rParam, "vip", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Vip] 		 = 		Amount, format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}VIP Level %d{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set VIP"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	//if(strcmp(rParam, "c4", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][C4] 		 = 		Amount, format(String, 200, "Administrator %s has setted you %d C4s!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set C4"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	//if(strcmp(rParam, "respect+", 	true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Respect][1] = 		Amount, format(String, 200, "Administrator %s has setted you %d Respect(+)!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Respect+"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
//	if(strcmp(rParam, "respect-", 	true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Respect][2] = 		Amount, format(String, 200, "Administrator %s has setted you %d Respect(-)!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Respect-"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	if(strcmp(rParam, "hours", 		true) 	== 0 && IsPlayerAdmin(playerid)) Playa[pID][Hours] 	 = 		Amount, format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}%d Online Time{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Hours"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
	if(strcmp(rParam, "money", 		true) 	== 0 && IsPlayerAdmin(playerid)) ResetPlayerMoney(pID), GivePlayerMoney(pID, Amount), format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}%d Money{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Money"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
 */if(strcmp(rParam, "admin", 		true) 	== 0 && IsPlayerAdmin(playerid))
	{
		 Playa[pID][Admin] = Amount, format(String, 200, "Administrator {FF0000}%s has setted you {FF0000}Admin Level %d{FFFFFF}!", SendName(playerid), Amount), SendClientMessage(pID, WHITE, String), SendCommandToAdmins(playerid, "Set Level"), PlayerPlaySound(pID,1057,0.0,0.0,0.0);
		 if(Playa[playerid][Admin] == 0 && Amount > 0)
		 	mysql_format(Velocity, msQuery, 256, "INSERT INTO `admindata`(`Name`) VALUES ('%s')", SendName(pID)),
			mysql_tquery(Velocity, msQuery, "InsertAdminID", "d", playerid);
	     else if(Playa[playerid][Admin] != 0 && Amount == 0)
			mysql_format(Velocity, msQuery, 256, "DELETE FROM `admindata` WHERE `ID` = '%d'", _Admin[playerid][ID]),
		 	mysql_tquery(Velocity, msQuery);
	}
	//----------------------------------------------------------------------
	return 1;
}
//==============================================================================
SendName(playerid)
{
	new name[MAX_PLAYER_NAME];
	//--------------------------------------------------------------------------
	GetPlayerName(playerid, name, sizeof(name));
	//--------------------------------------------------------------------------
	return name;
}
SendIP(playerid)
{
	new IP[30];
	//--------------------------------------------------------------------------
	GetPlayerIp(playerid, IP, 30);
	//--------------------------------------------------------------------------
	return IP;
}
//==============================================================================
//Login * Register
//==============================================================================
public CheckPlayerLogin(playerid)
{
	if(!cache_get_row_count())
	    switch(Playa[playerid][Language])
	    {
	        case 0:
	        {
				String[0] = '\0';
				format(String, 256, "{FFFFFF}Hello, {FFFF00}%s {FFFFFF}!\nYour account isn't registered on our database. Please enter a strong password between {FF0000}5 - 24 {FFFFFF}characters!",
    			SendName(playerid));
				ShowPlayerDialog(playerid, AccD + 1, DIALOG_STYLE_PASSWORD, "Account Registration", String, "Register", "New Name");
			}
			case 1:
			{
			    String[0] = '\0';
			    format(String, 256, "{FFFFFF}Salut, {FF0000}%s {FFFFFF}!\nContul tau nu este inregistrat in baza noastra de date. Te rugam sa introduci o parola puternica de {FF0000}5 - 24 {FFFFFF}caractere!",
		 		SendName(playerid));
			    ShowPlayerDialog(playerid, AccD + 1, DIALOG_STYLE_PASSWORD, "Inregistrarea Contului", String, "Inregistreaza", "Nume Nou");
			}
		}
	else
	    switch(Playa[playerid][Language])
	    {
	        case 0:
	        {
	        	String[0] = '\0';
	        	format(String, 256, "{FFFFFF}Welcome back, {FF0000}%s {FFFFFF}!\nGlad to see you love this server but please introduce your password to continue.", SendName(playerid));
	        	ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Account Login", String, "Login", "New Name");
			}
			case 1:
			{
			    String[0] = '\0';
			    format(String, 256, "{FFFFFF}Bine ai revenit, {FF0000}%s {FFFFFF}!\nMa bucur sa vad ca iubesti acest server dar te rog sa-ti introduci parola ca sa continui.", SendName(playerid));
			    ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Autentificare", String, "Autentificare", "Nume Nou");
			}
		}
	return 1;
}
public RegisterHim(playerid, Password[])
{
	new y, mo, d; String[0] = '\0'; String2[0] = '\0'; msQuery[0] = '\0'; getdate(y, mo, d);
	//--------------------------------------------------------------------------
	mysql_format(Velocity, msQuery, 256, "INSERT INTO `accounts`(`Name`, `Password`) VALUES ('%s', SHA1('%s'))", SendName(playerid), Password);
	mysql_pquery(Velocity, msQuery); Playa[playerid][LoggedIn] = true;
	//--------------------------------------------------------------------------
	msQuery[0] = '\0';
	mysql_format(Velocity, msQuery, 256, "UPDATE `accounts` SET `IP` = '%s' WHERE `Name` = '%s'", SendIP(playerid), SendName(playerid));
	mysql_pquery(Velocity, msQuery);
	//--------------------------------------------------------------------------
	format(Playa[playerid][EMail], 10, "None"); format(Playa[playerid][SPassword], 10, "-1");
	ResetPlayerMoney(playerid); GivePlayerMoney(playerid, 50000); SetPlayerScore(playerid, 1); Playa[playerid][Respect] = 1; Playa[playerid][Level] = 1;
	Playa[playerid][Day] = d; Playa[playerid][Month] = mo; Playa[playerid][Year] = y;   SendConnect(playerid);
	//--------------------------------------------------------------------------
 	msQuery[0] = '\0';
	mysql_format(Velocity, msQuery, 256, "SELECT * FROM `accounts` WHERE `Name` = '%s'", SendName(playerid));
	mysql_tquery(Velocity, msQuery, "SendPlayerID", "d", playerid);
	//--------------------------------------------------------------------------
	if(Playa[playerid][Language] == 0)
	{
		//----------------------------------------------------------------------
		format(String2, 50, "{FFFFFF}Hi, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
		strcat(String, String2);
		strcat(String, "{FFFFFF}You have registered on {00BBF6}Romanian {FFFF00}Server {FF0000}Name {FFFFFF}!\n");
		format(String2, 128, "{FFFFFF}Remember! When you'll come back, you will need to login with the password: {00FF00}%s{FFFFFF}.\n", Password);
		strcat(String, String2);
		strcat(String, "{FFFFFF}To use commands or write on the chat, press 'T' or 'F6'.\n\n");
		strcat(String, "{FFFFFF}For more informations, click on {FF0000}Help {FFFFFF}button.\n");
		strcat(String, "{FFFFFF}And, don't forget to visit our website & forum at {FF0000}www.SITE-NAME.com{FFFFFF}!\n");
		strcat(String, "{FFFFFF}Have fun!\n");
		//----------------------------------------------------------------------
		return ShowPlayerDialog(playerid, AccD + 3, DIALOG_STYLE_MSGBOX, "Successfully registered!", String, "HELP", "Close");
	}
	else if(Playa[playerid][Language] == 1)
	{
	    //----------------------------------------------------------------------
	    format(String2, 50, "{FFFFFF}Salut, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
	    strcat(String, String2);
	    strcat(String, "{FFFFFF}Te-ai inregistrat pe serverul {00BBF6}Romanian {FFFF00}Server {FF0000}Name{FFFFFF}!\n");
		format(String2, 128, "{FFFFFF}Nu uita! Cand vei reveni, va trebui sa te loghezi cu parola: {00FF00}%s{FFFFFF}.\n", Password);
		strcat(String, String2);
		strcat(String, "{FFFFFF}Ca sa folosesti comenzi sau sa scrii pe chat, apasa 'T' ori 'F6'.\n\n");
		strcat(String, "{FFFFFF}Pentru mai multe informatii, apasa pe butonul {FF0000}Ajutor{FFFFFF}.\n");
		strcat(String, "{FFFFFF}Si, nu uita sa vizitez website-ul & forumul nostru la {FF0000}www.SITE-NAME.com{FFFFFF}!\n");
		strcat(String, "{FFFFFF}Distreaza-te!\n");
		//----------------------------------------------------------------------
		return ShowPlayerDialog(playerid, AccD + 3, DIALOG_STYLE_MSGBOX, "Inregistrare Reusita!", String, "AJUTOR", "Inchide");
	}
	//--------------------------------------------------------------------------
	return 1;
}
public SendPlayerID(playerid)
{
	if(cache_get_row_count(Velocity))
	    Playa[playerid][ID][1]       = cache_get_field_content_int(0, "ID",       Velocity);
}
public CheckPassword(playerid, Password[])
{
    String[0] = '\0'; String2[0] = '\0'; msQuery[0] = '\0'; new query[2];
    //--------------------------------------------------------------------------
    cache_get_data(query[0], query[1], Velocity);
    //--------------------------------------------------------------------------
    if(!query[0])
    {
        if(Playa[playerid][Language] == 0)
		{
  			++Playa[playerid][FailedLogins][1];
		    //------------------------------------------------------------------
		    format(String2, 500, "{FF0000}Login failed (%d/4)!\n\n{FFFFFF}You have entered a wrong password! Please try again!\nIf you forgot your password, visit {FF0000}www.XSW-Servers.com {FFFFFF}to reset it!", Playa[playerid][FailedLogins][1]),
		    strcat(String, String2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Account Login", String, "Login", "New Name");
		}
		else if(Playa[playerid][Language] == 1)
		{
		    ++Playa[playerid][FailedLogins][1];
  			//------------------------------------------------------------------
		    format(String2, 500, "{FF0000}Autentificare esuata (%d/4)!\n\n{FFFFFF}Ai introdus o parola gresita! Te rugam sa incerci din nou!\nDaca ti-ai uitat parola, viziteaza {FF0000}www.XSW-Servers.com {FFFFFF}pentru a o reseta!", Playa[playerid][FailedLogins][1]);
		    strcat(String, String2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Autentificare", String, "Autentificare", "Nume Nou");
		}
		if(Playa[playerid][FailedLogins][1] == 4)
		{
			format(String2, 300, "*** {FF0000}%s {CEC8C8}has been kicked {FF0000}(Failed Logins)! {CEC8C8}***", SendName(playerid)),
			//------------------------------------------------------------------
			SendClientMessageToAll(GREY, String2), SetTimerEx("KickEx", 50, false, "d", playerid);
		}
		return 0;
	}
	mysql_format(Velocity, msQuery, 300, "SELECT * FROM `accounts` WHERE `Name` = '%s'", SendName(playerid));
	mysql_pquery(Velocity, msQuery, "LoadPlayerData", "d", playerid);
	return 1;
}
public CheckSPassword(playerid, Password[])
{
    String[0] = '\0'; String2[0] = '\0'; msQuery[0] = '\0'; new query[2];
    //--------------------------------------------------------------------------
    cache_get_data(query[0], query[1], Velocity);
    //--------------------------------------------------------------------------
    if(!query[0])
    {
        if(Playa[playerid][Language] == 0)
		{
  			++Playa[playerid][FailedLogins][2];
		    //------------------------------------------------------------------
		    format(String2, 500, "{FF0000}Login failed (%d/4)!\n\n{FFFFFF}You have entered a wrong password! Please try again!\nIf you forgot your password, visit {FF0000}www.XSW-Servers.com {FFFFFF}to reset it!", Playa[playerid][FailedLogins][2]),
		    strcat(String, String2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Account Login", String, "Login", "New Name");
		}
		else if(Playa[playerid][Language] == 1)
		{
		    ++Playa[playerid][FailedLogins][2];
  			//------------------------------------------------------------------
		    format(String2, 500, "{FF0000}Autentificare esuata (%d/4)!\n\n{FFFFFF}Ai introdus o parola gresita! Te rugam sa incerci din nou!\nDaca ti-ai uitat parola, viziteaza {FF0000}www.XSW-Servers.com {FFFFFF}pentru a o reseta!", Playa[playerid][FailedLogins][2]);
		    strcat(String, String2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccD + 2, DIALOG_STYLE_PASSWORD, "Autentificare", String, "Autentificare", "Nume Nou");
		}
		if(Playa[playerid][FailedLogins][2] == 4)
		{
			format(String2, 300, "*** {FF0000}%s {CEC8C8}has been kicked {FF0000}(Failed Logins)! {CEC8C8}***", SendName(playerid)),
			//------------------------------------------------------------------
			SendClientMessageToAll(GREY, String2), SetTimerEx("KickEx", 50, false, "d", playerid);
		}
		return 0;
	}
	mysql_format(Velocity, msQuery, 300, "SELECT * FROM `accounts` WHERE `Name` = '%s'", SendName(playerid));
	mysql_pquery(Velocity, msQuery, "ReLoadPlayerData", "d", playerid);
	return 1;
}
public LoadPlayerData(playerid)
{
    SendConnect(playerid);
	//----------------------------------------------------------------------
	String[0] = '\0'; String2[0] = '\0'; msQuery[0] = '\0';
	//--------------------------------------------------------------------------
	cache_get_field_content(0, "SPassword", Playa[playerid][SPassword], Velocity, 24);
	//--------------------------------------------------------------------------
	if(strcmp(Playa[playerid][SPassword], "-1", true) == -1)
	{
 		if(Playa[playerid][Language] == 1)      ShowPlayerDialog(playerid, AccD + 5, DIALOG_STYLE_PASSWORD, "Autentificare", "{FF0000}Acest cont are o parola secundara!\n{FFFFFF}Autentifica-te cu parola secundara pentru a putea continua!\n\nScrie mai jos {FF0000}Parola Secundara{FFFFFF}:", "Autentificare", "Renunta");
		//----------------------------------------------------------------------
		else if(Playa[playerid][Language] == 0) ShowPlayerDialog(playerid, AccD + 5, DIALOG_STYLE_PASSWORD, "Login", "{FF0000}This account has a secondary password!\n{FFFFFF}Please login with the secondary password in order to continue!\n\nEnter below the {FF0000}Secondary Password{FFFFFF}:", "Login", "Quit");
	}
	//--------------------------------------------------------------------------
	else
	{
	    Playa[playerid][LoggedIn] = true; 		ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid,   cache_get_field_content_int(0, 			"Money", 	Velocity));
		SetPlayerScore(playerid,    cache_get_field_content_int(0, 			"Score",  	Velocity));
		printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
	    //----------------------------------------------------------------------
	    cache_get_field_content(0,  "E-Mail",   Playa[playerid][EMail],     		Velocity,   150);
	    //----------------------------------------------------------------------
		//----------------------------------------------------------------------
	    Playa[playerid][ID][1]		=   	cache_get_field_content_int(0,  "ID", 		Velocity);
	    Playa[playerid][Level]	    =		cache_get_field_content_int(0,  "Level",   	Velocity);
	    Playa[playerid][Coins]      =		cache_get_field_content_int(0,  "Coins",    Velocity);
	    Playa[playerid][Vip]		=	    cache_get_field_content_int(0,  "VIP",      Velocity);
	    Playa[playerid][Admin]		=		cache_get_field_content_int(0,  "Admin",    Velocity);
	    Playa[playerid][Respect]	=		cache_get_field_content_int(0,  "Respect",  Velocity);
	    Playa[playerid][Hours]      =		cache_get_field_content_int(0,  "Hours",    Velocity);
	    Playa[playerid][Minutes]	=		cache_get_field_content_int(0,  "Minutes",  Velocity);
	    Playa[playerid][Day]        =       cache_get_field_content_int(0,  "Day",      Velocity);
	    Playa[playerid][Month]      =       cache_get_field_content_int(0,  "Month",    Velocity);
	    Playa[playerid][Year]       =       cache_get_field_content_int(0,  "Year",     Velocity);
	    printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
	    printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
	    if(Playa[playerid][Admin] > 0)
			mysql_format(Velocity, msQuery, 256, "SELECT * FROM `admindata` WHERE `Name` = '%s'", SendName(playerid)),
			mysql_pquery(Velocity, msQuery, "LoadAdminData", "d", playerid);
  		printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
		//----------------------------------------------------------------------
		for(new hi = 0; hi < MAX_HOUSES; ++hi)
		    if(strcmp(House[hi][Owner], SendName(playerid)) == 0)
			{
				Playa[playerid][OwnHouse] = 1;
	    		Playa[playerid][HousePos][1] = House[hi][Pickup][1];    Playa[playerid][HousePos][2] = House[hi][Pickup][2];    Playa[playerid][HousePos][3] = House[hi][Pickup][3];
			}
        printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
		//----------------------------------------------------------------------
		for(new pID = 0; pID < MAX_PROPS; ++pID)
		    if(strcmp(Property[pID][Owner], SendName(playerid)) == 0)
			{
				Playa[playerid][OwnProp] = 1;
	    		Playa[playerid][PropPos][1] = Property[pID][Pickup][1];    Playa[playerid][PropPos][2] = Property[pID][Pickup][2];    Playa[playerid][PropPos][3] = Property[pID][Pickup][3];
			}
		//----------------------------------------------------------------------
		switch(Playa[playerid][Language])
		{
		    case 0:
			{
			    format(String2, 50, "{FFFFFF}Hello, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
				strcat(String, String2);
				strcat(String, "{FFFFFF}You have been logged in succesfuly!\n\n");
				//--------------------------------------------------------------
				if(Playa[playerid][Admin] > 0)
				{
					format(String2, 50, "{FFFFFF}Admin: {00FF00}Yes {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Admin]);
					strcat(String, String2);
				}
				else strcat(String, "{FFFFFF}Admin: {00FF00}No\n");
				//--------------------------------------------------------------
				if(Playa[playerid][Vip] > 0)
				{
					format(String2, 50, "{FFFFFF}VIP: {00FF00}Yes {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Vip]);
					strcat(String, String2);
				}
				else strcat(String, "{FFFFFF}VIP: {00FF00}No\n");
				//--------------------------------------------------------------
				format(String2, 150, "{FFFFFF}Level: {00FF00}%d\n", Playa[playerid][Level]);
				strcat(String, String2);
				format(String2, 150, "{FFFFFF}Respect Points: {00FF00}%d{FFFFFF}/{00FF00}%d\n\n", Playa[playerid][Respect], Playa[playerid][Level] * 3);
				strcat(String, String2);
				strcat(String, "{FFFFFF}For more statistics, use {FF0000}/stats{FFFFFF}.\n\n");
				//--------------------------------------------------------------
				return ShowPlayerDialog(playerid, AccD + 6, DIALOG_STYLE_MSGBOX, "Account", String, "Ok", "");
			}
			case 1:
			{
			    format(String2, 50, "{FFFFFF}Buna, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
				strcat(String, String2);
				strcat(String, "{FFFFFF}Ai fost autentificat cu succes!\n\n");
				//--------------------------------------------------------------
				if(Playa[playerid][Admin] > 0)
				{
					format(String2, 50, "{FFFFFF}Admin: {00FF00}Da {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Admin]);
					strcat(String, String2);
				}
				else strcat(String, "{FFFFFF}Admin: {00FF00}Nu\n");
				//--------------------------------------------------------------
				if(Playa[playerid][Vip] > 0)
				{
					format(String2, 50, "{FFFFFF}VIP: {00FF00}Da {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Vip]);
					strcat(String, String2);
				}
				else strcat(String, "{FFFFFF}VIP: {00FF00}Nu\n");
				//--------------------------------------------------------------
				format(String2, 150, "{FFFFFF}Level: {00FF00}%d\n", Playa[playerid][Level]);
				strcat(String, String2);
				format(String2, 150, "{FFFFFF}Respect Points: {00FF00}%d{FFFFFF}/{00FF00}%d\n\n", Playa[playerid][Respect], Playa[playerid][Level] * 3);
				strcat(String, String2);
				strcat(String, "{FFFFFF}Pentru mai multe statistici, foloseste {FF0000}/stats{FFFFFF}.\n\n");
				//--------------------------------------------------------------
				return ShowPlayerDialog(playerid, AccD + 6, DIALOG_STYLE_MSGBOX, "Contul meu", String, "Inchide", "");
			}
		}
	}
	printf("Level: %d Respect: %d \n", Playa[playerid][Level], Playa[playerid][Respect]);
	return 1;
}
public ReLoadPlayerData(playerid)
{
    SendConnect(playerid);
    //--------------------------------------------------------------------------
	String[0] = '\0'; String2[0] = '\0';
	//--------------------------------------------------------------------------
    Playa[playerid][LoggedIn] = true; 		ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid,   cache_get_field_content_int(0, 			"Money", 	Velocity));
	SetPlayerScore(playerid,    cache_get_field_content_int(0, 			"Score",  	Velocity));
	//--------------------------------------------------------------------------
    Playa[playerid][ID][1]		=   	cache_get_field_content_int(0,  "ID", 		Velocity);
    Playa[playerid][Respect]	=		cache_get_field_content_int(0,  "Respect",  Velocity);
    Playa[playerid][Level]	    =		cache_get_field_content_int(0,  "Level",   	Velocity);
    Playa[playerid][Vip]		=	    cache_get_field_content_int(0,  "VIP",      Velocity);
    Playa[playerid][Admin]		=		cache_get_field_content_int(0,  "Admin",    Velocity);
    Playa[playerid][Coins]      =		cache_get_field_content_int(0,  "Coins",    Velocity);
    Playa[playerid][Hours]      =		cache_get_field_content_int(0,  "Hours",    Velocity);
    Playa[playerid][Minutes]	=		cache_get_field_content_int(0,  "Minutes",  Velocity);
    Playa[playerid][Day]        =       cache_get_field_content_int(0,  "Day",      Velocity);
	Playa[playerid][Month]      =       cache_get_field_content_int(0,  "Month",    Velocity);
	Playa[playerid][Year]       =       cache_get_field_content_int(0,  "Year",     Velocity);
    //--------------------------------------------------------------------------
    cache_get_field_content(	0,  "E-Mail",   Playa[playerid][EMail],     		Velocity,   150);
	//--------------------------------------------------------------------------
    if(Playa[playerid][Admin] > 0)
		mysql_format(Velocity, msQuery, 256, "SELECT * FROM `admindata` WHERE `Name` = '%s'", SendName(playerid)),
		mysql_pquery(Velocity, msQuery, "LoadAdminData", "d", playerid);
	//--------------------------------------------------------------------------
	for(new hi = 0; hi < MAX_HOUSES; ++hi)
	    if(strcmp(House[hi][Owner], SendName(playerid)) == 0)
		{
			Playa[playerid][OwnHouse] = 1;
			Playa[playerid][HousePos][1] = House[hi][Pickup][1];    Playa[playerid][HousePos][2] = House[hi][Pickup][2];    Playa[playerid][HousePos][3] = House[hi][Pickup][3];
		}
	//--------------------------------------------------------------------------
	for(new pID = 0; pID < MAX_PROPS; ++pID)
	    if(strcmp(Property[pID][Owner], SendName(playerid)) == 0)
		{
			Playa[playerid][OwnProp] = 1;
			Playa[playerid][PropPos][1] = Property[pID][Pickup][1];    Playa[playerid][PropPos][2] = Property[pID][Pickup][2];    Playa[playerid][PropPos][3] = Property[pID][Pickup][3];
		}
 	//----------------------------------------------------------------------
	switch(Playa[playerid][Language])
	{
	    case 0:
		{
		    format(String2, 50, "{FFFFFF}Hello, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
			strcat(String, String2);
			strcat(String, "{FFFFFF}You have been logged in succesfuly!\n\n");
			//--------------------------------------------------------------
			if(Playa[playerid][Admin] > 0)
			{
				format(String2, 50, "{FFFFFF}Admin: {00FF00}Yes {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Admin]);
				strcat(String, String2);
			}
			else strcat(String, "{FFFFFF}Admin: {00FF00}No\n");
			//--------------------------------------------------------------
			if(Playa[playerid][Vip] > 0)
			{
				format(String2, 50, "{FFFFFF}VIP: {00FF00}Yes {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Vip]);
				strcat(String, String2);
			}
			else strcat(String, "{FFFFFF}VIP: {00FF00}No\n");
			//--------------------------------------------------------------
			format(String2, 150, "{FFFFFF}Level: {00FF00}%d\n", Playa[playerid][Level]);
			strcat(String, String2);
			format(String2, 150, "{FFFFFF}Respect Points: {00FF00}%d{FFFFFF}/{00FF00}%d\n\n", Playa[playerid][Respect], Playa[playerid][Level] * 3);
			strcat(String, String2);
			strcat(String, "{FFFFFF}For more statistics, use {FF0000}/stats{FFFFFF}.\n\n");
			//--------------------------------------------------------------
			return ShowPlayerDialog(playerid, AccD + 6, DIALOG_STYLE_MSGBOX, "Account", String, "Ok", "");
		}
		case 1:
		{
		    format(String2, 50, "{FFFFFF}Buna, {FF0000}%s{FFFFFF}!\n", SendName(playerid));
			strcat(String, String2);
			strcat(String, "{FFFFFF}Ai fost autentificat cu succes!\n\n");
			//--------------------------------------------------------------
			if(Playa[playerid][Admin] > 0)
			{
				format(String2, 50, "{FFFFFF}Admin: {00FF00}Da {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Admin]);
				strcat(String, String2);
			}
			else strcat(String, "{FFFFFF}Admin: {00FF00}Nu\n");
			//--------------------------------------------------------------
			if(Playa[playerid][Vip] > 0)
			{
				format(String2, 50, "{FFFFFF}VIP: {00FF00}Da {FFFFFF}- level: {00FF00}%d\n", Playa[playerid][Vip]);
				strcat(String, String2);
			}
			else strcat(String, "{FFFFFF}VIP: {00FF00}Nu\n");
			//--------------------------------------------------------------
			format(String2, 150, "{FFFFFF}Level: {00FF00}%d\n", Playa[playerid][Level]);
			strcat(String, String2);
			format(String2, 150, "{FFFFFF}Respect Points: {00FF00}%d{FFFFFF}/{00FF00}%d\n\n", Playa[playerid][Respect], Playa[playerid][Level] * 3);
			strcat(String, String2);
			strcat(String, "{FFFFFF}Pentru mai multe statistici, foloseste {FF0000}/stats{FFFFFF}.\n\n");
			//--------------------------------------------------------------
			return ShowPlayerDialog(playerid, AccD + 6, DIALOG_STYLE_MSGBOX, "Contul meu", String, "Inchide", "");
		}
	}
	return 1;
}
public LoadAdminData(playerid)
{
	if(cache_get_row_count(Velocity))
	{
	    _Admin[playerid][Bans]			= cache_get_field_content_int(0, "Bans", 			Velocity);
	    _Admin[playerid][ID] 			= cache_get_field_content_int(0, "ID", 				Velocity);
	    _Admin[playerid][Warns] 		= cache_get_field_content_int(0, "Warns", 			Velocity);
	    _Admin[playerid][Kicks] 		= cache_get_field_content_int(0, "Kicks", 			Velocity);
	    _Admin[playerid][Jails] 		= cache_get_field_content_int(0, "Jails", 			Velocity);
	    _Admin[playerid][Mutes] 		= cache_get_field_content_int(0, "Mutes", 			Velocity);
	    _Admin[playerid][Explodes] 		= cache_get_field_content_int(0, "Explodes", 		Velocity);
	    _Admin[playerid][ChatsCleared] 	= cache_get_field_content_int(0, "ChatsCleared", 	Velocity);
	    _Admin[playerid][Events] 		= cache_get_field_content_int(0, "Events", 			Velocity);
	    _Admin[playerid][IsRcon] 		= cache_get_field_content_int(0, "IsRcon", 			Velocity);
	}
	//--------------------------------------------------------------------------
	return 1;
}
SavePlayerData(playerid)
{
	if(Playa[playerid][LoggedIn] == true)
	{
	    msQuery[0] = '\0'; new h, m, s; TotalGameTime(playerid, h, m, s);
	    //----------------------------------------------------------------------
	    format(msQuery, 2048, "UPDATE `accounts` SET `Level` = '%d', `Respect` = '%d', `Admin` = '%d', `VIP` = '%d', `Hours` = '%d', `Minutes` = '%d', `Coins` = '%d',\
 		`Money` = '%d', `Score` = '%d', `Day` = '%d', `Month` = '%d', `Year` = '%d' WHERE `ID` = '%d'",
		Playa[playerid][Level], Playa[playerid][Respect], Playa[playerid][Admin], Playa[playerid][Vip], h, m, Playa[playerid][Coins],
  		GetPlayerMoney(playerid), GetPlayerScore(playerid), Playa[playerid][Day], Playa[playerid][Month], Playa[playerid][Year], Playa[playerid][ID][1]);
		mysql_pquery(Velocity, msQuery);
		//----------------------------------------------------------------------
		if(Playa[playerid][Admin] > 0)
		{
			msQuery[0] = '\0';
			format(msQuery, 256, "UPDATE `admindata` SET `Bans` = '%d',`Warns` = '%d',`Kicks` = '%d',`Jails` = '%d',`Mutes` = '%d',`Explodes` = '%d',`ChatsCleared` = '%d',`Events` = '%d',`IsRcon` = '%d' WHERE `ID` = '%d'",
			_Admin[playerid][Bans], _Admin[playerid][Warns], _Admin[playerid][Kicks], _Admin[playerid][Jails], _Admin[playerid][Mutes], _Admin[playerid][Explodes], _Admin[playerid][ChatsCleared], _Admin[playerid][Events],
			_Admin[playerid][IsRcon], _Admin[playerid][ID]);
			mysql_pquery(Velocity, msQuery);
		}
	}
	//--------------------------------------------------------------------------
	return 1;
}
//==============================================================================
public KickEx(playerid) return	Kick(playerid);
ErrorMessages(playerid, ErrorID)
{
    if(ErrorID == 1)
	{
	    new RoError[150] = "ERROR: Trebuie sa ai RCON Admin pentru a accesa aceasta comanda!";
	    new EnError[100] = "ERROR: You must be a RCON Admin to use this command!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 2)
	{
	    new RoError[150] = "ERROR: Trebuie sa ai Gold VIP pentru a accesa aceasta comanda!";
	    new EnError[100] = "ERROR: You must have Gold VIP to use this command!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 3)
	{
	    new RoError[150] = "ERROR: Nu ai un nivel de Admin indeajuns de mare pentru a accesa aceasta comanda!";
	    new EnError[100] = "ERROR: You are not a high enough Admin Level to use this command!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 4)
	{
	    new RoError[150] = "ERROR: Nu ai un nivel de V.I.P. indeajuns de mare! Scrie /vCmds pentru detalii!";
	    new EnError[100] = "ERROR: You are not a high enough V.I.P. Level. Type /vCmds for details!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 5)
	{
	    new RoError[100] = "ERROR: Nu ai destui Coins/Ore pentru a cumpara acest Level de VIP!";
		new EnError[100] = "ERROR: You don't have enough Coins/Hours to buy that VIP Level!";
		//----------------------------------------------------------------------
		SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 6)
	{
	    new RoError[250] = "ERROR: Trebuie sa fii logat pentru a putea scrie pe Chat/pentru a putea folosii comenzi!";
	    new EnError[150] = "ERROR: You must be logged in to use commands/the chat!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 7)
	{
	    new RoError[100] = "ERROR: Daca noi iti intindem un deget, tu de ce vrei sa ne iei toata mana ?";
		new EnError[100] = "ERROR: Sorry, but you already had VIP Level 7 for FREE 10 days...";
		//----------------------------------------------------------------------
		SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 8)
	{
	    new RoError[250] = "ERROR: Trebuie sa ai VIP Level 7 sau sa fii la un Spawn Place pentru a folosii aceasta comanda!";
	    new EnError[200] = "ERROR: You must have VIP Level 7 or be on a Spawn Place to use this command!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 9)
	{
	    new RoError[150] = "ERROR: Acest jucator nu este conectat sau este un Admin!";
	    new EnError[100] = "ERROR: That player is not connected or is an Admin!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 10)
	{
	    new RoError[150] = "ERROR: Acest Nickname nu exista in Baza de Date!";
	    new EnError[100] = "ERROR: This Nickname does not exist in the DataBase!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 11)
	{
	    new RoError[100] = "ERROR: Ai deja un vehicul!";
	    new EnError[100] = "ERROR: You already have a vehicle!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 12)
	{
	    new RoError[100] = "ERROR: Nu esti intr-un vehicul!";
	    new EnError[100] = "ERROR: You are not in a vehicle!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 13)
	{
	    new RoError[100] = "ERROR: Nu ai o Proprietate!";
	    new EnError[100] = "ERROR: You don't have any Property!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 14)
	{
	    new RoError[100] = "ERROR: Nu ai destui Coins!";
	    new EnError[100] = "ERROR: You don't enough Coins!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 15)
	{
	    new RoError[100] = "ERROR: Nu esti intr-un Pickup de Casa/Proprietate!";
	    new EnError[100] = "ERROR: You are not in a House/Property Pickup!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 16)
	{
	    new RoError[100] = "ERROR: Nu ai destui bani!";
	    new EnError[100] = "ERROR: You don't have enough money!";
	    //----------------------------------------------------------------------
	    SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	//--------------------------------------------------------------------------
	else if(ErrorID == 17)
	{
 		new RoError[100] = "ERROR: Ai deja un Clan! Scrie /LClan pentru a iesii din el.";
		new EnError[100] = "ERROR: You already have a Clan. Type /LClan to leave your current clan!";
		//----------------------------------------------------------------------
		SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
	}
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ERROR_NC(playerid)
{
    new RoError[100] = "ERROR: Jucator neconectat!"; new EnError[100] = "ERROR: Player is Not Connected!";
    return SendClientMessage(playerid, RED, (Playa[playerid][Language] == 1) ? RoError : EnError);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EraseVeh(VehID)
{
    new MaxPlayers = GetPlayerPoolSize();
    //--------------------------------------------------------------------------
    for(new l; l <= MaxPlayers; l++)
	{
        new Float:X, Float:Y, Float:Z;
    	if(IsPlayerInVehicle(l, VehID)) RemovePlayerFromVehicle(l), GetPlayerPos(l, X, Y, Z), SetPlayerPos(l, X, Y+3, Z);
		//----------------------------------------------------------------------
	    SetVehicleParamsForPlayer(VehID, l, 0,1);
	}
    DestroyVehicle(VehID);
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IsNumeric(string[])
{
	for(new l = 0, j = strlen(string); l < j; l++)
	{
		if(string[l] > '9' || string[l] < '0') return 0;
	}
	return 1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
GetIDFromName(vName[])
{
	for(new l = 0; l < 211; l++)
	{
		if(strfind(VehicleNames[l], vName, true) != -1) return l + 400;
	}
	return -1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public InsertAdminID(playerid) return _Admin[playerid][ID] = cache_insert_id(Velocity);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
public UnMutePlayer(playerid) return KillTimer(Playa[playerid][MutedTime]), Playa[playerid][Muted] = 0, GameTextForPlayer(playerid, "~r~~h~Unmuted!", 3000, 6);
public SendMessageToAdmins(mColor, const string[])
{
	new MaxPlayers = GetPlayerPoolSize(); for(new l; l <= MaxPlayers; ++l) if(IsPlayerConnected(l) == 1) if(Playa[l][Admin] >= 1) SendClientMessage(l, mColor, string);
	return 1;
}
public SendMessageToVips(mColor, const string[])
{
	new MaxPlayers = GetPlayerPoolSize(); for(new l; l <= MaxPlayers; ++l) if(IsPlayerConnected(l) == 1) if(Playa[l][Vip] >= 1) SendClientMessage(l, mColor, string);
	return 1;
}
SendCommandToAdmins(playerid, command[])
{
	String[0] = '\0';
	format(String, 500, "{FFFFFF}Admin {FF0000}%s {FFFFFF}has used command {FF0000}%s{FFFFFF}.", SendName(playerid), command);
	SendMessageToAdmins(WHITE, String);
	return 1;
}
//==============================================================================
//House System
//==============================================================================
public LoadHouses()
{
	for(new hi = 0; hi < MAX_HOUSES; ++hi)
	{
	    House[hi][ID][1] 	= 	cache_get_field_content_int(hi, "ID", 	 	Velocity);
	    House[hi][Buy]      =   cache_get_field_content_int(hi, "Buy",      Velocity);
	    House[hi][Sell]     =   cache_get_field_content_int(hi, "Sell",     Velocity);
	    House[hi][Int]		=   cache_get_field_content_int(hi, "Interior", Velocity);
	    House[hi][Locked]	=   cache_get_field_content_int(hi, "Locked",   Velocity);
	    House[hi][Rents]    =   cache_get_field_content_int(hi, "Rents",    Velocity);
   		//----------------------------------------------------------------------
		cache_get_field_content(hi, "Owner", House[hi][Owner], Velocity, 24);
	    //----------------------------------------------------------------------
		House[hi][Exit][1]      =   cache_get_field_content_float(hi, "ExitX",      Velocity);
		House[hi][Exit][2]      =   cache_get_field_content_float(hi, "ExitY",      Velocity);
		House[hi][Exit][3]      =   cache_get_field_content_float(hi, "ExitZ",      Velocity);
  		House[hi][Pickup][1]	=   cache_get_field_content_float(hi, "PickupX",    Velocity);
		House[hi][Pickup][2]    =   cache_get_field_content_float(hi, "PickupY",    Velocity);
		House[hi][Pickup][3]    =   cache_get_field_content_float(hi, "PickupZ",    Velocity);
	}
	return BuildHouses();
}
BuildHouses()
{
	for(new hi = 0; hi < MAX_HOUSES; ++hi)
	{
	    if(strcmp(House[hi][Owner], "ForSale", true) == 0)
	    {
	        House[hi][ID][2] = CreatePickup(1273, 23, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3]);
	        //------------------------------------------------------------------
	        House[hi][House3d] = CreateDynamic3DTextLabel("{FFFFFF}House is {FF0000}For Sale{FFFFFF}! Type {FF0000}/house {FFFFFF}for help.", WHITE, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
		}
		else
		{
		    House[hi][ID][2] = CreatePickup(1272, 23, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3]); String[0] = '\0';
	        //------------------------------------------------------------------
			format(String, 512, "{FFFFFF}House is owned by {FF0000}%s{FFFFFF}! Type {FF0000}/house {FFFFFF}for help.", House[hi][Owner]);
			House[hi][House3d] = CreateDynamic3DTextLabel(String, WHITE, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
		}
	}
	return 1;
}
UpdateHouse(hi)
{
	if(strcmp(House[hi][Owner], "ForSale", true) == 0)
    {
        House[hi][ID][2] = CreatePickup(1273, 23, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3]);
        //------------------------------------------------------------------
        House[hi][House3d] = CreateDynamic3DTextLabel("House is {FF0000}For Sale{FFFFFF}! Type {FF0000}/house {FFFFFF}for help.", WHITE, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
	}
	else
	{
	    House[hi][ID][2] = CreatePickup(1272, 23, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3]); String[0] = '\0';
        //------------------------------------------------------------------
		format(String, 512, "{FFFFFF}House is owned by {FF0000}%s{FFFFFF}! Type {FF0000}/house {FFFFFF}for help.", House[hi][Owner]);
		House[hi][House3d] = CreateDynamic3DTextLabel(String, WHITE, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
	}
	return 1;
}
IsInHousePickup(playerid)
{
	for(new hi = 0; hi < MAX_HOUSES; ++hi)
	    if(IsPlayerInRangeOfPoint(playerid, 1.5, House[hi][Pickup][1], House[hi][Pickup][2], House[hi][Pickup][3]))
	        return hi;
 	return -1;
}
//==============================================================================
//Property Sistem
//==============================================================================
public LoadProperties()
{
	for(new pID = 0; pID < MAX_PROPS; ++pID)
	{
	    cache_get_field_content(pID, "Name", Property[pID][Name], Velocity, 24);
	    cache_get_field_content(pID, "Text", Property[pID][Text], Velocity, 24);
	    cache_get_field_content(pID, "Owner",Property[pID][Owner],Velocity, 24);
	    //----------------------------------------------------------------------
		Property[pID][ID][1]    	=   cache_get_field_content_int(pID, 	"ID", 		Velocity);
		Property[pID][Buy]      	=   cache_get_field_content_int(pID, 	"Buy", 		Velocity);
		Property[pID][Sell]     	=   cache_get_field_content_int(pID,    "Sell",     Velocity);
		Property[pID][Class]    	=   cache_get_field_content_int(pID,    "Class",    Velocity);
		Property[pID][Income]   	=   cache_get_field_content_int(pID,    "Income",   Velocity);
		Property[pID][Int]      	=   cache_get_field_content_int(pID,    "Interior", Velocity);
		Property[pID][Fare]         =   cache_get_field_content_int(pID,    "Fare",     Velocity);
		//-----------------------------------------------------------------------------------
		Property[pID][Pickup][1]	=   cache_get_field_content_float(pID,  "PickupX",  Velocity);
		Property[pID][Pickup][2]	=   cache_get_field_content_float(pID,  "PickupY",  Velocity);
		Property[pID][Pickup][3]	=   cache_get_field_content_float(pID,  "PickupZ",  Velocity);
		Property[pID][Exit][1]      =   cache_get_field_content_float(pID,  "ExitX",    Velocity);
		Property[pID][Exit][2]      =   cache_get_field_content_float(pID,  "ExitY",    Velocity);
		Property[pID][Exit][3]      =   cache_get_field_content_float(pID,  "ExitZ",    Velocity);
		//---------------------------------------------------------------------------------------
	}
	return BuildProps();
}
//------------------------------------------------------------------------------
BuildProps()
{
	for(new pID = 0; pID < MAX_PROPS; ++pID)
	{
	    if(strcmp(Property[pID][Owner], "ForSale", true) == 0)
		{
		    String[0] = '\0';
		    //------------------------------------------------------------------
		    Property[pID][ID][2] = CreatePickup(1274, 23, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3]);
		    //------------------------------------------------------------------
			Property[pID][ID][3] = CreateDynamicMapIcon(Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 52, 0, 0, 0, -1, 50.0);
		    //------------------------------------------------------------------
		    format(String, 256, "{FF0000}Name: {FFFFFF}%s\n\
								 {FF0000}Owner: {FFFFFF}ForSale\n\
								 {FF0000}Fare: {FFFFFF}%d {FF0000}Coins\n\
								 {FF0000}Income: {FFFFFF}%d {FF0000}Coins\n\
								 {FF0000}Cost: {FFFFFF}%d {FF0000}Coins\n\
								 {FFFFFF}Use {FF0000}/property {FFFFFF}for help!", Property[pID][Name], Property[pID][Fare], Property[pID][Income], Property[pID][Buy]);
			Property[pID][Prop3D] = CreateDynamic3DTextLabel(String, WHITE, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
			//------------------------------------------------------------------
		}
		else
		{
		    String[0] = '\0';
		    //------------------------------------------------------------------
		    Property[pID][ID][2] = CreatePickup(1274, 23, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3]);
		    //------------------------------------------------------------------
			Property[pID][ID][3] = CreateDynamicMapIcon(Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 36, 0, 0, 0, -1, 50.0);
			//------------------------------------------------------------------
			format(String, 256, "{FF0000}Name: {FFFFFF}%s\n\
								 {FF0000}Original Name: {FFFFFF}%s\n\
								 {FF0000}Owner: {FFFFFF}%s\n\
								 {FF0000}Class: {FFFFFF}%d\n\
								 {FF0000}Fare: {FFFFFF}%d {FF0000}Coins\n\
								 {FF0000}Income: {FFFFFF}%d {FF0000}Coins\n\
								 {FFFFFF}Use {FF0000}/property {FFFFFF}for help!", Property[pID][Text], Property[pID][Name], Property[pID][Owner], Property[pID][Class], Property[pID][Fare], Property[pID][Income]);
            	Property[pID][Prop3D] = CreateDynamic3DTextLabel(String, WHITE, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
		 }
	}
	return 1;
}
UpdateProp(pID)
{
	if(strcmp(Property[pID][Owner], "ForSale", true) == 0)
	{
	    String[0] = '\0';
	    //------------------------------------------------------------------
	    Property[pID][ID][2] = CreatePickup(1274, 23, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3]);
	    //------------------------------------------------------------------
		Property[pID][ID][3] = CreateDynamicMapIcon(Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 52, 0, 0, 0, -1, 150.0);
	    //------------------------------------------------------------------
	    format(String, 256, "{FF0000}Name: {FFFFFF}%s\n\
							 {FF0000}Owner: {FFFFFF}ForSale\n\
							 {FF0000}Fare: {FFFFFF}%d {FF0000}Coins\n\
							 {FF0000}Income: {FFFFFF}%d {FF0000}Coins\n\
							 {FF0000}Cost: {FFFFFF}%d {FF0000}Coins\n\
							 {FFFFFF}Use {FF0000}/property {FFFFFF}for help!", Property[pID][Name], Property[pID][Fare], Property[pID][Income], Property[pID][Buy]);
		Property[pID][Prop3D] = CreateDynamic3DTextLabel(String, WHITE, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
		//------------------------------------------------------------------
	}
	else
	{
	    String[0] = '\0';
	    //------------------------------------------------------------------
	    Property[pID][ID][2] = CreatePickup(1274, 23, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3]);
	    //------------------------------------------------------------------
		Property[pID][ID][3] = CreateDynamicMapIcon(Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 36, 0, 0, 0, -1, 150.0);
		//------------------------------------------------------------------
		format(String, 256, "{FF0000}Name: {FFFFFF}%s\n\
							 {FF0000}Original Name: {FFFFFF}%s\n\
							 {FF0000}Owner: {FFFFFF}%s\n\
							 {FF0000}Class: {FFFFFF}%d\n\
							 {FF0000}Fare: {FFFFFF}%d {FF0000}Coins\n\
							 {FF0000}Income: {FFFFFF}%d {FF0000}Coins\n\
							 {FFFFFF}Use {FF0000}/property {FFFFFF}for help!", Property[pID][Text], Property[pID][Name], Property[pID][Owner], Property[pID][Class], Property[pID][Fare], Property[pID][Income]);
        	Property[pID][Prop3D] = CreateDynamic3DTextLabel(String, WHITE, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3], 150, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100);
	 }
	 return 1;
}
//------------------------------------------------------------------------------
IsInPropertyPickup(playerid)
{
	for(new pID = 0; pID < MAX_PROPS; ++pID)
	    if(IsPlayerInRangeOfPoint(playerid, 1.5, Property[pID][Pickup][1], Property[pID][Pickup][2], Property[pID][Pickup][3]))
	        return pID;
	return -1;
}
//==============================================================================
PayDay()
{
	foreach(new i : Player)
		Playa[i][Coins] += Playa[i][Coins] * 5 / 100,
		GivePlayerMoney(i, GetPlayerMoney(i) * 10 / 100),
		SendClientMessage(i, WHITE, "PAYDAY!\nCheck your stats - /stats for details");
	//--------------------------------------------------------------------------
	return 1;
}
//------------------------------------------------------------------------------
TPlayer(playerid, telename[], telecmd[], Float:X, Float:Y, Float:Z, Float:Angle)
{
	new pVID = GetPlayerVehicleID(playerid), PState = GetPlayerState(playerid); String[0] = '\0';
	//--------------------------------------------------------------------------
	if(IsPlayerInAnyVehicle(playerid) && PState == PLAYER_STATE_DRIVER) SetVehiclePos(pVID, X, Y, Z), SetVehicleZAngle(pVID, Angle),          LinkVehicleToInterior(pVID, 0);
	else if(!IsPlayerInAnyVehicle(playerid)) 							SetCameraBehindPlayer(playerid),       SetPlayerPos(playerid, X, Y, Z), SetPlayerFacingAngle(playerid, Angle), SetPlayerInterior(playerid, 0);
	//--------------------------------------------------------------------------
	SendTeleport(playerid, telename, telecmd); format(String, 120, "~w~~h~Welcome to ~n~~g~~h~~h~%s", telename), GameTextForPlayer(playerid, String, 4000, 4);
	return 1;
}
/*ShowStats(playerid)
{
	return playerid;
}*/
//==============================================================================
SendTeleport(playerid, telename[], cmdname[])
{
	if(Playa[playerid][CarTDs] == 0)
	{
	    if(strlen(TDString[0]) < 5)
	        format(TDString[0], 256 * 3, "~r~~h~%s ~w~~h~has gone to ~r~~h~%s ~w~~h~- /%s", SendName(playerid), telename, cmdname);
		else
		    format(TDString[2], 256 * 3, TDString[1]),
		    format(TDString[1], 256 * 3, TDString[0]),
		    format(TDString[0], 256 * 3, "~r~~h~%s ~w~~h~has gone to ~r~~h~%s ~w~~h~- /%s", SendName(playerid), telename, cmdname);
		//----------------------------------------------------------------------
		String[0] = '\0'; new _HighID = GetPlayerPoolSize();
		//----------------------------------------------------------------------
		format(String, 256 * 3, "%s~n~%s~n~%s~n~%s", TDString[0], TDString[1], TDString[2]);
		//----------------------------------------------------------------------
		for(new i = 0; i <= _HighID; ++i)
		    if(Playa[i][HTDs] == 0) TextDrawSetString(ConnectTD, String), TextDrawShowForPlayer(i, ConnectTD);
		    else TextDrawHideForPlayer(i, ConnectTD);
		//----------------------------------------------------------------------
		return 1;
	}
	return 0;
}
SendConnect(playerid)
{
	if(Playa[playerid][CarTDs] == 0)
	{
	    if(strlen(TDString[0]) < 5)
	        format(TDString[0], 256 * 3, "~r~~h~%s ~g~~h~has connected on server", SendName(playerid));
		else
		    format(TDString[2], 256 * 3, TDString[1]),
		    format(TDString[1], 256 * 3, TDString[0]),
		    format(TDString[0], 256 * 3, "~r~~h~%s ~g~~h~has connected on server", SendName(playerid));
		//----------------------------------------------------------------------
		String[0] = '\0'; new _HighID = GetPlayerPoolSize();
		//----------------------------------------------------------------------
		format(String, 256 * 3, "%s~n~%s~n~%s~n~%s", TDString[0], TDString[1], TDString[2]);
		//----------------------------------------------------------------------
		for(new i = 0; i <= _HighID; ++i)
		    if(Playa[i][HTDs] == 0) TextDrawSetString(ConnectTD, String), TextDrawShowForPlayer(i, ConnectTD);
		    else TextDrawHideForPlayer(i, ConnectTD);
		//----------------------------------------------------------------------
		return 1;
	}
	return 0;
}
SendDisconnect(playerid, reasonid)
{
    if(Playa[playerid][CarTDs] == 0)
	{
		new _string[20], _HighID = GetPlayerPoolSize(); String[0] = '\0';
		//----------------------------------------------------------------------
		switch(reasonid) { case 0: _string = "Timeout"; case 1: _string = "Leaving"; case 2: _string = "Kicked/Banned"; }
		//----------------------------------------------------------------------
		if(strlen(TDString[0]) < 5)
			format(TDString[0], 256 * 3, "~r~~h~%s ~g~~h~has left the server ~w~~h~(%s)!", SendName(playerid), _string);
		else
			format(TDString[2], 256 * 3, TDString[1]),
		    format(TDString[1], 256 * 3, TDString[0]),
		    format(TDString[0], 256 * 3, "~r~~h~%s ~g~~h~has left the server ~w~~h~(%s)!", SendName(playerid), _string);
		//----------------------------------------------------------------------
		format(String, 256 * 3, "%s~n~%s~n~%s~n~%s", TDString[0], TDString[1], TDString[2]);
		//----------------------------------------------------------------------
		for(new i = 0; i <= _HighID; ++i)
		    if(Playa[i][HTDs] == 0) TextDrawSetString(ConnectTD, String), TextDrawShowForPlayer(i, ConnectTD);
		    else TextDrawHideForPlayer(i, ConnectTD);
 		//----------------------------------------------------------------------
		return 1;
	}
	return 0;
}
//==============================================================================
TotalGameTime(playerid, &h=0, &m=0, &s=0)
{
	//--------------------------------------------------------------------------
    Playa[playerid][TotalTime] = NetStats_GetConnectedTime(playerid);
	//--------------------------------------------------------------------------
	s = Playa[playerid][TotalTime] / 1000;
	m = s / 60;
	h = m / 60;
	//--------------------------------------------------------------------------
    return Playa[playerid][TotalTime];
}
//==============================================================================
public UpdateTime()
{   new h, m, d, mo, y, text[5], str[10]; gettime(h, m); getdate(y, mo, d);
	//--------------------------------------------------------------------------
	switch(mo)
	{
	    case 1:  text = "Jan";		case 2:  text = "Feb";		case 3:  text = "Mar";
	    case 4:  text = "Apr";		case 5:  text = "May";	    case 6:  text = "Jun";
	    case 7:  text = "Jul";		case 8:  text = "Aug";		case 9:  text = "Sep";
	    case 10: text = "Oct";		case 11: text = "Nov";		case 12: text = "Dec";
	}
	//--------------------------------------------------------------------------
	format(str, 10, "%02d %s",   d, text);							TextDrawSetString(Textdraw14, str);
	format(str, 6,  "%02d:%02d", h, m);								TextDrawSetString(Textdraw15, str);
	//--------------------------------------------------------------------------
	if(m == 0) return PayDay();
	return 1;
}


