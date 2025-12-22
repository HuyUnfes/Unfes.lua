local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService") 
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- Kiểm tra PlayerGui trước khi chạy tiếp
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then warn("Không tìm thấy PlayerGui!") return end

print("Unfes Script: Khởi tạo...")

-- CẤU HÌNH
local borderThickness = 3
local outerCornerRadius = 15
local transparencyLevel = 0.3
local FONT_SIZE = 18 
local NOTE_FONT_SIZE = 20 
local USERNAME = localPlayer.Name
local CONFIG_FILE_NAME = "Unfes_" .. USERNAME .. ".txt"

-- Hàm che tên
local function generateMaskedName(str)
    local len = #str
    if len <= 3 then return str end 
    local obscureLength = math.ceil(len / 2) 
    return str:sub(1, math.floor((len-obscureLength)/2)) .. string.rep("*", obscureLength) .. str:sub(len - math.ceil((len-obscureLength)/2) + 1)
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

-- Đọc/Lưu file (Sửa lỗi pcall)
local function readConfig(fileName)
    local status, content = pcall(function() return readfile(fileName) end)
    if status and content then return content end
    return "" 
end
local function saveConfig(fileName, content)
    pcall(function() writefile(fileName, content) end)
end

-- ==================================================================
-- HỆ THỐNG THÔNG BÁO (NOTIFICATION)
-- ==================================================================
local function SendNotification(title, text, duration)
    task.spawn(function()
        local notifyFrame = Instance.new("Frame")
        notifyFrame.Size = UDim2.new(0, 250, 0, 60)
        notifyFrame.Position = UDim2.new(1, 10, 0.8, 0)
        notifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        notifyFrame.BackgroundTransparency = 0.2
        notifyFrame.Parent = playerGui:FindFirstChild("UnfesMainGUI") or Instance.new("ScreenGui", playerGui)
        
        Instance.new("UICorner", notifyFrame).CornerRadius = UDim.new(0, 8)
        
        local tLabel = Instance.new("TextLabel", notifyFrame)
        tLabel.Size = UDim2.new(1, -10, 0, 25)
        tLabel.Position = UDim2.new(0, 5, 0, 5)
        tLabel.Text = title
        tLabel.TextColor3 = Color3.new(1, 1, 1)
        tLabel.Font = Enum.Font.GothamBold
        tLabel.BackgroundTransparency = 1
        tLabel.TextXAlignment = Enum.TextXAlignment.Left

        local mLabel = Instance.new("TextLabel", notifyFrame)
        mLabel.Size = UDim2.new(1, -10, 0, 20)
        mLabel.Position = UDim2.new(0, 5, 0, 30)
        mLabel.Text = text
        mLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        mLabel.Font = Enum.Font.Gotham
        mLabel.BackgroundTransparency = 1
        mLabel.TextXAlignment = Enum.TextXAlignment.Left

        notifyFrame:TweenPosition(UDim2.new(1, -260, 0.8, 0), "Out", "Quint", 0.5)
        task.wait(duration or 3)
        notifyFrame:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Quint", 0.5)
        task.wait(0.5)
        notifyFrame:Destroy()
    end)
end

-- ==================================================================
-- MAIN UI
-- ==================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnfesMainGUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local outerFrame = Instance.new("Frame")
outerFrame.Name = "MainFrame"
outerFrame.Size = UDim2.new(0.4, 0, 0.18, 0) 
outerFrame.Position = UDim2.new(0.5, 0, 0.05, 0) 
outerFrame.AnchorPoint = Vector2.new(0.5, 0)
outerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
outerFrame.Active = true 
outerFrame.Draggable = true 
outerFrame.Parent = screenGui

Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, outerCornerRadius)
local uiGradient = Instance.new("UIGradient", outerFrame)

local innerFrame = Instance.new("Frame")
innerFrame.Size = UDim2.new(1, -borderThickness*2, 1, -borderThickness*2)
innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
innerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
innerFrame.BackgroundTransparency = transparencyLevel
innerFrame.Parent = outerFrame
Instance.new("UICorner", innerFrame).CornerRadius = UDim.new(0, outerCornerRadius - borderThickness)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, -20, 0, 30)
header.Position = UDim2.new(0, 10, 0, 5)
header.BackgroundTransparency = 1
header.Parent = innerFrame

local userL = Instance.new("TextLabel", header)
userL.Size = UDim2.new(0.3, 0, 1, 0)
userL.Text = "User: "..MASKED_USERNAME
userL.TextColor3 = Color3.new(0.9, 0.9, 0.9)
userL.Font = Enum.Font.SourceSansBold
userL.TextSize = FONT_SIZE
userL.BackgroundTransparency = 1
userL.TextXAlignment = "Left"

local mapL = Instance.new("TextLabel", header)
mapL.Size = UDim2.new(0.4, 0, 1, 0)
mapL.Position = UDim2.new(0.3, 0, 0, 0)
mapL.Text = GameName
mapL.TextColor3 = Color3.new(1, 1, 1)
mapL.Font = Enum.Font.SourceSansBold
mapL.TextSize = FONT_SIZE
mapL.BackgroundTransparency = 1

