ZO_Dialogs_RegisterCustomDialog("ABANDON_CUSTOM_QUEST",
{
    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.BASIC,
    },
    title =
    {
        text = SI_PROMPT_TITLE_ABANDON_QUEST,
    },
    mainText = 
    {
        text = SI_CONFIRM_ABANDON_QUEST,
    },
    buttons =
    {
        [1] =
        {
            text =      SI_ABANDON_QUEST_CONFIRM,
            callback =  function(dialog)
                            CUSTOM_QUEST_MANAGER:AbandonQuest(dialog.data.questId)
                        end,
        },
        
        [2] =
        {
            text =      SI_DIALOG_CANCEL,
        }
    }
})