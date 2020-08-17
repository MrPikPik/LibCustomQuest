--This is built upon ExampleDialog of LibCustomDialog, with the speakers changed for testing purposes.

if not Alianym then Alianym = {} end
if not Alianym.Dialogues then Alianym.Dialogues = {} end

Alianym.Dialogues[1] = {}

Alianym.Dialogues[1].DETAILS = {
    questId = "TESTQUEST2",
    questStage = 1,
}

Alianym.Dialogues[1].YES = {
    speaker = "Vinicia Flavus",
    text = "I knew you would like them.",
}

Alianym.Dialogues[1].NO = {
    speaker = "Vinicia Flavus",
    text = "Very well. If you don't think so...",
}

Alianym.Dialogues[1].OPTION_INTIM = {
    text = "You believe I would not be interested?",
    decorator = Alianym.DECORATOR_INTIMIDATE,
    nextDialog = Alianym.Dialogues[1].YES,
}

Alianym.Dialogues[1].OPTION_PERS = {
    text = "Trust me, I'm not doubting they are possible, they are pretty cool.",
    decorator = Alianym.DECORATOR_PERSUADE,
    nextDialog = Alianym.Dialogues[1].YES,
}

Alianym.Dialogues[1].OPTION_YES = {
    text = "Yeah, custom dialogs are pretty neat!",
    important = true,
    nextDialog = Alianym.Dialogues[1].YES,
}
        
Alianym.Dialogues[1].OPTION_NO = {
    text = "No, why would anyone want custom dialogs anyway?",
    important = true,
    nextDialog = Alianym.Dialogues[1].NO,
}

Alianym.Dialogues[1].WHAT = {
    speaker = "Vinicia Flavus",
    text = "You doubt, this is possible? As you can see right here, it works. Flawless too! As far as I know at least.",
    options = {
        [1] = Alianym.Dialogues[1].OPTION_PERS,
        [2] = Alianym.Dialogues[1].OPTION_INTIM,
        [3] = Alianym.Dialogues[1].OPTION_NO,
        [4] = Alianym.Dialogues[1].OPTION_YES,    
    }
}

Alianym.Dialogues[1].OPTION_WHAT = {
    text = "What? How are custom dialogs possible?",
    nextDialog = Alianym.Dialogues[1].WHAT,
}

Alianym.Dialogues[1].ENTRY = {
    speaker = "Vinicia Flavus",
    text = "Hello, <<1>>!\n\nSeems like, you are the kind of man that is showing interest in |c006900custom dialogs|r, aren't you?",
    textfemale = "Hello, <<1>>!\n\nSeems like, you are the kind of woman that is showing interest in |c006900custom dialogs|r, aren't you?",
    insertCharName = true,
    options = {
        [1] = Alianym.Dialogues[1].OPTION_WHAT,
        [2] = Alianym.Dialogues[1].OPTION_NO,
        [3] = Alianym.Dialogues[1].OPTION_YES,   
    }
}

Alianym.Dialogues[2] = {}

Alianym.Dialogues[2].DETAILS = {
    questId = "TESTQUEST3",
    questStage = 1,
}

Alianym.Dialogues[2].YES = {
    speaker = "Captain Rahiba",
    text = "I knew you would like them.",
}

Alianym.Dialogues[2].NO = {
    speaker = "Captain Rahiba",
    text = "Very well. If you don't think so...",
}

Alianym.Dialogues[2].OPTION_INTIM = {
    text = "You believe I would not be interested?",
    decorator = Alianym.DECORATOR_INTIMIDATE,
    nextDialog = Alianym.Dialogues[2].YES,
}

Alianym.Dialogues[2].OPTION_PERS = {
    text = "Trust me, I'm not doubting they are possible, they are pretty cool.",
    decorator = Alianym.DECORATOR_PERSUADE,
    nextDialog = Alianym.Dialogues[2].YES,
}

Alianym.Dialogues[2].OPTION_YES = {
    text = "Yeah, custom dialogs are pretty neat!",
    important = true,
    nextDialog = Alianym.Dialogues[2].YES,
}
        
Alianym.Dialogues[2].OPTION_NO = {
    text = "No, why would anyone want custom dialogs anyway?",
    important = true,
    nextDialog = Alianym.Dialogues[2].NO,
}

Alianym.Dialogues[2].WHAT = {
    speaker = "Captain Rahiba",
    text = "You doubt, this is possible? As you can see right here, it works. Flawless too! As far as I know at least.",
    options = {
        [1] = Alianym.Dialogues[2].OPTION_PERS,
        [2] = Alianym.Dialogues[2].OPTION_INTIM,
        [3] = Alianym.Dialogues[2].OPTION_NO,
        [4] = Alianym.Dialogues[2].OPTION_YES,    
    }
}

Alianym.Dialogues[2].OPTION_WHAT = {
    text = "What? How are custom dialogs possible?",
    nextDialog = Alianym.Dialogues[2].WHAT,
}

Alianym.Dialogues[2].ENTRY = {
    speaker = "Captain Rahiba",
    text = "Hello, <<1>>!\n\nSeems like, you are the kind of man that is showing interest in |c006900custom dialogs|r, aren't you?",
    textfemale = "Hello, <<1>>!\n\nSeems like, you are the kind of woman that is showing interest in |c006900custom dialogs|r, aren't you?",
    insertCharName = true,
    options = {
        [1] = Alianym.Dialogues[2].OPTION_WHAT,
        [2] = Alianym.Dialogues[2].OPTION_NO,
        [3] = Alianym.Dialogues[2].OPTION_YES,   
    }
}

