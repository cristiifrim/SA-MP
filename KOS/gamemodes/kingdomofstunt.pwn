#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <a_mysql>
#include <foreach>
#include <streamer>
#include <a_zone>

#if !defined gpci
    native gpci(playerid, serial[], len);
#endif

#define ServerDialog 1
#define AccountDialog 10
#define GangDialog 20
#define MAX_TURFS 48
#define MAX_HOUSES 1200
#define MAX_HQS 50

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

#define NULL '\0'

#define sqlHost "localhost"
#define sqlPass ""
#define sqlDB "kingdomofstunt"
#define sqlUser "root"

enum PlayerData {
	ID,                House,
	EMail[32],         Warns,
	IsConfirmed,
	Security,
	Pin,
	Language,
	FailedLogins,
	bool:loggedIn,
	Level,
	Respect,
	Hours,
	Minutes,
	Coins,
    VIP,
    Kills,
    Deaths,
    bool: AFK,
    Mute,
    CommandSpam,
    ChatSpam,
	neacristy,
    ChatTag[40],
    Turfs
}

enum AdminData {
    ID, Level, Events, ChatsCleared, Kicks, Bans, Mutes, Warns, AdminPoints, neacristy, RCONPass[24]
}

enum ServerData {
	Hour, Minute, Day, Month, neacristy, Year, ncText[4]
}

enum TurfData {
    ID, Owner, Float: MinX, Float: MinY, Float: MaxX, Float: MaxY, bool: OnWar, Zone[2]
}

enum HouseData {
    ID, Owner[24], Float: X, Float: Y, Float: Z, Text3D: Info, Interior, Icon, Locked, Buy, Sell, Rent, Renters, Float: InX, Float: InY, Float: InZ
}

enum BanData {
    ID, BanDate, Admin[24], Time, Reason[128]
}
/*enum ClanData {
    ID, Name[24], Owner[24], HQ, ChatColor, RankName[8][20], Rank
}
enum HQData {
    ID, Owner[24], Float: X, Float: Y, Float: Z, Text3D: Info
}

enum TeleportData {
    Float: PrevX, Float: PrevY, Float: PrevZ, Float: X, Float: Y, Float: Z
}*/

new MySQL: dbConnect, ncStr[2048], ncStr2[2048], houseID,
playerData[MAX_PLAYERS][PlayerData],
adminData[MAX_PLAYERS][AdminData],
serverData[ServerData],
turfData[MAX_TURFS][TurfData],
houseData[MAX_HOUSES][HouseData],
banData[MAX_PLAYERS][BanData],
//clanData[MAX_PLAYERS][ClanData],
//hqData[MAX_HQS][HQData],
//antiTP[MAX_PLAYERS][TeleportData],
Text:Textdraw0,         Text:Textdraw1,         Text:Textdraw2,         Text:Textdraw3,
Text:Textdraw4,         Text:Textdraw5,         Text:Textdraw6,         Text:Textdraw7,
Text:Textdraw8,         Text:Textdraw9,         Text:Textdraw10,        Text:Textdraw11,
Text:Textdraw12,        Text:ConnectTD,         PlayerText:Textdraw13,  Text:Textdraw14,
Text:Textdraw15,        PlayerText:Textdraw16,
Iterator: Admins<MAX_PLAYERS>, Iterator: Vips<MAX_PLAYERS>;

forward OnAccountCheck(playerid);	forward OnAccountRegister(playerid, Password[]);	forward KickEx(playerid);
forward sendID(playerid);			forward OnLoginCheck(playerid);						forward OnLoadData(playerid);
forward UpdateTime();               forward GetAdminID(playerid);                       forward OnLoadAdminData(playerid);
forward OnRconCheck(playerid);      forward loadTurfs();                                
forward loadHouses();               forward checkAccountBan(playerid);

AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}

main() {

    for(new i = 0; i < 6; ++i)
        printf("%d ", randomEx(1, 49));
    for(new i = 0; i < 100; ++i)
        printf("(%d, %d, %d),", randomEx(1, 6), randomEx(1, 11), randomEx(1, 500));

}


