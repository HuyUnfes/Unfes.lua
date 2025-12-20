-- hello
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Cấu hình cơ bản
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 18 
local NOTE_FONT_SIZE = 20 

local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

-- Hàm phụ trợ
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
-- SCREEN GUI CHÍNH
-- ==================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnfesFinalUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- ==================================================================
-- UI CHÍNH (GIỮA MÀN HÌNH)
-- ==================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 150)
mainFrame.Position = UDim2.new(0.5, -225, 0.05, 0)
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
mainInner.BackgroundTransparency = 0.2
mainInner.Parent = mainFrame
Instance.new("UICorner", mainInner).CornerRadius = UDim.new(0, outerCornerRadius - 3)

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 5)
mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainLayout.Parent = mainInner

-- Header (User & FPS)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -20, 0, 40)
header.BackgroundTransparency = 1
header.Parent = mainInner

local userLbl = Instance.new("TextLabel")
userLbl.Size = UDim2.new(0.5, 0, 1, 0)
userLbl.Text = "User: " .. USERNAME:sub(1,3) .. "***"
userLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
userLbl.TextSize = FONT_SIZE
userLbl.Font = Enum.Font.SourceSansBold
userLbl.BackgroundTransparency = 1
userLbl.TextXAlignment = Enum.TextXAlignment.Left
userLbl.Parent = header

local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0.5, 0, 1, 0)
fpsLbl.Position = UDim2.new(0.5, 0, 0, 0)
fpsLbl.Text = "FPS: 0"
fpsLbl.TextColor3 = Color3.fromRGB(0, 255, 127)
fpsLbl.TextSize = FONT_SIZE
fpsLbl.Font = Enum.Font.SourceSansBold
fpsLbl.BackgroundTransparency = 1
fpsLbl.TextXAlignment = Enum.TextXAlignment.Right
fpsLbl.Parent = header

-- Note Box
local noteScroll = Instance.new("ScrollingFrame")
noteScroll.Size = UDim2.new(1, -15, 0, 80)
noteScroll.BackgroundTransparency = 1
noteScroll.ScrollBarThickness = 2
noteScroll.CanvasSize = UDim2.new(0,0,2,0)
noteScroll.Parent = mainInner

local noteBox = Instance.new("TextBox")
noteBox.Size = UDim2.new(1, 0, 1, 0)
noteBox.Text = readConfig(CONFIG_FILE_NAME)
noteBox.PlaceholderText = "Write notes here..."
noteBox.TextColor3 = Color3.new(1, 1, 1)
noteBox.MultiLine = true
noteBox.TextWrapped = true
noteBox.TextSize = NOTE_FONT_SIZE
noteBox.Font = Enum.Font.SourceSans
noteBox.BackgroundTransparency = 1
noteBox.TextYAlignment = Enum.TextYAlignment.Top
noteBox.TextXAlignment = Enum.TextXAlignment.Left
noteBox.Parent = noteScroll

-- ==================================================================
-- UI JOB ID (BÊN PHẢI)
-- ==================================================================
local jobSideFrame = Instance.new("Frame")
jobSideFrame.Name = "JobSideFrame"
jobSideFrame.Size = UDim2.new(0, 220, 0, 220)
jobSideFrame.Position = UDim2.new(1, 10, 0.4, 0) -- Ẩn
jobSideFrame.BackgroundColor3 = Color3.new(1, 1, 1)
jobSideFrame.BackgroundTransparency = transparencyLevel
jobSideFrame.Parent = screenGui
local jobGradient = Instance.new("UIGradient", jobSideFrame)
Instance.new("UICorner", jobSideFrame).CornerRadius = UDim.new(0, 10)

local jobInner = Instance.new("Frame")
jobInner.Size = UDim2.new(1, -6, 1, -6)
jobInner.Position = UDim2.new(0.5, 0, 0.5, 0)
jobInner.AnchorPoint = Vector2.new(0.5, 0.5)
jobInner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
jobInner.Parent = jobSideFrame
Instance.new("UICorner", jobInner).CornerRadius = UDim.new(0, 8)

local jobLayout = Instance.new("UIListLayout")
jobLayout.Padding = UDim.new(0, 10)
jobLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
jobLayout.Parent = jobInner

local jobTitle = Instance.new("TextLabel")
jobTitle.Size = UDim2.new(1, 0, 0, 35)
jobTitle.Text = "SERVER UTILS"
jobTitle.TextColor3 = Color3.new(1, 1, 1)
jobTitle.Font = Enum.Font.GothamBold
jobTitle.TextSize = 14
jobTitle.BackgroundTransparency = 1
jobTitle.Parent = jobInner

local jobIdInput = Instance.new("TextBox")
jobIdInput.Size = UDim2.new(0.9, 0, 0, 30)
jobIdInput.PlaceholderText = "Job ID Box..."
jobIdInput.Text = ""
jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
jobIdInput.TextColor3 = Color3.new(1, 1, 1)
jobIdInput.Font = Enum.Font.SourceSans
jobIdInput.TextSize = 14
jobIdInput.Parent = jobInner
Instance.new("UICorner", jobIdInput)

-- Các nút chức năng
local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = jobInner
    Instance.new("UICorner", btn)
    return btn
end

local clipBtn = createButton("JOIN FROM CLIPBOARD", Color3.fromRGB(85, 0, 255))
local joinBtn = createButton("JOIN FROM BOX", Color3.fromRGB(0, 120, 215))
local spamBtn = createButton("SPAM JOIN: NO", Color3.fromRGB(150, 0, 0))

-- ==================================================================
-- NÚT MỞ RỘNG (TOGGLE)
-- ==================================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 60)
toggleBtn.Position = UDim2.new(1, -35, 0.4, 80) -- Sát lề phải
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Text = "<"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- ==================================================================
-- LOGIC XỬ LÝ
-- ==================================================================

local function teleport(id)
    if id and #id > 5 then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
        end)
    end
end

-- Mở/Đóng Job ID UI
local isOpen = false
toggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        TweenService:Create(jobSideFrame, TweenInfo.new(0.4), {Position = UDim2.new(1, -230, 0.4, 0)}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.4), {Position = UDim2.new(1, -265, 0.4, 80)}):Play()
        toggleBtn.Text = ">"
    else
        TweenService:Create(jobSideFrame, TweenInfo.new(0.4), {Position = UDim2.new(1, 10, 0.4, 0)}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.4), {Position = UDim2.new(1, -35, 0.4, 80)}):Play()
        toggleBtn.Text = "<"
    end
end)

-- Nút Clipboard
clipBtn.MouseButton1Click:Connect(function()
    local success, content = pcall(function() return getclipboard() end)
    if success and content then
        jobIdInput.Text = content
        teleport(content)
    end
end)

-- Nút Join Box
joinBtn.MouseButton1Click:Connect(function()
    teleport(jobIdInput.Text)
end)

-- Nút Spam Join
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
        task.wait(1)
        if isSpamming then
            teleport(jobIdInput.Text)
        end
    end
end)

-- Hiệu ứng Rainbow & FPS
task.spawn(function()
    local h = 0
    while true do
        h = (h + 0.005) % 1
        local col = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.5) % 1, 1, 1))
        })
        mainGradient.Color = col
        jobGradient.Color = col
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
