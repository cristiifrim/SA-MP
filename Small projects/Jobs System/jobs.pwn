#if defined Header 
	Job system by NeaCristy. Please keep the credits and enjoy the system.
	Contact: WhatsApp: 0732391396; E-Mail: neacristy_scripts@yahoo.com;

	Jobs Contained: -Trucker-, -Fisher-, -Farmer-, -Drug Manufacter-, Hunter, -Air Transporter-, -Courier-, -PizzaBoy-, -Woodcutter-.

	I will need: Actors, 3dTexts, Commands;

	Done at the moment: Farmer, Trucker, Pizza Delivery, Courier, Drugs Manufacter, Woodcutter, Air Transporter, Fisher;
#endif


#include <a_samp>
#include <streamer>
#include <zcmd>
#include <sscanf2>
#include <a_mysql>
#include <foreach>
#include <playerprogress>
#include <crashdetect>

#define maxJobs 9
#define sqlHost "193.203.39.132"
#define sqlPass "nuamparola"
#define sqlDB "trippieredd"
#define sqlUser "trippieredd"

#define randomEx(%0,%1) \
	(random(%1-(%0))+%0)

enum jobData {

	jobActor,
	Text3D: jobInfo,
	jobName[24],
	// Fac cu astea ca am nev la mai multe
	Float: X,
	Float: Y,
	Float: Z
}
enum treeData {
	obj,
	Text3D: tree3D,
	bool: cutted
}

new playerJob[maxJobs][jobData],
sqlConnect,
inJob[MAX_PLAYERS], tree[9][treeData],
Text:Char, Text:Combina, PlayerText: Farm,
Text: GPS1, Text: GPS2, Text: GPS3, Text: GPS4, PlayerText: GPS5,
Text: BOX1, Text: BOX2, PlayerText: playerDiag, //Text:DIAG1, Text: DIAG2, Text: DIAG3,
Text:PIZZA1, Text:PIZZA2, Text:PIZZA3, Text:PIZZA4, Text:PIZZA5,
Text:CUR1, Text:CUR2, Text:CUR3, Text:CUR4, Text:CUR5, Text: CUR6,
Text:fishTD1, Text:fishTD2, Text:fishTD3, Text:fishTD4, Text:fishTD5,
PlayerBar: Drugs, PlayerText: DCollect,
Float: xyz[MAX_PLAYERS][4], // 0 - X, 1 - Y, 2 - Z, 3 - distanta parcursa
pickUp[MAX_PLAYERS], cTree[MAX_PLAYERS], packages[MAX_PLAYERS], Text3D: baginfo[MAX_PLAYERS], fishzone, deerZone[MAX_PLAYERS], deers[MAX_PLAYERS],
attachedDeers[MAX_PLAYERS][4];

new Float:zones_points_0[] = {
	-732.0,-2111.0,-678.0,-2050.0,-667.0,-1902.0,-505.0,-1909.0,-451.0,-1894.0,-457.0,-1865.0,-670.0,-1878.0,-773.0,-1852.0,-853.0,-1922.0,-857.0,-1992.0,
	-798.0,-2071.0,-732.0,-2111.0
};

forward LoadJobs();		forward startWork(playerid, jobid);	forward farmTimer();
forward attachTrailer(playerid, trailerid);	forward changeCamera(playerid, jobid);
forward updateTD(playerid, jobid);	forward reviveTree(treeid);	forward handFishing(playerid);
forward getFishEx(playerid);	forward startJobEx(playerid, __jobId);	forward spawnDeer(playerid);
forward killDeer(playerid, deerid);

new Iterator:Jobing<MAX_PLAYERS>;

