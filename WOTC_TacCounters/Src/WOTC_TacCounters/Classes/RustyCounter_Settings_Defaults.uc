//---------------------------------------------------------------------------------------
//  FILE:   KillCounter.uc MCM SETTINGS DEFAULTS                                
//           
//	CREATED BY LUMINGER WAY BACK IN SEP 2017
//	BEGIN EDITS BY RUSTYDIOS	18/02/21	22:00
//	LAST EDITED BY RUSTYDIOS	24/02/21	23:10
//  
//---------------------------------------------------------------------------------------
class RustyCounter_Settings_Defaults extends Object config(RustyCounter_Defaults);

var config bool alwaysShowActiveEnemyCount, showSplitTeamsActive, showSplitTeamsKilled;
var config bool neverShowEnemyTotal, alwaysShowEnemyTotal, locationScoutShowsTotal, showRemainingInsteadOfTotal;
var config bool includeTurrets, noColor, autoAdjust;
var config string textAlignment;
var config int BoxAnchor, OffsetX, OffsetY, CONFIG_VERSION;

var config string COLOR_ACTIVE_ADVENT, COLOR_ACTIVE_LOST, COLOR_ACTIVE_FACONE, COLOR_ACTIVE_FACTWO;
var config string COLOR_KILLED_ADVENT, COLOR_KILLED_LOST, COLOR_KILLED_FACONE, COLOR_KILLED_FACTWO;	
var config string COLOR_TOTAL_ACTIVE, COLOR_TOTAL_KILLED, COLOR_TOTAL_REMAIN;

var config array<name> NotAValidEnemy_TemplateName;
