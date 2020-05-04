require('tables')

--For buffs id you can check the buffs.lua in resources
whitelist = L{
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    19,
    20,
    21,
    28,
	31,
    33,
    40,
    41,
    42,
    43,
	66,
	80,
	93,
	104,
	106,
    113,
    116,
    119,
    134,
    135,
    136,
    144,
    146,
    147,
    149,
    187,
    188,
    265,
	275,
    417,
    418,
    419,
	444,
	445,
	446,
    513,
	523,
	524,
	525,
	526,
	527,
	528,
	529,
	530,
	531,
	532,
	533,
	534,
	537,
	538,
    539,
    540,
    541
} 

-- Buffs the important bar will show, each job has their own separate table.
important_buffs = {}
important_buffs['init'] = L{}
important_buffs['WAR'] = L{}
important_buffs['MNK'] = L{}
important_buffs['WHM'] = L{33, 36, 37, 39, 42, 43, 100, 101, 102, 103, 104, 106, 113, 119, 187, 188, 251, 275, 358, 359, 417, 418, 432, 462}
important_buffs['BLM'] = L{}
important_buffs['RDM'] = L{33, 37, 39, 42, 43, 94, 95, 96, 97, 98, 99, 116, 432, 454, 462}
important_buffs['THF'] = L{33, 42, 43, 56, 65, 68, 87, 93, 116, 289, 343, 353, 432, 462}
important_buffs['PLD'] = L{}
important_buffs['DRK'] = L{}
important_buffs['BST'] = L{}
important_buffs['BRD'] = L{}
important_buffs['RNG'] = L{}
important_buffs['SAM'] = L{}
important_buffs['NIN'] = L{}
important_buffs['DRG'] = L{}
important_buffs['SMN'] = L{}
important_buffs['BLU'] = L{}
important_buffs['COR'] = L{}
important_buffs['PUP'] = L{}
important_buffs['DNC'] = L{}
important_buffs['SCH'] = L{}
important_buffs['GEO'] = L{}
important_buffs['RUN'] = L{33, 39, 42, 43, 93, 116, 289, 353, 432, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 537, 538, 539, 540, 541}

blacklist = {
    WAR = L{}, -- buffs id separated by coma WAR = {40, 41}, this will filter only the protect and shell buffs on Warrior main job
    MNK = L{},
    WHM = L{},
    BLM = L{},
    RDM = L{},
    THF = L{},
    PLD = L{},
    DRK = L{},
    BST = L{},
    BRD = L{},
    RNG = L{},
    SAM = L{},
    NIN = L{},
    DRG = L{},
    SMN = L{},
    BLU = L{},
    COR = L{},
    PUP = L{},
    DNC = L{},
    SCH = L{},
    GEO = L{},
    RUN = L{}
}
