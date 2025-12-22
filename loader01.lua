local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Khởi tạo thời gian bắt đầu (để tính thời gian chơi)
local StartTime = tick()

-- ==================================================================
-- CẤU HÌNH GỐC
-- ==================================================================
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 20 
local NOTE_FONT_SIZE = 24 
local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

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

local GameName = "Loading..."
task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        GameName = info.Name
    end)
end)

-- ==================================================================
-- HỆ THỐNG THÔNG BÁO (NOTIFICATION)
-- ==================================================================
local function SendNotification(title, text, duration)
    task.spawn(function()
        local NotifyGui = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("UnfesNotificationGUI") or Instance.new("ScreenGui", localPlayer.PlayerGui)
        NotifyGui.Name = "UnfesNotificationGUI"
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 65)
        frame.Position = UDim2.new(1, 10, 0.8, 0)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.Parent = NotifyGui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 10, 0, 5); t.Text = title; t.TextColor3 = Color3.new(1,1,1); t.Font = "GothamBold"; t.TextSize = 16; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
        local m = Instance.new("TextLabel", frame)
        m.Size = UDim2.new(1, -20, 0, 25); m.Position = UDim2.new(0, 10, 0, 30); m.Text = text; m.TextColor3 = Color3.fromRGB(200,200,200); m.Font = "Gotham"; m.TextSize = 14; m.BackgroundTransparency = 1; m.TextXAlignment = "Left"
        frame:TweenPosition(UDim2.new(1, -290, 0.8, 0), "Out", "Quint", 0.5)
        task.wait(duration or 3)
        frame:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Quint", 0.5)
        task.wait(0.5); frame:Destroy()
    end)
end

-- ==================================================================
-- MAIN UI (UI GIỮA CŨ)
-- ==================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimatedRainbowBorderGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local outerFrame = Instance.new("Frame", screenGui)
outerFrame.Name = "RainbowBorderFrame"
outerFrame.Size = UDim2.new(0.45, 0, 0.15, 0) 
outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
outerFrame.AnchorPoint = Vector2.new(0.5, 0)
outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
outerFrame.Active = true 
outerFrame.Draggable = true 
Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, outerCornerRadius)
local uiGradient = Instance.new("UIGradient", outerFrame)

local innerFrame = Instance.new("Frame", outerFrame)
innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
innerFrame.BackgroundTransparency = transparencyLevel
innerFrame.ClipsDescendants = true 
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)

local listLayout = Instance.new("UIListLayout", innerFrame)
listLayout.Padding = UDim.new(0, 5); listLayout.HorizontalAlignment = "Center"

local headerFrame = Instance.new("Frame", innerFrame)
headerFrame.Size = UDim2.new(1, -15, 0.25, 0); headerFrame.BackgroundTransparency = 1

local usernameLabel = Instance.new("TextLabel", headerFrame)
usernameLabel.Size = UDim2.new(0.3, 0, 1, 0); usernameLabel.Text = "User: "..MASKED_USERNAME; usernameLabel.TextColor3 = Color3.new(0.8,0.8,0.8); usernameLabel.TextSize = FONT_SIZE; usernameLabel.Font = "SourceSansBold"; usernameLabel.BackgroundTransparency = 1; usernameLabel.TextXAlignment = "Left"

local mapNameLabel = Instance.new("TextLabel", headerFrame)
mapNameLabel.Size = UDim2.new(0.5, 0, 1, 0); mapNameLabel.Position = UDim2.new(0.3,0,0,0); mapNameLabel.Text = GameName; mapNameLabel.TextColor3 = Color3.new(0.8,0.8,0.8); mapNameLabel.TextSize = FONT_SIZE; mapNameLabel.Font = "SourceSansBold"; mapNameLabel.BackgroundTransparency = 1; mapNameLabel.TextXAlignment = "Center"

local fpsLabel = Instance.new("TextLabel", headerFrame)
fpsLabel.Size = UDim2.new(0.2, 0, 1, 0); fpsLabel.Position = UDim2.new(1,0,0,0); fpsLabel.AnchorPoint = Vector2.new(1,0); fpsLabel.Text = "FPS: 0"; fpsLabel.TextColor3 = Color3.fromRGB(0,255,127); fpsLabel.TextSize = FONT_SIZE; fpsLabel.Font = "SourceSansBold"; fpsLabel.BackgroundTransparency = 1; fpsLabel.TextXAlignment = "Right"

