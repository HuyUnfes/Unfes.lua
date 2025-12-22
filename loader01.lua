local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- CẤU HÌNH
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 20 
local NOTE_FONT_SIZE = 24 
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
    icon.Image = userId and "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=420&height=420&format=png" or "rbxassetid://6034045994"
    
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
    
    local fadeIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
    TweenService:Create(frame, fadeIn, {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(icon, fadeIn, {ImageTransparency = 0}):Play()
    TweenService:Create(titleLabel, fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(textLabel, fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(line, fadeIn, {BackgroundTransparency = 0}):Play()
    
    task.delay(duration or 5, function()
        local fadeOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
        TweenService:Create(frame, fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(icon, fadeOut, {ImageTransparency = 1}):Play()
        TweenService:Create(titleLabel, fadeOut, {TextTransparency = 1}):Play()
        TweenService:Create(textLabel, fadeOut, {TextTransparency = 1}):Play()
        TweenService:Create(line, fadeOut, {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- ==================================================================
-- MAIN UI SCRIPT
-- ==================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnfesMainGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local outerFrame = Instance.new("Frame")
outerFrame.Name = "RainbowBorderFrame"
outerFrame.Size = UDim2.new(0.45, 0, 0.15, 0) 
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

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)
innerCorner.Parent = innerFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5) 
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = innerFrame

-- [HEADER]
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, -15, 0.25, 0)
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
mapNameLabel.TextTruncate = Enum.TextTruncate.AtEnd 
mapNameLabel.Parent = headerFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.2, 0, 1, 0)
fpsLabel.Position = UDim2.new(1, 0, 0, 0)
fpsLabel.AnchorPoint = Vector2.new(1, 0)
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 127) 
fpsLabel.TextSize = FONT_SIZE
fpsLabel.Font = Enum.Font.SourceSansBold
的高级 = 1
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Right 
fpsLabel.Parent = headerFrame

-- [NOTE BODY]
local noteScrollingFrame = Instance.new("ScrollingFrame")
noteScrollingFrame.Size = UDim2.new(1, 0, 0.65, 0) 
noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
noteScrollingFrame.BackgroundTransparency = 1
noteScrollingFrame.ScrollBarThickness = 2
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

local function updateCanvas()
    local textBounds = TextService:GetTextSize(noteTextBox.Text, NOTE_FONT_SIZE, Enum.Font.SourceSans, Vector2.new(noteScrollingFrame.AbsoluteSize.X - 10, 10000))
    noteScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 20)
    noteTextBox.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
end
noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvas)
noteTextBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteTextBox.Text) end)

-- ==================================================================
-- HỆ THỐNG SIDE MENU (JOIN JOB-ID)
-- ==================================================================
local sideMenuVisible = false
local spamJoinActive = false

-- Nút mở rộng ">"
local toggleSideBtn = Instance.new("TextButton")
toggleSideBtn.Size = UDim2.new(0, 25, 0, 50)
toggleSideBtn.Position = UDim2.new(1, 0, 0.5, -25) -- Chạm đường viền phải
toggleSideBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleSideBtn.BackgroundTransparency = 0.2
toggleSideBtn.Text = ">"
toggleSideBtn.TextColor3 = Color3.new(1, 1, 1)
toggleSideBtn.TextSize = 18
toggleSideBtn.Font = Enum.Font.GothamBold
toggleSideBtn.Parent = outerFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleSideBtn

-- Khung Side Menu (Xanh đen mờ)
local sideMenu = Instance.new("Frame")
sideMenu.Size = UDim2.new(1, 0, 0.85, 0) -- Rộng bằng ui giữa, cao 85%
sideMenu.Position = UDim2.new(1, 10, 0.075, 0) -- Bên phải, không đè ui chính
sideMenu.BackgroundColor3 = Color3.fromRGB(10, 20, 35) -- Xanh đen
sideMenu.BackgroundTransparency = 0.4 -- Mờ 60%
sideMenu.Visible = false
sideMenu.Parent = outerFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 15)
sideCorner.Parent = sideMenu

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 8)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.Parent = sideMenu

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 10)
sidePadding.Parent = sideMenu

-- Các thành phần trong Side Menu
local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.Parent = sideMenu
    return btn
end

local jobIdInput = Instance.new("TextBox")
jobIdInput.Size = UDim2.new(0.9, 0, 0, 30)
jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
jobIdInput.PlaceholderText = "Enter Job-ID..."
jobIdInput.Text = ""
jobIdInput.TextColor3 = Color3.new(1, 1, 1)
jobIdInput.Font = Enum.Font.SourceSans
jobIdInput.Parent = sideMenu
Instance.new("UICorner", jobIdInput).CornerRadius = UDim.new(0, 6)

local joinBtn = createButton("Join Job-id", Color3.fromRGB(45, 90, 180))
local clipBtn = createButton("Job-id Clipboard", Color3.fromRGB(50, 130, 100))
local spamBtn = createButton("Spam Join: No", Color3.fromRGB(150, 50, 50))

-- LOGIC SIDE MENU
toggleSideBtn.MouseButton1Click:Connect(function()
    sideMenuVisible = not sideMenuVisible
    sideMenu.Visible = sideMenuVisible
    toggleSideBtn.Text = sideMenuVisible and "<" or ">"
end)

local function joinServer(id)
    if id and id ~= "" then
        SendNotification("Teleport", "Joining: " .. id, nil, 3)
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer) end)
    end
end

joinBtn.MouseButton1Click:Connect(function() joinServer(jobIdInput.Text) end)

clipBtn.MouseButton1Click:Connect(function()
    local clip = (getclipboard and getclipboard()) or ""
    jobIdInput.Text = clip
    joinServer(clip)
end)

spamBtn.MouseButton1Click:Connect(function()
    spamJoinActive = not spamJoinActive
    spamBtn.Text = "Spam Join: " .. (spamJoinActive and "Yes" or "No")
    spamBtn.BackgroundColor3 = spamJoinActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

task.spawn(function()
    while task.wait(3) do
        if spamJoinActive and jobIdInput.Text ~= "" then
            joinServer(jobIdInput.Text)
        end
    end
end)

-- ==================================================================
-- VÒNG LẶP HỆ THỐNG (RAINBOW, FPS, MAP)
-- ==================================================================
task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        -- Rainbow
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
        })
        -- FPS
        fpsLabel.Text = "FPS: " .. math.floor(1/dt)
        -- Update Map Name
        if mapNameLabel.Text ~= GameName then mapNameLabel.Text = GameName end
    end)
end)

SendNotification("Unfes Script", "Loaded Successfully!", localPlayer.UserId, 5)
print("Script Loaded!")
