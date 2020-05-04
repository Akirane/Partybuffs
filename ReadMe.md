# PartyBuffs

![Self Buff](https://github.com/Akirane/Partybuffs/blob/master/buff.PNG)

Updated version which also shows your own buffs!

Shows party members buffs icons next to party list (Doesn't work on trust and fellow).

Uses the modified icons of FFXIView of this version: https://github.com/KenshiDRK/XiView

## Important notes

* This version only runs in whitelist mode. 

## Update 04/05/2020

A new bar that shows important buffs as well as a timer has been implemented. This bar can be moved around with `//pb important offset X Y` or `//pb important offset 670 330` and the new offset will be saved in **data/settings.xml**.

![Important Bar](https://github.com/Akirane/Partybuffs/blob/master/important_bar.PNG)

### Adding more buffs to be whitelisted in the important bar 

In **filters.lua** there's now a new table called `important_buffs`. Apply status effect IDs you want to be shown here.

### New commands

| Command                     | Description                                                                                 |
|-----------------------------|---------------------------------------------------------------------------------------------|
| `//pb help`                 | Show a list of available commands                                                           |
| `//pb important toggle`     | Toggles the important bar ON/OFF                                                            |
| `//pb important offset X Y` | Sets important bar's X and Y offset (right-margin and bottom-margin in pixels respectively) |


### Adding more buffs to whitelist

`filters.lua` contains a whitelist which is built up entirely of buff ids. For example 40 is protect and 41 is shell. To add/remove a specific buff, I recommend checking out this list: https://wiki.dspt.info/index.php/Status_Effect_IDs

## Commands


![partybuffs](http://i.imgur.com/lXZfZVo.jpg)
