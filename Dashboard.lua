local Dashboard = {}

function Dashboard:Load(Parent, Palette)
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder -- WAJIB: Biar ngikutin nomor LayoutOrder
    Layout.Padding = UDim.new(0, 12)
    
    -- Judul (Paling Atas)
    local Title = Instance.new("TextLabel", Parent)
    Title.LayoutOrder = 1
    Title.Size = UDim2.new(1, -50, 0, 30)
    Title.Text = "WELCOME, MUHAMAD IQBAL"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Info (Bawah Judul)
    local Info = Instance.new("TextLabel", Parent)
    Info.LayoutOrder = 2
    Info.Size = UDim2.new(1, -50, 0, 20)
    Info.Text = "NIM: 0110224008 | STATUS: DEVELOPER"
    Info.TextColor3 = Palette.ForgeGlow
    Info.Font = Enum.Font.GothamMedium
    Info.TextSize = 14
    Info.BackgroundTransparency = 1
    Info.TextXAlignment = Enum.TextXAlignment.Left

    -- Garis Decor (Bawah Info)
    local Line = Instance.new("Frame", Parent)
    Line.LayoutOrder = 3
    Line.Size = UDim2.new(0.9, 0, 0, 1)
    Line.BackgroundColor3 = Palette.Border
    Line.BorderSizePixel = 0
end

return Dashboard