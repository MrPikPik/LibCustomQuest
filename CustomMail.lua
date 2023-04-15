-----------------------------------------
-- Custom Quest Mail
-----------------------------------------

----------
-- Local Funcs
----------

local function FormatSubject(subject, returned)
	local formattedSubject
	if(subject == "") then
		formattedSubject = GetString(SI_MAIL_READ_NO_SUBJECT)
	else
		formattedSubject = subject
	end

	if(returned) then
		formattedSubject = zo_strformat(SI_MAIL_READ_RETURNED_SUBJECT, formattedSubject)
	end

	return formattedSubject
end

local function GetFormattedSubject(self)
	if not self.formattedSubject then
		self.formattedSubject = FormatSubject(self.subject, self.returned)
	end
	return self.formattedSubject
end

local function GetFormattedReplySubject(self)
	local formattedSubject = GetFormattedSubject(self)
	local tag = GetString(SI_MAIL_READ_REPLY_TAG_NO_LOC)
	local tagLength = #tag
	if string.sub(formattedSubject, 1, tagLength) ~= tag then
		return string.format("%s %s", GetString(SI_MAIL_READ_REPLY_TAG_NO_LOC), formattedSubject)
	end
	return formattedSubject
end

local function GetExpiresText(self)
	if not self.expiresText then
		if not self.expiresInDays then
			self.expiresText = GetString(SI_MAIL_READ_NO_EXPIRATION)
		elseif self.expiresInDays > 0  then
			self.expiresText = zo_strformat(SI_MAIL_READ_EXPIRES_LABEL, self.expiresInDays)
		else
			self.expiresText = GetString(SI_MAIL_READ_EXPIRES_LESS_THAN_ONE_DAY)
		end
	end
	return self.expiresText
end

local function GetReceivedText(self)
	if not self.receivedText then
		self.receivedText = ZO_FormatDurationAgo(self.secsSinceReceived)
	end
	return self.receivedText
end

local function IsExpirationImminent(self)
	return self.expiresInDays and self.expiresInDays <= 3
end

local function GetCustomMailItemInfo(customMailId)
	local mailData = CUSTOM_QUEST_MAIL:GetCustomMailData(customMailId)

	local senderDisplayName = mailData.addOnName
	local senderCharacterName = mailData.senderName
	local subject = mailData.subject
	--local icon = ".dds"
	local icon = ""
	local unread = mailData.unread
	local onRead = mailData.onRead
	--local numAttachments = 0
	--local expiresInDays = 99
	local expiresInDays = 30
	local secsSinceReceived = 1

	return senderDisplayName, senderCharacterName, subject, icon, unread, onRead, expiresInDays, secsSinceReceived
end

local function IsReadCustomMailInfoReady(customMailId)
	return true
end

local function LCQ_MailInboxShared_PopulateMailData(dataTable, customMailId)
	local senderDisplayName, senderCharacterName, subject, icon, unread, onRead, expiresInDays, secsSinceReceived = GetCustomMailItemInfo(customMailId)
	dataTable.mailId = customMailId
	dataTable.subject = subject
	--dataTable.icon = icon
	dataTable.returned = false --returned
	--dataTable.senderTooltipName = senderDisplayName
	dataTable.senderCharacterName = senderCharacterName
	dataTable.expiresInDays = nil --expiresInDays
	dataTable.unread = unread
	dataTable.onRead = onRead
	dataTable.numAttachments = 0 --numAttachments
	dataTable.attachedMoney = 0 --attachedMoney
	dataTable.codAmount = 0 --codAmount
	dataTable.secsSinceReceived = secsSinceReceived
	dataTable.fromLCQ = true
	--dataTable.fromSystem = false --fromSystem
	--dataTable.fromCS = false --fromCS
	--dataTable.isFromPlayer = false --not (fromSystem or fromCS)
	dataTable.priority = 2 --fromCS and 1 or 2
	dataTable.GetFormattedSubject = GetFormattedSubject
	dataTable.GetFormattedReplySubject = GetFormattedReplySubject
	dataTable.GetExpiresText = GetExpiresText
	dataTable.GetReceivedText = GetReceivedText
	dataTable.isReadInfoReady = IsReadCustomMailInfoReady(customMailId)
	dataTable.IsExpirationImminent = IsExpirationImminent	
