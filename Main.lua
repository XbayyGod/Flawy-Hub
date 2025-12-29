-- [[ FLAWY HUB | UI ENGINE LIBRARY V5.5 (MOBILE FIX) ]]
local Engine = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [[ CONFIGURATION ]]
Engine.Config = {
    Title = "FLAWY HUB <font color='#454545'>|</font> THE FORGE",
    Size = UDim2.fromOffset(600, 380), 
    CornerRadius = 12,
    LogoID = "82178976184360",
    ToggleKey = Enum.KeyCode.RightControl
}

Engine.Palette = {
    Bg = Color3.fromRGB(12, 12, 14), 
    Sidebar = Color3.fromRGB(9, 9, 11),
    Header = Color3.fromRGB(18, 18, 20),
    Border = Color3.fromRGB(30, 30, 35),
    ForgeGlow = Color3.fromRGB(0, 220, 255),
    TextMain = Color3.fromRGB(240, 240, 240),
    TextMuted = Color3.fromRGB(100, 100, 110),
    MacRed = Color3.fromRGB(255, 60, 60),
    MacYellow = Color3.fromRGB(255, 180, 60),
    MacGreen = Color3.fromRGB(60, 200, 100)
}

-- [[ INTERNAL STORAGE ]]
Engine.Gui = nil
Engine.MainFrame = nil
Engine.Container = nil
Engine.Sidebar = nil
Engine.SidebarContent = nil
Engine.ToggleBtn = nil
Engine.IsOpen = true
Engine.IsMaximized = false
Engine.DefaultSize = Engine.Config.Size
Engine.MaxSize = UDim2.fromOffset(800, 500)

