# PartyBuffs

![Self Buff](https://github.com/Akirane/Partybuffs/blob/master/buff.PNG)

Updated version which also shows your own buffs!

Shows party members buffs icons without the necesity of targetting. (Doesn't work on trust and fellow)

Uses the modified icons of FFXIView of this version: https://github.com/KenshiDRK/XiView

## Important notes

* I've only tested this with whitelist mode. 
* Updating your buffs works differently from the rest of your party. Your buffs will be shown in the wrong spot after removing/adding members, this fixes itself by obtaining a new buff/debuff.

### Adding more buffs to whitelist

`filters.lua` contains a whitelist which is built up entirely of buff ids. For example 40 is protect and 41 is shell. To add/remove a specific buff, I recommend checking out this list: https://wiki.dspt.info/index.php/Status_Effect_IDs



Commands:
#### Show a list of available commands
`//pb|partybuffs help`
#### Sets the icon size to 10x10
`//pb|partybuffs size 10`
#### Sets the icon size to 20x20
`//pb|partybuffs size 20 `


![partybuffs](http://i.imgur.com/lXZfZVo.jpg)
