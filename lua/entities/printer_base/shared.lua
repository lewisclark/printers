ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Printer Base"
ENT.Spawnable = false

ENT.PrinterColor = Color(255, 255, 255, 255)
ENT.PrintTime = 0.1
ENT.MoneyPerPrint = 10
ENT.RechargePrice = 500
ENT.TemperatureIncrementPerPrint = 0.05
ENT.BatteryDecrementPerPrint = 0.11
ENT.PrinterHealth = 100

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
end