public OnFilterScriptInit() {

	sqlConnect = mysql_connect(sqlHost, sqlUser, sqlDB, sqlPass);
	mysql_log(LOG_ERROR | LOG_DEBUG | LOG_WARNING, LOG_TYPE_TEXT);
	mysql_tquery(sqlConnect, "SELECT * FROM `jobs`", "LoadJobs", "");
	UsePlayerPedAnims();	SetTimer("farmTimer", 1000, true);

	fishzone = CreateDynamicPolygon(zones_points_0);


	Char = TextDrawCreate(454.600006, 290.516998, "");	TextDrawLetterSize(Char, 0.000000, 0.000000);
	TextDrawTextSize(Char, 111.000000, 90.000000);		TextDrawAlignment(Char, 1);
	TextDrawColor(Char, -1);							TextDrawSetShadow(Char, 0);
	TextDrawSetOutline(Char, 0);						TextDrawBackgroundColor(Char, 0);
	TextDrawFont(Char, 5);								TextDrawSetProportional(Char, 0);
	TextDrawSetShadow(Char, 0);							TextDrawSetPreviewModel(Char, 161);
	TextDrawSetPreviewRot(Char, 0.000000, 0.000000, 0.000000, 1.000000);

	Combina = TextDrawCreate(529.506164, 252.165771, "");TextDrawLetterSize(Combina, 0.000000, 0.000000);
	TextDrawTextSize(Combina, 107.000000, 97.000000);	TextDrawAlignment(Combina, 1);
	TextDrawColor(Combina, -1);							TextDrawSetShadow(Combina, 0);
	TextDrawSetOutline(Combina, 0);						TextDrawBackgroundColor(Combina, 0);
	TextDrawFont(Combina, 5);							TextDrawSetProportional(Combina, 0);
	TextDrawSetShadow(Combina, 0);						TextDrawSetPreviewModel(Combina, 532);
	TextDrawSetPreviewRot(Combina, 0.000000, 0.000000, 0.000000, 1.000000);TextDrawSetPreviewVehCol(Combina, 1, 1);

	GPS1 = TextDrawCreate(638.899902, 320.599731, "Global Positioning System:"); TextDrawLetterSize(GPS1, 0.177999, 1.681669);
	TextDrawAlignment(GPS1, 3);													 TextDrawColor(GPS1, -1);
	TextDrawSetShadow(GPS1, 0);													 TextDrawSetOutline(GPS1, 1);
	TextDrawBackgroundColor(GPS1, 255);											 TextDrawFont(GPS1, 2);
	TextDrawSetProportional(GPS1, 1);											 TextDrawSetShadow(GPS1, 0);

	GPS2 = TextDrawCreate(475.799896, 322.233245, "");							 TextDrawLetterSize(GPS2, 0.000000, 0.000000);
	TextDrawTextSize(GPS2, 90.000000, 90.000000);								 TextDrawAlignment(GPS2, 1);
	TextDrawColor(GPS2, -1);													 TextDrawSetShadow(GPS2, 0);
	TextDrawSetOutline(GPS2, 0);												 TextDrawBackgroundColor(GPS2, 0);
	TextDrawFont(GPS2, 5);														 TextDrawSetProportional(GPS2, 0);
	TextDrawSetShadow(GPS2, 0);													 TextDrawSetPreviewModel(GPS2, 515);
	TextDrawSetPreviewRot(GPS2, 0.000000, 0.000000, 35.000000, 1.000000);		 TextDrawSetPreviewVehCol(GPS2, 5, 1);

	GPS3 = TextDrawCreate(533.901000, 256.833465, "");							 TextDrawLetterSize(GPS3, 0.000000, 0.000000);
	TextDrawTextSize(GPS3, 120.000000, 109.000000);								 TextDrawAlignment(GPS3, 1);
	TextDrawColor(GPS3, -1);													 TextDrawSetShadow(GPS3, 0);
	TextDrawSetOutline(GPS3, 0);												 TextDrawBackgroundColor(GPS3, 0);
	TextDrawFont(GPS3, 5);														 TextDrawSetProportional(GPS3, 0);
	TextDrawSetShadow(GPS3, 0);													 TextDrawSetPreviewModel(GPS3, 584);
	TextDrawSetPreviewRot(GPS3, 0.000000, 0.000000, -25.000000, 1.000000);	     TextDrawSetPreviewVehCol(GPS3, 1, 1);

	GPS4 = TextDrawCreate(578.401062, 248.099105, "");							 TextDrawLetterSize(GPS4, 0.000000, 0.000000);
	TextDrawTextSize(GPS4, 94.000000, 80.000000);								 TextDrawAlignment(GPS4, 1);
	TextDrawColor(GPS4, -1);													 TextDrawSetShadow(GPS4, 0);
	TextDrawSetOutline(GPS4, 0);												 TextDrawBackgroundColor(GPS4, 0);
	TextDrawFont(GPS4, 5);													     TextDrawSetProportional(GPS4, 0);
	TextDrawSetShadow(GPS4, 0);											  	 	 TextDrawSetPreviewModel(GPS4, 6);
	TextDrawSetPreviewRot(GPS4, 0.000000, 0.000000, -20.000000, 1.000000);

	BOX1 = TextDrawCreate(318.500000, 2.166651, "box");
	TextDrawLetterSize(BOX1, 0.000000, 10.850001);
	TextDrawTextSize(BOX1, 0.000000, 752.000000);
	TextDrawAlignment(BOX1, 2);
	TextDrawColor(BOX1, -1);
	TextDrawUseBox(BOX1, 1);
	TextDrawBoxColor(BOX1, 255);
	TextDrawSetShadow(BOX1, 0);
	TextDrawSetOutline(BOX1, 0);
	TextDrawBackgroundColor(BOX1, 255);
	TextDrawFont(BOX1, 1);
	TextDrawSetProportional(BOX1, 1);
	TextDrawSetShadow(BOX1, 0);

	BOX2 = TextDrawCreate(341.000000, 342.832946, "box");
	TextDrawLetterSize(BOX2, 0.000000, 12.000001);
	TextDrawTextSize(BOX2, 0.000000, 758.000000);
	TextDrawAlignment(BOX2, 2);
	TextDrawColor(BOX2, -1);
	TextDrawUseBox(BOX2, 1);
	TextDrawBoxColor(BOX2, 255);
	TextDrawSetShadow(BOX2, 0);
	TextDrawSetOutline(BOX2, 0);
	TextDrawBackgroundColor(BOX2, 255);
	TextDrawFont(BOX2, 1);
	TextDrawSetProportional(BOX2, 1);
	TextDrawSetShadow(BOX2, 0);

	/*DIAG1 = TextDrawCreate(398.599273, 362.933258, "Hello, numejucator!");
	TextDrawLetterSize(DIAG1, 0.245999, 1.413333);
	TextDrawAlignment(DIAG1, 3);
	TextDrawColor(DIAG1, -1);
	TextDrawSetShadow(DIAG1, 0);
	TextDrawSetOutline(DIAG1, 0);
	TextDrawBackgroundColor(DIAG1, 255);
	TextDrawFont(DIAG1, 2);
	TextDrawSetProportional(DIAG1, 1);
	TextDrawSetShadow(DIAG1, 0);*/

	/*DIAG3 = TextDrawCreate(479.600860, 390.967468, "In order to be paid, you need to harvest for a distance that equals 500 meters.");
	TextDrawLetterSize(DIAG3, 0.175500, 1.215000);
	TextDrawAlignment(DIAG3, 3);
	TextDrawColor(DIAG3, -1);
	TextDrawSetShadow(DIAG3, 0);
	TextDrawSetOutline(DIAG3, 0);
	TextDrawBackgroundColor(DIAG3, 255);
	TextDrawFont(DIAG3, 2);
	TextDrawSetProportional(DIAG3, 1);
	TextDrawSetShadow(DIAG3, 0);*/

	PIZZA1 = TextDrawCreate(567.800415, 263.866607, "");
	TextDrawLetterSize(PIZZA1, 0.000000, 0.000000);
	TextDrawTextSize(PIZZA1, 90.000000, 90.000000);
	TextDrawAlignment(PIZZA1, 1);
	TextDrawColor(PIZZA1, -1);
	TextDrawSetShadow(PIZZA1, 0);
	TextDrawSetOutline(PIZZA1, 0);
	TextDrawBackgroundColor(PIZZA1, 0);
	TextDrawFont(PIZZA1, 5);
	TextDrawSetProportional(PIZZA1, 0);
	TextDrawSetShadow(PIZZA1, 0);
	TextDrawSetPreviewModel(PIZZA1, 448);
	TextDrawSetPreviewRot(PIZZA1, 0.000000, 0.000000, -45.000000, 0.800000);
	TextDrawSetPreviewVehCol(PIZZA1, 3, 1);

	PIZZA2 = TextDrawCreate(487.901000, 333.833618, "");
	TextDrawLetterSize(PIZZA2, 0.000000, 0.000000);
	TextDrawTextSize(PIZZA2, 56.000000, 74.000000);
	TextDrawAlignment(PIZZA2, 1);
	TextDrawColor(PIZZA2, -1);
	TextDrawSetShadow(PIZZA2, 0);
	TextDrawSetOutline(PIZZA2, 0);
	TextDrawBackgroundColor(PIZZA2, 0);
	TextDrawFont(PIZZA2, 5);
	TextDrawSetProportional(PIZZA2, 0);
	TextDrawSetShadow(PIZZA2, 0);
	TextDrawSetPreviewModel(PIZZA2, 2814);
	TextDrawSetPreviewRot(PIZZA2, -25.000000, 0.000000, -13.000000, 1.000000);

	PIZZA3 = TextDrawCreate(463.901062, 298.849121, "");
	TextDrawLetterSize(PIZZA3, 0.000000, 0.000000);
	TextDrawTextSize(PIZZA3, 94.000000, 80.000000);
	TextDrawAlignment(PIZZA3, 1);
	TextDrawColor(PIZZA3, -1);
	TextDrawSetShadow(PIZZA3, 0);
	TextDrawSetOutline(PIZZA3, 0);
	TextDrawBackgroundColor(PIZZA3, 0);
	TextDrawFont(PIZZA3, 5);
	TextDrawSetProportional(PIZZA3, 0);
	TextDrawSetShadow(PIZZA3, 0);
	TextDrawSetPreviewModel(PIZZA3, 155);
	TextDrawSetPreviewRot(PIZZA3, 0.000000, 0.000000, 23.000000, 1.000000);

	PIZZA4 = TextDrawCreate(512.300109, 273.600402, "");
	TextDrawLetterSize(PIZZA4, 0.000000, 0.000000);
	TextDrawTextSize(PIZZA4, 68.000000, 87.000000);
	TextDrawAlignment(PIZZA4, 1);
	TextDrawColor(PIZZA4, -1);
	TextDrawSetShadow(PIZZA4, 0);
	TextDrawSetOutline(PIZZA4, 0);
	TextDrawBackgroundColor(PIZZA4, 0);
	TextDrawFont(PIZZA4, 5);
	TextDrawSetProportional(PIZZA4, 0);
	TextDrawSetShadow(PIZZA4, 0);
	TextDrawSetPreviewModel(PIZZA4, 2769);
	TextDrawSetPreviewRot(PIZZA4, 0.000000, 0.000000, -70.000000, 1.000000);

	PIZZA5 = TextDrawCreate(595.999755, 344.250244, "");
	TextDrawLetterSize(PIZZA5, 0.000000, 0.000000);
	TextDrawTextSize(PIZZA5, 57.000000, 43.000000);
	TextDrawAlignment(PIZZA5, 1);
	TextDrawColor(PIZZA5, -1);
	TextDrawSetShadow(PIZZA5, 0);
	TextDrawSetOutline(PIZZA5, 0);
	TextDrawBackgroundColor(PIZZA5, 0);
	TextDrawFont(PIZZA5, 5);
	TextDrawSetProportional(PIZZA5, 0);
	TextDrawSetShadow(PIZZA5, 0);
	TextDrawSetPreviewModel(PIZZA5, 19571);
	TextDrawSetPreviewRot(PIZZA5, 0.000000, 0.000000, -25.000000, 1.000000);

	CUR1 = TextDrawCreate(470.101928, 319.799682, "");
	TextDrawLetterSize(CUR1, 0.000000, 0.000000);
	TextDrawTextSize(CUR1, 90.000000, 90.000000);
	TextDrawAlignment(CUR1, 1);
	TextDrawColor(CUR1, -1);
	TextDrawSetShadow(CUR1, 0);
	TextDrawSetOutline(CUR1, 0);
	TextDrawBackgroundColor(CUR1, 0);
	TextDrawFont(CUR1, 5);
	TextDrawSetProportional(CUR1, 0);
	TextDrawSetShadow(CUR1, 0);
	TextDrawSetPreviewModel(CUR1, 440);
	TextDrawSetPreviewRot(CUR1, 0.000000, 0.000000, 15.000000, 0.800000);
	TextDrawSetPreviewVehCol(CUR1, 7, 1);

	CUR2 = TextDrawCreate(610.806884, 335.233673, "");
	TextDrawLetterSize(CUR2, 0.000000, 0.000000);
	TextDrawTextSize(CUR2, 43.000000, 59.000000);
	TextDrawAlignment(CUR2, 1);
	TextDrawColor(CUR2, -1);
	TextDrawSetShadow(CUR2, 0);
	TextDrawSetOutline(CUR2, 0);
	TextDrawBackgroundColor(CUR2, 0);
	TextDrawFont(CUR2, 5);
	TextDrawSetProportional(CUR2, 0);
	TextDrawSetShadow(CUR2, 0);
	TextDrawSetPreviewModel(CUR2, 1579);
	TextDrawSetPreviewRot(CUR2, 45.000000, 0.000000, 35.000000, 1.000000);

	CUR3 = TextDrawCreate(470.901062, 269.099029, "");
	TextDrawLetterSize(CUR3, 0.000000, 0.000000);
	TextDrawTextSize(CUR3, 94.000000, 80.000000);
	TextDrawAlignment(CUR3, 1);
	TextDrawColor(CUR3, -1);
	TextDrawSetShadow(CUR3, 0);
	TextDrawSetOutline(CUR3, 0);
	TextDrawBackgroundColor(CUR3, 0);
	TextDrawFont(CUR3, 5);
	TextDrawSetProportional(CUR3, 0);
	TextDrawSetShadow(CUR3, 0);
	TextDrawSetPreviewModel(CUR3, 91);
	TextDrawSetPreviewRot(CUR3, 0.000000, 0.000000, 35.000000, 1.000000);

	CUR4 = TextDrawCreate(597.000000, 271.066802, "");
	TextDrawLetterSize(CUR4, 0.000000, 0.000000);
	TextDrawTextSize(CUR4, 43.000000, 59.000000);
	TextDrawAlignment(CUR4, 1);
	TextDrawColor(CUR4, -1);
	TextDrawSetShadow(CUR4, 0);
	TextDrawSetOutline(CUR4, 0);
	TextDrawBackgroundColor(CUR4, 0);
	TextDrawFont(CUR4, 5);
	TextDrawSetProportional(CUR4, 0);
	TextDrawSetShadow(CUR4, 0);
	TextDrawSetPreviewModel(CUR4, 1575);
	TextDrawSetPreviewRot(CUR4, -45.000000, 0.000000, 15.000000, 1.000000);

	CUR5 = TextDrawCreate(562.306884, 271.066833, "");
	TextDrawLetterSize(CUR5, 0.000000, 0.000000);
	TextDrawTextSize(CUR5, 43.000000, 59.000000);
	TextDrawAlignment(CUR5, 1);
	TextDrawColor(CUR5, -1);
	TextDrawSetShadow(CUR5, 0);
	TextDrawSetOutline(CUR5, 0);
	TextDrawBackgroundColor(CUR5, 0);
	TextDrawFont(CUR5, 5);
	TextDrawSetProportional(CUR5, 0);
	TextDrawSetShadow(CUR5, 0);
	TextDrawSetPreviewModel(CUR5, 1576);
	TextDrawSetPreviewRot(CUR5, -45.000000, 0.000000, -15.000000, 1.000000);

	CUR6 = TextDrawCreate(525.500000, 272.816772, "");
	TextDrawLetterSize(CUR6, 0.000000, 0.000000);
	TextDrawTextSize(CUR6, 43.000000, 59.000000);
	TextDrawAlignment(CUR6, 1);
	TextDrawColor(CUR6, -1);
	TextDrawSetShadow(CUR6, 0);
	TextDrawSetOutline(CUR6, 0);
	TextDrawBackgroundColor(CUR6, 0);
	TextDrawFont(CUR6, 5);
	TextDrawSetProportional(CUR6, 0);
	TextDrawSetShadow(CUR6, 0);
	TextDrawSetPreviewModel(CUR6, 1577);
	TextDrawSetPreviewRot(CUR6, -45.000000, 0.000000, 15.000000, 1.000000);

	fishTD1 = TextDrawCreate(512.000183, 332.281616, "box");
	TextDrawLetterSize(fishTD1, 0.000000, 5.266666);
	TextDrawTextSize(fishTD1, 639.000000, 0.000000);
	TextDrawAlignment(fishTD1, 1);
	TextDrawColor(fishTD1, 80);
	TextDrawUseBox(fishTD1, 1);
	TextDrawBoxColor(fishTD1, 100);
	TextDrawSetShadow(fishTD1, 0);
	TextDrawSetOutline(fishTD1, 0);
	TextDrawBackgroundColor(fishTD1, 90);
	TextDrawFont(fishTD1, 1);
	TextDrawSetProportional(fishTD1, 1);
	TextDrawSetShadow(fishTD1, 0);

	fishTD2 = TextDrawCreate(619.766540, 331.866699, "FISHING ZONE");
	TextDrawLetterSize(fishTD2, 0.407666, 1.707852);
	TextDrawAlignment(fishTD2, 3);
	TextDrawColor(fishTD2, -1);
	TextDrawSetShadow(fishTD2, 0);
	TextDrawSetOutline(fishTD2, 0);
	TextDrawBackgroundColor(fishTD2, 255);
	TextDrawFont(fishTD2, 3);
	TextDrawSetProportional(fishTD2, 1);
	TextDrawSetShadow(fishTD2, 0);

	fishTD3 = TextDrawCreate(638.333190, 346.799957, "] /placebackpack ]");
	TextDrawLetterSize(fishTD3, 0.270000, 1.214221);
	TextDrawAlignment(fishTD3, 3);
	TextDrawColor(fishTD3, -1);
	TextDrawSetShadow(fishTD3, 0);
	TextDrawSetOutline(fishTD3, 0);
	TextDrawBackgroundColor(fishTD3, 255);
	TextDrawFont(fishTD3, 2);
	TextDrawSetProportional(fishTD3, 1);
	TextDrawSetShadow(fishTD3, 0);

	fishTD4 = TextDrawCreate(625.336364, 357.500610, "] /depositfish ]");
	TextDrawLetterSize(fishTD4, 0.270000, 1.214221);
	TextDrawAlignment(fishTD4, 3);
	TextDrawColor(fishTD4, -1);
	TextDrawSetShadow(fishTD4, 0);
	TextDrawSetOutline(fishTD4, 0);
	TextDrawBackgroundColor(fishTD4, 255);
	TextDrawFont(fishTD4, 2);
	TextDrawSetProportional(fishTD4, 1);
	TextDrawSetShadow(fishTD4, 0);

	fishTD5 = TextDrawCreate(628.435607, 367.801239, "] /getbackpack ]");
	TextDrawLetterSize(fishTD5, 0.270000, 1.214221);
	TextDrawAlignment(fishTD5, 3);
	TextDrawColor(fishTD5, -1);
	TextDrawSetShadow(fishTD5, 0);
	TextDrawSetOutline(fishTD5, 0);
	TextDrawBackgroundColor(fishTD5, 255);
	TextDrawFont(fishTD5, 2);
	TextDrawSetProportional(fishTD5, 1);
	TextDrawSetShadow(fishTD5, 0);

	tree[1][obj] = CreateDynamicObject(693, -554.32813, -32.94190, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[2][obj] = CreateDynamicObject(693, -571.12469, -0.99762, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[3][obj] = CreateDynamicObject(693, -563.56793, -21.34284, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[4][obj] = CreateDynamicObject(693, -575.30902, -11.60782, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[5][obj] = CreateDynamicObject(693, -556.61975, 2.44546, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[6][obj] = CreateDynamicObject(693, -558.53296, -10.85517, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[7][obj]= CreateDynamicObject(693, -545.41095, -3.76465, 67.93728,   0.00000, 0.00000, 0.00000);
	tree[8][obj] = CreateDynamicObject(693, -549.47058, -16.60959, 67.93728,   0.00000, 0.00000, 0.00000);

	new tmpobjid;
	tmpobjid = CreateDynamicObject(818, -1037.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1046.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1055.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1064.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1073.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1082.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1091.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1100.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1109.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1118.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1127.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(818, -1136.684082, -1070.410278, 131.632720, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 0, 3261, "grasshouse", "veg_marijuana", 0x00000000);
	tmpobjid = CreateDynamicObject(3409, -1078.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1082.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1086.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1090.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1094.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1125.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1129.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1133.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1137.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1141.145141, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1171.145141, -1095.772216, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1175.145141, -1095.772216, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1179.145141, -1095.772216, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1183.145141, -1095.772216, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1187.145141, -1095.772216, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1124.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1128.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1132.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1136.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1140.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1077.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1081.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1085.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1089.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1093.944702, -1084.358764, 127.680541, 0.000000, 0.000015, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1039.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1052.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1065.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1078.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1091.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1104.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1117.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1130.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1143.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1156.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3276, -1169.119750, -1105.041625, 129.036895, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1075.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1075.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1078.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1078.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1081.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1081.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1084.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1084.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1087.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1087.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1090.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1090.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1093.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1093.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1096.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1096.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1099.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1099.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1102.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1102.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1105.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1105.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1123.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1123.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1126.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1126.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1129.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1129.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1132.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1132.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1135.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1135.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1138.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1138.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1141.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1141.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1144.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1144.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1147.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1147.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1150.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1150.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1153.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1153.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1156.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1156.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1159.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1159.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1162.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1162.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1165.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1165.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1168.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1168.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1171.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1171.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1174.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1174.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1177.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1177.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1180.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1180.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1183.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1183.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1186.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1186.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1189.402587, -1088.238647, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(19473, -1189.402587, -1091.568969, 128.100860, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1037.524658, -1095.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1097.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1094.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1091.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1088.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1085.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1037.524658, -1082.672851, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1037.524658, -1090.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1037.524658, -1085.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1037.524658, -1080.622436, 127.680541, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1047.524658, -1081.672973, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1079.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1082.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1085.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1088.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1091.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1047.524658, -1094.622558, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1047.524658, -1086.672973, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1047.524658, -1091.672973, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1047.524658, -1096.672973, 127.680541, 0.000000, 0.000007, 179.999938, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1187.059570, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1189.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1186.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1183.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1180.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1177.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3261, -1174.109985, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1182.059570, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1177.059570, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(3409, -1172.059570, -1077.437744, 127.680541, -0.000007, -0.000000, -90.000022, -1, -1, -1, 300.00, 300.00);

	CreateActor(243, -1425.5680, -1529.3844, 102.2494, 359.6537);

	tree[1][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 1\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-554.32813, -32.94190, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[2][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 2\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-563.56793, -21.34284, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[3][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 3\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-575.30902, -11.60782, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[4][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 4\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-556.61975, 2.44546, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[5][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 5\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-558.53296, -10.85517, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[6][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 6\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-545.41095, -3.76465, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[7][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 7\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-545.41095, -3.76465, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	tree[8][tree3D] = CreateDynamic3DTextLabel("{FF0000}TREE ID: 8\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", 0x00FF00AA,-549.47058, -16.60959, 67.93728, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);

	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1080.2596,-1095.8872,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1089.5653,-1090.0135,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1085.0908,-1083.9738,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1122.2141,-1084.8730,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1129.6074,-1095.2813,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);
	CreateDynamic3DTextLabel("{FF0000}/collectdrugs\n{FFFFFF}Start work and collect drugs.", 0x00FF00AA,-1142.6465,-1089.0116,129.2188, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1,  -1, STREAMER_3D_TEXT_LABEL_SD, -1,  0);

	return 1;
}

public OnFilterScriptExit() return mysql_close();

public LoadJobs() {

	new ncStr[100];
	for(new jobID = 0; jobID < maxJobs; ++jobID) {
		if(cache_get_row_count() > 0) {
			/*playerJob[jobID][jobActor] = CreateActor(cache_get_field_content_int(jobID, "Skin", sqlConnect), cache_get_field_content_float(jobID, "PosX", sqlConnect),\
			cache_get_field_content_float(jobID, "PosY", sqlConnect), cache_get_field_content_float(jobID, "PosZ", sqlConnect), cache_get_field_content_float(jobID, "Rotation", sqlConnect));*/
			playerJob[jobID][X] = cache_get_field_content_float(jobID, "PosX", sqlConnect);
			playerJob[jobID][Y] = cache_get_field_content_float(jobID, "PosY", sqlConnect);
			playerJob[jobID][Z] = cache_get_field_content_float(jobID, "PosZ", sqlConnect);

			playerJob[jobID][jobActor] = CreateActor(cache_get_field_content_int(jobID, "Skin", sqlConnect), playerJob[jobID][X], playerJob[jobID][Y],\
			playerJob[jobID][Z], cache_get_field_content_float(jobID, "Rotation", sqlConnect));

			cache_get_field_content(jobID, "Name", playerJob[jobID][jobName], sqlConnect, 150);

			format(ncStr, 100, "{FF0000}Job: {FFFFFF}%s\n{00FF00}Press 'Y' to interact and work.", playerJob[jobID][jobName]);
			//playerJob[jobID][jobInfo] = CreateDynamic3DTextLabel(ncStr, 0xFFFFFFAA, cache_get_field_content_float(jobID, "PosX", sqlConnect),
			//cache_get_field_content_float(jobID, "PosY", sqlConnect), cache_get_field_content_float(jobID, "PosZ", sqlConnect) + 1.25, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);

			playerJob[jobID][jobInfo] = CreateDynamic3DTextLabel(ncStr, 0xFFFFFFAA, playerJob[jobID][X], playerJob[jobID][Y], playerJob[jobID][Z] + 1.25, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
			printf("%s LOADED '\n'", playerJob[jobID][jobName]);
		}
	}
	return 1;
}

public OnPlayerConnect(playerid) {

	inJob[playerid] = -1; pickUp[playerid] = 0; packages[playerid] = 0; cTree[playerid] = 0, deers[playerid] = 0;

	playerDiag = CreatePlayerTextDraw(playerid, 350, 378.416748, "I'm glad to see that you want to work for us.");
	PlayerTextDrawLetterSize(playerid, playerDiag, 0.203000, 1.162500);
	PlayerTextDrawAlignment(playerid, playerDiag, 2);
	PlayerTextDrawColor(playerid, playerDiag, -1);
	PlayerTextDrawSetShadow(playerid, playerDiag, 0);
	PlayerTextDrawSetOutline(playerid, playerDiag, 0);
	PlayerTextDrawBackgroundColor(playerid, playerDiag, 255);
	PlayerTextDrawFont(playerid, playerDiag, 2);
	PlayerTextDrawSetProportional(playerid, playerDiag, 1);
	PlayerTextDrawSetShadow(playerid, playerDiag, 0);

	GPS5 = CreatePlayerTextDraw(playerid, 581.399536, 322.800018, "~n~You have to drive for:~n~5 km");	PlayerTextDrawLetterSize(playerid, GPS5, 0.146999, 1.634999);
	PlayerTextDrawTextSize(playerid, GPS5, 0.000000, 113.000000);	PlayerTextDrawAlignment(playerid, GPS5, 2);
	PlayerTextDrawColor(playerid, GPS5, 16777215);					PlayerTextDrawUseBox(playerid, GPS5, 1);
	PlayerTextDrawBoxColor(playerid, GPS5, 75);						PlayerTextDrawSetShadow(playerid, GPS5, 1);
	PlayerTextDrawSetOutline(playerid, GPS5, 1);					PlayerTextDrawBackgroundColor(playerid, GPS5, 90);
	PlayerTextDrawFont(playerid, GPS5, 2);							PlayerTextDrawSetProportional(playerid, GPS5, 1);
	PlayerTextDrawSetShadow(playerid, GPS5, 1);		

	return 1;
}
public OnPlayerDisconnect(playerid, reason) {

	inJob[playerid] = -1;

	return 1;

}

/*CMD:createjob(playerid, params[]) {

	new ncStr[256], Name[24], skin, Float:x, Float:y, Float:z, Float:rot;

	if(sscanf(params, "s[24]d", Name, skin)) return SendClientMessage(playerid, -1, "SSCANF");
	if(strlen(Name) < 5 || strlen(Name) > 24) return SendClientMessage(playerid, -1, "nAME");
	if(skin > 311 || skin < 0) return SendClientMessage(playerid, -1, "Skin");

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, rot);

	mysql_format(sqlConnect, ncStr, 256, "INSERT INTO `jobs` (`Name`, `Skin`, `PosX`, `PosY`, `PosZ`, `Rotation`) VALUES ('%e', '%d', '%f', '%f', '%f', '%f')", Name, skin, x, y, z, rot);
	mysql_pquery(sqlConnect, ncStr);

	return 1;
}*/

CMD:placebackpack(playerid, params[]) {

	if(inJob[playerid] != 7)						  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You aren't a fisherman."		  );
	if(!IsPlayerInDynamicArea(playerid, fishzone, 0)) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You are not in the fishing zone.");
	if(!IsPlayerAttachedObjectSlotUsed(playerid, 9))  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You already placed the bag"	  );

	GetPlayerPos(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2]);
	cTree[playerid] = CreateDynamicObject(371, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 0, 0, 0, -1,  -1, -1, STREAMER_OBJECT_SD, STREAMER_OBJECT_DD, -1, 0);
	SetPlayerMapIcon(playerid, 55, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 9, -1, MAPICON_GLOBAL);

	new ncStr[150];
	RemovePlayerAttachedObject(playerid, 9);

	format(ncStr, 150, "{FF0000}%s {FFFFFF}backpack.\n{FFFFFF}It contains {00FF00}%d {FFFFFF}fish.", sendName(playerid), packages[playerid]);
	baginfo[playerid] = CreateDynamic3DTextLabel(ncStr, 0x00FF00AA, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2]-1, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,  0, -1, -1, -1,  STREAMER_3D_TEXT_LABEL_SD, -1,  0);

	SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}You placed the backpack. You can't get it untill you catch 15 fish.");
	SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}The backpack it's marked with an anchor on your minimap.");

	SetTimerEx("getFishEx", 2000, false, "d", playerid);

	return 1;
}
CMD:getbackpack(playerid, params[]) {

	if(inJob[playerid] != 7)						  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You aren't a fisherman."		  );
	if(!IsPlayerInDynamicArea(playerid, fishzone, 0)) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You are not in the fishing zone.");
	if(IsPlayerAttachedObjectSlotUsed(playerid, 9))   return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You did not place the bag."	  );
	if(packages[playerid] < 15) 					  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You don't have enough fish."	  );
	if(!IsPlayerInRangeOfPoint(playerid, 5, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2])) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You aren't near your backpack.");

	SetPlayerAttachedObject(playerid, 9, 371, 1, 0.048000, -0.087999, 0.000000, 0.000000, 87.800018, -3.699998, 1.000000, 1.000000, 1.081999);
	DestroyDynamicObject(cTree[playerid]);
	DestroyDynamic3DTextLabel(baginfo[playerid]);

	RemovePlayerMapIcon(playerid, 55);
	SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}You have got a backpack full of fish. Go to John.");
	SetPlayerCheckpoint(playerid, playerJob[7][X], playerJob[7][Y], playerJob[7][Z], 2.0);

	return 1;
}

CMD:depositfish(playerid, params[]) { //vezi ca la /leave trebuie sa distrugi ghiozdanul si 3d textul

	if(inJob[playerid] != 7)						  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You aren't a fisherman."		  );
	if(!IsPlayerInDynamicArea(playerid, fishzone, 0)) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You are not in the fishing zone.");
	if(IsPlayerAttachedObjectSlotUsed(playerid, 9))   return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You did not place the bag."	  );
	if(pickUp[playerid] < 1) 					  	  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You don't have enough fish."	  );
	if(!IsPlayerInRangeOfPoint(playerid, 5, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2])) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You aren't near your backpack.");
	if(packages[playerid] == 15)					  return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Your backpack is full."		  );

	packages[playerid] += pickUp[playerid];
	pickUp[playerid]    = 0;
	new ncStr[150];

	format(ncStr, 150, "{339966}(Fisherman): {FFFFFF}You deposited some fish. You have %d/15 fish.", packages[playerid]);
	SendClientMessage(playerid, 0x339966AA, ncStr);

	format(ncStr, 150, "{FF0000}%s {FFFFFF}backpack.\n{FFFFFF}It contains {00FF00}%d {FFFFFF}fish.", sendName(playerid), packages[playerid]);
	UpdateDynamic3DTextLabelText(baginfo[playerid], 0x339966AA, ncStr);

	if(packages[playerid] < 15)
		SetTimerEx("getFishEx", 2000, false, "d", playerid);
	else
		SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}Your backpack is now full. Use /getbackpack to get it.");


	return 1;
}

CMD:jobs(playerid, params[]) {

	return ShowPlayerDialog(playerid, 6996, DIALOG_STYLE_LIST, "Jobs", "Air Transporter\nCourier\nDrugs Manufacter\nFarmer\nFisherman\nHunter\nPizza Delivery\nTrucker\nWoodcutter", "Select", "Cancel");
}

CMD:collectdrugs(playerid, params[]) {

	if(inJob[playerid] != 4) return SendClientMessage(playerid, -1, "{FF0000}ERROR: You don't do that job.");
	else {
		Drugs = CreatePlayerProgressBar(playerid, 552.00, 368.00, 86.50, 2.50, -1, 100.0);
		SetPlayerProgressBarMaxValue(playerid, Drugs, 5);
		SetPlayerProgressBarValue(playerid, Drugs, 0);
		ShowPlayerProgressBar(playerid, Drugs);

		pickUp[playerid] = 1;

		xyz[playerid][3] = 0;

		DCollect = CreatePlayerTextDraw(playerid, 636.500122, 352.333648, "Collecting Drugs..(0%)");
		PlayerTextDrawLetterSize(playerid, DCollect, 0.151500, 1.384166);
		PlayerTextDrawAlignment(playerid, DCollect, 3);
		PlayerTextDrawColor(playerid, DCollect, -1);
		PlayerTextDrawSetShadow(playerid, DCollect, 1);
		PlayerTextDrawSetOutline(playerid, DCollect, 1);
		PlayerTextDrawBackgroundColor(playerid, DCollect, 255);
		PlayerTextDrawFont(playerid, DCollect, 2);
		PlayerTextDrawSetProportional(playerid, DCollect, 1);
		PlayerTextDrawSetShadow(playerid, DCollect, 1);

		PlayerTextDrawShow(playerid, DCollect);

	}
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPos(playerid, fX, fY,fZ + 7);
    return 1;
}
getJobID(playerid) {

	new _jobID = -1;

	while(++_jobID < maxJobs) {
		//if(IsActorStreamedIn(playerJob[_jobID][jobActor], playerid)) return _jobID;
		if(IsPlayerInRangeOfPoint(playerid, 3, playerJob[_jobID][X], playerJob[_jobID][Y],  playerJob[_jobID][Z])) return _jobID;
	}

	return -1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if(newkeys & KEY_YES && (getJobID(playerid) >= 0 && inJob[playerid] == -1)) pickUp[playerid] = 0, startJob(playerid, getJobID(playerid));

	else if(newkeys & KEY_YES && (inJob[playerid] == 8 && IsPlayerAttachedObjectSlotUsed(playerid, 9) && IsPlayerInRangeOfPoint(playerid, 10, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2]))) {
		
		RemovePlayerAttachedObject(playerid, 9);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);

		if(++deers[playerid] < 4) {
			if(deers[playerid] == 1) {
			    attachedDeers[playerid][0] = CreateDynamicObject(19315,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0); 
    			AttachDynamicObjectToVehicle(attachedDeers[playerid][0], cTree[playerid], -0.020, -1.147, -0.174, 101.299, 0.000, 0.000);
			}else if(deers[playerid] == 2) {
			    attachedDeers[playerid][1] = CreateDynamicObject(19315,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0); 
    			AttachDynamicObjectToVehicle(attachedDeers[playerid][1], cTree[playerid], -0.020, -1.640, 0.000, -58.999, 0.000, 0.000);
			}else if(deers[playerid] == 3) {
			    attachedDeers[playerid][2] = CreateDynamicObject(19315,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0); 
    			AttachDynamicObjectToVehicle(attachedDeers[playerid][2], cTree[playerid], -0.020, -1.855, -0.292, 46.699, 0.000, 0.000);
			}else if(deers[playerid] == 4) {
			    attachedDeers[playerid][3] = CreateDynamicObject(19315,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0); 
    			AttachDynamicObjectToVehicle(attachedDeers[playerid][3], cTree[playerid],  -0.020, -0.967, 0.331, -57.800, 0.000, 0.000);
			}

			SetTimerEx("spawnDeer", 2000, false, "d", playerid);
		}
		else
			pickUp[playerid] = 0,

			SendClientMessage(playerid, 0x339966AA, "(Hunter): {FFFFFF}You have killed enough deers. Go back to the hunter."),

			SetPlayerCheckpoint(playerid, playerJob[8][X] + 2, playerJob[8][Y] + 2, playerJob[8][Z], 4);
	}

	return 1;
}

public updateTD(playerid, jobid) {

	switch(jobid) {
		case 0: {
			PlayerTextDrawSetString(playerid, playerDiag, "I'm glad to see that you want to work for us.");
			if(pickUp[playerid] == 1) 
				PlayerTextDrawSetString(playerid, playerDiag, "In order to be paid, you need to harvest for a distance that equals 500 meters.");
			else SetTimerEx("updateTD", 5000, false, "dd", playerid, 0);
			pickUp[playerid] = 1;
		}
		case 1: {
			PlayerTextDrawSetString(playerid, playerDiag, "I'm glad to see that you want to work for us. We've got a nice truck for you.");
			if(pickUp[playerid] == 1) 
				PlayerTextDrawSetString(playerid, playerDiag, "In order to be paid, you need to deliver our trailer to a specified location.");
			else SetTimerEx("updateTD", 5000, false, "dd", playerid, 1);
			pickUp[playerid] = 1;
		}
		case 2: {
			PlayerTextDrawSetString(playerid, playerDiag, "I'm happy to see people that are thinking about our hungry customers.");
			if(pickUp[playerid] == 1) 
				PlayerTextDrawSetString(playerid, playerDiag, "In order to be paid, deliver the pizza to a customer until it gets cold.");
			else SetTimerEx("updateTD", 5000, false, "dd", playerid, 2);
			pickUp[playerid] = 1;
		}
		case 3: {
			PlayerTextDrawSetString(playerid, playerDiag, "You want to work for us? No problem then.");
			if(pickUp[playerid] == 1) 
				PlayerTextDrawSetString(playerid, playerDiag, "In order to be paid, deliver the package to the point marked on map.");
			else SetTimerEx("updateTD", 5000, false, "dd", playerid, 3);
			pickUp[playerid] = 1;
		}
		case 4: {
			PlayerTextDrawSetString(playerid, playerDiag, "Firstly, you may need to collect some weed to have a nice product.");
			if(pickUp[playerid] == 2)
				PlayerTextDrawSetString(playerid, playerDiag, "Here you can transform the plant into something enjoyable.");
		}
		case 5: {
			PlayerTextDrawSetString(playerid, playerDiag, "I hope that you're not afraid when a tree is falling.");
			if(pickUp[playerid] == 1)
				PlayerTextDrawSetString(playerid, playerDiag, "Here are the marked trees. Choose 3 that you like.");
			else if(pickUp[playerid] == 4)
				PlayerTextDrawSetString(playerid, playerDiag, "Here is your car. Drive slowly to not drop them or hurt someone.");
		}
		case 6: {
			PlayerTextDrawSetString(playerid, playerDiag, "Thank you for helping us. Our pilots left us and you're the last hope.");
		}
		case 7: {
			PlayerTextDrawSetString(playerid, playerDiag, "Do you want to fish? No problem old man, take this backpack to carry fish.");
			if(pickUp[playerid] == 1)
				PlayerTextDrawSetString(playerid, playerDiag, "I have a place were they boy fish only from me. Use your car and go there.");
		}
		case 8: {
			PlayerTextDrawSetString(playerid, playerDiag, "Do you want to hunt? You're in the perfect place.");
		}
	}

	return 1;
}


startJob(playerid, jobId) {

	TogglePlayerControllable(playerid, 0);
	Iter_Add(Jobing, playerid);

	switch(jobId) {
		case 0: { // farmer

			new carid;

			PlayerTextDrawSetString(playerid, playerDiag, "Welcome at our farm, mister!");
			PlayerTextDrawShow(playerid, playerDiag);
			SetTimerEx("updateTD", 4000, false, "dd", playerid, 0);

			TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

			carid = CreateVehicle(532, -397.2441, -1392.3705, 24.5446, 219.0414, -1, -1, 100);
			PutPlayerInVehicle(playerid, carid, 0);

			InterpolateCameraPos(playerid, -374.162689, -1420.249023, 26.448097, -384.412261, -1400.200317, 25.722841, 12000);
			InterpolateCameraLookAt(playerid, -372.967041, -1425.098388, 26.216180, -388.799530, -1397.967529, 24.847332, 12000);

		}
		case 1: { // trucker
			new carid;

			PlayerTextDrawSetString(playerid, playerDiag, "Welcome, big man! I see you like challenging jobs.");
			PlayerTextDrawShow(playerid, playerDiag);
			SetTimerEx("updateTD", 4000, false, "dd", playerid, 1);

			TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

			carid = CreateVehicle(515, -191.9437,-277.9622,1.4297, 90, -1, -1, 100);
			PutPlayerInVehicle(playerid, carid, 0);

			InterpolateCameraPos(playerid, -157.684738, -279.904052, 4.633290, -176.737365, -265.798461, 12.312053, 12000);
			InterpolateCameraLookAt(playerid, -152.720596, -279.999908, 4.043331, -180.062011, -268.594848, 9.836787, 12000);

		}
		case 2: { //pizza
			new carid;

			PlayerTextDrawSetString(playerid, playerDiag, "Hello, dear friend! Thank you for helping us.");
			PlayerTextDrawShow(playerid, playerDiag);
			SetTimerEx("updateTD", 4000, false, "dd", playerid, 2);

			TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

			carid = CreateVehicle(448, 2123.0964,-1779.4518,13.3897,85.9917, -1, -1, 100);
			PutPlayerInVehicle(playerid, carid, 0);

			InterpolateCameraPos(playerid, 2105.966796, -1788.379516, 14.393551, 2128.635253, -1785.399658, 19.963563, 12000);
			InterpolateCameraLookAt(playerid, 2106.075195, -1793.277587, 13.394947, 2124.937500, -1784.059814, 16.876277, 12000);
		}
		case 3: { //courier
			new carid;

			PlayerTextDrawSetString(playerid, playerDiag, "Good evening, mister! May I help you with something?");
			PlayerTextDrawShow(playerid, playerDiag);
			SetTimerEx("updateTD", 4000, false, "dd", playerid, 3);

			TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

			carid = CreateVehicle(440, -2682.9087,-21.5460,4.3359,177.6380, -1, -1, 100);
			PutPlayerInVehicle(playerid, carid, 0);

			InterpolateCameraPos(playerid, -2666.180419, -2.083501, 6.801624, -2674.618408, -34.279750, 13.000782, 12000);
			InterpolateCameraLookAt(playerid, -2661.198974, -1.845709, 6.443213, -2677.062255, -30.776826, 10.401436, 12000);
		}
		case 4: { //drug
			if(pickUp[playerid] == 0) {
				new ncStr[100];

				format(ncStr, sizeof(ncStr), "Hello, mister %s. We would like if you may help us with this legal job here.", sendName(playerid));

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -1059.441772, -1205.517211, 129.829605);
				SetPlayerCameraLookAt(playerid, -1064.425415, -1205.633789, 130.217239, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 4);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 4);
			}
			else if(pickUp[playerid] == 2) { // 2 = 26
				SetPlayerProgressBarValue(playerid, Drugs, 0);
				HidePlayerProgressBar(playerid, Drugs);
				PlayerTextDrawDestroy(playerid, DCollect);

				PlayerTextDrawSetString(playerid, playerDiag, "Secondly, you need to manufacter the drugs to get the best quality possible.");
				PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid,  -1386.778808, -1442.932006, 113.011375);
				SetPlayerCameraLookAt(playerid, -1389.721435, -1446.728515, 111.623001, CAMERA_CUT);

				SetTimerEx("updateTD", 5000, false, "dd", playerid, 26);
			}
			else if(pickUp[playerid] == 4) { // 4 == 28

				DestroyPlayerProgressBar(playerid, Drugs);
				PlayerTextDrawDestroy(playerid, DCollect);

				PlayerTextDrawSetString(playerid, playerDiag, "And now, you need to transport them at a safe location.~n~There you will get your money.");
				PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				new carid = CreateVehicle(424,-1440.9656,-1513.3668,101.7578,273.5164,-1, -1, 100);
				PutPlayerInVehicle(playerid, carid, 0);

				InterpolateCameraPos(playerid, -1430.040405, -1501.679809, 102.081077, -1422.985107, -1528.887695, 107.371589, 12000);
				InterpolateCameraLookAt(playerid, -1425.044677, -1501.513427, 101.957099, -1426.896362, -1526.159912, 105.867828, 12000);

				new rnr = random(3);
				switch(rnr) {
					case 0: xyz[playerid][0] = -2110.2375, xyz[playerid][1] = 0.2719, xyz[playerid][2] = 35.3203;
					case 1: xyz[playerid][0] = 1256.6041, xyz[playerid][1] = 368.5315, xyz[playerid][2] = 19.5614;
					case 2: xyz[playerid][0] = 2485.7939, xyz[playerid][1] = -1016.1608, xyz[playerid][2] = 65.3421;
				}
			}
		}
		case 5: { //wood
			if(pickUp[playerid] == 0) {
				new ncStr[100];

				format(ncStr, sizeof(ncStr), "Hello, mister %s. I feel that you love the smell of a cutted tree.", sendName(playerid));

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -548.390197, -192.489013, 79.001869);
				SetPlayerCameraLookAt(playerid, -548.445739, -197.488037, 79.083633, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 5);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 5);
			}
			else if(pickUp[playerid] == 1) {
				PlayerTextDrawSetString(playerid, playerDiag, "Now you have a chainsaw. Take a look and get a nice tree."); 
				PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -525.470153, -55.809741, 79.931030);
				SetPlayerCameraLookAt(playerid, -528.339172, -51.912536, 78.673835, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 5);
			}else if(pickUp[playerid] == 4) {
				cTree[playerid] = CreateVehicle(578, -508.5078, -81.7491, 63.3971, 0.0000, -1, -1, 100);

				PlayerTextDrawSetString(playerid, playerDiag, "You are doing good. The last thing I want from you is to transport the logs."); 
				PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -526.700988, -65.191070, 71.610282);
				SetPlayerCameraLookAt(playerid, -523.142822, -68.212631, 69.818725, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 5);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 5);
			}
		}
		case 6: { // air
			if(pickUp[playerid] == 0) {
				new ncStr[100];

				format(ncStr, sizeof(ncStr), "Hello, mister %s. Welcome to SC Extreme Air Transport SA.", sendName(playerid));

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -2186.702392, 2411.228759, 5.611249);
				SetPlayerCameraLookAt(playerid, -2183.216064, 2414.812744, 5.603696, CAMERA_CUT);

				cTree[playerid] = CreateVehicle(417,-2227.2844,2326.1956,7.5710,181.9411,175,220, 0, 0);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 6);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 6);
			}
			if(pickUp[playerid] == 3) {
				new ncStr[100], rand = randomEx(1, 7);

				format(ncStr, sizeof(ncStr), "This is your landing zone. You have %d/7 packages left.", packages[playerid]);

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				switch(rand) {
					case 1:
						xyz[playerid][0] = 2271.6050,
						xyz[playerid][1] = 1080.7261,
						xyz[playerid][2] = 29.3790,
						SetPlayerCameraPos(playerid, 2311.855468, 1074.345703, 49.842403),
						SetPlayerCameraLookAt(playerid, 2307.511230, 1075.105590, 47.486438, CAMERA_CUT);
					case 2:
						xyz[playerid][0] = 1278.9458,
						xyz[playerid][1] = 1274.1520,
						xyz[playerid][2] = 10.8203,
						SetPlayerCameraPos(playerid, 1319.327514, 1259.707641, 24.663829),
						SetPlayerCameraLookAt(playerid, 1315.178466, 1261.745239, 22.757749, CAMERA_CUT);
					case 3:
						xyz[playerid][0] = 365.3443,
						xyz[playerid][1] = 2537.4907,
						xyz[playerid][2] = 16.6648,
						SetPlayerCameraPos(playerid, 383.893493, 2522.859863, 25.494041),
						SetPlayerCameraLookAt(playerid, 380.044708, 2525.504150, 23.706535, CAMERA_CUT);
					case 4:
						xyz[playerid][0] = 1629.8431,
						xyz[playerid][1] = -2451.2339,
						xyz[playerid][2] = 13.5547,
						SetPlayerCameraPos(playerid, 1598.260131, -2479.283447, 14.607414),
						SetPlayerCameraLookAt(playerid, 1601.105834, -2475.263183, 15.467608, CAMERA_CUT);
					case 5:
						xyz[playerid][0] = -1188.5513,
						xyz[playerid][1] = 23.7029,
						xyz[playerid][2] = 35.4429,
						SetPlayerCameraPos(playerid, -1147.056518, 25.920558, 21.349851),
						SetPlayerCameraLookAt(playerid, -1152.014160, 25.804819, 20.710380, CAMERA_CUT);
					case 6:
						xyz[playerid][0] = -2593.3904,
						xyz[playerid][1] = 634.8461,
						xyz[playerid][2] = 48.0427,
						SetPlayerCameraPos(playerid, -2569.371826, 611.515502, 31.536722),
						SetPlayerCameraLookAt(playerid, -2572.855224, 615.072631, 31.074800, CAMERA_CUT);
					case 7:
						xyz[playerid][0] = 1542.5219,
						xyz[playerid][1] = -1355.3759,
						xyz[playerid][2] = 350.7141,
						SetPlayerCameraPos(playerid, 1509.888061, -1305.550659, 348.691528),
						SetPlayerCameraLookAt(playerid, 1512.560668, -1309.554443, 347.339965, CAMERA_CUT);
				}
			}
		}
		case 7: { //fish
			if(pickUp[playerid] == 0) {
				new ncStr[100];

				format(ncStr, sizeof(ncStr), "Water, the mighty water who hides real fish treasures. What brings you here, %s?", sendName(playerid));

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -417.060241, -1761.305175, 6.687301);
				SetPlayerCameraLookAt(playerid, -420.493377, -1757.671386, 6.781826, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 7);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 7);
			}
			else {

				PlayerTextDrawSetString(playerid, playerDiag, "You are doing good but it's not enough. To get paid, you need to sell these fish.");
				PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -417.060241, -1761.305175, 6.687301);
				SetPlayerCameraLookAt(playerid, -420.493377, -1757.671386, 6.781826, CAMERA_CUT);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 7);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 7);
			}
		}
		case 8: { // hunter
			if(pickUp[playerid] == 0) {
				new ncStr[100];

				format(ncStr, sizeof(ncStr), "Hunting, dear hunting. How can people hate you? Oah, hello %s.", sendName(playerid));

				PlayerTextDrawSetString(playerid, playerDiag, ncStr); PlayerTextDrawShow(playerid, playerDiag);
				TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -2408.400390, -2190.002441, 34.651187);
				SetPlayerCameraLookAt(playerid, -2413.389404, -2189.800537, 34.915813, CAMERA_CUT);

				cTree[playerid] = CreateVehicle(554, -2398.9197,-2206.2292,33.2891, 289.4673, 1, 1, 0, 0);

				SetTimerEx("updateTD", 4000, false, "dd", playerid, 8);
				SetTimerEx("changeCamera", 8000, false, "dd", playerid, 8);
			}
			else if(pickUp[playerid] == 1) {

				PlayerTextDrawSetString(playerid, playerDiag, "In this area are a lot of deers. Be sure to keep at least 25m distance from it."); 
				PlayerTextDrawShow(playerid, playerDiag); TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

				SetPlayerCameraPos(playerid, -1712.304687, -2098.639160, 74.027038);
				SetPlayerCameraLookAt(playerid, -1707.816650, -2100.814697, 73.675239, CAMERA_CUT);

				pickUp[playerid] = 2;

				packages[playerid] = CreateDynamicObject(19315, -1492.558959, -2143.818115, 2.183411, 0.000000, 0.399999, 108.899955, -1, -1, -1, 300.00, 300.00);

				SetTimerEx("changeCamera", 6500, false, "dd", playerid, 8);
			}
		}
	}
	
	return SetTimerEx("startWork", 13000, false, "dd", playerid, jobId);
}

