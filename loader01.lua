--test
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
-- THÔNG BÁO
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

local outerFrame = Instance.new("Frame")
outerFrame.Size = UDim2.new(0.45, 0, 0.15, 0) 
outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
outerFrame.AnchorPoint = Vector2.new(0.5, 0)
outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
outerFrame.Active = true 
outerFrame.Draggable = true 
outerFrame.Parent = screenGui
Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, outerCornerRadius)
local uiGradient = Instance.new("UIGradient", outerFrame)

local innerFrame = Instance.new("Frame")
innerFrame.Size = UDim2.new(1, -2 * borderThickness, 1, -2 * borderThickness)
innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
innerFrame.BackgroundTransparency = transparencyLevel
innerFrame.ClipsDescendants = true 
innerFrame.Parent = outerFrame
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)

local listLayout = Instance.new("UIListLayout", innerFrame)
listLayout.Padding = UDim.new(0, 5); listLayout.HorizontalAlignment = "Center"

local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, -15, 0.25, 0)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = innerFrame

local usernameLabel = Instance.new("TextLabel", headerFrame)
usernameLabel.Size = UDim2.new(0.3, 0, 1, 0); usernameLabel.Text = "User: "..MASKED_USERNAME; usernameLabel.TextColor3 = Color3.new(0.8,0.8,0.8); usernameLabel.TextSize = FONT_SIZE; usernameLabel.Font = "SourceSansBold"; usernameLabel.BackgroundTransparency = 1; usernameLabel.TextXAlignment = "Left"

local mapNameLabel = Instance.new("TextLabel", headerFrame)
mapNameLabel.Size = UDim2.new(0.5, 0, 1, 0); mapNameLabel.Position = UDim2.new(0.3,0,0,0); mapNameLabel.Text = GameName; mapNameLabel.TextColor3 = Color3.new(0.8,0.8,0.8); mapNameLabel.TextSize = FONT_SIZE; mapNameLabel.Font = "SourceSansBold"; mapNameLabel.BackgroundTransparency = 1; mapNameLabel.TextTruncate = "AtEnd"

local fpsLabel = Instance.new("TextLabel", headerFrame)
fpsLabel.Size = UDim2.new(0.2, 0, 1, 0); fpsLabel.Position = UDim2.new(1,0,0,0); fpsLabel.AnchorPoint = Vector2.new(1,0); fpsLabel.Text = "FPS: 0"; fpsLabel.TextColor3 = Color3.fromRGB(0,255,127); fpsLabel.TextSize = FONT_SIZE; fpsLabel.Font = "SourceSansBold"; fpsLabel.BackgroundTransparency = 1; fpsLabel.TextXAlignment = "Right"

local scroll = Instance.new("ScrollingFrame", innerFrame)
scroll.Size = UDim2.new(1, 0, 0.65, 0); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 5

local noteTextBox = Instance.new("TextBox", scroll)
noteTextBox.Size = UDim2.new(1, -10, 0, 0); noteTextBox.Position = UDim2.new(0,5,0,0); noteTextBox.Text = readConfig(CONFIG_FILE_NAME); noteTextBox.PlaceholderText = "Script by HuyUnfes"; noteTextBox.TextColor3 = Color3.new(1,1,1); noteTextBox.MultiLine = true; noteTextBox.TextWrapped = true; noteTextBox.TextSize = NOTE_FONT_SIZE; noteTextBox.Font = "SourceSans"; noteTextBox.BackgroundTransparency = 1; noteTextBox.TextXAlignment = "Left"; noteTextBox.TextYAlignment = "Top"

local function updateCanvas()
    local textBounds = TextService:GetTextSize(noteTextBox.Text, NOTE_FONT_SIZE, "SourceSans", Vector2.new(scroll.AbsoluteSize.X - 10, 10000))
    scroll.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 20)
    noteTextBox.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
end
noteTextBox:GetPropertyChangedSignal("Text"):Connect(updateCanvas)
noteTextBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteTextBox.Text) end)

-- ==================================================================
-- SIDE MENU (PHẢI)
-- ==================================================================
local sideMenuVisible = false
local spamJoinActive = false

