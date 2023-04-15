-----------------------------------------
-- Currency Listener
-----------------------------------------

LCQCurrencyListener = LCQListener:Subclass()

function LCQCurrencyListener:New(...)
    local listener = LCQListener.New(self, ...)
    listener:Initialize(...)
    return listener
end

function LCQCurrencyListener:Initialize(...)
    self.name = "CurrencyListener"
    self.targets = {}

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CURRENCY_UPDATE, function(...) self:Update(...) end)

    LCQ_DBG:Verbose("Listener: Currency listener initalized.")
end

function LCQCurrencyListener:Update(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason)
    -- If the currency update is not on the current character, bail
    if currencyLocation ~= CURRENCY_LOCATION_CHARACTER then return end

    -- If the player has lost money, bail
    local difference = newAmount - oldAmount
    if difference <= 0 then return end

    -- No cheating :P
    if  reason == CURRENCY_CHANGE_REASON_PLAYER_INIT or
        reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or
        reason == CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL or
        reason == CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY or
        reason == CURRENCY_CHANGE_REASON_MAIL or
        reason == CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND then
            return
    end

    for _, target in ipairs(self.targets) do
        if currencyType == target.currencyType then
            target.amount = target.amount - difference

            if target.amount <= 0 then
                self:FireCallbacks("OnConditionMet", target)
            else
                self:FireCallbacks("OnConditionUpdate", target)
            end
        end
    end

end