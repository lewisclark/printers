include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 200000 then return end

	local owning_ent = self:Getowning_ent()
	local owner = IsValid(owning_ent) and owning_ent:Nick() or "UNKNOWN"

	local pos = self:GetPos()
	local ang = self:GetAngles()

	self.curBattery = self:GetNW2Float("Battery")
	self.curBatteryD = self.curBattery / 100

	ang:RotateAroundAxis(ang:Up(), 90)

	cam.Start3D2D(pos + ang:Up() * 10.7, ang, 0.11)
		-- Main square
		draw.RoundedBox(3, -127, -141, 259, 265, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -125, -139, 255, 261, Color(30, 30, 30, 255))

		-- Owner box
		draw.RoundedBox(3, -117, -130, 240, 36, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -115, -128, 236, 32, Color(55, 55, 55, 255))

		-- Printer Name box
		draw.RoundedBox(3, -117, -84, 240, 36, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -115, -82, 236, 32, Color(55, 55, 55, 255))

		-- Money box
		draw.RoundedBox(3, -117, -37, 240, 74, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -115, -35, 236, 70, Color(55, 55, 55, 255))

		-- Collect Money box
		draw.RoundedBox(3, -87, 10, 180, 21, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -85, 12, 176, 17, Color(55, 255, 55, 255))
		draw.SimpleText("Collect", "PrinterFontMoneyCollect", 0, 20, Color(255, 255, 255, 255), 1, 1)

		-- Battery box
		draw.RoundedBox(3, -117, 46, 112, 68, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, -115, 48, 108, 64, Color(55, 55, 55, 255))
		draw.SimpleText("Battery:", "PrinterFontMoneyCollect", -110, 60, Color(255, 255, 255, 255), 0, 1)
		draw.SimpleText(math.Round(self.curBattery) .. "%", "PrinterFontMoneyCollect", -52, 60, Color(255, 255, 255, 255), 0, 1)
		draw.RoundedBox(1, -107, 75, 92, 10, Color(90, 90, 90, 255)) -- Battery bar outline
		if self.curBattery > 0 then
			draw.RoundedBox(1, -107, 75, 92 * math.Clamp(self.curBatteryD, 0, 1), 10, Color(55, 255, 55, 255)) -- Battery bar
		end
		if not self:GetNW2Bool("HasRecharger") then
			draw.RoundedBox(1, -109, 90, 96, 18, Color(90, 90, 90, 255)) -- Recharge outline
			draw.RoundedBox(1, -107, 92, 92, 14, Color(55, 255, 55, 255)) -- Recharge
			draw.SimpleText("Recharge (" .. DarkRP.formatMoney(self.RechargePrice) .. ")", "PrinterRecharge", -62, 98, Color(255, 255, 255, 255), 1, 1)
		else
			draw.SimpleText("Solar Power Installed", "PrinterRechargee", -61, 99, Color(255, 255, 255, 255), 1, 1)
		end

		-- Cooler box
		self.curTemp = self:GetNW2Float("Temperature")
		self.tempColor = Color(0, 220, 255, 255)

		self.curTempD = self.curTemp / 75

		if self.curTemp < 30 then self.tempColor = Color(0, 220, 255, 255) end
		if self.curTemp >= 30 and self.curTemp < 60 then self.tempColor = Color(255, 157, 0, 255) end
		if self.curTemp >= 60 and self.curTemp < 100 then self.tempColor = Color(255, 50, 50, 255) end

		draw.RoundedBox(3, 9, 46, 114, 68, Color(90, 90, 90, 255)) -- Outline
		draw.RoundedBox(3, 11, 48, 110, 64, Color(55, 55, 55, 255))
		draw.SimpleText("Temperature:", "PrinterTemperature", 13, 60, Color(255, 255, 255, 255), 0, 1)
		draw.SimpleText(math.Round(self.curTemp) .. "C", "PrinterTemperatureNumber", 91, 60, self.tempColor, 0, 1)
		if not self:GetNW2Bool("HasCooler") then
			draw.RoundedBox(1, 18, 90, 96, 18, Color(90, 90, 90, 255)) -- Buy cooler outline
			draw.RoundedBox(1, 20, 92, 92, 14, Color(55, 255, 55, 255)) -- Buy cooler
			draw.SimpleText("Cool", "PrinterRecharge", 63, 98, Color(255, 255, 255, 255), 1, 1)
		else
			draw.SimpleText("Cooler Installed", "PrinterTemperature", 65, 98, Color(255, 255, 255, 255), 1, 1)
		end
		draw.RoundedBox(1, 20, 75, 92, 10, Color(90, 90, 90, 255)) -- Temperature bar outline
		draw.RoundedBox(1, 20, 75, 92 * math.Clamp(self.curTempD, 0, 1), 10, self.tempColor) -- Temperature bar

		draw.SimpleText(owner, "PrinterFontName", 0, -112, Color(255, 255, 255, 255), 1, 1)
		draw.SimpleText(self.PrintName, "PrinterFontName", 0, -67, Color(255, 255, 255, 255), 1, 1)
		draw.SimpleText(DarkRP.formatMoney(self:GetNW2Int("MoneyStored")), "PrinterFontMoney", 0, -12, Color(255, 255, 255, 255), 1, 1)
	cam.End3D2D()
end