-- [[ INIT ENGINE (AUTO UPDATE / ANTI-DUPLICATE) ]]
function Engine:Init()
    local targetBase = (gethui and gethui()) or CoreGui
    local UI_NAME = "Flawy_Engine_V3" -- Nama unik UI
    
    -- [[ 1. CLEANUP (HAPUS UI LAMA) ]]
    for _, child in pairs(targetBase:GetChildren()) do
        if child.Name == UI_NAME then
            child:Destroy()
        end
    end

    local lp = game:GetService("Players").LocalPlayer
    if lp and lp:FindFirstChild("PlayerGui") then
        for _, child in pairs(lp.PlayerGui:GetChildren()) do
            if child.Name == UI_NAME then
                child:Destroy()
            end
        end
    end

    -- [[ 2. SETUP UI BARU ]]
    self.Gui = Instance.new("ScreenGui", targetBase)
    self.Gui.Name = UI_NAME
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true 

    -- [[ 3. FLOATING BUTTON ]]
    self.ToggleBtn = Instance.new("ImageButton", self.Gui)
    self.ToggleBtn.Name = "ToggleUI"
    self.ToggleBtn.Size = UDim2.fromOffset(50, 50)
    self.ToggleBtn.Position = UDim2.new(0, 30, 0.5, -25)
    self.ToggleBtn.BackgroundColor3 = self.Palette.Header
    self.ToggleBtn.Image = "rbxassetid://" .. self.Config.LogoID
    self.ToggleBtn.Visible = true
    self.ToggleBtn.BorderSizePixel = 0
    Instance.new("UICorner", self.ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    -- [[ FIX: LOGIC DRAG TOMBOL (ANDROID SUPPORT) ]]
    local tDragging = false
    local tDragStart = nil
    local tStartPos = nil
    local isMoved = false 

    self.ToggleBtn.InputBegan:Connect(function(input)
        -- Tambah Touch untuk Android
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true
            tDragStart = input.Position
            tStartPos = self.ToggleBtn.Position
            isMoved = false 
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        -- Tambah Touch untuk Android
        if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tDragStart
            if delta.Magnitude > 5 then isMoved = true end
            self.ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        -- Tambah Touch untuk Android
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            tDragging = false 
        end
    end)
    
    self.ToggleBtn.MouseButton1Click:Connect(function()
        if not isMoved then
            if Engine.IsOpen then Engine:ToggleUI(false) else Engine:ToggleUI(true) end
        end
    end)

    -- [[ 4. MAIN FRAME ]]
    local Main = Instance.new("Frame", self.Gui)
    Main.Name = "MainFrame"
    Main.Size = self.Config.Size
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.BackgroundColor3 = self.Palette.Bg
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, self.Config.CornerRadius)
    self.MainFrame = Main
    
    local Shadow = Instance.new("UIStroke", Main)
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Thickness = 3
    Shadow.Transparency = 0.5

    -- [[ 5. HEADER ]]
    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = self.Palette.Header
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.Selectable = true
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, self.Config.CornerRadius)
    
    local HeaderFix = Instance.new("Frame", Header)
    HeaderFix.Size = UDim2.new(1, 0, 0, 10)
    HeaderFix.Position = UDim2.new(0, 0, 1, -10)
    HeaderFix.BackgroundColor3 = self.Palette.Header
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Text = self.Config.Title
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = self.Palette.TextMain
    Title.TextSize = 14
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.BackgroundTransparency = 1
    Title.RichText = true
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Controls (Min/Max/Close)
    local Controls = Instance.new("Frame", Header)
    Controls.Size = UDim2.new(0, 60, 1, 0)
    Controls.Position = UDim2.new(1, -70, 0, 0)
    Controls.BackgroundTransparency = 1
    
    local CLayout = Instance.new("UIListLayout", Controls)
    CLayout.FillDirection = Enum.FillDirection.Horizontal
    CLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    CLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    CLayout.Padding = UDim.new(0, 8)

    local function CreateDot(color, callback)
        local dot = Instance.new("TextButton", Controls)
        dot.Text = ""
        dot.Size = UDim2.fromOffset(12, 12)
        dot.BackgroundColor3 = color
        dot.AutoButtonColor = false
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        if callback then
            dot.MouseButton1Click:Connect(callback)
            dot.MouseEnter:Connect(function() dot.BackgroundTransparency = 0.2 end)
            dot.MouseLeave:Connect(function() dot.BackgroundTransparency = 0 end)
        end
    end

    local isMaximized = false
    local AnimInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    CreateDot(self.Palette.MacGreen, function() self:ToggleUI(false) end)
    CreateDot(self.Palette.MacYellow, function()
        if isMaximized then
            TweenService:Create(Main, AnimInfo, {Size = self.Config.Size}):Play()
        else
            TweenService:Create(Main, AnimInfo, {Size = self.MaxSize}):Play()
        end
        isMaximized = not isMaximized
    end)
    CreateDot(self.Palette.MacRed, function() self.Gui:Destroy() end)

    -- [[ 6. SIDEBAR ]]
    self.Sidebar = Instance.new("Frame", Main)
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 160, 1, -42) 
    self.Sidebar.Position = UDim2.new(0, 0, 0, 42)
    self.Sidebar.BackgroundColor3 = self.Palette.Sidebar
    self.Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, self.Config.CornerRadius)

    -- Cosmetic Corner
    local SideFix = Instance.new("Frame", self.Sidebar)
    SideFix.Name = "CornerFix_TopRight"
    SideFix.Size = UDim2.new(0, 20, 0, 20) 
    SideFix.Position = UDim2.new(1, -20, 0, 0)
    SideFix.BackgroundColor3 = self.Palette.Sidebar
    SideFix.BorderSizePixel = 0

    local SideFixBottom = Instance.new("Frame", self.Sidebar)
    SideFixBottom.Name = "CornerFix_BotRight"
    SideFixBottom.Size = UDim2.new(0, 20, 0, 20)
    SideFixBottom.Position = UDim2.new(1, -20, 1, -20)
    SideFixBottom.BackgroundColor3 = self.Palette.Sidebar
    SideFixBottom.BorderSizePixel = 0

    -- Sidebar Content
    self.SidebarContent = Instance.new("Frame", self.Sidebar)
    self.SidebarContent.Name = "Content"
    self.SidebarContent.Size = UDim2.new(1, 0, 1, 0)
    self.SidebarContent.BackgroundTransparency = 1
    self.SidebarContent.ZIndex = 2 

    local NavList = Instance.new("UIListLayout", self.SidebarContent)
    NavList.Padding = UDim.new(0, 4) 
    NavList.SortOrder = Enum.SortOrder.LayoutOrder
    NavList.VerticalAlignment = Enum.VerticalAlignment.Top
    NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local NavPad = Instance.new("UIPadding", self.SidebarContent)
    NavPad.PaddingTop = UDim.new(0, 10) 

    local Sep = Instance.new("Frame", Main)
    Sep.ZIndex = 5
    Sep.Size = UDim2.new(0, 1, 1, -42)
    Sep.Position = UDim2.new(0, 160, 0, 42)
    Sep.BackgroundColor3 = self.Palette.Border
    Sep.BorderSizePixel = 0

    -- [[ 7. CONTAINER ]]
    self.Container = Instance.new("Frame", Main)
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(1, -161, 1, -42)
    self.Container.Position = UDim2.new(0, 161, 0, 42)
    self.Container.BackgroundTransparency = 1
    self.Container.ClipsDescendants = true
    
    local ContainerPad = Instance.new("UIPadding", self.Container)
    ContainerPad.PaddingTop = UDim.new(0, 10)
    ContainerPad.PaddingBottom = UDim.new(0, 10)
    ContainerPad.PaddingLeft = UDim.new(0, 10)
    ContainerPad.PaddingRight = UDim.new(0, 6)

    -- [[ FIX: DRAG LOGIC MAIN FRAME (ANDROID SUPPORT) ]]
    -- [[ FIX: SUPER SMOOTH DRAG + ANTI BLINK ]]
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local RunService = game:GetService("RunService")

    -- 1. Deteksi Sentuhan Awal
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            -- [[ FIX PENTING ]]
            -- Kita set dragInput jadi input yang SEKARANG.
            -- Biar dia gak pakai data input dari masa lalu (penyebab blink).
            dragInput = input 

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    -- 2. Update Input saat jari gerak
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- 3. Loop Halus (RenderStepped)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            
            -- Pastikan startPos ada isinya biar gak error
            if startPos then
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    -- [[ Keybind Toggle (Biarkan tetap ada di bawahnya) ]]
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Config.ToggleKey then
            if self.IsOpen then self:ToggleUI(false) else self:ToggleUI(true) end
        end
    end)
