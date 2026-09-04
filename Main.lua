--[[
    ZenexLib — Reusable Roblox UI Library
    
    A clean, minimal, modern dark UI framework.
    Inspired by Orion/Rayfield/Linoria/Kavo concepts with original implementation.
    
    Usage:
        local ZenexLib = loadstring(...)() -- or require(...)
        local Window = ZenexLib:CreateWindow({ Name = "My Hub", Subtitle = "Game - 1.0.0" })
        local Tab = Window:CreateTab({ Name = "Main", Icon = "" })
        Tab:AddButton({ Name = "Click Me", Callback = function() print("Clicked") end })
        -- etc.
]]

-- ============================================================================
-- MODULE TABLE
-- ============================================================================

local ZenexLib = {}
ZenexLib.__index = ZenexLib
ZenexLib._windows = {}
ZenexLib._theme = nil
ZenexLib._connections = {}

-- ============================================================================
-- SERVICES
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- THEME / STYLING
-- ============================================================================

local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    TitleBar = Color3.fromRGB(32, 32, 38),
    TabBar = Color3.fromRGB(28, 28, 34),
    TabActive = Color3.fromRGB(90, 90, 235),
    TabInactive = Color3.fromRGB(45, 45, 52),
    TabHover = Color3.fromRGB(55, 55, 65),
    Container = Color3.fromRGB(30, 30, 36),
    Element = Color3.fromRGB(38, 38, 46),
    ElementBorder = Color3.fromRGB(55, 55, 65),
    ElementHover = Color3.fromRGB(45, 45, 55),
    AccentColor = Color3.fromRGB(90, 90, 235),
    AccentHover = Color3.fromRGB(110, 110, 255),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextDim = Color3.fromRGB(100, 100, 115),
    ToggleOn = Color3.fromRGB(90, 90, 235),
    ToggleOff = Color3.fromRGB(55, 55, 65),
    SliderFill = Color3.fromRGB(90, 90, 235),
    SliderBackground = Color3.fromRGB(45, 45, 55),
    DropdownBackground = Color3.fromRGB(35, 35, 42),
    InputBackground = Color3.fromRGB(35, 35, 42),
    Shadow = Color3.fromRGB(0, 0, 0),
    Notification = Color3.fromRGB(35, 35, 42),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(240, 180, 50),
    Error = Color3.fromRGB(220, 70, 70),
    
    CornerRadius = UDim.new(0, 8),
    CornerRadiusSmall = UDim.new(0, 5),
    CornerRadiusLarge = UDim.new(0, 12),
    
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
    
    TextSize = 13,
    TextSizeSmall = 11,
    TextSizeLarge = 15,
    TextSizeTitle = 16,
    
    ElementHeight = 36,
    ElementPadding = 5,
    SectionPadding = 8,
    ContentPadding = 10,
    
    AnimationSpeed = 0.2,
    AnimationEasing = Enum.EasingStyle.Quart,
    AnimationDirection = Enum.EasingDirection.Out,
    
    WindowWidth = 520,
    WindowHeight = 380,
    TabBarWidth = 130,
    TitleBarHeight = 38,
}

ZenexLib._theme = Theme

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local Utility = {}

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "Parent" then
                pcall(function()
                    instance[prop] = value
                end)
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function Utility.Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or Theme.AnimationSpeed
    easingStyle = easingStyle or Theme.AnimationEasing
    easingDirection = easingDirection or Theme.AnimationDirection
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle, easingDirection),
        properties
    )
    tween:Play()
    return tween
end

function Utility.AddCorner(parent, radius)
    return Utility.Create("UICorner", {
        CornerRadius = radius or Theme.CornerRadius,
        Parent = parent
    })
end

function Utility.AddStroke(parent, color, thickness, transparency)
    return Utility.Create("UIStroke", {
        Color = color or Theme.ElementBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

function Utility.AddPadding(parent, top, right, bottom, left)
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        Parent = parent
    })
end

function Utility.AddListLayout(parent, padding, hAlign, sortOrder)
    return Utility.Create("UIListLayout", {
        Padding = UDim.new(0, padding or Theme.ElementPadding),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

function Utility.AddShadow(parent)
    local holder = Utility.Create("Frame", {
        Name = "ShadowHolder",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = parent
    })
    Utility.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = holder
    })
    return holder
end

function Utility.MakeDraggable(topBar, mainFrame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local connections = {}

    table.insert(connections, topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))

    table.insert(connections, topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    return connections
end

function Utility.Ripple(button)
    local ripple = Utility.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = button.ZIndex + 1,
        Parent = button
    })
    Utility.AddCorner(ripple, UDim.new(1, 0))
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Utility.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.4)
    
    task.delay(0.4, function()
        if ripple and ripple.Parent then
            ripple:Destroy()
        end
    end)
end

function Utility.HoverEffect(button, normalColor, hoverColor)
    local connections = {}
    table.insert(connections, button.MouseEnter:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = hoverColor}, 0.15)
    end))
    table.insert(connections, button.MouseLeave:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = normalColor}, 0.15)
    end))
    return connections
end

function Utility.GenerateId()
    return HttpService:GenerateGUID(false)
end

-- ============================================================================
-- CONFIGURATION SYSTEM
-- ============================================================================

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(configName)
    local self = setmetatable({}, ConfigManager)
    self._name = configName or "ZenexConfig"
    self._flags = {} -- { [flagId] = { Value = ..., Type = ..., Set = function, Get = function } }
    self._saveFolder = "ZenexLib"
    return self
end

function ConfigManager:RegisterFlag(id, flagData)
    self._flags[id] = flagData
end

function ConfigManager:GetFlag(id)
    local flag = self._flags[id]
    if flag and flag.Get then
        return flag.Get()
    end
    return flag and flag.Value
end

function ConfigManager:SetFlag(id, value)
    local flag = self._flags[id]
    if flag and flag.Set then
        flag.Set(value)
    end
end

function ConfigManager:Serialize()
    local data = {}
    for id, flag in pairs(self._flags) do
        local val = flag.Value
        if flag.Type == "Keybind" then
            val = val and val.Name or "Unknown"
        elseif flag.Type == "Color" then
            val = {R = val.R, G = val.G, B = val.B}
        end
        data[id] = {
            Type = flag.Type,
            Value = val
        }
    end
    return HttpService:JSONEncode(data)
