local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService") -- Thêm TeleportService

local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 18 
local NOTE_FONT_SIZE = 20 

-- 1. CẤU HÌNH TÊN FILE
local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

-- Hàm che tên
local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscureLength = math.ceil(len / 2) 
    local visibleLen = len - obscureLength
    local startLen = math.ceil(visibleLen / 2)
    local endLen = visibleLen - startLen
    return str:sub(1, startLen) .. string.rep("*", obscureLength) .. str:sub(len - endLen + 1, len)
end
local MASKED_USERNAME = generateMaskedName(USERNAME)

-- Lấy tên Map
local GameName = "Loading..."
task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        GameName = info.Name
    end)
end)

-- Đọc/Lưu file
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

-- ==================================================================
-- HỆ THỐNG THÔNG BÁO (NOTIFICATION)
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
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) 
    frame.BorderSizePixel = 0
    frame.Parent = NotifyContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 10, 0, 10)
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
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    line.Parent = frame

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

-- ==================================================================
-- MAIN UI SCRIPT
-- ==================================================================
local playerGui = localPlayer:WaitForChild("PlayerGui")

if localPlayer and playerGui then 
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimatedRainbowBorderGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- GỐC UI (Để quản lý kéo ra/vào)
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0.45, 0, 0.2, 0) -- Tăng size một chút cho JobID
    mainContainer.Position = UDim2.new(0.5, 0, 0.05, 0)
    mainContainer.AnchorPoint = Vector2.new(0.5, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = screenGui

    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "RainbowBorderFrame"
    outerFrame.Size = UDim2.new(1, 0, 1, 0)
    outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    outerFrame.BackgroundTransparency = transparencyLevel
    outerFrame.Active = true 
    outerFrame.Draggable = true 
    outerFrame.Parent = mainContainer
    
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
    headerFrame.Size = UDim2.new(1, -15, 0.2, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = innerFrame

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0.3, 0, 1, 0) 
    usernameLabel.Text = "User: " .. MASKED_USERNAME 
    usernameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    usernameLabel.TextSize = FONT_SIZE 
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left 
    usernameLabel.Parent = headerFrame

    local mapNameLabel = Instance.new("TextLabel")
    mapNameLabel.Size = UDim2.new(0.4, 0, 1, 0) 
    mapNameLabel.Position = UDim2.new(0.3, 0, 0, 0) 
    mapNameLabel.Text = GameName
    mapNameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) 
    mapNameLabel.TextSize = FONT_SIZE 
    mapNameLabel.Font = Enum.Font.SourceSansBold 
    mapNameLabel.BackgroundTransparency = 1
    mapNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    mapNameLabel.TextTruncate = Enum.TextTruncate.AtEnd 
    mapNameLabel.Parent = headerFrame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.3, 0, 1, 0)
    fpsLabel.Position = UDim2.new(1, 0, 0, 0)
    fpsLabel.AnchorPoint = Vector2.new(1, 0)
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) 
    fpsLabel.TextSize = FONT_SIZE
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right 
    fpsLabel.Parent = headerFrame

    -- [JOB ID JOINER] - MỚI
    local jobFrame = Instance.new("Frame")
    jobFrame.Name = "JobFrame"
    jobFrame.Size = UDim2.new(1, -15, 0, 25)
    jobFrame.BackgroundTransparency = 1
    jobFrame.Parent = innerFrame

    local jobIdInput = Instance.new("TextBox")
    jobIdInput.Size = UDim2.new(0.7, -5, 1, 0)
    jobIdInput.PlaceholderText = "Paste Job-ID here..."
    jobIdInput.Text = ""
    jobIdInput.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    jobIdInput.TextColor3 = Color3.new(1, 1, 1)
    jobIdInput.Font = Enum.Font.SourceSans
    jobIdInput.TextSize = 14
    jobIdInput.Parent = jobFrame
    Instance.new("UICorner", jobIdInput).CornerRadius = UDim.new(0, 4)

    local joinBtn = Instance.new("TextButton")
    joinBtn.Size = UDim2.new(0.3, 0, 1, 0)
    joinBtn.Position = UDim2.new(0.7, 0, 0, 0)
    joinBtn.Text = "JOIN"
    joinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    joinBtn.TextColor3 = Color3.new(1, 1, 1)
    joinBtn.Font = Enum.Font.SourceSansBold
    joinBtn.TextSize = 14
    joinBtn.Parent = jobFrame
    Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)

    joinBtn.MouseButton1Click:Connect(function()
        local id = jobIdInput.Text
        if id and #id > 5 then
            SendNotification("Teleport", "Joining server...", nil, 3)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
        else
            SendNotification("Error", "Invalid Job ID!", nil, 3)
        end
    end)

    -- [NOTE BODY]
    local noteScrollingFrame = Instance.new("ScrollingFrame")
    noteScrollingFrame.Size = UDim2.new(1, 0, 0.45, 0) 
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
    noteScrollingFrame.BackgroundTransparency = 1
    noteScrollingFrame.ScrollBarThickness = 3 
    noteScrollingFrame.Parent = innerFrame

    local noteTextBox = Instance.new("TextBox")
    noteTextBox.Size = UDim2.new(1, -10, 0, 0) 
    noteTextBox.Position = UDim2.new(0, 5, 0, 0) 
    noteTextBox.Text = readConfig(CONFIG_FILE_NAME)
    noteTextBox.PlaceholderText = "Script by HuyUnfes"
    noteTextBox.TextColor3 = Color3.new(1, 1, 1)
    noteTextBox.MultiLine = true    
    noteTextBox.TextWrapped = true 
    noteTextBox.TextSize = NOTE_FONT_SIZE 
    noteTextBox.Font = Enum.Font.SourceSans
    noteTextBox.BackgroundTransparency = 1
    noteTextBox.TextXAlignment = Enum.TextXAlignment.Left
    noteTextBox.TextYAlignment = Enum.TextYAlignment.Top
    noteTextBox.Parent = noteScrollingFrame
    
    -- [TOGGLE BUTTON] - MỚI (Nút > để kéo ra/vào)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleBtn.Position = UDim2.new(1, 5, 0, 0) -- Nằm bên phải UI chính
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleBtn.Text = "<"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 20
    toggleBtn.Parent = outerFrame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
    
    local isOpen = true
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
        local targetText = isOpen and "<" or ">"
        
        TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = isOpen and UDim2.new(1, -6, 1, -6) or UDim2.new(0, 0, 1, -6)}):Play()
        TweenService:Create(outerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = isOpen and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 35, 1, 0)}):Play()
        toggleBtn.Text = targetText
    end)

    -- Logic update map name & canvas
    local function updateCanvasSize()
        local textBounds = TextService:GetTextSize(noteTextBox.Text, NOTE_FONT_SIZE, Enum.Font.SourceSans, Vector2.new(noteScrollingFrame.AbsoluteSize.X - 10, 10000))
        noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 20)
        noteTextBox.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
    end
    noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    task.delay(0.1, function()
        mapNameLabel.Text = GameName
        updateCanvasSize()
    end)
    noteTextBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteTextBox.Text) end)

    -- FPS Loop
    task.spawn(function()
        while true do
            local dt = RunService.RenderStepped:Wait()
            fpsLabel.Text = "FPS: " .. math.floor(1/dt)
        end
    end)

    -- Rainbow Border Loop
    task.spawn(function()
        local h = 0 
        while true do
            h = (h + 0.01) % 1
            uiGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
            })
            task.wait()
        end
    end)
    
    SendNotification("Script Status", "Loaded Successfully!", localPlayer.UserId, 5)
end