end

function Engine:ToggleUI(state)
    if state then
        if self.IsOpen then return end
        self.IsOpen = true
        self.MainFrame.Visible = true
    else
        if not self.IsOpen then return end
        self.IsOpen = false
        self.MainFrame.Visible = false
    end
end

function Engine:AddTab(name, icon, order)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0) 
    Page.BackgroundTransparency = 1
    Page.Visible = false
    
    -- Scrollbar Style
    Page.ScrollBarThickness = 4 
    Page.ScrollBarImageTransparency = 0
    Page.ScrollBarImageColor3 = self.Palette.ForgeGlow 
    Page.AutomaticCanvasSize = Enum.AutomaticSize.None 
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 12)
    
    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop = UDim.new(0, 5)
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.PaddingRight = UDim.new(0, 15)
    Pad.PaddingBottom = UDim.new(0, 20)
    
    local function UpdateCanvas()
        local contentHeight = Layout.AbsoluteContentSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 50)
    end
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
    task.delay(0.1, UpdateCanvas)

    -- [[ BAGIAN TOMBOL SIDEBAR (CARD STYLE) ]]
    local btnContainer = Instance.new("Frame", self.SidebarContent)
    btnContainer.Name = name .. "_Btn"
    btnContainer.LayoutOrder = order or 99
    btnContainer.Size = UDim2.new(1, -24, 0, 34) 
    btnContainer.AnchorPoint = Vector2.new(0.5, 0)
    btnContainer.Position = UDim2.new(0.5, 0, 0, 0)
    btnContainer.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", btnContainer)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = self.Palette.Bg 
    
    -- Default non-aktif (samar)
    btn.BackgroundTransparency = 0.9 
    
    btn.Text = name
    btn.Font = Enum.Font.GothamBold 
    btn.TextColor3 = self.Palette.TextMuted
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left 
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local btnPad = Instance.new("UIPadding", btn)
    btnPad.PaddingLeft = UDim.new(0, 12) 
    
    -- Indikator (Garis kecil di kiri)
    local indicator = Instance.new("Frame", btnContainer)
    indicator.Name = "TabIndicator"
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.Position = UDim2.new(0, -6, 0.5, 0) 
    
    -- [UBAHAN 1] Warna Indikator BALIK KE CYAN (ForgeGlow)
    indicator.BackgroundColor3 = self.Palette.ForgeGlow 
    
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1 
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Name = "TabStroke"
    btnStroke.Color = self.Palette.Border
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7 

    -- [HOVER EFFECT]
    btn.MouseEnter:Connect(function()
        if btn.TextColor3 == self.Palette.TextMuted then 
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
            -- Stroke hover sedikit lebih jelas tapi tetap warna border
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if btn.TextColor3 == self.Palette.TextMuted then 
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
        end
    end)

    -- [CLICK EFFECT]
    btn.MouseButton1Click:Connect(function()
        -- 1. Reset Semua Tab Lain
        for _, b in pairs(self.SidebarContent:GetChildren()) do 
            if b:IsA("Frame") and b:FindFirstChild("TextButton") then
                local tBtn = b:FindFirstChild("TextButton")
                local tInd = b:FindFirstChild("TabIndicator")
                local tStr = tBtn:FindFirstChild("TabStroke")
                if tBtn and tInd and tStr then
                    TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = self.Palette.TextMuted}):Play()
                    TweenService:Create(tInd, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(tStr, TweenInfo.new(0.2), {Transparency = 0.7, Color = self.Palette.Border}):Play()
                end
            end 
        end
        
        -- 2. Tampilkan Halaman
        for _, p in pairs(self.Container:GetChildren()) do 
            if p:IsA("ScrollingFrame") then p.Visible = false end 
        end
        
        Page.Visible = true
        UpdateCanvas() 
        
        -- 3. [UBAHAN 2] Efek Aktif: Clean Style
        -- Background agak terlihat, Teks Putih Terang
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = self.Palette.TextMain}):Play()
        
        -- Indikator Cyan Muncul
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        
        -- [NO GLOW] Stroke tetap warna border (gelap), tidak berubah putih/cyan
        -- Jadi tidak ada efek "menyala" di sekeliling tombol
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Transparency = 0.7, 
            Color = self.Palette.Border -- Tetap warna garis biasa
        }):Play()
    end)
    
    return Page
