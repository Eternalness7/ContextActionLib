--[[
	-Creates the mobile buttons for use
	-You can use this module without using ContextActionLib for unbinded mobile buttons if you know how
	-Written by @Eternalness7
]]

if game.UserInputService.TouchEnabled == false then return {} end
local MobileButton = {}
MobileButton.__index = MobileButton

--Config
local ChangeApperanceOnTouch = false

--Variables
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

local MobileButtonData = require(script.Parent.MobileButtonData)

local DefaultButtonSize = JumpButton.Size
local DefaultButtonPosition = UDim2.new(0.5, 0, 0.5, 0) --UDim2.new(-0.4169, 0, 0.715, 0)
local DefaultButtonImage = "rbxassetid://16668879289" --"rbxassetid://16659918208"

local connections = {}
local positionSaves = {} --{actionName = Position}
local oldTouches = {}
UserInputService.InputEnded:Connect(function(inputObject)
	oldTouches[inputObject] = nil
end)

function MobileButton.GetJumpButton()
	return JumpButton
end

function MobileButton.ToggleUserSetPositionMode(enabled, buttons)
	for _, btn in pairs(buttons) do
		btn:SetEnabled(enabled)
		btn:SetDraggable(enabled)
	end
	if enabled then
		for _, btn in pairs(buttons) do
			connections[btn.actionName.."PosChange"] = btn.instances.Button:GetPropertyChangedSignal("Position"):Connect(function()
				btn.position = btn.instances.Button.Position
				positionSaves[btn.actionName] = btn.position
			end)
		end
	elseif not enabled then
		for _, btn in pairs(buttons) do
			if connections[btn.actionName.."PosChange"] then
				connections[btn.actionName.."PosChange"]:Disconnect()
				connections[btn.actionName.."PosChange"] = nil
			end
		end
	end
end

function MobileButton.GetMobileButtonPositions()
	local t = {}
	for actionName, btn in pairs(MobileButtonData.GetAllButtons()) do
		t[actionName] = btn.position
	end
	return t
end

function MobileButton.ApplyMobileButtonPositions(positions:{string:UDim2})
	positionSaves = positions
	if positions ~= nil then
		for actionName, btn in pairs(MobileButtonData.GetAllButtons()) do
			btn:SetPosition(positionSaves[actionName])
		end
	end
end

function ButtonDown(button, inputObject, actionName, functionToBind)
	if not button.enabled then return end
	local Button = button.instances.Button
	local Title = button.instances.Title
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		functionToBind(actionName, Enum.UserInputState.Begin, inputObject)
		if ChangeApperanceOnTouch then
			Button.ImageColor3 = Button.BorderColor3
			if Title.Visible then
				Title.TextColor3 = Button.BorderColor3
			end
		end
	end
end

function ButtonMoved(button, inputObject, actionName, functionToBind)
	if not button.enabled then return end
	local Button = button.instances.Button
	local Title = button.instances.Title
	if inputObject.UserInputType == Enum.UserInputType.Touch and inputObject.UserInputState == Enum.UserInputState.End then
		functionToBind(actionName, Enum.UserInputState.Change, inputObject)
		if ChangeApperanceOnTouch then
			Button.ImageColor3 = Button.BorderColor3
			if Title.Visible then
				Title.TextColor3 = Button.BorderColor3
			end
		end
	end
end

function ButtonUp(button, inputObject, actionName, functionToBind)
	if not button.enabled then return end
	local Button = button.instances.Button
	local Title = button.instances.Title
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		functionToBind(actionName, Enum.UserInputState.End, inputObject)
		if ChangeApperanceOnTouch then
			Button.ImageColor3 = Button.BackgroundColor3
			if Title.Visible then
				Title.TextColor3 = Button.BackgroundColor3
			end
		end
	end
end

function BindButton(MobileButton, actionName, functionToBind)
	local Button = MobileButton.instances.Button
	local Title = MobileButton.instances.Title
	connections[actionName] = {}

	local currentButtonTouch = nil

	local function inputBegan(inputObject)
		if oldTouches[inputObject] then return end

		if inputObject.UserInputState == Enum.UserInputState.Begin and currentButtonTouch == nil then
			currentButtonTouch = inputObject
			ButtonDown(MobileButton, inputObject, actionName, functionToBind)
		end
	end
	connections.Began = Button.InputBegan:Connect(inputBegan)

	local function inputChanged(inputObject)
		if oldTouches[inputObject] then return end
		if currentButtonTouch ~= inputObject then return end

		ButtonMoved(MobileButton, inputObject, actionName, functionToBind)
	end
	connections.Changed = Button.InputChanged:Connect(inputChanged)

	local function inputEnded(inputObject)
		if oldTouches[inputObject] then return end
		if currentButtonTouch ~= inputObject then return end

		currentButtonTouch = nil
		oldTouches[inputObject] = true
		ButtonUp(MobileButton, inputObject, actionName, functionToBind)
	end
	connections.End = Button.InputEnded:Connect(inputEnded)

--[[local function mouseLeaveHandler()
		if not MobileButton.draggable and MobileButton.UpdateInputAppearance then
			Button.ImageColor3 = Button.BackgroundColor3
			if Title.Visible then
				Title.TextColor3 = Button.BackgroundColor3
			end
		end
	end
	connections.MouseLeave = Button.MouseLeave:Connect(mouseLeaveHandler)]]
end

function UnbindButton(MobileButton, actionName)
	MobileButton.bindedFunction = nil
	if connections[actionName] then
		for name, connection in ipairs(connections[actionName]) do
			connection:Disconnect()
		end 
	end
	connections[actionName] = nil
