local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 15)

    local MainPad = Instance.new("UIPadding", Parent)
    MainPad.PaddingTop = UDim.new(0, 20)
    MainPad.PaddingLeft = UDim.new(0, 25)
    MainPad.PaddingRight = UDim.new(0, 25)

    -- [[ 1. HEADER CARD ]]
    local Header = Instance.new("Frame", Parent)
    Header.LayoutOrder = 1
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Palette.Sidebar
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Header).Color = Palette.Border

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "FORGE ENGINE | <font color='#00C8FF'>V1.1</font>"
    Title.RichText = true
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TimeLabel = Instance.new("TextLabel", Header)
    TimeLabel.Size = UDim2.new(1, -20, 0, 20)
    TimeLabel.Position = UDim2.new(0, 20, 0, 42)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = "Loading system time..."
    TimeLabel.TextColor3 = Palette.TextMuted
    TimeLabel.Font = Enum.Font.GothamMedium
    TimeLabel.TextSize = 13
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while task.wait(1) do
            local time = os.date("%H:%M:%S")
            local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
            TimeLabel.Text = "Local Time: "..time.." | Latency: "..ping.."ms"
        end
    end)

    -- [[ 2. SOCIAL BUTTONS (NON-NORAK COLORS) ]]
    local Socials = Instance.new("Frame", Parent)
    Socials.LayoutOrder = 2
    Socials.Size = UDim2.new(1, 0, 0, 50)
    Socials.BackgroundTransparency = 1
    local SLayout = Instance.new("UIListLayout", Socials)
    SLayout.FillDirection = Enum.FillDirection.Horizontal
    SLayout.Padding = UDim.new(0, 12)

    local function CreateSocialBtn(name, color, link)
        local btn = Instance.new("TextButton", Socials)
        btn.Size = UDim2.new(0, 140, 1, 0)
        btn.BackgroundColor3 = Palette.Sidebar
        btn.Text = name
        btn.TextColor3 = Palette.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = color
        bStroke.Thickness = 1.2
        bStroke.Transparency = 0.5

        btn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(link) end
            print("Link Copied: "..link)
        end)

        btn.MouseEnter:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
        end)
    end

    -- Warna Muted: Deep Blue & Muted Rose
    CreateSocialBtn("DISCORD", Color3.fromRGB(75, 85, 180), "https://discord.gg/linklu")
    CreateSocialBtn("TIKTOK", Color3.fromRGB(180, 50, 80), "https://tiktok.com/@linklu")
end

return Dashboard