local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    -- Layout
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 10)
    
    local Pad = Instance.new("UIPadding", Parent)
    Pad.PaddingTop = UDim.new(0, 20)
    Pad.PaddingLeft = UDim.new(0, 20)

    -- Welcome Label
    local Title = Instance.new("TextLabel", Parent)
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "WELCOME, MUHAMAD IQBAL"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- NIM & Info
    local Info = Instance.new("TextLabel", Parent)
    Info.Size = UDim2.new(1, -40, 0, 20)
    Info.BackgroundTransparency = 1
    Info.Text = "NIM: 0110224008 | STATUS: DEVELOPER"
    Info.TextColor3 = Palette.ForgeGlow
    Info.Font = Enum.Font.GothamMedium
    Info.TextSize = 14
    Info.TextXAlignment = Enum.TextXAlignment.Left

    -- Line Decor
    local Line = Instance.new("Frame", Parent)
    Line.Size = UDim2.new(0.5, 0, 0, 1)
    Line.BackgroundColor3 = Palette.Border
    Line.BorderSizePixel = 0

    -- Script Status
    local Status = Instance.new("TextLabel", Parent)
    Status.Size = UDim2.new(1, -40, 0, 40)
    Status.BackgroundTransparency = 1
    Status.Text = "Forge Engine V1.1 is running smoothly. All systems operational."
    Status.TextColor3 = Palette.TextMuted
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 13
    Status.TextWrapped = true
    Status.TextXAlignment = Enum.TextXAlignment.Left
end

return Dashboard