public changeCamera(playerid, jobid) {
	switch(jobid) {
		case 4: {
			SetPlayerCameraPos(playerid, -1064.856079, -1117.114135, 135.982635);
			SetPlayerCameraLookAt(playerid, -1068.555908, -1113.840332, 135.212539, CAMERA_CUT);
			PlayerTextDrawSetString(playerid, playerDiag, "There is the field. Make sure you will get the best weed.");
		}
		case 5: {
			SetPlayerCameraPos(playerid, -451.513122, -70.954238, 64.187133);
			SetPlayerCameraLookAt(playerid,  -447.269042, -68.906646, 62.515281, CAMERA_CUT);
			PlayerTextDrawSetString(playerid, playerDiag, "Firstly, you need to get the chainsaw from the cabin.");
			if(pickUp[playerid] == 4) {
				SetPlayerCameraPos(playerid, -2001.056274, -2353.244628, 43.190204);
				SetPlayerCameraLookAt(playerid, -2000.245727, -2357.824462, 41.355121, CAMERA_CUT);
				PlayerTextDrawSetString(playerid, playerDiag, "This is the delivery point. It's marked with red on your minimap.");
			}
		}
		case 6: {
			SetPlayerCameraPos(playerid, -2258.893310, 2305.367675, 15.447655);
			SetPlayerCameraLookAt(playerid, -2254.692626, 2307.864501, 14.389058, CAMERA_CUT);
			PlayerTextDrawSetString(playerid, playerDiag, "This is your helicopter. Enter it and we'll give you further information.");
		}
		case 7: {
			SetPlayerCameraPos(playerid, -837.246704, -1920.897827, 42.737274);
			SetPlayerCameraLookAt(playerid, -832.597717, -1921.747924, 41.105045, CAMERA_CUT);
			PlayerTextDrawSetString(playerid, playerDiag, "Here's the damned lake. I hope you know the art of hand fishing. Good luck!");
			if(pickUp[playerid] == 1) {
				SetPlayerCameraPos(playerid, 1364.027099, -1732.271972, 28.132932);
				SetPlayerCameraLookAt(playerid, 1361.984130, -1736.186767, 25.787675, CAMERA_CUT);
				PlayerTextDrawSetString(playerid, playerDiag, "Here is the market. Sell the fish and get paid.");
			}
		}
		case 8: {
			SetPlayerCameraPos(playerid, -2403.767333, -2229.232421, 36.618934);
			SetPlayerCameraLookAt(playerid, -2401.733642, -2224.733642, 35.827907, CAMERA_CUT);
			PlayerTextDrawSetString(playerid, playerDiag, "Here is my car. Use it to get the rifle I forget in my boar hunting cabin.");
			if(pickUp[playerid] == 2) {

				SetPlayerCameraPos(playerid, -1508.427978, -2149.276611, 3.947346);
				SetPlayerCameraLookAt(playerid, -1504.111938, -2146.872558, 3.177245, CAMERA_CUT);
				PlayerTextDrawSetString(playerid, playerDiag, "This is how a deer looks like. Good luck teen hunter!");

			}
		}
	}
}