end

-- [[ COMPONENT: SLIDER (REAL-TIME INPUT) ]]
function Engine:CreateSlider(parent, text, min, max, default, order, callback)
    local frame = Instance.new("Frame", parent)
    frame.LayoutOrder = order or 0
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    
    -- 1. HEADER (Label)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Palette.TextMain
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- 2. INPUT BOX (Angka)
    local valueBox = Instance.new("TextBox", frame)
    valueBox.Name = "ValueInput"
    valueBox.Size = UDim2.new(0.3, 0, 0, 24) 
    valueBox.Position = UDim2.new(0.7, 0, 0, 2)
    valueBox.BackgroundTransparency = 1
    valueBox.BackgroundColor3 = self.Palette.Sidebar
    valueBox.Text = tostring(default)
    valueBox.TextColor3 = self.Palette.ForgeGlow
    valueBox.Font = Enum.Font.GothamBold
    valueBox.TextSize = 13
    valueBox.TextXAlignment = Enum.TextXAlignment.Right
    valueBox.ClearTextOnFocus = false
    valueBox.ZIndex = 10 
    
    -- 3. AREA SLIDER
    local trackArea = Instance.new("Frame", frame)
    trackArea.Size = UDim2.new(1, 0, 0, 30)
    trackArea.Position = UDim2.new(0, 0, 0, 30)
    trackArea.BackgroundTransparency = 1
    
    local track = Instance.new("Frame", trackArea)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0.5, -2)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Palette.ForgeGlow
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = self.Palette.Bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = self.Palette.ForgeGlow
    knobStroke.Thickness = 2
    
    -- Tombol Geser (Invisible)
    local btn = Instance.new("TextButton", trackArea)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5 
    
    local function UpdateVisualsOnly(val)
        local clampedValue = math.clamp(val, min, max)
        local percent = (clampedValue - min) / (max - min)
        
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
        
        callback(clampedValue)
    end

    valueBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = valueBox.Text
        if txt == "" then
            UpdateVisualsOnly(min)
            return
        end
        if txt == "-" then return end
        local num = tonumber(txt)
        if num then
            UpdateVisualsOnly(num)
        end
    end)

    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if not num then
            local currentPercent = fill.Size.X.Scale
            local val = math.floor(min + (max - min) * currentPercent)
            valueBox.Text = tostring(val)
        else
            local clamped = math.clamp(num, min, max)
            valueBox.Text = tostring(clamped)
            UpdateVisualsOnly(clamped)
        end
    end)

    -- [[ FIX: SLIDER DRAG (ANDROID) ]]
    local dragging = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local barPos = track.AbsolutePosition.X
            local barSize = track.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            
            valueBox.Text = tostring(val)
            
            TweenService:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.05), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
            
            callback(val)
        end
    end)
