local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Cấu hình UI
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 18 
local NOTE_FONT_SIZE = 20 

local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

-- Hàm đọc/ghi file config cho Note
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
-- MAIN UI (CHÍNH GIỮA)
-- ==================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnfesMainGUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.4, 0, 0.15, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.05, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.BackgroundColor3 = Color3.new(1, 1, 1)
mainFrame.BackgroundTransparency = transparencyLevel
mainFrame.Active = true 
mainFrame.Draggable = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, outerCornerRadius)
local mainGradient = Instance.new("UIGradient", mainFrame)

local mainInner = Instance.new("Frame")
mainInner.Size = UDim2.new(1, -6, 1, -6)
mainInner.Position = UDim2.new(0.5, 0, 0.5, 0)
mainInner.AnchorPoint = Vector2.new(0.5, 0.5)
mainInner.BackgroundColor3 = Color3.new(0, 0, 0)
mainInner.BackgroundTransparency = transparencyLevel
mainInner.Parent = mainInner.Parent
mainInner.Parent = mainFrame
Instance.new("UICorner", mainInner).CornerRadius = UDim.new(0, outerCornerRadius - 3)

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 5)
mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainLayout.Parent = mainInner

-- Header & Note
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -15, 0.3, 0); header.BackgroundTransparency = 1; header.Parent = mainInner
local userLbl = Instance.new("TextLabel")
userLbl.Size = UDim2.new(0.4, 0, 1, 0); userLbl.Text = "User: "..USERNAME:sub(1,3).."***"; userLbl.TextColor3 = Color3.new(0.8,0.8,0.8); userLbl.TextSize = FONT_SIZE; userLbl.Font = Enum.Font.SourceSansBold; userLbl.BackgroundTransparency = 1; userLbl.Parent = header
local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0.3, 0, 1, 0); fpsLbl.Position = UDim2.new(1,0,0,0); fpsLbl.AnchorPoint = Vector2.new(1,0); fpsLbl.Text = "FPS: 0"; fpsLbl.TextColor3 = Color3.fromRGB(0,255,127); fpsLbl.TextSize = FONT_SIZE; fpsLbl.Font = Enum.Font.SourceSansBold; fpsLbl.BackgroundTransparency = 1; fpsLbl.Parent = header
local noteScroll = Instance.new("ScrollingFrame")
noteScroll.Size = UDim2.new(1, -10, 0.6, 0); noteScroll.BackgroundTransparency = 1; noteScroll.ScrollBarThickness = 2; noteScroll.Parent = mainInner
local noteBox = Instance.new("TextBox")
noteBox.Size = UDim2.new(1, 0, 1, 0); noteBox.Text = readConfig(CONFIG_FILE_NAME); noteBox.PlaceholderText = "Ghi chú..."; noteBox.TextColor3 = Color3.new(1,1,1); noteBox.MultiLine = true; noteBox.TextWrapped = true; noteBox.TextSize = NOTE_FONT_SIZE; noteBox.Font = Enum.Font.SourceSans; noteBox.BackgroundTransparency = 1; noteBox.Parent = noteScroll

-- ==================================================================
-- JOB ID UI (BÊN PHẢI)
-- ==================================================================
local jobSideFrame = Instance.new("Frame")
jobSideFrame.Size = UDim2.new(0, 220, 0, 185) 
jobSideFrame.Position = UDim2.new(1, 10, 0.4, 0) -- Giấu sau lề phải
jobSideFrame.BackgroundColor3 = Color3.new(1, 1, 1)
jobSideFrame.BackgroundTransparency = transparencyLevel
jobSideFrame.Parent = screenGui
local jobGradient = Instance.new("UIGradient", jobSideFrame)
Instance.new("UICorner", jobSideFrame).CornerRadius = UDim.new(0, 10)

local jobInner = Instance.new("Frame")
jobInner.Size = UDim2.new(1, -6, 1, -6)
jobInner.Position = UDim2.new(0.5, 0, 0.5, 0)
jobInner.AnchorPoint = Vector2.new(0.5, 0.5)
jobInner.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
jobInner.Parent = jobSideFrame
Instance.new("UICorner", jobInner).CornerRadius = UDim.new(0, 8)

local jobLayout = Instance.new("UIListLayout")
jobLayout.Padding = UDim.new(0, 8)
jobLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
jobLayout.Parent = jobInner

