local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    local TweenService = game:GetService("TweenService")
    
    -- [[ LAYOUT UTAMA ]]
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 15)

    local MainPad = Instance.new("UIPadding", Parent)
    MainPad.PaddingTop = UDim.new(0, 20)
    MainPad.PaddingLeft = UDim.new(0, 20)
    MainPad.PaddingRight = UDim.new(0, 20)

    -- [[ HELPER: CREATE MODERN CARD ]]
    local function CreateCard(name, order, height)
        local card = Instance.new("Frame", Parent)
        card.Name = name .. "_Card"
        card.LayoutOrder = order
        card.Size = UDim2.new(1, 0, 0, height or 100)
        card.BackgroundColor3 = Palette.Sidebar
        card.BorderSizePixel = 0
        card.ZIndex = 5 -- Pastiin card ada di layer tengah
        
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Palette.Border
        stroke.Thickness = 1
        
        return card
    end

    -- [[ 1. HEADER CARD (Status Script) ]]
    local HeaderCard = CreateCard("Header", 1, 80)
    local HeaderPad = Instance.new("UIPadding", HeaderCard)
    HeaderPad.PaddingLeft = UDim.new(0, 20)

    local Title = Instance.new("TextLabel", HeaderCard)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "FORGE ENGINE <font color='#00C8FF'>STABLE</font>"
    Title.RichText = true
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", HeaderCard)
    Desc.Size = UDim2.new(1, 0, 0, 20)
    Desc.Position = UDim2.new(0, 0, 0, 40)
    Desc.BackgroundTransparency = 1
    Desc.Text = "System authenticated. All modules ready to use."
    Desc.TextColor3 = Palette.TextMuted
    Desc.Font = Enum.Font.GothamMedium
    Desc.TextSize = 13
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    -- [[ 2. SOCIAL LINKS (Gaya Modern Buttons) ]]
    local SocialCard = CreateCard("Socials", 2, 100)
    local SocialLayout = Instance.new("UIListLayout", SocialCard)
    SocialLayout.FillDirection = Enum.FillDirection.Horizontal
    SocialLayout.Padding = UDim.new(0, 10)
    SocialLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SocialLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateSocialBtn(name, color, link)
        local btn = Instance.new("TextButton", SocialCard)
        btn.Name = name .. "Btn"
        btn.Size = UDim2.new(0, 120, 0, 45)
        btn.BackgroundColor3 = Palette.Header
        btn.Text = name
        btn.TextColor3 = Palette.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ZIndex = 10 -- FORCE ATAS BIAR BISA DIKLIK
        btn.Active = true -- Biar nerima input
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = color
        bStroke.Thickness = 1.5
        bStroke.Transparency = 0.4

        -- CLICK LOGIC
        btn.MouseButton1Click:Connect(function()
            if setclipboard then 
                setclipboard(link)
                print(name .. " link copied to clipboard!")
            else
                print(name .. ": " .. link)
            end
            
            -- Feedback pas diklik
            btn.BackgroundColor3 = color
            task.wait(0.1)
            btn.BackgroundColor3 = Palette.Header
        end)

        -- HOVER EFFECT
        btn.MouseEnter:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Palette.Border}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.2), {Transparency = 0.4, Thickness = 1.5}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Palette.Header}):Play()
        end)
    end

    CreateSocialBtn("DISCORD", Color3.fromRGB(88, 101, 242), "https://discord.gg/linklu")
    CreateSocialBtn("TIKTOK", Color3.fromRGB(255, 0, 80), "https://tiktok.com/@linklu")
    CreateSocialBtn("YOUTUBE", Color3.fromRGB(255, 0, 0), "https://youtube.com/linklu")

    -- [[ 3. NEWS SECTION ]]
    local NewsCard = CreateCard("News", 3, 100)
    local NewsPad = Instance.new("UIPadding", NewsCard)
    NewsPad.PaddingLeft = UDim.new(0, 20)
    NewsPad.PaddingTop = UDim.new(0, 15)

    local NewsTitle = Instance.new("TextLabel", NewsCard)
    NewsTitle.Text = "LATEST UPDATES"
    NewsTitle.TextColor3 = Palette.ForgeGlow
    NewsTitle.Font = Enum.Font.GothamBold
    NewsTitle.TextSize = 12
    NewsTitle.BackgroundTransparency = 1
    NewsTitle.Size = UDim2.new(1, 0, 0, 20)
    NewsTitle.TextXAlignment = Enum.TextXAlignment.Left

    local ChangeLog = Instance.new("TextLabel", NewsCard)
    ChangeLog.Size = UDim2.new(0.9, 0, 0, 50)
    ChangeLog.Position = UDim2.new(0, 0, 0, 25)
    ChangeLog.BackgroundTransparency = 1
    ChangeLog.Text = "• Fixed Clickable Social Links\n• Refined Dashboard Layout\n• Improved UI Performance"
    ChangeLog.TextColor3 = Palette.TextMuted
    ChangeLog.Font = Enum.Font.Gotham
    ChangeLog.TextSize = 13
    ChangeLog.TextXAlignment = Enum.TextXAlignment.Left
    ChangeLog.TextYAlignment = Enum.TextYAlignment.Top
end

return Dashboard