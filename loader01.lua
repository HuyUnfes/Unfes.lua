local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Thời gian bắt đầu
local StartTime = tick()

-- CẤU HÌNH GỐC
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 20 
local NOTE_FONT_SIZE = 24 
local USERNAME = localPlayer.Name

local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscureLength = math.ceil(len / 2) 
    return str:sub(1, math.ceil((len-obscureLength)/2)) .. string.rep("*", obscureLength) .. str:sub(len - math.ceil((len-obscureLength)/2) + 1)
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
-- HỆ THỐNG AFK MODE (GIAO DIỆN MỚI - FONT PACIFICO)
-- ==================================================================
local afkScreen = Instance.new("ScreenGui", localPlayer.PlayerGui)
afkScreen.Name = "AFK_Overlay_Pacifico"
afkScreen.Enabled = false
afkScreen.DisplayOrder = 999

local afkBg = Instance.new("Frame", afkScreen)
afkBg.Size = UDim2.new(1, 0, 1, 0)
afkBg.BackgroundColor3 = Color3.new(0, 0, 0)
afkBg.BackgroundTransparency = 0.5

-- Hàm tạo Text Pacifico
local function createPacificoText(name, size, pos, color, scaled)
    local l = Instance.new("TextLabel", afkBg)
    l.Name = name
    l.Size = size
    l.Position = pos
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.TextColor3 = color
    l.BackgroundTransparency = 1
    -- Sử dụng font Pacifico chính thức của Roblox
    l.FontFace = Font.new("rbxasset://fonts/families/Pacifico.json")
    if scaled then l.TextScaled = true else l.TextSize = 30 end
    return l
end

-- Cách hàng xa ra bằng việc điều chỉnh tọa độ Y (0.3 -> 0.5 -> 0.65 -> 0.8)
local afkMainText = createPacificoText("AFK_Title", UDim2.new(0.7, 0, 0.2, 0), UDim2.new(0.5, 0, 0.25, 0), Color3.fromRGB(255, 224, 189), true)
afkMainText.Text = "AFK Mode"

local afkMapText = createPacificoText("AFK_Map", UDim2.new(1, 0, 0.05, 0), UDim2.new(0.5, 0, 0.45, 0), Color3.fromRGB(255, 255, 180), false)
afkMapText.Text = "Game: " .. GameName

local afkUserText = createPacificoText("AFK_User", UDim2.new(1, 0, 0.05, 0), UDim2.new(0.5, 0, 0.58, 0), Color3.fromRGB(173, 216, 230), false)
afkUserText.Text = "Username: " .. MASKED_USERNAME

local afkTimeText = createPacificoText("AFK_Time", UDim2.new(1, 0, 0.05, 0), UDim2.new(0.5, 0, 0.72, 0), Color3.fromRGB(255, 150, 150), false)
afkTimeText.Text = "Thời gian chơi: 0D:0H:0M:0S"

-- Hàm định dạng thời gian
local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%dD:%dH:%dM:%dS", days, hours, minutes, secs)
end

local blurEffect = Instance.new("BlurEffect", Lighting)
blurEffect.Size = 0

local function toggleAFK(state)
    afkScreen.Enabled = state
    blurEffect.Size = state and 25 or 0
    if state then
        -- Cập nhật thời gian liên tục khi đang AFK
        task.spawn(function()
            while afkScreen.Enabled do
                afkTimeText.Text = "Thời gian chơi: " .. formatTime(tick() - StartTime)
                task.wait(1)
            end
        end)
    end
end

-- Thoát AFK khi click hoặc nhấn phím
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if afkScreen.Enabled and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1) then
        toggleAFK(false)
    end
end)

-- ==================================================================
-- MAIN UI (GIỮ NGUYÊN UI GIỮA CŨ)
-- ==================================================================
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
screenGui.Name = "AnimatedRainbowBorderGUI"
screenGui.ResetOnSpawn = false

local outerFrame = Instance.new("Frame", screenGui)
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
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)

local listLayout = Instance.new("UIListLayout", innerFrame)
listLayout.Padding = UDim.new(0, 5); listLayout.HorizontalAlignment = "Center"

local headerFrame = Instance.new("Frame", innerFrame)
headerFrame.Size = UDim2.new(1, -15, 0.25, 0); headerFrame.BackgroundTransparency = 1

local userL = Instance.new("TextLabel", headerFrame)
userL.Size = UDim2.new(0.3, 0, 1, 0); userL.Text = "User: "..MASKED_USERNAME; userL.TextColor3 = Color3.new(0.8,0.8,0.8); userL.TextSize = FONT_SIZE; userL.Font = "SourceSansBold"; userL.BackgroundTransparency = 1; userL.TextXAlignment = "Left"

local mapL = Instance.new("TextLabel", headerFrame)
mapL.Size = UDim2.new(0.5, 0, 1, 0); mapL.Position = UDim2.new(0.3,0,0,0); mapL.Text = "Loading Map..."; mapL.TextColor3 = Color3.new(0.8,0.8,0.8); mapL.TextSize = FONT_SIZE; mapL.Font = "SourceSansBold"; mapL.BackgroundTransparency = 1; mapL.TextXAlignment = "Center"