sendName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, 24);
	return name;
}

public startWork(playerid, jobid) {

	SetCameraBehindPlayer(playerid);
	if(!IsPlayerInAnyVehicle(playerid)) ClearAnimations(playerid);
	TogglePlayerControllable(playerid, 1);
	inJob[playerid] = jobid;
	TextDrawHideForPlayer(playerid, BOX1); TextDrawHideForPlayer(playerid, BOX2);
	PlayerTextDrawHide(playerid, playerDiag);
	switch(jobid) {
		case 0: {
			GetPlayerPos(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2]);
			xyz[playerid][3] = 500;

			Farm = CreatePlayerTextDraw(playerid, 584.802490, 319.717773, "You have to harvest for:~n~500 meters."); PlayerTextDrawLetterSize(playerid, Farm, 0.230500, 1.868331);
			PlayerTextDrawTextSize(playerid, Farm, 0.000000, 136.000000);	PlayerTextDrawAlignment(playerid, Farm, 2);
			PlayerTextDrawColor(playerid, Farm, 798359807);					PlayerTextDrawUseBox(playerid, Farm, 1);
			PlayerTextDrawBoxColor(playerid, Farm, 75);						PlayerTextDrawSetShadow(playerid, Farm, 5);
			PlayerTextDrawSetOutline(playerid, Farm, 1);					PlayerTextDrawBackgroundColor(playerid, Farm, 122);
			PlayerTextDrawFont(playerid, Farm, 2);							PlayerTextDrawSetProportional(playerid, Farm, 1);
			PlayerTextDrawSetShadow(playerid, Farm, 5);						PlayerTextDrawSetSelectable(playerid, Farm, true);

			TextDrawShowForPlayer(playerid, Char);							TextDrawShowForPlayer(playerid, Combina);
			PlayerTextDrawShow(playerid, Farm);
		}
		case 1, 2, 3, 4: {
			//Modifici matale aici la checkpoints, pentru joburile 2 si 3 faci sa dea la case, pt 1 la proprietati
			//ew number = random(1011);

			//SetPlayerCheckpoint(playerid, playerProp[number][posX], playerProp[number][posY], playerProp[number][posZ], 1.5);

			if(jobid == 1) { //Trucker == Aici pui coords la proprietati random
				TextDrawShowForPlayer(playerid, GPS2), TextDrawShowForPlayer(playerid, GPS3), TextDrawShowForPlayer(playerid, GPS4);

				new trailer, tId = random(3), tID, Float: trailerX, Float: trailerY, Float: trailerZ, Float: trailerA;

				GetPlayerPos(playerid, trailerX, trailerY, trailerZ); GetVehicleZAngle(GetPlayerVehicleID(playerid), trailerA);

				switch(tId) {
					case 0: tID = 435;
					case 1: tID = 450;
					case 2: tID = 584;
					case 3: tID = 591;
				}

				trailer = CreateVehicle(tID, trailerX + 6, trailerY, trailerZ, trailerA, -1, -1, 100);

				SetTimerEx("attachTrailer", 1000, 0, "ii", playerid, trailer);
			}
			//Case la amandoua, coords la case random
			else if(jobid == 2) TextDrawShowForPlayer(playerid, PIZZA2), TextDrawShowForPlayer(playerid, PIZZA3), TextDrawShowForPlayer(playerid, PIZZA4), TextDrawShowForPlayer(playerid, PIZZA5), TextDrawShowForPlayer(playerid, PIZZA1);
			else if(jobid == 3) TextDrawShowForPlayer(playerid, CUR2), TextDrawShowForPlayer(playerid, CUR3), TextDrawShowForPlayer(playerid, CUR4), TextDrawShowForPlayer(playerid, CUR5), TextDrawShowForPlayer(playerid, CUR1), TextDrawShowForPlayer(playerid, CUR6);
			else if(jobid == 4) {
				if(pickUp[playerid] == 0)
					SendClientMessage(playerid, 0x339966AA, "{339966}(Drugs Job): {FFFFFF}Go and collect some quality weed.");
				else if(pickUp[playerid] == 2)
					SendClientMessage(playerid, 0x339966AA, "{339966}(Drugs Job): {FFFFFF}Find any vehicle and go to the 'Fabric'."),
					SetPlayerCheckpoint(playerid, -1410.2872,-1470.7137,101.5854, 2);
				else if(pickUp[playerid] == -1)
					SetPlayerCheckpoint(playerid, -1425.6824,-1527.3225,101.7478, 2),
					SendClientMessage(playerid, 0x339966AA, "{339966}(Drugs Job): {FFFFFF}Find madame RuNiX and talk with her about your business.");
			}
			if(jobid != 4) xyz[playerid][0] = 0, xyz[playerid][1] = 0, xyz[playerid][2] = 3;
			if(pickUp[playerid] == 4 || inJob[playerid] != 4) {
				SetPlayerCheckpoint(playerid,xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 3.0);

				PlayerTextDrawShow(playerid, GPS5);
				TextDrawShowForPlayer(playerid, GPS1);

				new tdString[44];

				format(tdString, 44, "~n~You have to drive for:~n~%0.2f kilometers.", GetPlayerDistanceFromPoint(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2])/1000);
				PlayerTextDrawSetString(playerid, GPS5, tdString);
			}
		}
		case 5: {
			if(pickUp[playerid] == 0)
				SendClientMessage(playerid, 0x339966AA, "{339966}(Woodcutter): {FFFFFF}Go and get the chainsaw."),
				SetPlayerMapIcon(playerid, 5, -435.6984,-63.5863,58.8750, 16, 1, MAPICON_LOCAL),
				pickUp[playerid] = CreateDynamicPickup(341, 19, -435.4926,-63.6325,58.8750, -1, -1, playerid, 50, -1,  0);
			else if(pickUp[playerid] == 1) {
				new ncStr[75];
				format(ncStr, 75, "{339966}(Woodcutter): {FFFFFF}Cut 3 trees(Cutted: %d/3).", cTree[playerid]);
				if(cTree[playerid] == 0) SendClientMessage(playerid, 0x339966AA, "{339966}(Woodcutter): {FFFFFF}Cut 3 trees.");
				else SendClientMessage(playerid, 0x339966AA, ncStr);
			}else if(pickUp[playerid] == 3) {
				SendClientMessage(playerid, 0x339966AA, "{339966}(Woodcutter): {FFFFFF}Take the log and put it on stack.");
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject(playerid, 9, 19793, 5, 0.103999, 0.203999, 0.118999, -0.599990, -66.499992, -5.699998, 4.210000, 2.894000, 2.747000);
				SetPlayerCheckpoint(playerid, -452.6131,-46.5802,59.7873, 2.0);
				createCuttedTree(getTreeId(playerid));	
			}else if(pickUp[playerid] == 4) {
				PutPlayerInVehicle(playerid, cTree[playerid], 0);
				SetPlayerAttachedObject(playerid, 9, 13369, 7, -5.975979, 1.717005, 0.072999, -84.700096, 16.999990, 173.700134, 0.327999, 0.143999, 0.198000);

				xyz[playerid][0] = -1991.3411; xyz[playerid][1] = -2387.4167; xyz[playerid][2] = 30.6250;
				SetPlayerCheckpoint(playerid, -1991.3411, -2387.4167, 30.6250, 4.0);

				SendClientMessage(playerid, 0x339966AA, "{339966}(Woodcutter): {FFFFFF}Drive to the delivery point, else you will not get paid.");

				PlayerTextDrawShow(playerid, GPS5);
				TextDrawShowForPlayer(playerid, GPS1);

				new tdString[44];

				format(tdString, 44, "~n~You have to drive for:~n~%0.2f kilometers.", GetPlayerDistanceFromPoint(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2])/1000);
				PlayerTextDrawSetString(playerid, GPS5, tdString);

				pickUp[playerid] = 5;
			}
		}
		case 6: {

			if(pickUp[playerid] == 0) {
			
				SetPlayerMapIcon(playerid, 8, -2227.2844,2326.1956,7.5710, 5, 1, MAPICON_LOCAL);

				SendClientMessage(playerid, 0x339966AA, "{339966}(Air Transporter): {FFFFFF}Get in the helicopter to get further information.");

				xyz[playerid][3] = 0;
				packages[playerid] = 0;
			}else if(pickUp[playerid] == 1) {

				SetPlayerCheckpoint(playerid, -1472.6537,1489.9269,8.2578, 4.0);

				SendClientMessage(playerid, 0x339966AA, "{339966}(Air Transporter): {FFFFFF}Fly to the loading zone to load your packages.");
			}else if(pickUp[playerid] == 3) {
				SetPlayerCheckpoint(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 4.0);

				new ncStr[100];
				format(ncStr, 100, "{339966}(Air Transporter): {FFFFFF}Deliver the package. Left packages to be delivered: %d", packages[playerid]);

				SendClientMessage(playerid, 0x339966AA, ncStr);

				SetVehicleParamsEx(cTree[playerid], 1, 0, 0, 0, 0, 0, 0);

				new tdString[44];

				format(tdString, 44, "~n~You have to drive for:~n~%0.2f kilometers.", GetPlayerDistanceFromPoint(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2])/1000);
				PlayerTextDrawSetString(playerid, GPS5, tdString);


				PlayerTextDrawShow(playerid, GPS5);
				TextDrawShowForPlayer(playerid, GPS1);
			}
		}
		case 7: {

			if(pickUp[playerid] == 0) {

				SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}John Fish gave you his backpack. It fits 15 fish, go to the lake and place it somewhere convenient.");

				SetPlayerAttachedObject(playerid, 9, 371, 1, 0.048000, -0.087999, 0.000000, 0.000000, 87.800018, -3.699998, 1.000000, 1.000000, 1.081999);
			}
			else {

				SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}You heard him. Use your car and reach the market.");

				SetPlayerCheckpoint(playerid, 1344.6250,-1753.1008,13.3586, 2.0);
			}
		}
		case 8: {

			if(pickUp[playerid] == 0)
				SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Get in the car. You will see a photo with the cabin.");

			else if(pickUp[playerid] == 1) {
				if(packages[playerid] == 0) 
					pickUp[playerid] = CreateDynamicPickup(357, 19,-2816.1499,-1519.4093,140.8438, -1,  -1, playerid, STREAMER_PICKUP_SD, -1, 0),
					SetPlayerMapIcon(playerid, 38,-2816.1499,-1519.4093,140.8438, 38, 1, MAPICON_GLOBAL),
					SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Find the cabin and get the rifle. It is marked on your radar with a 'S'.");
				else
					pickUp[playerid] = CreateDynamicPickup(19832, 19,-1631.3982,-2245.0549,31.4766, -1,  -1, playerid, STREAMER_PICKUP_SD, -1, 0),
					RemovePlayerMapIcon(playerid, 38),
					SetPlayerMapIcon(playerid, 38,-1631.3982,-2245.0549,31.4766, 38, 1, MAPICON_GLOBAL), packages[playerid] = 1,
					SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Find the cabin and get the scope. It is marked on your radar with a 'S'.");
			}

			else if(pickUp[playerid] == 2) {

				DestroyDynamicObject(packages[playerid]);

				SendClientMessage(playerid, 0x339966AA, "(Hunter): {FFFFFF}Kill five deers.");
				SetTimerEx("spawnDeer", 2000, false, "d", playerid);

			}
	
		}
	}

	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {

	if(vehicleid == cTree[playerid] && inJob[playerid] == 6) {

		PlayerTextDrawSetString(playerid, playerDiag, "Here is the loading point. Get there and get your packages.");
		PlayerTextDrawShow(playerid, playerDiag); TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

		SetPlayerCameraPos(playerid, -1495.158935, 1471.437500, 19.992513);
		SetPlayerCameraLookAt(playerid, -1491.299194, 1474.021362, 18.141540, CAMERA_CUT);

		pickUp[playerid] = 1;

		SetTimerEx("startWork", 5000, false, "dd", playerid, 6);

	}
	if(vehicleid == cTree[playerid] && inJob[playerid] == 8 && xyz[playerid][3] == 0) {

		PlayerTextDrawSetString(playerid, playerDiag, "There is the cabin. Get there and take the rifle.");
		PlayerTextDrawShow(playerid, playerDiag); TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

		if(packages[playerid] == 0)
			SetPlayerCameraPos(playerid, -2786.352783, -1505.122680, 141.800674),
			SetPlayerCameraLookAt(playerid, -2790.736083, -1507.520507, 141.606094, CAMERA_CUT);
		else 
			SetPlayerCameraPos(playerid, -1651.411376, -2221.998046, 35.760509),
			SetPlayerCameraLookAt(playerid, -1648.122802, -2225.587158, 34.619007, CAMERA_CUT),
			PlayerTextDrawSetString(playerid, playerDiag, "There is the second cabin. Get there and take the scope and some bullets.");

		pickUp[playerid] = 1;

		SetTimerEx("startWork", 5000, false, "dd", playerid, 8);		
	}

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {

	if(inJob[playerid] > -1 && inJob[playerid] != 8) {
		inJob[playerid] = -1;
		eraseVeh(GetPlayerVehicleID(playerid));
		GameTextForPlayer(playerid, "~r~~h~Job Failed", 4000, 4);
		TextDrawHideForPlayer(playerid, Char);							TextDrawHideForPlayer(playerid, Combina);
		PlayerTextDrawHide(playerid, Farm);								PlayerTextDrawHide(playerid, GPS5);
		TextDrawHideForPlayer(playerid, GPS1);
		TextDrawHideForPlayer(playerid, GPS2), TextDrawHideForPlayer(playerid, GPS3), TextDrawHideForPlayer(playerid, GPS4);
		TextDrawHideForPlayer(playerid, PIZZA2), TextDrawHideForPlayer(playerid, PIZZA3), TextDrawHideForPlayer(playerid, PIZZA4), TextDrawHideForPlayer(playerid, PIZZA5), TextDrawHideForPlayer(playerid, PIZZA1);
		TextDrawHideForPlayer(playerid, CUR2), TextDrawHideForPlayer(playerid, CUR3), TextDrawHideForPlayer(playerid, CUR4), TextDrawHideForPlayer(playerid, CUR5), TextDrawHideForPlayer(playerid, CUR1), TextDrawHideForPlayer(playerid, CUR6);
		DisablePlayerCheckpoint(playerid);	eraseVeh(cTree[playerid]);
		pickUp[playerid] = 0; xyz[playerid][3] = 0; cTree[playerid] = 0; packages[playerid] = 0;
	}
	return 1;
}
public OnPlayerEnterCheckpoint(playerid) {
	if(IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)) && inJob[playerid] == 1) { //Aici pui tu ce castiga
		GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);
		PlayerTextDrawHide(playerid, GPS5);		TextDrawHideForPlayer(playerid, GPS1);
		TextDrawHideForPlayer(playerid, GPS2), TextDrawHideForPlayer(playerid, GPS3), TextDrawHideForPlayer(playerid, GPS4);
		eraseVeh(GetVehicleTrailer(GetPlayerVehicleID(playerid)));
		inJob[playerid] = -1; pickUp[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
		Iter_Remove(Jobing, playerid);
	}
	else if(inJob[playerid] > 1 && inJob[playerid] < 4 || (inJob[playerid] == 4 && pickUp[playerid] == 4)) {  //Aici pui tu ce castiga
		TextDrawHideForPlayer(playerid, PIZZA2), TextDrawHideForPlayer(playerid, PIZZA3), TextDrawHideForPlayer(playerid, PIZZA4), TextDrawHideForPlayer(playerid, PIZZA5), TextDrawHideForPlayer(playerid, PIZZA1);
		TextDrawHideForPlayer(playerid, CUR2), TextDrawHideForPlayer(playerid, CUR3), TextDrawHideForPlayer(playerid, CUR4), TextDrawHideForPlayer(playerid, CUR5), TextDrawHideForPlayer(playerid, CUR1), TextDrawHideForPlayer(playerid, CUR6);
		GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);
		PlayerTextDrawHide(playerid, GPS5);		TextDrawHideForPlayer(playerid, GPS1);
		eraseVeh(GetPlayerVehicleID(playerid));
		inJob[playerid] = -1; pickUp[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
		Iter_Remove(Jobing, playerid);
	}
	else if(inJob[playerid] == 4 && pickUp[playerid] == 2) {
		SetPlayerCameraPos(playerid, -1423.545654, -1520.740478, 102.929832);
		SetPlayerCameraLookAt(playerid, -1424.533203, -1525.611938, 102.387413, CAMERA_CUT);
		PlayerTextDrawSetString(playerid, playerDiag, "Here is Miss RuNiX, she and her faggots will produce the drugs.");
		PlayerTextDrawShow(playerid, playerDiag);
		TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);
		pickUp[playerid] = -1;
		SetTimerEx("startWork", 6000, false, "dd", playerid, 4);
	}else if(inJob[playerid] == 4 && pickUp[playerid] == -1) {
		SetPlayerCameraPos(playerid, -1453.103515, -1604.367187, 104.684745);
		SetPlayerCameraLookAt(playerid, -1450.874511, -1608.798095, 104.053619, CAMERA_CUT);
		PlayerTextDrawSetString(playerid, playerDiag, "Wait until the drugs are done.....~n~That's a nice view to see...");
		PlayerTextDrawShow(playerid, playerDiag);
		TextDrawShowForPlayer(playerid, BOX1); TextDrawShowForPlayer(playerid, BOX2);

		SetPlayerProgressBarMaxValue(playerid, Drugs, 5);
		SetPlayerProgressBarValue(playerid, Drugs, 0);
		ShowPlayerProgressBar(playerid, Drugs);

		pickUp[playerid] = 3;

		xyz[playerid][3] = 0;

		DCollect = CreatePlayerTextDraw(playerid, 636.500122, 352.333648, "Manufacturing Drugs..(0%)");
		PlayerTextDrawLetterSize(playerid, DCollect, 0.151500, 1.384166);
		PlayerTextDrawAlignment(playerid, DCollect, 3);
		PlayerTextDrawColor(playerid, DCollect, -1);
		PlayerTextDrawSetShadow(playerid, DCollect, 1);
		PlayerTextDrawSetOutline(playerid, DCollect, 1);
		PlayerTextDrawBackgroundColor(playerid, DCollect, 255);
		PlayerTextDrawFont(playerid, DCollect, 2);
		PlayerTextDrawSetProportional(playerid, DCollect, 1);
		PlayerTextDrawSetShadow(playerid, DCollect, 1);

		PlayerTextDrawShow(playerid, DCollect);

	}
	else if(inJob[playerid] == 5 && pickUp[playerid] == 3) {

		xyz[playerid][3] = 0;

		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(playerid, 9);

		DisablePlayerCheckpoint(playerid);

		if(++cTree[playerid] == 3)
			pickUp[playerid] = 4,
			SetTimerEx("startJobEx", 1000, false, "dd", playerid, 5);
		else 
			pickUp[playerid] = 1,
			startWork(playerid, 5);
	}else if(inJob[playerid] == 5 && pickUp[playerid] == 5) { //Aici pui tu ce castiga
		DisablePlayerCheckpoint(playerid);
		RemovePlayerAttachedObject(playerid, 9);

		GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);

		PlayerTextDrawHide(playerid, GPS5);		TextDrawHideForPlayer(playerid, GPS1);

		eraseVeh(cTree[playerid]);
		Iter_Remove(Jobing, playerid);

		inJob[playerid] = -1; pickUp[playerid] = 0;
	}
	else if(inJob[playerid] == 6 && pickUp[playerid] == 1) {
		
		pickUp[playerid] = 2;

		GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~w~Loading packages...", 14000, 3);

		SetVehiclePos(cTree[playerid], -1469.3060,1491.0345,8.2578);
		SetVehicleZAngle(cTree[playerid], 270.5156);
		SetVehicleParamsEx(cTree[playerid], 0, 0, 0, 0, 0, 0, 0);

		DisablePlayerCheckpoint(playerid);

	}else if(inJob[playerid] == 6 && pickUp[playerid] == 3)  //Ai de ales aici. Ori castiga per package ori castiga dupa ce le livreaza pe toate.
		if(packages[playerid]-- > 0) {

			new ncStr[100];

			format(ncStr, 100, "{339966}(Air Transporter): {FFFFFF}Package delivered. Left package to be delivered: %d", packages[playerid]);
			SendClientMessage(playerid, 0x339966AA, ncStr);

			SetTimerEx("startJobEx", 3000, false, "dd", playerid, 6);

		}
		else {
			DisablePlayerCheckpoint(playerid);

			GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);

			PlayerTextDrawHide(playerid, GPS5);		TextDrawHideForPlayer(playerid, GPS1);

			eraseVeh(cTree[playerid]);

			inJob[playerid] = -1; pickUp[playerid] = packages[playerid] = 0; xyz[playerid][3] = 0;
			Iter_Remove(Jobing, playerid);
		}
	else if(inJob[playerid] == 7) {

		GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~w~Fishing...", 15000, 3);
		DisablePlayerCheckpoint(playerid);

		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("handFishing", 15000, false, "d", playerid);

	}else if(inJob[playerid] == 7 && IsPlayerAttachedObjectSlotUsed(playerid, 9)) {
		pickUp[playerid] = 1;
		SetTimerEx("startJobEx", 2000, false, "dd", playerid, 7);
	}else if(inJob[playerid] == 7 && pickUp[playerid] == 1) { //Aici pui tu ce castiga

			DisablePlayerCheckpoint(playerid);

			GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);

			inJob[playerid] = -1; pickUp[playerid] = packages[playerid] = 0; xyz[playerid][3] = 0;
			Iter_Remove(Jobing, playerid);
	}
	else if(inJob[playerid] == 8 && pickUp[playerid] != 0) {

		GetVehiclePos(cTree[playerid], xyz[playerid][0], xyz[playerid][1], xyz[playerid][2]);
		RemovePlayerMapIcon(playerid, 38);
		SetPlayerMapIcon(playerid, 38, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 55, 1, MAPICON_LOCAL);

		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		SetPlayerAttachedObject(playerid, 9, 19315, 6, 0.190000, 0.000000, -0.184000, -30.800018, -67.899932, -13.199958);

		DestroyDynamicObject(packages[playerid]);
		DisablePlayerCheckpoint(playerid);


		SendClientMessage(playerid, 0x339966AA, "(Hunter): {FFFFFF}You picked up the deer. Put it in the car.");
		SendClientMessage(playerid, 0x339966AA, "(Hunter): {FFFFFF}Your car appears on your radar as a blue car.");

	}else if(inJob[playerid] == 8 && pickUp[playerid] == 0) { // Aici pui ce primeste

		eraseVeh(cTree[playerid]);

		for(new _zID = 0; _zID < 4; ++_zID)
			DestroyDynamicObject(attachedDeers[playerid][_zID]);

		GameTextForPlayer(playerid, "~r~~h~Job Done!", 4000, 4);

		RemovePlayerMapIcon(playerid, 38);
		DisablePlayerCheckpoint(playerid);

		inJob[playerid]    = -1;    pickUp[playerid] = 0;
		packages[playerid] =  0; 	xyz[playerid][3] = 0;
		deers[playerid]	   =  0;	

		Iter_Remove(Jobing, playerid);

	}
	return 1;
}


