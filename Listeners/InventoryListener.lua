-----------------------------------------
-- Inventory Listener
-----------------------------------------

LCQInventoryListener = LCQListener:Subclass()

function LCQInventoryListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQInventoryListener:Initialize(...)
    self.name = "InventoryListener"
    self.targets = {}

   

    LCQ_DBG:Verbose("Listener: Inventory listener initalized")
end

function LCQInteractionListener.HasItemInInventory(item, amount)
    local slot = ZO_GetNextBagSlotIndex(BAG_BACKPACK)
    while slot do
        -- GetItemId(bag, slot) -> itemId
        -- GetItemInfo(bag, slot) -> icon, stack, sellPrice, meetsUsageRequirement, locked, EquipType equipType, itemStyleId, ItemQuality quality
        -- GetItemLink(bag, slot) -> link
        -- GetItemName(bag, slot) -> name
        -- GetItemQuality(bag, slot) -> ItemQuality quality
        -- GetItemType(bag, slot) -> ItemType type, SpecializedItemType specialType
        slot = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slot)
    end
end