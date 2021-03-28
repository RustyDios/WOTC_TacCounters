//---------------------------------------------------------------------------------------
//  FILE:   KillCounter.uc MCM SETTINGS                                   
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
//  
//---------------------------------------------------------------------------------------
class RustyCounter_Settings extends Object config(RustyCounter);

`include(WOTC_TacCounters/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTC_TacCounters/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var localized string Group1_Label, Group2_Label;

var localized string BoxAnchor_Label, OffsetX_Label, OffsetY_Label;
var localized string alwaysShowActiveEnemyCount_Label, showSplitTeamsActive_Label, showSplitTeamsKilled_Label;
var localized string neverShowEnemyTotal_Label, alwaysShowEnemyTotal_Label, locationScoutShowsTotal_Label, showRemainingInsteadOfTotal_Label;
var localized string includeTurrets_Label, noColor_Label, autoAdjust_Label, textAlignment_Label;

var localized string BoxAnchor_Tooltip, OffsetX_Tooltip, OffsetY_Tooltip;
var localized string alwaysShowActiveEnemyCount_Tooltip, showSplitTeamsActive_Tooltip, showSplitTeamsKilled_Tooltip;
var localized string neverShowEnemyTotal_Tooltip, alwaysShowEnemyTotal_Tooltip, locationScoutShowsTotal_Tooltip, showRemainingInsteadOfTotal_Tooltip;
var localized string includeTurrets_Tooltip, noColor_Tooltip, autoAdjust_Tooltip, textAlignment_Tooltip;

var config int CONFIG_VERSION, BoxAnchor, OffsetX, OffsetY;
var config bool alwaysShowActiveEnemyCount, showSplitTeamsActive, showSplitTeamsKilled;
var config bool neverShowEnemyTotal, alwaysShowEnemyTotal, locationScoutShowsTotal, showRemainingInsteadOfTotal;
var config bool includeTurrets, noColor, autoAdjust;
var config string textAlignment;

var config string COLOR_ACTIVE_ADVENT, COLOR_ACTIVE_LOST, COLOR_ACTIVE_FACONE, COLOR_ACTIVE_FACTWO;
var config string COLOR_KILLED_ADVENT, COLOR_KILLED_LOST, COLOR_KILLED_FACONE, COLOR_KILLED_FACTWO;	
var config string COLOR_TOTAL_ACTIVE, COLOR_TOTAL_KILLED, COLOR_TOTAL_REMAIN;

var config array<name> NotAValidEnemy_TemplateName;

var MCM_API_Checkbox alwaysShowActiveEnemyCount_Checkbox, showSplitTeamsActive_Checkbox, showSplitTeamsKilled_Checkbox;
var MCM_API_Checkbox neverShowEnemyTotal_Checkbox, alwaysShowEnemyTotal_Checkbox, locationScoutShowsTotal_Checkbox, showRemainingInsteadOfTotal_Checkbox;
var MCM_API_Checkbox includeTurrets_Checkbox, noColor_Checkbox, autoAdjust_Checkbox;

var MCM_API_Dropdown textAlignment_Dropdown;
var MCM_API_Slider BoxAnchor_Slider, OffsetX_Slider, OffsetY_Slider;

`MCM_CH_VersionChecker(class'RustyCounter_Settings_Defaults'.default.CONFIG_VERSION, CONFIG_VERSION)

// INIT MCM STUFFS
function OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);

	// Ensure that the default config is loaded if necessary, in the UIShell
	if (CONFIG_VERSION == 0) 
	{
		LoadSavedSettings();
		SaveButtonClicked(none);
	}
}