end

function MobileButton.new()
	local self = {}
	setmetatable(self, MobileButton)

	self.actionName = ""
	self.name = "ContextActionButton"
	self.title = ""
	self.imageId = DefaultButtonImage
	self.iconId = ""
	self.enabled = true
	self.size = DefaultButtonSize
	self.position = DefaultButtonPosition
	self.bindedFunction = nil
	self.draggable = false

	local instances = {}
	self.instances = instances
	instances.Button = Instance.new("ImageButton")
	instances.Button.Name = self.name
	instances.Button.Size = self.size
	instances.Button.Position = self.position
	instances.Button.Image = self.imageId
	instances.Button.Draggable = self.draggable
	instances.Button.BackgroundTransparency = 1
	instances.Button.ImageTransparency = 0.5
	--Used for unactivated color
	instances.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	--Used for activated color
	instances.Button.BorderColor3 = Color3.fromRGB(125, 125, 125)
	instances.Button.Parent = TouchControlFrame

	instances.Title = Instance.new("TextLabel")
	instances.Title.Name = "Title"
	instances.Title.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Title.Position = UDim2.new(0.5, 0, 0.5, 0)
	instances.Title.BackgroundTransparency = 1
	instances.Title.Size = UDim2.new(0.75, 0, 0.45, 0)
	instances.Title.Font = Enum.Font.SourceSansBold
	instances.Title.TextScaled = true
	instances.Title.TextTransparency = 0.5
	instances.Title.TextColor3 = Color3.new(255, 255, 255)
	instances.Title.TextXAlignment = Enum.TextXAlignment.Center
	instances.Title.TextYAlignment = Enum.TextYAlignment.Center
	instances.Title.Visible = false
	instances.Title.Text = self.title
	instances.Title.Parent = instances.Button

	instances.Icon = Instance.new("ImageLabel")
	instances.Icon.Name = "Icon"
	instances.Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	instances.Icon.Position = UDim2.new(0.514, 0, 0.525, 0)
	instances.Icon.BackgroundTransparency = 1
	instances.Icon.Size = UDim2.new(0.7, 0, 0.7, 0)
	instances.Icon.Visible = false
	instances.Icon.Image = self.iconId
	instances.IconAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	instances.IconAspectRatioConstraint.Parent = instances.Icon 
	instances.Icon.Parent = instances.Button

	--Without this the jump button locks in the jump state because the input ends incorrectly. Dont let the button hitboxes overlap the jump button hit box.
	instances.Corner = Instance.new("UICorner")
	instances.Corner.CornerRadius = UDim.new(0.5, 0)
	instances.Corner.Parent = instances.Button

	MobileButtonData.Buttons[self.actionName] = self

	return self
end

function MobileButton:SetName(name)
	self.name = name
	self.instances.Button.Name = name
end

function MobileButton:SetActionName(actionName)
	MobileButtonData.Buttons[self.actionName] = nil --remove the old one lol
	self.actionName = actionName
	if self.name == "ContextActionButton" then
		self:SetName(actionName)
	end
	MobileButtonData.Buttons[self.actionName] = self
end

function MobileButton:SetFunctionToBind(functionToBind)
	self.bindedFunction = functionToBind
	BindButton(self, self.actionName, functionToBind)
end

function MobileButton:SetTitle(title)
	self.title = title
	self.instances.Button.Title.Text = title
	self.instances.Button.Title.Visible = title ~= ""
end

function MobileButton:SetImage(image)
	self.imageId = image
	self.instances.Button.Image = image
end

function MobileButton:SetIcon(icon)
	self.iconId = icon
	self.instances.Icon.Image = icon
	self.instances.Icon.Visible = icon ~= ""
end

function MobileButton:SetSize(size)
	self.size = size
	self.instances.Button.Size = size
end

function MobileButton:SetPosition(position)
	if position ~= nil then
		self.position = position
		self.instances.Button.Position = position
	end
end

function MobileButton:ResetPosition(position)
	if positionSaves[self.actionName] then
		positionSaves[self.actionName] = nil
		self.position = position
		self.instances.Button.Position = position
	end
end

function MobileButton:SetDraggable(draggable)
	self.draggable = draggable
	self.instances.Button.Draggable = draggable
end

function MobileButton:Enable()
	self.enabled = true
end

function MobileButton:Disable()
	self.enabled = false
end

function MobileButton:SetEnabled(enabled:boolean) --lol
	self.enabled = enabled
end

function MobileButton:UpdateData()
	self.name = self.instances.Button.Name
	self.size = self.instances.Button.Size
	self.position = self.instances.Button.Position
	self.imageId = self.instances.Button.Image
	self.iconId = self.instances.Icon.Image
	self.title = self.instances.Title.Text
	self.draggable = self.instances.Button.Draggable
end

function MobileButton:WriteToProperty(instanceType, property, value)
	if self.instances[instanceType] ~= nil then
		self.instances[instanceType][property] = value
	end
	self:UpdateData()
end

function MobileButton:WriteToKey(property, value)
	self[property] = value
	self:UpdateData()
end

function MobileButton:ToggleInputAppearance(value)
	self.UpdateInputAppearance = value
end

function MobileButton:WhitelistButton()
	MobileButtonData.Buttons[self.actionName] = self
end

function MobileButton:BlacklistButton()
	MobileButtonData.Buttons[self.actionName] = nil
end

function MobileButton:Remove()
	self.instances.Button:Destroy()
	MobileButtonData.Buttons[self.actionName] = nil
	UnbindButton(MobileButton, self.actionName)
	table.clear(self)
end

return MobileButton
