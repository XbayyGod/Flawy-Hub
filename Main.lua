local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local targetBase = (gethui and gethui()) or CoreGui

local function GetExternal(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then return result else warn("Not Found: "..url) return nil end
end

-- [[ DESIGNER PALETTE ]]
local Canvas = {
    Bg = Color3.fromRGB(11, 11, 13),
    Sidebar = Color3.fromRGB(8, 8, 9),
    Header = Color3.fromRGB(18, 18, 20),
    Border = Color3.fromRGB(35, 35, 40),
    ForgeGlow = Color3.fromRGB(0, 200, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 160)
}

-- [[ CONFIG & STATE ]]
local LogoID = "82178976184360" 
local UI_Visible = true
local IsMaximized = false

-- [[ UI ENGINE ]]
local ScreenGui = Instance.new("ScreenGui", targetBase)
ScreenGui.Name = "Flawy_TheForge_V1.1_Stable"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local NoSelection = Instance.new("Frame", ScreenGui)
NoSelection.Size = UDim2.new(0,0,0,0)
NoSelection.BackgroundTransparency = 1
NoSelection.Visible = false

-- [[ MAIN WINDOW ]]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(600, 380)
Main.Position = UDim2.new(0.5, -300, 0.5, -190)
Main.BackgroundColor3 = Canvas.Bg
Main.BorderSizePixel = 0
Main.Visible = UI_Visible
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1
MainStroke.Color = Canvas.Border

-- [[ HEADER SECTION ]]
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Canvas.Header
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Text = "FLAWY HUB <font color='#454545'>|</font> THE FORGE"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Canvas.TextMain
Title.TextSize = 18 
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(0, 400, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.RichText = true

-- [[ WINDOW CONTROLS ]]
local Controls = Instance.new("Frame", Header)
Controls.Size = UDim2.new(0, 110, 1, 0)
Controls.Position = UDim2.new(1, -125, 0, 0)
Controls.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", Controls)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.Padding = UDim.new(0, 15)
UIList.VerticalAlignment = Enum.VerticalAlignment.Center
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function CreateDot(color, callback)
    local dot = Instance.new("Frame", Controls)
    dot.Size = UDim2.fromOffset(13, 13) 
    dot.BackgroundColor3 = color
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", dot)
    btn.Size = UDim2.new(1, 12, 1, 12)
    btn.Position = UDim2.new(0, -6, 0, -6)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.SelectionImageObject = NoSelection 
    btn.MouseButton1Click:Connect(callback)
end

CreateDot(Color3.fromRGB(39, 201, 63), function() UI_Visible = false Main.Visible = false end)
CreateDot(Color3.fromRGB(255, 189, 46), function() 
    IsMaximized = not IsMaximized
    local targetSize = IsMaximized and UDim2.fromOffset(800, 480) or UDim2.fromOffset(600, 380)
    local targetPos = IsMaximized and UDim2.new(0.5, -400, 0.5, -240) or UDim2.new(0.5, -300, 0.5, -190)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize, Position = targetPos}):Play()
end)
CreateDot(Color3.fromRGB(255, 95, 87), function() ScreenGui:Destroy() end)

-- [[ SIDEBAR ]]
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 170, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Canvas.Sidebar
Sidebar.BorderSizePixel = 0
local NavList = Instance.new("UIListLayout", Sidebar)
NavList.Padding = UDim.new(0, 6)
local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 20)
SidePad.PaddingLeft = UDim.new(0, 15)
SidePad.PaddingRight = UDim.new(0, 15)

-- [[ CONTAINER ]]
local Container = Instance.new("Frame", Main)
Container.Name = "PageContainer"
Container.Size = UDim2.new(1, -170, 1, -42)
Container.Position = UDim2.new(0, 170, 0, 42)
Container.BackgroundTransparency = 1

-- [[ FIXED STABLE DRAG LOGIC (No Jump, No Disappear) ]]
local function makeDraggable(obj, target, isToggle)
    local dragging, dragStart, startPos, dragMoved

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragMoved = false
            dragStart = input.Position
            startPos = target.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                    if isToggle and not dragMoved then
                        UI_Visible = not UI_Visible
                        Main.Visible = UI_Visible
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                dragMoved = true
            end
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ FLOATING TOGGLE ]]
local Toggle = Instance.new("Frame", ScreenGui)
Toggle.Size = UDim2.fromOffset(55, 55)
Toggle.Position = UDim2.new(0, 30, 0.5, -27)
Toggle.BackgroundColor3 = Canvas.Bg
Toggle.ZIndex = 10
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", Toggle)
TStroke.Color = Canvas.Border
TStroke.Thickness = 1.5
local TBtn = Instance.new("ImageButton", Toggle)
TBtn.Size = UDim2.new(1, 0, 1, 0)
TBtn.BackgroundTransparency = 1 
TBtn.Image = "rbxassetid://" .. LogoID
TBtn.ScaleType = Enum.ScaleType.Fit
TBtn.ZIndex = 12
TBtn.SelectionImageObject = NoSelection 
Instance.new("UICorner", TBtn).CornerRadius = UDim.new(1, 0) 

