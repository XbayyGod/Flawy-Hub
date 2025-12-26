local Combat = {}

function Combat:Load(Parent, Palette)
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", Parent).PaddingTop = UDim.new(0, 20)
    Instance.new("UIPadding", Parent).PaddingLeft = UDim.new(0, 20)

    local Title = Instance.new("TextLabel", Parent)
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "COMBAT MODULE"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local function CreateToggle(txt)
        local btn = Instance.new("TextButton", Parent)
        btn.Size = UDim2.new(1, -50, 0, 40)
        btn.BackgroundColor3 = Palette.Sidebar
        btn.Text = "[ OFF ] " .. txt
        btn.TextColor3 = Palette.TextMuted
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.Text = active and "[ ON ] " .. txt or "[ OFF ] " .. txt
            btn.TextColor3 = active and Palette.ForgeGlow or Palette.TextMuted
        end)
    end

    CreateToggle("Kill Aura")
    CreateToggle("Auto Block")
    CreateToggle("Hitbox Expander")
end

return Combat