end

function ConfigManager:Deserialize(jsonString)
    local success, data = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    if not success or type(data) ~= "table" then return false end
    
    for id, entry in pairs(data) do
        if self._flags[id] then
            local value = entry.Value
            if entry.Type == "Keybind" and type(value) == "string" then
                local ok, enumVal = pcall(function() return Enum.KeyCode[value] end)
                if ok then value = enumVal end
            elseif entry.Type == "Color" and type(value) == "table" then
                value = Color3.new(value.R or 0, value.G or 0, value.B or 0)
            end
            self:SetFlag(id, value)
        end
    end
    return true
end

function ConfigManager:Save()
    local data = self:Serialize()
    if writefile then
        pcall(function()
            if not isfolder(self._saveFolder) then
                makefolder(self._saveFolder)
            end
            writefile(self._saveFolder .. "/" .. self._name .. ".json", data)
        end)
    end
end

function ConfigManager:Load()
    if readfile and isfile then
        local path = self._saveFolder .. "/" .. self._name .. ".json"
        local success, content = pcall(function()
            if isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if success and content then
            return self:Deserialize(content)
        end
    end
    return false
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================

local NotificationManager = {}
NotificationManager._container = nil
NotificationManager._notifications = {}

function NotificationManager:Init(screenGui)
    if self._container then return end
    self._container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -15, 1, -15),
        Size = UDim2.new(0, 280, 1, -30),
        ZIndex = 100,
        Parent = screenGui
    })
    Utility.AddListLayout(self._container, 8, Enum.HorizontalAlignment.Right, Enum.SortOrder.LayoutOrder)
    Utility.AddPadding(self._container, 0, 0, 0, 0)
end

function NotificationManager:Send(options)
    if not self._container then return end
    
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 4
    local notifType = options.Type or "Info" -- Info, Success, Warning, Error
    
    local accentColor = Theme.AccentColor
    if notifType == "Success" then accentColor = Theme.Success
    elseif notifType == "Warning" then accentColor = Theme.Warning
    elseif notifType == "Error" then accentColor = Theme.Error end
    
    local notifFrame = Utility.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Notification,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = self._container
    })
    Utility.AddCorner(notifFrame, Theme.CornerRadius)
    Utility.AddStroke(notifFrame, accentColor, 1, 0.5)
    
    -- Accent line on left
    Utility.Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = notifFrame
    })
    
    local contentFrame = Utility.Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -15, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = notifFrame
    })
    Utility.AddPadding(contentFrame, 8, 5, 8, 5)
    Utility.AddListLayout(contentFrame, 3, Enum.HorizontalAlignment.Left)
    
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = contentFrame
    })
    
    if message ~= "" then
        Utility.Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Theme.FontLight,
            Text = message,
            TextColor3 = Theme.TextSecondary,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = contentFrame
        })
    end
    
    -- Progress bar
    local progressBar = Utility.Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 2,
        Parent = notifFrame
    })
    
    -- Animate in
    notifFrame.BackgroundTransparency = 1
    Utility.Tween(notifFrame, {BackgroundTransparency = 0}, 0.3)
    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then
            Utility.Tween(notifFrame, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.35)
            if notifFrame and notifFrame.Parent then
                notifFrame:Destroy()
            end
        end
    end)
end

-- ============================================================================
-- COMPONENT BUILDERS
-- ============================================================================

local Components = {}

-- Creates the base element holder that all components sit inside
function Components.CreateElementBase(parent, name, height)
    local frame = Utility.Create("Frame", {
        Name = name or "Element",
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or Theme.ElementHeight),
        ClipsDescendants = true,
        Parent = parent
    })
    Utility.AddCorner(frame, Theme.CornerRadiusSmall)
    Utility.AddStroke(frame, Theme.ElementBorder, 1, 0.7)
    return frame
end

-- ============================================================================
-- BUTTON COMPONENT
-- ============================================================================

function Components.Button(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Button"
    local description = config.Description or nil
    local callback = config.Callback or function() end
    
    local totalHeight = description and 48 or Theme.ElementHeight
    local holder = Components.CreateElementBase(parent, "Button_" .. name, totalHeight)
    
    local button = Utility.Create("TextButton", {
        Name = "Clickable",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 2,
        Parent = holder
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, description and 4 or 0),
        Size = UDim2.new(1, -50, 0, description and 20 or totalHeight),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -50, 0, 18),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    -- Arrow indicator
    Utility.Create("TextLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Theme.FontBold,
        Text = "→",
        TextColor3 = Theme.TextDim,
        TextSize = Theme.TextSize,
        ZIndex = 2,
        Parent = holder
    })
    
    local connections = Utility.HoverEffect(holder, Theme.Element, Theme.ElementHover)
    
    button.MouseButton1Click:Connect(function()
        Utility.Ripple(holder)
        
        -- Flash effect
        Utility.Tween(holder, {BackgroundColor3 = Theme.AccentColor}, 0.1)
        task.wait(0.1)
        Utility.Tween(holder, {BackgroundColor3 = Theme.Element}, 0.2)
        
        pcall(callback)
    end)
    
    local buttonObj = {
        Instance = holder,
        _connections = connections,
        SetName = function(self, newName)
            holder:FindFirstChild("Label").Text = newName
        end,
        Destroy = function(self)
            for _, conn in ipairs(self._connections) do
                conn:Disconnect()
            end
            holder:Destroy()
        end
    }
    
    return buttonObj
end

-- ============================================================================
-- TOGGLE COMPONENT
-- ============================================================================

