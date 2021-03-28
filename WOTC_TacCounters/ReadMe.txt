You created an XCOM 2 Mod Project!
Changed by RustyDios to be WOTC only and account for the CHL Faction Teams
============================================================================================
STEAM DESC		  https://steamcommunity.com/sharedfiles/filedetails/?id=2405013108
============================================================================================
[h1]What is this?[/h1]
This is a small update and slight rearrange to [url=https://steamcommunity.com/sharedfiles/filedetails/?id=749138678] Lumingers Kill Counter [/url] made under the terms of the license on the github, included.
This mod adds a set of very simple counters to the Tactical UI, [b]for each enemy team.[/b] 
[quote=Luminger]
So this mod doesn't show you anything which you didn't already know, but who does exactly count how many aliens have been killed so far or how many are currently active?
While the total enemy count will go up whenever reinforcements arrive, this also isn't something you didn't already know (as long as you counted fast enough).
In case you dislike this, there's an option to disable the total count. Same goes for the count of the currently active enemies 
- technically not cheating, but somebody might dislike it -> tweak the settings until you like it.
[/quote]

[h1]Features[/h1][list]
[*]Works for all four possible enemy teams. Advent | Lost | Faction1 | Faction2.
[*]Shows the number of active units, for each enemy team (MCM editable).
[*]Shows the number of killed units, for each enemy team (MCM editable).
[*]Shows either the total enemy count or number remaining (MCM editable).
[*]The total/remaining will show up after construction of the Shadow Chamber (MCM editable).
[*]The total/remaining will show up if the 'Location Scout' sitrep is active (MCM editable).
[*]All counter colours are [i]config editable[/i] and there is a non-colour option (MCM editable).
[*]Non-Colour mode forces combined counters, as it is no longer clear what the numbers represent without colour.
[*]Skips counting of turrets (MCM editable). Skips Gremlins and Mimic Beacons.
[*][i]Config editable[/i] list of enemy templates to not count. 
Default exclusion for the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2387956032] Faction Anchor [/url].
[*]Ignores the Chosen and Rulers! You don't need to know these are active/killed right ?
[*]Goes by the exact units on the map, instead of team counts. This means it should stay updated with what is actually in the mission.
[*]Dynamically adjusts for new reinforcements.
[*]No lingering counts for units not in play. (eg; evac'ed units)
[*]New 3 line layout that auto-adjusts if a timer is on the screen (MCM editable).
[*]The timers Auto-Adjust should catch if both are visible while using [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1823265096] Request Evac [/url] or [b]LWotC[/b]. It might take a moment to update the position.
[/list]

[h1]Config[/h1]
There are options in the [b]XComKillCounter.ini[/b] for controlling the colour of the numbers.
Default team colour options are;[list]
[*]ADVENT = Red 
[*]LOST = Green
[*]FACTION 1 = Purple
[*]FACTION 2 = Yellow
[/list]
Config editable list of enemy templates to not count in the active/total.
Default exclusion for the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2387956032] Faction Anchor [/url].

Most config options from the original kept including the [url=https://steamcommunity.com/sharedfiles/filedetails/?id=667104300] Mod Config Menu [/url] compatibility.
Technically 'my' first MCM compatible mod, and I added all of 4 new options.

[h1]Known Issues, ETC[/h1][olist]
[*]Aliens who bail out and join another pod may increase the active counter. Technically this isn't something you knew, so it violates a key pricipal of this mod.
[*]During Tactical Comms/Narrative Moments the counters are hidden under the video feed. Not a huge priority to fix. It only looks a little visually jarring.
[/olist]
Should work with Covert Infilitraton, LWotC and RPGO. 
Sadly not for Vanilla anymore (I use the faction team stuff from the WotC CHL).
Should work mid-campaign, and possibly mid-tactical.
Shows an incompatible pop-up warning for [url=https://steamcommunity.com/sharedfiles/filedetails/?id=749138678] Lumingers Kill Counter [/url], although the two mods are [i][b]not[/b] completely incompatible[/i], just 'redundant'.

[h1]Credits and Thanks[/h1]
[b]HUGE[/b] thanks to [b]Lumingers[/b] [url=https://github.com/Luminger/xcom2-killcounter] Original Source Code [/url], I wish I knew how to use GiT better.
Many thanks to [b]Managarmr[/b] for the originals MCM inclusion, and [b]guby[/b] for the MCM, and [b]MrNiceUK[/b] for help with my MCM additions!
Many thanks to [b]ShireMct[/b] for the config pop on the shell screen to aid with MCM configs.
Many thanks to the XCom2 Modders Discord for continued support.

~ Enjoy [b]!![/b] and please buy me a [url=https://www.buymeacoffee.com/RustyDios] Cuppa Tea [/url]

============================================================================================
ORIG DESC     https://steamcommunity.com/sharedfiles/filedetails/?id=749138678
============================================================================================
TL;DR: Tactical UI now shows you how many enemies you've killed, the remaining
	   count and how many are currently active.

NEW: WotC Ready - works on every XCOM2 version (despite the triangle)
NEW: TheLost are taken into account as well!
NEW: Now with MCM support! (Big thanks to Managarmr!)

This mod adds a set of (very) simple counters to the Tactical UI. It shows you
how may enemies you've killed so far, how many are remaining (or the total
count, this can be changed in the settings) and how many are currently activated
and after you (you can disable this in the settings if you dislike it).

This mod is open source: https://github.com/Luminger/xcom2-killcounter

It will only show the number of remaining enemies (or the total) in a mission
as long as you've already build the ShadowChamber (you can change this as
well in the settings).

So this mod doesn't show you anything which you didn't already know, but who
does exactly count how many aliens have been killed so far or how many are
currently active? While the total enemy count will go up whenever reinforcements
arrive, this also isn't something you didn't already knew (as long as you
counted fast enough). In case you dislike this, there's an option to
disable the total count. Same goes for the count of the currently active
enemies - technically not cheating, but somebody might dislike it -> tweak the
settings until you like it.

This mod is somewhat mature by now, so new features are rather unlikely to
appear out of nowhere, but please feel free to donate the code if you like;
I'm happy to have a look at improvements/features! I'll also do my best to
keep it working, but this may take a while as real life is a priority way
before XCOM.

Possible future features:
 - Show the names (and count) of each enemy type killed, maybe in a tooltip. If
   you have any other idea how to visualize this properly (I'm not a UI 
   designer) please leave a comment [LOW]
 - Give players the option to not count reinforcements into the total count
   (looks like this is way more complex than I though) [LOW]
 - Give players the option to disable the remaining/total count in story
   missions where the count is rather high and it adds to the 'thrill' of
   those missions. [LOW]
 - Aliens who bail out and join another pod will increase the Active counter.
   Technically this isn't something you knew, so it violates the key pricipal
   of this mod. It might be possible to detect a 'pod join', but it might be
   at least tricky or just not possible at all. [MEDIUM]

Features marked with [LOW] are questionable and might not be useful at all.
Please feel free to leave a comment if you do think a features marked as [LOW]
is worth implementing. Other suggestions are welcome as well!