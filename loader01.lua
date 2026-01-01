local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local StartTime = tick()
local AFK_Started_Time = 0
local Is_Spamming_Join = false

-- ==================================================================
-- HỆ THỐNG FILE & CONFIG
-- ==================================================================
local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_Exviun_" .. USERNAME .. ".txt"
local IMAGE_NAME = "AFK_Mode.jpeg"
local IMAGE_URL = "https://raw.githubusercontent.com/HuyUnfes/Unfes.lua/refs/heads/main/1351993.jpeg"

local function downloadBackground()
    if writefile and readfile and not isfile(IMAGE_NAME) then
        pcall(function()
            local success, content = pcall(function() return game:HttpGet(IMAGE_URL) end)
            if success then writefile(IMAGE_NAME, content) end
        end)
    end
end
task.spawn(downloadBackground)

-- ==================================================================
-- ANTI-AFK LOGIC
-- ==================================================================
local function SetAntiAfk(state)
    if state then
        if _G.AntiAfkConnection then _G.AntiAfkConnection:Disconnect() end
        _G.AntiAfkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if _G.AntiAfkConnection then _G.AntiAfkConnection:Disconnect() end
    end
end

-- ==================================================================
-- AFK MODE UI (NÂNG CẤP)
-- ==================================================================
local afkScreen = Instance.new("ScreenGui", localPlayer.PlayerGui)
afkScreen.Name = "AFK_Overlay_Premium"
afkScreen.Enabled = false
afkScreen.IgnoreGuiInset = true 

local afkBg = Instance.new("ImageLabel", afkScreen)
afkBg.Size = UDim2.new(1, 0, 1, 0)
afkBg.BackgroundTransparency = 1
afkBg.ImageTransparency = 0.7
afkBg.ScaleType = Enum.ScaleType.Crop

task.spawn(function()
    while not isfile(IMAGE_NAME) do task.wait(0.5) end
    pcall(function() afkBg.Image = getcustomasset(IMAGE_NAME) end)
end)

-- Nút X thiết kế sang trọng
local exitAfkBtn = Instance.new("TextButton", afkBg)
exitAfkBtn.Size = UDim2.new(0, 50, 0, 50)
exitAfkBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
exitAfkBtn.AnchorPoint = Vector2.new(0.5, 0.5)
exitAfkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
exitAfkBtn.Text = "×"
exitAfkBtn.TextColor3 = Color3.new(1, 1, 1)
exitAfkBtn.TextSize = 40
Instance.new("UICorner", exitAfkBtn).CornerRadius = UDim.new(1, 0)
local xStroke = Instance.new("UIStroke", exitAfkBtn)
xStroke.Thickness = 2; xStroke.Color = Color3.new(1,1,1)

local function createAfkLabel(name, pos, color, size, isScaled)
    local l = Instance.new("TextLabel", afkBg)
    l.Name = name
    l.Size = isScaled and UDim2.new(0.8, 0, 0.15, 0) or UDim2.new(1, 0, 0.05, 0)
    l.Position = pos
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.TextColor3 = color
    l.BackgroundTransparency = 1
    l.TextStrokeTransparency = 0.6
    l.FontFace = Font.new("rbxassetid://8764312106") -- Dancing Script
    if isScaled then l.TextScaled = true else l.TextSize = size end
    return l
end

local afkTitle = createAfkLabel("Title", UDim2.new(0.5, 0, 0.22, 0), Color3.new(1,1,1), 0, true)
afkTitle.Text = "AFK Mode"
local afkMap = createAfkLabel("Map", UDim2.new(0.5, 0, 0.40, 0), Color3.fromRGB(255, 255, 180), 32, false)
local afkUser = createAfkLabel("User", UDim2.new(0.5, 0, 0.50, 0), Color3.fromRGB(173, 216, 230), 28, false)
local afkTime = createAfkLabel("Time", UDim2.new(0.5, 0, 0.60, 0), Color3.fromRGB(255, 150, 150), 28, false)
local afkTotal = createAfkLabel("Total", UDim2.new(0.5, 0, 0.70, 0), Color3.fromRGB(150, 255, 150), 28, false)

local function toggleAFK(state)
    afkScreen.Enabled = state
    SetAntiAfk(state) -- Tự động bật/tắt Anti-AFK
    if state then
        AFK_Started_Time = tick()
        task.spawn(function()
            while afkScreen.Enabled do
                local session = tick() - StartTime
                local afkDuration = tick() - AFK_Started_Time
                afkTime.Text = string.format("AFK Duration: %dM:%dS", math.floor(afkDuration/60), math.floor(afkDuration%60))
                afkTotal.Text = string.format("Total Session: %dH:%dM:%dS", math.floor(session/3600), math.floor((session%3600)/60), math.floor(session%60))
                afkUser.Text = "User: " .. USERNAME
                task.wait(1)
            end
        end)
    end