function Components.Toggle(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Toggle"
    local description = config.Description or nil
    local default = config.Default or false
    local callback = config.Callback or function() end
    local flag = config.Flag or nil
    
    local value = default
    local totalHeight = description and 48 or Theme.ElementHeight
    local holder = Components.CreateElementBase(parent, "Toggle_" .. name, totalHeight)
    
    local button = Utility.Create("TextButton", {
        Name = "Clickable",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 2,
        Parent = holder
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, description and 4 or 0),
        Size = UDim2.new(1, -65, 0, description and 20 or totalHeight),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(1, -65, 0, 18),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    -- Toggle switch
    local toggleBg = Utility.Create("Frame", {
        Name = "ToggleBg",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 20),
        ZIndex = 3,
        Parent = holder
    })
    Utility.AddCorner(toggleBg, UDim.new(1, 0))
    
    local toggleKnob = Utility.Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 4,
        Parent = toggleBg
    })
    Utility.AddCorner(toggleKnob, UDim.new(1, 0))
    
    local function updateVisual(newValue, animate)
        if animate ~= false then
            Utility.Tween(toggleBg, {
                BackgroundColor3 = newValue and Theme.ToggleOn or Theme.ToggleOff
            }, 0.2)
            Utility.Tween(toggleKnob, {
                Position = newValue and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            }, 0.2)
        else
            toggleBg.BackgroundColor3 = newValue and Theme.ToggleOn or Theme.ToggleOff
            toggleKnob.Position = newValue and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        end
    end
    
    local function setValue(newValue, skipCallback)
        value = newValue
        updateVisual(value)
        if not skipCallback then
            pcall(callback, value)
        end
        if flag and configManager then
            configManager._flags[flag].Value = value
        end
    end
    
    button.MouseButton1Click:Connect(function()
        setValue(not value)
    end)
    
    local connections = Utility.HoverEffect(holder, Theme.Element, Theme.ElementHover)
    
    local toggleObj = {
        Instance = holder,
        _connections = connections,
        Get = function() return value end,
        Set = function(self, newVal, skipCallback)
            setValue(newVal, skipCallback)
        end,
        SetName = function(self, newName)
            holder:FindFirstChild("Label").Text = newName
        end,
        Destroy = function(self)
            for _, conn in ipairs(self._connections) do
                conn:Disconnect()
            end
            holder:Destroy()
        end
    }
    
    -- Register with config
    if flag and configManager then
        configManager:RegisterFlag(flag, {
            Type = "Toggle",
            Value = value,
            Get = function() return value end,
            Set = function(v)
                setValue(v, false)
            end
        })
    end
    
    -- Set default (skip callback on init)
    updateVisual(value, false)
    
    return toggleObj
end

-- ============================================================================
-- SLIDER COMPONENT
-- ============================================================================

