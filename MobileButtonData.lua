--[[
	-Easy module to get created mobile buttons
	-You can use this module without using ContextActionLib if you know how
	-Written by @Eternalness7
]]

local Data = {}

Data.Buttons = {}

function Data.GetButton(actionName)
	for _, btn in pairs(Data.Buttons) do
		if btn.actionName == actionName then
			return btn
		end
	end
	return nil
end

function Data.GetAllButtons()
	return Data.Buttons
end

return Data
