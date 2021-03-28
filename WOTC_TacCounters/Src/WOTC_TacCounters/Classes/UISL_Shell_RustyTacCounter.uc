//---------------------------------------------------------------------------------------
//  FILE:   UISL Config Warning.uc                                    
//           
//	ORIGINAL CREATED BY SHIREMCT
//	BEGIN EDITS BY RUSTYDIOS	21/02/21	03:00
//	LAST EDITED BY RUSTYDIOS	27/03/21	11:30
// 
//		!!	DONT FORGET TO ACTUALLY UPDATE THE CONFIG NUMBER ON UPDATES	!!
//	EACH MOD SHOULD HAVE UNIQUE CLASS_NAME AND CONFIG FILE
//	ALSO A LOCALIZATION\MODNAME.INT WITH THE STRINGS UNDER THE HEADER [CLASS_NAME]
//
//---------------------------------------------------------------------------------------
class UISL_Shell_RustyTacCounter extends UIScreenListener config(RustyCounter_Version);

var config int			iVERSION;
var int					iVersion_Installed;

var localized string	strMessage_Title, strMessage_Header, strMessage_Body, strDismiss_Button;

var UIBGBox 		WarningPanelBG;
var UIPanel 		WarningPanel;
var UIImage			WarningImage;
var UIX2PanelHeader WarningTitle;
var UITextContainer WarningHeader, WarningBody;
var UIButton		DismissButton;

event OnInit(UIScreen Screen)
{
	// DO WE CREATE THIS OR NOT, YES TO FIRST WARNING = 0, YES TO TESTING = -1, YES TO EACH UPDATE = NEW > OLD
	if(ShouldShowWarningMsg())
	{
		CreatePanel_ConfigWarning(Screen);
	}

	return;
}

simulated function  CreatePanel_ConfigWarning(UIScreen Screen)
{
	local int X, Y, W, H;

 	// pos x, 	pos y , 	width, 		height
	X = 500;	Y = 300;	W = 800;	H = 420;

	// CREATE A PANEL WITH A BACKGROUND PANEL AND LITTLE IMAGE
	WarningPanelBG = Screen.Spawn(class'UIBGBox', Screen);
	WarningPanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	WarningPanelBG.InitBG('ConfigPopup_BG', X, Y, W, H);

	WarningPanel = Screen.Spawn(class'UIPanel', Screen);
	WarningPanel.InitPanel('ConfigPopup');
	WarningPanel.SetSize(WarningPanelBG.Width, WarningPanelBG.Height);		//800, 420
	WarningPanel.SetPosition(WarningPanelBG.X, WarningPanelBG.Y);			//500, 300

	WarningImage = Screen.Spawn(class'UIImage', Screen);
	WarningImage.InitImage(, "img:///UILibrary_Common.TargetIcons.Hack_satelite_icon");
	WarningImage.SetScale(1.0);
	WarningImage.SetPosition(WarningPanelBG.X + WarningPanelBG.Width - 90, WarningPanelBG.Y + 20);

	// CREATE A TITLE, COOL ONE WITH THE HAZARD BAR
	WarningTitle = Screen.Spawn(class'UIX2PanelHeader', WarningPanel);
	WarningTitle.InitPanelHeader('', class'UIUtilities_Text'.static.GetColoredText(strMessage_Title, eUIState_Bad, 32), "");	//red
    WarningTitle.SetPosition(WarningTitle.X + 10, WarningTitle.Y + 10);		//510, 310
    WarningTitle.SetHeaderWidth(WarningPanel.Width - 20);					//780

	// CREATE A ONE LINE HEADER
	WarningHeader = Screen.Spawn(class'UITextContainer', WarningPanel);
	WarningHeader.InitTextContainer();
	WarningHeader.bAutoScroll = true;
	WarningHeader.SetSize(WarningPanelBG.Width - 40, 30); 					//760, 30
	WarningHeader.SetPosition(WarningHeader.X + 20, WarningHeader.Y +60);	//520, 360

	WarningHeader.Text.SetHTMLText( class'UIUtilities_Text'.static.StyleText(strMessage_Header, eUITextStyle_Tooltip_H1, eUIState_Warning2));	//orange
	
	// CREATE THE ACTUAL MESSAGE
	WarningBody = Screen.Spawn(class'UITextContainer', WarningPanel);
	WarningBody.InitTextContainer();
	WarningBody.bAutoScroll = true;
	WarningBody.SetSize(WarningPanelBG.Width - 40, WarningPanelBG.Height - 150);	//760, 270
	WarningBody.SetPosition(WarningBody.X +20, WarningBody.Y + 90);					//520, 390

	WarningBody.Text.SetHTMLText( class'UIUtilities_Text'.static.StyleText(strMessage_Body, eUITextStyle_Tooltip_Body, eUIState_Normal));	//cyan
    WarningBody.Text.SetHeight(WarningBody.Text.Height * 3.0f);                   

	// CREATE A DISMISS BUTTON
	DismissButton = Screen.Spawn(class'UIButton', WarningPanel);
	DismissButton.InitButton('DismissButton', strDismiss_Button, DismissButtonHandler, );
	DismissButton.SetSize(760, 30); 
	DismissButton.SetResizeToText(true);
	DismissButton.AnchorTopCenter();			//AUTO
	DismissButton.OriginTopCenter();			//AUTO
	DismissButton.SetPosition(DismissButton.X - 60, WarningPanelBG.Y +375);
}

// CLEAR EVERYTHING ON BUTTON PRESS
simulated function DismissButtonHandler(UIButton Button)
{
	DismissButton.Remove();

	WarningBody.Remove();
	WarningHeader.Remove();
	WarningTitle.Remove();
	WarningImage.Remove();
	WarningPanel.Remove();
	WarningPanelBG.Remove();
}

// SHOULD WE DISPLAY THE POPUP BASED ON CONFIG NUMBER
static function bool ShouldShowWarningMsg()
{
	// Show it because the version number is set to negative (testing)... 
	if (default.iVersion_Installed <= -1)
	{	
		return true; 
	}

	// Show it this first time because it's the first version that establishes the version numbers
	if (default.iVERSION == 0 )
	{	
		default.iVersion = default.iVersion_Installed;
		StaticSaveConfig();
		return true; 
	}

	// Older version detected - Show update warning
	if (default.iVERSION < default.iVersion_Installed)
	{	
		default.iVersion = default.iVersion_Installed;
		StaticSaveConfig();
		return true;
	}

	// Same version, backup config save - Don't display
	default.iVersion = default.iVersion_Installed;
	StaticSaveConfig();
	return false;
}

// DONT FORGET TO ACTUALLY UPDATE THE CONFIG NUMBER ON UPDATES
// DO THIS IS ONLY ON THE FINAL SHELL - MAIN MENU SCREEN IN REVIEW MODE
defaultproperties
{
	ScreenClass = UIFinalShell;
	iVersion_Installed = 5;
}
