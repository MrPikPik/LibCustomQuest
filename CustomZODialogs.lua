-- LCQ Dialogs
ZO_Dialogs_RegisterCustomDialog("LCQ_DELETE_CUSTOM_MAIL",   
{
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.BASIC,
	},
	title =
	{
		text = SI_PROMPT_TITLE_DELETE_MAIL,
	},
	mainText = 
	{
		text = SI_MAIL_CONFIRM_DELETE,
	},
	buttons =
	{
		[1] =
		{
			text =      SI_MAIL_DELETE,
			callback =  function(dialog)
							dialog.data.callback(dialog.data.mailId)
						end
		},
		[2] = {text = SI_DIALOG_CANCEL},
	}
})