public OnGameModeInit()
{

	new s; ncStr[0] = EOS;
	dbConnect = mysql_connect(sqlHost, sqlUser, sqlPass, sqlDB);
	mysql_log(ERROR | DEBUG | WARNING);
	SetGameModeText("Kingdom of Stunt v1");
	gettime(serverData[Hour], serverData[Minute], s);
    getdate(serverData[Year], serverData[Month], serverData[Day]);
	AntiDeAMX();   UsePlayerPedAnims();

    switch(serverData[Month])
    {
        case 1:  serverData[ncText] = "Jan";      case 2:  serverData[ncText] = "Feb";      case 3:  serverData[ncText] = "Mar";
        case 4:  serverData[ncText] = "Apr";      case 5:  serverData[ncText] = "May";      case 6:  serverData[ncText] = "Jun";
        case 7:  serverData[ncText] = "Jul";      case 8:  serverData[ncText] = "Aug";      case 9:  serverData[ncText] = "Sep";
        case 10: serverData[ncText] = "Oct";      case 11: serverData[ncText] = "Nov";      case 12: serverData[ncText] = "Dec";
    }
    //--------------------------------------------------------------------------
    // -> Server's Querries
    //--------------------------------------------------------------------------
    mysql_tquery(dbConnect, "SELECT * FROM `turfs`", "loadTurfs");
    mysql_tquery(dbConnect, "SELECT * FROM `houses`", "loadHouses");
    mysql_tquery(dbConnect, "SELECT * FROM `hqs`", "loadHQS");
	//--------------------------------------------------------------------------
    // -> Server's Textdraws
    //--------------------------------------------------------------------------
    Textdraw0 = TextDrawCreate(17.000000, 420.000000, "Kingdom");   TextDrawBackgroundColor(Textdraw0, 255);
    TextDrawFont(Textdraw0, 0);                                     TextDrawLetterSize(Textdraw0, 0.619999, 1.800000);
    TextDrawColor(Textdraw0, 7658495);                              TextDrawSetOutline(Textdraw0, 0);
    TextDrawSetProportional(Textdraw0, 1);                          TextDrawSetShadow(Textdraw0, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw1 = TextDrawCreate(82.000000, 420.000000, "of");        TextDrawBackgroundColor(Textdraw1, 255);
    TextDrawFont(Textdraw1, 0);                                     TextDrawLetterSize(Textdraw1, 0.619999, 1.800000);
    TextDrawColor(Textdraw1, -65281);                               TextDrawSetOutline(Textdraw1, 0);
    TextDrawSetProportional(Textdraw1, 1);                          TextDrawSetShadow(Textdraw1, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw2 = TextDrawCreate(102.000000, 420.000000, "Stunt");    TextDrawBackgroundColor(Textdraw2, 255);
    TextDrawFont(Textdraw2, 0);                                     TextDrawLetterSize(Textdraw2, 0.619999, 1.800000);
    TextDrawColor(Textdraw2, -16776961);                            TextDrawSetOutline(Textdraw2, 0);
    TextDrawSetProportional(Textdraw2, 1);                          TextDrawSetShadow(Textdraw2, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw3 = TextDrawCreate(29.000000, 437.000000, "]");         TextDrawBackgroundColor(Textdraw3, 255);
    TextDrawFont(Textdraw3, 2);                                     TextDrawLetterSize(Textdraw3, 0.500000, 1.000000);
    TextDrawColor(Textdraw3, -16776961);                            TextDrawSetOutline(Textdraw3, 0);
    TextDrawSetProportional(Textdraw3, 1);                          TextDrawSetShadow(Textdraw3, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw4 = TextDrawCreate(48.000000, 437.000000, "Version 1"); TextDrawBackgroundColor(Textdraw4, 255);
    TextDrawFont(Textdraw4, 3);                                     TextDrawLetterSize(Textdraw4, 0.370000, 1.100000);
    TextDrawColor(Textdraw4, -1);                                   TextDrawSetOutline(Textdraw4, 0);
    TextDrawSetProportional(Textdraw4, 1);                          TextDrawSetShadow(Textdraw4, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw5 = TextDrawCreate(108.000000, 437.000000, "]");        TextDrawBackgroundColor(Textdraw5, 255);
    TextDrawFont(Textdraw5, 2);                                     TextDrawLetterSize(Textdraw5, 0.500000, 1.000000);
    TextDrawColor(Textdraw5, -16776961);                            TextDrawSetOutline(Textdraw5, 0);
    TextDrawSetProportional(Textdraw5, 1);                          TextDrawSetShadow(Textdraw5, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw6 = TextDrawCreate(85.000000, 195.000000, "~w~~h~Welcome ~r~~h~on"); TextDrawBackgroundColor(Textdraw6, 255);
    TextDrawFont(Textdraw6, 0);                                     TextDrawLetterSize(Textdraw6, 0.919999, 1.900000);
    TextDrawColor(Textdraw6, -1);                                   TextDrawSetOutline(Textdraw6, 0);
    TextDrawSetProportional(Textdraw6, 1);                          TextDrawSetShadow(Textdraw6, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw7 = TextDrawCreate(20.000000, 220.000000, "~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]"); TextDrawBackgroundColor(Textdraw7, 255);
    TextDrawFont(Textdraw7, 0);                                     TextDrawLetterSize(Textdraw7, 0.500000, 1.000000);
    TextDrawColor(Textdraw7, -1);                                   TextDrawSetOutline(Textdraw7, 0);
    TextDrawSetProportional(Textdraw7, 1);                          TextDrawSetShadow(Textdraw7, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw8 = TextDrawCreate(40.000000, 230.000000, "Kingdom");   TextDrawBackgroundColor(Textdraw8, 255);
    TextDrawFont(Textdraw8, 0);                                     TextDrawLetterSize(Textdraw8, 0.679999, 2.000000);
    TextDrawColor(Textdraw8, 7519231);                              TextDrawSetOutline(Textdraw8, 0);
    TextDrawSetProportional(Textdraw8, 1);                          TextDrawSetShadow(Textdraw8, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw9 = TextDrawCreate(110.000000, 230.000000, "of");       TextDrawBackgroundColor(Textdraw9, 255);
    TextDrawFont(Textdraw9, 0);                                     TextDrawLetterSize(Textdraw9, 0.679999, 2.000000);
    TextDrawColor(Textdraw9, -65281);                               TextDrawSetOutline(Textdraw9, 0);
    TextDrawSetProportional(Textdraw9, 1);                          TextDrawSetShadow(Textdraw9, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw10 = TextDrawCreate(130.000000, 230.000000, "Stunt");   TextDrawBackgroundColor(Textdraw10, 255);
    TextDrawFont(Textdraw10, 0);                                    TextDrawLetterSize(Textdraw10, 0.679999, 2.000000);
    TextDrawColor(Textdraw10, -16776961);                           TextDrawSetOutline(Textdraw10, 0);
    TextDrawSetProportional(Textdraw10, 1);                         TextDrawSetShadow(Textdraw10, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw11 = TextDrawCreate(20.000000, 263.000000, "~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]~w~~h~]~r~~h~]"); TextDrawBackgroundColor(Textdraw11, 255);
    TextDrawFont(Textdraw11, 0);                                    TextDrawLetterSize(Textdraw11, 0.500000, 1.000000);
    TextDrawColor(Textdraw11, -1);                                  TextDrawSetOutline(Textdraw11, 0);
    TextDrawSetProportional(Textdraw11, 1);                         TextDrawSetShadow(Textdraw11, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Textdraw12 = TextDrawCreate(57.000000, 279.000000, "~w~~h~www.~r~~h~Kingdom-of-Stunt~w~~h~.com"); TextDrawBackgroundColor(Textdraw12, 255);
    TextDrawFont(Textdraw12, 2);                                    TextDrawLetterSize(Textdraw12, 0.360000, 1.400000);
    TextDrawColor(Textdraw12, -1);                                  TextDrawSetOutline(Textdraw12, 0);
    TextDrawSetProportional(Textdraw12, 1);                         TextDrawSetShadow(Textdraw12, 1);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ConnectTD = TextDrawCreate(249.000000, 417.000000, ""),         TextDrawBackgroundColor(ConnectTD, 255);
    TextDrawFont(ConnectTD, 1),                                     TextDrawLetterSize(ConnectTD, 0.190000, 1.000000);
    TextDrawColor(ConnectTD, -1),                                   TextDrawSetOutline(ConnectTD, 0);
    TextDrawSetProportional(ConnectTD, 1),                          TextDrawSetShadow(ConnectTD, 1);
    //--------------------------------------------------------------------------
    Textdraw14 = TextDrawCreate(548.000000, 22.000000, "31 Mar");   TextDrawBackgroundColor(Textdraw14, 255);
    TextDrawFont(Textdraw14, 3);                                    TextDrawLetterSize(Textdraw14, 0.500000, 1.700000);
    TextDrawColor(Textdraw14, -1);                                  TextDrawSetShadow(Textdraw14, 1);
    TextDrawSetOutline(Textdraw14, 0);                              TextDrawSetProportional(Textdraw14, 1);
    //--------------------------------------------------------------------------
    Textdraw15 = TextDrawCreate(573.000000, 35.000000, "00:00");    TextDrawBackgroundColor(Textdraw15, 255);
    TextDrawFont(Textdraw15, 2);                                    TextDrawLetterSize(Textdraw15, 0.500000, 1.700000);
    TextDrawColor(Textdraw15, -1);                                  TextDrawSetOutline(Textdraw15, 0);
    TextDrawSetProportional(Textdraw15, 1);                         TextDrawSetShadow(Textdraw15, 1);

    //--------------------------------------------------------------------------

    AddPlayerClass(217,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),    AddPlayerClass(122,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(23,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),     AddPlayerClass(28,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(101,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),    AddPlayerClass(115,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(116,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),    AddPlayerClass(53,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(78,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),     AddPlayerClass(134,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(135,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),    AddPlayerClass(137,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(93,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),     AddPlayerClass(192,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(193,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),    AddPlayerClass(12,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(55,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1),     AddPlayerClass(91,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

    //--------------------------------------------------------------------------
    format(ncStr, 10, "%02d %s",   serverData[Day], serverData[ncText]); TextDrawSetString(Textdraw14, ncStr);
    format(ncStr, 6, "%02d:%02d", serverData[Hour], serverData[Minute]); TextDrawSetString(Textdraw15, ncStr);
    //--------------------------------------------------------------------------
    SetTimer("UpdateTime", 60 * 1000, true);
    //--------------------------------------------------------------------------

    printf("%02d %s", serverData[Day], serverData[ncText]);

	return 1;
}

public OnGameModeExit() return mysql_close();


public OnPlayerConnect(playerid)
{

	ncStr[0] = '\0'; resetVar(playerid);
    new rColor = random(9);

    new gpcistring[42];
    format(gpcistring, 42, "Your GPCI: %s", ReturnGPCI(playerid));
    SendClientMessage(playerid, -1, gpcistring);
    mysql_format(dbConnect, ncStr, 144, "SELECT * FROM `Bans` WHERE `Name` = '%s' OR `IP` = '%s' ORDER BY `ID` DESC", sendName(playerid), sendIP(playerid));
    mysql_pquery(dbConnect, ncStr, "checkAccountBan", "d", playerid);

    ncStr[0] = NULL;
	format(ncStr, 150, "{00FF00}Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}, {FFFFFF}%s{00FF00}!\nPlease select a language to continue!", sendName(playerid));
	ShowPlayerDialog(playerid, ServerDialog, DIALOG_STYLE_MSGBOX, "Server's Language", ncStr, "Romana", "English");

    playerData[playerid][Level] = playerData[playerid][Respect] = 1;
    playerData[playerid][House] = -1;

	Textdraw16 = CreatePlayerTextDraw(playerid, 544.000000, 50.000000, "");     PlayerTextDrawBackgroundColor(playerid, Textdraw16, 255);
    PlayerTextDrawFont(playerid, Textdraw16, 2);                                PlayerTextDrawLetterSize(playerid, Textdraw16, 0.149999, 1.400000);
    PlayerTextDrawColor(playerid, Textdraw16, -1);                              PlayerTextDrawSetOutline(playerid, Textdraw16, 0);
    PlayerTextDrawSetProportional(playerid, Textdraw16, 1);                     PlayerTextDrawSetShadow(playerid, Textdraw16, 1);
    //---------------------------------------------------------------------------
    Textdraw13 = CreatePlayerTextDraw(playerid, 150.000000, 250.000000, "");    PlayerTextDrawBackgroundColor(playerid, Textdraw13, 255);
    PlayerTextDrawFont(playerid, Textdraw13, 2);                                PlayerTextDrawLetterSize(playerid, Textdraw13, 0.320000, 1.300000);
    PlayerTextDrawColor(playerid, Textdraw13, -1);                              PlayerTextDrawSetOutline(playerid, Textdraw13, 0);
    PlayerTextDrawSetProportional(playerid, Textdraw13, 1);                     PlayerTextDrawSetShadow(playerid, Textdraw13, 1);

    ncStr2[0] = '\0';              format(ncStr2, 30, "%s", sendName(playerid));
    PlayerTextDrawSetString(playerid, Textdraw13, ncStr2); PlayerTextDrawSetString(playerid, Textdraw16, ncStr2);

    switch(rColor)
    {
        case 0: SetPlayerColor(playerid, 0xFFFFFFAA); case 1: SetPlayerColor(playerid, 0xFF0000AA); case 2: SetPlayerColor(playerid, 0x0072FFAA);
        case 3: SetPlayerColor(playerid, 0xFFFFFFAA); case 4: SetPlayerColor(playerid, 0x00BBF6AA); case 5: SetPlayerColor(playerid, 0xAFAFAFAA);
        case 6: SetPlayerColor(playerid, 0xFF9900AA); case 7: SetPlayerColor(playerid, 0xFFEB7BAA); case 8: SetPlayerColor(playerid, 0xFFCC00AA);
    }
    //--------------------------------------------------------------------------
    TextDrawShowForPlayer(playerid, Textdraw0);     TextDrawShowForPlayer(playerid, Textdraw1);
    TextDrawShowForPlayer(playerid, Textdraw2);     TextDrawShowForPlayer(playerid, Textdraw3);
    TextDrawShowForPlayer(playerid, Textdraw4);     TextDrawShowForPlayer(playerid, Textdraw5);
    TextDrawShowForPlayer(playerid, Textdraw6);     TextDrawShowForPlayer(playerid, Textdraw7);
    TextDrawShowForPlayer(playerid, Textdraw8);     TextDrawShowForPlayer(playerid, Textdraw9);
    TextDrawShowForPlayer(playerid, Textdraw10);    TextDrawShowForPlayer(playerid, Textdraw11);
    TextDrawShowForPlayer(playerid, Textdraw12);    PlayerTextDrawShow(playerid,    Textdraw13);
    TextDrawShowForPlayer(playerid, Textdraw14);    TextDrawShowForPlayer(playerid, Textdraw15);

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    switch(classid)
    {
        case 0:  GameTextForPlayer(playerid, "~y~~h~Stunt man", 3000, 6); case 1:  GameTextForPlayer(playerid, "~r~~h~Pirate", 3000, 6); case 2:  GameTextForPlayer(playerid, "~y~~h~Skater", 3000, 6);
        case 3:  GameTextForPlayer(playerid, "~r~~h~Nigga", 3000, 6);     case 4:  GameTextForPlayer(playerid, "~y~~h~Civil", 3000, 6);  case 5:  GameTextForPlayer(playerid, "~r~~h~Mafia", 3000, 6);
        case 6:  GameTextForPlayer(playerid, "~y~~h~Mafia", 3000, 6);     case 7:  GameTextForPlayer(playerid, "~r~~h~Killer", 3000, 6); case 8:  GameTextForPlayer(playerid, "~y~~h~Pops", 3000, 6);
        case 9:  GameTextForPlayer(playerid, "~r~~h~Killer", 3000, 6);    case 10: GameTextForPlayer(playerid, "~y~~h~Killer", 3000, 6); case 11: GameTextForPlayer(playerid, "~y~~h~Z~r~~h~o~y~~h~m~r~~h~b~y~~h~i~r~~h~e", 3000, 6);
        case 12: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);      case 13: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);   case 14: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);
        case 15: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);      case 16: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);   case 17: GameTextForPlayer(playerid, "~p~~h~Girl", 3000, 6);
    }
    //--------------------------------------------------------------------------
    SetPlayerInterior(playerid, 7),                         SetPlayerPos(playerid, -1466.5, 1582.0, 1054.3),             SetPlayerFacingAngle(playerid, 115.9805),
    SetPlayerCameraPos(playerid, -1471.0, 1579.5, 1055.6),  SetPlayerCameraLookAt(playerid, -1465.5, 1582.5560, 1054.8), ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.0, 1, 0, 0, 0, 0),
    SetPlayerInterior(playerid, 14),                        PlayerPlaySound(playerid, 1183, 0.0, 0.0, 0.0),              SetPlayerAttachedObject(playerid, 0, 19078, 1, 0.329150, -0.072101, 0.156082, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
    //--------------------------------------------------------------------------
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success) {

    if(success == 1) 
        foreach(new ncID: Player)
            if(strcmp(ip, sendIP(ncID)) == 0) {
                getPlayerTag(ncID);
                return 1; 
            }
                //return ShowPlayerDialog(ncID, ServerDialog + 5, DIALOG_STYLE_PASSWORD, "{FF0000}Secondary RCON", "{FFFFFF}Please insert your {FF0000}secondary {FFFFFF}password to succeed.", "Done", "Cancel");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(playerData[playerid][VIP]  != 0) Iter_Remove(Vips,   playerid);
    if(adminData[playerid][Level] != 0) Iter_Remove(Admins, playerid);

	saveData(playerid);
    resetVar(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0); SetPlayerWeather(playerid, 2); SetPlayerHealth(playerid, 100);
    //--------------------------------------------------------------------------
    new rSpawn = random(8); switch(rSpawn)
    {
        case 0: SetPlayerPos(playerid, 404.2386,2453.6709,16.6602       ); // AA
        case 1: SetPlayerPos(playerid, 1887.8350,-2625.3059,13.6016     ); // LSAir
        case 2: SetPlayerPos(playerid, -1370.0363,-256.3452,18.7700     ); // SFAir
        case 3: SetPlayerPos(playerid, 1602.5377,1311.2509,13.6200      ); // LVAir
        case 4: SetPlayerPos(playerid, -2345.4111,-1623.9098,483.9355   ); // Chilliad
        case 5: SetPlayerPos(playerid, 1420.3746,2773.9958,11.0972      ); // Stunt Golf
        case 6: SetPlayerPos(playerid, -2272.3455,2318.3928,4.5575      ); // Pimps
        case 7: SetPlayerPos(playerid, -2625.1626,1361.3967,7.0816      ); // Jizzy's
    }
    //GetPlayerPos(playerid, antiTP[PrevX], antiTP[PrevY], antiTP[PrevZ]);
    for(new i = 1; i < 35; ++i)
        GivePlayerWeapon(playerid, i, 9999);
    GivePlayerWeapon(playerid, 24, 9999);
    GivePlayerWeapon(playerid, 31, 9999);
    GivePlayerWeapon(playerid, 33, 9999);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    SendDeathMessage(killerid, playerid, reason);

    playerData[playerid][Deaths]++; playerData[killerid][Kills]++;

	return 1;
}

//Dialogs

//Comenzi RCON


CMD:set(playerid, params[]) {

    new ncSet[15], ncID, ncAmount, ok;

    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, RED, "KOS-ERROR: Only RCONS can use that command.");

    if(sscanf(params, "s[10]ud", ncSet, ncID, ncAmount))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /Set [Level, Coins, Respect, ...][PlayerID][Amount]");

    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected.");

    if(strcmp("admin", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0 || ncAmount > 6)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified level is too high/low(0-6).");

        if(adminData[playerid][Level] == 0) {

            ncStr[0] = NULL;

            mysql_format(dbConnect, ncStr, 128, "INSERT INTO `admins` (`Name`, `Level`) VALUES ('%s', '%d')", sendName(ncID), ncAmount);
            mysql_tquery(dbConnect, ncStr, "GetAdminID", "d", playerid);

            Iter_Add(Admins, ncID);
        }

        adminData[ncID][Level] = ncAmount;

        if(ncAmount == 0 && strcmp(adminData[playerid][RCONPass], "None") == 0) {
            
            ncStr[0] = NULL;

            mysql_format(dbConnect, ncStr, 128, "DELETE FROM `admins` WHERE `ID` = '%d'", adminData[playerid][ID]);
            mysql_tquery(dbConnect, ncStr);

            adminData[playerid][ID] = 0;

            Iter_Remove(Admins, ncID);
        }

        strcpy(ncSet, "Admin Level");

    }else if(strcmp("vip", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0 || ncAmount > 5)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified level is too high/low(0-5).");

        if(ncAmount == 0) Iter_Remove(Vips, ncID);
        else Iter_Add(Vips, ncID);

        playerData[playerid][VIP] = ncAmount;

        strcpy(ncSet, "VIP Level");

    }else if(strcmp("level", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 1)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified level is too low.");

        playerData[playerid][Level] = ncAmount;

        strcpy(ncSet, "Level");

    }else if(strcmp("respect", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified amount is too low.");

        playerData[playerid][Respect] = ncAmount;

        strcpy(ncSet, "Respect Points");

    }else if(strcmp("coins", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified amount is too low.");

        playerData[playerid][Coins] = ncAmount;

        strcpy(ncSet, "Coins");
    }else if(strcmp("hours", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified amount is too low.");

        playerData[playerid][Hours] = ncAmount;

        strcpy(ncSet, "Hours");
    }else if(strcmp("neacristy", ncSet, true) == 0) {

        ok = 1;

        if(ncAmount < 0 || ncAmount > 3)
            return SendClientMessage(playerid, RED, "KOS-ERROR: The specified amount is too low/high.");
        adminData[playerid][neacristy] = ncAmount;
    }
    if(ok == 1) {

        ncStr[0] = NULL;

        PlayerPlaySound(ncID,1057,0.0,0.0,0.0);
        format(ncStr, 128, "{33AA33}Administrator %s has setted your %s to %d.", sendName(playerid), ncSet, ncAmount);
        SendClientMessage(ncID, GREEN, ncStr);

        ncStr[0] = NULL;

        format(ncStr, 128, "{33AA33}You have setted %s's %s to %d.", sendName(ncID), ncSet, ncAmount);
        SendClientMessage(playerid, GREEN, ncStr);

        getPlayerTag(ncID);
    }
    else 
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /Set [Level, Coins, Respect, ...][PlayerID][Amount]");

    return 1;

}

CMD:giverconpass(playerid, params[]) {

    new ncID, ncPass[24];
    if(adminData[playerid][neacristy] != 3)
        return 0;
    if(sscanf(params, "us[24]", ncID, ncPass))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /giverconpass [PlayerID][Password]");
    if(!IsPlayerConnected(ncID))
        return 0;

    format(adminData[ncID][RCONPass], 24, ncPass);

    ncStr[0] = NULL;
    mysql_format(dbConnect, ncStr, 128, "UPDATE `accounts` SET `RCONPass` = SHA1('%s') WHERE `ID` = '%d'", ncPass, playerData[ncID][ID]);

    SendClientMessage(ncID, LIME, "Founder has set you a new password for RCON logins.");
    SendClientMessage(playerid, -1, "You have setted the new password for rcon logins");

    return 1;
}

//Comenzi Admin

CMD:warn(playerid, params[]) {

    new ncID, ncReason[128];
    if(adminData[playerid][Level] < 2)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 2 to use this command.");
    if(sscanf(params, "us[128]", ncID, ncReason))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /Warn [PlayerID][Reason]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(ncID == playerid)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are unable to warn yourself.");
    if(adminData[ncID][Level] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't warn another admins.");

    playerData[ncID][Warns]++;
    adminData[playerid][Warns]++;

    format(ncStr, 144, "Admin {FF0000}%s {00FF00}warned {00BBF6}%s{00FF00}. Reason: {00BBF6}%s {00FF00}(Warns: {00BBF6}%d/5{00FF00})", sendName(playerid), sendName(ncID), ncReason, playerData[ncID][Warns]);
    SendClientMessageToAll(LIME, ncStr);

    if(playerData[ncID][Warns] == 5) {
        banData[ncID][BanDate] = gettime() + 3 * 86400;
        ncStr[0] = NULL;
        mysql_format(dbConnect, ncStr, 144, "INSERT INTO `bans` (`Name`, `Admin`, `BanDate`, `Time`, `Reason`, `IP`) VALUES ('%s', 'KOS-BOT', '%d', '%d', 'Exceeded warn limit', '%s')",
            sendName(ncID), gettime(), banData[ncID][BanDate],  sendIP(ncID));
        mysql_pquery(dbConnect, ncStr);

        ncStr2[0] = NULL;
        SendClientMessageToAll(Blue, "----------KOS-BOT----------");
        format(ncStr2, 150, "KOS-BOT {CEC8C8}has banned {00BBF6}%s {CEC8C8}for {FF0000}3 {CEC8C8}day(s).", sendName(ncID));
        SendClientMessageToAll(RED, ncStr2);
        format(ncStr2, 150, "Reason: {00BBF6}Exceeded warn limit.");
        SendClientMessageToAll(GREY, ncStr2);
        SendClientMessageToAll(Blue, "---------------------------");


        for(new l; l < 20; l++) SendClientMessage(ncID, -1, "");

        if(playerData[ncID][Language] == 1) {
            SendClientMessage(ncID, Blue, "----------KOS-BOT----------");
            format(ncStr2, 150, "Ai primit interdictie de la {00BBF6}KOS-BOT {CEC8C8}pentru {FF0000}3 {CEC8C8}zile.");
            SendClientMessage(ncID, GREY, ncStr2);
            format(ncStr2, 150, "Motiv: {CEC8C8}Ai depasit limita advertismentelor.");
            SendClientMessage(ncID, LBLUE, ncStr2);
            format(ncStr2, 200, "Pentru UnBan, fa o cerere pe {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}cu numele {FF0000}%s {CEC8C8}si IP-ul {00BBF6}%s", sendName(ncID), sendIP(ncID));
            SendClientMessage(ncID, GREY, ncStr2);
            SendClientMessage(ncID, Blue, "---------------------------");
        }
        else if(playerData[ncID][Language] == 2) {
            SendClientMessage(ncID, Blue, "----------KOS-BOT----------");
            format(ncStr2, 150, "You have been banned by {00BBF6}KOS-BOT {CEC8C8}for {FF0000}%d {CEC8C8}day(s).");
            SendClientMessage(ncID, GREY, ncStr2);
            format(ncStr2, 150, "Reason: {CEC8C8}Exceeded warn limit..");
            SendClientMessage(ncID, LBLUE, ncStr2);
            format(ncStr2, 200, "For UnBan, make a request on {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}with the name {FF0000}%s {CEC8C8}and IP {00BBF6}%s", sendName(ncID), sendIP(ncID));
            SendClientMessage(ncID, GREY, ncStr2);
            SendClientMessage(ncID, Blue, "---------------------------");
        }
        SetTimerEx("KickEx", 50, false, "d", ncID);
    }
    return 1;
}

CMD:mute(playerid, params[]) {
    new ncID, ncReason[128];
    if(adminData[playerid][Level] < 1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 1 to use this command.");
    if(sscanf(params, "us[128]", ncID, ncReason))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /Mute [PlayerID][Reason]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(ncID == playerid)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are unable to mute yourself.");
    if(adminData[ncID][Level] != 0 && !IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't mute another admins.");

    playerData[ncID][Mute] = 3;
    adminData[playerid][Mutes]++;

    ncStr[0] = NULL;

    format(ncStr, 144, "Administrator {FF0000}%s {00FF00}muted {00BBF6}%s {00FF00}(Reason: {00BBF6}%s{00FF00})", sendName(playerid), sendName(ncID), ncReason);
    SendClientMessageToAll(LIME, ncStr);

    return 1;
}
CMD:unmute(playerid, params[]) {
    new ncID;
    if(adminData[playerid][Level] < 1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 2 to use this command.");
    if(sscanf(params, "u", ncID))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /Mute [PlayerID]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(playerData[ncID][Mute] == 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified players is not mutted.");

    playerData[ncID][Mute] = 0;

    format(ncStr, 144, "Administrator {FF0000}%s {00FF00}un-muted {00BBF6}%s.", sendName(playerid), sendName(ncID));
    SendClientMessageToAll(LIME, ncStr);

    GameTextForPlayer(ncID, "You have been unmutted", 3000, 6);
    return 1;
}

CMD:ban(playerid, params[]) {

    new ncID, ncDays, ncReason[128];
    if(adminData[playerid][Level] < 3)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 3 to use this command.");
    if(sscanf(params, "uds[128]", ncID, ncDays, ncReason))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /Ban [PlayerID][Days][Reason]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(ncID == playerid)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are unable to ban yourself.");
    if(adminData[ncID][Level] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't ban another admins.");
    if(ncDays < 1 && ncDays > 100)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The numbers of ban days is invalid(1-100).");

    banData[ncID][BanDate] = gettime() + ncDays * 86400;
    ncStr[0] = NULL;
    mysql_format(dbConnect, ncStr, 144, "INSERT INTO `bans` (`Name`, `Admin`, `BanDate`, `Time`, `Reason`, `IP`) VALUES ('%s', '%s', '%d', '%d', '%s', '%s')",
        sendName(ncID), sendName(playerid), gettime(), banData[ncID][BanDate], ncReason, sendIP(ncID));
    mysql_pquery(dbConnect, ncStr);

    ncStr2[0] = NULL;
    SendClientMessageToAll(Blue, "--------------------KOS-BOT--------------------");
    format(ncStr2, 150, "%s {CEC8C8}has banned {00BBF6}%s {CEC8C8}for {FF0000}%d {CEC8C8}day(s).", sendName(playerid), sendName(ncID), ncDays);
    SendClientMessageToAll(RED, ncStr2);
    format(ncStr2, 150, "Reason: {00BBF6}%s.", ncReason);
    SendClientMessageToAll(GREY, ncStr2);
    SendClientMessageToAll(Blue, "-----------------------------------------------");

    for(new l; l < 20; l++) SendClientMessage(ncID, -1, "");

    if(playerData[ncID][Language] == 1) {
        SendClientMessage(ncID, Blue, "--------------------KOS-BOT--------------------");
        format(ncStr2, 150, "Ai primit interdictie de la {00BBF6}%s {CEC8C8}pentru {FF0000}%d {CEC8C8}zile.", sendName(playerid), ncDays);
        SendClientMessage(ncID, GREY, ncStr2);
        format(ncStr2, 150, "Motiv: {CEC8C8}%s.", ncReason);
        SendClientMessage(ncID, LBLUE, ncStr2);
        format(ncStr2, 200, "Pentru UnBan, fa o cerere pe {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}cu numele {FF0000}%s {CEC8C8}si IP-ul {00BBF6}%s", sendName(ncID), sendIP(ncID));
        SendClientMessage(ncID, GREY, ncStr2);
        SendClientMessage(ncID, Blue, "-----------------------------------------------");
    }
    else if(playerData[ncID][Language] == 2) {
        SendClientMessage(ncID, Blue, "--------------------KOS-BOT--------------------");
        format(ncStr2, 150, "You have been banned by {00BBF6}%s {CEC8C8}for {FF0000}%d {CEC8C8}day(s).", sendName(playerid), ncDays);
        SendClientMessage(ncID, GREY, ncStr2);
        format(ncStr2, 150, "Reason: {CEC8C8}%s.", ncReason);
        SendClientMessage(ncID, LBLUE, ncStr2);
        format(ncStr2, 200, "For UnBan, make a request on {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}with the name {FF0000}%s {CEC8C8}and IP {00BBF6}%s", sendName(ncID), sendIP(ncID));
        SendClientMessage(ncID, GREY, ncStr2);
        SendClientMessage(ncID, Blue, "-----------------------------------------------");
    }
    adminData[playerid][Bans]++;
    SetTimerEx("KickEx", 50, false, "d", ncID);
    return 1;
}

CMD:kick(playerid, params[]) { 

    new ncID, ncReason[128];
    if(adminData[playerid][Level] < 2)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 2 to use this command.");
    if(sscanf(params, "us[128]", ncID, ncReason))
        return SendClientMessage(playerid, RED, "KOS-USAGE: /Kick [PlayerID][Reason]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(ncID == playerid)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are unable to kick yourself.");
    if(adminData[ncID][Level] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't kick another admins.");

    format(ncStr, 869, "Admin {00BBF6}%s {CEC8C8}kicked {00BBF6}%s{CEC8C8}. Reason: {00BBF6}%s", sendName(playerid), sendName(ncID), ncReason);
    SendClientMessageToAll(GREY, ncStr);

    SetTimerEx("KickEx", 50, false, "d", ncID);
    adminData[playerid][Kicks]++;
    return 1;
}

CMD:cc(playerid, params[]) {

    if(adminData[playerid][Level] < 1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least admin level 2 to use this command.");

    for(new i = 0; i < 20; ++i)
        SendClientMessageToAll(WHITE, " ");
    ++adminData[playerid][ChatsCleared];
    return 1;
}

CMD:clearchat(playerid, params[]) return cmd_cc(playerid, params);

//Comenzi Vip

//Comnezi Jucatori normali

CMD:cmds(playerid) {
    ncStr[0] = EOS; ncStr2[0] = EOS;
    
    switch(playerData[playerid][Language]) {
        case 2: {
            format(ncStr2, 200, "{00FF00}Hello, {FF0000}%s{00FF00}! Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}If you ever wondered what commands are on the server, below it's a list with them:\n\n", 1900);
            strcat(ncStr, "{0072BB}Commands with informative role: \n", 1900);
            strcat(ncStr, "{FF0000}/cmds \t{00FF00}- \t{FFFFFF}It shows you a list of the server's commands.\n", 1900);
            strcat(ncStr, "{FF0000}/credits \t{00FF00}- \t{FFFFFF}It shows you a list with the server's creators.\n", 1900);
            strcat(ncStr, "{FF0000}/help \t{00FF00}- \t{FFFFFF}It shows you some information about the server.\n", 1900);
            strcat(ncStr, "{FF0000}/rules \t{00FF00}- \t{FFFFFF}It shows you a list with the server's rules.\n", 1900);
            strcat(ncStr, "{FF0000}/teles \t{00FF00}- \t{FFFFFF}It shows you a list with the server's teleportations.\n", 1900);
            strcat(ncStr, "{FF0000}/acmds \t{00FF00}- \t{FFFFFF}It shows you a list of the server's admin commands.\n", 1900);
            strcat(ncStr, "{FF0000}/vcmds \t{00FF00}- \t{FFFFFF}It shows you a list with the server's VIP commands.\n", 1900);
            strcat(ncStr, "{FF0000}/gang \t{00FF00}- \t{FFFFFF}It shows you a list of the gang's commads.\n", 1900);
            strcat(ncStr, "{FF0000}/v \t{00FF00}- \t{FFFFFF}It shows you a list with the server's cars.\n\n", 1900);
            format(ncStr2, 200, "{00FF00}Thank you, {FF0000}%s{00FF00} for playing on our server. We're honored to serve you. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}And, don't forget! If you have a dilemma, use {FF0000}/n{00FF00} to ask a question to our admins!\n");
        }
        case 1: {
            format(ncStr2, 200, "{00FF00}Salut, {FF0000}%s{00FF00}! Bine ai venit pe {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Daca te-ai intrebat vreodata care sunt comenzile serverului, aici este o lista cu acestea:\n\n", 1900);
            strcat(ncStr, "{0072BB}Comenzi cu rol informativ: \n", 1900);
            strcat(ncStr, "{FF0000}/cmds \t{00FF00}- \t{FFFFFF}Iti arata o lista cu comenzile serverului.\n", 1900);
            strcat(ncStr, "{FF0000}/credits \t{00FF00}- \t{FFFFFF}Iti arata o lista cu creatorii serverului.\n", 1900);
            strcat(ncStr, "{FF0000}/help \t{00FF00}- \t{FFFFFF}Iti arata niste informatii despre server.\n" , 1900);
            strcat(ncStr, "{FF0000}/rules \t{00FF00}- \t{FFFFFF}Iti arata o lista cu regulile serverului.\n" , 1900);
            strcat(ncStr, "{FF0000}/teles \t{00FF00}- \t{FFFFFF}Iti arata o lista cu teleportarile serverului.\n" , 1900);
            strcat(ncStr, "{FF0000}/acmds \t{00FF00}- \t{FFFFFF}Iti arata o lista cu comenzile pentru admin ale serverului.\n" , 1900);
            strcat(ncStr, "{FF0000}/vcmds \t{00FF00}- \t{FFFFFF}Iti arata o lista cu comenzile pentru VIP ale serverului.\n" , 1900);
            strcat(ncStr, "{FF0000}/gang \t{00FF00}- \t{FFFFFF}Iti arata o lista cu comenzile gangurilor.\n" , 1900);
            strcat(ncStr, "{FF0000}/v \t{00FF00}- \t{FFFFFF}Iti arata o lista cu masinile serverului.\n\n" , 1900);
            format(ncStr2, 200, "{00FF00}Multumim, {FF0000}%s{00FF00} pentru ca joci pe serverul nostru. Suntem onorati sa te servim. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Si, nu uita! Daca ai vreo dilema, foloseste {FF0000}/n{00FF00} sa pui o intrebare adminilor!\n");
        }
    }
    return ShowPlayerDialog(playerid, ServerDialog + 1, DIALOG_STYLE_MSGBOX, "Server Commands", ncStr, "Close", "");
}


CMD:credits(playerid) {
    ncStr[0] = EOS; ncStr2[0] = EOS;

    switch(playerData[playerid][Language]) {
        case 2: {
            format(ncStr2, 200, "{00FF00}Hello, {FF0000}%s{00FF00}! Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}If you ever wondered who created or helped the server, below it's a list with them:\n\n", 1900);
            strcat(ncStr, "{FF0000}Owners:\n{FFFFFF}[KoS]NeaCristy\n\n{FF0000}Scripters:\n{FFFFFF}[KoS]NeaCristy\n\n{FF0000}Mappers:\n\n\n", 1900);
            strcat(ncStr, "{FF0000}Site & Forum ({00FF00}www.Kingdom-of-Stunt.ro{FF0000}):\n{FFFFFF}[KOS]NeaCristy\n{FFFFFF}Invision Power Board Team\n\n", 1900);
            strcat(ncStr, "{FF0000}Special Thanks:\n{FFFFFF}SA-MP Team\n{FFFFFF}Zeex(ZCMD)\n{FFFFFF}Y_Less(SSCanf & Foreach)\n{FFFFFF}pBlueG(MySQL)\n{FFFFFF}Incognito(Streamer)\n\n", 1900);
            format(ncStr2, 1900, "{FF0000}Best Player:\n{FFFFFF}%s\n\n", sendName(playerid));
            strcat(ncStr, ncStr2, 1900);
            format(ncStr2, 200, "{00FF00}Thank you, {FF0000}%s{00FF00} for playing on our server. We're honored to serve you. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}And, don't forget! If you have a dilemma, use {FF0000}/n{00FF00} to ask a question to our admins!\n");
        }
        case 1: {
            format(ncStr2, 200, "{00FF00}Salut, {FF0000}%s{00FF00}! Bine ai venit pe {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Daca te-ai intrebat vreodata cine a creat sau a ajutat serverul, aici este o lista cu acestia:\n\n", 1900);
            strcat(ncStr, "{FF0000}Detinatori:\n{FFFFFF}[KoS]NeaCristy\n\n{FF0000}Scripteri:\n{FFFFFF}[KoS]NeaCristy\n\n{FF0000}Creatorii hartilor:\n\n\n", 1900);
            strcat(ncStr, "{FF0000}Site & Forum ({00FF00}www.Kingdom-of-Stunt.ro{FF0000}):\n{FFFFFF}[KOS]NeaCristy\n{FFFFFF}Invision Power Board Team\n\n", 1900);
            strcat(ncStr, "{FF0000}Multumiri speciale:\n{FFFFFF}SA-MP Team\n{FFFFFF}Zeex(ZCMD)\n{FFFFFF}Y_Less(SSCanf & Foreach)\n{FFFFFF}pBlueG(MySQL)\n{FFFFFF}Incognito(Streamer)\n\n", 1900);
            format(ncStr2, 1900, "{FF0000}Cel mai bun jucator:\n{FFFFFF}%s\n\n", sendName(playerid));
            strcat(ncStr, ncStr2, 1900);
            format(ncStr2, 200, "{00FF00}Multumim, {FF0000}%s{00FF00} pentru ca joci pe serverul nostru. Suntem onorati sa te servim. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Si, nu uita! Daca ai vreo dilema, foloseste {FF0000}/n{00FF00} sa pui o intrebare adminilor!\n");
        }
    }
    return ShowPlayerDialog(playerid, ServerDialog + 1, DIALOG_STYLE_MSGBOX, "Credits", ncStr, "Close", "");
}

CMD:help(playerid)
{
    ncStr[0] = '\0'; ncStr2[0] = '\0';
    //--------------------------------------------------------------------------
    switch(playerData[playerid][Language]) {
        case 1: {
            format(ncStr2, 200, "{FFFFFF}Salut, {FF0000}%s{FFFFFF}! Bine ai venit pe {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{FFFFFF}.\n\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{FF0000}Informatii Generale:\n\
                            {FFFFFF}Serverul nostru este un server de {FF0000}Stunt{FFFFFF} combinat cu elemente {FF0000}RPG{FFFFFF}.\n\
                            {FFFFFF}Unul din ele, dupa cum vezi, este sistemul de {FF0000}Nivel al Contului{FFFFFF}, care este un sistem cheie pentru cateva sisteme ale serverului.\n\
                            {FFFFFF}La nivelul 5, poti avea o {FF0000}masina personala {FFFFFF}care poate fi cumparata cu {FF0000}coins{FFFFFF}.\n\n", 1900);
            strcat(ncStr, "{FF0000}Activitatea Contului:\n\
                            {FFFFFF}De fiecare data cand o ora trece, iti vei primi {FF0000}salariul{FFFFFF}. Ce inseamna asta?\n\
                            {FFFFFF}Vei primi un{FF0000}Respect Point{FFFFFF} care te va ajuta sa avansezi in nivel.\n\
                            {FFFFFF}Timpul tau online va fi contorizat de la conectare pana acum.\n\
                            {FFFFFF}Vei primi niste coins si o suma de bani\n\n", 1900);
            strcat(ncStr, "{FF0000}Comenzi folositoare:\n\
                            {FFFFFF}/{FF0000}cmds{FFFFFF}  - Iti arata o lista cu toate comenzile serverului.\n\
                            {FFFFFF}/{FF0000}rules{FFFFFF} - Iti arata regulile serverului si programele/modurile permise.\n\
                            {FFFFFF}/{FF0000}teles{FFFFFF} - Iti arata o lista cu toate zonele serverului.\n\
                            {FFFFFF}/{FF0000}car{FFFFFF}(/v) - Iti arata o lista cu toate masinile serverului.\n\n", 1900);
            format(ncStr2, 200, "{FFFFFF}Multumim, {FF0000}%s{FFFFFF} pentru ca joci pe serverul nostru. Suntem onorati sa te servim. Be nice and {FF0000}have fun{FFFFFF}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{FFFFFF}Si, nu uita! Daca ai vreo dilema, foloseste {FF0000}/n{FFFFFF} sa pui o intrebare adminilor!\n");
        }
        case 2: {
            format(ncStr2, 200, "{FFFFFF}Hello, {FF0000}%s{FFFFFF}! Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{FFFFFF}.\n\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{FF0000}General information:\n\
                            {FFFFFF}Our server is a {FF0000}Stunt{FFFFFF} server combined with {FF0000}RPG{FFFFFF} elements.\n\
                            {FFFFFF}One of them, as you see, is the {FF0000}Account Level {FFFFFF}system, wich is a key system for some of server's systems.\n\
                            {FFFFFF}At level 5 you can have your own {FF0000}personal car {FFFFFF}wich can be bought by {FF0000}coins{FFFFFF}.\n\n", 1900);
            strcat(ncStr, "{FF0000}Account Activity:\n\
                            {FFFFFF}Everytime a hour passes, you'll get your {FF0000}payday{FFFFFF}. What means that?\n\
                            {FFFFFF}You'll get a {FF0000}Respect Point{FFFFFF} wich will help you to advance in level.\n\
                            {FFFFFF}Your online time will be saved from connect time till now.\n\
                            {FFFFFF}You'll recieve some coins and some money!\n\n", 1900);
            strcat(ncStr, "{FF0000}Usefull commands:\n\
                            {FFFFFF}/{FF0000}cmds{FFFFFF}  - Shows you a list with all server's commands.\n\
                            {FFFFFF}/{FF0000}rules{FFFFFF} - Shows you server's rules and allowed programs/mods.\n\
                            {FFFFFF}/{FF0000}teles{FFFFFF} - Shows you a list with all server's zones.\n\
                            {FFFFFF}/{FF0000}car{FFFFFF}(/v) - Shows you a list with all server's cars.\n\n", 1900);
            format(ncStr2, 200, "{FFFFFF}Thank you, {FF0000}%s{FFFFFF} for playing on our server. We're honored to serve you. Be nice and {FF0000}have fun{FFFFFF}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{FFFFFF}And, don't forget! If you have a dilemma, use {FF0000}/n{FFFFFF} to ask a question to our admins!\n");           
        }
    }
    return ShowPlayerDialog(playerid, ServerDialog + 1, DIALOG_STYLE_MSGBOX, "Server Help", ncStr, "Close", "");
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{

    new spamTime;

    if(playerData[playerid][AFK] == true) 
        return GameTextForPlayer(playerid, "~w~~h~Type ~r~~h~/back~n~~w~~h~to use ~n~~r~~h~commands~w~~h~!", 4000, 4), 0;
    if(playerData[playerid][loggedIn] == false)
        return GameTextForPlayer(playerid, "~r~~h~You are not logged in. Please reconnect!", 4000, 4), 0;

    if(playerData[playerid][VIP] < 4) {

        if(gettime() - playerData[playerid][CommandSpam] < 2) {

            spamTime = 2 - gettime() + playerData[playerid][CommandSpam];
            format(ncStr, 128 , "Please wait {00FF00}%d{FF0000} Second(s) to type another command!", spamTime);
            SendClientMessage(playerid, RED, ncStr);
            return 0;
        }
        else playerData[playerid][CommandSpam] = gettime();
    }

    return 1;

}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(success == 0)
    {
        ncStr[0] = '\0'; ncStr2[0] = '\0';
        //----------------------------------------------------------------------
        format(ncStr,  350, "Comanda {00FF00}%s {FF0000}nu exista! Incearca {00FF00}/help {FF0000}sau {00FF00}/cmds{FF0000}!", cmdtext);
        format(ncStr2, 350, "Command {00FF00}%s {FF0000}doesn't exists! Please try {00FF00}/help {FF0000}or {00FF00}/cmds{FF0000}!", cmdtext);
        //----------------------------------------------------------------------
        return SendClientMessage(playerid, RED, (playerData[playerid][Language] == 1) ? ncStr : ncStr2);
    }
    return 1;
}

public OnPlayerText(playerid, text[]) {

    if(playerData[playerid][AFK] == true || playerData[playerid][Mute] > 0 || playerData[playerid][loggedIn] == false) {

        if(playerData[playerid][AFK] == true)
            return GameTextForPlayer(playerid, "~w~~h~Type ~r~~h~/back~n~~w~~h~to use the~n~~r~~h~Chat~w~~h~!", 4000, 4), 0;

        else if(playerData[playerid][Mute] > 0)
            return GameTextForPlayer(playerid, "~r~~h~You are muted right now!", 4000, 4), 0;

        return GameTextForPlayer(playerid, "~r~~h~You are not logged in. Please reconnect!", 4000, 4), 0;
    }
    
    new spamTime;

    if(playerData[playerid][VIP] < 3) {
        if(gettime() - playerData[playerid][ChatSpam] < 4) {

            spamTime = 4 - gettime() + playerData[playerid][ChatSpam];
            format(ncStr, 128, "Please wait {00FF00}%d{FF0000} Second(s) to write something again!", spamTime);
            SendClientMessage(playerid, RED, ncStr);
            return 0;
        }
        else playerData[playerid][ChatSpam] = gettime();
    }else if(playerData[playerid][VIP] < 4) {

        if(gettime() - playerData[playerid][ChatSpam] < 3) {

            spamTime = 3 - gettime() + playerData[playerid][ChatSpam];
            format(ncStr, 128, "Please wait {00FF00}%d{FF0000} Second(s) to write something again!", spamTime);
            SendClientMessage(playerid, RED, ncStr);
            return 0;
        }
        else playerData[playerid][ChatSpam] = gettime();
    }else if(playerData[playerid][VIP] < 5) {

        if(gettime() - playerData[playerid][ChatSpam] < 2) {

            spamTime = 2 - gettime() + playerData[playerid][ChatSpam];
            format(ncStr, 128, "Please wait {00FF00}%d{FF0000} Second(s) to write something again!", spamTime);
            SendClientMessage(playerid, RED, ncStr);
            return 0;
        }
        else playerData[playerid][ChatSpam] = gettime();
    }
    else if(playerData[playerid][VIP] == 5) {
        if(gettime() - playerData[playerid][ChatSpam] < 1) {

            spamTime = 1 - gettime() + playerData[playerid][ChatSpam];
            format(ncStr, 128, "Please wait {00FF00}%d{FF0000} Second(s) to write something again!", spamTime);
            SendClientMessage(playerid,RED, ncStr);
            return 0;
        }
        else playerData[playerid][ChatSpam] = gettime();
    }


    if(text[0] == '@' && adminData[playerid][Level] > 0) {
        format(ncStr, 144, "[Admin Chat] {FF4400}%s: {15FF00}%s", sendName(playerid), text[1]);
        SendMessageToAdmins(ORANGE, ncStr);
        return 0;
    }else if(text[0] == '#' && playerData[playerid][VIP] > 2) {
        format(ncStr, 144, "[VIP Chat] {FF4400}%s: {15FF00}%s", sendName(playerid), text[1]);
        SendMessageToVIPs(ORANGE, ncStr);
        return 0;
    }/*else if(text[0] == '!' && gangData[playerid][ID] != 0) {
        format(ncStr, 144, "[Gang Chat] {FF4400}%s: {15FF00}%s", sendName(playerid), text[1]);
        foreach(new ncID: Player) 
            if(gangData[playerid][ID] == gangData[ncID][ID]) 
                SendClientMessage(ncID, ORANGE, ncStr);
        return 0;
    } */

    format(ncStr, 200, "%s%s{00FF00}(%d):{FFFFFF} %s", sendName(playerid), playerData[playerid][ChatTag], playerid, text);

    SendClientMessageToAll(GetPlayerColor(playerid), ncStr);
    SetPlayerChatBubble(playerid, text, LIME, 50.0, 5000);
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid) {

		case ServerDialog: {
			if(response) {
				playerData[playerid][Language] = 1; //RO
				ncStr[0] = EOS;
				mysql_format(dbConnect, ncStr, 256, "SELECT `Name` FROM `accounts` WHERE `Name` = '%e' LIMIT 1", sendName(playerid));
				mysql_pquery(dbConnect, ncStr, "OnAccountCheck", "d", playerid);
			}
			else {
				playerData[playerid][Language] = 2; //EN
				ncStr[0] = EOS;
				mysql_format(dbConnect, ncStr, 256, "SELECT `Name` FROM `accounts` WHERE `Name` = '%e' LIMIT 1", sendName(playerid));
				mysql_pquery(dbConnect, ncStr, "OnAccountCheck", "d", playerid);
			}
		}
		case ServerDialog + 1: {
			if(response) return 1;
		}
        case ServerDialog + 5: {
            if(!response) return SetTimerEx("KickEx", 50, false, "d", playerid);
            else {
                ncStr[0] = EOS;
                mysql_format(dbConnect, ncStr, 256, "SELECT * FROM `accounts` WHERE `ID` = '%d' AND `RCONPass` = SHA1('%s')", playerData[playerid][ID], inputtext);
                mysql_pquery(dbConnect, ncStr, "OnRconCheck", "d", playerid);
            }
        }
		case AccountDialog: {
			if(response) {
				ncStr[0] = EOS;
				mysql_format(dbConnect, ncStr, 256, "SELECT * FROM `accounts` WHERE `Name` = '%e' AND `Password` = SHA1('%s')", sendName(playerid), inputtext);
				mysql_pquery(dbConnect, ncStr, "OnLoginCheck", "d", playerid);
			}
			else {
				SendClientMessage(playerid, -1, "Coming Soon");
				Kick(playerid);
			}
		}
		case AccountDialog + 1: {
			if(!response) return SetTimerEx("KickEx", 50, false, "d", playerid);
			else {
				ncStr[0] = EOS; ncStr2[0] = EOS;
				if(strlen(inputtext) < 3 || strlen(inputtext) > 24) {
					switch(playerData[playerid][Language]) {
						case 1: {
							format(ncStr, 390, "{00FF00}Bine ai venit, {FF0000}%s{00FF00}!\n\nSuntem fericiti ca ai ales serverul nostru, si iti recomandam sa-l adaugi la {FFFFFF}Favorite{00FF00}: {FF0000}93.119.26.252:7777\n\
							{00FF00}Pentru inceput te rugam sa te inregistrezi cu o {FF0000}parola {00FF00}grea pe care doar tu sa o stii pentru a te autentifica! ({FF0000}intre 3-25 de caractere{00FF00}): \n", sendName(playerid));
							ShowPlayerDialog(playerid, AccountDialog+1, DIALOG_STYLE_PASSWORD, "Inregistrare", ncStr, "Gata", "Anuleaza");
						}
						case 2: {
							format(ncStr, 390, "{00FF00}Welcome, {FF0000}%s{00FF00}!\n\nWe're glad to see that you chose our server, and we're recommending you to add it on {FFFFFF}Favourites{00FF00}: {FF0000}93.119.26.252:7777\n\
							{00FF00}On the beggining, please register with a hard password that only you will know!({FF0000}Min. 3 - Max. 25 characters{FFFF00}): \n", sendName(playerid));
							ShowPlayerDialog(playerid, AccountDialog+1, DIALOG_STYLE_PASSWORD, "Register", ncStr, "Done", "Cancel");
						}
					}
				}
				OnAccountRegister(playerid, inputtext);
			}
		}
		case AccountDialog + 2: {
			if(response) return cmd_help(playerid);
			else return 1;
		}
		case AccountDialog + 3: {
			if(strval(inputtext) == playerData[playerid][Pin]) {
				playerData[playerid][Security] = 0;
				ncStr[0] = EOS;
				mysql_format(dbConnect, ncStr, 256, "SELECT * FROM `accounts` WHERE `Name` = '%e'", sendName(playerid));
				mysql_pquery(dbConnect, ncStr, "OnLoadData", "d", playerid);
			}
			else {
				ncStr[0] = EOS; ncStr2[0] = EOS;

				if(playerData[playerid][Language] == 1)
				{
				    ++playerData[playerid][FailedLogins];
				    //------------------------------------------------------------------
				    format(ncStr2, 500, "{FF0000}Autentificare esuata (%d/3)!\n\n{FFCC00}Ai introdus un pin gresit! Te rugam sa incerci din nou!\n{00FF00}Daca nu-ti stii pinul, viziteaza {FF0000}%s{00FF00} pentru a-l obtine!", playerData[playerid][FailedLogins], playerData[playerid][EMail]);
				    strcat(ncStr, ncStr2, 500);
				    //------------------------------------------------------------------
					ShowPlayerDialog(playerid, AccountDialog + 3, DIALOG_STYLE_PASSWORD, "Autentificare", ncStr, "Autentificare", "Nume Nou");
				}
				else if(playerData[playerid][Language] == 2)
				{
				    ++playerData[playerid][FailedLogins];
				    //------------------------------------------------------------------
				    format(ncStr2, 500, "{FF0000}Login failed (%d/3)!\n\n{FFCC00}You have entered a wrong pin! Please try again!\n{00FF00}If you don't know your pin, visit {FF0000}%s{00FF00} to obtain it!", playerData[playerid][FailedLogins], playerData[playerid][EMail]);
				    strcat(ncStr, ncStr2, 500);
				    //------------------------------------------------------------------
					ShowPlayerDialog(playerid, AccountDialog + 3, DIALOG_STYLE_PASSWORD, "Login", ncStr, "Login", "New Name");
				}
		  		//----------------------------------------------------------------------
		  		if(playerData[playerid][FailedLogins] == 3)
				{
					format(ncStr2, 300, "*** {FF0000}%s {CEC8C8}has been kicked {FF0000}(Failed Logins)! {CEC8C8}***", sendName(playerid)),
					//------------------------------------------------------------------
					SendClientMessageToAll(GREY, ncStr2), SetTimerEx("KickEx", 50, false, "d", playerid);
				}
				return 0;
			}
		}
        case GangDialog: {
            if(response) {
                switch(listitem) {
                    case 0: ShowPlayerDialog(playerid, GangDialog + 1, DIALOG_STYLE_INPUT, "Gang Settings - Name", "{00FF00}Please enter below the name of the gang.", "Done", "Cancel");
                    case 1: ShowPlayerDialog(playerid, GangDialog + 2, DIALOG_STYLE_INPUT, "Gang Settings - Color", "{00FF00}Please enter below the color of the gang.", "Done", "Cancel");
                    case 2: ShowPlayerDialog(playerid, GangDialog + 3, DIALOG_STYLE_MSGBOX, "Gang Settings - Weapons", "{00FF00}Coming Soon", "Done", "Cancel");
                    case 3: ShowPlayerDialog(playerid, GangDialog + 4, DIALOG_STYLE_MSGBOX, "Gang Settings - Description", "{00FF00}Coming Soon", "Done", "Cancel");
                }
            }
        }
        /*case GangDialog + 1: {
            if(!response) return 1;

            if(strlen(inputtext) < 4 || strlen(inputtext) > 24)
                return SendClientMessage(playerid, RED,"ERROR: Invalid name size! Only between 4 and 24 characters!");

            ncStr[0] = NULL;
            mysql_format(dbConnect, ncStr, 256, "UPDATE `gangs` SET `Name` = '%e' WHERE `ID` = '%d'", inputtext, gangData[playerid][ID]);
            mysql_pquery(dbConnect, ncStr);

            foreach(new ncID: Player) if(gangData[ncID][ID] == gangData[playerid][ID]) format(gangData[ncID][Name], 24, "%s", inputtext);
        }
        case GangDialog + 2: {
            if(!response) return 1;

            new color;
            if(sscanf(inputtext, "x", color))
                return ShowPlayerDialog(playerid, GangDialog + 2, DIALOG_STYLE_INPUT, "Gang Settings - Color", "{00FF00}Please enter below the color of the gang.", "Done", "Cancel");

            color = (color * 256) + 0xAA; foreach(new ncID: Player) if(gangData[playerid][ID] == gangData[ncID][ID]) SetPlayerColor(ncID, color), gangData[ncID][Color] = color;

            ncStr2[0] = NULL;
            mysql_format(dbConnect, ncStr2, 256, "UPDATE `gangs` SET `Color` = '%d' WHERE `ID` = '%d'", color, gangData[playerid][ID]);
            mysql_pquery(dbConnect, ncStr2);
        }*/
	}
	return 1;
}

sendName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
resetVar(playerid) {

	new reset[PlayerData],
        adminReset[AdminData];

	playerData[playerid] = reset;
    adminData[playerid] = adminReset;

    /*gangData[playerid][ID] = 0; strcpy(gangData[playerid][Name], "None"); strcpy(gangData[playerid][Founder], "None");
    gangData[playerid][Kills] = 0; gangData[playerid][TotalKills] = 0; gangData[playerid][Points] = 0; gangData[playerid][TotalPoints] = 0;
    gangData[playerid][Color] = 0; gangData[playerid][Skin] = 0; gangData[playerid][Turfs] = 0; gangData[playerid][Members] = 0; gangData[playerid][Rank] = 0;
    */
}
sendIP(playerid) {
	new IP[30];
	//--------------------------------------------------------------------------
	GetPlayerIp(playerid, IP, 30);
	//--------------------------------------------------------------------------
	return IP;
}

public OnAccountCheck(playerid) {

	ncStr[0] = EOS;
	if(cache_num_rows()) {
		switch(playerData[playerid][Language]) {
			case 1: {
				format(ncStr, 390, "{00FF00}Bine ai revenit, {FF0000}%s{00FF00}!\n\nSuntem fericiti ca iti place serverul nostru, si suntem onorati sa te servim!\n\
					Te rugam sa te autentifici cu parola pe care ai folosit-o ultima data cand ai intrat pe server.\nAutentificarea este necesara ca sa iti primestii banii, orele si statisticile salvate!\n\n\
					{FF0000}Parola contului este: \n", sendName(playerid));
				ShowPlayerDialog(playerid, AccountDialog, DIALOG_STYLE_PASSWORD, "Autentificare", ncStr, "Gata", "Nume Nou");
			}
			case 2: {
				format(ncStr, 390, "{00FF00}Welcome back, {FF0000}%s{00FF00}!\n\nWe're glad to see you like our server, and we're honored to serve you!\n\
					Please login with your password that you used last time you logged on our server.\nSigning-in on your account it's necesary to have acces on your money, played hours and saved statistics!\n\n\
					{FF0000}Your account password is: \n", sendName(playerid));
				ShowPlayerDialog(playerid, AccountDialog, DIALOG_STYLE_PASSWORD, "Login", ncStr, "Done", "New Name");
			}
		}
	}
	else {
		switch(playerData[playerid][Language]) {
			case 1: {
				format(ncStr, 390, "{00FF00}Bine ai venit, {FF0000}%s{00FF00}!\n\nSuntem fericiti ca ai ales serverul nostru, si iti recomandam sa-l adaugi la {FFFFFF}Favorite{00FF00}: {FF0000}93.119.26.252:7777\n\
				{00FF00}Pentru inceput te rugam sa te inregistrezi cu o {FF0000}parola {00FF00}grea pe care doar tu sa o stii pentru a te autentifica! ({FF0000}intre 3-25 de caractere{00FF00}): \n", sendName(playerid));
				ShowPlayerDialog(playerid, AccountDialog+1, DIALOG_STYLE_PASSWORD, "Inregistrare", ncStr, "Gata", "Anuleaza");
			}
			case 2: {
				format(ncStr, 390, "{00FF00}Welcome, {FF0000}%s{00FF00}!\n\nWe're glad to see that you chose our server, and we're recommending you to add it on {FFFFFF}Favourites{00FF00}: {FF0000}93.119.26.252:7777\n\
				{00FF00}On the beggining, please register with a hard password that only you will know!({FF0000}Min. 3 - Max. 25 characters{FFFF00}): \n", sendName(playerid));
				ShowPlayerDialog(playerid, AccountDialog+1, DIALOG_STYLE_PASSWORD, "Register", ncStr, "Done", "Cancel");
			}
		}
	}

    TextDrawHideForPlayer(playerid, Textdraw6);     TextDrawHideForPlayer(playerid, Textdraw7);
    TextDrawHideForPlayer(playerid, Textdraw8);     TextDrawHideForPlayer(playerid, Textdraw9);
    TextDrawHideForPlayer(playerid, Textdraw10);    TextDrawHideForPlayer(playerid, Textdraw11);
    TextDrawHideForPlayer(playerid, Textdraw12);    PlayerTextDrawHide(playerid,    Textdraw13);
    TextDrawShowForPlayer(playerid, ConnectTD);     PlayerTextDrawShow(playerid,    Textdraw16);

	return 1;
}
public OnRconCheck(playerid) {

    if(!cache_num_rows())
        return SetTimerEx("KickEx", 50, false, "d", playerid);
    
    return 1;
}

public OnAccountRegister(playerid, Password[]) {
	ncStr[0] = EOS; ncStr2[0] = EOS;

	mysql_format(dbConnect, ncStr, 300, "INSERT INTO `accounts`(`Name`, `Password`, `IP`) VALUES ('%e', SHA1('%e'), '%s')", sendName(playerid), Password, sendIP(playerid));
	mysql_pquery(dbConnect, ncStr, "sendID", "d", playerid);

	/*mysql_format(dbConnect, ncStr2, 300, "SELECT `ID` FROM `accounts` WHERE `Name` = '%e'", sendName(playerid));
	mysql_pquery(dbConnect, ncStr2, "sendID", "d", playerid);*/

	ResetPlayerMoney(playerid); GivePlayerMoney(playerid, 30000);
	playerData[playerid][Level] = playerData[playerid][Respect] = 1;
    playerData[playerid][loggedIn] = true;
	format(playerData[playerid][EMail], 32, "None");
    format(playerData[playerid][ChatTag], 40, "");

    TextDrawHideForPlayer(playerid, Textdraw6);     TextDrawHideForPlayer(playerid, Textdraw7);
    TextDrawHideForPlayer(playerid, Textdraw8);     TextDrawHideForPlayer(playerid, Textdraw9);
    TextDrawHideForPlayer(playerid, Textdraw10);    TextDrawHideForPlayer(playerid, Textdraw11);
    TextDrawHideForPlayer(playerid, Textdraw12);    PlayerTextDrawHide(playerid,    Textdraw13);
    TextDrawShowForPlayer(playerid, ConnectTD);     PlayerTextDrawShow(playerid,    Textdraw16);

	ncStr[0] = '\0'; ncStr2[0] = EOS; 
	if(playerData[playerid][Language] == 1)
	{
	    format(ncStr2, 1900, "{00FF00}Salut, {FF0000}%s{FFFF00}!\n", sendName(playerid));
	    strcat(ncStr,  ncStr2, 1900);
	    strcat(ncStr,  "{00FF00}Te-ai inregistrat cu succes pe server-ul {0072FF}Kingdom {FFFF00}of {FF0000}Stunt{FFFF00}!\n", 1900);
	    format(ncStr2, 1900, "{00FF00}De cate ori intrii pe server-ul nostru, trebuie sa te autentifici cu parola: {FF0000}%s{00FF00}.\n\n", Password);
	    strcat(ncStr,  ncStr2, 1900);
		strcat(ncStr,  "{00FF00}Daca este printre primele dati cand joci SA:MP, iti recomandam sa vizitezi meniul {FF0000}/help{00FF00}.\n", 1900);
		strcat(ncStr,  "{00FF00}Pentru a vedea toate lucrurile pe care le poti face pe Server-ul nostru, scrie {FF0000}/cmds{00FF00}.\n", 1900);
		strcat(ncStr,  "{00FF00}Iti uram distractie placuta!", 1900);
		//----------------------------------------------------------------------
		return ShowPlayerDialog(playerid, AccountDialog + 2, DIALOG_STYLE_MSGBOX, "Inregistrare Reusita!", ncStr, "HELP", "Inchide");
	}
	else if(playerData[playerid][Language] == 2)
	{
	    format(ncStr2, 300, "{00FF00}Hi, {FF0000}%s{00FF00}!\n", sendName(playerid));
	    strcat(ncStr,  ncStr2, 500);
	    strcat(ncStr,  "{00FF00}You have been successfully registered on {0072FF}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}!\n", 500);
	    format(ncStr2, 400, "{00FF00}Each time you join our server, you must login with this password: {FF0000}%s{00FF00}.\n\n", Password);
	    strcat(ncStr,  ncStr2, 500);
		strcat(ncStr,  "{00FF00}If you are a newbie SA:MP player, you should visit {FF0000}/help{00FF00}.\n", 500);
		strcat(ncStr,  "{00FF00}To view our server's features, visit {FF0000}/teles{00FF00}.\n", 500);
		strcat(ncStr,  "{00FF00}Have fun!", 500);
		//----------------------------------------------------------------------
		return ShowPlayerDialog(playerid, AccountDialog + 2, DIALOG_STYLE_MSGBOX, "Successfully registered!", ncStr, "HELP", "Close");
	}
	return 1;
}

public OnLoginCheck(playerid) {
	ncStr[0] = EOS; ncStr2[0] = EOS;
	if(!cache_num_rows()) {
		if(playerData[playerid][Language] == 1)
		{
		    ++playerData[playerid][FailedLogins];
		    //------------------------------------------------------------------
		    format(ncStr2, 500, "{FF0000}Autentificare esuata (%d/3)!\n\n{FFCC00}Ai introdus o parola gresita! Te rugam sa incerci din nou!\n{00FF00}Daca ti-ai uitat parola, viziteaza {FF0000}www.Kingdom-of-Stunt.ro {00FF00}pentru a o reseta!", playerData[playerid][FailedLogins]);
		    strcat(ncStr, ncStr2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccountDialog, DIALOG_STYLE_PASSWORD, "Autentificare", ncStr, "Autentificare", "Nume Nou");
		}
		else if(playerData[playerid][Language] == 2)
		{
		    ++playerData[playerid][FailedLogins];
		    //------------------------------------------------------------------
		    format(ncStr2, 500, "{FF0000}Login failed (%d/3)!\n\n{FFCC00}You have entered a wrong password! Please try again!\n{00FF00}If you forgot your password, visit {FF0000}www.Kingdom-of-Stunt.ro {00FF00}to reset it!", playerData[playerid][FailedLogins]);
		    strcat(ncStr, ncStr2, 500);
		    //------------------------------------------------------------------
			ShowPlayerDialog(playerid, AccountDialog, DIALOG_STYLE_PASSWORD, "Login", ncStr, "Login", "New Name");
		}
  		//----------------------------------------------------------------------
  		if(playerData[playerid][FailedLogins] == 3)
		{
			format(ncStr2, 300, "*** {FF0000}%s {CEC8C8}has been kicked {FF0000}(Failed Logins)! {CEC8C8}***", sendName(playerid)),
			//------------------------------------------------------------------
			SendClientMessageToAll(GREY, ncStr2), SetTimerEx("KickEx", 50, false, "d", playerid);
		}
		return 0;
	}
	ncStr[0] = EOS;
	cache_get_value_int(0, "Security", playerData[playerid][Security]);
	mysql_format(dbConnect, ncStr, 256, "SELECT * FROM `accounts` WHERE `Name` = '%e'", sendName(playerid));
	mysql_pquery(dbConnect, ncStr, "OnLoadData", "d", playerid);
	return 1;
}
public OnLoadData(playerid) {
	ncStr[0] = EOS; ncStr2[0] = EOS;
	playerData[playerid][FailedLogins] = 0;

	cache_get_value(0, "EMail", playerData[playerid][EMail], 150);

	if(playerData[playerid][Security] == 1) {
		playerData[playerid][Pin] = randomEx(1000, 9999);
		if(playerData[playerid][Language] == 1) {
			format(ncStr, 256, "{00FF00}Salut, {FF0000}%s{00FF00}!\n\nContul tau este securizat prin confirmarea pinului.\nPentru a putea accesa pinul, intra pe adresa de E-Mail pe care o ai in cont{FF0000}(%s){00FF00}.",\
			sendName(playerid), playerData[playerid][EMail]);
			ShowPlayerDialog(playerid, AccountDialog + 3, DIALOG_STYLE_INPUT, "Pin Security", ncStr, "Done", "Cancel");
		}
		else {
			format(ncStr, 256, "{00FF00}Hello, {FF0000}%s{00FF00}!\n\nYour account is protected by pin confirmation.\nTo acces the pin, please verify your E-Mail adrees that you have in your account{FF0000}(%s){00FF00}.",\
			sendName(playerid), playerData[playerid][EMail]);
			ShowPlayerDialog(playerid, AccountDialog + 3, DIALOG_STYLE_INPUT, "Pin Security", ncStr, "Done", "Cancel");
		}
	}
	else {
		playerData[playerid][loggedIn] = true;

		cache_get_value_int(0, "ID", playerData[playerid][ID]);
		cache_get_value_int(0, "IsConfirmed", playerData[playerid][IsConfirmed]);
        cache_get_value_int(0, "VIP", playerData[playerid][VIP]);
        cache_get_value_int(0, "Level", playerData[playerid][Level]);
        cache_get_value_int(0, "Respect", playerData[playerid][Respect]);
        cache_get_value_int(0, "Coins", playerData[playerid][Coins]);
        cache_get_value_int(0, "Hours", playerData[playerid][Hours]);
        cache_get_value_int(0, "Minutes", playerData[playerid][Minutes]);
        cache_get_value_int(0, "Admin", adminData[playerid][Level]);
        //cache_get_value_int(0, "GangID", gangData[playerid][ID]);
        cache_get_value_int(0, "Mute", playerData[playerid][Mute]);
        cache_get_value_int(0, "Warns", playerData[playerid][Warns]);

        cache_get_value(0, "RCONPass", adminData[playerid][RCONPass], 150);

        if(adminData[playerid][Level] != 0 || strcmp(adminData[playerid][RCONPass], "None") != 0) {

            ncStr[0] = NULL;
            mysql_format(dbConnect, ncStr, 128, "SELECT * FROM `admins` WHERE `Name` = '%s'", sendName(playerid));
            mysql_pquery(dbConnect, ncStr, "OnLoadAdminData", "d", playerid);
        }

        if(playerData[playerid][VIP] != 0) Iter_Add(Vips, playerid);

        /*if(gangData[playerid][ID] != 0) {
            cache_get_value_int(0, "GangRank",   gangData[playerid][Rank]  );
            cache_get_value_int(0, "GangKills",  gangData[playerid][Kills] );
            cache_get_value_int(0, "GangPoints", gangData[playerid][Points]);
            cache_get_value_int(0, "GangSkin",   gangData[playerid][Skin]  );

            SetPlayerSkin(playerid, gangData[playerid][Skin]);

            ncStr2[0] = NULL;
            mysql_format(dbConnect, ncStr, 256, "SELECT * FROM `gangs` WHERE `ID` = '%d'", gangData[playerid][ID]);
            mysql_pquery(dbConnect, ncStr, "OnLoadGangData", "d", playerid);
        }*/

        getPlayerTag(playerid);

		SendClientMessage(playerid, YELLOW, "You have succesfully logged in!");

	}
}


/*public OnLoadGangData(playerid) {

    if(cache_num_rows()) {
        cache_get_value(0, "Name", gangData[playerid][Name], 24);
        cache_get_value(0, "Founder", gangData[playerid][Founder], 24);
        cache_get_value_int(0, "Members", gangData[playerid][Members]);
        cache_get_value_int(0, "Turfs", gangData[playerid][Turfs]);
        cache_get_value_int(0, "Color", gangData[playerid][Color]);
    }
    SetPlayerColor(playerid, gangData[playerid][Color]);
}*/

saveData(playerid) {

	ncStr[0] = EOS;

    if(playerData[playerid][loggedIn] == true) {

    	mysql_format(dbConnect, ncStr, 2048, "UPDATE `accounts` SET `IsConfirmed` = '%d', `Level` = '%d', `Respect` = '%d',\
        `Admin` = '%d', `VIP` = '%d', `Coins` = '%d', `Hours` = '%d', `Minutes` = '%d', `Warns` = '%d', `Mute` = '%d' WHERE `ID` = '%d'",
        playerData[playerid][IsConfirmed], playerData[playerid][Level], playerData[playerid][Respect],\
    	adminData[playerid][Level], playerData[playerid][VIP], playerData[playerid][Coins],
        playerData[playerid][Hours], playerData[playerid][Minutes], /*gangData[playerid][ID],*/ playerData[playerid][Warns], playerData[playerid][Mute], playerData[playerid][ID]);

    	mysql_pquery(dbConnect, ncStr);

        if(adminData[playerid][Level] != 0 || strcmp(adminData[playerid][RCONPass], "None") != 0) {

            ncStr2[0] = NULL;

            mysql_format(dbConnect, ncStr2, 1024, "UPDATE `admins` SET `Level` = '%d', `Events` = '%d',\
            `ChatsCleared` = '%d', `Kicks` = '%d', `Bans` = '%d', `Mutes`= '%d', `Warns` = '%d',\
            `AdminPoints` = '%d', `AdminType` = '%d' WHERE `ID` = '%d'", adminData[playerid][Level],
            adminData[playerid][Events], adminData[playerid][ChatsCleared], adminData[playerid][Kicks],
            adminData[playerid][Bans], adminData[playerid][Mutes], adminData[playerid][Warns],
            adminData[playerid][AdminPoints], adminData[playerid][neacristy], adminData[playerid][ID]);

            mysql_pquery(dbConnect, ncStr2);

        }

        /*if(gangData[playerid][ID] != 0) {
            ncStr2[0] = NULL;
            mysql_format(dbConnect, ncStr2, 512, "UPDATE `accounts` SET `GangKills` = '%d', `GangPoints` = '%d', `GangRank` = '%d', `GangSkin` = '%d' WHERE `ID` = '%d'", gangData[playerid][Kills],
            gangData[playerid][Points], gangData[playerid][Rank], gangData[playerid][Skin], playerData[playerid][ID]);
            mysql_pquery(dbConnect, ncStr2);

            ncStr2[0] = NULL;
            mysql_format(dbConnect, ncStr2, 256, "SELECT `Kills`, `Points`, `Members` FROM `gangs` WHERE `ID` = '%d'", gangData[playerid][ID]);
            mysql_pquery(dbConnect, ncStr2, "GetGangKills", "d", playerid);
        }*/
    }

	return 1;
}

public KickEx(playerid) return Kick(playerid);

public sendID(playerid) {
    
    playerData[playerid][ID] = cache_insert_id();
    return 1;
}

randomEx(min, max) {
	return random(max - min) + min;
}

getPlayerTag(playerid) {

   if(IsPlayerAdmin(playerid) && adminData[playerid][Level] > 0) {
        
        switch(adminData[playerid][neacristy]) {
            case 0: 
                format(playerData[playerid][ChatTag], 40, "{FF0000}({FFFFFF}RCON{FF0000})");
            
            case 1: 
                format(playerData[playerid][ChatTag], 40, "{FF0000}({FFFFFF}Assistent{FF0000})");

            case 2: 
                format(playerData[playerid][ChatTag], 40, "{FF0000}({FFFFFF}Manager{FF0000})");

            case 3:
                format(playerData[playerid][ChatTag], 40, "{FF0000}({FFFFFF}Founder{FF0000})");
        }

    }else if(adminData[playerid][Level] > 0) {

        if(adminData[playerid][Level] < 4)
            format(playerData[playerid][ChatTag], 40, "{FFFF00}(Helper)");
        else 
            format(playerData[playerid][ChatTag], 40, "{0000FF}(Admin)");

    }else if(playerData[playerid][VIP] > 3)
        format(playerData[playerid][ChatTag], 40, "{FF0000}(VIP)");

}

public UpdateTime()
{   new str[10]; gettime(serverData[Hour], serverData[Minute]); getdate(serverData[Year], serverData[Month], serverData[Day]);

    switch(serverData[Month])
    {
        case 1:  serverData[ncText] = "Jan";      case 2:  serverData[ncText] = "Feb";      case 3:  serverData[ncText] = "Mar";
        case 4:  serverData[ncText] = "Apr";      case 5:  serverData[ncText] = "May";      case 6:  serverData[ncText] = "Jun";
        case 7:  serverData[ncText] = "Jul";      case 8:  serverData[ncText] = "Aug";      case 9:  serverData[ncText] = "Sep";
        case 10: serverData[ncText] = "Oct";      case 11: serverData[ncText] = "Nov";      case 12: serverData[ncText] = "Dec";
    }
    //--------------------------------------------------------------------------
    format(str, 10, "%02d %s",   serverData[Day], serverData[ncText]);  TextDrawSetString(Textdraw14, str);
    format(str, 6,  "%02d:%02d", serverData[Hour], serverData[Minute]); TextDrawSetString(Textdraw15, str);
    //--------------------------------------------------------------------------
    if(serverData[Minute] == 0) return payDay();

    foreach(new i: Player) {

    	saveData(i);

	    ++playerData[i][Minutes];
        if(playerData[i][Mute] > 0)
            if(--playerData[i][Mute] == 0) 
                GameTextForPlayer(i, "You have been unmutted", 3000, 6);
    	if(playerData[i][Minutes] == 60) ++playerData[i][Hours];
    }
    return 1;
}

payDay() {
	foreach(new i: Player) {
		++playerData[i][Respect];
		GivePlayerMoney(i, 15000);
		GameTextForPlayer(i, "PayDay", 4000, 4);
	}
	return 1;
}

stock strcpy(dest[], const source[], maxlength = sizeof dest)
{
    strcat((dest[0] = EOS, dest), source, maxlength);
}

//Admin Sistem
public GetAdminID(playerid) {
    adminData[playerid][ID] = cache_insert_id();
    return 1;
}
public OnLoadAdminData(playerid) {

    Iter_Add(Admins, playerid);

    cache_get_value_int(0, "ID", adminData[playerid][ID] );
    cache_get_value_int(0, "Events", adminData[playerid][Events]);
    cache_get_value_int(0, "ChatsCleared", adminData[playerid][ChatsCleared]);
    cache_get_value_int(0, "Kicks", adminData[playerid][Kicks]);
    cache_get_value_int(0, "Bans", adminData[playerid][Bans]);
    cache_get_value_int(0, "Mutes", adminData[playerid][Mutes]);
    cache_get_value_int(0, "Warns", adminData[playerid][Warns]);
    cache_get_value_int(0, "AdminPoints", adminData[playerid][AdminPoints]);
    cache_get_value_int(0, "AdminType", adminData[playerid][neacristy]);
}

SendMessageToAdmins(color, string[]) {

    foreach(new ncID: Admins) 
        SendClientMessage(ncID, color, string);
    return 1;
}

SendMessageToVIPs(color, string[]) {
    foreach(new ncID: Vips)
        SendClientMessage(ncID, color, string);
    return 1;
}

//Gangs

public loadTurfs() {

    for(new turfID = 0; turfID < MAX_TURFS; ++turfID) {
        cache_get_value_int(turfID, "ID", turfData[turfID][ID]);
        cache_get_value_int(turfID, "Owner", turfData[turfID][Owner]);
        cache_get_value_float(turfID, "MinX", turfData[turfID][MinX]);
        cache_get_value_float(turfID, "MinY", turfData[turfID][MinY]);
        cache_get_value_float(turfID, "MaxX", turfData[turfID][MaxX]);
        cache_get_value_float(turfID, "MaxY", turfData[turfID][MaxY]);

        turfData[turfID][Zone][0] = CreateDynamicRectangle(turfData[turfID][MinX], turfData[turfID][MinY], turfData[turfID][MaxX], turfData[turfID][MaxY]);
        turfData[turfID][Zone][1] = CreateZone(turfData[turfID][MinX], turfData[turfID][MinY], turfData[turfID][MaxX], turfData[turfID][MaxY]);

        CreateZoneNumber(turfData[turfID][Zone][1], turfID + 1);
        CreateZoneBorders(turfData[turfID][Zone][1]);

        printf("%d/%d Zones loaded", turfID + 1, cache_num_rows());
    }

}

/*CMD:invite(playerid, params[]) {

    new ncID;

    if(gangData[playerid][ID] == 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be in a gang to invite players.");
    if(gangData[playerid][Rank] < 6)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need at least a gang Co-Leader.");
    if(sscanf(params, "d", ncID))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /Invite [PlayerID]");
    if(!IsPlayerConnected(ncID) || playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not online/logged-in.");
    if(gangData[ncID][ID] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified players is in another gang/clan.");

    gangData[playerid][InvitedID] = ncID;
    gangData[ncID][InviterID] = playerid;
    gangData[ncID][AcceptTime] = gettime();

    ncStr[0] = NULL;
    format(ncStr, 200, "{FFFFFF}Player {FF0000}%s {FFFFFF}invited you to join {FF0000}%s {FFFFFF}gang. Use /Accept or /Decline.", sendName(playerid), gangData[playerid][Name]);
    SendClientMessage(ncID, WHITE, ncStr);

    return 1;
}

CMD:accept(playerid, params[]) {

    if(gettime() - gangData[playerid][AcceptTime] > 20000 || gangData[playerid][InviterID] == -1 || IsPlayerConnected(gangData[playerid][InviterID]))
        return SendClientMessage(playerid, RED, "KOS-ERROR: You have nothing to accept.");

    if(gangData[playerid][ID] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are already in a gang.");

    gangData[playerid][ID] = gangData[gangData[playerid][InviterID]][ID];
    gangData[gangData[playerid][InviterID]][InvitedID] = -1;
    gangData[playerid][Rank] = 1;
    ncStr2[0] = NULL;
    mysql_format(dbConnect, ncStr2, 256, "SELECT * FROM `gangs` WHERE `ID` = '%d'", gangData[playerid][ID]);
    mysql_pquery(dbConnect, ncStr2, "OnLoadGangData", "d", playerid);

    ncStr[0] = NULL;
    format(ncStr, 144, "{FFFF00}Player {00FF00}%s {FFFF00}has joined your gang. Check {00FF00}/GM{ffff00}.", sendName(playerid));

    foreach(new i: Player)
        if(gangData[i][ID] == gangData[playerid][ID])
            SendClientMessage(i, YELLOW, ncStr),
            gangData[i][Members]++;

    return 1;
}

CMD:decline(playerid, params[]) {
    if(gettime() - gangData[playerid][AcceptTime] > 20000 || gangData[playerid][InviterID] == -1 || IsPlayerConnected(gangData[playerid][InviterID]))
        return SendClientMessage(playerid, RED, "KOS-ERROR: You have nothing to decline.");

    ncStr[0] = NULL;
    format(ncStr, 144, "{FFFF00}Player {00FF00}%s {FFFF00}has declined your invite.", sendName(playerid));
    SendClientMessage(gangData[playerid][InviterID], YELLOW, ncStr);

    gangData[gangData[playerid][InviterID]][InvitedID] = -1;
    gangData[playerid][InviterID] = -1;

    return 1;
}

CMD:makefounder(playerid, params[]) {

    new ncID, gangID;

    if(!IsPlayerAdmin(playerid) && adminData[playerid][neacristy] < 3)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Manager to use this command.");
    if(sscanf(params, "dd", ncID, gangID))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /MakeFounder [PlayerID/GangID].");
    if(!IsPlayerConnected(ncID) && playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(gangData[ncID][ID] != 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is in another gang/clan.");

    ncStr2[0] = NULL;
    mysql_format(dbConnect, ncStr2, 300, "SELECT * FROM `gangs` WHERE `ID` = '%d'", gangID);
    mysql_pquery(dbConnect, ncStr2, "ConstructGang", "dd", ncID, gangID);

    return 1;
}

CMD:settings(playerid, params[]) {

    if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] != 7)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Founder to use this command.");

    return ShowPlayerDialog(playerid, GangDialog, DIALOG_STYLE_TABLIST_HEADERS, "Gang Settings", "Setting \tDescription\n\
                                                                                                  {00FF00}Name\t{FFFFFF}Set the Gang's name.\n\
                                                                                                  {00FF00}Color\t{FFFFFF}Set the Gang's color.\n\
                                                                                                  {00FF00}Weapons\t{FFFFFF}Set the Gang's weapons.\n\
                                                                                                  {00FF00}Description\t{FFFFFF}Set the Gang's description.", "Select", "Cancel");
}

CMD:setgskin(playerid, params[]) {
    new ncID, skinID;

    if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] < 5)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Co-Leader to use this command.");
    if(sscanf(params, "dd", ncID, skinID))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /SetCSkin [PlayerID/SkinID].");
    if(!IsPlayerConnected(ncID) && playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(gangData[ncID][ID] != gangData[playerid][ID])
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not in your gang.");
    if(skinID < 0 || skinID > 311)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified skin ID does not exist.");

    gangData[ncID][Skin] = skinID;
    SetPlayerSkin(ncID, skinID);
    return 1;
}

CMD:setrank(playerid, params[]) {
    new ncID, skinID;

    if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] < 5)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Co-Leader to use this command.");
    if(sscanf(params, "dd", ncID, skinID))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /SetRank [PlayerID/Rank].");
    if(!IsPlayerConnected(ncID) && playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(gangData[ncID][ID] != gangData[playerid][ID])
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not in your gang.");
    if(skinID <= 0 || skinID > gangData[playerid][Rank] - 1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You aren't able to set this rank.");

    gangData[ncID][Rank] = skinID;
    return 1;
}

CMD:gannounce(playerid, params[]) {
    if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] < 5)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Co-Leader to use this command.");

    new Text[128]; ncStr[0] = NULL;
    if(sscanf(params, "s[128]", Text))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: {49FFFF}/GAnnounce [Text]");

    format(ncStr, 256, "~r~~h~Gang: ~r~~h~%s~n~~w~~h~%s", sendName(playerid), Text);
    foreach(new i: Player) if(gangData[i][ID] == gangData[playerid][ID]) GameTextForPlayer(i, ncStr, 5000, 4);

    return 1;
}

CMD:gann(playerid, params[]) {
    return cmd_gannounce(playerid, params);
}

CMD:gkick(playerid, params[]) {
    new ncID, ncReason[100];

    if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] < 5)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Co-Leader to use this command.");
    if(sscanf(params, "ds[100]", ncID, ncReason))
        return SendClientMessage(playerid, GREEN, "KOS-USAGE: /GKick [PlayerID/Reason].");
    if(!IsPlayerConnected(ncID) && playerData[ncID][loggedIn] == false)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not connected/logged-in.");
    if(gangData[ncID][ID] != gangData[playerid][ID])
        return SendClientMessage(playerid, RED, "KOS-ERROR: The specified player is not in your gang.");
    if(gangData[ncID][Rank] >= gangData[playerid][Rank])
        return SendClientMessage(playerid, RED, "KOS-ERROR: You cannot kick this player from your gang.");
    ncStr[0] = NULL;
    format(ncStr, 256, "%s(%d) {BBFF00}has been kicked by %s(%d) from our gang! Reason: %s.", sendName(ncID), ncID, sendName(playerid), playerid, ncReason);
    foreach(new i: Player) if(gangData[i][ID] == gangData[playerid][ID]) SendClientMessage(i, LBLUE, ncStr), gangData[i][Members]--;

    gangData[ncID][ID] = 0; strcpy(gangData[ncID][Name], "None"); strcpy(gangData[ncID][Founder], "None");
    gangData[ncID][Kills] = 0; gangData[ncID][TotalKills] = 0; gangData[ncID][Points] = 0; gangData[ncID][TotalPoints] = 0;
    gangData[ncID][Color] = 0; gangData[ncID][Skin] = 0; gangData[ncID][Turfs] = 0; gangData[ncID][Members] = 0; gangData[ncID][Rank] = 0;

    return 1;
}
CMD:lgang(playerid, params[]) {

    if(gangData[playerid][ID] == 0)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be in a gang to use this command.");

    if(gangData[playerid][Rank] == 7)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to contact a manager to leave this gang.");

    ncStr[0] = NULL;
    format(ncStr, 128, "%s(%d) {BBFF00}has left our gang!", sendName(playerid), playerid);
    foreach(new i: Player) if(gangData[i][ID] == gangData[playerid][ID]) SendClientMessage(i, LBLUE, ncStr), gangData[i][Members]--;

    gangData[playerid][ID] = 0; strcpy(gangData[playerid][Name], "None"); strcpy(gangData[playerid][Founder], "None");
    gangData[playerid][Kills] = 0; gangData[playerid][TotalKills] = 0; gangData[playerid][Points] = 0; gangData[playerid][TotalPoints] = 0;
    gangData[playerid][Color] = 0; gangData[playerid][Skin] = 0; gangData[playerid][Turfs] = 0; gangData[playerid][Members] = 0; gangData[playerid][Rank] = 0;

    return 1;
}

CMD:gm(playerid)
{
    ncStr[0] = '\0';
    //--------------------------------------------------------------------------
    if(gangData[playerid][ID] == 0) return SendClientMessage(playerid, RED, "KOS-ERROR: You are not a member in any gang!");
    //--------------------------------------------------------------------------
    foreach(new l : Player)
    {
        if(gangData[l][ID] == gangData[playerid][ID])
        {
            switch(gangData[l][Rank])
            {
                //--------------------------------------------------------------
                case 1..4: format(ncStr, 1024, "%s\n{00FF00}%s(%d) - {00BBF6}Member",  ncStr, sendName(l), l);
                case 5:    format(ncStr, 1024, "%s\n{00FF00}%s(%d) - {00BBF6}Manager", ncStr, sendName(l), l);
                case 6:    format(ncStr, 1024, "%s\n{00FF00}%s(%d) - {00BBF6}Leader",  ncStr, sendName(l), l);
                case 7:    format(ncStr, 1024, "%s\n{00FF00}%s(%d) - {00BBF6}Owner",   ncStr, sendName(l), l);
                //--------------------------------------------------------------
            }
        }
    }
    return ShowPlayerDialog(playerid, 123, DIALOG_STYLE_LIST, "{BBFF00}Online {00BBF6}Gang Members", ncStr, "Close", "");
}

CMD:gang(playerid) {
    ncStr[0] = EOS; ncStr2[0] = EOS;
    
    switch(playerData[playerid][Language]) {
        case 2: {
            format(ncStr2, 200, "{00FF00}Hello, {FF0000}%s{00FF00}! Welcome to {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}If you ever wondered what commands server's gang use, below it's a list with them:\n\n", 1900);
            strcat(ncStr, "{0072BB}Commands for Owner: \n", 1900);
            strcat(ncStr, "{FF0000}/settings \t{00FF00}- \t{FFFFFF}Lets you to change gang's settings.\n\n", 1900);
            strcat(ncStr, "{0072BB}Commands for Leaders: \n\n", 1900);
            strcat(ncStr, "{0072BB}Commands for Co-Leaders: \n", 1900);
            strcat(ncStr, "{FF0000}/gannounce \t{00FF00}- \t{FFFFFF}It shows a message on the screen to all players.\n", 1900);
            strcat(ncStr, "{FF0000}/invite \t{00FF00}- \t{FFFFFF}Lets you invite a plyer in your gang.\n", 1900);
            strcat(ncStr, "{FF0000}/ckick \t{00FF00}- \t{FFFFFF}Lets you to kick a player from your gang.\n", 1900);
            strcat(ncStr, "{FF0000}/setcskin \t{00FF00}- \t{FFFFFF}Lets you to set a member's skin.\n", 1900);
            strcat(ncStr, "{FF0000}/setrank \t{00FF00}- \t{FFFFFF}Lets you to set a member's rank.\n\n", 1900);
            strcat(ncStr, "{0072BB}Commands for Members: \n\n", 1900);
            format(ncStr2, 200, "{00FF00}Thank you, {FF0000}%s{00FF00} for playing on our server. We're honored to serve you. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}And, don't forget! If you have a dilemma, use {FF0000}/n{00FF00} to ask a question to our admins!\n");
        }
        case 1: {
            format(ncStr2, 200, "{00FF00}Salut, {FF0000}%s{00FF00}! Bine ai venit pe {0072BB}Kingdom {FFFF00}of {FF0000}Stunt{00FF00}.\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Daca te-ai intrebat vreodata ce comenzi folosesc gangurile serverului, aici este o lista cu acestea:\n\n", 1900);
            strcat(ncStr, "{0072BB}Comenzi pentru Owner: \n", 1900);
            strcat(ncStr, "{FF0000}/settings \t{00FF00}- \t{FFFFFF}Iti permite sa schimbi setarile gangului.\n\n", 1900);
            strcat(ncStr, "{0072BB}Comenzi pentru Lideri: \n\n", 1900);
            strcat(ncStr, "{0072BB}Comenzi pentru Co-Lideri: \n", 1900);
            strcat(ncStr, "{FF0000}/gannounce \t{00FF00}- \t{FFFFFF}Arata un mesaj pe ecranul tuturor membrilor.\n", 1900);
            strcat(ncStr, "{FF0000}/invite \t{00FF00}- \t{FFFFFF}Iti permite sa inviti un player in gangul tau.\n", 1900);
            strcat(ncStr, "{FF0000}/ckick \t{00FF00}- \t{FFFFFF}Iti permite sa dai afara un membru din gangul tau.\n", 1900);
            strcat(ncStr, "{FF0000}/setcskin \t{00FF00}- \t{FFFFFF}Iti permite sa setezi skinul unui membru.\n", 1900);
            strcat(ncStr, "{FF0000}/setrank \t{00FF00}- \t{FFFFFF}Iti permite sa setezi rankul unui membru.\n\n", 1900);
            strcat(ncStr, "{0072BB}Comenzi pentru Membri: \n\n", 1900);
            format(ncStr2, 200, "{00FF00}Multumim, {FF0000}%s{00FF00} pentru ca joci pe serverul nostru. Suntem onorati sa te servim. Be nice and {FF0000}have fun{00FF00}!\n", sendName(playerid));
            strcat(ncStr, ncStr2);
            strcat(ncStr, "{00FF00}Si, nu uita! Daca ai vreo dilema, foloseste {FF0000}/n{00FF00} sa pui o intrebare adminilor!\n");
        }
    }
    return ShowPlayerDialog(playerid, ServerDialog + 1, DIALOG_STYLE_MSGBOX, "Server Commands", ncStr, "Close", "");
}

public GetGangKills(playerid) {
    if(cache_num_rows()) {
        cache_get_value_int(0, "Kills", gangData[playerid][TotalKills]);
        cache_get_value_int(0, "Points", gangData[playerid][TotalPoints]);

        ncStr2[0] = NULL;
        mysql_format(dbConnect, ncStr2, 512, "UPDATE `Gangs` SET `Kills` = '%d', `Points` = '%d', `Members` = '%d' WHERE `ID` = '%d'", gangData[playerid][TotalKills] + gangData[playerid][Kills],
        gangData[playerid][TotalPoints] + gangData[playerid][Points], gangData[playerid][Members], gangData[playerid][ID]);
        mysql_pquery(dbConnect, ncStr2);
    }
}

public ConstructGang(playerid, gangid) {
    if(cache_num_rows()) {

        ncStr2[0] = NULL;
        mysql_format(dbConnect, ncStr2, 512, "UPDATE `gangs` SET `Founder` = '%e' WHERE `ID` = '%d'", sendName(playerid), gangid);
        mysql_pquery(dbConnect, ncStr2);

        gangData[playerid][ID] = gangid;

        foreach(new ncID: Player)
            if(gangData[playerid][ID] == gangData[ncID][ID])
                SendClientMessage(ncID, YELLOW, "KOS-INFO: Your gang has a new founder. Please check /GM."),
                gangData[ncID][Members]++;

    }
    else {

        ncStr2[0] = NULL;
        mysql_format(dbConnect, ncStr2, 512, "INSERT INTO `gangs` (`Name`, `Founder`, `Members`) VALUES ('New Gang', '%e', '%d')", sendName(playerid), 1);
        mysql_pquery(dbConnect, ncStr2, "InsertGangID", "d", playerid);

        SendClientMessage(playerid, YELLOW, "KOS-INFO: You are the new owner of this gang.");
    }

    gangData[playerid][Rank] = 7;
}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

        for(new turfID = 0; turfID < MAX_TURFS; ++turfID)
            if(areaid == turfData[turfID][Zone][0]) {
                gangData[playerid][onTurf] = turfID;
                break;
            }
        for(new turfID = 0; turfID < MAX_TURFS; ++turfID) {
            if(areaid == turfData[turfID][Zone][0] && turfData[turfID][OnWar] == true)
            {}
        }*/
/*}

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

    gangData[playerid][onTurf] = -1;

}*/

CMD:ip(playerid, params[], tipvoucher[27]) {
    new string[256];
    format(string, 256, "%s", sendIP(playerid));
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:attack(playerid, params[]) {

    return SendClientMessage(playerid, YELLOW, "Coming soon.");

    /*if(gangData[playerid][ID] == 0 || gangData[playerid][Rank] < 5)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You need to be a Gang Co-Leader to use this command.");
    if(serverData[Hour] < 20 || serverData[Hour] > 21)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can only start an attack in the interval 20-21.");
    if(gangData[playerid][onTurf] == -1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: In order to start an attack you need to be in a territory.");
    if(turfData[gangData[playerid][onTurf]][Owner] == gangData[playerid][ID])
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't attack your own territory.");
    if(turfData[gangData[playerid][onTurf]][OnWar] == true)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You can't attack a territory that is already on war.");
    if(gangData[playerid][inWar] == true)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You already have a war.");
    if(gangData[turfData[gangData[playerid][onTurf]][Owner]][inWar] == true)
        return SendClientMessage(playerid, RED, "KOS-ERROR: The gang you are trying to attack has already a war");

    new x  = gangData[playerid][onTurf];

    gangData[ turfData[ gangData[playerid][onTurf] ][Owner] ][inWar] = gangData[playerid][inWar] = true;
    turfData[gangData[playerid][onTurf]][OnWar] = true;
    turfData[x][First] = gangData[playerid][ID];
    turfData[x][Second] = turfData[x][Owner];
    turfData[x][warTime] = 300;

    return 1;*/

}

/*public InsertGangID(playerid) {
    gangData[playerid][ID] = cache_insert_id();
    return 1;
}*/

/*CMD:turfs(playerid, params[]) {

    if(playerData[playerid][Turfs] == 1) {
        for(new turfID = 0; turfID < MAX_TURFS; ++turfID)
            HideZoneForPlayer(playerid, turfData[turfID][Zone][1]);
        playerData[playerid][Turfs] = 0;
    }
    else {
        for(new turfID = 0; turfID < MAX_TURFS; ++turfID)
            ShowZoneForPlayer(playerid, turfData[turfID][Zone][1], (turfData[turfID][Owner] == 0)?0xFFFFFFAA:gangData[turfData[turfID][Owner]][Color]);
        playerData[playerid][Turfs] = 1;
    }
    return 1;
}*/

//debug

CMD:id(playerid, params[]) {
    new str[144];
    format(str, 144, "Account ID: %d\nAdmin ID: %d\n", playerData[playerid][ID], adminData[playerid][ID]);
    return SendClientMessage(playerid, GREEN, str);
}

//clan system

/*CMD:createclan(playerid, params[]) {

    if(clanData[playerid][ID] != 0) 
        return SendClientMessage(playerid, RED, "You ")
}*/

// House system

public loadHouses() {

    houseID = cache_num_rows();
    for(new hID = 0; hID < houseID; ++hID) {
        cache_get_value_int(hID, "ID", houseData[hID][ID]);
        cache_get_value_int(hID, "Interior", houseData[hID][Interior]);
        cache_get_value_int(hID, "Locked", houseData[hID][Locked]);
        cache_get_value_int(hID, "Buy", houseData[hID][Buy]);
        cache_get_value_int(hID, "Sell", houseData[hID][Sell]);
        cache_get_value_int(hID, "Rent", houseData[hID][Rent]);
        cache_get_value_int(hID, "Renters", houseData[hID][Renters]);

        cache_get_value_float(hID, "X", houseData[hID][X]);
        cache_get_value_float(hID, "Y", houseData[hID][Y]);
        cache_get_value_float(hID, "Z", houseData[hID][Z]);
        cache_get_value_float(hID, "InX", houseData[hID][InX]);
        cache_get_value_float(hID, "InY", houseData[hID][InY]);
        cache_get_value_float(hID, "InZ", houseData[hID][InZ]);

        cache_get_value(hID, "Owner", houseData[hID][Owner], 24);

        if(strcmp("For Sale", houseData[hID][Owner], true) == 0) {
            houseData[hID][Icon] = CreateDynamicPickup(19523, 23, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]);
            ncStr[0] = NULL;
            format(ncStr, 512, "{FFFF00}This house is For Sale!\n{00FF00}Cost: {FFFFFF}%d\n{00FF00}Rent Price: {FFFFFF}%d\n{00FF00}Renters: {FFFFFF}%d\n\
            {00FF00}Sell: {FFFFFF}%d\n\n{f0d92b}Type {FFFFFF}/house {f0d92b}for more!", houseData[hID][Buy], houseData[hID][Rent], houseData[hID][Renters], houseData[hID][Sell]);
            houseData[hID][Info] = CreateDynamic3DTextLabel(ncStr, WHITE, houseData[hID][X], houseData[hID][Y], houseData[hID][Z], 40);
        }
        else {
            houseData[hID][Icon] = CreateDynamicPickup(19522, 23, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]);
            ncStr[0] = NULL;
            format(ncStr, 512, "{FFFF00}This house is owned by %s!\n{00FF00}Cost: {FFFFFF}%d\n{00FF00}Rent Price: {FFFFFF}%d\n{00FF00}Renters: {FFFFFF}%d\n\
            {00FF00}Sell: {FFFFFF}%d\n\n{f0d92b}Type {FFFFFF}/house {f0d92b}for more!", houseData[hID][Owner], houseData[hID][Buy], houseData[hID][Rent], houseData[hID][Renters], houseData[hID][Sell]);
            houseData[hID][Info] = CreateDynamic3DTextLabel(ncStr, WHITE, houseData[hID][X], houseData[hID][Y], houseData[hID][Z], 40);
        }

        //printf("Loaded house with ID: %d/%d", hID + 1, houseID);
    }
}

/*public loadHQS() {
    hqID = cache_num_rows();
    for(new hID = 0; hID < hqID; ++hID) {
        cache_get_value_int(hID, "ID", hqData[hID][ID]);

        cache_get_value_float(hID, "X", hqData[hID][X]);
        cache_get_value_float(hID, "Y", hqData[hID][Y]);
        cache_get_value_float(hID, "Z", hqData[hID][Z]);
        
        cache_get_value(hID, "Owner", hq[hID][Owner], 24);

        if(strcmp("None", hqData[hID][Owner], true) == 0) {
            houseData[hID][Icon] = CreateDynamicPickup(1314, 23, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]);
            ncStr[0] = NULL;
            format(ncStr, 512, "{FFFF00}This HQ is not owned by a clan!\n\n{f0d92b}Type {FFFFFF}/buyhq {f0d92b}to buy this HQ for your clan!");
            houseData[hID][Info] = CreateDynamic3DTextLabel(ncStr, WHITE, hqData[hID][X], hqData[hID][Y], hqData[hID][Z], 40);
        }
        else {
            houseData[hID][Icon] = CreateDynamicPickup(1314, 23, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]);
            ncStr[0] = NULL;
            format(ncStr, 512, "{FFFF00}This house is owned by %s!\n", hqData[hID][Owner]);
            houseData[hID][Info] = CreateDynamic3DTextLabel(ncStr, WHITE, hqData[hID][X], hqData[hID][Y], hqData[hID][Z], 40);
        }

    }
}*/

returnHouseID(playerid) {
    for(new hID = 0; hID <= houseID; ++hID) {
        if(IsPlayerInRangeOfPoint(playerid, 1.5, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]))
            return hID;
    }
    return -1;
}

CMD:buy(playerid, params[]) {

    new hID = returnHouseID(playerid);
    if(hID == -1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are not close enough to a house icon.");
    if(playerData[playerid][House] != -1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You already own a house.");
    if(strcmp(houseData[hID][Owner], "For Sale", true)) 
        return SendClientMessage(playerid, RED, "KOS-ERROR: This house is owned by someone else.");
    if(playerData[playerid][Coins] < houseData[hID][Buy])
        return SendClientMessage(playerid, RED, "KOS-ERROR: You don't have the amount of coins required to buy this house.");

    playerData[playerid][House] = hID;
    strcpy(houseData[hID][Owner], sendName(playerid));
    playerData[playerid][Coins] -= houseData[hID][Buy];

    ncStr2[0] = NULL;
    mysql_format(dbConnect, ncStr2, 256, "UPDATE `houses` SET `Owner` = '%s' WHERE `ID` = '%d'", sendName(playerid), houseData[hID][ID]);
    mysql_pquery(dbConnect, ncStr2);

    DestroyDynamicPickup(houseData[hID][Icon]);
    houseData[hID][Icon] = CreateDynamicPickup(19522, 23, houseData[hID][X], houseData[hID][Y], houseData[hID][Z]);
    ncStr[0] = NULL;
    format(ncStr, 512, "{FFFF00}This house is owned by %s!\n{00FF00}Cost: {FFFFFF}%d\n{00FF00}Rent Price: {FFFFFF}%d\n{00FF00}Renters: {FFFFFF}%d\n\
    {00FF00}Sell: {FFFFFF}%d\n\n{f0d92b}Type {FFFFFF}/house {f0d92b}for more!", houseData[hID][Owner], houseData[hID][Buy], houseData[hID][Rent], houseData[hID][Renters], houseData[hID][Sell]);
    Update3DTextLabelText(houseData[hID][Info], WHITE, ncStr);

    return 1;
}


CMD:sell(playerid, params[]) {

    new hID = returnHouseID(playerid);
    if(hID == -1)
        return SendClientMessage(playerid, RED, "KOS-ERROR: You are not close enough to a house icon.");
    if(playerData[playerid][House] != hID)
        return SendClientMessage(playerid, RED, "KOS-ERROR: This house is not yours");
    return 1;
}

//Admin System
public checkAccountBan(playerid) {

    GameTextForPlayer(playerid, "Checking account ban status", 4000, 4);

    if(cache_num_rows()) {
        cache_get_value_int(0, "ID", banData[playerid][ID]);
        cache_get_value_int(0, "BanDate", banData[playerid][BanDate]);
        cache_get_value_int(0, "Time", banData[playerid][Time]);

        if(banData[playerid][Time] == -1) {
            for(new l; l < 20; l++) SendClientMessage(playerid, -1, "");
            //------------------------------------------------------------------
            SendClientMessage(playerid, Blue, "--------------------KOS-BOT--------------------");
            format(ncStr, 144, "Sorry, but {FF0000}%s {CEC8C8}is blocked on our server!", sendName(playerid));
            SendClientMessage(playerid, GREY, ncStr);
            SendClientMessage(playerid, GREY, "Visit {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}for Un Block!");
            SendClientMessage(playerid, Blue, "-----------------------------------------------");
            //------------------------------------------------------------------
            SetTimerEx("KickEx", 50, false, "d", playerid);
        }
        else if(banData[playerid][Time] < gettime())
            ncStr[0] = NULL, banData[playerid][Time] = 0,
            mysql_format(dbConnect, ncStr, 128, "UPDATE `bans` SET `Time` = '0' WHERE `ID` = '%d'", banData[playerid][ID]),
            mysql_pquery(dbConnect, ncStr);
        else if(banData[playerid][Time] != 0) {
            for(new l; l < 20; l++) SendClientMessage(playerid, -1, "");
            //------------------------------------------------------------------
            SendClientMessage(playerid, Blue, "--------------------KOS-BOT--------------------");
            format(ncStr, 144, "Sorry, but {FF0000}%s {CEC8C8}is banned on our server!", sendName(playerid));
            SendClientMessage(playerid, GREY, ncStr);
            format(ncStr, 144, "This ban is set to expire in {FF0000}%d {CEC8C8}day(s)!", floatround(((banData[playerid][Time] - gettime()) / 86400)) + 1);
            SendClientMessage(playerid, GREY, ncStr);
            SendClientMessage(playerid, GREY, "Visit {00BBF6}www.Kingdom-of-Stunt.com {CEC8C8}for UnBan!");
            SendClientMessage(playerid, Blue, "-----------------------------------------------");
            //------------------------------------------------------------------
            SetTimerEx("KickEx", 50, false, "d", playerid);
        }
    }
}

CMD:showgpci(playerid) {

    new gpcistring[42];
    format(gpcistring, 42, "%s", ReturnGPCI(playerid));
    SendClientMessage(playerid, -1, gpcistring);
    return 1;
}


ReturnGPCI(iPlayerID)
{
    new 
        szSerial[41]; // 40 + \0
 
    gpci(iPlayerID, szSerial, sizeof(szSerial));
    return szSerial;
}