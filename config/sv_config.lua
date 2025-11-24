return {
    -- Minimum number of players required in a group to ready up (minimum: 2)
    minGroupSize = 2,

    -- Maximum number of players allowed in a group
    maxGroupSize = 10,

    -- If true, players can only be in one active (creating status) group at a time
    -- If false, players can join multiple groups
    singleGroupOnly = false,

    -- Command options
    command = {
        enable = false, -- Enable command to open menu
        name = 'secretsanta' -- Command name
    },

    -- Enable or disable the gift list
    -- If false, the gift selection prompt will not appear when readying up a group
    enableGiftList = true,

    -- List of gift items that can be randomly assigned to players
    giftList = {
        'Christmas sweater',
        'Sprunk Soda',
        'LSPD Badge',
        'Lottery ticket',
        'Thermite',
        'Cookie',
        'Suspicious white powder',
        'Keys to a Faggio scooter',
        'Counterfeit Rolex',
        'eCola',
        'Mustache Dom',
        'A duffel bag full of surprises',
        'Franklin\'s autograph',
        'A brick',
        'Casino chips',
        'A lovely photograph',
        'A hug',
        'Lockpicks',
        'ERP',
        'A better getaway driver',
        'Bulletproof vest'
    }
}