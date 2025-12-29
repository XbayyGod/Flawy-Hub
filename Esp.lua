local Esp = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- [[ 1. ULTRA PERFORMANCE CONFIG ]]
local RENDER_DISTANCE = 1500     -- Jarak maksimal teks muncul
local HIGHLIGHT_DISTANCE = 300   -- Highlight cuma nyala kalau dekat (Hemat GPU)
local MAX_HIGHLIGHTS = 15        -- [BARU] Maksimal jumlah highlight di layar (Biar ga kedip/lag)
local REFRESH_RATE = 0.1         -- Update rate UI

-- [TIPS] Kalau tau foldernya, ganti workspace jadi foldernya. Contoh: workspace.Mobs
-- Kalau nil, dia bakal scan satu map (Default)
local TARGET_SCAN_PARENT = workspace 

-- [[ 2. DATABASE ORE ]]
local RockConfig = {
    -- Es & Crystal
    ["Icy Pebble"] = {Color = Color3.fromRGB(0, 255, 255)},
    ["Icy Rock"] = {Color = Color3.fromRGB(0, 200, 255)},
    ["Icy Boulder"] = {Color = Color3.fromRGB(0, 150, 255)},
    ["Small Ice Crystal"] = {Color = Color3.fromRGB(150, 255, 255)},
    ["Medium Ice Crystal"] = {Color = Color3.fromRGB(100, 255, 255)},
    ["Floating Crystal"] = {Color = Color3.fromRGB(0, 255, 100)}, 
    ["Iceberg"] = {Color = Color3.fromRGB(0, 0, 255)},
    -- Api & Basalt
    ["Basalt Rock"] = {Color = Color3.fromRGB(255, 100, 0)},
    ["Basalt Core"] = {Color = Color3.fromRGB(255, 50, 0)},
    ["Basalt Vein"] = {Color = Color3.fromRGB(255, 0, 0)},
    ["Volcanic Rock"] = {Color = Color3.fromRGB(200, 0, 0)},
    -- Lainnya
    ["Earth Crystal"] = {Color = Color3.fromRGB(50, 255, 50)},
    ["Violet Crystal"] = {Color = Color3.fromRGB(170, 0, 255)},
    ["Pebble"] = {Color = Color3.fromRGB(200, 200, 200)},
    ["Rock"] = {Color = Color3.fromRGB(150, 150, 150)},
    ["Boulder"] = {Color = Color3.fromRGB(100, 100, 100)},
    ["Lucky Block"] = {Color = Color3.fromRGB(255, 215, 0)}, 
}

-- [[ 3. DATABASE ENEMY ]]
local EnemyConfig = {
    ["Zombie"] = Color3.fromRGB(100, 255, 100),
    ["Elite Zombie"] = Color3.fromRGB(0, 255, 0),
    ["Brute Zombie"] = Color3.fromRGB(30, 100, 30),
    ["Delver Zombie"] = Color3.fromRGB(0, 255, 255),
    ["Skeleton Rogue"] = Color3.fromRGB(220, 220, 220),
    ["Axe Skeleton"] = Color3.fromRGB(180, 180, 180),
    ["Deathaxe Skeleton"] = Color3.fromRGB(100, 100, 100),
    ["Elite Rogue Skeleton"] = Color3.fromRGB(200, 200, 255),
    ["Elite Deathaxe Skeleton"] = Color3.fromRGB(50, 50, 50),
    ["Slime"] = Color3.fromRGB(150, 255, 150),
    ["Blazing Slime"] = Color3.fromRGB(255, 120, 0),
    ["Bomber"] = Color3.fromRGB(255, 255, 0),
    ["Blight Pyromancer"] = Color3.fromRGB(255, 80, 0),
    ["Crystal Spider"] = Color3.fromRGB(170, 255, 255),
    ["Diamond Spider"] = Color3.fromRGB(0, 150, 255),
    ["Mini Demonic Spider"] = Color3.fromRGB(150, 0, 0),
    ["Demonic Spider"] = Color3.fromRGB(100, 0, 0),
    ["Demonic Queen Spider"] = Color3.fromRGB(255, 0, 100),
    ["Prismarine Spider"] = Color3.fromRGB(0, 255, 200),
    ["Common Orc"] = Color3.fromRGB(150, 100, 50),
    ["Elite Orc"] = Color3.fromRGB(100, 50, 0),
    ["Yeti"] = Color3.fromRGB(255, 255, 255),
    ["Reaper"] = Color3.fromRGB(255, 0, 0),
    ["Crystal Golem"] = Color3.fromRGB(170, 0, 255),
}

-- [[ 4. SYSTEM VARIABLES ]]
local EspState = {
    Enabled = false,      
    EnemyEnabled = false,  
    SelectedOres = {},
    SelectedEnemies = {},
    Cache = {}, 
    Connections = {},
    IsRunning = false
}

