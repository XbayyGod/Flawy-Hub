local Automation = {}

function Automation:Load(Parent, Palette)
    local Layout = Instance.new("UIListLayout", Parent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", Parent).PaddingTop = UDim.new(0, 20)
    Instance.new("UIPadding", Parent).PaddingLeft = UDim.new(0, 25)

    local Title = Instance.new("TextLabel", Parent)
    Title.LayoutOrder = 0 -- PASTI PALING ATAS
    Title.Size = UDim2.new(1, -50, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "AUTOMATION MODULE"
    Title.TextColor3 = Palette.TextMain
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local function CreateButton(txt, order)
        local btn = Instance.new("TextButton", Parent)
        btn.LayoutOrder = order
        btn.Size = UDim2.new(1, -50, 0, 40)
        btn.BackgroundColor3 = Palette.Sidebar
        btn.Text = txt
        btn.TextColor3 = Palette.TextMuted
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        Instance.new("UIStroke", btn).Color = Palette.Border
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    end

    CreateButton("Auto Farm Level", 1)
    CreateButton("Auto Collect Coins", 2)
    CreateButton("Auto Quest", 3)
end

return Automation