CMD:cuttree(playerid, params[]) {
	new treeID = getTreeId(playerid);

	if(inJob[playerid] != 5) 	return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You are not a woodcutter."	);
	if(treeID == 0) 			return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You are not near a tree."	);
	if(tree[treeID][cutted]) 	return SendClientMessage(playerid, 0xFF0000AA, "ERROR: The tree is already cutted." );

	TogglePlayerControllable(playerid, 0);

	GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~w~Cutting...", 10000, 3);

	pickUp[playerid] = 2;

	return 1;

}


public OnTrailerUpdate(playerid, vehicleid) {

	if(IsTrailerAttachedToVehicle(vehicleid) == 0 && inJob[playerid] == -1) eraseVeh(vehicleid);
	return 1;
}

eraseVeh(vID) {
    for(new l; l <= GetPlayerPoolSize(); ++l) {

        new Float:_x, Float:_y, Float:_z;

    	if(IsPlayerInVehicle(l, vID)) RemovePlayerFromVehicle(l), GetPlayerPos(l, _x, _y, _z), SetPlayerPos(l, _x, _y+3, _z);

	    SetVehicleParamsForPlayer(vID, l, 0,1);
	}
    DestroyVehicle(vID);
}

public farmTimer() {

	foreach(new i: Jobing) {
		if(inJob[i] == 0 && getVehicleSpeed(GetPlayerVehicleID(i)) > 10) {
			xyz[i][3] -= GetPlayerDistanceFromPoint(i, xyz[i][0], xyz[i][1], xyz[i][2]);
			if(xyz[i][3] > 0) {
				GetPlayerPos(i, xyz[i][0], xyz[i][1], xyz[i][2]);
				new ncStr[44]; format(ncStr, 44, "You have to harvest for:~n~%0.2f meters.", xyz[i][3]);
				PlayerTextDrawSetString(i, Farm, ncStr);
			}
			else {
				GivePlayerMoney(i, 500); //Aici pui tu ce primeste
				eraseVeh(GetPlayerVehicleID(i));
				TextDrawHideForPlayer(i, Char);							TextDrawHideForPlayer(i, Combina);
				PlayerTextDrawHide(i, Farm);							inJob[i] = -1;
				Iter_Remove(Jobing, i);
			}                                                          
		}
		else if((inJob[i] > 0 && inJob[i] < 4 || (inJob[i] == 4 && pickUp[i] == 4) || (inJob[i] == 5 && pickUp[i] == 5)
		|| (inJob[i] == 6 && pickUp[i] == 3)) && getVehicleSpeed(GetPlayerVehicleID(i)) > 1) {

			new ncStr[44]; format(ncStr, 44, "~n~You have to drive for:~n~%0.2f kilometers.", GetPlayerDistanceFromPoint(i, xyz[i][0], xyz[i][1], xyz[i][2])/1000);
			PlayerTextDrawSetString(i, GPS5, ncStr);
		}
		else if(inJob[i] == 4 && pickUp[i] == 1) {
			if(xyz[i][3]++ < 5) {
				SetPlayerProgressBarValue(i, Drugs, floatround(xyz[i][3], floatround_round));
				ShowPlayerProgressBar(i, Drugs);
				new ncStr[25]; format(ncStr, 25, "Collecting Drugs..(%d%%)", floatround(xyz[i][3], floatround_round) * 20);
				PlayerTextDrawSetString(i, DCollect, ncStr);
				ApplyAnimation(i, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0);
			}
			else pickUp[i] = 2, SetTimerEx("startJobEx", 1000, false, "dd", i, 4);
		}
		else if(inJob[i] == 4 && pickUp[i] == 3) {
			if(xyz[i][3]++ < 5) {
				SetPlayerProgressBarValue(i, Drugs, floatround(xyz[i][3], floatround_round));
				ShowPlayerProgressBar(i, Drugs);
				new ncStr[25]; format(ncStr, 25, "Manufacturing Drugs..(%d%%)", floatround(xyz[i][3], floatround_round) * 20);
				PlayerTextDrawSetString(i, DCollect, ncStr);
			}
			else pickUp[i] = 4, SetTimerEx("startJobEx", 1000, false, "dd", i, 4);
		}
		else if(inJob[i] == 5 && pickUp[i] == 2) {
			if(xyz[i][3]++ < 10) {
				new rand = random(2);
				switch(rand) {
					case 0: ApplyAnimation(i, "CHAINSAW", "CSAW_1", 4.0, 1, 0, 0, 0, 0);
					case 1: ApplyAnimation(i, "CHAINSAW", "CSAW_2", 4.0, 1, 0, 0, 0, 0);
					case 2: ApplyAnimation(i, "CHAINSAW", "CSAW_3", 4.0, 1, 0, 0, 0, 0);
				}
			}
			else 
				pickUp[i] = 3,
				startWork(i, 5);
		}
		else if(inJob[i] == 6 && pickUp[i] == 2)
			if(xyz[i][3]++ > 15) 
				pickUp[i] = 3,
				packages[i] = 7,
				SendClientMessage(i, 0x339966AA, "{339966}(Air Transporter): {FFFFFF}Seven packages have been loaded up."),
				SetTimerEx("startJobEx", 1000, false, "dd", i, 6);
			
	}
	return 1;
}
getVehicleSpeed(vehicleid) {
    if(vehicleid != INVALID_VEHICLE_ID) {
        new Float:Pos[3], Float:VS;
        GetVehicleVelocity(vehicleid, Pos[0], Pos[1], Pos[2]);
        VS = floatsqroot(Pos[0]*Pos[0] + Pos[1]*Pos[1] + Pos[2]*Pos[2])*187.666667;
        return floatround(VS,floatround_round);
	}
	return INVALID_VEHICLE_ID;
} 