if CoreGui:FindFirstChild("FPerformance") then
    CoreGui.FPerformance:Destroy()
end
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "FPerformance"

-- [[ 5. HELPER FUNCTIONS ]]
local function GetCleanName(RawName)
    local cleaned = string.gsub(RawName, "%d+$", "") 
    cleaned = string.gsub(cleaned, "^%s*(.-)%s*$", "%1")
    return cleaned
end

local function GetHealth(Obj)
    local Attr = Obj:GetAttribute("Health") or Obj:GetAttribute("HP") or Obj:GetAttribute("Durability")
    if Attr then return Attr end

    local Val = Obj:FindFirstChild("Health", true) or Obj:FindFirstChild("HP", true) or Obj:FindFirstChild("Durability", true)
    if Val and Val:IsA("ValueBase") then return Val.Value end
    
    local Hum = Obj:FindFirstChildOfClass("Humanoid")
    if Hum then return Hum.Health end

    return nil 
end

-- [[ 6. CORE LOGIC ]]
local function RemoveEspObj(Obj)
    if EspState.Cache[Obj] then
        if EspState.Cache[Obj].Highlight then EspState.Cache[Obj].Highlight:Destroy() end
        if EspState.Cache[Obj].Billboard then EspState.Cache[Obj].Billboard:Destroy() end
        EspState.Cache[Obj] = nil
    end
end

local function AddEspObj(Obj)
    -- [OPTIMISASI 1] Filter Level 1 - Validasi Instance
    -- Kita cuma peduli Model (Monster/Ore biasanya Model) atau Part.
    if not Obj:IsA("Model") and not Obj:IsA("BasePart") then return end
    if EspState.Cache[Obj] then return end 

    -- [OPTIMISASI 2] Bersihin Nama sekali aja di awal
    local RawName = Obj.Name
    local CleanName = GetCleanName(RawName) 
    
    local IsTargetOre = false
    local IsTargetEnemy = false

    -- Cek Ore 
    if EspState.Enabled and table.find(EspState.SelectedOres, RawName) then
        IsTargetOre = true
    end

    -- Cek Enemy 
    if EspState.EnemyEnabled and table.find(EspState.SelectedEnemies, CleanName) then
        IsTargetEnemy = true
    end

    if not IsTargetOre and not IsTargetEnemy then return end

    -- [OPTIMISASI 3] Cek Darah
    local HP = GetHealth(Obj)
    if not HP then return end

    -- Warna
    local FinalColor = Color3.fromRGB(255, 255, 255)
    if IsTargetEnemy then
        FinalColor = EnemyConfig[CleanName] or Color3.fromRGB(255, 0, 0)
    elseif IsTargetOre then
        local ConfigData = RockConfig[RawName]
        if ConfigData then FinalColor = ConfigData.Color end
    end
    
    -- Setup Visual (Default OFF semua biar ringan)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "HL"
    Highlight.Adornee = Obj
    Highlight.FillColor = FinalColor
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.5 -- Kurangi outline biar FPS naik dikit
    Highlight.Enabled = false 
    Highlight.Parent = ESP_Folder

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "BG"
    Billboard.Adornee = Obj
    Billboard.Size = UDim2.new(0, 150, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false 
    Billboard.Parent = ESP_Folder
    
    local Label = Instance.new("TextLabel", Billboard)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = FinalColor
    Label.TextStrokeTransparency = 0
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10 -- Kecilin size (lebih ringan render font kecil)
    Label.Text = "" 

    EspState.Cache[Obj] = {
        Highlight = Highlight,
        Billboard = Billboard,
        Label = Label,
        HP = HP,
        Name = CleanName,
        Root = (Obj:IsA("Model") and Obj.PrimaryPart) or Obj
    }

    local RemovingConn
    RemovingConn = Obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            RemoveEspObj(Obj)
            RemovingConn:Disconnect()
        end
    end)
end

-- [[ 7. LOOP MANAGER (HEAVY OPTIMIZATION) ]]
local function StopESP()
    ESP_Folder:ClearAllChildren()
    EspState.Cache = {}
    for _, conn in pairs(EspState.Connections) do conn:Disconnect() end
    EspState.Connections = {}
    EspState.IsRunning = false
end