end

-- [[ COMPONENT: SECTION (ROUNDED ACCENT & THICKER LINE) ]]
function Engine:CreateSection(parent, text, order)
    local frame = Instance.new("Frame", parent)
    frame.LayoutOrder = order or 0
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true

    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    local accent = Instance.new("Frame", frame)
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 0, 14) 
    accent.BackgroundColor3 = self.Palette.ForgeGlow
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4) 

    local label = Instance.new("TextLabel", frame)
    label.Name = "Title"
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = self.Palette.TextMuted
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local divider = Instance.new("Frame", frame)
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 2)
    divider.BackgroundColor3 = self.Palette.Border
    divider.BorderSizePixel = 0
    
    local gradient = Instance.new("UIGradient", divider)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })

    return label
end

function Engine:CreateSpacer(parent, height, order)
    local f = Instance.new("Frame", parent)
    f.LayoutOrder = order or 0
    f.Size = UDim2.new(1, 0, 0, height)
    f.BackgroundTransparency = 1
    return f
end

-- [[ COMPONENT: MODERN TOGGLE (SWITCH STYLE) ]]
function Engine:CreateToggle(parent, text, order, callback)
    local btn = Instance.new("TextButton", parent)
    btn.LayoutOrder = order or 0
    btn.Size = UDim2.new(1, 0, 0, 40) -- Tinggi tombol
    btn.BackgroundTransparency = 1
    btn.Text = "" 
    btn.AutoButtonColor = false

    -- 1. Label Teks (Kiri)
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Palette.TextMuted -- Warna default (Mati)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- 2. Wadah Switch (Kapsul Kanan)
    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.fromOffset(44, 22) -- Ukuran kapsul
    switchBg.AnchorPoint = Vector2.new(1, 0.5)
    switchBg.Position = UDim2.new(1, -10, 0.5, 0) -- Rata kanan
    switchBg.BackgroundColor3 = self.Palette.Bg -- Warna dalam kapsul
    switchBg.BorderSizePixel = 0
    
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0) 
    
    local switchStroke = Instance.new("UIStroke", switchBg)
    switchStroke.Color = self.Palette.Border
    switchStroke.Thickness = 1.5

    -- 3. Knob (Lingkaran di dalam)
    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 3, 0.5, 0) -- Posisi awal (Kiri/OFF)
    knob.BackgroundColor3 = self.Palette.TextMuted
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0) 

    -- Logic Animasi
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if active then
            TweenService:Create(label, tweenInfo, {TextColor3 = self.Palette.TextMain}):Play()
            TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = self.Palette.ForgeGlow}):Play()
            TweenService:Create(switchStroke, tweenInfo, {Color = self.Palette.ForgeGlow}):Play()
            TweenService:Create(knob, tweenInfo, {
                Position = UDim2.new(1, -19, 0.5, 0), -- Geser kanan
                BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
            }):Play()
        else
            TweenService:Create(label, tweenInfo, {TextColor3 = self.Palette.TextMuted}):Play()
            TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = self.Palette.Bg}):Play()
            TweenService:Create(switchStroke, tweenInfo, {Color = self.Palette.Border}):Play()
            TweenService:Create(knob, tweenInfo, {
                Position = UDim2.new(0, 3, 0.5, 0), -- Geser kiri
                BackgroundColor3 = self.Palette.TextMuted
            }):Play()
        end
        
        if callback then callback(active) end
    end)
    
    return btn
end

