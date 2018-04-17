AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetColor(self.PrinterColor)
	self:SetCollisionGroup(15)
	self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
	self.sound:SetSoundLevel(52)
	self.sound:PlayEx(1, 100)

	self:SetNW2Int("MoneyStored", 0)
	self:SetNW2Float("Battery", 100)
	self:SetNW2Float("Temperature", 25)
	self:SetNW2Bool("IsSilent", false)
	self:SetNW2Bool("HasCooler", false)
	self:SetNW2Bool("HasRecharger", false)

	self.timer = 0

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:RewardPlayerDestroyed(ply)
	if not IsValid(ply) or not ply:IsPlayer() or ply == self:GetOwner() then
		return
	end

	DarkRP.createMoneyBag(self:GetPos() + Vector(0, 0, 10), self:GetNW2Int("MoneyStored") + self.PrinterPrice)
end

function ENT:OnTakeDamage(dmg)
	self.PrinterHealth = self.PrinterHealth - dmg:GetDamage()

	if self.PrinterHealth <= 0 then
		self:RewardPlayerDestroyed(dmg:GetAttacker())

		self:Explode()
	end
end

function ENT:Explode()
	local effect = EffectData()

	effect:SetStart(self:GetPos())
	effect:SetOrigin(self:GetPos())
	effect:SetScale(1)
	util.Effect("Explosion", effect)
	self:Remove()
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:Think()
	self:NextThink(CurTime() + .5)

	--[[ Automatic recharging ]]--
	if self:GetNW2Bool("HasRecharger") and self:GetNW2Float("Battery") <= 25 and not timer.Exists("PrinterRecharge" .. tostring(self)) then
		timer.Create("PrinterRecharge" .. tostring(self), .1, 0, function()
		if not IsValid(self) or self:GetNW2Float("Battery") >= 95 then
			timer.Remove("PrinterRecharge" .. tostring(self))
			return true
		end

			self:SetNW2Float("Battery", self:GetNW2Float("Battery") + 1)
		end)
	end

	--[[ Automatic cooling ]]--
	if self:GetNW2Bool("HasCooler") and self:GetNW2Float("Temperature") >= 50 and not timer.Exists("PrinterCool" .. tostring(self)) then
		timer.Create("PrinterCool" .. tostring(self), .1, math.random(10, 35), function()
			if not IsValid(self) then
				timer.Remove("PrinterCool" .. tostring(self))
				return true
			end

			self:SetNW2Float("Temperature", self:GetNW2Float("Temperature") - 1)
		end)
	end

	if self:GetNW2Bool("IsSilent") and self.sound:IsPlaying() then
		self.sound:Stop()
	end

	if self:GetNW2Float("Battery") <= 0 then
		self.sound:Stop()
	elseif not self:GetNW2Bool("IsSilent") and not (self.sound or self.sound:IsPlaying()) then
		self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
		self.sound:SetSoundLevel(52)
		self.sound:PlayEx(1, 100)
	end

	if self:GetNW2Float("Temperature") >= 75 then
		self:Explode()
	end

	--[[ Update printer values ]]--
	if self:GetNW2Float("Battery") > 0 and CurTime() > (self.timer + self.PrintTime) then
		self.timer = CurTime()

		self.curStored = self:GetNW2Int("MoneyStored")
		self:SetNW2Int("MoneyStored", self.curStored + self.MoneyPerPrint)

		self.curBattery = self:GetNW2Float("Battery")
		self:SetNW2Float("Battery", self.curBattery - self.BatteryDecrementPerPrint)

		self.curTemp = self:GetNW2Float("Temperature")
		self:SetNW2Float("Temperature", self.curTemp + self.TemperatureIncrementPerPrint)

		if self.ResetSoundPerPrint then
			self.sound:Stop()
			self.sound:PlayEx(1, 100)
		end
	end

	return true
end

function ENT:RechargeBattery(c)
	if c:getDarkRPVar("money") >= self.RechargePrice and self:GetNW2Float("Battery") < 95 then
		c:addMoney(-self.RechargePrice)

		self:SetNW2Float("Battery", 100)
	end
end

function ENT:CollectPrinter(c)
	local moneyStored = self:GetNW2Int("MoneyStored")

	self:SetNW2Int("MoneyStored", 0)
	c:addMoney(moneyStored)
end

function ENT:Use(a, c, usetype, value)
	local TraceLine = util.TraceLine({start = c:GetShootPos(), endpos = c:GetAimVector() * 128 + c:GetShootPos(), filter = c})
	local HitPosition = self:WorldToLocal(TraceLine.HitPos)

	-- print(HitPosition.x .. " " .. HitPosition.y)

	if TraceLine.Entity == self
	and HitPosition.x >= 10.29176235199
	and HitPosition.x <= 11.618851661682
	and HitPosition.y >= -11.73853302002
	and HitPosition.y <= -1.4332900047302
	and c:KeyDown(IN_USE) then
		self:RechargeBattery(c)
	end

	if TraceLine.Entity == self
	and HitPosition.x >= 1.2818530797958
	and HitPosition.x <= 3.110196352005
	and HitPosition.y >= -9.0663061141968
	and HitPosition.y <= 9.8833808898926
	and c:KeyDown(IN_USE) then
		self:CollectPrinter(c)
	end

	if TraceLine.Entity == self
	and HitPosition.x >= 10.045016288757
	and HitPosition.x <= 11.906805992126
	and HitPosition.y >= 2.1385428905487
	and HitPosition.y <= 12.304306030273
	and c:KeyDown(IN_USE) and self:GetNW2Float("Temperature") > 16 then
		self:SetNW2Float("Temperature", self:GetNW2Float("Temperature") - 1)
	end
end

function ENT:Touch(entity)
	local class = entity:GetClass()

	if class == "printer_addon_silent" and not self:GetNW2Bool("IsSilent") and not entity.used then
		entity.used = true -- entity:Remove() isn't instant. this prevents duplication of printer addons

		self:SetNW2Bool("IsSilent", true)
		entity:Remove()
	elseif class == "printer_addon_cooler" and not self:GetNW2Bool("HasCooler") and not entity.used then
		entity.used = true

		self:SetNW2Bool("HasCooler", true)
		entity:Remove()
	elseif class == "printer_addon_solarpower" and not self:GetNW2Bool("HasRecharger") and not entity.used then
		entity.used = true

		self:SetNW2Bool("HasRecharger", true)
		entity:Remove()
	end
end