task.spawn(function()
    while GameName == "Loading..." do task.wait(0.5) end
    mapL.Text = GameName
end)

local fpsL = Instance.new("TextLabel", headerFrame)
fpsL.Size = UDim2.new(0.2, 0, 1, 0); fpsL.Position = UDim2.new(1,0,0,0); fpsL.AnchorPoint = Vector2.new(1,0); fpsL.Text = "FPS: 0"; fpsL.TextColor3 = Color3.fromRGB(0,255,127); fpsL.TextSize = FONT_SIZE; fpsL.Font = "SourceSansBold"; fpsL.BackgroundTransparency = 1; fpsL.TextXAlignment = "Right"

local scroll = Instance.new("ScrollingFrame", innerFrame)
scroll.Size = UDim2.new(1, 0, 0.65, 0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3

local note = Instance.new("TextBox", scroll)
note.Size = UDim2.new(1, -10, 1, 0); note.Position = UDim2.new(0,5,0,0); note.Text = ""; note.PlaceholderText = "Script by HuyUnfes"; note.TextColor3 = Color3.new(1,1,1); note.MultiLine = true; note.TextWrapped = true; note.TextSize = NOTE_FONT_SIZE; note.Font = "SourceSans"; note.BackgroundTransparency = 1; note.TextXAlignment = "Left"; note.TextYAlignment = "Top"

-- ==================================================================
-- THÔNG BÁO XÁC NHẬN AFK
-- ==================================================================
local function ShowAFKPrompt()
    local prompt = Instance.new("Frame", screenGui)
    prompt.Size = UDim2.new(0, 300, 0, 120)
    prompt.Position = UDim2.new(0.5, 0, 0.5, 0)
    prompt.AnchorPoint = Vector2.new(0.5, 0.5)
    prompt.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", prompt)

    local txt = Instance.new("TextLabel", prompt)
    txt.Size = UDim2.new(1, 0, 0.6, 0)
    txt.Text = "Do you want turn on AFK Mode?"
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = "GothamBold"
    txt.TextSize = 16
    txt.BackgroundTransparency = 1

    local function createBtn(t, pos, color)
        local b = Instance.new("TextButton", prompt)
        b.Size = UDim2.new(0.4, 0, 0.3, 0)
        b.Position = pos
        b.Text = t
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", b)
        return b
    end

    local yes = createBtn("Yes", UDim2.new(0.05, 0, 0.6, 0), Color3.fromRGB(50, 150, 50))
    local no = createBtn("No", UDim2.new(0.55, 0, 0.6, 0), Color3.fromRGB(150, 50, 50))

    yes.MouseButton1Click:Connect(function() prompt:Destroy(); toggleAFK(true) end)
    no.MouseButton1Click:Connect(function() prompt:Destroy() end)
end

-- ==================================================================
-- SIDE MENU
-- ==================================================================
local toggleSideBtn = Instance.new("TextButton", outerFrame)
toggleSideBtn.Size = UDim2.new(0, 25, 0, 60); toggleSideBtn.Position = UDim2.new(1, 0, 0.5, -30); toggleSideBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); toggleSideBtn.Text = ">"; toggleSideBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleSideBtn)

local sideMenu = Instance.new("Frame", outerFrame)
sideMenu.Size = UDim2.new(1, 0, 1.2, 0); sideMenu.Position = UDim2.new(1, 10, 0, 0); sideMenu.BackgroundColor3 = Color3.fromRGB(10, 20, 35); sideMenu.BackgroundTransparency = 0.4; sideMenu.Visible = false
Instance.new("UICorner", sideMenu)

local sideLayout = Instance.new("UIListLayout", sideMenu); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", sideMenu).PaddingTop = UDim.new(0, 8)

local function sideBtn(t, c)
    local b = Instance.new("TextButton", sideMenu)
    b.Size = UDim2.new(0.9, 0, 0, 28); b.Text = t; b.BackgroundColor3 = c; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; b.TextSize = 14; Instance.new("UICorner", b)
    return b
end

local jobIn = Instance.new("TextBox", sideMenu)
jobIn.Size = UDim2.new(0.9, 0, 0, 28); jobIn.PlaceholderText = "Job-ID..."; jobIn.BackgroundColor3 = Color3.fromRGB(30, 40, 60); jobIn.TextColor3 = Color3.new(1,1,1); jobIn.TextSize = 14; Instance.new("UICorner", jobIn)

sideBtn("Join Job-id", Color3.fromRGB(45, 90, 180)).MouseButton1Click:Connect(function() 
    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIn.Text, localPlayer) 
end)
sideBtn("AFK Mode", Color3.fromRGB(180, 130, 50)).MouseButton1Click:Connect(ShowAFKPrompt)

toggleSideBtn.MouseButton1Click:Connect(function()
    sideMenu.Visible = not sideMenu.Visible
    toggleSideBtn.Text = sideMenu.Visible and "<" or ">"
end)

-- Rainbow & FPS
task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.5) % 1, 1, 1))
        })
        fpsL.Text = "FPS: " .. math.floor(1/dt)
    end)
end)