local toggleSideBtn = Instance.new("TextButton", outerFrame)
toggleSideBtn.Size = UDim2.new(0, 25, 0, 60); toggleSideBtn.Position = UDim2.new(1, 0, 0.5, -30); toggleSideBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); toggleSideBtn.BackgroundTransparency = 0.2; toggleSideBtn.Text = ">"; toggleSideBtn.TextColor3 = Color3.new(1,1,1); toggleSideBtn.TextSize = 20; toggleSideBtn.Font = "GothamBold"
Instance.new("UICorner", toggleSideBtn).CornerRadius = UDim.new(0, 8)

local sideMenu = Instance.new("Frame", outerFrame)
sideMenu.Size = UDim2.new(1, 0, 0.85, 0); sideMenu.Position = UDim2.new(1, 10, 0.075, 0); sideMenu.BackgroundColor3 = Color3.fromRGB(10, 20, 35); sideMenu.BackgroundTransparency = 0.4; sideMenu.Visible = false
Instance.new("UICorner", sideMenu).CornerRadius = UDim.new(0, 15)

local sideLayout = Instance.new("UIListLayout", sideMenu); sideLayout.Padding = UDim.new(0, 8); sideLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", sideMenu).PaddingTop = UDim.new(0, 10)

local function createSideBtn(text, color)
    local b = Instance.new("TextButton", sideMenu)
    b.Size = UDim2.new(0.9, 0, 0, 32); b.Text = text; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; b.TextSize = 16
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local jobInput = Instance.new("TextBox", sideMenu)
jobInput.Size = UDim2.new(0.9, 0, 0, 32); jobInput.PlaceholderText = "Nhập Job-ID..."; jobInput.BackgroundColor3 = Color3.fromRGB(30, 40, 60); jobInput.TextColor3 = Color3.new(1,1,1); jobInput.Font = "SourceSans"; jobInput.TextSize = 16
Instance.new("UICorner", jobInput).CornerRadius = UDim.new(0, 6)

local joinBtn = createSideBtn("Join Job-id", Color3.fromRGB(45, 90, 180))
local clipBtn = createSideBtn("Job-id Clipboard", Color3.fromRGB(50, 130, 100))
local spamBtn = createSideBtn("Spam Join: No", Color3.fromRGB(150, 50, 50))

-- LOGIC JOIN CHUẨN
local function doTeleport(id)
    if id and id ~= "" then
        -- Lọc ID (Chỉ giữ lại chữ cái và số, xóa khoảng cách/ngoặc)
        local cleanId = tostring(id):gsub("%s+", ""):gsub("['\"]", ""):gsub("%(", ""):gsub("%)", ""):gsub(";", "")
        SendNotification("Teleport", "ID: " .. cleanId, 2)
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, cleanId, localPlayer) end)
    else
        SendNotification("Lỗi", "Job-ID trống!", 2)
    end
end

toggleSideBtn.MouseButton1Click:Connect(function()
    sideMenuVisible = not sideMenuVisible
    sideMenu.Visible = sideMenuVisible
    toggleSideBtn.Text = sideMenuVisible and "<" or ">"
end)

joinBtn.MouseButton1Click:Connect(function() doTeleport(jobInput.Text) end)

-- FIX LỖI CLIPBOARD
clipBtn.MouseButton1Click:Connect(function()
    -- Thử các hàm lấy clipboard phổ biến của Executor
    local clipboardFunc = getclipboard or readclipboard or (syn and syn.get_clipboard)
    
    if clipboardFunc then
        local success, content = pcall(clipboardFunc)
        if success and content and content ~= "" then
            jobInput.Text = tostring(content)
            doTeleport(content)
        else
            SendNotification("Lỗi", "Bộ nhớ tạm trống hoặc không đọc được!", 2)
        end
    else
        SendNotification("Lỗi", "Executor không hỗ trợ Clipboard!", 3)
    end
end)

spamBtn.MouseButton1Click:Connect(function()
    spamJoinActive = not spamJoinActive
    spamBtn.Text = "Spam Join: " .. (spamJoinActive and "Yes" or "No")
    spamBtn.BackgroundColor3 = spamJoinActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

task.spawn(function()
    while task.wait(3) do
        if spamJoinActive and jobInput.Text ~= "" then doTeleport(jobInput.Text) end
    end
end)

task.spawn(function()
    local h = 0 
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 1, 1))
        })
        fpsLabel.Text = "FPS: " .. math.floor(1/dt)
        if mapNameLabel.Text ~= GameName then mapNameLabel.Text = GameName end
    end)
end)

SendNotification("Unfes Script", "Đã tải thành công!", 4)