function Components.Slider(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Slider"
    local description = config.Description or nil
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local callback = config.Callback or function() end
    local flag = config.Flag or nil
    local suffix = config.Suffix or ""
    
    local value = math.clamp(default, min, max)
    local totalHeight = description and 62 or 52
    local holder = Components.CreateElementBase(parent, "Slider_" .. name, totalHeight)
    
    local yOffset = description and 4 or 4
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, yOffset),
        Size = UDim2.new(0.6, -12, 0, 18),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    local valueLabel = Utility.Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, yOffset),
        Size = UDim2.new(0.4, -12, 0, 18),
        Font = Theme.Font,
        Text = tostring(value) .. suffix,
        TextColor3 = Theme.AccentColor,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 22),
            Size = UDim2.new(1, -24, 0, 16),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    local sliderBarY = description and 44 or 32
    
    local sliderBg = Utility.Create("Frame", {
        Name = "SliderBg",
        BackgroundColor3 = Theme.SliderBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, sliderBarY),
        Size = UDim2.new(1, -24, 0, 6),
        ZIndex = 2,
        Parent = holder
    })
    Utility.AddCorner(sliderBg, UDim.new(1, 0))
    
    local fillPercent = (value - min) / (max - min)
    
    local sliderFill = Utility.Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.SliderFill,
        BorderSizePixel = 0,
        Size = UDim2.new(fillPercent, 0, 1, 0),
        ZIndex = 3,
        Parent = sliderBg
    })
    Utility.AddCorner(sliderFill, UDim.new(1, 0))
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new(fillPercent, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 4,
        Parent = sliderBg
    })
    Utility.AddCorner(knob, UDim.new(1, 0))
    
    -- Invisible interaction area
    local interactButton = Utility.Create("TextButton", {
        Name = "Interact",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, sliderBarY - 8),
        Size = UDim2.new(1, -24, 0, 22),
        Text = "",
        ZIndex = 5,
        Parent = holder
    })
    
    local sliding = false
    
    local function roundToIncrement(val)
        return math.floor((val - min) / increment + 0.5) * increment + min
    end
    
    local function updateSlider(input)
        local barAbsPos = sliderBg.AbsolutePosition.X
        local barAbsSize = sliderBg.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
        local rawValue = min + (max - min) * percent
        local newValue = roundToIncrement(rawValue)
        newValue = math.clamp(newValue, min, max)
        
        if newValue ~= value then
            value = newValue
            local actualPercent = (value - min) / (max - min)
            
            Utility.Tween(sliderFill, {Size = UDim2.new(actualPercent, 0, 1, 0)}, 0.05)
            Utility.Tween(knob, {Position = UDim2.new(actualPercent, 0, 0.5, 0)}, 0.05)
            valueLabel.Text = tostring(value) .. suffix
            
            pcall(callback, value)
            
            if flag and configManager then
                configManager._flags[flag].Value = value
            end
        end
    end
    
    local slideConnection = nil
    
    interactButton.MouseButton1Down:Connect(function(x, y)
        sliding = true
        -- Process the click position immediately
        local percent = math.clamp((x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local rawValue = min + (max - min) * percent
        local newValue = roundToIncrement(rawValue)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        local actualPercent = (value - min) / (max - min)
        Utility.Tween(sliderFill, {Size = UDim2.new(actualPercent, 0, 1, 0)}, 0.05)
        Utility.Tween(knob, {Position = UDim2.new(actualPercent, 0, 0.5, 0)}, 0.05)
        valueLabel.Text = tostring(value) .. suffix
        pcall(callback, value)
        if flag and configManager then
            configManager._flags[flag].Value = value
        end
        
        slideConnection = UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
    end)
    
    local mouseUpConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
            if slideConnection then
                slideConnection:Disconnect()
                slideConnection = nil
            end
        end
    end)
    
    local sliderObj = {
        Instance = holder,
        _connections = {mouseUpConn},
        Get = function() return value end,
        Set = function(self, newVal, skipCallback)
            newVal = math.clamp(roundToIncrement(newVal), min, max)
            value = newVal
            local actualPercent = (value - min) / (max - min)
            Utility.Tween(sliderFill, {Size = UDim2.new(actualPercent, 0, 1, 0)}, 0.1)
            Utility.Tween(knob, {Position = UDim2.new(actualPercent, 0, 0.5, 0)}, 0.1)
            valueLabel.Text = tostring(value) .. suffix
            if not skipCallback then
                pcall(callback, value)
            end
            if flag and configManager then
                configManager._flags[flag].Value = value
            end
        end,
        Destroy = function(self)
            for _, conn in ipairs(self._connections) do
                conn:Disconnect()
            end
            if slideConnection then slideConnection:Disconnect() end
            holder:Destroy()
        end
    }
    
    if flag and configManager then
        configManager:RegisterFlag(flag, {
            Type = "Slider",
            Value = value,
            Get = function() return value end,
            Set = function(v)
                sliderObj:Set(v, false)
            end
        })
    end
    
    return sliderObj
end

-- ============================================================================
-- DROPDOWN COMPONENT
-- ============================================================================

function Components.Dropdown(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Dropdown"
    local description = config.Description or nil
    local options = config.Options or {}
    local default = config.Default or nil
    local multiSelect = config.MultiSelect or false
    local callback = config.Callback or function() end
    local flag = config.Flag or nil
    
    local isOpen = false
    local selected
    if multiSelect then
        selected = {}
        if type(default) == "table" then
            for _, v in ipairs(default) do
                selected[v] = true
            end
        end
    else
        selected = default
    end
    
    local baseHeight = description and 48 or Theme.ElementHeight
    local holder = Components.CreateElementBase(parent, "Dropdown_" .. name, baseHeight)
    holder.ClipsDescendants = true
    
    local button = Utility.Create("TextButton", {
        Name = "Clickable",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, baseHeight),
        Text = "",
        ZIndex = 2,
        Parent = holder
    })
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, description and 4 or 0),
        Size = UDim2.new(0.5, -12, 0, description and 20 or baseHeight),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(0.6, -12, 0, 18),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    local function getDisplayText()
        if multiSelect then
            local items = {}
            for _, opt in ipairs(options) do
                if selected[opt] then
                    table.insert(items, opt)
                end
            end
            return #items > 0 and table.concat(items, ", ") or "None"
        else
            return selected or "Select..."
        end
    end
    
    local selectedLabel = Utility.Create("TextLabel", {
        Name = "Selected",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -30, 0, description and 4 or 0),
        Size = UDim2.new(0.45, -12, 0, description and 20 or baseHeight),
        Font = Theme.FontLight,
        Text = getDisplayText(),
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2,
        Parent = holder
    })
    
    local arrow = Utility.Create("TextLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0, baseHeight / 2),
        Size = UDim2.new(0, 16, 0, 16),
        Font = Theme.FontBold,
        Text = "▼",
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        ZIndex = 2,
        Rotation = 0,
        Parent = holder
    })
    
    local optionsContainer = Utility.Create("Frame", {
        Name = "Options",
        BackgroundColor3 = Theme.DropdownBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 6, 0, baseHeight + 2),
        Size = UDim2.new(1, -12, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = holder
    })
    Utility.AddCorner(optionsContainer, Theme.CornerRadiusSmall)
    
    local optionsList = Utility.Create("ScrollingFrame", {
        Name = "OptionsList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentColor,
        ZIndex = 11,
        Parent = optionsContainer
    })
    Utility.AddListLayout(optionsList, 1, Enum.HorizontalAlignment.Center)
    Utility.AddPadding(optionsList, 2, 2, 2, 2)
    
    local optionButtons = {}
    
    local function rebuildOptions()
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        optionButtons = {}
        
        for i, opt in ipairs(options) do
            local isSelected = multiSelect and selected[opt] or (selected == opt)
            
            local optBtn = Utility.Create("TextButton", {
                Name = "Option_" .. opt,
                BackgroundColor3 = isSelected and Theme.AccentColor or Theme.DropdownBackground,
                BackgroundTransparency = isSelected and 0.7 or 0,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -4, 0, 28),
                Font = Theme.FontLight,
                Text = opt,
                TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary,
                TextSize = Theme.TextSizeSmall,
                ZIndex = 12,
                LayoutOrder = i,
                Parent = optionsList
            })
            Utility.AddCorner(optBtn, Theme.CornerRadiusSmall)
            
            optBtn.MouseEnter:Connect(function()
                if not (multiSelect and selected[opt] or (selected == opt)) then
                    Utility.Tween(optBtn, {BackgroundColor3 = Theme.TabHover}, 0.1)
                end
            end)
            optBtn.MouseLeave:Connect(function()
                local isSel = multiSelect and selected[opt] or (selected == opt)
                Utility.Tween(optBtn, {
                    BackgroundColor3 = isSel and Theme.AccentColor or Theme.DropdownBackground,
                    BackgroundTransparency = isSel and 0.7 or 0
                }, 0.1)
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                if multiSelect then
                    selected[opt] = not selected[opt]
                    local isSel = selected[opt]
                    Utility.Tween(optBtn, {
                        BackgroundColor3 = isSel and Theme.AccentColor or Theme.DropdownBackground,
                        BackgroundTransparency = isSel and 0.7 or 0,
                    }, 0.15)
                    optBtn.TextColor3 = isSel and Theme.TextPrimary or Theme.TextSecondary
                    selectedLabel.Text = getDisplayText()
                    
                    local result = {}
                    for _, o in ipairs(options) do
                        if selected[o] then table.insert(result, o) end
                    end
                    pcall(callback, result)
                    if flag and configManager then
                        configManager._flags[flag].Value = result
                    end
                else
                    selected = opt
                    selectedLabel.Text = getDisplayText()
                    
                    -- Update all buttons
                    for _, child in ipairs(optionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            local isSel = (child.Text == selected)
                            Utility.Tween(child, {
                                BackgroundColor3 = isSel and Theme.AccentColor or Theme.DropdownBackground,
                                BackgroundTransparency = isSel and 0.7 or 0,
                            }, 0.15)
                            child.TextColor3 = isSel and Theme.TextPrimary or Theme.TextSecondary
                        end
                    end
                    
                    pcall(callback, selected)
                    if flag and configManager then
                        configManager._flags[flag].Value = selected
                    end
                    
                    -- Close dropdown after single select
                    task.wait(0.1)
                    isOpen = false
                    Utility.Tween(arrow, {Rotation = 0}, 0.2)
                    local closedHeight = baseHeight
                    Utility.Tween(holder, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                end
            end)
            
            table.insert(optionButtons, optBtn)
        end
    end
    
    rebuildOptions()
    
    button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            optionsContainer.Visible = true
            local optionsHeight = math.min(#options * 29 + 4, 150)
            local totalHeight = baseHeight + optionsHeight + 4
            Utility.Tween(holder, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.25)
            optionsContainer.Size = UDim2.new(1, -12, 0, optionsHeight)
            Utility.Tween(arrow, {Rotation = 180}, 0.2)
        else
            Utility.Tween(arrow, {Rotation = 0}, 0.2)
            Utility.Tween(holder, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.25)
            task.wait(0.25)
            optionsContainer.Visible = false
        end
    end)
    
    local dropdownObj = {
        Instance = holder,
        _connections = {},
        Get = function()
            if multiSelect then
                local result = {}
                for _, o in ipairs(options) do
                    if selected[o] then table.insert(result, o) end
                end
                return result
            else
                return selected
            end
        end,
        Set = function(self, val)
            if multiSelect and type(val) == "table" then
                selected = {}
                for _, v in ipairs(val) do selected[v] = true end
            else
                selected = val
            end
            selectedLabel.Text = getDisplayText()
            rebuildOptions()
            pcall(callback, multiSelect and self.Get() or selected)
        end,
        UpdateOptions = function(self, newOptions)
            options = newOptions
            rebuildOptions()
        end,
        Destroy = function(self)
            holder:Destroy()
        end
    }
    
    if flag and configManager then
        configManager:RegisterFlag(flag, {
            Type = "Dropdown",
            Value = multiSelect and dropdownObj.Get() or selected,
            Get = function() return dropdownObj.Get() end,
            Set = function(v) dropdownObj:Set(v) end
        })
    end
    
    return dropdownObj
end

-- ============================================================================
-- TEXTBOX / INPUT COMPONENT
-- ============================================================================

function Components.Input(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Input"
    local description = config.Description or nil
    local placeholder = config.Placeholder or "Type here..."
    local default = config.Default or ""
    local callback = config.Callback or function() end
    local flag = config.Flag or nil
    local clearOnFocus = config.ClearOnFocus or false
    
    local value = default
    local totalHeight = description and 62 or 52
    local holder = Components.CreateElementBase(parent, "Input_" .. name, totalHeight)
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, description and 4 or 4),
        Size = UDim2.new(1, -24, 0, description and 18 or 16),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 22),
            Size = UDim2.new(1, -24, 0, 14),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    local inputY = description and 38 or 24
    
    local inputBox = Utility.Create("TextBox", {
        Name = "TextBox",
        BackgroundColor3 = Theme.InputBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, inputY),
        Size = UDim2.new(1, -20, 0, 22),
        Font = Theme.FontLight,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeSmall,
        ClearTextOnFocus = clearOnFocus,
        ZIndex = 3,
        Parent = holder
    })
    Utility.AddCorner(inputBox, Theme.CornerRadiusSmall)
    Utility.AddPadding(inputBox, 0, 8, 0, 8)
    
    inputBox.Focused:Connect(function()
        Utility.Tween(inputBox, {BackgroundColor3 = Theme.TabHover}, 0.15)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        Utility.Tween(inputBox, {BackgroundColor3 = Theme.InputBackground}, 0.15)
        value = inputBox.Text
        pcall(callback, value, enterPressed)
        if flag and configManager then
            configManager._flags[flag].Value = value
        end
    end)
    
    local inputObj = {
        Instance = holder,
        _connections = {},
        Get = function() return value end,
        Set = function(self, newVal, skipCallback)
            value = newVal
            inputBox.Text = newVal
            if not skipCallback then
                pcall(callback, value, false)
            end
            if flag and configManager then
                configManager._flags[flag].Value = value
            end
        end,
        Destroy = function(self)
            holder:Destroy()
        end
    }
    
    if flag and configManager then
        configManager:RegisterFlag(flag, {
            Type = "Input",
            Value = value,
            Get = function() return value end,
            Set = function(v) inputObj:Set(v, false) end
        })
    end
    
    return inputObj