end

local function MailComparator(mailData1, mailData2)
	return ZO_TableOrderingFunction(mailData1, mailData2, MAIL_ENTRY_FIRST_SORT_KEY, MAIL_ENTRY_SORT_KEYS, ZO_SORT_ORDER_UP)
end

----------
-- CustomQuestMail
---------

CustomQuestMail = ZO_CallbackObject:Subclass()

-- Instantiates a new quest mail object
function CustomQuestMail:New(...)
	local questMail = ZO_Object.New(self)
	questMail:Initialize(...)
	return questMail
end

-- Initializes a CustomQuestMail object
function CustomQuestMail:Initialize(mailData)
	self.customMailData = {}
	self.customMailEmptyNodeData = { text = GetString(LCQ_MAIL_NO_CUSTOM_MAIL_ENTRY) }

	self:RegisterCallback("UpdateNumCustomMail", function()
		local numCustomUnread = self.numUnread

		--if self.numUnread == 0 then return end
		local numUnread = GetNumUnreadMail() + numCustomUnread

		if numUnread > KEYBOARD_CHAT_SYSTEM.numUnreadMails and IsPlayerActivated() then
			KEYBOARD_CHAT_SYSTEM.mailBurstTimeline:PlayFromStart()
		end

		SharedChatSystem.OnNumUnreadMailChanged(KEYBOARD_CHAT_SYSTEM, numUnread)

		KEYBOARD_CHAT_SYSTEM.mailLabel:SetText(numUnread)
		KEYBOARD_CHAT_SYSTEM.mailGlow:SetHidden(numUnread == 0)
	end)
end

function CustomQuestMail:GetCustomMailData(mailId)
	local key = Id64ToString(mailId)
	return self.customMailData[key]
end

function CustomQuestMail:IsCustomMail(mailId)
	return self:GetCustomMailData(mailId) ~= nil
end

function CustomQuestMail:ReadCustomMail(customMailId)
	local customMailData = self:GetCustomMailData(customMailId)
	return customMailData.body
end

function CustomQuestMail:OnCustomMailReadable(mailId)
	if not self:IsCustomMail(mailId) then return end

	if not mailId == MAIL_INBOX.pendingRequestMailId then
		return
	end

	MAIL_INBOX:EndRead()

	-- Set mail as read and refresh header status icon
	local customMailData = CUSTOM_QUEST_MAIL:GetCustomMailData(mailId)

	customMailData.unread = false
	MAIL_INBOX:GetMailData(mailId).unread = false

	local headerControl = CUSTOM_QUEST_MAIL.customMailNode.control
	local headerData = CUSTOM_QUEST_MAIL.customMailNode.data
	local statusIcon = headerControl.statusIcon

	statusIcon:ClearIcons()

	if NonContiguousCount(headerData.unreadData) > 0 then
		statusIcon:AddIcon(ZO_KEYBOARD_NEW_ICON)
	end

	statusIcon:Show()
	----------

	MAIL_INBOX.pendingRequestMailId = nil
	MAIL_INBOX.mailId = mailId
	MAIL_INBOX.messageControl:SetHidden(false)
	KEYBIND_STRIP:UpdateKeybindButtonGroup(MAIL_INBOX.selectionKeybindStripDescriptor)

	local mailData = MAIL_INBOX:GetMailData(mailId)
	LCQ_MailInboxShared_PopulateMailData(mailData, mailId)
	if not mailData.unread then
		mailData.node.parentNode.data.unreadData[mailData] = nil
		CUSTOM_QUEST_MAIL.numUnread = CUSTOM_QUEST_MAIL.numUnread - 1 > 0 and CUSTOM_QUEST_MAIL.numUnread or 0
	end
	local NOT_USER_REQUESTED = false
	MAIL_INBOX.navigationTree:RefreshVisible(NOT_USER_REQUESTED)

	self:FireCallbacks("UpdateNumCustomMail")

	ZO_MailInboxShared_UpdateInbox(mailData, MAIL_INBOX.fromControl, MAIL_INBOX.subjectLabel, MAIL_INBOX.expirationLabel, MAIL_INBOX.receivedLabel, MAIL_INBOX.bodyLabel)
	MAIL_INBOX:RefreshMailFrom()
	ZO_Scroll_ResetToTop(MAIL_INBOX.messagePaneControl)

	MAIL_INBOX:RefreshMoneyControls()
	MAIL_INBOX:RefreshAttachmentsHeaderShown()
	MAIL_INBOX:RefreshAttachmentSlots()

	-- Run any OnRead function
	if customMailData.onRead then
		customMailData.onRead()
	end

	return true