// CREATE PAGE WHEN TICKED
simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group1, Group2;

	local array<string> textAlignmentOptions;
    
	textAlignmentOptions.addItem("LEFT");
	textAlignmentOptions.addItem("CENTER");
	textAlignmentOptions.addItem("RIGHT");
	
    LoadSavedSettings();
    
	// PAGE BUTTON AND TITLE
    Page = ConfigAPI.NewSettingsPage("Kill Counter Redux");
    Page.SetPageTitle("Kill Counter Redux");

	// PAGE SAVE AND RESET BUTTONS
	Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);
    
	////////////////////////////////////////////////////////////////////////////////////////////
	//	IDEALLY THE STRINGS BELOW SHOULD ALL BE LOCALISED ... 
	///////////////////////////////////////////////////////////////////////////////////////////

		// ---------------------------- General Settings ----------------------------- //

    Group1 = Page.AddGroup('Group1', Group1_Label);

	alwaysShowActiveEnemyCount_Checkbox	 = Group1.AddCheckbox('alwaysShowActiveEnemyCount',	alwaysShowActiveEnemyCount_Label, alwaysShowActiveEnemyCount_Tooltip, alwaysShowActiveEnemyCount, alwaysShowActiveEnemyCountSaveHandler);
	showSplitTeamsActive_Checkbox 		 = Group1.AddCheckbox('showSplitTeamsActive', showSplitTeamsActive_Label, showSplitTeamsActive_Tooltip, showSplitTeamsActive, showSplitTeamsActiveSaveHandler);
	showSplitTeamsKilled_Checkbox 		 = Group1.AddCheckbox('showSplitTeamsKilled', showSplitTeamsKilled_Label, showSplitTeamsKilled_Tooltip, showSplitTeamsKilled, showSplitTeamsKilledSaveHandler);
	neverShowEnemyTotal_Checkbox 		 = Group1.AddCheckbox('neverShowEnemyTotal', neverShowEnemyTotal_Label, neverShowEnemyTotal_Tooltip, neverShowEnemyTotal, neverShowEnemyTotalSaveHandler);
	alwaysShowEnemyTotal_Checkbox 		 = Group1.AddCheckbox('alwaysShowEnemyTotal', alwaysShowEnemyTotal_Label, alwaysShowEnemyTotal_Tooltip, alwaysShowEnemyTotal, alwaysShowEnemyTotalSaveHandler);
	locationScoutShowsTotal_Checkbox 	 = Group1.AddCheckbox('locationScoutShowsTotal', locationScoutShowsTotal_Label, locationScoutShowsTotal_Tooltip, locationScoutShowsTotal, locationScoutShowsTotalSaveHandler);
	showRemainingInsteadOfTotal_Checkbox = Group1.AddCheckbox('showRemainingInsteadOfTotal', showRemainingInsteadOfTotal_Label, showRemainingInsteadOfTotal_Tooltip, showRemainingInsteadOfTotal, showRemainingInsteadOfTotalSaveHandler);
	includeTurrets_Checkbox 			 = Group1.AddCheckbox('includeTurrets', includeTurrets_Label, includeTurrets_Tooltip, includeTurrets, includeTurretsSaveHandler);

		// ---------------------------- UI Settings ----------------------------- //

	Group2 = Page.AddGroup('Group2', Group2_Label);
    
	noColor_Checkbox 		= Group2.AddCheckbox('noColor', noColor_Label, noColor_Tooltip, noColor, noColorSaveHandler);
	textAlignment_Dropdown 	= Group2.AddDropdown('textAlignment', textAlignment_Label, textAlignment_Tooltip, textAlignmentOptions, textAlignment, textAlignmentSaveHandler);
	autoAdjust_Checkbox 	= Group2.AddCheckbox('autoAdjust', autoAdjust_Label, autoAdjust_Tooltip, autoAdjust, autoAdjustSaveHandler);
	BoxAnchor_Slider 		= Group2.AddSlider('BoxAnchor', BoxAnchor_Label, BoxAnchor_Tooltip, 0, 9, 1, BoxAnchor, BoxAnchorSaveHandler);	//slider values are min, max, step
	OffsetX_Slider 			= Group2.AddSlider('OffsetX', OffsetX_Label, OffsetX_Tooltip, -1000, 1000, 1, OffsetX, OffsetXSaveHandler);		//slider values are min, max, step
	OffsetY_Slider 			= Group2.AddSlider('OffsetY', OffsetY_Label, OffsetY_Tooltip, -1000, 1000, 1, OffsetY, OffsetYSaveHandler);		//slider values are min, max, step

	
    Page.ShowSettings();
}