end

-- ============================================================================
-- KEYBIND COMPONENT
-- ============================================================================

function Components.Keybind(parent, config, configManager)
    config = config or {}
    local name = config.Name or "Keybind"
    local description = config.Description or nil
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local changedCallback = config.ChangedCallback or function() end
    local flag = config.Flag or nil
    local ignoreGameProcessed = config.IgnoreGameProcessed or true
    
    local currentKey = default
    local isBinding = false
    
    local totalHeight = description and 48 or Theme.ElementHeight
    local holder = Components.CreateElementBase(parent, "Keybind_" .. name, totalHeight)
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, description and 4 or 0),
        Size = UDim2.new(0.6, -12, 0, description and 20 or totalHeight),
        Font = Theme.Font,
        Text = name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = holder
    })
    
    if description then
        Utility.Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 24),
            Size = UDim2.new(0.6, -12, 0, 18),
            Font = Theme.FontLight,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = holder
        })
    end
    
    local keyButton = Utility.Create("TextButton", {
        Name = "KeyButton",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.InputBackground,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 70, 0, 24),
        Font = Theme.Font,
        Text = currentKey.Name or "None",
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        ZIndex = 3,
        Parent = holder
    })
    Utility.AddCorner(keyButton, Theme.CornerRadiusSmall)
    
    Utility.HoverEffect(keyButton, Theme.InputBackground, Theme.TabHover)
    
    keyButton.MouseButton1Click:Connect(function()
        isBinding = true
        keyButton.Text = "..."
        Utility.Tween(keyButton, {BackgroundColor3 = Theme.AccentColor}, 0.15)
        keyButton.TextColor3 = Theme.TextPrimary
    end)
    
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isBinding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    -- Cancel binding
                    isBinding = false
                    keyButton.Text = currentKey.Name or "None"
                    Utility.Tween(keyButton, {BackgroundColor3 = Theme.InputBackground}, 0.15)
                    keyButton.TextColor3 = Theme.TextSecondary
                    return
                end
                currentKey = input.KeyCode
                isBinding = false
                keyButton.Text = currentKey.Name
                Utility.Tween(keyButton, {BackgroundColor3 = Theme.InputBackground}, 0.15)
                keyButton.TextColor3 = Theme.TextSecondary
                pcall(changedCallback, currentKey)
                if flag and configManager then
                    configManager._flags[flag].Value = currentKey
                end
            end
        else
            if not gameProcessed or not ignoreGameProcessed then
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    pcall(callback, currentKey)
                end
            end
        end
    end)
    
    local keybindObj = {
        Instance = holder,
        _connections = {inputConn},
        Get = function() return currentKey end,
        Set = function(self, newKey, skipCallback)
            currentKey = newKey
            keyButton.Text = currentKey.Name or "None"
            if not skipCallback then
                pcall(changedCallback, currentKey)
            end
            if flag and configManager then
                configManager._flags[flag].Value = currentKey
            end
        end,
        Destroy = function(self)
            for _, conn in ipairs(self._connections) do
                conn:Disconnect()
            end
            holder:Destroy()
        end
    }
    
    if flag and configManager then
        configManager:RegisterFlag(flag, {
            Type = "Keybind",
            Value = currentKey,
            Get = function() return currentKey end,
            Set = function(v) keybindObj:Set(v, false) end
        })
    end
    
    return keybindObj