end

function CustomQuestMail:RequestReadCustomMail(customMailId)
	return self:OnCustomMailReadable(customMailId)
end

function CustomQuestMail:RegisterMail(addOnName, mailDataIn)
	LCQ_DBG:LuaAssert(addOnName and mailDataIn, "Missing parameter! :RegisterMail(addOnName, mailDataIn)")
	
	local numUnread = 0
	for _, mailData in pairs(mailDataIn) do
		local mailIdType = type(mailData.id)
		local mailId = mailIdType == "number" and mailData.id or mailIdType == "string" and HashString(mailData.id)

		LCQ_DBG:LuaAssert(not self.customMailData[tostring(mailId)], "A custom mail with that ID already exists!")

		self.customMailData[tostring(mailId)] = 
		{
			addOnName = addOnName,
			customMailId = StringToId64(mailId), 
			senderName = mailData.senderName,
			subject = mailData.subject,
			body = zo_strformat(LCQ_MAIL_CUSTOM_MAIL_BODY, mailData.body, ZO_GAME_REPRESENTATIVE_TEXT:Colorize(addOnName)),
			unread = true,
			onRead = mailData.onRead,
		}

		self.numUnread = numUnread + 1 -- Can update to be based off saved vars storing read/unread state (if going that route)
		self:FireCallbacks("UpdateNumCustomMail")
	end
end

function CustomQuestMail:UnregisterMail(customMailId, isDelete)
	local key = tostring(type(customMailId) == "number" or type(customMailId) == "string" and HashString(customMailId))
	if isDelete then key = Id64ToString(customMailId) end

	self.customMailData[key] = nil
end

-- Create object
CUSTOM_QUEST_MAIL = CustomQuestMail:New()

----------
-- Hooks
----------

-- Only updates after the mail is opened
ZO_PreHook(KEYBOARD_CHAT_SYSTEM, "OnNumUnreadMailChanged", function(chatObj, numUnread)
	if CUSTOM_QUEST_MAIL.numUnread and CUSTOM_QUEST_MAIL.numUnread > 0 then 
		CUSTOM_QUEST_MAIL:FireCallbacks("UpdateNumCustomMail")
		return true
	end
end)

ZO_PreHook("ZO_MailInboxShared_PopulateMailData", function(mailData, mailId)
	if not CUSTOM_QUEST_MAIL:IsCustomMail(mailId) then return end
	return true
end)