local function StartESP()
    if EspState.IsRunning then return end
    EspState.IsRunning = true

    -- Scan Awal
    for _, child in pairs(TARGET_SCAN_PARENT:GetDescendants()) do
        task.spawn(function() AddEspObj(child) end)
    end

    -- Listener Baru (Dioptimalkan)
    local AddedConn = TARGET_SCAN_PARENT.DescendantAdded:Connect(function(child)
        -- Cek Toggle dulu sebelum proses apapun
        if not (EspState.Enabled or EspState.EnemyEnabled) then return end
        
        -- Langsung filter kalau bukan Model/Part (Hemat CPU)
        if not child:IsA("Model") and not child:IsA("BasePart") then return end
        
        AddEspObj(child) 
    end)
    table.insert(EspState.Connections, AddedConn)

    -- Render Loop
    local Timer = 0
    local RenderConn = RunService.Heartbeat:Connect(function(deltaTime)
        Timer = Timer + deltaTime
        if Timer < REFRESH_RATE then return end 
        Timer = 0 

        local Player = Players.LocalPlayer
        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        
        if not Root then return end
        local MyPos = Root.Position

        -- Hitung jumlah highlight yang aktif frame ini
        local ActiveHighlights = 0

        for Obj, Data in pairs(EspState.Cache) do
            if Obj.Parent then
                local TargetPos = (Obj:IsA("Model") and Obj:GetPivot().Position) or Obj.Position
                local Dist = (MyPos - TargetPos).Magnitude

                if Dist > RENDER_DISTANCE then
                    -- Jauh -> Matikan Total
                    if Data.Billboard.Enabled then Data.Billboard.Enabled = false end
                    if Data.Highlight.Enabled then Data.Highlight.Enabled = false end
                else
                    -- Dekat -> Nyalakan Teks
                    Data.Billboard.Enabled = true
                    Data.Label.Text = string.format("%s\nHP: %s\n[%dm]", Data.Name, tostring(Data.HP), math.floor(Dist))
                    
                    -- [OPTIMISASI 4] Smart Highlight Limiter
                    -- Cuma nyalakan highlight kalau:
                    -- 1. Jarak deket (HIGHLIGHT_DISTANCE)
                    -- 2. Slot highlight belum penuh (MAX_HIGHLIGHTS)
                    if Dist < HIGHLIGHT_DISTANCE and ActiveHighlights < MAX_HIGHLIGHTS then
                        Data.Highlight.Enabled = true
                        ActiveHighlights = ActiveHighlights + 1
                    else
                        Data.Highlight.Enabled = false
                    end
                end
            else
                RemoveEspObj(Obj)
            end
        end
    end)
    table.insert(EspState.Connections, RenderConn)
end

local function UpdateStatus()
    if EspState.Enabled or EspState.EnemyEnabled then
        if not EspState.IsRunning then
            StartESP()
        end
        -- Re-scan kalau toggle berubah
        for _, child in pairs(TARGET_SCAN_PARENT:GetDescendants()) do
             task.spawn(function() AddEspObj(child) end)
        end
    else
        StopESP()
    end
end

-- [[ 8. UI LOADER ]]
function Esp:Load(Parent, Palette, Engine) 
    
    -- ORE
    Engine:CreateSection(Parent, "ESP ORE", 1)

    local OreList = {}
    for Name, _ in pairs(RockConfig) do table.insert(OreList, Name) end
    table.sort(OreList)

    Engine:CreateDropdown(Parent, "Select Ores", OreList, 3, true, function(Selected)
        EspState.SelectedOres = Selected
        if EspState.Enabled then 
            for Obj, Data in pairs(EspState.Cache) do
                 if RockConfig[Data.Name] and not table.find(Selected, Data.Name) then 
                      RemoveEspObj(Obj)
                 end
            end
            UpdateStatus()
        end
    end)

    Engine:CreateToggle(Parent, "Enable Ore ESP", 2, function(Value)
        EspState.Enabled = Value
        UpdateStatus()
    end)

    
    
    -- ENEMY
    Engine:CreateSection(Parent, "ESP ENEMY", 6)

    local EnemyNames = {}
    for Name, _ in pairs(EnemyConfig) do table.insert(EnemyNames, Name) end
    table.sort(EnemyNames) 

    Engine:CreateDropdown(Parent, "Select Enemies", EnemyNames, 8, true, function(Selected)
        EspState.SelectedEnemies = Selected
        if EspState.EnemyEnabled then 
             for Obj, Data in pairs(EspState.Cache) do
                 if EnemyConfig[Data.Name] and not table.find(Selected, Data.Name) then
                      RemoveEspObj(Obj)
                 end
            end
            UpdateStatus()
        end
    end)

    Engine:CreateToggle(Parent, "Enable Enemy ESP", 7, function(Val)
        EspState.EnemyEnabled = Val
        UpdateStatus()
    end)

    Engine:CreateSpacer(Parent, 10, 9)
    Engine:CreateSlider(Parent, "Render Dist", 500, 1000, 500, 100, function(Val)
        RENDER_DISTANCE = Val
    end)
end

return Esp