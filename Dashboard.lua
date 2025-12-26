local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 15)

    local MainPad = Instance.new("UIPadding", Parent)
    MainPad.PaddingTop = UDim.new(0, 20)
    MainPad.PaddingLeft = UDim.new(0, 20)
    MainPad.PaddingRight = UDim.new(0, 20)

    -- [[ HELPER: CREATE PREMIUM CARD ]]
    local function CreateCard(name, order, height)
        local card = Instance.new("Frame", Parent)
        card.Name = name .. "_Card"
        card.LayoutOrder = order
        card.Size = UDim2.new(1, 0, 0, height or 100)
        card.BackgroundColor3 = Palette.Sidebar
        card.BorderSizePixel = 0
        
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Palette.Border
        stroke.Thickness = 1
        
        return card
    end

    -- [[ 1. SESSION STATISTICS CARD ]]
    local SessionCard = CreateCard("Session", 1, 95)
    local SessionPad = Instance.new("UIPadding", SessionCard)
    SessionPad.PaddingLeft = UDim.new(0, 20)

    local Greet = Instance.new("TextLabel", SessionCard)
    Greet.Size = UDim2.new(1, 0, 0, 40)
    Greet.Position = UDim2.new(0, 0, 0, 15)
    Greet.BackgroundTransparency = 1
    Greet.Text = "FLAWY HUB | <font color='#00C8FF'>V1</font>"
    Greet.RichText = true
    Greet.TextColor3 = Palette.TextMain
    Greet.Font = Enum.Font.GothamBold
    Greet.TextSize = 18
    Greet.TextXAlignment = Enum.TextXAlignment.Left

    local UptimeLabel = Instance.new("TextLabel", SessionCard)
    UptimeLabel.Size = UDim2.new(1, 0, 0, 20)
    UptimeLabel.Position = UDim2.new(0, 0, 0, 45)
    UptimeLabel.BackgroundTransparency = 1
    UptimeLabel.Text = "Time: 00:00:00 | Ping: ... ms"
    UptimeLabel.TextColor3 = Palette.TextMuted
    UptimeLabel.Font = Enum.Font.GothamMedium
    UptimeLabel.TextSize = 13
    UptimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Logic Uptime & Ping
    local startTime = os.time()
    task.spawn(function()
        while task.wait(1) do
            local currentTime = os.date("%H:%M:%S") 
            local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000) 
            UptimeLabel.Text = string.format("Time: %s | Ping: %d ms", currentTime, ping)
        end
    end)

    -- [[ 2. QUICK LINKS CARD ]]
    local SocialCard = CreateCard("Socials", 2, 75)
    local SocialLayout = Instance.new("UIListLayout", SocialCard)
    SocialLayout.FillDirection = Enum.FillDirection.Horizontal
    SocialLayout.Padding = UDim.new(0, 20)
    SocialLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SocialLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateLinkBtn(name, color, link)
        local btn = Instance.new("TextButton", SocialCard)
        btn.Size = UDim2.new(0, 140, 0, 32)
        btn.BackgroundColor3 = Palette.Header
        btn.Text = name
        btn.TextColor3 = Palette.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.AutoButtonColor = false
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = color
        bStroke.Thickness = 1.2

        btn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(link) end
            print("Link Copied!")
        end)
    end

    CreateLinkBtn("JOIN DISCORD", Color3.fromRGB(88, 101, 242), "https://discord.gg/link_lu")
    CreateLinkBtn("YOUTUBE CHANNEL", Color3.fromRGB(255, 0, 0), "https://youtube.com/link_lu")

    -- [[ 3. SYSTEM LOGS / NEWS CARD ]]
    local NewsCard = CreateCard("News", 3, 110)
    local NewsPad = Instance.new("UIPadding", NewsCard)
    NewsPad.PaddingLeft = UDim.new(0, 20)
    NewsPad.PaddingTop = UDim.new(0, 15)

    local NewsTitle = Instance.new("TextLabel", NewsCard)
    NewsTitle.Size = UDim2.new(1, 0, 0, 20)
    NewsTitle.BackgroundTransparency = 1
    NewsTitle.Text = "UPDATE LOGS & STATUS"
    NewsTitle.TextColor3 = Palette.ForgeGlow
    NewsTitle.Font = Enum.Font.GothamBold
    NewsTitle.TextSize = 12
    NewsTitle.TextXAlignment = Enum.TextXAlignment.Left

    local NewsDesc = Instance.new("TextLabel", NewsCard)
    NewsDesc.Size = UDim2.new(0.9, 0, 0, 50)
    NewsDesc.Position = UDim2.new(0, 0, 0, 25)
    NewsDesc.BackgroundTransparency = 1
    NewsDesc.Text = "• Fixed Tab Switching lag\n• Optimized Memory Usage\n• Added Live Ping/Uptime Statistics"
    NewsDesc.TextColor3 = Palette.TextMuted
    NewsDesc.Font = Enum.Font.Gotham
    NewsDesc.TextSize = 13
    NewsDesc.TextXAlignment = Enum.TextXAlignment.Left
    NewsDesc.TextYAlignment = Enum.TextYAlignment.Top
    NewsDesc.RichText = true
end

return Dashboard