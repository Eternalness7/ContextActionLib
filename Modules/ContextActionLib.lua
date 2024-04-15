--[[
	-Functions as a replacement for ContextActionService, 
	-with the main feature being increased mobile button customization
	-Written by @Eternalness7
	-V0.1
]]
local ContextActionLib = {}

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TouchGui
local TouchControlFrame
local JumpButton
local isMobile = UserInputService.TouchEnabled
if isMobile then
	TouchGui = PlayerGui:WaitForChild("TouchGui")
	TouchControlFrame = TouchGui:WaitForChild("TouchControlFrame")
	JumpButton = TouchControlFrame:WaitForChild("JumpButton")
end

local function FixDefaultJumpButton()
	--Removes the corners of the button interaction hitbox so button can't lock
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = JumpButton
end
FixDefaultJumpButton()

local MobileButton = require(script.MobileButton)
local MobileButtonData = require(script.MobileButtonData)

ContextActionLib.Archivable = ContextActionService.Archivable
ContextActionLib.ClassName = ContextActionService.ClassName
ContextActionLib.Name = ContextActionService.Name
ContextActionLib.Parent = ContextActionService.Parent
ContextActionLib.LocalToolEquipped = ContextActionService.LocalToolEquipped
ContextActionLib.LocalToolUnequipped = ContextActionService.LocalToolUnequipped

function ContextActionLib.BindAction(actionName:string, functionToBind: (actionName:string, inputState:Enum.UserInputState, inputObject:InputObject) -> (), createTouchButton:boolean, inputTypes:Enum.KeyCode|{Enum.KeyCode}, Caller:Script)
	if typeof(inputTypes) == "table" then 	
		ContextActionService:BindAction(actionName, functionToBind, false, unpack(inputTypes))
	elseif typeof(inputTypes) == "EnumItem" then
		ContextActionService:BindAction(actionName, functionToBind, false, inputTypes)
	end
	if Caller then
		Caller.Destroying:Connect(function()
			ContextActionLib.UnbindAction(actionName)
		end)
	end
	if createTouchButton and isMobile then
		local Button = MobileButton.new()
		Button:SetActionName(actionName)
		Button:SetFunctionToBind(functionToBind)
	end
end

function ContextActionLib.BindActionAtPriority(actionName:string, functionToBind: (actionName:string, inputState:Enum.UserInputState, inputObject:InputObject) -> (), createTouchButton:boolean, priorityLevel:number, inputTypes:Enum.KeyCode|{Enum.KeyCode}, Caller:Script)
	if typeof(inputTypes) == "table" then
		ContextActionService:BindActionAtPriority(actionName, functionToBind, false, priorityLevel, unpack(inputTypes))
	elseif typeof(inputTypes) == "EnumItem" then
		ContextActionService:BindActionAtPriority(actionName, functionToBind, false, priorityLevel, inputTypes)
	end
	if Caller then
		Caller.Destroying:Connect(function()
			ContextActionLib.UnbindAction(actionName)
		end)
	end
	if createTouchButton and isMobile then
		local Button = MobileButton.new()
		Button:SetActionName(actionName)
		Button:SetFunctionToBind(functionToBind)
	end
end

function ContextActionLib.GetAllBoundActionInfo()
	return ContextActionService:GetAllBoundActionInfo()
end

function ContextActionLib.GetBoundActionInfo()
	return ContextActionService:GetBoundActionInfo()
end

function ContextActionLib.SetDescription(actionName:string, description:string)
	ContextActionService:SetDescription(actionName, description)
end

function ContextActionLib.SetImage(actionName:string, image:string)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:SetImage(image)
	end
end

function ContextActionLib.SetPosition(actionName:string, position:UDim2)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:SetPosition(position)
	end
end

function ContextActionLib.SetSize(actionName:string, size:UDim2)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:SetSize(size)
	end
end

function ContextActionLib.SetTitle(actionName:string, title:string)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:SetTitle(title)
	end
end

function ContextActionLib.UnbindAction(actionName:string)
	ContextActionService:UnbindAction(actionName)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:Remove()
	end
end

function ContextActionLib.UnbindAllActions()
	ContextActionService:UnbindAllActions()
	if MobileButtonData.GetAllButtons() ~= {} then
		for name, btn in pairs(MobileButtonData.GetAllButtons()) do
			btn:Remove()
		end
	end
end

function ContextActionLib.GetButton(actionName:string)
	if isMobile then
		return MobileButtonData.GetButton(actionName).instances.Button
	end
	return nil
end

function ContextActionLib.GetButtonData(actionName:string)
	if isMobile then
		return MobileButtonData.GetButton(actionName)
	end
	return nil
end

function ContextActionLib.GetAllButtons()
	if isMobile then
		local btns = {Instance}
		for _, btn in pairs(MobileButtonData.GetAllButtons()) do
			btns[#btns+1] = btn
		end
		return btns
	end
	return nil
end 

function ContextActionLib.GetAllButtonData()
	if isMobile then
		return MobileButtonData.GetAllButtons()
	end
	return nil
end 

function ContextActionLib.EnableButton(actionName:string)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:Enable()
	end
end

function ContextActionLib.DisableButton(actionName:string)
	local button = MobileButtonData.GetButton(actionName)
	if isMobile and button then
		button:Disable()
	end
end

function ContextActionLib.GetJumpButton()
	if isMobile then
		return MobileButton.GetJumpButton()
	end
	return nil
end

function ContextActionLib.ToggleUserSetPositionMode(enabled:boolean, buttonactionNames:{string})
	if isMobile then
		local buttons = {}
		for _, actionName in ipairs(buttonactionNames) do
			table.insert(buttons, MobileButtonData.GetButton(actionName))
		end
		MobileButton.ToggleUserSetPositionMode(enabled, buttons)
	end
end

return ContextActionLib