local scroll = Instance.new("ScrollingFrame", innerFrame)
scroll.Size = UDim2.new(1, 0, 0.65, 0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 5

local noteTextBox = Instance.new("TextBox", scroll)
noteTextBox.Size = UDim2.new(1, -10, 0, 0); noteTextBox.Position = UDim2.new(0,5,0,0); noteTextBox.Text = ""; noteTextBox.PlaceholderText = "Script by HuyUnfes"; noteTextBox.TextColor3 = Color3.new(1,1,1); noteTextBox.MultiLine = true; noteTextBox.TextWrapped = true; noteTextBox.TextSize = NOTE_FONT_SIZE; noteTextBox.Font = "SourceSans"; noteTextBox.BackgroundTransparency = 1; noteTextBox.TextXAlignment = "Left"; noteTextBox.TextYAlignment = "Top"

-- ==================================================================
-- HỆ THỐNG AFK MODE (YÊU CẦU MỚI)
-- ==================================================================
local afkScreen = Instance.new("ScreenGui", localPlayer.PlayerGui)
afkScreen.Name = "AFK_Overlay"
afkScreen.Enabled = false
afkScreen.DisplayOrder = 999

local afkBg = Instance.new("Frame", afkScreen)
afkBg.Size = UDim2.new(1, 0, 1, 0)
afkBg.BackgroundColor3 = Color3.new(0, 0, 0)
afkBg.BackgroundTransparency = 0.5

local afkMainText = Instance.new("TextLabel", afkBg)
afkMainText.Size = UDim2.new(0.7, 0, 0.2, 0)
afkMainText.Position = UDim2.new(0.5, 0, 0.35, 0)
afkMainText.AnchorPoint = Vector2.new(0.5, 0.5)
afkMainText.Text = "AFK MODE"
afkMainText.TextColor3 = Color3.fromRGB(255, 224, 189) -- Màu da
afkMainText.TextScaled = true
afkMainText.Font = "GothamBold"
afkMainText.BackgroundTransparency = 1

local afkMapText = Instance.new("TextLabel", afkBg)
afkMapText.Size = UDim2.new(1, 0, 0.05, 0)
afkMapText.Position = UDim2.new(0.5, 0, 0.48, 0)
afkMapText.AnchorPoint = Vector2.new(0.5, 0.5)
afkMapText.Text = "Game: " .. GameName
afkMapText.TextColor3 = Color3.fromRGB(255, 255, 180) -- Vàng nhạt
afkMapText.TextSize = 25
afkMapText.Font = "GothamBold"
afkMapText.BackgroundTransparency = 1

local afkUserText = Instance.new("TextLabel", afkBg)
afkUserText.Size = UDim2.new(1, 0, 0.05, 0)
afkUserText.Position = UDim2.new(0.5, 0, 0.53, 0)
afkUserText.AnchorPoint = Vector2.new(0.5, 0.5)
afkUserText.Text = "Username: " .. MASKED_USERNAME
afkUserText.TextColor3 = Color3.fromRGB(173, 216, 230) -- Xanh nhạt
afkUserText.TextSize = 22
afkUserText.Font = "Gotham"
afkUserText.BackgroundTransparency = 1

local afkTimeText = Instance.new("TextLabel", afkBg)
afkTimeText.Size = UDim2.new(1, 0, 0.05, 0)
afkTimeText.Position = UDim2.new(0.5, 0, 0.58, 0)
afkTimeText.AnchorPoint = Vector2.new(0.5, 0.5)
afkTimeText.Text = "Thời gian chơi: 0D:0H:0M:0S"
afkTimeText.TextColor3 = Color3.fromRGB(255, 150, 150) -- Đỏ nhạt
afkTimeText.TextSize = 22
afkTimeText.Font = "Gotham"
afkTimeText.BackgroundTransparency = 1

local exitHint = Instance.new("TextLabel", afkBg)
exitHint.Size = UDim2.new(1, 0, 0.1, 0)
exitHint.Position = UDim2.new(0.5, 0, 0.9, 0)
exitHint.AnchorPoint = Vector2.new(0.5, 0.5)
exitHint.Text = "(Nhấn nút bất kỳ để thoát AFK)"
exitHint.TextColor3 = Color3.new(1, 1, 1)
exitHint.TextTransparency = 0.5
exitHint.TextSize = 18
exitHint.BackgroundTransparency = 1

-- Hàm định dạng thời gian
local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%dD:%dH:%dM:%dS", days, hours, minutes, secs)
end

-- Hiệu ứng làm mờ
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting

local function toggleAFK(state)
    afkScreen.Enabled = state
    blurEffect.Size = state and 24 or 0
    if state then
        screenGui.Enabled = false
        -- Vòng lặp cập nhật thời gian
        task.spawn(function()
            while afkScreen.Enabled do
                afkTimeText.Text = "Thời gian chơi: " .. formatTime(tick() - StartTime)
                afkMapText.Text = "Game: " .. GameName
                task.wait(1)
            end
        end)
    else
        screenGui.Enabled = true
    end
end

-- Thoát AFK khi nhấn phím
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if afkScreen.Enabled and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1) then
        toggleAFK(false)
    end