ZO_PreHook("ZO_MailInboxShared_UpdateInbox", function(mailData, fromControl, subjectControl, expiresControl, receivedControl, bodyControl)
	if not CUSTOM_QUEST_MAIL:IsCustomMail(mailData.mailId) then return end

	local body = CUSTOM_QUEST_MAIL:ReadCustomMail(mailData.mailId)
	if body == "" then
		body = GetString(SI_MAIL_READ_NO_BODY)
	end

	-- Header and Body.
	fromControl:SetText(mailData.senderDisplayName)
	if mailData.fromLCQ then
		fromControl:SetColor(ZO_GAME_REPRESENTATIVE_TEXT:UnpackRGBA())
	else
		fromControl:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	end

	subjectControl:SetText(mailData:GetFormattedSubject())

	if expiresControl then
		local expiresText = mailData:GetExpiresText()
		if mailData:IsExpirationImminent() then
			expiresText = ZO_ERROR_COLOR:Colorize(expiresText)
		end
		expiresControl:SetText(expiresText)
	end

	if receivedControl then
		receivedControl:SetText(mailData:GetReceivedText())
	end

	bodyControl:SetText(body)

	return true
end)

----------
-- Keyboard-Specific
----------

ZO_PreHook(MAIL_INBOX, "RequestReadMessage", function(mailInboxObj, mailId)
	if not CUSTOM_QUEST_MAIL:IsCustomMail(mailId) then return end

	if not AreId64sEqual(MAIL_INBOX.mailId, mailId) then
		MAIL_INBOX.pendingRequestMailId = mailId
		CUSTOM_QUEST_MAIL:RequestReadCustomMail(mailId)
	end

	return true
end)

ZO_PreHook(MAIL_INBOX, "Delete", function(mailInboxOb)
	local mailId = MAIL_INBOX.mailId

	if not mailId then return end
	if not CUSTOM_QUEST_MAIL:IsCustomMail(mailId) then return end

	local function ConfirmDelete(mailId)
		CUSTOM_QUEST_MAIL:UnregisterMail(mailId, true)
		PlaySound(SOUNDS.MAIL_ITEM_DELETED) 

		MAIL_INBOX:OnMailRemoved(mailId)
	end

	-- Do a check on attachments later
	ZO_Dialogs_ShowDialog("LCQ_DELETE_CUSTOM_MAIL", {callback = function(...) ConfirmDelete(...) end, mailId = mailId})

	-- Return true, no need for hooked function to run
	return true
end)

-- Store last selected mailId before MAIL_INBOX:RefreshData() wipes it, then use it in the SecurePostHook
ZO_PreHook(MAIL_INBOX, "RefreshData", function(mailInboxObj)
	CUSTOM_QUEST_MAIL.currentMailId = MAIL_INBOX.mailId
	CUSTOM_QUEST_MAIL.selectMailIdOnRefresh = MAIL_INBOX.selectMailIdOnRefresh
end)

