#if defined Header 
	Roulette system by NeaCristy. Please keep the credits and enjoy the system.
	Contact: WhatsApp: 0732391396; E-Mail: neacristy_scripts@yahoo.com;
#endif

//=============================================================================

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <streamer>
#include <foreach>


//roulete red - -1523963137

/*enum RoulleteData {

}*/

#define randomEx(%0,%1) \
	(random(%1-(%0))+%0)

new rouletteOption[MAX_PLAYERS], // 0 - 36(Number) x36, 37 - 38(RED, BLACK) x2, 39-40(ODD, EVEN) x2, 41-42-43(1st12, 2nd12, 3rd12) x3, 44-45(1-18, 19-36) x2, 46-47-48(3 to 1) x3
playerCoins[MAX_PLAYERS], rouletteResult, rouletteFirstBet, rouletteTimer, betCoins[MAX_PLAYERS];  //Modifici tu aici cu coins-u playerilor

new betNames[][] = {
	"Bet on number 0",
	"Bet on number 1",
	"Bet on number 2",
	"Bet on number 3",
	"Bet on number 4",
	"Bet on number 5",
	"Bet on number 6",
	"Bet on number 7",
	"Bet on number 8",
	"Bet on number 9",
	"Bet on number 10",
	"Bet on number 11",
	"Bet on number 12",
	"Bet on number 13",
	"Bet on number 14",
	"Bet on number 15",
	"Bet on number 16",
	"Bet on number 17",
	"Bet on number 18",
	"Bet on number 19",
	"Bet on number 20",
	"Bet on number 21",
	"Bet on number 22",
	"Bet on number 23",
	"Bet on number 24",
	"Bet on number 25",
	"Bet on number 26",
	"Bet on number 27",
	"Bet on number 28",
	"Bet on number 29",
	"Bet on number 30",
	"Bet on number 31",
	"Bet on number 32",
	"Bet on number 33",
	"Bet on number 34",
	"Bet on number 35",
	"Bet on number 36",
	"Bet on color RED",
	"Bet on color BLACK",
	"Bet on EVEN number",
	"Bet on ODD number",
	"Bet on 1st12 number",
	"Bet on 2nd12 number",
	"Bet on 3rd12 number",
	"Bet on 1-18 number",
	"Bet on 19-36 number",
	"Bet on 3 to 1 number - column 1",
	"Bet on 3 to 1 number - column 2",
	"Bet on 3 to 1 number - column 3"
};

new Iterator: inRoulette<MAX_PLAYERS>;

new Text:Roulette[49], Text:RouletteNumber[4], Text:RouletteTime, PlayerText: rouletteCoins;

forward RouletteRolling(); forward RouletteStart();



AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}

main() {}

