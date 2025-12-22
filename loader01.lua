local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local StartTime = tick()

-- ==================================================================
-- HỆ THỐNG FILE (ANTI-ERROR)
-- ==================================================================
local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

local function saveConfig(content)
    if writefile then pcall(function() writefile(CONFIG_FILE_NAME, content) end) end
end

local function readConfig()
    if isfile and isfile(CONFIG_FILE_NAME) then
        local success, content = pcall(function() return readfile(CONFIG_FILE_NAME) end)
        if success then return content end
    end
    return "Script by HuyUnfes"
end

-- ==================================================================
-- CẤU HÌNH & CHE TÊN
-- ==================================================================
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 20 
local NOTE_FONT_SIZE = 24 

local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscure = math.ceil(len / 2) 
    return str:sub(1, math.ceil((len-obscure)/2)) .. string.rep("*", obscure) .. str:sub(len - math.floor((len-obscure)/2) + 1)
end
local MASKED_USERNAME = generateMaskedName(USERNAME)

local GameName = "Loading..."
task.spawn(function()
    pcall(function()
        GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
end)

-- ==================================================================
-- AFK MODE (SỬ DỤNG FONT DANCING SCRIPT & CÁCH HÀNG)
-- ==================================================================
local afkScreen = Instance.new("ScreenGui", localPlayer.PlayerGui)
afkScreen.Name = "AFK_Overlay"
afkScreen.Enabled = false
afkScreen.DisplayOrder = 999

local afkBg = Instance.new("Frame", afkScreen)
afkBg.Size = UDim2.new(1, 0, 1, 0)
afkBg.BackgroundColor3 = Color3.new(0, 0, 0)
afkBg.BackgroundTransparency = 0.5

local function createAfkText(pos, color, size, isTitle)
    local l = Instance.new("TextLabel", afkBg)
    l.Size = isTitle and UDim2.new(0.7, 0, 0.2, 0) or UDim2.new(1, 0, 0.05, 0)
    l.Position = pos
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.TextColor3 = color
    l.BackgroundTransparency = 1
    
    -- LOAD FONT DANCING SCRIPT TỪ HỆ THỐNG ROBLOX
    pcall(function()
        l.FontFace = Font.new("rbxasset://fonts/families/DancingScript.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    end)
    
    if isTitle then l.TextScaled = true else l.TextSize = size end
    return l
end

-- Giãn cách hàng cực xa theo đúng yêu cầu
local afkTitle = createAfkText(UDim2.new(0.5, 0, 0.25, 0), Color3.fromRGB(255, 224, 189), 0, true) -- Màu da
afkTitle.Text = "AFK Mode"

local afkMap = createAfkText(UDim2.new(0.5, 0, 0.45, 0), Color3.fromRGB(255, 255, 180), 32, false) -- Vàng nhạt
local afkUser = createAfkText(UDim2.new(0.5, 0, 0.58, 0), Color3.fromRGB(173, 216, 230), 28, false) -- Xanh nhạt
local afkTime = createAfkText(UDim2.new(0.5, 0, 0.72, 0), Color3.fromRGB(255, 150, 150), 28, false) -- Đỏ nhạt

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local function toggleAFK(state)
    afkScreen.Enabled = state
    blur.Size = state and 24 or 0
    if state then
        task.spawn(function()
            while afkScreen.Enabled do
                local s = tick() - StartTime
                afkTime.Text = string.format("Thời gian chơi: %dD:%dH:%dM:%dS", math.floor(s/86400), math.floor((s%86400)/3600), math.floor((s%3600)/60), math.floor(s%60))
                afkMap.Text = "Game: " .. GameName
                afkUser.Text = "Username: " .. MASKED_USERNAME
                task.wait(1)
            end
        end)
    end
end

-- Thoát AFK khi nhấn phím hoặc click
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if afkScreen.Enabled and (i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton1) then
        toggleAFK(false)
    end
end)

-- ==================================================================
-- MAIN UI (UI GIỮA CŨ - KHÔNG ĐỔI)
-- ==================================================================
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
screenGui.ResetOnSpawn = false

local outerFrame = Instance.new("Frame", screenGui)
outerFrame.Size = UDim2.new(0.45, 0, 0.15, 0) 
outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
outerFrame.AnchorPoint = Vector2.new(0.5, 0)
outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
outerFrame.Draggable = true
outerFrame.Active = true
Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, outerCornerRadius)
local uiGradient = Instance.new("UIGradient", outerFrame)

local innerFrame = Instance.new("Frame", outerFrame)
innerFrame.Size = UDim2.new(1, -6, 1, -6)
innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
innerFrame.BackgroundTransparency = transparencyLevel
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, outerCornerRadius - 3)

local header = Instance.new("Frame", innerFrame)
header.Size = UDim2.new(1, -15, 0.25, 0); header.BackgroundTransparency = 1
Instance.new("UIListLayout", innerFrame).HorizontalAlignment = "Center"

local userL = Instance.new("TextLabel", header)
userL.Size = UDim2.new(0.3, 0, 1, 0); userL.Text = "User: "..MASKED_USERNAME; userL.TextColor3 = Color3.new(0.8,0.8,0.8); userL.TextSize = FONT_SIZE; userL.Font = "SourceSansBold"; userL.BackgroundTransparency = 1; userL.TextXAlignment = "Left"