end

-- ============================================================================
-- LABEL COMPONENT
-- ============================================================================

function Components.Label(parent, config)
    config = config or {}
    local text = config.Text or "Label"
    
    local label = Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Theme.Font,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
    Utility.AddPadding(label, 0, 0, 0, 8)
    
    return {
        Instance = label,
        SetText = function(self, newText)
            label.Text = newText
        end,
        Destroy = function(self)
            label:Destroy()
        end
    }
end

-- ============================================================================
-- SECTION / DIVIDER COMPONENT
-- ============================================================================

function Components.Section(parent, config)
    config = config or {}
    local title = config.Title or "Section"
    
    local holder = Utility.Create("Frame", {
        Name = "Section_" .. title,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = parent
    })
    
    -- Left line
    Utility.Create("Frame", {
        Name = "LineLeft",
        BackgroundColor3 = Theme.ElementBorder,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.new(0.15, 0, 0, 1),
        Parent = holder
    })
    
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.65, 0, 1, 0),
        Font = Theme.FontBold,
        Text = string.upper(title),
        TextColor3 = Theme.TextDim,
        TextSize = Theme.TextSizeSmall - 1,
        LetterSpacing = 2,
        Parent = holder
    })
    
    -- Right line
    Utility.Create("Frame", {
        Name = "LineRight",
        BackgroundColor3 = Theme.ElementBorder,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0.15, 0, 0, 1),
        Parent = holder
    })
    
    return {
        Instance = holder,
        Destroy = function(self) holder:Destroy() end
    }
end

-- ============================================================================
-- PARAGRAPH COMPONENT
-- ============================================================================

function Components.Paragraph(parent, config)
    config = config or {}
    local title = config.Title or "Paragraph"
    local content = config.Content or ""
    
    local holder = Utility.Create("Frame", {
        Name = "Paragraph_" .. title,
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    })
    Utility.AddCorner(holder, Theme.CornerRadiusSmall)
    Utility.AddStroke(holder, Theme.ElementBorder, 1, 0.7)
    
    local innerFrame = Utility.Create("Frame", {
        Name = "Inner",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = holder
    })
    Utility.AddPadding(innerFrame, 8, 12, 8, 12)
    Utility.AddListLayout(innerFrame, 4, Enum.HorizontalAlignment.Left)
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = innerFrame
    })
    
    local contentLabel = Utility.Create("TextLabel", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Theme.FontLight,
        Text = content,
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = innerFrame
    })
    
    return {
        Instance = holder,
        SetTitle = function(self, t) titleLabel.Text = t end,
        SetContent = function(self, c) contentLabel.Text = c end,
        Destroy = function(self) holder:Destroy() end
    }
end

-- ============================================================================
-- TAB CLASS
-- ============================================================================

local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    self._window = window
    self._name = config.Name or "Tab"
    self._icon = config.Icon or nil
    self._elements = {}
    self._container = nil
    self._tabButton = nil
    self._configManager = window._configManager
    return self
end

function Tab:_createContainer(parent)
    self._container = Utility.Create("ScrollingFrame", {
        Name = "TabContent_" .. self._name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentColor,
        ScrollBarImageTransparency = 0.3,
        Visible = false,
        BorderSizePixel = 0,
        Parent = parent
    })
    Utility.AddListLayout(self._container, Theme.ElementPadding, Enum.HorizontalAlignment.Center)
    Utility.AddPadding(self._container, Theme.ContentPadding, Theme.ContentPadding, Theme.ContentPadding, Theme.ContentPadding)
    
    return self._container
end