// HANDLE SAVING THE SETTINGS
`MCM_API_BasicCheckboxSaveHandler(alwaysShowActiveEnemyCountSaveHandler, alwaysShowActiveEnemyCount)
`MCM_API_BasicCheckboxSaveHandler(showSplitTeamsActiveSaveHandler, showSplitTeamsActive)
`MCM_API_BasicCheckboxSaveHandler(showSplitTeamsKilledSaveHandler, ShowSplitTeamsKilled)
`MCM_API_BasicCheckboxSaveHandler(neverShowEnemyTotalSaveHandler, neverShowEnemyTotal)
`MCM_API_BasicCheckboxSaveHandler(alwaysShowEnemyTotalSaveHandler, alwaysShowEnemyTotal)
`MCM_API_BasicCheckboxSaveHandler(locationScoutShowsTotalSaveHandler, locationScoutShowsTotal)
`MCM_API_BasicCheckboxSaveHandler(showRemainingInsteadOfTotalSaveHandler, showRemainingInsteadOfTotal)
`MCM_API_BasicCheckboxSaveHandler(includeTurretsSaveHandler, includeTurrets)

`MCM_API_BasicCheckboxSaveHandler(noColorSaveHandler, noColor)
`MCM_API_BasicDropDownSaveHandler(textAlignmentSaveHandler, textAlignment)
`MCM_API_BasicCheckboxSaveHandler(autoAdjustSaveHandler, autoAdjust)
`MCM_API_BasicSliderSaveHandler(BoxAnchorSaveHandler, BoxAnchor)
`MCM_API_BasicSliderSaveHandler(OffsetXSaveHandler, OffsetX)
`MCM_API_BasicSliderSaveHandler(OffsetYSaveHandler, OffsetY)

// HANDLE LOADING/COPYING THE DEFAULT SETTINGS
simulated function LoadSavedSettings()
{
	alwaysShowActiveEnemyCount 	= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.alwaysShowActiveEnemyCount, alwaysShowActiveEnemyCount);
	showSplitTeamsActive		= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.showSplitTeamsActive, showSplitTeamsActive);
	showSplitTeamsKilled		= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.showSplitTeamsKilled, showSplitTeamsKilled);
    neverShowEnemyTotal 		= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.neverShowEnemyTotal, neverShowEnemyTotal);
	alwaysShowEnemyTotal 		= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.alwaysShowEnemyTotal, alwaysShowEnemyTotal);
	locationScoutShowsTotal		= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.locationScoutShowsTotal, locationScoutShowsTotal);
	showRemainingInsteadOfTotal = `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.showRemainingInsteadOfTotal, showRemainingInsteadOfTotal);
	includeTurrets 				= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.includeTurrets, includeTurrets);

	noColor 					= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.noColor, noColor);
	textAlignment 				= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.textAlignment, textAlignment);
	autoAdjust 					= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.autoAdjust, autoAdjust);
	BoxAnchor 					= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.BoxAnchor, BoxAnchor);
	OffsetX 					= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.OffsetX, OffsetX);
	OffsetY						= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.OffsetY, OffsetY);

	COLOR_ACTIVE_ADVENT			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_ACTIVE_ADVENT, COLOR_ACTIVE_ADVENT);
	COLOR_ACTIVE_LOST			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_ACTIVE_LOST,   COLOR_ACTIVE_LOST);
	COLOR_ACTIVE_FACONE			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_ACTIVE_FACONE, COLOR_ACTIVE_FACONE);
	COLOR_ACTIVE_FACTWO			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_ACTIVE_FACTWO, COLOR_ACTIVE_FACTWO);
	
	COLOR_KILLED_ADVENT			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_KILLED_ADVENT, COLOR_KILLED_ADVENT);
	COLOR_KILLED_LOST			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_KILLED_LOST,   COLOR_KILLED_LOST);
	COLOR_KILLED_FACONE			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_KILLED_FACONE, COLOR_KILLED_FACONE);
	COLOR_KILLED_FACTWO			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_KILLED_FACTWO, COLOR_KILLED_FACTWO);

	COLOR_TOTAL_ACTIVE			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_TOTAL_ACTIVE, COLOR_TOTAL_ACTIVE);
	COLOR_TOTAL_KILLED			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_TOTAL_KILLED, COLOR_TOTAL_KILLED);
	COLOR_TOTAL_REMAIN			= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.COLOR_TOTAL_REMAIN, COLOR_TOTAL_REMAIN);

	NotAValidEnemy_TemplateName	= `MCM_CH_GetValue(class'RustyCounter_Settings_Defaults'.default.NotAValidEnemy_TemplateName, NotAValidEnemy_TemplateName);
}

