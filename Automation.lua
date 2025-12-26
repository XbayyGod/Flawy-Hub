local Automation = {}

function Automation:Load(Parent, Palette)
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder -- WAJIB
    Layout.Padding = UDim.new(0, 10)

    -- Judul Modul (LayoutOrder 1)
    local Title = Instance.new("TextLabel", Parent)
    Title.LayoutOrder = 1
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "AUTOMATION MODULE"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local function CreateButton(txt)
        local btn = Instance.new("TextButton", Parent)
        btn.LayoutOrder = 2 -- Biar di bawah Judul (LayoutOrder 1)
        btn.Size = UDim2.new(1, -50, 0, 40)
        btn.BackgroundColor3 = Palette.Sidebar
        btn.Text = txt
        btn.TextColor3 = Palette.TextMuted
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.AutoButtonColor = false
        
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Palette.Border
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function() 
            game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {TextColor3 = Palette.TextMain, BackgroundColor3 = Palette.Header}):Play()
        end)
        btn.MouseLeave:Connect(function() 
            game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {TextColor3 = Palette.TextMuted, BackgroundColor3 = Palette.Sidebar}):Play()
        end)
    end

    CreateButton("Auto Farm Level")
    CreateButton("Auto Collect Coins")
    CreateButton("Auto Quest")
end

return Automation