local fpsL = Instance.new("TextLabel", header)
fpsL.Size = UDim2.new(0.3, 0, 1, 0)
fpsL.Position = UDim2.new(0.7, 0, 0, 0)
fpsL.Text = "FPS: 60"
fpsL.TextColor3 = Color3.fromRGB(0, 255, 150)
fpsL.Font = Enum.Font.SourceSansBold
fpsL.TextSize = FONT_SIZE
fpsL.BackgroundTransparency = 1
fpsL.TextXAlignment = "Right"

local scroll = Instance.new("ScrollingFrame", innerFrame)
scroll.Size = UDim2.new(1, -20, 1, -45)
scroll.Position = UDim2.new(0, 10, 0, 35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local noteBox = Instance.new("TextBox", scroll)
noteBox.Size = UDim2.new(1, 0, 1, 0)
noteBox.Text = readConfig(CONFIG_FILE_NAME)
noteBox.PlaceholderText = "Ghi chú tại đây..."
noteBox.TextColor3 = Color3.new(1, 1, 1)
noteBox.TextSize = NOTE_FONT_SIZE
noteBox.Font = Enum.Font.SourceSans
noteBox.MultiLine = true
noteBox.TextWrapped = true
noteBox.BackgroundTransparency = 1
noteBox.TextYAlignment = "Top"
noteBox.TextXAlignment = "Left"

-- Cập nhật Canvas tự động
local function updateScroll()
    local size = TextService:GetTextSize(noteBox.Text, NOTE_FONT_SIZE, noteBox.Font, Vector2.new(scroll.AbsoluteSize.X, 10000))
    scroll.CanvasSize = UDim2.new(0, 0, 0, size.Y + 20)
end
noteBox:GetPropertyChangedSignal("Text"):Connect(updateScroll)
noteBox.FocusLost:Connect(function() saveConfig(CONFIG_FILE_NAME, noteBox.Text) end)

-- ==================================================================
-- SIDE MENU
-- ==================================================================
local toggleSide = Instance.new("TextButton", outerFrame)
toggleSide.Size = UDim2.new(0, 25, 0, 60)
toggleSide.Position = UDim2.new(1, 0, 0.5, -30)
toggleSide.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleSide.Text = ">"
toggleSide.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleSide)

local sideFrame = Instance.new("Frame", outerFrame)
sideFrame.Size = UDim2.new(1, 0, 0.9, 0)
sideFrame.Position = UDim2.new(1, 10, 0.05, 0)
sideFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
sideFrame.BackgroundTransparency = 0.4
sideFrame.Visible = false
Instance.new("UICorner", sideFrame)

local layout = Instance.new("UIListLayout", sideFrame)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = "Center"
Instance.new("UIPadding", sideFrame).PaddingTop = UDim.new(0, 10)

local jobInput = Instance.new("TextBox", sideFrame)
jobInput.Size = UDim2.new(0.9, 0, 0, 30)
jobInput.PlaceholderText = "Job-ID..."
jobInput.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
jobInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", jobInput)

local function btn(txt, color)
    local b = Instance.new("TextButton", sideFrame)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    return b
end

local joinB = btn("Join Job-ID", Color3.fromRGB(50, 100, 200))
local clipB = btn("Clipboard Join", Color3.fromRGB(50, 150, 100))
local spamB = btn("Spam Join: No", Color3.fromRGB(150, 50, 50))

local spamActive = false
toggleSide.MouseButton1Click:Connect(function()
    sideFrame.Visible = not sideFrame.Visible
    toggleSide.Text = sideFrame.Visible and "<" or ">"
end)

local function doJoin(id)
    if id and id ~= "" then
        SendNotification("Teleport", "Đang kết nối: "..id, 2)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, localPlayer)
    end
end

joinB.MouseButton1Click:Connect(function() doJoin(jobInput.Text) end)
clipB.MouseButton1Click:Connect(function() 
    local s, text = pcall(function() return getclipboard() end)
    if s then jobInput.Text = text; doJoin(text) end
end)
spamB.MouseButton1Click:Connect(function()
    spamActive = not spamActive
    spamB.Text = "Spam Join: "..(spamActive and "Yes" or "No")
    spamB.BackgroundColor3 = spamActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

task.spawn(function()
    while task.wait(3) do
        if spamActive and jobInput.Text ~= "" then doJoin(jobInput.Text) end
    end
end)

-- Vòng lặp hiệu ứng
task.spawn(function()
    local h = 0
    RunService.RenderStepped:Connect(function(dt)
        h = (h + 0.01) % 1
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 0.8, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((h+0.5)%1, 0.8, 1))
        })
        fpsL.Text = "FPS: "..math.floor(1/dt)
        if mapL.Text ~= GameName then mapL.Text = GameName end
    end)
end)

print("Unfes Script: Hoàn tất!")
SendNotification("Thành công", "Script đã sẵn sàng!", 3)
