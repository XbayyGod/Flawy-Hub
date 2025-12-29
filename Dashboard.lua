local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    -- [[ LAYOUT SETTINGS ]]
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 18) -- Jarak antar widget lebih lega

    local MainPad = Instance.new("UIPadding", Parent)
    MainPad.PaddingTop = UDim.new(0, 25)
    MainPad.PaddingLeft = UDim.new(0, 30)
    MainPad.PaddingRight = UDim.new(0, 30)

    -- [[ HELPER: CREATE BIG CARD ]]
    local function CreateWidget(name, order, height)
        local frame = Instance.new("Frame", Parent)
        frame.Name = name .. "_Widget"
        frame.LayoutOrder = order
        frame.Size = UDim2.new(1, 0, 0, height or 100)
        frame.BackgroundColor3 = Palette.Sidebar
        frame.BorderSizePixel = 0
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Palette.Border
        stroke.Thickness = 1.5
        
        return frame
    end

    -- [[ 1. STATUS WIDGET (FONT GEDE) ]]
    local StatusW = CreateWidget("Status", 1, 95)
    local Glow = Instance.new("Frame", StatusW)
    Glow.Size = UDim2.new(0, 5, 1, -30)
    Glow.Position = UDim2.new(0, 18, 0, 15)
    Glow.BackgroundColor3 = Palette.ForgeGlow
    Glow.BorderSizePixel = 0
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(1, 0)

    local Title = Instance.new("TextLabel", StatusW)
    Title.Size = UDim2.new(1, -50, 0, 35)
    Title.Position = UDim2.new(0, 35, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "FLAWY HUB <font color='#00C8FF'>V1</font>"
    Title.RichText = true
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24 -- GEDEIN
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local StatsLabel = Instance.new("TextLabel", StatusW)
    StatsLabel.Size = UDim2.new(1, -50, 0, 25)
    StatsLabel.Position = UDim2.new(0, 35, 0, 50)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Text = "Loading system time..."
    StatsLabel.TextColor3 = Palette.TextMuted
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.TextSize = 16 -- GEDEIN
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while task.wait(1) do
            local time = os.date("%H:%M:%S")
            local ping = math.floor(lp:GetNetworkPing() * 1000)
            StatsLabel.Text = "Time: " .. time .. "  |  Ping: " .. ping .. "ms"
        end
    end)

    -- [[ 2. SOCIAL LINKS (CLEAN) ]]
    local SocialW = CreateWidget("Socials", 2, 85)
    local SLayout = Instance.new("UIListLayout", SocialW)
    SLayout.FillDirection = Enum.FillDirection.Horizontal
    SLayout.Padding = UDim.new(0, 15)
    SLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateLinkBtn(name, color, link)
        local btn = Instance.new("TextButton", SocialW)
        btn.Size = UDim2.new(0.3, -10, 0, 45) -- Tombol lebih tinggi
        btn.BackgroundColor3 = Palette.Header
        btn.Text = name
        btn.TextColor3 = Palette.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13 -- Lebih kebaca
        btn.AutoButtonColor = false
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = color
        bStroke.Thickness = 1.5
        bStroke.Transparency = 0.5

        btn.MouseButton1Click:Connect(function() 
            if setclipboard then setclipboard(link) end 
            btn.BackgroundColor3 = color
            task.wait(0.1)
            btn.BackgroundColor3 = Palette.Header
        end)
    end

    CreateLinkBtn("DISCORD", Color3.fromRGB(75, 85, 180), "https://discord.gg/linklu")
    CreateLinkBtn("TIKTOK", Color3.fromRGB(180, 50, 80), "https://tiktok.com/@linklu")
    CreateLinkBtn("YOUTUBE", Color3.fromRGB(180, 30, 30), "https://youtube.com/linklu")
end

return Dashboard