-- [[ COMPONENT: DROPDOWN V7 (MULTI-SELECT SUPPORT + POS FIX) ]]
function Engine:CreateDropdown(parent, title, values, order, multi, callback)
    local RunService = game:GetService("RunService")
    
    if type(multi) == "function" then
        callback = multi
        multi = false
    end

    -- 1. Header (Wadah Statis)
    local frame = Instance.new("Frame", parent)
    frame.LayoutOrder = order or 0
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    
    -- Label Judul
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = self.Palette.TextMain
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Trigger
    local dropBtn = Instance.new("TextButton", frame)
    dropBtn.Size = UDim2.new(0, 140, 0, 30)
    dropBtn.Position = UDim2.new(1, -5, 0.5, 0) 
    dropBtn.AnchorPoint = Vector2.new(1, 0.5) 
    dropBtn.BackgroundColor3 = self.Palette.Sidebar 
    dropBtn.Text = ""
    dropBtn.AutoButtonColor = false
    
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
    local btnStroke = Instance.new("UIStroke", dropBtn)
    btnStroke.Color = self.Palette.Border
    btnStroke.Thickness = 1

    -- Teks Pilihan
    local currentText = Instance.new("TextLabel", dropBtn)
    currentText.Size = UDim2.new(1, -30, 1, 0)
    currentText.Position = UDim2.new(0, 10, 0, 0)
    currentText.BackgroundTransparency = 1
    
    if multi then
        currentText.Text = "Select..." 
    else
        currentText.Text = values[1] or "Select..." 
    end
    
    currentText.TextColor3 = self.Palette.TextMuted
    currentText.Font = Enum.Font.GothamMedium
    currentText.TextSize = 12
    currentText.TextXAlignment = Enum.TextXAlignment.Left
    currentText.TextTruncate = Enum.TextTruncate.AtEnd

    -- Icon Panah
    local icon = Instance.new("ImageLabel", dropBtn)
    icon.Size = UDim2.fromOffset(14, 14)
    icon.Position = UDim2.new(1, -20, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://6034818372"
    icon.ImageColor3 = self.Palette.TextMuted

    -- [[ LOGIC FLOATING & SELECTION ]]
    local isOpen = false
    local FloatingList = nil
    local RenderConnection = nil 
    local CloseEvent = nil
    local multiSelected = {} 

    local function CloseDropdown()
        isOpen = false
        if FloatingList then FloatingList:Destroy() FloatingList = nil end
        if RenderConnection then RenderConnection:Disconnect() RenderConnection = nil end
        if CloseEvent then CloseEvent:Disconnect() CloseEvent = nil end
        
        TweenService:Create(icon, TweenInfo.new(0.2), {Rotation = 0}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = self.Palette.Border}):Play()
    end

    local function OpenDropdown()
        if isOpen then CloseDropdown() return end
        isOpen = true
        
        TweenService:Create(icon, TweenInfo.new(0.2), {Rotation = 180}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = self.Palette.ForgeGlow}):Play()

        -- Buat Frame Ngambang
        FloatingList = Instance.new("ScrollingFrame", self.Gui)
        FloatingList.Name = "FloatingDropdown"
        FloatingList.ZIndex = 10000 
        FloatingList.BackgroundColor3 = self.Palette.Sidebar 
        FloatingList.BorderColor3 = self.Palette.ForgeGlow
        FloatingList.BorderSizePixel = 0 
        
        -- Style Scrollbar
        FloatingList.ScrollBarThickness = 2
        FloatingList.ScrollBarImageColor3 = self.Palette.ForgeGlow
        FloatingList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        FloatingList.CanvasSize = UDim2.new(0,0,0,0)
        FloatingList.ClipsDescendants = true
        
        -- Stroke & Corner
        Instance.new("UICorner", FloatingList).CornerRadius = UDim.new(0, 6)
        local fStroke = Instance.new("UIStroke", FloatingList)
        fStroke.Color = self.Palette.Border
        fStroke.Thickness = 1
        
        local listLayout = Instance.new("UIListLayout", FloatingList)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        local listPad = Instance.new("UIPadding", FloatingList)
        listPad.PaddingTop = UDim.new(0, 5)
        listPad.PaddingLeft = UDim.new(0, 5)
        listPad.PaddingRight = UDim.new(0, 5)
        listPad.PaddingBottom = UDim.new(0, 5)

        -- Isi Item
        for i, val in ipairs(values) do
            local item = Instance.new("TextButton", FloatingList)
            item.LayoutOrder = i
            item.Size = UDim2.new(1, 0, 0, 28)
            item.BackgroundColor3 = self.Palette.Bg 
            item.BackgroundTransparency = 0.5
            item.Text = "  " .. val
            item.TextColor3 = self.Palette.TextMuted
            item.Font = Enum.Font.Gotham
            item.TextSize = 12
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.ZIndex = 10001 
            item.AutoButtonColor = false
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)

            if multi and table.find(multiSelected, val) then
                item.TextColor3 = self.Palette.TextMain
                item.BackgroundTransparency = 0
            end

            item.MouseEnter:Connect(function()
                if not multi or not table.find(multiSelected, val) then
                    TweenService:Create(item, TweenInfo.new(0.2), {TextColor3 = self.Palette.TextMain, BackgroundTransparency = 0}):Play()
                end
            end)
            item.MouseLeave:Connect(function()
                if not multi or not table.find(multiSelected, val) then
                    TweenService:Create(item, TweenInfo.new(0.2), {TextColor3 = self.Palette.TextMuted, BackgroundTransparency = 0.5}):Play()
                end
            end)

            item.MouseButton1Click:Connect(function()
                if multi then
                    local foundIdx = table.find(multiSelected, val)
                    if foundIdx then
                        table.remove(multiSelected, foundIdx)
                        TweenService:Create(item, TweenInfo.new(0.2), {TextColor3 = self.Palette.TextMuted, BackgroundTransparency = 0.5}):Play()
                    else
                        table.insert(multiSelected, val)
                        TweenService:Create(item, TweenInfo.new(0.2), {TextColor3 = self.Palette.TextMain, BackgroundTransparency = 0}):Play()
                    end

                    if #multiSelected == 0 then
                        currentText.Text = "Select..."
                        currentText.TextColor3 = self.Palette.TextMuted
                    else
                        currentText.Text = table.concat(multiSelected, ", ")
                        currentText.TextColor3 = self.Palette.TextMain
                    end
                    
                    callback(multiSelected)
                else
                    currentText.Text = val
                    currentText.TextColor3 = self.Palette.TextMain
                    callback(val)
                    CloseDropdown()
                end
            end)
        end

        local function UpdatePosition()
            if not dropBtn or not dropBtn.Parent then CloseDropdown() return end
            if not FloatingList or not FloatingList.Parent then return end 
            
            local btnAbsPos = dropBtn.AbsolutePosition
            local btnSize = dropBtn.AbsoluteSize
            local parentAbsPos = FloatingList.Parent.AbsolutePosition
            
            FloatingList.AnchorPoint = Vector2.new(0, 0)
            
            local finalX = btnAbsPos.X - parentAbsPos.X
            local finalY = (btnAbsPos.Y - parentAbsPos.Y) + btnSize.Y + 2
            
            FloatingList.Position = UDim2.fromOffset(finalX, finalY)
            
            local totalHeight = math.min((#values * 30) + 15, 200)
            FloatingList.Size = UDim2.fromOffset(btnSize.X, totalHeight)
        end

        RenderConnection = RunService.RenderStepped:Connect(UpdatePosition)
        UpdatePosition() 

        CloseEvent = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not FloatingList then return end
                
                local mPos = input.Position
                local fPos = FloatingList.AbsolutePosition
                local fSize = FloatingList.AbsoluteSize
                local bPos = dropBtn.AbsolutePosition
                local bSize = dropBtn.AbsoluteSize

                local inList = (mPos.X >= fPos.X and mPos.X <= fPos.X + fSize.X and mPos.Y >= fPos.Y and mPos.Y <= fPos.Y + fSize.Y)
                local inBtn = (mPos.X >= bPos.X and mPos.X <= bPos.X + bSize.X and mPos.Y >= bPos.Y and mPos.Y <= bPos.Y + bSize.Y)

                if not inList and not inBtn then
                    CloseDropdown()
                end
            end
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then CloseDropdown() else OpenDropdown() end
    end)
    
    frame.AncestryChanged:Connect(function()
        if not frame.Parent then CloseDropdown() end
    end)

    return {Frame = frame, Button = dropBtn}
end

-- [[ COMPONENT: DROPDOWN STATIS (INLINE / NON-FLOATING) ]]
function Engine:CreateStaticDropdown(parent, title, values, order, multi, callback)
    local frame = Instance.new("Frame", parent)
    frame.LayoutOrder = order or 0
    frame.Name = title .. "_StaticDrop"
    frame.Size = UDim2.new(1, 0, 0, 40) -- Tinggi awal (tertutup)
    frame.BackgroundColor3 = self.Palette.Sidebar
    frame.BackgroundTransparency = 0.5
    frame.ClipsDescendants = true -- Biar listnya sembunyi pas tertutup
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = self.Palette.Border
    stroke.Transparency = 0.5

    -- Header Button (Bagian yang diklik)
    local header = Instance.new("TextButton", frame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = ""
    
    local label = Instance.new("TextLabel", header)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = title
    label.TextColor3 = self.Palette.TextMain
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local indicator = Instance.new("TextLabel", header)
    indicator.Size = UDim2.new(0, 40, 1, 0)
    indicator.Position = UDim2.new(1, -40, 0, 0)
    indicator.Text = "+" -- Simbol pas tertutup
    indicator.TextColor3 = self.Palette.TextMuted
    indicator.Font = Enum.Font.GothamMedium
    indicator.TextSize = 18
    indicator.BackgroundTransparency = 1

    -- Container List (Tempat item-itemnya)
    local listContainer = Instance.new("Frame", frame)
    listContainer.Position = UDim2.new(0, 5, 0, 40)
    listContainer.Size = UDim2.new(1, -10, 0, 0) -- Otomatis nanti
    listContainer.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", listContainer)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local multiSelected = {}
    local isOpened = false

    -- Fungsi Toggle Buka/Tutup
    local function Toggle()
        isOpened = not isOpened
        local targetSize = isOpened and UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 50) or UDim2.new(1, 0, 0, 40)
        
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        indicator.Text = isOpened and "-" or "+"
        indicator.TextColor3 = isOpened and self.Palette.ForgeGlow or self.Palette.TextMuted
    end

    header.MouseButton1Click:Connect(Toggle)

    -- Tambah Item
    for i, val in ipairs(values) do
        local btn = Instance.new("TextButton", listContainer)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = self.Palette.Bg
        btn.BackgroundTransparency = 0.8
        btn.Text = "  " .. val
        btn.TextColor3 = self.Palette.TextMuted
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            if multi then
                if table.find(multiSelected, val) then
                    table.remove(multiSelected, table.find(multiSelected, val))
                    btn.TextColor3 = self.Palette.TextMuted
                    btn.BackgroundColor3 = self.Palette.Bg
                else
                    table.insert(multiSelected, val)
                    btn.TextColor3 = self.Palette.TextMain
                    btn.BackgroundColor3 = self.Palette.ForgeGlow
                    btn.BackgroundTransparency = 0.6
                end
                callback(multiSelected)
            else
                callback(val)
                label.Text = title .. ": " .. val
                Toggle() -- Tutup kalau single select
            end
        end)
    end

    return frame
