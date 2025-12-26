local Dashboard = {}
function Dashboard:Load(Parent, Palette)
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder -- Biar urutan rapi dari atas ke bawah
    Layout.Padding = UDim.new(0, 12)
    Instance.new("UIPadding", Parent).PaddingTop = UDim.new(0, 25)
    Instance.new("UIPadding", Parent).PaddingLeft = UDim.new(0, 25)

    local Title = Instance.new("TextLabel", Parent)
    Title.LayoutOrder = 1
    Title.Size = UDim2.new(1, -50, 0, 30) -- FULL WIDTH
    Title.Text = "WELCOME, MUHAMAD IQBAL"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Info = Instance.new("TextLabel", Parent)
    Info.LayoutOrder = 2
    Info.Size = UDim2.new(1, -50, 0, 20)
    Info.Text = "NIM: 0110224008 | STATUS: DEVELOPER"
    Info.TextColor3 = Palette.ForgeGlow
    Info.Font = Enum.Font.GothamMedium
    Info.TextSize = 14
    Info.BackgroundTransparency = 1
    Info.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame", Parent)
    Line.LayoutOrder = 3
    Line.Size = UDim2.new(0.9, 0, 0, 1) -- Garis hampir full
    Line.BackgroundColor3 = Palette.Border
    Line.BorderSizePixel = 0
end
return Dashboard