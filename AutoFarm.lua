local AutoFarm = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = {
    Height_Offset = 2,
    Travel_Speed = 60,
    IsMining = false,
    SelectedResource = {}, 
    IsFarmingMob = false,
    SelectedMob = "None",
    CurrentTarget = nil,
    IsFlying = false,
    FlyHeight = 10 -- Tinggi default terbang saat idle
}

local EngineConnection = nil
local AttackLoop = nil
local NoclipLoop = nil
local FlyLoop = nil
local CurrentResDropdown = nil
local CurrentMobDropdown = nil

-- [[ 1. FULL RESET & CLEANUP ]]
local function ResetCharacter()
    State.IsMining = false
    State.IsFarmingMob = false
    State.CurrentTarget = nil
    State.IsFlying = false
    
    if EngineConnection then EngineConnection:Disconnect(); EngineConnection = nil end
    if NoclipLoop then task.cancel(NoclipLoop); NoclipLoop = nil end
    if AttackLoop then task.cancel(AttackLoop); AttackLoop = nil end
    if FlyLoop then task.cancel(FlyLoop); FlyLoop = nil end

    local Char = Players.LocalPlayer.Character
    if Char then
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then
            Hum.PlatformStand = false
            Hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        for _, v in ipairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

-- [[ 2. PERMANENT NOCLIP LOOP ]]
local function StartNoclip()
    if NoclipLoop then task.cancel(NoclipLoop) end
    NoclipLoop = task.spawn(function()
        while State.IsMining or State.IsFarmingMob do
            local Char = Players.LocalPlayer.Character
            if Char then
                for _, v in ipairs(Char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
            task.wait()
        end
    end)
end

-- [[ 3. FLY SYSTEM - KARAKTER TERBANG SAAT TARGET HABIS ]]
local function StartFlySystem()
    if FlyLoop then task.cancel(FlyLoop) end
    
    FlyLoop = task.spawn(function()
        local Char = Players.LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        if not Root then return end
        
        State.IsFlying = true
        
        while State.IsFlying do
            local currentPos = Root.Position
            local targetHeight = State.FlyHeight
            local targetPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
            
            -- Smooth movement ke target height
            local distance = (targetPos - currentPos).Magnitude
            if distance > 0.1 then
                local moveStep = 50 * task.wait() -- Kecepatan naik/turun
                if moveStep > distance then moveStep = distance end
                
                local direction = (targetPos - currentPos).Unit
                Root.CFrame = CFrame.new(currentPos + (direction * moveStep))
            end
            
            -- Putar perlahan di tempat untuk mencari target
            Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(1), 0)
            
            task.wait()
        end
    end)
end

-- [[ 4. AGGRESSIVE SCANNER DENGAN FIXED RANGE 1000 ]]
local function GetNearest()
    local Char = Players.LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Closest, ClosestDist = nil, 1000 -- Fixed range 1000 studs
    
    for _, Obj in pairs(workspace:GetDescendants()) do
        local Valid = false
        if State.IsMining then
            if table.find(State.SelectedResource, Obj.Name) then
                local HP = Obj:GetAttribute("Health") or (Obj:FindFirstChild("HP") and Obj.HP.Value) or 100
                Valid = (HP > 0)
            end
        elseif State.IsFarmingMob then
            if Obj.Name:find(State.SelectedMob) and Obj:FindFirstChildOfClass("Humanoid") then
                local Hum = Obj:FindFirstChildOfClass("Humanoid")
                Valid = (Hum and Hum.Health > 0)
            end
        end

        if Valid and Obj.Parent then
            local Pos = Obj:IsA("Model") and Obj:GetPivot().Position or (Obj:IsA("BasePart") and Obj.Position)
            if Pos then
                local Dist = (Root.Position - Pos).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Closest = Obj
                end
            end
        end
    end
    
    -- Jika ada target, matikan flying mode
    if Closest then
        State.IsFlying = false
        if FlyLoop then
            task.cancel(FlyLoop)
            FlyLoop = nil
        end
    else
        -- Jika tidak ada target, aktifkan flying mode
        if not State.IsFlying then
            StartFlySystem()
        end
    end
    
    return Closest
end

