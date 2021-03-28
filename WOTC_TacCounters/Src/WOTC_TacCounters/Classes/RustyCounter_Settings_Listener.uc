//---------------------------------------------------------------------------------------
//  FILE:   KillCounter.uc MCM SETTINGS UISL                                  
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
//  
//---------------------------------------------------------------------------------------
class RustyCounter_Settings_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local RustyCounter_Settings Settings;

	/* //MrNiceUK MCM handler
	if (ScreenClass == none)
	{
		if (MCM_API(Screen) != none)	{	ScreenClass=Screen.Class;	}
		else	{			return;		}
	}

    Settings = new class'RustyCounter_Settings';
    Settings.OnInit(Screen);
	*/

    if (MCM_API(Screen) != none || UIShell(Screen) != none)
    {
        Settings = new class'RustyCounter_Settings';
        Settings.OnInit(Screen);
    }
}

defaultproperties
{
    ScreenClass = none;
}