local jobTitle = Instance.new("TextLabel")
jobTitle.Size = UDim2.new(1, 0, 0, 30)
jobTitle.Text = "SERVER UTILS"
jobTitle.TextColor3 = Color3.new(1, 1, 1); jobTitle.Font = Enum.Font.GothamBold; jobTitle.TextSize = 14; jobTitle.BackgroundTransparency = 1; jobTitle.Parent = jobInner

local jobIdInput = Instance.new("TextBox")
jobIdInput.Size = UDim2.new(0.9, 0, 0, 30)
jobIdInput.PlaceholderText = "Job ID Box..."
jobIdInput.Text = ""
jobIdInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35); jobIdInput.TextColor3 = Color3.new(1, 1, 1); jobIdInput.Font = Enum.Font.SourceSans; jobIdInput.TextSize = 14; jobIdInput.Parent = jobInner
Instance.new("UICorner", jobIdInput)

-- [NÚT 1: JOIN TỪ CLIPBOARD] (MỚI)
local clipBtn = Instance.new("TextButton")
clipBtn.Size = UDim2.new(0.9, 0, 0, 25)
clipBtn.Text = "JOIN FROM CLIPBOARD"
clipBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
clipBtn.TextColor3 = Color3.new(1, 1, 1); clipBtn.Font = Enum.Font.SourceSansBold; clipBtn.Parent = jobInner
Instance.new("UICorner", clipBtn)

-- [NÚT 2: JOIN TỪ Ô NHẬP]
local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(0.9, 0, 0, 25)
joinBtn.Text = "JOIN FROM BOX"
joinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
joinBtn.TextColor3 = Color3.new(1, 1, 1); joinBtn.Font = Enum.Font.SourceSansBold; joinBtn.Parent = jobInner
Instance.new("UICorner", joinBtn)

-- [NÚT 3: SPAM JOIN (YES/NO)]
local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(0.9, 0, 0, 25)
spamBtn.Text = "SPAM JOIN: NO"
spamBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
spamBtn.TextColor3 = Color3.new(1, 1, 1); spamBtn.Font = Enum.Font.SourceSansBold; spamBtn.Parent = jobInner
Instance.new("UICorner", spamBtn)

-- ==================================================================
-- XỬ LÝ LOGIC
-- ==================================================================

-- Hàm Teleport
local function joinJob(id)
    if id and #id > 5 then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
        end)
    end
end

-- Logic Nút Clipboard
clipBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local clipboardContent = getclipboard()
        jobIdInput.Text = clipboardContent -- Hiện ID vào box để người dùng biết
        joinJob(clipboardContent)
    end
end)

-- Logic Nút Box
joinBtn.MouseButton1Click:Connect(function()
    joinJob(jobIdInput.Text)
end)

-- Logic Spam Join
local isSpamming = false
spamBtn.MouseButton1Click:Connect(function()
    isSpamming = not isSpamming
    if isSpamming then
        spamBtn.Text = "SPAM JOIN: YES"
        spamBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        spamBtn.Text = "SPAM JOIN: NO"
        spamBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.7)
        if isSpamming then
            joinJob(jobIdInput.Text)
        end
    end
end)

-- ==================================================================
-- NÚT MỞ RỘNG (SIDE TOGGLE)
-- ==================================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 60)
toggleBtn.Position = UDim2.new(1, -35, 0.4, 60) 
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Text = "<"
toggleBtn.TextColor3 = Color3.new(1, 1, 1); toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 20; toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local isOpen = false
toggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        TweenService:Create(jobSideFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -230, 0.4, 0)}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -265, 0.4, 60)}):Play()
        toggleBtn.Text = ">"
    else
        TweenService:Create(jobSideFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 0.4, 0)}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -35, 0.4, 60)}):Play()
        toggleBtn.Text = "<"
    end
end)

-- Loop Hiệu ứng
task.spawn(function()
    local h = 0
    while true do
        h = (h + 0.005) % 1
        local color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.5) % 1, 1, 1))
        })
        mainGradient.Color = color
        jobGradient.Color = color
        task.wait()
    end
end)

task.spawn(function()
    while true do
        local dt = RunService.RenderStepped:Wait()
        fpsLbl.Text = "FPS: " .. math.floor(1/dt)
    end
end)

noteBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteBox.Text) end)
