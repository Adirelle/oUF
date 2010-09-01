local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF_HealPrediction was unable to locate oUF install')

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	local hp = self.HealPrediction

	if not hp then return end

	if hp.PreUpdate then hp:PreUpdate(unit) end

	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0

	local health = self.Health:GetValue()
	local _, maxHealth = frame.Health:GetMinMaxValues()

	if(health + allIncomingHeal > maxHealth * self.maxHealPredictionOverflow) then
		allIncomingHeal = maxHealth * self.maxHealPredictionOverflow - health
	end

	if allIncomingHeal < myIncomingHeal then
		myIncomingHeal = allIncomingHeal
		allIncomingHeal = 0
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	if hp.myBar then
		if event == 'UNIT_MAXHEALTH' then
			hp.myBar:SetMinMaxValues(0, maxHealth)
		end

		hp.myBar:SetValue(myIncomingHeal)
		hp.myBar:Show()
	end

	if hp.otherBar then
		if event == 'UNIT_MAXHEALTH' then
			hp.otherBar:SetMinMaxValues(0, maxHealth)
		end

		hp.otherBar:SetValue(allIncomingHeal)
		hp.otherBar:Show()
	end

	if hp.PostUpdate then hp:PostUpdate(unit) end
end


local function Path(self, ...)
	return (self.HealPrediction.Override or Update) (self, ...)
end


local function Enable(self)
	local hp = self.HealPrediction
	if not hp then return end

	self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)
	self:RegisterEvent('UNIT_MAXHEALTH', Path)
	self:RegisterEvent('UNIT_HEALTH', Path)

	if not hp.maxOverflow then
		hp.maxOverflow = 1.05
	end

	if hp.myBar and not hp.myBar:GetStatusBarTexture() then
		hp.myBar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
	end
	if hp.otherBar and not hp.otherBar:GetStatusBarTexture() then
		hp.otherBar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
	end

	return true
end


local function Disable(self)
	local hp = self.HealPrediction
	if hp then
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
	end
end

oUF:AddElement('HealPrediction', Update, Enable, Disable)