end
exitAfkBtn.MouseButton1Click:Connect(function() toggleAFK(false) end)

-- ==================================================================
-- MAIN UI & SIDE MENU (ĐẸP HƠN)
-- ==================================================================
local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
local outerFrame = Instance.new("Frame", screenGui)
outerFrame.Size = UDim2.new(0.4, 0, 0.14, 0)
outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0)
outerFrame.AnchorPoint = Vector2.new(0.5, 0)
outerFrame.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", outerFrame)
local uiGradient = Instance.new("UIGradient", outerFrame)

local innerFrame = Instance.new("Frame", outerFrame)
innerFrame.Size = UDim2.new(1, -6, 1, -6); innerFrame.Position = UDim2.new(0.5,0,0.5,0); innerFrame.AnchorPoint = Vector2.new(0.5,0.5); innerFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", innerFrame)

-- SIDE MENU DESIGN
local sideMenu = Instance.new("Frame", outerFrame)
sideMenu.Size = UDim2.new(0.7, 0, 2.5, 0)
sideMenu.Position = UDim2.new(1, 15, 0, 0)
sideMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sideMenu.Visible = false
local sideCorner = Instance.new("UICorner", sideMenu)
local sideStroke = Instance.new("UIStroke", sideMenu)
sideStroke.Color = Color3.fromRGB(60, 60, 70); sideStroke.Thickness = 2

local sideLayout = Instance.new("UIListLayout", sideMenu)
sideLayout.Padding = UDim.new(0, 10); sideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", sideMenu).PaddingTop = UDim.new(0, 12)

-- Các thành phần Side Menu
local jobIn = Instance.new("TextBox", sideMenu)
jobIn.Size = UDim2.new(0.9, 0, 0, 35)
jobIn.PlaceholderText = "Job-ID Here..."
jobIn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
jobIn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", jobIn)

local function styledBtn(text, color)
    local btn = Instance.new("TextButton", sideMenu)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    -- Hiệu ứng Hover
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
    return btn
end

local joinBtn = styledBtn("Join Job-ID", Color3.fromRGB(50, 100, 200))
local spamBtn = styledBtn("Spam Join: OFF", Color3.fromRGB(180, 50, 50))
local afkBtn = styledBtn("AFK Mode", Color3.fromRGB(200, 150, 50))

-- Logic Spam Join
spamBtn.MouseButton1Click:Connect(function()
    Is_Spamming_Join = not Is_Spamming_Join
    spamBtn.Text = Is_Spamming_Join and "Spam Join: ON" or "Spam Join: OFF"
    spamBtn.BackgroundColor3 = Is_Spamming_Join and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
    
    task.spawn(function()
        while Is_Spamming_Join do
            if jobIn.Text ~= "" then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIn.Text, localPlayer)
            end
            task.wait(3) -- Chờ teleport
        end
    end)
end)

joinBtn.MouseButton1Click:Connect(function()
    if jobIn.Text ~= "" then TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIn.Text, localPlayer) end
end)

afkBtn.MouseButton1Click:Connect(function() toggleAFK(true) end)

-- Nút đóng mở Side Menu
local toggleSide = Instance.new("TextButton", outerFrame)
toggleSide.Size = UDim2.new(0, 25, 0, 50); toggleSide.Position = UDim2.new(1, 0, 0.5, -25); toggleSide.Text = ">"; toggleSide.BackgroundColor3 = Color3.fromRGB(30,30,30); toggleSide.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleSide)

toggleSide.MouseButton1Click:Connect(function()
    sideMenu.Visible = not sideMenu.Visible
    toggleSide.Text = sideMenu.Visible and "<" or ">"
end)

-- Hiệu ứng Rainbow & FPS
local fpsL = Instance.new("TextLabel", innerFrame)
fpsL.Size = UDim2.new(1, -20, 0.3, 0); fpsL.BackgroundTransparency = 1; fpsL.TextColor3 = Color3.new(1,1,1); fpsL.TextXAlignment = "Right"; fpsL.Font = "GothamBold"; fpsL.TextSize = 16

task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(h,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV((h+0.5)%1,1,1))})
        fpsL.Text = "FPS: " .. math.floor(1/dt)
    end)
end)