-- [[ 5. PERBAIKAN MOVEMENT ENGINE DENGAN HEIGHT OFFSET REAL ]]
local function StartMovementEngine()
    if EngineConnection then EngineConnection:Disconnect() end
    StartNoclip()
    
    EngineConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.IsMining and not State.IsFarmingMob then return end
        
        local Char = Players.LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        if not Root or not Hum then return end

        Hum.PlatformStand = true 
        Root.Velocity = Vector3.new(0,0,0)

        if not State.CurrentTarget or not State.CurrentTarget.Parent then
            State.CurrentTarget = GetNearest()
            -- Jika tidak ada target, biarkan fly system mengontrol
            if not State.CurrentTarget then
                return
            end
        else
            local Dead = false
            if State.IsFarmingMob then
                local mHum = State.CurrentTarget:FindFirstChildOfClass("Humanoid")
                if not mHum or mHum.Health <= 0 then Dead = true end
            else
                local oHP = State.CurrentTarget:GetAttribute("Health") or (State.CurrentTarget:FindFirstChild("HP") and State.CurrentTarget.HP.Value) or 100
                if oHP <= 0 then Dead = true end
            end
            if Dead then 
                State.CurrentTarget = nil
                return
            end
        end

        if State.CurrentTarget then
            local TPosRaw = State.CurrentTarget:IsA("Model") and State.CurrentTarget:GetPivot().Position or State.CurrentTarget.Position
            
            -- [[ HEIGHT OFFSET REAL - SESUAI INPUT USER ]]
            local TPos = Vector3.new(
                TPosRaw.X,
                TPosRaw.Y + State.Height_Offset, -- Gunakan offset langsung dari user
                TPosRaw.Z
            )
            
            local Distance = (Root.Position - TPos).Magnitude
            
            -- Hitung posisi untuk melihat target (lookAt)
            local LookPos = Vector3.new(TPosRaw.X, TPosRaw.Y + 1, TPosRaw.Z) -- Lihat ke tengah target
            
            if Distance > 0.1 then
                local MoveStep = State.Travel_Speed * dt
                if MoveStep > Distance then MoveStep = Distance end
                
                local NewPos = Root.Position + ((TPos - Root.Position).Unit * MoveStep)
                Root.CFrame = CFrame.lookAt(NewPos, LookPos)
            else
                Root.CFrame = CFrame.lookAt(TPos, LookPos)
            end
        end
    end)
end

-- [[ 6. ATTACK ENGINE ]]
local function StartAttackEngine()
    if AttackLoop then task.cancel(AttackLoop) end
    AttackLoop = task.spawn(function()
        local RF = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
        while (State.IsMining or State.IsFarmingMob) do
            if State.CurrentTarget then
                pcall(function()
                    RF:InvokeServer(State.IsMining and "Pickaxe" or "Weapon")
                end)
            end
            task.wait(0) 
        end
    end)
end

-- [[ 7. UI LOADER YANG DISEDERHANAKAN ]]
function AutoFarm:Load(Parent, Palette, Engine) 
    Engine:CreateSection(Parent, "Tween Setting", 1)
    
    -- Height Offset dengan info real
    Engine:CreateSlider(Parent, "Height Offset (Units)", -10, 20, State.Height_Offset, 2, function(val) 
        State.Height_Offset = val 
        -- Info: 1 unit = 1 stud = tinggi karakter Roblox
    end)
    
    Engine:CreateSlider(Parent, "Fly Speed", 20, 300, State.Travel_Speed, 3, function(val) 
        State.Travel_Speed = val 
    end)

    -- ORES
    Engine:CreateSection(Parent, "Farm Ores", 4)
    local OreData = {
        ["Stonewake's Cross"] = {"Pebble", "Rock", "Boulder", "Lucky Block"},
        ["Forgotten Kingdom"] = {"Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock", "Light Crystal", "Earth Crystal", "Violet Crystal", "Crimson Crystal", "Cyan Crystal"},
        ["Frostspire Expanse"] = {"Icy Pebble", "Icy Rock", "Icy Boulder", "Small Ice Crystal", "Medium Ice Crystal", "Large Ice Crystal", "Floating Crystal", "Iceberg"}
    }
    Engine:CreateDropdown(Parent, "Select Island (Ore)", {"Stonewake's Cross", "Forgotten Kingdom", "Frostspire Expanse"}, 5, function(val)
        if CurrentResDropdown then pcall(function() CurrentResDropdown.Frame:Destroy() end) end
        CurrentResDropdown = Engine:CreateDropdown(Parent, "Select Rocks", OreData[val] or {}, 6, true, function(res) 
            State.SelectedResource = res 
        end)
    end)
    Engine:CreateToggle(Parent, "Start Farm Ore", 7, function(state)
        if state then 
            ResetCharacter()
            State.IsMining = true
            StartMovementEngine() 
            StartAttackEngine() 
        else 
            ResetCharacter() 
        end
    end)

    -- MONSTERS
    Engine:CreateSection(Parent, "Farm Monsters", 8)
    local MobData = {
        ["Iron Valley"] = {"Zombie", "Elite Zombie", "Delver Zombie", "Brute Zombie"},
        ["Forgotten Kingdom"] = {"Bomber", "Slime", "Blazing Slime", "Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton", "Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Blight Pyromancer", "Reaper"},
        ["Frostspire Expanse"] = {"Crystal Spider", "Diamond Spider", "Prismarine Spider", "Mini Demonic Spider", "Demonic Spider", "Demonic Queen Spider", "Common Orc", "Elite Orc", "Yeti", "Crystal Golem"}
    }
    Engine:CreateDropdown(Parent, "Select Island (Mob)", {"Iron Valley", "Forgotten Kingdom", "Frostspire Expanse"}, 9, function(val)
        if CurrentMobDropdown then pcall(function() CurrentMobDropdown.Frame:Destroy() end) end
        CurrentMobDropdown = Engine:CreateDropdown(Parent, "Select Monster", MobData[val] or {}, 10, false, function(mob) 
            State.SelectedMob = mob 
        end)
    end)
    Engine:CreateToggle(Parent, "Start Farm Mobs", 11, function(state)
        if state then 
            ResetCharacter()
            State.IsFarmingMob = true
            StartMovementEngine() 
            StartAttackEngine() 
        else 
            ResetCharacter() 
        end
    end)
    
end

return AutoFarm