local mapL = Instance.new("TextLabel", header)
mapL.Size = UDim2.new(0.4, 0, 1, 0); mapL.Position = UDim2.new(0.3,0,0,0); mapL.Text = "Loading..."; mapL.TextColor3 = Color3.new(0.8,0.8,0.8); mapL.TextSize = FONT_SIZE; mapL.Font = "SourceSansBold"; mapL.BackgroundTransparency = 1

local fpsL = Instance.new("TextLabel", header)
fpsL.Size = UDim2.new(0.3, 0, 1, 0); fpsL.Position = UDim2.new(1,0,0,0); fpsL.AnchorPoint = Vector2.new(1,0); fpsL.Text = "FPS: 0"; fpsL.TextColor3 = Color3.fromRGB(0,255,127); fpsL.TextSize = FONT_SIZE; fpsL.Font = "SourceSansBold"; fpsL.BackgroundTransparency = 1; fpsL.TextXAlignment = "Right"

local scroll = Instance.new("ScrollingFrame", innerFrame)
scroll.Size = UDim2.new(1, 0, 0.65, 0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3

local note = Instance.new("TextBox", scroll)
note.Size = UDim2.new(1, -10, 1, 0); note.Position = UDim2.new(0,5,0,0); note.Text = readConfig(); note.PlaceholderText = "Script by HuyUnfes"; note.TextColor3 = Color3.new(1,1,1); note.MultiLine = true; note.TextWrapped = true; note.TextSize = NOTE_FONT_SIZE; note.Font = "SourceSans"; note.BackgroundTransparency = 1; note.TextXAlignment = "Left"; note.TextYAlignment = "Top"
note.FocusLost:Connect(function() saveConfig(note.Text) end)

-- ==================================================================
-- PROMPT & SIDE MENU
-- ==================================================================
local function ShowPrompt()
    local p = Instance.new("Frame", screenGui); p.Size = UDim2.new(0,280,0,120); p.Position = UDim2.new(0.5,0,0.5,0); p.AnchorPoint = Vector2.new(0.5,0.5); p.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",p)
    local t = Instance.new("TextLabel",p); t.Size = UDim2.new(1,0,0.6,0); t.Text = "Do you want turn on AFK Mode?"; t.TextColor3 = Color3.new(1,1,1); t.Font = "GothamBold"; t.TextSize = 16; t.BackgroundTransparency = 1; t.TextWrapped = true
    local function btn(txt, pos, col)
        local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.4,0,0.3,0); b.Position = pos; b.Text = txt; b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner",b); return b
    end
    btn("Yes", UDim2.new(0.05,0,0.6,0), Color3.fromRGB(50,150,50)).MouseButton1Click:Connect(function() p:Destroy(); toggleAFK(true) end)
    btn("No", UDim2.new(0.55,0,0.6,0), Color3.fromRGB(150,50,50)).MouseButton1Click:Connect(function() p:Destroy() end)
end

local toggleSide = Instance.new("TextButton", outerFrame)
toggleSide.Size = UDim2.new(0, 25, 0, 60); toggleSide.Position = UDim2.new(1, 0, 0.5, -30); toggleSide.BackgroundColor3 = Color3.fromRGB(20,20,20); toggleSide.Text = ">"; toggleSide.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleSide)

local sideMenu = Instance.new("Frame", outerFrame)
sideMenu.Size = UDim2.new(1, 0, 1.2, 0); sideMenu.Position = UDim2.new(1, 10, 0, 0); sideMenu.BackgroundColor3 = Color3.fromRGB(10, 20, 35); sideMenu.BackgroundTransparency = 0.4; sideMenu.Visible = false; Instance.new("UICorner", sideMenu)
local sideLayout = Instance.new("UIListLayout", sideMenu); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = "Center"; Instance.new("UIPadding", sideMenu).PaddingTop = UDim.new(0, 8)

local jobIn = Instance.new("TextBox", sideMenu); jobIn.Size = UDim2.new(0.9,0,0,28); jobIn.PlaceholderText = "Job-ID..."; jobIn.BackgroundColor3 = Color3.fromRGB(30,40,60); jobIn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", jobIn)
local function sBtn(txt, col)
    local b = Instance.new("TextButton", sideMenu); b.Size = UDim2.new(0.9,0,0,28); b.Text = txt; b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; Instance.new("UICorner",b); return b
end

sBtn("Join Job-id", Color3.fromRGB(45,90,180)).MouseButton1Click:Connect(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIn.Text, localPlayer) end)
sBtn("AFK Mode", Color3.fromRGB(180,130,50)).MouseButton1Click:Connect(ShowPrompt)

toggleSide.MouseButton1Click:Connect(function() sideMenu.Visible = not sideMenu.Visible; toggleSide.Text = sideMenu.Visible and "<" or ">" end)

-- Cập nhật Rainbow và FPS
task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(h,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV((h+0.5)%1,1,1))})
        fpsL.Text = "FPS: " .. math.floor(1/dt)
        mapL.Text = GameName
    end)
end)
