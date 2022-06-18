local ADDON_DATA = 1
local SECTION_HEADER_DATA = 2

local IS_LIBRARY = true
local IS_ADDON = false
local IS_QUESTPACK = "LCQ"

local AddOnManager = GetAddOnManager()

local expandedAddons = {}

local g_uniqueNamesByCharacterName = {}
local function CreateAddOnFilter(characterName)
    local uniqueName = g_uniqueNamesByCharacterName[characterName]
    if not uniqueName then
        uniqueName = GetUniqueNameForCharacter(characterName)
        g_uniqueNamesByCharacterName[characterName] = uniqueName
    end
    return uniqueName
end

local function StripText(text)
    return text:gsub("|c%x%x%x%x%x%x", "")
end

local function BuildMasterList(self)
    self.addonTypes = {}
    self.addonTypes[IS_LIBRARY] = {}
    self.addonTypes[IS_ADDON] = {}
    self.addonTypes[IS_QUESTPACK] = {}

    if self.selectedCharacterEntry and not self.selectedCharacterEntry.allCharacters then
        self.isAllFilterSelected = false
        AddOnManager:SetAddOnFilter(CreateAddOnFilter(self.selectedCharacterEntry.name))
    else
        self.isAllFilterSelected = true
        AddOnManager:RemoveAddOnFilter()
    end

    for i = 1, AddOnManager:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = AddOnManager:GetAddOnInfo(i)
        local entryData = {
            index = i,
            addOnFileName = name,
            addOnName = title,
            strippedAddOnName = StripText(title),
            addOnDescription = description,
            addOnEnabled = enabled,
            addOnState = state,
            isOutOfDate = isOutOfDate,
            isLibrary = isLibrary,
            isCustomQuestPack = false,
        }

        if author ~= "" then
            local strippedAuthor = StripText(author)
            entryData.addOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, author)
            entryData.strippedAddOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, strippedAuthor)
        else
            entryData.addOnAuthorByLine = ""
            entryData.strippedAddOnAuthorByLine = ""
        end

        local dependencyText = ""
        for j = 1, AddOnManager:GetAddOnNumDependencies(i) do
            local dependencyName, dependencyExists, dependencyActive, dependencyMinVersion, dependencyVersion = AddOnManager:GetAddOnDependencyInfo(i, j)
            local dependencyTooLowVersion = dependencyVersion < dependencyMinVersion
            
            -- Mark it as a quest pack
            if dependencyName == "LibCustomQuest" then
                entryData.isCustomQuestPack = true
            end
            
            
            local dependencyInfoLine = dependencyName
            if not self.isAllFilterSelected and (not dependencyActive or not dependencyExists or dependencyTooLowVersion) then
                entryData.hasDependencyError = true
                if not dependencyExists then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_MISSING, dependencyName)
                elseif not dependencyActive then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_DISABLED, dependencyName)
                elseif dependencyTooLowVersion then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_TOO_LOW_VERSION, dependencyName)
                end
                dependencyInfoLine = ZO_ERROR_COLOR:Colorize(dependencyInfoLine)
            end
            dependencyText = string.format("%s\n    %s  %s", dependencyText, GetString(SI_BULLET), dependencyInfoLine)
        end
        entryData.addOnDependencyText = dependencyText

        entryData.expandable = (description ~= "") or (dependencyText ~= "")
        
        if entryData.isCustomQuestPack == true then
            table.insert(self.addonTypes[IS_QUESTPACK], entryData)
        else
            table.insert(self.addonTypes[isLibrary], entryData)
        end
    end
end

local _AddAddonTypeSection = ADD_ON_MANAGER.AddAddonTypeSection
local function AddAddonTypeSection(self, isLibrary, sectionTitleText)
    if isLibrary == IS_QUESTPACK then
        local addonEntries = self.addonTypes[IS_QUESTPACK]
        table.sort(addonEntries, self.sortCallback)

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SECTION_HEADER_DATA, { isLibrary = IS_QUESTPACK, text = sectionTitleText })
        for _, entryData in ipairs(addonEntries) do
            if entryData.expandable and expandedAddons[entryData.index] then
                entryData.expanded = true

                local useHeight, typeId = self:SetupTypeId(entryData.addOnDescription, entryData.addOnDependencyText)

                entryData.height = useHeight
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(typeId, entryData)
            else
                entryData.height = ZO_ADDON_ROW_HEIGHT
                scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, entryData)
            end
        end
    else
        _AddAddonTypeSection(self, isLibrary, sectionTitleText)
    end
end

local _SetupSectionHeaderRow = ADD_ON_MANAGER.SetupSectionHeaderRow
local function SetupSectionHeaderRow(self, control, data)
    if data.isLibrary == IS_QUESTPACK then
        control.textControl:SetText(data.text)
        control.checkboxControl:SetHidden(true)
    else
        _SetupSectionHeaderRow(self, control, data)
    end
end

local function SortScrollList(self)
    self:ResetDataTypes()
    local scrollData = ZO_ScrollList_GetDataList(self.list)        
    ZO_ClearNumericallyIndexedTable(scrollData)

    self:AddAddonTypeSection(IS_ADDON, GetString(SI_WINDOW_TITLE_ADDON_MANAGER))
    self:AddAddonTypeSection(IS_QUESTPACK, GetString(LCQ_ADDON_CATEGORY))
    self:AddAddonTypeSection(IS_LIBRARY, GetString(SI_ADDON_MANAGER_SECTION_LIBRARIES))
end

function OnExpandButtonClicked(self, row)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local data = ZO_ScrollList_GetData(row)

    if expandedAddons[data.index] then
        expandedAddons[data.index] = false

        data.expanded = false
        data.height = ZO_ADDON_ROW_HEIGHT
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, data)
    else
        expandedAddons[data.index] = true

        local useHeight, typeId = self:SetupTypeId(data.addOnDescription, data.addOnDependencyText)

        data.expanded = true
        data.height = useHeight
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(typeId, data)
    end

    self:CommitScrollList()
end

ADD_ON_MANAGER.BuildMasterList = BuildMasterList
ADD_ON_MANAGER.AddAddonTypeSection = AddAddonTypeSection
ADD_ON_MANAGER.SetupSectionHeaderRow = SetupSectionHeaderRow
ADD_ON_MANAGER.SortScrollList = SortScrollList
ADD_ON_MANAGER.OnExpandButtonClicked = OnExpandButtonClicked