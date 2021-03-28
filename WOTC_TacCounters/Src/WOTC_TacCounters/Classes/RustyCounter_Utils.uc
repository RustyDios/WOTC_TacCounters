//---------------------------------------------------------------------------------------
//  FILE:   KillCounter_UTILS.uc                                    
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
//  
//	VARIOUS FUNCTIONS USED TO MANAGE THE KILL COUNTER UI
//
//---------------------------------------------------------------------------------------
class RustyCounter_Utils extends Object;

// As we want to be backward compatible, we can't use eTeam_TheLost directly.
// The value is defined in the Object.uc, with the value 32. This shouldn't ever
// change (*cough* famous last words)
//const TeamTheLost = 32;
// >> not making it backwards compatible anymore ... WOTC CHL specific <<

/////////////////////////////////////////////////////////////////////////////////////////////
//	GET THE CURRENT ACTIVE UI PANEL
/////////////////////////////////////////////////////////////////////////////////////////////
static function RustyCounter_UI GetUI()
{
	local UIScreen hud;
	local RustyCounter_UI ui;

	hud = `PRES.GetTacticalHUD();
	if (hud == none)
	{
		return none;
	}

	ui = RustyCounter_UI(hud.GetChild('RustyCounter_UI'));
	if(ui == none)
	{
		ui = hud.Spawn(class'RustyCounter_UI', hud);
		ui.InitPanel('RustyCounter_UI');
	}

	return ui;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	CHECK FOR SHADOW CHAMBER TO SHOW REMAINING OR TOTAL
/////////////////////////////////////////////////////////////////////////////////////////////
static function bool IsShadowChamberBuilt()
{
	local XComGameState_HeadquartersXCom XComHQ;

	// RETURNS TRUE IF BUILT, FALSE IF NOT BUILT
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	if (XComHQ != none)
	{
		if (XComHQ.GetFacilityByName('ShadowChamber') != none)
		{
			return true;
		}
	}

	return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	CHECK FOR LOCATION SCOUT SITREP
/////////////////////////////////////////////////////////////////////////////////////////////
static function bool IsMissionSitRep_LocationScout()
{
	local XComGameState_BattleData BattleState;

	// RETURNS TRUE IF IN BATTLE && THE SITREP IS ACTIVE
	BattleState = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if (BattleState != none)
	{
		if (BattleState.ActiveSitReps.Find('LocationScout') != INDEX_NONE)
		{
			return true;
		}
	}

	return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	COUNT ALL ENEMY UNITS FOR EACH TEAM
/////////////////////////////////////////////////////////////////////////////////////////////
static function GetCounters(int historyIndex, bool skipTurrets, out int killed_Advent, out int killed_Lost, out int killed_FacOne, out int killed_FacTwo, 
																out int active_Advent, out int active_Lost, out int active_FacOne, out int active_FacTwo, out int total)
{
	local XComGameState_Unit UnitState;
	local array <XComGameState_Unit> arrUnits, arrTotalUnits;
	local array <name> TemplatesToCheck;
	local int i, iPrevSeen, iPrevKilled;

	//  Teams initialized to -1 as it's used as an draw indicator in the UI; 
	//	if it stays -1 than there's no point in drawing the extra counter as it will never show anything 
	//	(as it won't in XCOM2 VANILLA or in WOTC missions where the Teams aren't present).
	active_Advent 	= -1;
	active_Lost 	= -1;
	active_FacOne 	= -1;
	active_FacTwo 	= -1;
	
	killed_Advent 	= -1;
	killed_Lost 	= -1;
	killed_FacOne 	= -1;
	killed_FacTwo 	= -1;

	arrUnits.length = 0;
	arrTotalUnits.length = 0;

	TemplatesToCheck = class'RustyCounter_Settings_Defaults'.default.NotAValidEnemy_TemplateName;

	//get all active units states
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		// skip if unit is non-selectable (mimic beacon) or cosmectic (gremlin) or turret with skip turrets or on the excluded list 
        if (UnitState.GetMyTemplate().bNeverSelectable || UnitState.GetMyTemplate().bIsCosmetic || (UnitState.IsTurret() && SkipTurrets) 
			|| (TemplatesToCheck.Find(UnitState.GetMyTemplateName()) != INDEX_NONE) )
        {
			continue;
		}

		//else it was a 'valid' unit add it to the list
		arrUnits.AddItem(UnitState);
	}

	//go over the list and do counts for each team
	for( i = 0; i < arrUnits.length ; i++)
	{
		UnitState = arrUnits[i];

		//ADD TO SEPARATE COUNTERS FOR EACH TEAM
		switch (UnitState.GetTeam())
		{
			case eTeam_Alien:	IncreaseTeamCounts(historyIndex, UnitState, active_Advent, 	killed_Advent, 	total);	arrTotalUnits.AddItem(UnitState);	break;
			case eTeam_TheLost:	IncreaseTeamCounts(historyIndex, UnitState, active_Lost, 	killed_Lost, 	total);	arrTotalUnits.AddItem(UnitState);	break;
			case eTeam_One:		IncreaseTeamCounts(historyIndex, UnitState, active_FacOne, 	killed_FacOne, 	total);	arrTotalUnits.AddItem(UnitState);	break;
			case eTeam_Two:		IncreaseTeamCounts(historyIndex, UnitState, active_FacTwo, 	killed_FacTwo, 	total);	arrTotalUnits.AddItem(UnitState);	break;
			//case eTeam_None:			THIS IS NORMALLY CHOSEN OR RULERS BUT LW HAS SOME ODDBALL UNITS HERE TOO
			//case eTeam_All:			THIS COUNTS EVERYONE, POSSIBLY ?
			//case eTeam_XCom:			THIS IS US. YEAY!
			//case eTeam_Neutral:		SCARED CIVVIES RUNNING FOR THIER LIVES AND YELLING
			//case eTeam_Resistance:	THE -OTHER- GOOD GUYS. WOO HOO!
			default:			
				break;					//FUCK KNOWS WHAT TEAM, SOMETHINGS GONE HORRIBLY WRONG
		}
	}

	//RUNNING TOTAL COUNTER CHECK
	if (total != arrTotalUnits.length)
	{
		total = arrTotalUnits.length;
	}

	//PULL INFORMATION FROM A TACTICAL TO TACTICAL TRANSFER
	if(GetTransferMissionStats(iPrevSeen, iPrevKilled))
	{
		total += iPrevSeen;
		killed_Advent += iPrevKilled;
	}
}

//increase the counts includes an offset for -1 'invis' to 'correctly zero' for accurate reports
static function IncreaseTeamCounts(int historyIndex, XComGameState_Unit UnitState, out int active, out int killed, out int total)
{
	if (UnitState.IsAlive() && !UnitState.bRemovedFromPlay)			//alive and in play
	{	
		if (GetActiveState(historyIndex, UnitState))
		{
			if (active == -1) {active++;} 	active++;
		}
	}
	else if (UnitState.IsDead() || UnitState.bRemovedFromPlay )		//dead or removed
	{	
		if (killed == -1) {killed++;} 	killed++; 
	}

	//total counts everything as we minus the killed for remaining
	total++;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	FIND OUT IF UNITS ARE 'ACTIVE'
/////////////////////////////////////////////////////////////////////////////////////////////
static function bool GetActiveState(int historyIndex, XComGameState_Unit UnitState)
{
	local int AlertLevel, DataID;
	local XComGameState_AIUnitData AIData;
	local StateObjectReference KnowledgeRef;
	
	//FIND OUT IF THE UNIT IS ACTIVE
	AlertLevel = UnitState.GetCurrentStat(eStat_AlertLevel);
	if(AlertLevel == `ALERT_LEVEL_RED)
	{
		return true;	//RED ALERT ACTIVE
	}
	else if (AlertLevel == `ALERT_LEVEL_YELLOW)
	{
		DataID = UnitState.GetAIUnitDataID();
		if( DataID > 0 )
		{
			AIData = XComGameState_AIUnitData(`XCOMHISTORY.GetGameStateForObjectID(DataID, eReturnType_Reference, historyIndex));
			if( AIData != none && AIData.HasAbsoluteKnowledge(KnowledgeRef) )  
			{
				return true;	//YELLOW ALERT ACTIVE && KNOWS WHERE XCOM ARE
			}
		}
	}

	return false;		//GREEN ALERT OR NOT ACTIVE
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	GET NUMBERS FOR A TACTICAL TO TACTICAL TRANSFER
//	BASEGAME HAS ISSUES THAT IT CANNOT CARRY OVER THE FACTION TEAM COUNTS !!
/////////////////////////////////////////////////////////////////////////////////////////////
static function bool GetTransferMissionStats(out int seen, out int killed)
{
	local XComGameState_BattleData BattleData;
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if(BattleData.DirectTransferInfo.IsDirectMissionTransfer)
	{
		seen = BattleData.DirectTransferInfo.AliensSeen;
		killed = BattleData.DirectTransferInfo.AliensKilled;
		return true;
	}
	
	seen = 0;
	killed = 0;
	return false;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	HANDLE DISPLAY OF THE UI	DISPLAY THE TEXT	OUTLINE THE TEXT	SHADOW THE TEXT
// 	This is a UnrealScript translation from the original ActionScript function. 
//	From Components.SwfMoview within 'scripts/__Packages/Utilities', located in gfxComponents.upk.
// 	Usage: Call this with your UIText element AFTER you've called InitText() on it!
/////////////////////////////////////////////////////////////////////////////////////////////

static function ShadowToTextField(UIText panel)
{
	local string path;
	local UIMovie mov;
	path = string(panel.MCPath) $ ".text";
	mov = panel.Movie;

	mov.SetVariableString(path $ ".shadowStyle", "s{0,0}{0,0){0,0}t{0,0}");
	mov.SetVariableNumber(path $ ".shadowColor", 0);
	mov.SetVariableNumber(path $ ".shadowBlurX", 3);
	mov.SetVariableNumber(path $ ".shadowBlurY", 3);
	mov.SetVariableNumber(path $ ".shadowStrength", 15);
	mov.SetVariableNumber(path $ ".shadowAngle", 0);
	mov.SetVariableNumber(path $ ".shadowAlpha", 0.25);
	mov.SetVariableNumber(path $ ".shadowDistance", 0);
}

static function OutlineTextField(UIText panel, int thickness)
{
	local string path;
	local UIMovie mov;
	path = string(panel.MCPath) $ ".text";
	mov = panel.Movie;

	mov.SetVariableString(path $ ".shadowStyle", "s{" $ thickness $ ",0}{0," $ 
		thickness $ "}{" $ thickness $ "," $ thickness $ "}{" $ -1 * thickness $
		",0}{0," $ -1 * thickness $ "}{" $ -1 * thickness $ "," $ -1 * thickness $
		"}{" $ thickness $ "," $ -1 * thickness $ "}{" $ -1 * thickness $ ","
		$ thickness $ "}t{0,0}");
	mov.SetVariableNumber(path $ ".shadowColor", 3552822);
	mov.SetVariableNumber(path $ ".shadowBlurX", 1);
	mov.SetVariableNumber(path $ ".shadowBlurY", 1);
	mov.SetVariableNumber(path $ ".shadowStrength", thickness);
	mov.SetVariableNumber(path $ ".shadowAngle", 0);
	mov.SetVariableNumber(path $ ".shadowAlpha", 0.5);
	mov.SetVariableNumber(path $ ".shadowDistance", 0);
}

// Used to find the above values. Kind of a mess, but does the job...
static function TestValueOnPanel(UIPanel panel, string prop)
{
	local ASValue val;
	local string fullpath;

	fullpath = string(panel.MCPath) $ "." $ prop;
	val = panel.Movie.GetVariable(fullpath);

	`LOG("Path:" @ fullpath, false, 'RustyCounter_Rusty');

	if(val.Type == AS_Undefined)
	{
		`LOG("Type:" @ val.Type, false, 'RustyCounter_Rusty');
	}
	else if (val.Type == AS_Null)
	{
		`LOG("Type:" @ val.Type, false, 'RustyCounter_Rusty');
	}
	else if (val.Type == AS_Boolean)
	{
		`LOG("Type:" @ val.Type @ "Value:" @ val.b, false, 'RustyCounter_Rusty');
	}
	else if (val.Type == AS_Number)
	{
		`LOG("Type:" @ val.Type @ "Value:" @ val.n, false, 'RustyCounter_Rusty');
	}
	else if (val.Type == AS_String)
	{
		`LOG("Type:" @ val.Type @ "Value:" @ val.s, false, 'RustyCounter_Rusty');
	}
}
