//---------------------------------------------------------------------------------------
//  FILE:   KillCounter_UI.uc                                    
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
//
//	USED TO COMPOSE THE PANEL & UPDATE THE PANEL
// 
//---------------------------------------------------------------------------------------
class RustyCounter_UI extends UIPanel; // config (RustyCounter);

var localized string strKilled, strActive, strTotal, strRemaining;

var RustyCounter_Settings Settings;

var UIText Text;
var UITextStyleObject TextStyle;

var int LastKilled_Advent, LastKilled_Lost, LastKilled_FacOne, LastKilled_FacTwo;
var int LastActive_Advent, LastActive_Lost, LastActive_FacOne, LastActive_FacTwo;
var int LastTotal, LastIndex;

// Stolen from UiUtilities_Colors::THELOST_HTML_COLOR as we can't reference that color
// otherwise to stay backward compatible	// >> colours moved to config <<
//const COLOR_LOST = "ACD373";

/////////////////////////////////////////////////////////////////////////////////////////////
//	INIT
/////////////////////////////////////////////////////////////////////////////////////////////
simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);
	SetSize(600, 150);			//size of the box, 600 is plenty wide enough, each line is 50high

	Text = Spawn(class'UIText', self);
	Text.InitText('RustyCounter_Text');
	Text.SetSize(Width, Height);

	class'RustyCounter_Utils'.static.ShadowToTextField(Text);

	TextStyle = class'UIUtilities_Text'.static.GetStyle(eUITextStyle_Tooltip_H2);
	TextStyle.bUseCaps = False;

	// Reset is needed here for a load from Tactical to Tactical as the current instance doesn't get destroyed 
	// - but OnInit is called again, so here's the correct place to wipe all of the state again.
	LastKilled_Advent 	= -1;
	LastKilled_Lost 	= -1;
	LastKilled_FacOne 	= -1;
	LastKilled_FacTwo 	= -1;

	LastActive_Advent 	= -1;
	LastActive_Lost 	= -1;
	LastActive_FacOne 	= -1;
	LastActive_FacTwo 	= -1;

	LastTotal 	= -1;
	LastIndex 	= -1;

	UpdateSettings(new class'RustyCounter_Settings');
	return self;
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	UPDATE INITIAL POSITIONING
/////////////////////////////////////////////////////////////////////////////////////////////
function UpdateSettings(RustyCounter_Settings newSettings)
{
	Settings = newSettings;

	SetAnchor(Settings.BoxAnchor);
	SetPosition(Settings.OffsetX, Settings.OffsetY);
	TextStyle.Alignment = Settings.textAlignment;

	Update();
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	UPDATE UI ELEMENTS
/////////////////////////////////////////////////////////////////////////////////////////////
function Update(optional int historyIndex = LastIndex)
{
	local bool SkipTurrets;
	local int killed_Advent, killed_Lost, killed_FacOne, killed_FacTwo;
	local int active_Advent, active_Lost, active_FacOne, active_FacTwo;
	local int total;

	local UISpecialMissionHUD	UITimers;	//can get both timers from here, cleaner

	////////////////////////////////////
	//	GET Settings
	///////////////////////////////////

	SkipTurrets = Settings.ShouldSkipTurrets();

	class'RustyCounter_Utils'.static.GetCounters(historyIndex, SkipTurrets, killed_Advent, killed_Lost, killed_FacOne, killed_FacTwo, active_Advent, active_Lost, active_FacOne, active_FacTwo, total);

	////////////////////////////////////
	//	ADJUST COUNTERS IF CHANGED
	///////////////////////////////////
	if (	killed_Advent != LastKilled_Advent || killed_Lost != LastKilled_Lost || killed_FacOne != LastKilled_FacOne || killed_FacTwo != LastKilled_FacTwo
		|| 	active_Advent != LastActive_Advent || active_Lost != LastActive_Lost || active_FacOne != LastActive_FacOne || active_FacTwo != LastActive_FacTwo 
		|| 	total != LastTotal || LastIndex == -1)
	{
		//store the new numbers
		LastActive_Advent 	= active_Advent;
		LastActive_Lost 	= active_Lost;
		LastActive_FacOne 	= active_FacOne;
		LastActive_FacTwo 	= active_FacTwo;

		LastKilled_Advent 	= killed_Advent;
		LastKilled_Lost 	= killed_Lost;
		LastKilled_FacOne 	= killed_FacOne;
		LastKilled_FacTwo 	= killed_FacTwo;

		LastTotal = total;
		LastIndex = historyIndex;

		//input the new numbers
		UpdateText(LastKilled_Advent, LastKilled_Lost, LastKilled_FacOne, LastKilled_FacTwo, LastActive_Advent, LastActive_Lost, LastActive_FacOne, LastActive_FacTwo, LastTotal);
	}

	////////////////////////////////////
	//	AUTO ADJUST FOR TIMERS
	///////////////////////////////////
	if (Settings.ShouldAutoAdjust())
	{
		//grab the current mission and evac timers
		UITimers = `PRES.GetSpecialMissionHUD();

		//check for timers
		if(UITimers != none )
		{
			if (UITimers.m_kGenericTurnCounter.bIsVisible)	//turn counter
			{
				if (UITimers.m_kTurnCounter2.bIsVisible)	//evac request
				{
					SetPosition(Settings.OffsetX, Settings.OffsetY +250);	//we have both
				}
				else
				{
					SetPosition(Settings.OffsetX, Settings.OffsetY +150);	//we just turn counter
				}
			}
			else	//we have no timers or just evac counter ... put us back at default
			{
				SetPosition(Settings.OffsetX, Settings.OffsetY);
			}
		}
		else	//we have no timer class ? ... put us back at default
		{
			SetPosition(Settings.OffsetX, Settings.OffsetY);
		}

		///////////////////////////////////
		//	AUTO HIDE IF NARRATIVE MOMENT- DIDN'T QUITE WORK HOW I WANTED
		//	FAILED TO COME 'BACK' UNTIL NEXT UPDATE - IT DOESNT LOOK TOO BAD SHOWN UNDER
		///////////////////////////////////
		//if (Movie.Pres.GetUIComm().bIsVisible){	Hide();	}	else	{	Show();	}

	}//end auto-adjust

}

	////////////////////////////////////
	//	UPDATE TEXT DISPLAYS
	///////////////////////////////////
function UpdateText(int killed_Advent, int killed_Lost, int killed_FacOne, int killed_FacTwo, int active_Advent, int active_Lost, int active_FacOne, int active_FacTwo, int total)
{
	local string Value;
	local int active_Total, killed_Total;

	// BAIL OUT IF WE HAVE NO TEXT TO UPDATE
	if(Text == none)
	{
		return;
	}

	// begin constructing the string, done so we auto shift if active is not shown
	Value = "";

	////////////////////////////////////
	//	ACTIVE COUNTER
	////////////////////////////////////

	//add number of active enemies if set in the config 
	if(Settings.ShouldDrawActiveCount())
	{
		Value $= strActive @ "[";

		//add a 'blank' value if ALL values are 'hidden'
		if (active_Advent == -1 && active_Lost == -1 && active_FacOne == -1 && active_FacTwo == -1)
		{
			Value @= "---";
		}
		else
		{
			//show four individual teams or one combined total
			if (Settings.ShouldShowSplitTeamsActive() && !Settings.noColor)
			{
				//I really dislike in line if's but it makes the code so much easier to read
				if (active_Advent != -1)																		{Value @= AddStrColor(active_Advent, Settings.COLOR_ACTIVE_ADVENT);			}	//red
				
				if (active_Advent != -1 && active_Lost != -1)													{Value @= "|";																}	//linebreak
				if (active_Lost   != -1)																		{Value @= AddStrColor(active_Lost, Settings.COLOR_ACTIVE_LOST);				}	//lost green
				
				if ( (active_Advent != -1 || active_Lost != -1) && active_FacOne != -1)							{Value @= "|";																}	//linebreak
				if (active_FacOne != -1)																		{Value @= AddStrColor(active_FacOne, Settings.COLOR_ACTIVE_FACONE);			}	//purple
				
				if ( (active_Advent != -1 || active_Lost != -1 || active_FacOne != -1) && active_FacTwo != -1)	{Value @= "|";																}	//linebreak
				if (active_FacTwo != -1)																		{Value @= AddStrColor(active_FacTwo, Settings.COLOR_ACTIVE_FACTWO);			}	//yellow
			}
			else
			{
				//I really dislike in line if's but it makes the code so much easier to read
				active_Total = 0;
				if (active_Advent != -1)	{active_Total += active_Advent;	}
				if (active_Lost   != -1)	{active_Total += active_Lost;	}
				if (active_FacOne != -1)	{active_Total += active_FacOne;	}		
				if (active_FacTwo != -1)	{active_Total += active_FacTwo;	}

				Value @= AddStrColor(active_Total, Settings.COLOR_TOTAL_ACTIVE);	//red
			}
		}

		Value @= "]  <br>";
	}

	////////////////////////////////////
	//	KILLED COUNTER
	////////////////////////////////////

	//add Killed:
	Value $= strKilled @ "[";

	//add a 'blank' value if ALL values are 'hidden'
	if (killed_Advent == -1 && killed_Lost == -1 && killed_FacOne == -1 && killed_FacTwo == -1)
	{
		Value @= "---";
	}
	else
	{
		//show four individual teams or one combined total
		if (Settings.ShouldShowSplitTeamsKilled() && !Settings.noColor)
		{
			//I really dislike in line if's but it makes the code so much easier to read
			if (killed_Advent != -1)																		{Value @= AddStrColor(killed_Advent, Settings.COLOR_KILLED_ADVENT);	}	//deep red

			if (killed_Advent != -1 && killed_Lost != -1)													{Value @= "|";														}	//linebreak
			if (killed_Lost   != -1)																		{Value @= AddStrColor(killed_Lost, Settings.COLOR_KILLED_LOST);		}	//deep green

			if ( (killed_Advent != -1 || killed_Lost != -1) && killed_FacOne != -1)							{Value @= "|";														}	//linebreak
			if (killed_FacOne != -1)																		{Value @= AddStrColor(killed_FacOne, Settings.COLOR_KILLED_FACONE);	}	//deep purple

			if ( (killed_Advent != -1 || killed_Lost != -1 || killed_FacOne != -1) && killed_FacTwo != -1)	{Value @= "|"; 														}	//linebreak
			if (killed_FacTwo != -1)																		{Value @= AddStrColor(killed_FacTwo, Settings.COLOR_KILLED_FACTWO);	}	//deep yellow
		}
		else
		{
			//I really dislike in line if's but it makes the code so much easier to read
			killed_Total = 0;
			if (killed_Advent != -1)	{killed_Total += killed_Advent;	}
			if (killed_Lost   != -1)	{killed_Total += killed_Lost;	}
			if (killed_FacOne != -1)	{killed_Total += killed_FacOne;	}		
			if (killed_FacTwo != -1)	{killed_Total += killed_FacTwo;	}

			Value @= AddStrColor(killed_Total, Settings.COLOR_TOTAL_KILLED);	//orange
		}
	}

	Value @= "]  <br>";

	////////////////////////////////////
	//	TOTALS COUNTER
	////////////////////////////////////

	//add Total: or Remaining: based on config options && has a shadow chamber built or location scout sitrep
	if(Settings.ShouldDrawTotalCount())
	{
		//calculate remaining based on total minus killed, show if set in config
		if(Settings.ShouldShowRemainingInsteadOfTotal())
		{
			//I really dislike in line if's but it makes the code so much easier to read
			killed_Total = 0;
			if (killed_Advent != -1)	{killed_Total += killed_Advent;	}
			if (killed_Lost   != -1)	{killed_Total += killed_Lost;	}
			if (killed_FacOne != -1)	{killed_Total += killed_FacOne;	}		
			if (killed_FacTwo != -1)	{killed_Total += killed_FacTwo;	}

			total = total -killed_Total;

			Value $= strRemaining @ "[";
		}
		else
		{
			Value $= strTotal @ "[";
		}

		//add a 'blank' value if total is 'hidden' ??
		if (total == -1)
		{
			Value @= "--- ]  ";
		}
		else
		{
			Value @= AddStrColor(total, Settings.COLOR_TOTAL_REMAIN) @ "]  "; //green
		}
	}

	////////////////////////////////////
	//	SET FINAL COUNTER
	////////////////////////////////////

	//actually set the text to the constructed string
	//	Active: [ a | l | f | t ]		Active: [---] 		Active: [x] 
	//	Killed: [ a | l | f | t ] 		Killed: [---] 		Killed: [y]
	//	   Total/Remaining: [ x ]    Remaining: [---]    Remaining: [z]

	Text.SetHtmlText(class'UIUtilities_Text'.static.ApplyStyle(Value, TextStyle));
}

/////////////////////////////////////////////////////////////////////////////////////////////
//	COLOUR CONTROL FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////
function string AddStrColor(int value, string clr)
{
	if(Settings.noColor)
	{
		return string(value);
	}

	return "<font color='#" $ clr $ "'>" $ string(value) $ "</font>";
}

/////////////////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	LastKilled_Advent = -1;
	LastKilled_Lost   = -1;
	LastKilled_FacOne = -1;
	LastKilled_FacTwo = -1;

	LastActive_Advent = -1;
	LastActive_Lost   = -1;
	LastActive_FacOne = -1;
	LastActive_FacTwo = -1;

	LastTotal = -1;
	LastIndex = -1;
}