end

-- [[ LOADER ]]
function Engine:LoadFeature(fileName, url, targetPage)
    local moduleScript = nil
    local isDev = true 
    if isDev then
        local path = "Flawy/" .. fileName
        if isfile(path) then moduleScript = loadstring(readfile(path))() end
    else
        local s, r = pcall(function() return game:HttpGet(url) end)
        if s then moduleScript = loadstring(r)() end
    end
    if moduleScript and moduleScript.Load then
        moduleScript:Load(targetPage, self.Palette, self) 
        print("Loaded: " .. fileName)
    end
end

-- [[ EXECUTION ]]
Engine:Init()

local DashPage = Engine:AddTab("DASHBOARD", nil, 1)
local AutoPage = Engine:AddTab("AUTO FARM", nil, 2)
local EspPage = Engine:AddTab("ESP", nil, 3)

task.spawn(function()
    Engine:LoadFeature("Dashboard.lua", "https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/Dashboard.lua", DashPage)
    Engine:LoadFeature("AutoFarm.lua", "https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/AutoFarm.lua", AutoPage)
    Engine:LoadFeature("Esp.lua", "https://raw.githubusercontent.com/XbayyGod/Flawy-Hub/refs/heads/main/Esp.lua", EspPage)

    if Engine.SidebarContent:FindFirstChild("DASHBOARD_Btn") then 
        local btnCont = Engine.SidebarContent["DASHBOARD_Btn"]
        local btn = btnCont.TextButton
        local str = btn:FindFirstChild("TabStroke")
        local ind = btnCont:FindFirstChild("TabIndicator")
        
        DashPage.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextColor3 = Engine.Palette.TextMain}):Play()
        if ind then TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
        if str then TweenService:Create(str, TweenInfo.new(0.3), {Transparency = 0}):Play() end
    end
end)

return Engine