public attachTrailer(playerid, trailerid) {
	new Float:pX, Float:pY, Float:pZ, Float:vX, Float:vY, Float:vZ;

	GetPlayerPos(playerid, pX, pY, pZ); GetVehiclePos(trailerid,vX,vY,vZ);

	if((floatabs(pX-vX)<100.0)&&(floatabs(pY-vY)<100.0)&&(floatabs(pZ-vZ)<100.0)) return AttachTrailerToVehicle(trailerid, GetPlayerVehicleID(playerid));

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{

	if(dialogid == 123) {
		if(!response) {
			inJob[playerid] = -1;
			eraseVeh(GetPlayerVehicleID(playerid));
			PlayerTextDrawHide(playerid, GPS5);
			TextDrawHideForPlayer(playerid, GPS1);
			TextDrawHideForPlayer(playerid, GPS2), TextDrawHideForPlayer(playerid, GPS3), TextDrawHideForPlayer(playerid, GPS4);
		}
		else startWork(playerid, 1);
	}
	else if(dialogid == 6996) {
		if(!response) return 0;
		else {
			switch(listitem) {
				case 0: SetPlayerPos(playerid, -2187.1829, 2410.6433, 4.9686  	 ); //Air Transporter
				case 1: SetPlayerPos(playerid, -2667.1404, -2.3663, 6.1328  	 ); //Courier
				case 2: SetPlayerPos(playerid, -1058.7367, -1205.3679, 129.2188	 ); //Drugs Dealer
				case 3: SetPlayerPos(playerid, -374.8170, -1418.1420, 25.7266	 ); //Farmer
				case 4: SetPlayerPos(playerid, -416.3486, -1761.9376, 5.6124 	 ); //Fisherman
				case 5: SetPlayerPos(playerid, -2406.6384, -2189.9441, 33.2891 	 ); //Hunter
				case 6: SetPlayerPos(playerid,  2106.5989, -1784.6007, 13.3872 	 ); //Pizza Delivery
				case 7: SetPlayerPos(playerid, -159.6252, -279.9867, 3.9053	 	 ); //Trucker
				case 8: SetPlayerPos(playerid, -548.1020, -191.4657, 78.4063	 ); //Woodcutter
			}
		}
	}
	return 0;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(inJob[playerid] == 5 && pickupid == pickUp[playerid]) {
		GivePlayerWeapon(playerid, 9, 1);
		DestroyDynamicPickup(pickUp[playerid]);
		RemovePlayerMapIcon(playerid, 5);
		pickUp[playerid] = 1;
		SetTimerEx("startJobEx", 1000, false, "dd", playerid, 5);
	}
	else if(inJob[playerid] == 8 && pickupid == pickUp[playerid]) {
		if(packages[playerid] == 0) {

			pickUp[playerid] = 0;
			packages[playerid] = 1;
			GivePlayerWeapon(playerid, 33, 1);
			SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}You've got the rifle. The hunter is calling you. Get in the car quickly!");
			RemovePlayerMapIcon(playerid, 38);

		}
		else {

			pickUp[playerid] = 1;
			packages[playerid] = 0;

			GivePlayerWeapon(playerid, 34, 40);
			SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}The rifle is loaded and the scope is on. Good luck from now.");
			SetTimerEx("startJobEx", 2000, false, "dd", playerid, 8);

			xyz[playerid][3] = 1;
		}
	}
	return 1;

}

public OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if(areaid == fishzone && inJob[playerid] == 7) {
		TextDrawShowForPlayer(playerid, fishTD1);	TextDrawShowForPlayer(playerid, fishTD3);	TextDrawShowForPlayer(playerid, fishTD5);
		TextDrawShowForPlayer(playerid, fishTD2);	TextDrawShowForPlayer(playerid, fishTD4);
	}
	if(areaid == deerZone[playerid] && inJob[playerid] == 8) {

		DestroyDynamicObject(packages[playerid]);
		SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Oh no! You we're too close and the deer saw you and runned.");
		SetTimerEx("spawnDeer", 3000, false, "d", playerid);
	}
}

public OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA areaid) {

	if(areaid == fishzone) {
		TextDrawHideForPlayer(playerid, fishTD1);	TextDrawHideForPlayer(playerid, fishTD3);	TextDrawHideForPlayer(playerid, fishTD5);
		TextDrawHideForPlayer(playerid, fishTD2);	TextDrawHideForPlayer(playerid, fishTD4);
	}
}

public OnPlayerShootDynamicObject(playerid, weaponid, objectid, Float:x, Float:y, Float:z)
{
	if(inJob[playerid] == 8 && weaponid == 34 && objectid == packages[playerid]) {

		SetTimerEx("killDeer", 3000, false, "dd", playerid, pickUp[playerid]);
		SetPlayerCheckpoint(playerid, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 2);
	}
	return 1;
}