function Tab:AddButton(config)
    local element = Components.Button(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddToggle(config)
    local element = Components.Toggle(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddSlider(config)
    local element = Components.Slider(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddDropdown(config)
    local element = Components.Dropdown(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddInput(config)
    local element = Components.Input(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddKeybind(config)
    local element = Components.Keybind(self._container, config, self._configManager)
    table.insert(self._elements, element)
    return element
end

function Tab:AddLabel(config)
    local element = Components.Label(self._container, config)
    table.insert(self._elements, element)
    return element
end

function Tab:AddSection(config)
    local element = Components.Section(self._container, config)
    table.insert(self._elements, element)
    return element
end

function Tab:AddParagraph(config)
    local element = Components.Paragraph(self._container, config)
    table.insert(self._elements, element)
    return element
end

function Tab:Destroy()
    for _, element in ipairs(self._elements) do
        if element.Destroy then
            element:Destroy()
        end
    end
    if self._container then
        self._container:Destroy()
    end
    if self._tabButton then
        self._tabButton:Destroy()
    end
end

-- ============================================================================
-- WINDOW CLASS
-- ============================================================================

local Window = {}
Window.__index = Window

function Window.new(screenGui, config, configManager)
    local self = setmetatable({}, Window)
    self._screenGui = screenGui
    self._name = config.Name or "ZenexLib"
    self._subtitle = config.Subtitle or nil
    self._icon = config.Icon or nil
    self._configName = config.ConfigName or "ZenexConfig"
    self._configManager = configManager
    self._tabs = {}
    self._activeTab = nil
    self._isMinimized = false
    self._connections = {}
    self._elements = {} -- window-level UI elements
    
    self:_build()
    return self
end

function Window:_build()
    -- Main frame
    self._mainFrame = Utility.Create("Frame", {
        Name = "ZenexWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0), -- Start at 0 for open animation
        ClipsDescendants = true,
        Parent = self._screenGui
    })
    Utility.AddCorner(self._mainFrame, Theme.CornerRadiusLarge)
    
    -- Shadow
    self._shadow = Utility.AddShadow(self._mainFrame)
    
    -- Title bar
    self._titleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Theme.TitleBarHeight),
        ZIndex = 5,
        Parent = self._mainFrame
    })
    
    -- Subtle bottom border on title bar
    Utility.Create("Frame", {
        Name = "TitleBarBorder",
        BackgroundColor3 = Theme.ElementBorder,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 5,
        Parent = self._titleBar
    })
    
    -- Title elements container
    local titleLeft = Utility.Create("Frame", {
        Name = "TitleLeft",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        ZIndex = 6,
        Parent = self._titleBar
    })
    
    local titleLayoutX = 0
    
    -- Icon
    if self._icon then
        Utility.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Image = self._icon,
            ZIndex = 7,
            Parent = titleLeft
        })
        titleLayoutX = 26
    end
    
    -- Title text
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, titleLayoutX, 0, 0),
        Size = UDim2.new(1, -titleLayoutX, 1, self._subtitle and -2 or 0),
        Font = Theme.FontBold,
        Text = self._name,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeTitle,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = self._subtitle and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center,
        ZIndex = 7,
        Parent = titleLeft
    })
    
    -- Subtitle
    if self._subtitle then
        Utility.Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, titleLayoutX, 0.5, 1),
            Size = UDim2.new(1, -titleLayoutX, 0.5, -1),
            Font = Theme.FontLight,
            Text = self._subtitle,
            TextColor3 = Theme.TextDim,
            TextSize = Theme.TextSizeSmall - 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 7,
            Parent = titleLeft
        })
    end
    
    -- Title bar buttons (right side)
    local titleRight = Utility.Create("Frame", {
        Name = "TitleRight",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 0),
        Size = UDim2.new(0, 60, 1, 0),
        ZIndex = 6,
        Parent = self._titleBar
    })
    
    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Error,
        BackgroundTransparency = 0.85,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Theme.FontBold,
        Text = "×",
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        ZIndex = 8,
        Parent = titleRight
    })
    Utility.AddCorner(closeBtn, Theme.CornerRadiusSmall)
    
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {BackgroundTransparency = 0.85}, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Minimize button
    local minimizeBtn = Utility.Create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.TextDim,
        BackgroundTransparency = 0.85,
        Position = UDim2.new(1, -30, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Theme.FontBold,
        Text = "−",
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        ZIndex = 8,
        Parent = titleRight
    })
    Utility.AddCorner(minimizeBtn, Theme.CornerRadiusSmall)
    
    minimizeBtn.MouseEnter:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundTransparency = 0.85}, 0.15)
    end)
    
    self._originalSize = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight)
    self._minimizedSize = UDim2.new(0, Theme.WindowWidth, 0, Theme.TitleBarHeight)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:_toggleMinimize()
    end)
    
    -- Make draggable
    local dragConns = Utility.MakeDraggable(self._titleBar, self._mainFrame)
    for _, c in ipairs(dragConns) do
        table.insert(self._connections, c)
    end
    
    -- Body: Tab bar (left) + Content (right)
    self._bodyFrame = Utility.Create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, Theme.TitleBarHeight),
        Size = UDim2.new(1, 0, 1, -Theme.TitleBarHeight),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = self._mainFrame
    })
    
    -- Tab sidebar
    self._tabBarFrame = Utility.Create("Frame", {
        Name = "TabBar",
        BackgroundColor3 = Theme.TabBar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, Theme.TabBarWidth, 1, 0),
        ZIndex = 3,
        Parent = self._bodyFrame
    })
    
    -- Subtle right border
    Utility.Create("Frame", {
        Name = "TabBarBorder",
        BackgroundColor3 = Theme.ElementBorder,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 3,
        Parent = self._tabBarFrame
    })
    
    self._tabButtonContainer = Utility.Create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -1, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.AccentColor,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = self._tabBarFrame
    })
    Utility.AddListLayout(self._tabButtonContainer, 2, Enum.HorizontalAlignment.Center)
    Utility.AddPadding(self._tabButtonContainer, 6, 6, 6, 6)
    
    -- Content area
    self._contentFrame = Utility.Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.TabBarWidth, 0, 0),
        Size = UDim2.new(1, -Theme.TabBarWidth, 1, 0),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = self._bodyFrame
    })
    
    -- Floating toggle button
    self._toggleButton = Utility.Create("ImageButton", {
        Name = "ZenexToggle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TitleBar,
        Position = UDim2.new(0, 40, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 40),
        Image = self._icon or "",
        ImageColor3 = Theme.TextPrimary,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 50,
        Visible = false,
        Parent = self._screenGui
    })
    Utility.AddCorner(self._toggleButton, UDim.new(1, 0))
    Utility.AddStroke(self._toggleButton, Theme.AccentColor, 1.5, 0.3)
    Utility.AddShadow(self._toggleButton)
    
    -- If no icon, show text
    if not self._icon or self._icon == "" then
        self._toggleButton.Image = ""
        local toggleLabel = Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.FontBold,
            Text = string.sub(self._name, 1, 2),
            TextColor3 = Theme.AccentColor,
            TextSize = 16,
            ZIndex = 51,
            Parent = self._toggleButton
        })
    end
    
    -- Make toggle button draggable
    local toggleDragConns = Utility.MakeDraggable(self._toggleButton, self._toggleButton)
    for _, c in ipairs(toggleDragConns) do
        table.insert(self._connections, c)
    end
    
    -- Track if actually dragged vs clicked
    local toggleDragStart = nil
    local toggleWasDragged = false
    
    self._toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragStart = input.Position
            toggleWasDragged = false
        end
    end)
    
    self._toggleButton.InputChanged:Connect(function(input)
        if toggleDragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = (input.Position - toggleDragStart).Magnitude
            if delta > 5 then
                toggleWasDragged = true
            end
        end
    end)
    
    self._toggleButton.MouseButton1Click:Connect(function()
        if not toggleWasDragged then
            self:_show()
        end
        toggleDragStart = nil
        toggleWasDragged = false
    end)
    
    -- Open animation
    Utility.Tween(self._mainFrame, {Size = self._originalSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Initialize notification system
    NotificationManager:Init(self._screenGui)
end

function Window:_toggleMinimize()
    self._isMinimized = not self._isMinimized
    
    if self._isMinimized then
        Utility.Tween(self._mainFrame, {Size = self._minimizedSize}, Theme.AnimationSpeed)
        self._toggleButton.Visible = true
        Utility.Tween(self._toggleButton, {ImageTransparency = 0}, 0.2)
    else
        Utility.Tween(self._mainFrame, {Size = self._originalSize}, Theme.AnimationSpeed)
        self._toggleButton.Visible = false
    end
end

function Window:_hide()
    Utility.Tween(self._mainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.3)
    self._mainFrame.Visible = false
    self._toggleButton.Visible = true
end

function Window:_show()
    self._mainFrame.Visible = true
    self._isMinimized = false
    self._mainFrame.Size = UDim2.new(0, 0, 0, 0)
    Utility.Tween(self._mainFrame, {Size = self._originalSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    self._toggleButton.Visible = false
end

function Window:_selectTab(tab)
    if self._activeTab == tab then return end
    
    -- Deselect old tab
    if self._activeTab then
        self._activeTab._container.Visible = false
        if self._activeTab._tabButton then
            Utility.Tween(self._activeTab._tabButton, {
                BackgroundColor3 = Theme.TabInactive,
                BackgroundTransparency = 0.5
            }, 0.15)
            local label = self._activeTab._tabButton:FindFirstChild("Label")
            if label then
                Utility.Tween(label, {TextColor3 = Theme.TextSecondary}, 0.15)
            end
            local indicator = self._activeTab._tabButton:FindFirstChild("Indicator")
            if indicator then
                Utility.Tween(indicator, {BackgroundTransparency = 1}, 0.15)
            end
        end
    end
    
    -- Select new tab
    self._activeTab = tab
    tab._container.Visible = true
    if tab._tabButton then
        Utility.Tween(tab._tabButton, {
            BackgroundColor3 = Theme.TabActive,
            BackgroundTransparency = 0.8
        }, 0.15)
        local label = tab._tabButton:FindFirstChild("Label")
        if label then
            Utility.Tween(label, {TextColor3 = Theme.TextPrimary}, 0.15)
        end
        local indicator = tab._tabButton:FindFirstChild("Indicator")
        if indicator then
            Utility.Tween(indicator, {BackgroundTransparency = 0}, 0.15)
        end
    end
end

function Window:CreateTab(config)
    if type(config) == "string" then
        config = {Name = config}
    end
    config = config or {}
    
    local tab = Tab.new(self, config)
    tab:_createContainer(self._contentFrame)
    
    -- Create tab button
    local tabBtn = Utility.Create("TextButton", {
        Name = "Tab_" .. tab._name,
        BackgroundColor3 = Theme.TabInactive,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        ZIndex = 5,
        LayoutOrder = #self._tabs + 1,
        Parent = self._tabButtonContainer
    })
    Utility.AddCorner(tabBtn, Theme.CornerRadiusSmall)
    
    -- Active indicator bar on left
    local indicator = Utility.Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Theme.AccentColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.15, 0),
        Size = UDim2.new(0, 3, 0.7, 0),
        ZIndex = 6,
        Parent = tabBtn
    })
    Utility.AddCorner(indicator, UDim.new(1, 0))
    
    -- Icon (optional)
    local textOffsetX = 12
    if tab._icon and tab._icon ~= "" then
        Utility.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = tab._icon,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 6,
            Parent = tabBtn
        })
        textOffsetX = 32
    end
    
    Utility.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, textOffsetX, 0, 0),
        Size = UDim2.new(1, -textOffsetX - 5, 1, 0),
        Font = Theme.Font,
        Text = tab._name,
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 6,
        Parent = tabBtn
    })
    
    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Utility.Tween(tabBtn, {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0.3}, 0.12)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Utility.Tween(tabBtn, {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.5}, 0.12)
        end
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)
    
    tab._tabButton = tabBtn
    table.insert(self._tabs, tab)
    
    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_selectTab(tab)
    end
    
    return tab