// WHAT TO DO WHEN THE SAVE BUTTON IS CLICKED
simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local RustyCounter_UI ui;

	CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    SaveConfig();

	ui = class'RustyCounter_Utils'.static.GetUI();
	if(ui == none)
	{
		return;
	}

	ui.UpdateSettings(self);
}

// WHAT TO DO WHEN THE RESET BUTTON IS CLICKED ... LOADS DEFAULT SETTINGS
simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	alwaysShowActiveEnemyCount_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.alwaysShowActiveEnemyCount, true);
	showSplitTeamsActive_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.showSplitTeamsActive, true);
	showSplitTeamsKilled_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.showSplitTeamsKilled, true);
	neverShowEnemyTotal_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.neverShowEnemyTotal, true);
	alwaysShowEnemyTotal_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.alwaysShowEnemyTotal, true);
	locationScoutShowsTotal_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.locationScoutShowsTotal, true);
	showRemainingInsteadOfTotal_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.showRemainingInsteadOfTotal, true);
	includeTurrets_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.includeTurrets, true);

	noColor_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.noColor, true);
	textAlignment_Dropdown.SetValue(class'RustyCounter_Settings_Defaults'.default.textAlignment, true);
	autoAdjust_Checkbox.SetValue(class'RustyCounter_Settings_Defaults'.default.autoAdjust, true);
	BoxAnchor_Slider.SetValue(class'RustyCounter_Settings_Defaults'.default.BoxAnchor, true);
	OffsetX_Slider.SetValue(class'RustyCounter_Settings_Defaults'.default.OffsetX, true);
	OffsetY_Slider.SetValue(class'RustyCounter_Settings_Defaults'.default.OffsetY, true);
}

///////////////////////////////////////////////////////////////////////////////
//	INFORMATION GATHERING FOR OTHER CLASSES BASED ON THE VALUES IN MCM
///////////////////////////////////////////////////////////////////////////////

function bool ShouldDrawActiveCount()
{
	return alwaysShowActiveEnemyCount;
}

function bool ShouldShowSplitTeamsActive()
{
	return showSplitTeamsActive;
}

function bool ShouldShowSplitTeamsKilled()
{
	return showSplitTeamsKilled;
}

// TOTAL COUNT, ALWAYS OVERRIDES NEVER, DEFAULT BASED ON IF SHADOW CHAMBER IS BUILT OR LOCATION SCOUT IS ACTIVE
function bool ShouldDrawTotalCount()
{
	// direct overides ... always overrides never
	if (alwaysShowEnemyTotal)
	{
		return true;
	}
	else if (neverShowEnemyTotal) 
	{
		return false;
	} 

	// default conditional settings
	if (class'RustyCounter_Utils'.static.IsShadowChamberBuilt() 
		|| (locationScoutShowsTotal && class'RustyCounter_Utils'.static.IsMissionSitRep_LocationScout() ) )
	{
		return true;
	}

	return false;
}

function bool ShouldShowRemainingInsteadOfTotal()
{
	return showRemainingInsteadOfTotal;
}

function bool ShouldSkipTurrets()
{
	return !includeTurrets;
}

function bool ShouldAutoAdjust()
{
	return autoAdjust;
}