SecurePostHook(MAIL_INBOX, "RefreshData", function(mailInboxObj)
		if not SCENE_MANAGER:IsShowing("mailInbox") then
			MAIL_INBOX.inboxDirty = true
		end

		-- Initialize and clear
		MAIL_INBOX.inboxDirty = false
		local tree = MAIL_INBOX.navigationTree

		local masterList = MAIL_INBOX.masterList

		local customList = {}

		local customMailNodeData = { text = GetString(LCQ_MAIL_NO_CUSTOM_MAIL_HEADER), unreadData = {} }
		
		local currentReadMailData = nil

		-- Accumulate data
		for key, customData in pairs(CUSTOM_QUEST_MAIL.customMailData) do
			local mailData = {}
			LCQ_MailInboxShared_PopulateMailData(mailData, customData.customMailId)
			table.insert(masterList, mailData)
			if CUSTOM_QUEST_MAIL.currentMailId and not currentReadMailData and AreId64sEqual(CUSTOM_QUEST_MAIL.currentMailId, customData.customMailId) then
				currentReadMailData = mailData
			end

			table.insert(customList, mailData)
			if mailData.unread then
				customMailNodeData.unreadData[mailData] = true
			end
		end

		table.sort(customList, MailComparator)

		local numCustomMails = #customList

		-- Add BGs
		-- Number of custom mails (or "empty" node if none), plus header node
		local numCustomNodes = zo_max(numCustomMails, 1) + 1
		local numTotalNodes = numCustomNodes or 0
		-- Every other node gets a background
		local numBGControlsToAdd = zo_max(zo_ceil(numTotalNodes / 2), MAIL_INBOX.minNumBackgroundControls)

		local previousBGControl = nil
		for i = 1, numBGControlsToAdd do
			local bgControl = MAIL_INBOX.nodeBGControlPool:AcquireObject()
			if previousBGControl then
				bgControl:SetAnchor(TOPLEFT, previousBGControl, BOTTOMLEFT, 0, ZO_MAIL_INDBOX_KEYBOARD_NODE_HEIGHT)
			else
				bgControl:SetAnchor(TOPLEFT)
			end
			previousBGControl = bgControl
		end

		-- Add header nodes
		customMailNodeData.text = (numCustomMails > 0) and zo_strformat(LCQ_MAIL_CUSTOM_MAIL_HEADER, numCustomMails) or GetString(LCQ_MAIL_NO_CUSTOM_MAIL_HEADER)
		local customMailNode = tree:AddNode("ZO_MailInboxHeader", customMailNodeData)
		
		local autoSelectNode = nil

		-- Add custom nodes
		if numCustomMails > 0 then
			for index, mailData in ipairs(customList) do
				mailData.node = tree:AddNode("ZO_MailInboxRow", mailData, customMailNode)

				if not autoSelectNode then
					if CUSTOM_QUEST_MAIL.selectMailIdOnRefresh then
						if AreId64sEqual(mailData.mailId, CUSTOM_QUEST_MAIL.selectMailIdOnRefresh) then
							autoSelectNode = mailData.node
						end
					elseif CUSTOM_QUEST_MAIL.isFirstTimeOpening then
						-- Select the first node of the system list if opening for the first time and nothing else is auto selecting
						autoSelectNode = mailData.node
					elseif AreId64sEqual(mailData.mailId, CUSTOM_QUEST_MAIL.currentMailId) then
						-- Select the last selected node if it matches a customMailId
						autoSelectNode = mailData.node
					end
				end
			end
		else
			tree:AddNode("ZO_MailInboxEmptyRow", CUSTOM_QUEST_MAIL.customMailEmptyNodeData, customMailNode)
		end
		
		CUSTOM_QUEST_MAIL.isFirstTimeOpening = false
		CUSTOM_QUEST_MAIL.selectMailIdOnRefresh = nil

		local DONT_BRING_PARENT_INTO_VIEW = false
		tree:Commit(autoSelectNode, DONT_BRING_PARENT_INTO_VIEW)

		-- ESO-714031: Edge case where the mail you had been reading when the menu closed may be gone due to expiration when you come back
		-- But the system doesn't end and re-read mail you were already reading when continually opening and closing the menu, for effeciency
		if CUSTOM_QUEST_MAIL.currentMailId and CUSTOM_QUEST_MAIL:GetCustomMailData(CUSTOM_QUEST_MAIL.currentMailId) and not currentReadMailData then
			MAIL_INBOX:EndRead()
		end

		CUSTOM_QUEST_MAIL.customMailNode = customMailNode
		MAIL_INBOX.fullLabel:SetHidden(not (IsLocalMailboxFull() or HasUnreceivedMail()))
end)

----------
-- EXAMPLE REGISTER DATA
----------

--[[

local customMailDataIni = {
	[1] = {
		id = LCQ_MAIL_CUSTOM_ID_ONE,										-- (string) StringId, (not the string)
		senderName = "Mr. Mysterious",										-- (string)
		subject = "A Mysterious Letter",									-- (string) 
		body = "Dear "..GetUnitName("player")..",\n\nWelcome to this demo."	-- (string) 700 Char Limit?
	},
}

CUSTOM_QUEST_MAIL:RegisterMail(addOnName, customMailDataIni)

]]

----------
-- END SECTION
----------