public OnFilterScriptInit() {

	AntiDeAMX();
	DisableInteriorEnterExits();

	//New map featured for 'neacristy' by 'NoLife' on 06/01/2019.
	new tmpobjid;
	tmpobjid = CreateDynamicObject(2176, 2235.843261, 1677.167480, 1014.834228, -0.000000, 540.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	SetDynamicObjectMaterial(tmpobjid, 1, 19480, "signsurf", "sign", 0x00000000);
	tmpobjid = CreateDynamicObject(7313, 2235.742187, 1667.037597, 1014.800292, 0.000000, -0.000022, 179.999786, -1, 1, -1, 300.00, 300.00);
	SetDynamicObjectMaterialText(tmpobjid, 0, "{FF0000}Coins Betting!", 110, "Ariel", 50, 1, 0x00000000, 0xFFFFFFFF, 1);
	tmpobjid = CreateDynamicObject(1978, 2235.843261, 1670.907226, 1008.384338, 0.000022, 0.000000, 89.999862, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1978, 2242.163574, 1677.167480, 1008.384338, 0.000000, -0.000022, 179.999786, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(1978, 2229.643554, 1677.167480, 1008.384338, -0.000000, 0.000022, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2178, 2235.843261, 1677.167480, 1017.614196, -0.000000, 360.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2178, 2235.843261, 1677.167480, 1017.114196, -0.000000, 360.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2178, 2235.843261, 1677.167480, 1016.614196, -0.000000, 360.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2178, 2235.843261, 1677.167480, 1016.114196, -0.000000, 360.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(11726, 2235.843261, 1677.167480, 1014.834228, -0.000000, 720.000000, -0.000068, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2176, 2240.702148, 1682.026123, 1010.154296, 0.000016, 720.000000, 44.999984, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2176, 2240.723144, 1672.287597, 1010.154296, 0.000016, 720.000000, 44.999984, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2176, 2231.019775, 1672.343994, 1010.154296, 0.000016, 720.000000, 44.999984, -1, 1, -1, 300.00, 300.00);
	tmpobjid = CreateDynamicObject(2176, 2231.048828, 1681.961914, 1010.154296, 0.000016, 720.000000, 44.999984, -1, 1, -1, 300.00, 300.00);


	RouletteTime = TextDrawCreate(335.800506, 32.685161, "Roulette will roll in: 60 seconds.");
	TextDrawLetterSize(RouletteTime, 0.213666, 2.583112);
	TextDrawAlignment(RouletteTime, 3);
	TextDrawColor(RouletteTime, -1);
	TextDrawSetShadow(RouletteTime, 1);
	TextDrawSetOutline(RouletteTime, 1);
	TextDrawBackgroundColor(RouletteTime, 255);
	TextDrawFont(RouletteTime, 2);
	TextDrawSetProportional(RouletteTime, 1);
	TextDrawSetShadow(RouletteTime, 1);

	RouletteNumber[0] = TextDrawCreate(409.333404, 12.044433, "box");
	TextDrawLetterSize(RouletteNumber[0], 0.000000, 6.166667);
	TextDrawTextSize(RouletteNumber[0], 0.000000, 49.000000);
	TextDrawAlignment(RouletteNumber[0], 2);
	TextDrawColor(RouletteNumber[0], -1);
	TextDrawUseBox(RouletteNumber[0], 1);
	TextDrawBoxColor(RouletteNumber[0], -1061109505);
	TextDrawSetShadow(RouletteNumber[0], 0);
	TextDrawSetOutline(RouletteNumber[0], 0);
	TextDrawBackgroundColor(RouletteNumber[0], 255);
	TextDrawFont(RouletteNumber[0], 1);
	TextDrawSetProportional(RouletteNumber[0], 1);
	TextDrawSetShadow(RouletteNumber[0], 0);

	RouletteNumber[1] = TextDrawCreate(409.766693, 15.348143, "box");
	TextDrawLetterSize(RouletteNumber[1], 0.000000, 5.466664);
	TextDrawTextSize(RouletteNumber[1], 0.000000, 45.000000);
	TextDrawAlignment(RouletteNumber[1], 2);
	TextDrawColor(RouletteNumber[1], -1);
	TextDrawUseBox(RouletteNumber[1], 1);
	TextDrawBoxColor(RouletteNumber[1], 865691391);
	TextDrawSetShadow(RouletteNumber[1], 0);
	TextDrawSetOutline(RouletteNumber[1], 0);
	TextDrawBackgroundColor(RouletteNumber[1], 255);
	TextDrawFont(RouletteNumber[1], 1);
	TextDrawSetProportional(RouletteNumber[1], 1);
	TextDrawSetShadow(RouletteNumber[1], 0);

	RouletteNumber[2] = TextDrawCreate(409.566680, 18.381484, "box");
	TextDrawLetterSize(RouletteNumber[2], 0.000999, 4.799998);
	TextDrawTextSize(RouletteNumber[2], 0.000000, 43.000000);
	TextDrawAlignment(RouletteNumber[2], 2);
	TextDrawColor(RouletteNumber[2], -1);
	TextDrawUseBox(RouletteNumber[2], 1);
	TextDrawBoxColor(RouletteNumber[2], -1523963137);
	TextDrawSetShadow(RouletteNumber[2], 0);
	TextDrawSetOutline(RouletteNumber[2], 0);
	TextDrawBackgroundColor(RouletteNumber[2], 255);
	TextDrawFont(RouletteNumber[2], 1);
	TextDrawSetProportional(RouletteNumber[2], 1);
	TextDrawSetShadow(RouletteNumber[2], 0);

	RouletteNumber[3] = TextDrawCreate(395.666687, 24.488901, "24");
	TextDrawLetterSize(RouletteNumber[3], 0.718333, 3.221926);
	TextDrawAlignment(RouletteNumber[3], 1);
	TextDrawColor(RouletteNumber[3], -1);
	TextDrawSetShadow(RouletteNumber[3], 0);
	TextDrawSetOutline(RouletteNumber[3], 0);
	TextDrawBackgroundColor(RouletteNumber[3], 255);
	TextDrawFont(RouletteNumber[3], 3);
	TextDrawSetProportional(RouletteNumber[3], 1);
	TextDrawSetShadow(RouletteNumber[3], 0);

	Roulette[0] = TextDrawCreate(319.333465, 66.799987, "box");
	TextDrawLetterSize(Roulette[0], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[0], 360.000000, 10.000000);
	TextDrawAlignment(Roulette[0], 1);
	TextDrawColor(Roulette[0], -1);
	TextDrawUseBox(Roulette[0], 1);
	TextDrawBoxColor(Roulette[0], 0);
	TextDrawSetShadow(Roulette[0], 0);
	TextDrawSetOutline(Roulette[0], 0);
	TextDrawBackgroundColor(Roulette[0], 255);
	TextDrawFont(Roulette[0], 1);
	TextDrawSetProportional(Roulette[0], 1);
	TextDrawSetShadow(Roulette[0], 0);
	TextDrawSetSelectable(Roulette[0], true);

	Roulette[1] = TextDrawCreate(280.000000, 91.274055, "box");
	TextDrawLetterSize(Roulette[1], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[1], 310.000000, 10.000000);
	TextDrawAlignment(Roulette[1], 1);
	TextDrawColor(Roulette[1], -1);
	TextDrawUseBox(Roulette[1], 1);
	TextDrawBoxColor(Roulette[1], 0);
	TextDrawSetShadow(Roulette[1], 0);
	TextDrawSetOutline(Roulette[1], 0);
	TextDrawBackgroundColor(Roulette[1], 255);
	TextDrawFont(Roulette[1], 1);
	TextDrawSetProportional(Roulette[1], 1);
	TextDrawSetShadow(Roulette[1], 0);
	TextDrawSetSelectable(Roulette[1], true);

	Roulette[2] = TextDrawCreate(323.000091, 92.103698, "box");
	TextDrawLetterSize(Roulette[2], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[2], 350.000000, 10.000000);
	TextDrawAlignment(Roulette[2], 1);
	TextDrawColor(Roulette[2], -1);
	TextDrawUseBox(Roulette[2], 1);
	TextDrawBoxColor(Roulette[2], 0);
	TextDrawSetShadow(Roulette[2], 0);
	TextDrawSetOutline(Roulette[2], 0);
	TextDrawBackgroundColor(Roulette[2], 255);
	TextDrawFont(Roulette[2], 1);
	TextDrawSetProportional(Roulette[2], 1);
	TextDrawSetShadow(Roulette[2], 0);
	TextDrawSetSelectable(Roulette[2], true);

	Roulette[3] = TextDrawCreate(370.333465, 92.103706, "box");
	TextDrawLetterSize(Roulette[3], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[3], 396.000000, 10.000000);
	TextDrawAlignment(Roulette[3], 1);
	TextDrawColor(Roulette[3], -1);
	TextDrawUseBox(Roulette[3], 1);
	TextDrawBoxColor(Roulette[3], 0);
	TextDrawSetShadow(Roulette[3], 0);
	TextDrawSetOutline(Roulette[3], 0);
	TextDrawBackgroundColor(Roulette[3], 255);
	TextDrawFont(Roulette[3], 1);
	TextDrawSetProportional(Roulette[3], 1);
	TextDrawSetShadow(Roulette[3], 0);
	TextDrawSetSelectable(Roulette[3], true);

	Roulette[4] = TextDrawCreate(281.666717, 116.992576, "box");
	TextDrawLetterSize(Roulette[4], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[4], 310.000000, 10.000000);
	TextDrawAlignment(Roulette[4], 1);
	TextDrawColor(Roulette[4], -1);
	TextDrawUseBox(Roulette[4], 1);
	TextDrawBoxColor(Roulette[4], 0);
	TextDrawSetShadow(Roulette[4], 0);
	TextDrawSetOutline(Roulette[4], 0);
	TextDrawBackgroundColor(Roulette[4], 255);
	TextDrawFont(Roulette[4], 1);
	TextDrawSetProportional(Roulette[4], 1);
	TextDrawSetShadow(Roulette[4], 0);
	TextDrawSetSelectable(Roulette[4], true);

	Roulette[5] = TextDrawCreate(326.333404, 116.992568, "box");
	TextDrawLetterSize(Roulette[5], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[5], 354.000000, 10.000000);
	TextDrawAlignment(Roulette[5], 1);
	TextDrawColor(Roulette[5], -1);
	TextDrawUseBox(Roulette[5], 1);
	TextDrawBoxColor(Roulette[5], 0);
	TextDrawSetShadow(Roulette[5], 0);
	TextDrawSetOutline(Roulette[5], 0);
	TextDrawBackgroundColor(Roulette[5], 255);
	TextDrawFont(Roulette[5], 1);
	TextDrawSetProportional(Roulette[5], 1);
	TextDrawSetShadow(Roulette[5], 0);
	TextDrawSetSelectable(Roulette[5], true);

	Roulette[6] = TextDrawCreate(371.000122, 116.992561, "box");
	TextDrawLetterSize(Roulette[6], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[6], 397.000000, 10.000000);
	TextDrawAlignment(Roulette[6], 1);
	TextDrawColor(Roulette[6], -1);
	TextDrawUseBox(Roulette[6], 1);
	TextDrawBoxColor(Roulette[6], 0);
	TextDrawSetShadow(Roulette[6], 0);
	TextDrawSetOutline(Roulette[6], 0);
	TextDrawBackgroundColor(Roulette[6], 255);
	TextDrawFont(Roulette[6], 1);
	TextDrawSetProportional(Roulette[6], 1);
	TextDrawSetShadow(Roulette[6], 0);
	TextDrawSetSelectable(Roulette[6], true);

	Roulette[7] = TextDrawCreate(282.333404, 141.881484, "box");
	TextDrawLetterSize(Roulette[7], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[7], 310.000000, 10.000000);
	TextDrawAlignment(Roulette[7], 1);
	TextDrawColor(Roulette[7], -1);
	TextDrawUseBox(Roulette[7], 1);
	TextDrawBoxColor(Roulette[7], 0);
	TextDrawSetShadow(Roulette[7], 0);
	TextDrawSetOutline(Roulette[7], 0);
	TextDrawBackgroundColor(Roulette[7], 255);
	TextDrawFont(Roulette[7], 1);
	TextDrawSetProportional(Roulette[7], 1);
	TextDrawSetShadow(Roulette[7], 0);
	TextDrawSetSelectable(Roulette[7], true);

	Roulette[8] = TextDrawCreate(326.333435, 142.711135, "box");
	TextDrawLetterSize(Roulette[8], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[8], 353.000000, 10.000000);
	TextDrawAlignment(Roulette[8], 1);
	TextDrawColor(Roulette[8], -1);
	TextDrawUseBox(Roulette[8], 1);
	TextDrawBoxColor(Roulette[8], 0);
	TextDrawSetShadow(Roulette[8], 0);
	TextDrawSetOutline(Roulette[8], 0);
	TextDrawBackgroundColor(Roulette[8], 255);
	TextDrawFont(Roulette[8], 1);
	TextDrawSetProportional(Roulette[8], 1);
	TextDrawSetShadow(Roulette[8], 0);
	TextDrawSetSelectable(Roulette[8], true);

	Roulette[9] = TextDrawCreate(370.000091, 142.296325, "box");
	TextDrawLetterSize(Roulette[9], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[9], 397.000000, 10.000000);
	TextDrawAlignment(Roulette[9], 1);
	TextDrawColor(Roulette[9], -1);
	TextDrawUseBox(Roulette[9], 1);
	TextDrawBoxColor(Roulette[9], 0);
	TextDrawSetShadow(Roulette[9], 0);
	TextDrawSetOutline(Roulette[9], 0);
	TextDrawBackgroundColor(Roulette[9], 255);
	TextDrawFont(Roulette[9], 1);
	TextDrawSetProportional(Roulette[9], 1);
	TextDrawSetShadow(Roulette[9], 0);
	TextDrawSetSelectable(Roulette[9], true);

	Roulette[10] = TextDrawCreate(282.000061, 168.844467, "box");
	TextDrawLetterSize(Roulette[10], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[10], 310.000000, 10.000000);
	TextDrawAlignment(Roulette[10], 1);
	TextDrawColor(Roulette[10], -1);
	TextDrawUseBox(Roulette[10], 1);
	TextDrawBoxColor(Roulette[10], 0);
	TextDrawSetShadow(Roulette[10], 0);
	TextDrawSetOutline(Roulette[10], 0);
	TextDrawBackgroundColor(Roulette[10], 255);
	TextDrawFont(Roulette[10], 1);
	TextDrawSetProportional(Roulette[10], 1);
	TextDrawSetShadow(Roulette[10], 0);
	TextDrawSetSelectable(Roulette[10], true);

	Roulette[11] = TextDrawCreate(326.333435, 168.844467, "box");
	TextDrawLetterSize(Roulette[11], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[11], 353.000000, 10.000000);
	TextDrawAlignment(Roulette[11], 1);
	TextDrawColor(Roulette[11], -1);
	TextDrawUseBox(Roulette[11], 1);
	TextDrawBoxColor(Roulette[11], 0);
	TextDrawSetShadow(Roulette[11], 0);
	TextDrawSetOutline(Roulette[11], 0);
	TextDrawBackgroundColor(Roulette[11], 255);
	TextDrawFont(Roulette[11], 1);
	TextDrawSetProportional(Roulette[11], 1);
	TextDrawSetShadow(Roulette[11], 0);
	TextDrawSetSelectable(Roulette[11], true);

	Roulette[12] = TextDrawCreate(371.333465, 168.014801, "box");
	TextDrawLetterSize(Roulette[12], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[12], 397.000000, 10.000000);
	TextDrawAlignment(Roulette[12], 1);
	TextDrawColor(Roulette[12], -1);
	TextDrawUseBox(Roulette[12], 1);
	TextDrawBoxColor(Roulette[12], 0);
	TextDrawSetShadow(Roulette[12], 0);
	TextDrawSetOutline(Roulette[12], 0);
	TextDrawBackgroundColor(Roulette[12], 255);
	TextDrawFont(Roulette[12], 1);
	TextDrawSetProportional(Roulette[12], 1);
	TextDrawSetShadow(Roulette[12], 0);
	TextDrawSetSelectable(Roulette[12], true);

	Roulette[13] = TextDrawCreate(282.666870, 194.977783, "box");
	TextDrawLetterSize(Roulette[13], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[13], 306.000000, 10.000000);
	TextDrawAlignment(Roulette[13], 1);
	TextDrawColor(Roulette[13], -1);
	TextDrawUseBox(Roulette[13], 1);
	TextDrawBoxColor(Roulette[13], 0);
	TextDrawSetShadow(Roulette[13], 0);
	TextDrawSetOutline(Roulette[13], 0);
	TextDrawBackgroundColor(Roulette[13], 255);
	TextDrawFont(Roulette[13], 1);
	TextDrawSetProportional(Roulette[13], 1);
	TextDrawSetShadow(Roulette[13], 0);
	TextDrawSetSelectable(Roulette[13], true);

	Roulette[14] = TextDrawCreate(328.333557, 194.148147, "box");
	TextDrawLetterSize(Roulette[14], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[14], 351.000000, 10.000000);
	TextDrawAlignment(Roulette[14], 1);
	TextDrawColor(Roulette[14], -1);
	TextDrawUseBox(Roulette[14], 1);
	TextDrawBoxColor(Roulette[14], 0);
	TextDrawSetShadow(Roulette[14], 0);
	TextDrawSetOutline(Roulette[14], 0);
	TextDrawBackgroundColor(Roulette[14], 255);
	TextDrawFont(Roulette[14], 1);
	TextDrawSetProportional(Roulette[14], 1);
	TextDrawSetShadow(Roulette[14], 0);
	TextDrawSetSelectable(Roulette[14], true);

	Roulette[15] = TextDrawCreate(371.333496, 193.318511, "box");
	TextDrawLetterSize(Roulette[15], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[15], 396.000000, 10.000000);
	TextDrawAlignment(Roulette[15], 1);
	TextDrawColor(Roulette[15], -1);
	TextDrawUseBox(Roulette[15], 1);
	TextDrawBoxColor(Roulette[15], 0);
	TextDrawSetShadow(Roulette[15], 0);
	TextDrawSetOutline(Roulette[15], 0);
	TextDrawBackgroundColor(Roulette[15], 255);
	TextDrawFont(Roulette[15], 1);
	TextDrawSetProportional(Roulette[15], 1);
	TextDrawSetShadow(Roulette[15], 0);
	TextDrawSetSelectable(Roulette[15], true);

	Roulette[16] = TextDrawCreate(281.666748, 219.866668, "box");
	TextDrawLetterSize(Roulette[16], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[16], 309.000000, 10.000000);
	TextDrawAlignment(Roulette[16], 1);
	TextDrawColor(Roulette[16], -1);
	TextDrawUseBox(Roulette[16], 1);
	TextDrawBoxColor(Roulette[16], 0);
	TextDrawSetShadow(Roulette[16], 0);
	TextDrawSetOutline(Roulette[16], 0);
	TextDrawBackgroundColor(Roulette[16], 255);
	TextDrawFont(Roulette[16], 1);
	TextDrawSetProportional(Roulette[16], 1);
	TextDrawSetShadow(Roulette[16], 0);
	TextDrawSetSelectable(Roulette[16], true);

	Roulette[17] = TextDrawCreate(326.666748, 219.451858, "box");
	TextDrawLetterSize(Roulette[17], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[17], 354.000000, 10.000000);
	TextDrawAlignment(Roulette[17], 1);
	TextDrawColor(Roulette[17], -1);
	TextDrawUseBox(Roulette[17], 1);
	TextDrawBoxColor(Roulette[17], 0);
	TextDrawSetShadow(Roulette[17], 0);
	TextDrawSetOutline(Roulette[17], 0);
	TextDrawBackgroundColor(Roulette[17], 255);
	TextDrawFont(Roulette[17], 1);
	TextDrawSetProportional(Roulette[17], 1);
	TextDrawSetShadow(Roulette[17], 0);
	TextDrawSetSelectable(Roulette[17], true);

	Roulette[18] = TextDrawCreate(370.333374, 219.866653, "box");
	TextDrawLetterSize(Roulette[18], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[18], 399.000000, 10.000000);
	TextDrawAlignment(Roulette[18], 1);
	TextDrawColor(Roulette[18], -1);
	TextDrawUseBox(Roulette[18], 1);
	TextDrawBoxColor(Roulette[18], 0);
	TextDrawSetShadow(Roulette[18], 0);
	TextDrawSetOutline(Roulette[18], 0);
	TextDrawBackgroundColor(Roulette[18], 255);
	TextDrawFont(Roulette[18], 1);
	TextDrawSetProportional(Roulette[18], 1);
	TextDrawSetShadow(Roulette[18], 0);
	TextDrawSetSelectable(Roulette[18], true);

	Roulette[19] = TextDrawCreate(281.333435, 245.585205, "box");
	TextDrawLetterSize(Roulette[19], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[19], 308.000000, 10.000000);
	TextDrawAlignment(Roulette[19], 1);
	TextDrawColor(Roulette[19], -1);
	TextDrawUseBox(Roulette[19], 1);
	TextDrawBoxColor(Roulette[19], 0);
	TextDrawSetShadow(Roulette[19], 0);
	TextDrawSetOutline(Roulette[19], 0);
	TextDrawBackgroundColor(Roulette[19], 255);
	TextDrawFont(Roulette[19], 1);
	TextDrawSetProportional(Roulette[19], 1);
	TextDrawSetShadow(Roulette[19], 0);
	TextDrawSetSelectable(Roulette[19], true);

	Roulette[20] = TextDrawCreate(326.333496, 246.000015, "box");
	TextDrawLetterSize(Roulette[20], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[20], 351.000000, 10.000000);
	TextDrawAlignment(Roulette[20], 1);
	TextDrawColor(Roulette[20], -1);
	TextDrawUseBox(Roulette[20], 1);
	TextDrawBoxColor(Roulette[20], 0);
	TextDrawSetShadow(Roulette[20], 0);
	TextDrawSetOutline(Roulette[20], 0);
	TextDrawBackgroundColor(Roulette[20], 255);
	TextDrawFont(Roulette[20], 1);
	TextDrawSetProportional(Roulette[20], 1);
	TextDrawSetShadow(Roulette[20], 0);
	TextDrawSetSelectable(Roulette[20], true);

	Roulette[21] = TextDrawCreate(373.000183, 246.414825, "box");
	TextDrawLetterSize(Roulette[21], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[21], 397.000000, 10.000000);
	TextDrawAlignment(Roulette[21], 1);
	TextDrawColor(Roulette[21], -1);
	TextDrawUseBox(Roulette[21], 1);
	TextDrawBoxColor(Roulette[21], 0);
	TextDrawSetShadow(Roulette[21], 0);
	TextDrawSetOutline(Roulette[21], 0);
	TextDrawBackgroundColor(Roulette[21], 255);
	TextDrawFont(Roulette[21], 1);
	TextDrawSetProportional(Roulette[21], 1);
	TextDrawSetShadow(Roulette[21], 0);
	TextDrawSetSelectable(Roulette[21], true);

	Roulette[22] = TextDrawCreate(282.000122, 272.133361, "box");
	TextDrawLetterSize(Roulette[22], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[22], 308.000000, 10.000000);
	TextDrawAlignment(Roulette[22], 1);
	TextDrawColor(Roulette[22], -1);
	TextDrawUseBox(Roulette[22], 1);
	TextDrawBoxColor(Roulette[22], 0);
	TextDrawSetShadow(Roulette[22], 0);
	TextDrawSetOutline(Roulette[22], 0);
	TextDrawBackgroundColor(Roulette[22], 255);
	TextDrawFont(Roulette[22], 1);
	TextDrawSetProportional(Roulette[22], 1);
	TextDrawSetShadow(Roulette[22], 0);
	TextDrawSetSelectable(Roulette[22], true);

	Roulette[23] = TextDrawCreate(327.333465, 272.548095, "box");
	TextDrawLetterSize(Roulette[23], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[23], 353.000000, 10.000000);
	TextDrawAlignment(Roulette[23], 1);
	TextDrawColor(Roulette[23], -1);
	TextDrawUseBox(Roulette[23], 1);
	TextDrawBoxColor(Roulette[23], 0);
	TextDrawSetShadow(Roulette[23], 0);
	TextDrawSetOutline(Roulette[23], 0);
	TextDrawBackgroundColor(Roulette[23], 255);
	TextDrawFont(Roulette[23], 1);
	TextDrawSetProportional(Roulette[23], 1);
	TextDrawSetShadow(Roulette[23], 0);
	TextDrawSetSelectable(Roulette[23], true);

	Roulette[24] = TextDrawCreate(373.333557, 272.962921, "box");
	TextDrawLetterSize(Roulette[24], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[24], 396.000000, 10.000000);
	TextDrawAlignment(Roulette[24], 1);
	TextDrawColor(Roulette[24], -1);
	TextDrawUseBox(Roulette[24], 1);
	TextDrawBoxColor(Roulette[24], 0);
	TextDrawSetShadow(Roulette[24], 0);
	TextDrawSetOutline(Roulette[24], 0);
	TextDrawBackgroundColor(Roulette[24], 255);
	TextDrawFont(Roulette[24], 1);
	TextDrawSetProportional(Roulette[24], 1);
	TextDrawSetShadow(Roulette[24], 0);
	TextDrawSetSelectable(Roulette[24], true);

	Roulette[25] = TextDrawCreate(281.666870, 299.511138, "box");
	TextDrawLetterSize(Roulette[25], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[25], 305.000000, 10.000000);
	TextDrawAlignment(Roulette[25], 1);
	TextDrawColor(Roulette[25], -1);
	TextDrawUseBox(Roulette[25], 1);
	TextDrawBoxColor(Roulette[25], 0);
	TextDrawSetShadow(Roulette[25], 0);
	TextDrawSetOutline(Roulette[25], 0);
	TextDrawBackgroundColor(Roulette[25], 255);
	TextDrawFont(Roulette[25], 1);
	TextDrawSetProportional(Roulette[25], 1);
	TextDrawSetShadow(Roulette[25], 0);
	TextDrawSetSelectable(Roulette[25], true);

	Roulette[26] = TextDrawCreate(326.666870, 298.266662, "box");
	TextDrawLetterSize(Roulette[26], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[26], 350.000000, 10.000000);
	TextDrawAlignment(Roulette[26], 1);
	TextDrawColor(Roulette[26], -1);
	TextDrawUseBox(Roulette[26], 1);
	TextDrawBoxColor(Roulette[26], 0);
	TextDrawSetShadow(Roulette[26], 0);
	TextDrawSetOutline(Roulette[26], 0);
	TextDrawBackgroundColor(Roulette[26], 255);
	TextDrawFont(Roulette[26], 1);
	TextDrawSetProportional(Roulette[26], 1);
	TextDrawSetShadow(Roulette[26], 0);
	TextDrawSetSelectable(Roulette[26], true);

	Roulette[27] = TextDrawCreate(373.666931, 298.266754, "box");
	TextDrawLetterSize(Roulette[27], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[27], 395.000000, 10.000000);
	TextDrawAlignment(Roulette[27], 1);
	TextDrawColor(Roulette[27], -1);
	TextDrawUseBox(Roulette[27], 1);
	TextDrawBoxColor(Roulette[27], 0);
	TextDrawSetShadow(Roulette[27], 0);
	TextDrawSetOutline(Roulette[27], 0);
	TextDrawBackgroundColor(Roulette[27], 255);
	TextDrawFont(Roulette[27], 1);
	TextDrawSetProportional(Roulette[27], 1);
	TextDrawSetShadow(Roulette[27], 0);
	TextDrawSetSelectable(Roulette[27], true);

	Roulette[28] = TextDrawCreate(285.333587, 327.303833, "box");
	TextDrawLetterSize(Roulette[28], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[28], 307.000000, 10.000000);
	TextDrawAlignment(Roulette[28], 1);
	TextDrawColor(Roulette[28], -1);
	TextDrawUseBox(Roulette[28], 1);
	TextDrawBoxColor(Roulette[28], 0);
	TextDrawSetShadow(Roulette[28], 0);
	TextDrawSetOutline(Roulette[28], 0);
	TextDrawBackgroundColor(Roulette[28], 255);
	TextDrawFont(Roulette[28], 1);
	TextDrawSetProportional(Roulette[28], 1);
	TextDrawSetShadow(Roulette[28], 0);
	TextDrawSetSelectable(Roulette[28], true);

	Roulette[29] = TextDrawCreate(329.000213, 325.644592, "box");
	TextDrawLetterSize(Roulette[29], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[29], 352.000000, 10.000000);
	TextDrawAlignment(Roulette[29], 1);
	TextDrawColor(Roulette[29], -1);
	TextDrawUseBox(Roulette[29], 1);
	TextDrawBoxColor(Roulette[29], 0);
	TextDrawSetShadow(Roulette[29], 0);
	TextDrawSetOutline(Roulette[29], 0);
	TextDrawBackgroundColor(Roulette[29], 255);
	TextDrawFont(Roulette[29], 1);
	TextDrawSetProportional(Roulette[29], 1);
	TextDrawSetShadow(Roulette[29], 0);
	TextDrawSetSelectable(Roulette[29], true);

	Roulette[30] = TextDrawCreate(375.000213, 327.303833, "box");
	TextDrawLetterSize(Roulette[30], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[30], 398.000000, 10.000000);
	TextDrawAlignment(Roulette[30], 1);
	TextDrawColor(Roulette[30], -1);
	TextDrawUseBox(Roulette[30], 1);
	TextDrawBoxColor(Roulette[30], 0);
	TextDrawSetShadow(Roulette[30], 0);
	TextDrawSetOutline(Roulette[30], 0);
	TextDrawBackgroundColor(Roulette[30], 255);
	TextDrawFont(Roulette[30], 1);
	TextDrawSetProportional(Roulette[30], 1);
	TextDrawSetShadow(Roulette[30], 0);
	TextDrawSetSelectable(Roulette[30], true);

	Roulette[31] = TextDrawCreate(283.333526, 355.096405, "box");
	TextDrawLetterSize(Roulette[31], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[31], 307.000000, 10.000000);
	TextDrawAlignment(Roulette[31], 1);
	TextDrawColor(Roulette[31], -1);
	TextDrawUseBox(Roulette[31], 1);
	TextDrawBoxColor(Roulette[31], 0);
	TextDrawSetShadow(Roulette[31], 0);
	TextDrawSetOutline(Roulette[31], 0);
	TextDrawBackgroundColor(Roulette[31], 255);
	TextDrawFont(Roulette[31], 1);
	TextDrawSetProportional(Roulette[31], 1);
	TextDrawSetShadow(Roulette[31], 0);
	TextDrawSetSelectable(Roulette[31], true);

	Roulette[32] = TextDrawCreate(328.000244, 354.266723, "box");
	TextDrawLetterSize(Roulette[32], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[32], 350.000000, 10.000000);
	TextDrawAlignment(Roulette[32], 1);
	TextDrawColor(Roulette[32], -1);
	TextDrawUseBox(Roulette[32], 1);
	TextDrawBoxColor(Roulette[32], 0);
	TextDrawSetShadow(Roulette[32], 0);
	TextDrawSetOutline(Roulette[32], 0);
	TextDrawBackgroundColor(Roulette[32], 255);
	TextDrawFont(Roulette[32], 1);
	TextDrawSetProportional(Roulette[32], 1);
	TextDrawSetShadow(Roulette[32], 0);
	TextDrawSetSelectable(Roulette[32], true);

	Roulette[33] = TextDrawCreate(374.333526, 354.266723, "box");
	TextDrawLetterSize(Roulette[33], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[33], 398.000000, 10.000000);
	TextDrawAlignment(Roulette[33], 1);
	TextDrawColor(Roulette[33], -1);
	TextDrawUseBox(Roulette[33], 1);
	TextDrawBoxColor(Roulette[33], 0);
	TextDrawSetShadow(Roulette[33], 0);
	TextDrawSetOutline(Roulette[33], 0);
	TextDrawBackgroundColor(Roulette[33], 255);
	TextDrawFont(Roulette[33], 1);
	TextDrawSetProportional(Roulette[33], 1);
	TextDrawSetShadow(Roulette[33], 0);
	TextDrawSetSelectable(Roulette[33], true);

	Roulette[34] = TextDrawCreate(282.000183, 382.474182, "box");
	TextDrawLetterSize(Roulette[34], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[34], 306.000000, 10.000000);
	TextDrawAlignment(Roulette[34], 1);
	TextDrawColor(Roulette[34], -1);
	TextDrawUseBox(Roulette[34], 1);
	TextDrawBoxColor(Roulette[34], 0);
	TextDrawSetShadow(Roulette[34], 0);
	TextDrawSetOutline(Roulette[34], 0);
	TextDrawBackgroundColor(Roulette[34], 255);
	TextDrawFont(Roulette[34], 1);
	TextDrawSetProportional(Roulette[34], 1);
	TextDrawSetShadow(Roulette[34], 0);
	TextDrawSetSelectable(Roulette[34], true);

	Roulette[35] = TextDrawCreate(328.000183, 383.303802, "box");
	TextDrawLetterSize(Roulette[35], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[35], 352.000000, 10.000000);
	TextDrawAlignment(Roulette[35], 1);
	TextDrawColor(Roulette[35], -1);
	TextDrawUseBox(Roulette[35], 1);
	TextDrawBoxColor(Roulette[35], 0);
	TextDrawSetShadow(Roulette[35], 0);
	TextDrawSetOutline(Roulette[35], 0);
	TextDrawBackgroundColor(Roulette[35], 255);
	TextDrawFont(Roulette[35], 1);
	TextDrawSetProportional(Roulette[35], 1);
	TextDrawSetShadow(Roulette[35], 0);
	TextDrawSetSelectable(Roulette[35], true);

	Roulette[36] = TextDrawCreate(375.333557, 384.963073, "box");
	TextDrawLetterSize(Roulette[36], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[36], 398.000000, 10.000000);
	TextDrawAlignment(Roulette[36], 1);
	TextDrawColor(Roulette[36], -1);
	TextDrawUseBox(Roulette[36], 1);
	TextDrawBoxColor(Roulette[36], 0);
	TextDrawSetShadow(Roulette[36], 0);
	TextDrawSetOutline(Roulette[36], 0);
	TextDrawBackgroundColor(Roulette[36], 255);
	TextDrawFont(Roulette[36], 1);
	TextDrawSetProportional(Roulette[36], 1);
	TextDrawSetShadow(Roulette[36], 0);
	TextDrawSetSelectable(Roulette[36], true);

	Roulette[37] = TextDrawCreate(191.000228, 200.370452, "box");
	TextDrawLetterSize(Roulette[37], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[37], 221.000000, 20.000000);
	TextDrawAlignment(Roulette[37], 1);
	TextDrawColor(Roulette[37], -1);
	TextDrawUseBox(Roulette[37], 1);
	TextDrawBoxColor(Roulette[37], 0);
	TextDrawSetShadow(Roulette[37], 0);
	TextDrawSetOutline(Roulette[37], 0);
	TextDrawBackgroundColor(Roulette[37], 255);
	TextDrawFont(Roulette[37], 1);
	TextDrawSetProportional(Roulette[37], 1);
	TextDrawSetShadow(Roulette[37], 0);
	TextDrawSetSelectable(Roulette[37], true);

	Roulette[38] = TextDrawCreate(189.666915, 252.637130, "box");
	TextDrawLetterSize(Roulette[38], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[38], 221.000000, 20.000000);
	TextDrawAlignment(Roulette[38], 1);
	TextDrawColor(Roulette[38], -1);
	TextDrawUseBox(Roulette[38], 1);
	TextDrawBoxColor(Roulette[38], 0);
	TextDrawSetShadow(Roulette[38], 0);
	TextDrawSetOutline(Roulette[38], 0);
	TextDrawBackgroundColor(Roulette[38], 255);
	TextDrawFont(Roulette[38], 1);
	TextDrawSetProportional(Roulette[38], 1);
	TextDrawSetShadow(Roulette[38], 0);
	TextDrawSetSelectable(Roulette[38], true);

	Roulette[39] = TextDrawCreate(192.000244, 146.859344, "box");
	TextDrawLetterSize(Roulette[39], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[39], 223.000000, 20.000000);
	TextDrawAlignment(Roulette[39], 1);
	TextDrawColor(Roulette[39], -1);
	TextDrawUseBox(Roulette[39], 1);
	TextDrawBoxColor(Roulette[39], 0);
	TextDrawSetShadow(Roulette[39], 0);
	TextDrawSetOutline(Roulette[39], 0);
	TextDrawBackgroundColor(Roulette[39], 255);
	TextDrawFont(Roulette[39], 1);
	TextDrawSetProportional(Roulette[39], 1);
	TextDrawSetShadow(Roulette[39], 0);
	TextDrawSetSelectable(Roulette[39], true);

	Roulette[40] = TextDrawCreate(188.333572, 309.466796, "box");
	TextDrawLetterSize(Roulette[40], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[40], 219.000000, 20.000000);
	TextDrawAlignment(Roulette[40], 1);
	TextDrawColor(Roulette[40], -1);
	TextDrawUseBox(Roulette[40], 1);
	TextDrawBoxColor(Roulette[40], 0);
	TextDrawSetShadow(Roulette[40], 0);
	TextDrawSetOutline(Roulette[40], 0);
	TextDrawBackgroundColor(Roulette[40], 255);
	TextDrawFont(Roulette[40], 1);
	TextDrawSetProportional(Roulette[40], 1);
	TextDrawSetShadow(Roulette[40], 0);
	TextDrawSetSelectable(Roulette[40], true);

	Roulette[41] = TextDrawCreate(237.666946, 111.600112, "box");
	TextDrawLetterSize(Roulette[41], -0.002666, 6.308145);
	TextDrawTextSize(Roulette[41], 265.000000, 30.000000);
	TextDrawAlignment(Roulette[41], 1);
	TextDrawColor(Roulette[41], -1);
	TextDrawUseBox(Roulette[41], 1);
	TextDrawBoxColor(Roulette[41], 0);
	TextDrawSetShadow(Roulette[41], 0);
	TextDrawSetOutline(Roulette[41], 0);
	TextDrawBackgroundColor(Roulette[41], 255);
	TextDrawFont(Roulette[41], 1);
	TextDrawSetProportional(Roulette[41], 1);
	TextDrawSetShadow(Roulette[41], 0);
	TextDrawSetSelectable(Roulette[41], true);

	Roulette[42] = TextDrawCreate(235.666961, 211.155639, "box");
	TextDrawLetterSize(Roulette[42], -0.002666, 6.308145);
	TextDrawTextSize(Roulette[42], 264.000000, 30.000000);
	TextDrawAlignment(Roulette[42], 1);
	TextDrawColor(Roulette[42], -1);
	TextDrawUseBox(Roulette[42], 1);
	TextDrawBoxColor(Roulette[42], 0);
	TextDrawSetShadow(Roulette[42], 0);
	TextDrawSetOutline(Roulette[42], 0);
	TextDrawBackgroundColor(Roulette[42], 255);
	TextDrawFont(Roulette[42], 1);
	TextDrawSetProportional(Roulette[42], 1);
	TextDrawSetShadow(Roulette[42], 0);
	TextDrawSetSelectable(Roulette[42], true);

	Roulette[43] = TextDrawCreate(235.333602, 321.496337, "box");
	TextDrawLetterSize(Roulette[43], -0.002666, 6.308145);
	TextDrawTextSize(Roulette[43], 262.000000, 30.000000);
	TextDrawAlignment(Roulette[43], 1);
	TextDrawColor(Roulette[43], -1);
	TextDrawUseBox(Roulette[43], 1);
	TextDrawBoxColor(Roulette[43], 0);
	TextDrawSetShadow(Roulette[43], 0);
	TextDrawSetOutline(Roulette[43], 0);
	TextDrawBackgroundColor(Roulette[43], 255);
	TextDrawFont(Roulette[43], 1);
	TextDrawSetProportional(Roulette[43], 1);
	TextDrawSetShadow(Roulette[43], 0);
	TextDrawSetSelectable(Roulette[43], true);

	Roulette[44] = TextDrawCreate(194.000198, 96.666748, "box");
	TextDrawLetterSize(Roulette[44], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[44], 222.000000, 20.000000);
	TextDrawAlignment(Roulette[44], 1);
	TextDrawColor(Roulette[44], -1);
	TextDrawUseBox(Roulette[44], 1);
	TextDrawBoxColor(Roulette[44], 0);
	TextDrawSetShadow(Roulette[44], 0);
	TextDrawSetOutline(Roulette[44], 0);
	TextDrawBackgroundColor(Roulette[44], 255);
	TextDrawFont(Roulette[44], 1);
	TextDrawSetProportional(Roulette[44], 1);
	TextDrawSetShadow(Roulette[44], 0);
	TextDrawSetSelectable(Roulette[44], true);

	Roulette[45] = TextDrawCreate(189.000167, 362.562988, "box");
	TextDrawLetterSize(Roulette[45], 0.004666, 3.321481);
	TextDrawTextSize(Roulette[45], 215.000000, 20.000000);
	TextDrawAlignment(Roulette[45], 1);
	TextDrawColor(Roulette[45], -1);
	TextDrawUseBox(Roulette[45], 1);
	TextDrawBoxColor(Roulette[45], 0);
	TextDrawSetShadow(Roulette[45], 0);
	TextDrawSetOutline(Roulette[45], 0);
	TextDrawBackgroundColor(Roulette[45], 255);
	TextDrawFont(Roulette[45], 1);
	TextDrawSetProportional(Roulette[45], 1);
	TextDrawSetShadow(Roulette[45], 0);
	TextDrawSetSelectable(Roulette[45], true);

	Roulette[46] = TextDrawCreate(277.333251, 410.681579, "box");
	TextDrawLetterSize(Roulette[46], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[46], 310.000000, 10.000000);
	TextDrawAlignment(Roulette[46], 1);
	TextDrawColor(Roulette[46], -1);
	TextDrawUseBox(Roulette[46], 1);
	TextDrawBoxColor(Roulette[46], 0);
	TextDrawSetShadow(Roulette[46], 0);
	TextDrawSetOutline(Roulette[46], 0);
	TextDrawBackgroundColor(Roulette[46], 255);
	TextDrawFont(Roulette[46], 1);
	TextDrawSetProportional(Roulette[46], 1);
	TextDrawSetShadow(Roulette[46], 0);
	TextDrawSetSelectable(Roulette[46], true);

	Roulette[47] = TextDrawCreate(323.666595, 410.681579, "box");
	TextDrawLetterSize(Roulette[47], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[47], 356.000000, 10.000000);
	TextDrawAlignment(Roulette[47], 1);
	TextDrawColor(Roulette[47], -1);
	TextDrawUseBox(Roulette[47], 1);
	TextDrawBoxColor(Roulette[47], 0);
	TextDrawSetShadow(Roulette[47], 0);
	TextDrawSetOutline(Roulette[47], 0);
	TextDrawBackgroundColor(Roulette[47], 255);
	TextDrawFont(Roulette[47], 1);
	TextDrawSetProportional(Roulette[47], 1);
	TextDrawSetShadow(Roulette[47], 0);
	TextDrawSetSelectable(Roulette[47], true);

	Roulette[48] = TextDrawCreate(369.666564, 411.096405, "box");
	TextDrawLetterSize(Roulette[48], -0.000666, 1.869629);
	TextDrawTextSize(Roulette[48], 403.000000, 10.000000);
	TextDrawAlignment(Roulette[48], 1);
	TextDrawColor(Roulette[48], -1);
	TextDrawUseBox(Roulette[48], 1);
	TextDrawBoxColor(Roulette[48], 0);
	TextDrawSetShadow(Roulette[48], 0);
	TextDrawSetOutline(Roulette[48], 0);
	TextDrawBackgroundColor(Roulette[48], 255);
	TextDrawFont(Roulette[48], 1);
	TextDrawSetProportional(Roulette[48], 1);
	TextDrawSetShadow(Roulette[48], 0);
	TextDrawSetSelectable(Roulette[48], true);
}

public OnPlayerConnect(playerid) {

	rouletteOption[playerid] = -1;

	rouletteCoins = CreatePlayerTextDraw(playerid, 270.966705, 69.844398, "coins: 500000");
	PlayerTextDrawLetterSize(playerid, rouletteCoins, 0.350000, 1.604148);
	PlayerTextDrawAlignment(playerid, rouletteCoins, 3);
	PlayerTextDrawColor(playerid, rouletteCoins, -1);
	PlayerTextDrawSetShadow(playerid, rouletteCoins, 1);
	PlayerTextDrawSetOutline(playerid, rouletteCoins, 0);
	PlayerTextDrawBackgroundColor(playerid, rouletteCoins, 255);
	PlayerTextDrawFont(playerid, rouletteCoins, 3);
	PlayerTextDrawSetProportional(playerid, rouletteCoins, 1);
	PlayerTextDrawSetShadow(playerid, rouletteCoins, 1);

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if(newkeys & KEY_SECONDARY_ATTACK && GetPlayerInterior(playerid) == 1 && (IsPlayerInRangeOfPoint(playerid, 5, 2235.843261, 1670.907226, 1008.384338)
	|| IsPlayerInRangeOfPoint(playerid, 5, 2242.163574, 1677.167480, 1008.384338) || IsPlayerInRangeOfPoint(playerid, 5, 2229.643554, 1677.167480, 1008.384338))) {

		if(rouletteOption[playerid] == -1) {

			rouletteOption[playerid] = -2;

			SetPlayerCameraPos(playerid, 2236.368896, 1670.870361, 1010.687866);
			SetPlayerCameraLookAt(playerid, 2235.933105, 1670.869995, 1005.706909, CAMERA_CUT);

			TextDrawShowForPlayer(playerid, RouletteTime);

			new str[15];
			format(str, 15, "COINS: %d", playerCoins[playerid]);
			PlayerTextDrawSetString(playerid, rouletteCoins, str);
			PlayerTextDrawShow(playerid, rouletteCoins);

			Iter_Add(inRoulette, playerid);

			SelectTextDraw(playerid, 0x00FF00FF);

			for(new i = 0; i < 49; ++i)
				TextDrawShowForPlayer(playerid, Roulette[i]);
		}
		else if(rouletteOption[playerid] == -2) {

			rouletteOption[playerid] = -1;

			SetCameraBehindPlayer(playerid);
			Iter_Remove(inRoulette, playerid);

			CancelSelectTextDraw(playerid);

			TextDrawHideForPlayer(playerid, RouletteTime);
			PlayerTextDrawHide(playerid, rouletteCoins);

			TextDrawHideForPlayer(playerid, RouletteNumber[0]);	TextDrawHideForPlayer(playerid, RouletteNumber[1]);
			TextDrawHideForPlayer(playerid, RouletteNumber[2]);	TextDrawHideForPlayer(playerid, RouletteNumber[3]);

			for(new i = 0; i < 49; ++i)
				TextDrawHideForPlayer(playerid, Roulette[i]);
		}
	}


	return 1;
}

isInTwelve(number) { //Verific daca e in 1st12, 2nd12, 3rd12

	if(number <= 12)
		return number != 0;

	else if(number <= 24)
		return 2;
	else 
		return 3;

}

CMD:showcoins(playerid) {

	new str[10]; valstr(str, playerCoins[playerid]);
	SendClientMessage(playerid, 0xFFFFFFAA, str);
	return 1;
}


isLowerThan(number) { //Verific daca e in 1-18 sau 19-36

	return number <= 18;
}


checkParity(number) { //Verific paritatea numarului

	return number % 2 == 0;

}

checkColor(number) { //Verific culoarea numarului

	if(number == 0) 
		return 0;

	switch(number) {
		case 1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36:
			return 1;
		default: return 2;
	}

	return 69; //le pun sa nu-mi mai dea warning
}

isInPlace(number) { //Verific daca se afla in 3 to 1, pentru fiecare rand

	if(number % 3 == 0)
		return number != 0;

	for(new i = 1; i <= 12; ++i) {
		if(1 + (i-1) * 3 == number)
			return 2;
		if(2 + (i-1) * 3 == number)
			return 3;
	}

	return 69; //le pun sa nu-mi mai dea warning
}

CMD:gotopos(playerid, params[]) {

	return SetPlayerPos(playerid, 2264.7573,1514.1862,49.8358);
}

CMD:gotopos2(playerid, params[]) {
	return SetPlayerPos(playerid, 2351.7161,1514.2821,49.8358);
}

CMD:god(playerid, params[]) {
	SetPlayerHealth(playerid, 500000);
	return 1;
}

CMD:casino(playerid) {

	return SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 2233.8032,1712.2303,1011.7632);
}

CMD:givecoins(playerid) {
	playerCoins[playerid] = 50000;
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {

	if(clickedid != Text:INVALID_TEXT_DRAW) {
		for(new i = 0; i < 49; ++i)
			if(clickedid == Roulette[i]) {

				if(rouletteOption[playerid] == -2 || rouletteResult >= 1) {

					rouletteOption[playerid] = i;
					return ShowPlayerDialog(playerid, 6996, DIALOG_STYLE_INPUT, betNames[i], "Please insert your amount you want to bet", "Done", "Cancel");
				}
				else return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You already placed a bet or the time has occured.");
			}
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(dialogid == 6996) {

		if(!response) {
			rouletteOption[playerid] = -2;
			return 1;
		}

		if(strval(inputtext) == 0) {
			rouletteOption[playerid] = -2;
			return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Please insert a valid amount(1-3000).");
		}

		if(playerCoins[playerid] < strval(inputtext)) {
			rouletteOption[playerid] = -2;
			return SendClientMessage(playerid, 0xFF0000AA, "ERROR: You don't have that amount of coins.");
		}

		else {

			playerCoins[playerid] -= strval(inputtext);
			betCoins[playerid] += strval(inputtext);

			new str[15];

			format(str, 15, "COINS: %d", playerCoins[playerid]);
			PlayerTextDrawSetString(playerid, rouletteCoins, str);
			PlayerTextDrawShow(playerid, rouletteCoins);

			if(rouletteFirstBet++ == 0) {

				rouletteResult = 60;

				rouletteTimer = SetTimer("RouletteStart", 1000, true);
				foreach(new i: inRoulette)
					SendClientMessage(i, 0xFFFF00AA, "The roullete will start in 60 seconds.");
			}

			SendClientMessage(playerid, 0xFFFFFFAA, "You have succesfully placed your bet!");
		}

	}

	return 1;
}

public RouletteStart() {

	if(--rouletteResult <= 0) {

		KillTimer(rouletteTimer);

		foreach(new i: inRoulette) {

			SendClientMessage(i, 0xFFFF00AA, "The roulette it's about to start");

			TextDrawHideForPlayer(i, RouletteTime);

			for(new j = 0; j < 4; ++j)
				TextDrawShowForPlayer(i, RouletteNumber[j]);
		}

		rouletteFirstBet = randomEx(30, 45);
		
		rouletteTimer = SetTimer("RouletteRolling", 1000, true);
	}
	else {

		new str[50];
		format(str, 50, "Roulette will roll in: %d seconds.", rouletteResult);
		TextDrawSetString(RouletteTime, str);
	}

	return 1;
}


public RouletteRolling() {

	new rand = randomEx(0, 36), result;

	result = checkColor(rand);

	switch(result) {

		case 0: TextDrawBoxColor(RouletteNumber[2], 0x37A50EAA);
		case 1: TextDrawBoxColor(RouletteNumber[2], 0xA52A2AFF);
		case 2: TextDrawBoxColor(RouletteNumber[2], 0x000000FF);
	}

	foreach(new i: inRoulette) 
		TextDrawShowForPlayer(i, RouletteNumber[2]);

	new str[5]; valstr(str, rand);
	TextDrawSetString(RouletteNumber[3], str);

	if(++rouletteResult >= rouletteFirstBet) {

		KillTimer(rouletteTimer);
		rouletteResult = rouletteFirstBet = 0;

		foreach(new i: inRoulette) {

			if(rouletteOption[i] >= 0 && rouletteOption[i] <= 36 && rouletteOption[i] == rand) 
				playerCoins[i] += betCoins[i] * 36,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 37 && result == 1)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 38 && result == 2)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 39 && checkParity(rand) == 1)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 40 && checkParity(rand) == 0)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 41 && isInTwelve(rand) == 1)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 42 && isInTwelve(rand) == 2)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 43 && isInTwelve(rand) == 3)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 44 && isLowerThan(rand) == 1)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 45 && isLowerThan(rand) == 0)
				playerCoins[i] += betCoins[i] * 2,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 46 && isInPlace(rand) == 2)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 47 && isInPlace(rand) == 3)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else if(rouletteOption[i] == 48 && isInPlace(rand) == 1)
				playerCoins[i] += betCoins[i] * 3,
				GameTextForPlayer(i, "~n~~g~~h~Winner!", 3000, 6);
			else {
				GameTextForPlayer(i, "~r~~h~Looser!", 3000, 6);
			}

			new str2[15];

			format(str2, 15, "COINS: %d", playerCoins[i]);
			PlayerTextDrawSetString(i, rouletteCoins, str2);
			PlayerTextDrawShow(i, rouletteCoins);
		}

		SetTimer("getReadyForNextBet", 4000, false);
	}
}

CMD:gotocasino(playerid, params[]) {
	SetPlayerInterior(playerid, 1);
	SetPlayerPos(playerid, 2233.8032,1712.2303,1011.7632);
	return 1;
}

forward getReadyForNextBet();

public getReadyForNextBet() {

	foreach(new i: inRoulette) {

		rouletteOption[i] = -2;
		betCoins[i] = 0;

		for(new j = 0; j < 4; ++j)
			TextDrawHideForPlayer(i, RouletteNumber[j]);

		TextDrawSetString(RouletteTime, "Roulette will roll in: 60 seconds.");
		TextDrawShowForPlayer(i, RouletteTime);
	}
}