end)

-- ==================================================================
-- BẢNG THÔNG BÁO XÁC NHẬN AFK
-- ==================================================================
local function ShowAFKPrompt()
    local promptFrame = Instance.new("Frame", screenGui)
    promptFrame.Size = UDim2.new(0, 300, 0, 150)
    promptFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    promptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    promptFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    promptFrame.BorderSizePixel = 0
    Instance.new("UICorner", promptFrame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", promptFrame)
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Text = "Do you want turn on AFK Mode?"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = "GothamBold"
    title.TextWrapped = true
    title.BackgroundTransparency = 1

    local yesBtn = Instance.new("TextButton", promptFrame)
    yesBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
    yesBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    yesBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    yesBtn.Text = "Yes"
    yesBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", yesBtn)

    local noBtn = Instance.new("TextButton", promptFrame)
    noBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
    noBtn.Position = UDim2.new(0.5, 0, 0.6, 0)
    noBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    noBtn.Text = "No"
    noBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", noBtn)

    yesBtn.MouseButton1Click:Connect(function()
        promptFrame:Destroy()
        toggleAFK(true)
    end)

    noBtn.MouseButton1Click:Connect(function()
        promptFrame:Destroy()
    end)
end

-- ==================================================================
-- SIDE MENU CẬP NHẬT
-- ==================================================================
local toggleSideBtn = Instance.new("TextButton", outerFrame)
toggleSideBtn.Size = UDim2.new(0, 25, 0, 60); toggleSideBtn.Position = UDim2.new(1, 0, 0.5, -30); toggleSideBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); toggleSideBtn.Text = ">"; toggleSideBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleSideBtn).CornerRadius = UDim.new(0, 8)

local sideMenu = Instance.new("Frame", outerFrame)
sideMenu.Size = UDim2.new(1, 0, 1.2, 0); sideMenu.Position = UDim2.new(1, 10, 0, 0); sideMenu.BackgroundColor3 = Color3.fromRGB(10, 20, 35); sideMenu.BackgroundTransparency = 0.4; sideMenu.Visible = false
Instance.new("UICorner", sideMenu).CornerRadius = UDim.new(0, 15)

local sideLayout = Instance.new("UIListLayout", sideMenu); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", sideMenu).PaddingTop = UDim.new(0, 8)

local function createSideBtn(text, color)
    local b = Instance.new("TextButton", sideMenu)
    b.Size = UDim2.new(0.9, 0, 0, 28); b.Text = text; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local jobInput = Instance.new("TextBox", sideMenu)
jobInput.Size = UDim2.new(0.9, 0, 0, 28); jobInput.PlaceholderText = "Job-ID..."; jobInput.BackgroundColor3 = Color3.fromRGB(30, 40, 60); jobInput.TextColor3 = Color3.new(1,1,1); jobInput.TextSize = 14; Instance.new("UICorner", jobInput)

local joinBtn = createSideBtn("Join Job-id", Color3.fromRGB(45, 90, 180))
local clipBtn = createSideBtn("Clipboard Join", Color3.fromRGB(50, 130, 100))
local afkBtn = createSideBtn("AFK Mode", Color3.fromRGB(180, 130, 50)) -- Nút mở AFK

-- LOGIC
toggleSideBtn.MouseButton1Click:Connect(function()
    sideMenu.Visible = not sideMenu.Visible
    toggleSideBtn.Text = sideMenu.Visible and "<" or ">"
end)

afkBtn.MouseButton1Click:Connect(function()
    ShowAFKPrompt()
end)

-- Hiệu ứng Rainbow & FPS (Vòng lặp cũ)
task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.5) % 1, 1, 1))
        })
        fpsLabel.Text = "FPS: " .. math.floor(1/dt)
    end)
end)

SendNotification("Unfes", "Đã tích hợp AFK Mode!", 3)