getTreeId(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 7.5, -554.32813, -32.94190, 67.93728)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -571.12469, -0.99762, 67.93728)) return 2;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -563.56793, -21.34284, 67.93728)) return 3;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -575.30902, -11.60782, 67.93728)) return 4;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -556.61975, 2.44546, 67.93728)) return 5;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5,  -558.53296, -10.85517, 67.93728)) return 6;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -545.41095, -3.76465, 67.93728)) return 7;
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, -549.47058, -16.60959, 67.93728)) return 8;
	return 0;
}

createCuttedTree(treeid) {
	DestroyDynamicObject(tree[treeid][obj]);
	tree[treeid][cutted] = true;
	switch(treeid) {
		case 1:	tree[1][obj] = CreateDynamicObject(832, -554.32813, -32.94190, 63.43728,   0.00000, 0.00000, 0.00000);
		case 2:	tree[2][obj] = CreateDynamicObject(832, -571.12469, -0.99762, 63.4728,   0.00000, 0.00000, 0.00000);
		case 3:	tree[3][obj] = CreateDynamicObject(832, -563.56793, -21.34284, 63.43728,   0.00000, 0.00000, 0.00000);
		case 4:	tree[4][obj] = CreateDynamicObject(832, -575.30902, -11.60782, 63.43728,   0.00000, 0.00000, 0.00000);
		case 5:	tree[5][obj] = CreateDynamicObject(832, -556.61975, 2.44546, 63.43728,   0.00000, 0.00000, 0.00000);
		case 6:	tree[6][obj] = CreateDynamicObject(832, -558.53296, -10.85517, 63.43728,   0.00000, 0.00000, 0.00000);
		case 7:	tree[7][obj] = CreateDynamicObject(832, -545.41095, -3.76465, 63.43728,   0.00000, 0.00000, 0.00000);
		case 8:	tree[8][obj] = CreateDynamicObject(832, -549.47058, -16.60959, 63.43728,   0.00000, 0.00000, 0.00000);
	}
	UpdateDynamic3DTextLabelText(tree[treeid][tree3D], 0xFFFFFFAA, "{FF0000}Cutted Tree.\n{FFFFFF}You have to wait {00FF00}1 minute {FFFFFF}to cut it again.");
	return SetTimerEx("reviveTree", 4*15000, false, "d", treeid);
}

public reviveTree(treeid) {
	DestroyDynamicObject(tree[treeid][obj]);
	tree[treeid][cutted] = false;
	switch(treeid) {
		case 1:	tree[1][obj] = CreateDynamicObject(693, -554.32813, -32.94190, 67.93728,   0.00000, 0.00000, 0.00000);
		case 2:	tree[2][obj] = CreateDynamicObject(693, -571.12469, -0.99762, 67.93728,   0.00000, 0.00000, 0.00000);
		case 3:	tree[3][obj] = CreateDynamicObject(693, -563.56793, -21.34284, 67.93728,   0.00000, 0.00000, 0.00000);
		case 4:	tree[4][obj] = CreateDynamicObject(693, -575.30902, -11.60782, 67.93728,   0.00000, 0.00000, 0.00000);
		case 5:	tree[5][obj] = CreateDynamicObject(693, -556.61975, 2.44546, 67.93728,   0.00000, 0.00000, 0.00000);
		case 6:	tree[6][obj] = CreateDynamicObject(693, -558.53296, -10.85517, 67.93728,   0.00000, 0.00000, 0.00000);
		case 7:	tree[7][obj] = CreateDynamicObject(693, -545.41095, -3.76465, 67.93728,   0.00000, 0.00000, 0.00000);
		case 8:	tree[8][obj] = CreateDynamicObject(693, -549.47058, -16.60959, 67.93728,   0.00000, 0.00000, 0.00000);
	}
	new ncStr[100];
	format(ncStr, 100, "{FF0000}TREE ID: %d\n{FFFFFF}Use {00FF00}/cuttree{FFFFFF} to cut the tree.", treeid);
	return UpdateDynamic3DTextLabelText(tree[treeid][tree3D], 0xFFFFFFAA, ncStr);
}

public handFishing(playerid) {

	if(packages[playerid] == 15) return 1;

	new rand = randomEx(1, 100);
	TogglePlayerControllable(playerid, 1);
	if(rand <= 20) {
		pickUp[playerid] = 0;
		SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}Awe crap, you scared all of them. You didn't catch anything");
		SetTimerEx("getFishEx", 2000, false, "d", playerid);
	}
	else if(rand <= 60) {
		pickUp[playerid] = 1;
		SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}With some luck, you caught one fish.");
	}
	else if(rand <= 90) {
		pickUp[playerid] = 2;
		if(packages[playerid] + pickUp[playerid] > 15)
			return handFishing(playerid);
		SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}Nice fishing skills! You got two nice fish.");
	}
	else {
		pickUp[playerid] = 3;
		if(packages[playerid] + pickUp[playerid] > 15)
			return handFishing(playerid);
		SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}Legendary fishing! You caught as many fish as you can carry.");
	}
	return 1;
}
getFish(playerid) {
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, 0x339966AA, "{339966}(Fisherman): {FFFFFF}John Fish saw a good fish place. Go check it.");

	new fishcp = randomEx(1, 8);
	switch(fishcp) {
		case 1: SetPlayerCheckpoint(playerid, -695.2822,-1912.8324,4.9402, 2.0);
		case 2: SetPlayerCheckpoint(playerid, -716.1973,-1942.7616,4.6932, 2.0);
		case 3: SetPlayerCheckpoint(playerid, -810.1213,-1953.9418,4.7739, 2.0);
		case 4: SetPlayerCheckpoint(playerid, -652.8000,-1889.5713,5.0845, 2.0);
		case 5: SetPlayerCheckpoint(playerid, -632.5768,-1885.0773,5.1940, 2.0);
		case 6: SetPlayerCheckpoint(playerid, -590.2084,-1886.5566,5.0265, 2.0);
		case 7: SetPlayerCheckpoint(playerid, -543.5562,-1897.2457,4.7200, 2.0);
		case 8: SetPlayerCheckpoint(playerid, -466.4421,-1888.5702,4.7200, 2.0);
	}

	return 1;
}
public getFishEx(playerid) return getFish(playerid);
public startJobEx(playerid, __jobId) return startJob(playerid, __jobId);

public spawnDeer(playerid) {

	new rand = randomEx(1, 10);
	if(pickUp[playerid] == rand) rand = randomEx(1, 10);

	pickUp[playerid] = rand;

	switch(rand) {

		case 1: {
			packages[playerid] = CreateDynamicObject(19315, -1453.158447, -2191.359863, 10.868762, -4.600001, 17.799982, 115.399986, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1453.158447; xyz[playerid][1] = -2191.359863; xyz[playerid][2] = 10.868762;
		}
		case 2: {
			packages[playerid] = CreateDynamicObject(19315, -1355.193603, -2110.982177, 30.378963, 3.899998, 2.899999, -48.899997, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1355.193603; xyz[playerid][1] = -2110.982177; xyz[playerid][2] = 30.378963;
		}
		case 3: {
			packages[playerid] = CreateDynamicObject(19315, -1253.601318, -2167.967529, 30.667551, 0.000000, -6.800000, -141.800003, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1253.601318; xyz[playerid][1] = -2167.967529; xyz[playerid][2] = 30.667551;
		}
		case 4: {
			packages[playerid] = CreateDynamicObject(19315, -1334.538574, -2252.269287, 32.460483, 0.000000, 9.900001, 0.000000, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1334.538574; xyz[playerid][1] = -2252.269287; xyz[playerid][2] = 32.460483;
		}
		case 5: {
			packages[playerid] = CreateDynamicObject(19315, -1418.794555, -2407.343017, 29.809692, 0.000000, 16.800001, 90.100006, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1418.794555; xyz[playerid][1] = -2407.343017; xyz[playerid][2] = 29.809692;
		}
		case 6: {
			packages[playerid] = CreateDynamicObject(19315, -1336.248779, -2416.627685, 44.285144, 0.000000, 14.399999, 2.499999, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1336.248779; xyz[playerid][1] = -2416.627685; xyz[playerid][2] = 44.285144;
		}
		case 7: {
			packages[playerid] = CreateDynamicObject(19315, -1472.407470, -2498.945312, 56.468868, -4.799997, 13.099999, 51.099983, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1472.407470; xyz[playerid][1] = -2498.945312; xyz[playerid][2] = 56.468868;
		}
		case 8: {
			packages[playerid] = CreateDynamicObject(19315, -1381.315917, -2588.684570, 54.389060, -1.899999, 21.000003, 0.000000, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1381.315917; xyz[playerid][1] = -2588.684570; xyz[playerid][2] = 54.389060;
		}
		case 9: {
			packages[playerid] = CreateDynamicObject(19315, -1571.797729, -2070.796386, 46.286926, 13.799998, 3.400002, 0.000000, -1, -1, -1, 300.00, 300.00); 
			xyz[playerid][0] = -1571.797729; xyz[playerid][1] = -2070.796386; xyz[playerid][2] = 46.286926;
		}
		case 10: {
			packages[playerid] = CreateDynamicObject(19315, -1394.707153, -1911.376708, 25.810544, 12.200004, -6.800000, 0.000000, -1, -1, -1, 300.00, 300.00);
			xyz[playerid][0] = -1394.707153; xyz[playerid][1] = -1911.376708; xyz[playerid][2] = 25.810544;
		}

	}
  
	RemovePlayerMapIcon(playerid, 38);
	SetPlayerMapIcon(playerid, 38, xyz[playerid][0], xyz[playerid][1], xyz[playerid][2], 12, 1, MAPICON_GLOBAL);
	deerZone[playerid] = CreateDynamicCircle(xyz[playerid][0], xyz[playerid][1], 25);

	SendClientMessage(playerid, 0x339966AA, " ");
	SendClientMessage(playerid, 0x339966AA, " ");
	SendClientMessage(playerid, 0x339966AA, "(Hunter): {FFFFFF}A deer has just showed up. Go and kill it.");

	return 1;
}

public killDeer(playerid, deerid) {

	DestroyDynamicArea(deerZone[playerid]);
	DestroyDynamicObject(packages[playerid]);

	switch(deerid) {

		case 1: {
			packages[playerid] = CreateDynamicObject(19315, -1453.080810, -2191.283691, 10.575698, -106.899955, 17.799982, 115.399986, -1, -1, -1, 300.00, 300.00);
		}
		case 2: {
			packages[playerid] = CreateDynamicObject(19315, -1355.232543, -2111.015380, 29.954225, -88.800148, 2.899999, -49.899982, -1, -1, -1, 300.00, 300.00); 
		}
		case 3: {
			packages[playerid] = CreateDynamicObject(19315, -1253.607910, -2167.958007, 30.247701, 85.199958, -17.099990, -121.399971, -1, -1, -1, 300.00, 300.00);
		}
		case 4: {
			packages[playerid] = CreateDynamicObject(19315, -1334.538574, -2252.375488, 32.212314, 72.299942, 9.900001, 0.000000, -1, -1, -1, 300.00, 300.00);
		}
		case 5: {
			packages[playerid] = CreateDynamicObject(19315, -1418.838500, -2407.313964, 29.724624, -152.700057, 16.800001, 90.100006, -1, -1, -1, 300.00, 300.00);
		}
		case 6: {
			packages[playerid] = CreateDynamicObject(19315, -1336.444091, -2416.560791, 43.929405, -86.099983, 14.399999, 2.499999, -1, -1, -1, 300.00, 300.00);
		}
		case 7: {
			packages[playerid] = CreateDynamicObject(19315, -1472.392333, -2498.956787, 56.279842, -95.799949, 11.999994, 52.999988, -1, -1, -1, 300.00, 300.00);
		}
		case 8: {
			packages[playerid] = CreateDynamicObject(19315, -1381.379150, -2588.561523, 54.056468, -67.500038, 19.699987, 32.500000, -1, -1, -1, 300.00, 300.00); 
		}
		case 9: {
			packages[playerid] = CreateDynamicObject(19315, -1571.797729, -2070.638916, 45.984817, 117.300033, 3.400002, 0.000000, -1, -1, -1, 300.00, 300.00);
		}
		case 10: {
			packages[playerid] = CreateDynamicObject(19315, -1394.693237, -1911.311767, 25.436426, 100.099990, 10.899998, -12.699999, -1, -1, -1, 300.00, 300.00);
		}
	}

	SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Nice sniping skills! The deer has fallen down.");
	SendClientMessage(playerid, 0x339966AA, "{339966}(Hunter): {FFFFFF}Now take her and put it in the trunk.");

	return 1;

}

resetVar(playerid) {

	xyz[playerid][0] = xyz[playerid][1] = xyz[playerid][2] = xyz[playerid][3] = 0;
	pickUp[playerid] = packages[playerid] = deers[playerid] = 0;
	cTree[playerid] = 0; inJob[playerid] = -1;

}