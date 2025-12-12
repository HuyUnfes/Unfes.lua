getgenv().ShowFPS = true 
getgenv().HideLeaderboard = true -- [ON] Che tên trên Bảng Xếp Hạng

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 20 
local NOTE_FONT_SIZE = 24 

-- ==================================================================
-- PHẦN 1: HỆ THỐNG THÔNG BÁO (NOTIFICATION SYSTEM) - BLACK THEME
-- ==================================================================
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "UnfesNotificationGUI"
NotifyGui.Parent = localPlayer:WaitForChild("PlayerGui")

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "Container"
NotifyContainer.Position = UDim2.new(1, -320, 0.5, 0) 
NotifyContainer.Size = UDim2.new(0, 300, 0.5, 0)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = NotifyGui

local NotifyListLayout = Instance.new("UIListLayout")
NotifyListLayout.Padding = UDim.new(0, 10)
NotifyListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyListLayout.Parent = NotifyContainer

local function SendNotification(title, text, userId, duration)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 70)
    
    -- [ĐỔI MÀU] Background màu Đen
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) 
    
    frame.BorderSizePixel = 0
    frame.Parent = NotifyContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    icon.BackgroundTransparency = 1
    if userId then
        icon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=420&height=420&format=png"
    else
        icon.Image = "rbxassetid://6034045994" 
    end
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = icon
    icon.Parent = frame
    
    -- Tiêu đề
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 25)
    titleLabel.Position = UDim2.new(0, 70, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    -- Nội dung
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -80, 0, 25)
    textLabel.Position = UDim2.new(0, 70, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    -- [ĐỔI MÀU] Line màu Trắng để nổi bật trên nền đen
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    line.BorderSizePixel = 0
    line.Parent = frame
    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(0, 8)
    lineCorner.Parent = line

    -- Animation
    frame.BackgroundTransparency = 1
    icon.ImageTransparency = 1
    titleLabel.TextTransparency = 1
    textLabel.TextTransparency = 1
    line.BackgroundTransparency = 1
    
    local fadeInInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(frame, fadeInInfo, {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(icon, fadeInInfo, {ImageTransparency = 0}):Play()
    TweenService:Create(titleLabel, fadeInInfo, {TextTransparency = 0}):Play()
    TweenService:Create(textLabel, fadeInInfo, {TextTransparency = 0}):Play()
    TweenService:Create(line, fadeInInfo, {BackgroundTransparency = 0}):Play()
    
    task.delay(duration or 5, function()
        local fadeOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(frame, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(icon, fadeOutInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(titleLabel, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(textLabel, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(line, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- [THÔNG BÁO 1] LOADING
SendNotification("Script Status", "Loading...", localPlayer.UserId, 2)

-- ==================================================================
-- PHẦN 2: MAIN SCRIPT
-- ==================================================================

local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscureLength = math.ceil(len / 2) 
    local visibleLen = len - obscureLength
    local startLen = math.ceil(visibleLen / 2)
    local endLen = visibleLen - startLen
    return str:sub(1, startLen) .. string.rep("*", obscureLength) .. str:sub(len - endLen + 1, len)
end

local USERNAME = localPlayer.Name
local MASKED_USERNAME = generateMaskedName(USERNAME)
local CONFIG_FILE_NAME = USERNAME .. ".txt" 

local GameName = "Loading..."
task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        GameName = info.Name
    end)
end)

local function readConfig(fileName)
    if readfile then
        local success, content = pcall(readfile, fileName)
        if success and content and content ~= "" then return content end
    end
    return "" 
end
local function saveConfig(fileName, content)
    if writefile then pcall(writefile, fileName, content) end
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    outerFrame.Size = UDim2.new(0.45, 0, 0.15, 0) -- Width 0.45
    outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
    outerFrame.AnchorPoint = Vector2.new(0.5, 0)
    outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    outerFrame.BackgroundTransparency = transparencyLevel
    outerFrame.Active = true 
    outerFrame.Draggable = true 
    outerFrame.Parent = screenGui
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, outerCornerRadius)
    outerCorner.Parent = outerFrame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Parent = outerFrame
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerBlackBackground"
    innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
    innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    innerFrame.BackgroundTransparency = transparencyLevel
    innerFrame.ClipsDescendants = true 
    innerFrame.Parent = outerFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = innerFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
    innerCorner.Parent = innerFrame

    -- [HEADER]
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, -15, 0.25, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = innerFrame

    -- 1. Username
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(0.3, 0, 1, 0) 
    usernameLabel.Text = "User: " .. MASKED_USERNAME 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextScaled = false
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left 
    usernameLabel.Parent = headerFrame

    -- 2. Map Name
    local mapNameLabel = Instance.new("TextLabel")
    mapNameLabel.Name = "MapNameLabel"
    mapNameLabel.Size = UDim2.new(0.5, 0, 1, 0) 
    mapNameLabel.Position = UDim2.new(0.3, 0, 0, 0) 
    mapNameLabel.Text = GameName
    mapNameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    mapNameLabel.TextScaled = false
    mapNameLabel.TextSize = FONT_SIZE 
    mapNameLabel.Font = Enum.Font.SourceSansBold 
    mapNameLabel.BackgroundTransparency = 1
    mapNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    mapNameLabel.TextTruncate = Enum.TextTruncate.AtEnd 
    mapNameLabel.Parent = headerFrame
    
    task.spawn(function()
        while GameName == "Loading..." do task.wait(0.5) end
        mapNameLabel.Text = GameName
    end)

    -- 3. FPS
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0.2, 0, 1, 0)
    fpsLabel.Position = UDim2.new(1, 0, 0, 0)
    fpsLabel.AnchorPoint = Vector2.new(1, 0)
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) 
    fpsLabel.TextScaled = false
    fpsLabel.TextSize = FONT_SIZE
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right 
    fpsLabel.Parent = headerFrame

    -- [NOTE BODY]
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.65, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 5 
    noteScrollingFrame.ClipsDescendants = true 
    noteScrollingFrame.Parent = innerFrame

    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Size = UDim2.new(1, -10, 0, 0) 
    noteTextBox.Position = UDim2.new(0, 5, 0, 0) 
    noteTextBox.Text = readConfig(CONFIG_FILE_NAME)
    noteTextBox.PlaceholderText = "Script by HuyUnfes"
    noteTextBox.PlaceholderColor3 = Color3.new(0.6, 0.6, 0.6)
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.TextScaled = false 
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true 
    noteTextBox.TextSize = NOTE_FONT_SIZE 
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    local function updateCanvasSize()
        local textBounds = TextService:GetTextSize(noteTextBox.Text, NOTE_FONT_SIZE, Enum.Font.SourceSans, Vector2.new(noteScrollingFrame.AbsoluteSize.X - 10, 10000))
        local h = math.max(textBounds.Y + 20, noteScrollingFrame.AbsoluteSize.Y)
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, h)
        noteTextBox.Size = UDim2.new(1, -10, 0, h)
    end
    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    noteTextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize) 
    task.delay(0.1, updateCanvasSize)
    noteTextBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteTextBox.Text) end)

    task.spawn(function()
        local lastUpdate = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            if tick() - lastUpdate >= 0.5 then
                lastUpdate = tick()
                if getgenv().ShowFPS then
                    fpsLabel.Text = "FPS: " .. math.floor(1 / deltaTime)
                else
                    fpsLabel.Text = ""
                end
            end
        end)
    end)

    if getgenv().HideLeaderboard then
        task.spawn(function()
            local NameMap = {}
            local function RefreshNameMap()
                for _, p in pairs(Players:GetPlayers()) do
                    NameMap[p.Name] = generateMaskedName(p.Name)
                    NameMap[p.DisplayName] = generateMaskedName(p.DisplayName)
                end
            end
            Players.PlayerAdded:Connect(RefreshNameMap)
            RefreshNameMap()

            while task.wait(1) do
                local success, playerList = pcall(function() return CoreGui:FindFirstChild("PlayerList") end)
                if success and playerList then
                    for _, obj in pairs(playerList:GetDescendants()) do
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            for real, masked in pairs(NameMap) do
                                if (obj.Text == real or obj.Text:find(real)) and not obj.Text:find("*") then
                                    obj.Text = obj.Text:gsub(real, masked)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    local function animateRainbowBorder()
        local h = 0 
        while true do
            h = (h + 0.01) % 1
            uiGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
            })
            RunService.RenderStepped:Wait() 
        end
    end
    task.spawn(animateRainbowBorder)
    
    -- [THÔNG BÁO 2] THÀNH CÔNG (CHỈ CHẠY KHI CODE ĐẾN ĐƯỢC DÒNG NÀY)
    SendNotification("Script Status", "Loaded Successfully!", localPlayer.UserId, 5)
end