end

function Window:Notify(config)
    NotificationManager:Send(config)
end

function Window:SaveConfig()
    self._configManager:Save()
end

function Window:LoadConfig()
    self._configManager:Load()
end

function Window:Destroy()
    -- Animate out
    Utility.Tween(self._mainFrame, {
        Size = UDim2.new(0, 0, 0, 0)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    task.wait(0.35)
    
    -- Disconnect all connections
    for _, conn in ipairs(self._connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    -- Destroy all tabs
    for _, tab in ipairs(self._tabs) do
        tab:Destroy()
    end
    
    -- Remove toggle button
    if self._toggleButton then
        self._toggleButton:Destroy()
    end
    
    -- Remove screen gui
    if self._screenGui then
        self._screenGui:Destroy()
    end
    
    -- Remove from library tracking
    for i, w in ipairs(ZenexLib._windows) do
        if w == self then
            table.remove(ZenexLib._windows, i)
            break
        end
    end
end

-- ============================================================================
-- LIBRARY MAIN API
-- ============================================================================

function ZenexLib:CreateWindow(config)
    config = config or {}
    
    -- Create ScreenGui
    local screenGui = Utility.Create("ScreenGui", {
        Name = "ZenexLib_" .. (config.Name or "Window"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
    })
    
    -- Try CoreGui first, fallback to PlayerGui
    local success = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Config manager
    local configManager = ConfigManager.new(config.ConfigName or config.Name or "ZenexConfig")
    
    local window = Window.new(screenGui, config, configManager)
    table.insert(self._windows, window)
    
    return window
end

function ZenexLib:GetTheme()
    return Theme
end

function ZenexLib:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        Theme[k] = v
    end
end

function ZenexLib:DestroyAll()
    for _, window in ipairs(self._windows) do
        window:Destroy()
    end
    self._windows = {}
end

function ZenexLib:Notify(config)
    if #self._windows > 0 then
        self._windows[1]:Notify(config)
    end
end

-- ============================================================================
-- RETURN LIBRARY
-- ============================================================================

return ZenexLib
