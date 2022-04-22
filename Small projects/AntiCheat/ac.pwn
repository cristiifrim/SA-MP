#include <a_samp>
#include <YSF>
#include <zcmd>
#include <sscanf2>
#include <a_mysql>
#include <foreach>


#define RELEASED(%0) \
    (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

/*#define SQL_HOST "185.248.199.32"
#define SQL_USER "mateidb"
#define SQL_DATA "mateidb"
#define SQL_PASS "0n7k8TqADsFlzxxC" 

new SQL = -1;*/

enum TP {
	Float: Prev[4],
	Float: Post[4]
}

new Float: error = 5.315, Float: perror = 1.9,
playerRunning[MAX_PLAYERS],
aimbotWarning[MAX_PLAYERS],
pSilentWarning[MAX_PLAYERS],
rBulletCount[50][MAX_PLAYERS],
teleportWarning[MAX_PLAYERS][TP],
disabled[3];

forward checkTP();


new maxshot[50], lastShotTime[50][MAX_PLAYERS], shotTime[50][MAX_PLAYERS];
new Float:vmax[MAX_PLAYERS];


public OnFilterScriptInit() {

	//SQL = mysql_connect(SQL_HOST, SQL_USER, SQL_DATA, SQL_PASS);

	SendClientMessageToAll(-1, "AC ON testing cheats");
	SendClientMessageToAllf(-1, "ERROR RATE: %f", error);

	disabled[0] = disabled[1] = 0;

	SetTimer("checkTP", 1000, true);

	for(new i = 0; i < 50; ++i)
		maxshot[i] = 1740434400;

	return 1;

}

new Float: vmaxx, Float: vmaxy, Float: vmaxz;

public OnPlayerUpdate(playerid) {

	//new Float:vx,Float:vy,Float:vz;
	//GetPlayerVelocity(playerid,vx,vy,vz);
	//SendClientMessageToAllf(-1, "DEBUG: %s Velocity: %f %f %f", sendName(playerid), vx, vy, vz);
	/*if(vx > vmaxx) {
		SendClientMessagef(playerid, -1, "NEW HIGHER SPEED ON X AXIS: %f", vx);
		vmaxx = vx;
	}
	if(vy > vmaxy) {
		SendClientMessagef(playerid, -1, "NEW HIGHER SPEED ON Y AXIS: %f", vy);
		vmaxy = vy;
	}
	if(vz > vmaxz) {
		SendClientMessagef(playerid, -1, "NEW HIGHER SPEED ON Z AXIS: %f", vz);
		vmaxz = vz;
	}*/
	return 1;
}

public OnPlayerConnect(playerid)
{
	pSilentWarning[playerid] = 0;
	aimbotWarning[playerid] = 0;
	for(new i = 0; i < 50; ++i)
		rBulletCount[i][playerid] = 0;
	vmax[playerid] = 0;
	return 1;
}



public checkTP() {

	foreach(new i: Player) {
		new pState; pState = GetPlayerState(i);
		if(pState == PLAYER_STATE_DRIVER) {
			GetVehiclePos(GetPlayerVehicleID(i), teleportWarning[i][Post][1], teleportWarning[i][Post][2], teleportWarning[i][Post][3]);
		}
		else {
			GetPlayerPos(i, teleportWarning[i][Post][1], teleportWarning[i][Post][2], teleportWarning[i][Post][3]);
			new Float:vx,Float:vy,Float:vz;
			GetPlayerVelocity(i, vx, vy, vz);
			//SendClientMessageToAllf(-1, "DEBUG: %s Velocity: %f %f %f", sendName(i), vx, vy, vz);
			vmax[i] = GetPlayerDistanceFromPoint(i, teleportWarning[i][Prev][1], teleportWarning[i][Prev][2], teleportWarning[i][Prev][3]);
			if(floatabs(vx) > 0.30 || floatabs(vy) > 0.30 || vmax[i] > 12.46 && vmax[i] < 20) {
				SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - fast-run. X: %f Y: %f", sendName(i), vx, vy);
		
			}
			if(vmax[i] > 20 && GetPlayerAnimationIndex(i) != 1130) {
				SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - Air-Break / Map-Run / Teleport. X: %f Y: %f", sendName(i), vx, vy);
		
			}
			/*if(vz > 0.15 || teleportWarning[i][Post][3] - teleportWarning[i][Prev][3] > vz * 50) 
				SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - mega-jump.", sendName(i));
			//if(teleportWarning[i][Prev][])*/
		}
		teleportWarning[i][Prev][1] = teleportWarning[i][Post][1];
		teleportWarning[i][Prev][2] = teleportWarning[i][Post][2];
		teleportWarning[i][Prev][3] = teleportWarning[i][Post][3];
	}

}

CMD:resetvmax(playerid, params[]) {

	vmax[playerid]  = 0;
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{


	/*shotTime[weaponid][playerid] = gettime();
	rBulletCount[weaponid][playerid]++;
	if(shotTime[weaponid][playerid] - lastShotTime[weaponid][playerid] < 1)
	if(gettime() - shotTime[weaponid][playerid] == 1) {
		if(rBulletCount[24][playerid] > 2)
			SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - rapid-fire.", sendName(playerid));
		if(rBulletCount[31][playerid] > 10)
			SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - rapid-fire.", sendName(playerid));
		if(rBulletCount[23][playerid] > 1)
			SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - rapid-fire.", sendName(playerid));
		if(rBulletCount[29][playerid] > 10)
			SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - rapid-fire.", sendName(playerid));
		if(rBulletCount[30][playerid] > 10)
			SendClientMessageToAllf(0xFF0000AA, "AC-Testing: %s may be cheating - rapid-fire.", sendName(playerid));

		rBulletCount[weaponid][playerid] = 0;
	}*/
	if(hittype == 1)
	{
        new Float:fOriginX, Float:fOriginY, Float:fOriginZ, Float:fHitPosX, Float:fHitPosY, Float:fHitPosZ;
        GetPlayerLastShotVectors(playerid, Float:fOriginX, Float:fOriginY, Float:fOriginZ, Float:fHitPosX, Float:fHitPosY, Float:fHitPosZ);
		new Float: Angle; GetPlayerFacingAngle(playerid, Angle);   
		if(disabled[0] == 0) {
			if(GetPlayerAnimationIndex(playerid) != 1183 && GetPlayerAnimationIndex(playerid) != 1189 && floatround(floattan(Angle) - (fHitPosY - fOriginY) / (fHitPosX - fOriginX), floatround_round) == floatround(floattan(error), floatround_round) && GetPlayerState(hitid) != PLAYER_STATE_NONE) {
				new string[128];
	            format(string, sizeof(string), "Testing: {FFFFFF}%s may be using {FF0000}Aim-Bot {FFFFFF} - %d warnings", sendName(playerid), ++pSilentWarning[playerid]);
	            SendClientMessageToAll(0xFFFF00AA, string);
	       	}  
        }
       	if(disabled[1] == 0) {

	        if(!IsPlayerInRangeOfPoint(hitid, perror, fHitPosX, fHitPosY, fHitPosZ))
	        {
	            aimbotWarning[playerid]++;
	            new string[128];
	            format(string, sizeof(string), "AC-AdmBot: {FFFFFF}%s may be using {FF0000}Aim-Bot {FFFFFF}- %d warnings.", sendName(playerid), aimbotWarning[playerid]);
		        SendClientMessageToAll(0xFFFF00AA, string);
	        }
	    }

    }
	      
	return 1;
}

new bulletCount[MAX_PLAYERS][MAX_PLAYERS];

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(weaponid == 31) {
		if(playerRunning[damagedid] == 1) {
			if(++bulletCount[playerid][damagedid] > 6)
				SendClientMessageToAllf(0xFF0000AA, "AC-TEST: Player %s hit %s with M4 %d times while he was running.", sendName(playerid), sendName(damagedid), bulletCount[playerid][damagedid]);
		}
	}
	if(weaponid != 24 && weaponid != 31 && weaponid != 30 && weaponid != 25 && weaponid != 29 && weaponid != 33 && weaponid != 8)
	{
		SendClientMessageToAllf(0xFF0000AA, "AC-TEST: Player %s has been kicked. Reason: Weapon cheats.", sendName(playerid));
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {

	foreach(new i: Player)
		bulletCount[i][playerid] = 0;

	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if(PRESSED(KEY_SPRINT))
			playerRunning[playerid] = 1;
		else if(RELEASED(KEY_SPRINT))
			playerRunning[playerid] = 0;
	}

	return 0;
}


CMD:disableac(playerid, params[]) {
	new d;
	if(sscanf(params, "d", d)) {
		SendClientMessage(playerid, -1, "USAGE: /DISABLEAC [0 - pSilent | 1 - Pro Aimbot]");
		SendClientMessage(playerid, -1, "[TO ENABLE AC USE THE SAME COMMAND]");
		return 1;
	}
	if(d == 0) {
		if(disabled[0] == 1) {
			disabled[0] = 0;
			SendClientMessageToAll(-1, "SERVER MESSAGE: Anti pSilent Aimbot activated!");
		}
		else {
			disabled[0] = 1;
			SendClientMessageToAll(-1, "SERVER MESSAGE: Anti pSilent Aimbot disabled!");
		}
	}
	else if(d == 1) {
		if(disabled[1] == 1) {
			disabled[1] = 0;
			SendClientMessageToAll(-1, "SERVER MESSAGE: Anti Pro-Aimbot activated!");
		}
		else {
			disabled[1] = 1;
			SendClientMessageToAll(-1, "SERVER MESSAGE: Anti Pro-Aimbot disabled!");
		}
	}
	SendClientMessageToAll(-1, "SERVER MESSAGE: Be kindful and understand that we are still testing the anticheat. Thank you. Auto-Message by the developer.");
	return 1;

}

CMD:seterror(playerid, params[]) {

	new Float: Z;
	if(sscanf(params, "f", Z)) {
		SendClientMessage(playerid, -1, "USAGE: /SETERROR [RECOMMENDED TO USE VALUES BETWEEN 4.5-7 TO TEST");
		SendClientMessage(playerid, -1, "[THIS COMMAND NEEDS A LOT OF TESTS THEN YOU DM ME THE BEST ERROR]");
		return 1;
	}
	error = Z;
	SendClientMessageToAllf(-1, "ERROR RATE: %f", error);
	SendClientMessageToAll(-1, "SERVER MESSAGE: Take into account that this command is used to test the AC with various error rates for pSilent. Auto-Message by the developer.");
	return 1;
}

CMD:setperror(playerid, params[]) {

	new Float: Z;
	if(sscanf(params, "f", Z)) {
		SendClientMessage(playerid, -1, "USAGE: /SETPERROR [RECOMMENDED TO USE VALUES BETWEEN 1.5-3.5 TO TEST");
		SendClientMessage(playerid, -1, "[THIS COMMAND NEEDS A LOT OF TESTS THEN YOU DM ME THE BEST pERROR]");
		return 1;
	}
	perror = Z;
	SendClientMessageToAllf(-1, "pERROR RATE: %f", perror);
	SendClientMessageToAll(-1, "SERVER MESSAGE: Take into account that this command is used to test the AC with various error rates for Pro-Aim. Auto-Message by the developer.");
	return 1;
}

sendName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, 24);
	return name;
}