makeDraggable(Header, Main, false)
makeDraggable(TBtn, Toggle, true)

-- [[ TAB SYSTEM WITH SMOOTH TRANSITION ]]
local function AddTab(name)
    local TabPage = Instance.new("CanvasGroup", Container)
    TabPage.Name = name .. "_Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.GroupTransparency = 1

    local btn = Instance.new("TextButton", Sidebar)
    btn.Name = name .. "_Tab"
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Canvas.TextMuted
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Center 
    btn.AutoButtonColor = false
    btn.SelectionImageObject = NoSelection 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local function CreateIndicator(pos, nameTag)
        local ind = Instance.new("Frame", btn)
        ind.Name = nameTag
        ind.Size = UDim2.new(0, 3, 0, 0)
        ind.Position = pos
        ind.AnchorPoint = Vector2.new(0.5, 0.5)
        ind.BackgroundColor3 = Canvas.ForgeGlow
        ind.BorderSizePixel = 0
        ind.Visible = false 
        Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
        return ind
    end

    local IndicatorL = CreateIndicator(UDim2.new(0, -10, 0.5, 0), "IndicatorL")
    local IndicatorR = CreateIndicator(UDim2.new(1, 10, 0.5, 0), "IndicatorR")

    local function Switch()
        for _, otherTab in pairs(Sidebar:GetChildren()) do
            if otherTab:IsA("TextButton") then
                TweenService:Create(otherTab, TweenInfo.new(0.3), {TextColor3 = Canvas.TextMuted, BackgroundTransparency = 1}):Play()
                if otherTab:FindFirstChild("IndicatorL") then
                    otherTab.IndicatorL.Visible = false
                    otherTab.IndicatorR.Visible = false
                end
            end
        end

        for _, otherPage in pairs(Container:GetChildren()) do
            if otherPage:IsA("CanvasGroup") and otherPage.Visible then
                TweenService:Create(otherPage, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
                task.delay(0.2, function() otherPage.Visible = false end)
            end
        end

        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Canvas.TextMain, BackgroundTransparency = 0.95}):Play()
        IndicatorL.Visible = true
        IndicatorR.Visible = true
        TweenService:Create(IndicatorL, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 18)}):Play()
        TweenService:Create(IndicatorR, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 18)}):Play()
        
        TabPage.Visible = true
        TweenService:Create(TabPage, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
    end

    btn.MouseButton1Click:Connect(Switch)
    return TabPage
end

local DashPage = AddTab("DASHBOARD")
local AutoPage = AddTab("AUTOMATION")
local CombatPage = AddTab("COMBAT")
local VisualPage = AddTab("VISUALS")
local SettingPage = AddTab("SETTINGS")

-- [[ LOAD EXTERNAL CONTENT - GANTI URL RAW LU ]]
local DashScript = GetExternal("https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/Dashboard.lua")
if DashScript then DashScript:Load(DashPage, Canvas) end

local AutoScript = GetExternal("https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/Automation.lua")
if AutoScript then AutoScript:Load(AutoPage, Canvas) end

local CombatScript = GetExternal("https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/Combat.lua")
if CombatScript then CombatScript:Load(CombatPage, Canvas) end

-- [[ DEFAULT PAGE: DASHBOARD ]]
task.wait(0.2)
local dashBtn = Sidebar:FindFirstChild("DASHBOARD_Tab")
if dashBtn then
    dashBtn.TextColor3 = Canvas.TextMain
    dashBtn.BackgroundTransparency = 0.95
    dashBtn.IndicatorL.Visible = true; dashBtn.IndicatorR.Visible = true
    dashBtn.IndicatorL.Size = UDim2.new(0, 3, 0, 18); dashBtn.IndicatorR.Size = UDim2.new(0, 3, 0, 18)
    DashPage.Visible = true
    DashPage.GroupTransparency = 0
end

print("Flawy HUB | Forge 1.1 Fixed Stable Loaded.")