Alianym.Dialogues[3] = {}

Alianym.Dialogues[3].DETAILS = {
    questId = "TESTQUEST2",
    questStage = 1,
}

Alianym.Dialogues[3].YES = {
    speaker = "Tilanfire",
    text = "I knew you would like them.",
}

Alianym.Dialogues[3].NO = {
    speaker = "Tilanfire",
    text = "Very well. If you don't think so...",
}

Alianym.Dialogues[3].OPTION_INTIM = {
    text = "You believe I would not be interested?",
    decorator = Alianym.DECORATOR_INTIMIDATE,
    nextDialog = Alianym.Dialogues[3].YES,
}

Alianym.Dialogues[3].OPTION_PERS = {
    text = "Trust me, I'm not doubting they are possible, they are pretty cool.",
    decorator = Alianym.DECORATOR_PERSUADE,
    nextDialog = Alianym.Dialogues[3].YES,
}

Alianym.Dialogues[3].OPTION_YES = {
    text = "Yeah, custom dialogs are pretty neat!",
    important = true,
    nextDialog = Alianym.Dialogues[3].YES,
}
        
Alianym.Dialogues[3].OPTION_NO = {
    text = "No, why would anyone want custom dialogs anyway?",
    important = true,
    nextDialog = Alianym.Dialogues[3].NO,
}

Alianym.Dialogues[3].WHAT = {
    speaker = "Tilanfire",
    text = "You doubt, this is possible? As you can see right here, it works. Flawless too! As far as I know at least.",
    options = {
        [1] = Alianym.Dialogues[3].OPTION_PERS,
        [2] = Alianym.Dialogues[3].OPTION_INTIM,
        [3] = Alianym.Dialogues[3].OPTION_NO,
        [4] = Alianym.Dialogues[3].OPTION_YES,    
    }
}

Alianym.Dialogues[3].OPTION_WHAT = {
    text = "What? How are custom dialogs possible?",
    nextDialog = Alianym.Dialogues[3].WHAT,
}

Alianym.Dialogues[3].ENTRY = {
    speaker = "Tilanfire",
    text = "Hello, <<1>>!\n\nHave you taken up the challenge to Slapp the Hellhound?",
    textfemale = "Hello, <<1>>!\n\nHave you taken up the challenge to Slapp the Hellhound",
    insertCharName = true,
    options = {
        [1] = Alianym.Dialogues[3].OPTION_WHAT,
        [2] = Alianym.Dialogues[3].OPTION_NO,
        [3] = Alianym.Dialogues[3].OPTION_YES,   
    }
}

Alianym.Dialogues[4] = {}

Alianym.Dialogues[4].DETAILS = {
    questId = "TESTQUEST3",
    questStage = 1,
}

Alianym.Dialogues[4].YES = {
    speaker = "Tilanfire",
    text = "I knew you would like them.",
}

Alianym.Dialogues[4].NO = {
    speaker = "Tilanfire",
    text = "Very well. If you don't think so...",
}

Alianym.Dialogues[4].OPTION_INTIM = {
    text = "You believe I would not be interested?",
    decorator = Alianym.DECORATOR_INTIMIDATE,
    nextDialog = Alianym.Dialogues[4].YES,
}

Alianym.Dialogues[4].OPTION_PERS = {
    text = "Trust me, I'm not doubting they are possible, they are pretty cool.",
    decorator = Alianym.DECORATOR_PERSUADE,
    nextDialog = Alianym.Dialogues[4].YES,
}

Alianym.Dialogues[4].OPTION_YES = {
    text = "Yeah, custom dialogs are pretty neat!",
    important = true,
    nextDialog = Alianym.Dialogues[4].YES,
}
        
Alianym.Dialogues[4].OPTION_NO = {
    text = "No, why would anyone want custom dialogs anyway?",
    important = true,
    nextDialog = Alianym.Dialogues[4].NO,
}

Alianym.Dialogues[4].WHAT = {
    speaker = "Tilanfire",
    text = "You doubt, this is possible? As you can see right here, it works. Flawless too! As far as I know at least.",
    options = {
        [1] = Alianym.Dialogues[4].OPTION_PERS,
        [2] = Alianym.Dialogues[4].OPTION_INTIM,
        [4] = Alianym.Dialogues[4].OPTION_NO,
        [4] = Alianym.Dialogues[4].OPTION_YES,    
    }
}

Alianym.Dialogues[4].OPTION_WHAT = {
    text = "What? How are custom dialogs possible?",
    nextDialog = Alianym.Dialogues[4].WHAT,
}

Alianym.Dialogues[4].ENTRY = {
    speaker = "Tilanfire",
    text = "Hello, <<1>>!\n\nHave you taken up the challenge to check out New Content?",
    textfemale = "Hello, <<1>>!\n\nHave you taken up the challenge to check out New Content?",
    insertCharName = true,
    options = {
        [1] = Alianym.Dialogues[4].OPTION_WHAT,
        [2] = Alianym.Dialogues[4].OPTION_NO,
        [4] = Alianym.Dialogues[4].OPTION_YES,   
    }
}