//---------------------------------------------------------------------------------------
//  FILE:   KillCounter.uc                                    
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
// 
//	USED TO CREATE THE KILL COUNTER ON THE SCREEN
//
//---------------------------------------------------------------------------------------
class RustyCounter extends UIScreenListener implements(X2VisualizationMgrObserverInterface);

var int LastRealizedIndex;

//on screen init
event OnInit(UIScreen Screen)
{	
	// LastRealizedIndex can't be just set to `defaults.LastRealizedIndex`
	// Having -1 hardcoded solves any "the UI doesn't update" issues I have seen so far.
	LastRealizedIndex = -1;

	RegisterEvents();

	// A call to GetUI will initialize the UI if it isn't already. This
	// fixes a bug where the UI isn't shown after a savegame load in tactical.
	class'RustyCounter_Utils'.static.GetUI();
}

//on screen removed
event OnRemoved(UIScreen Screen)
{
	UnregisterEvents();
	DestroyUI();
}

event OnVisualizationBlockComplete(XComGameState AssociatedGameState)
{
	local int index;
	index = `XCOMVISUALIZATIONMGR.LastStateHistoryVisualized;

	if(index > LastRealizedIndex)
	{
		UpdateUI(index);
		LastRealizedIndex = index;
	}
}

event OnVisualizationIdle();

event OnActiveUnitChanged(XComGameState_Unit NewActiveUnit);

//make the visualation manager register this screen for updates
function RegisterEvents()
{
	`XCOMVISUALIZATIONMGR.RegisterObserver(self);
}

function UnregisterEvents()
{
	`XCOMVISUALIZATIONMGR.RemoveObserver(self);
}

//remove the KC screen
function DestroyUI()
{
	local RustyCounter_UI ui;
	ui = class'RustyCounter_Utils'.static.GetUI();
	if(ui != none)
	{
		ui.Remove();
	}

	return;
}

//update the KC screen
function UpdateUI(int historyIndex)
{
	local RustyCounter_UI ui;
	ui = class'RustyCounter_Utils'.static.GetUI(); 
	if(ui != none)
	{
		ui.Update(historyIndex);
	}

	return;
}

///////////////////////////////////////////////////////////////////////////////////////
//make this only works on the tactical HUD

defaultproperties
{
	ScreenClass = class'UITacticalHUD';
	LastRealizedIndex = -1;
}
