--[[ PARTE 1/4 ]]

-- Serviços
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Limpeza de GUI anterior
if CoreGui:FindFirstChild("ZakyFinalBoss") then
    CoreGui.ZakyFinalBoss:Destroy()
end

-- Interface
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyFinalBoss"
Screen.ResetOnSpawn = false

-- ================== SISTEMA DE SALVAR/CARREGAR ==================
local SaveFileName = "ZakyHub_Config.json"
local ToggleStates = {
    ESP_Players = false,
    Aimbot = false,
    AntiLag = false,
    Noclip = false,
    ItemESP = false,
    HealthBarESP = false
}

local function SaveConfig()
    local json = game:GetService("HttpService"):JSONEncode(ToggleStates)
    pcall(function()
        writefile(SaveFileName, json)
    end)
end

local function LoadConfig()
    local success, data = pcall(function()
        return readfile(SaveFileName)
    end)
    if success and data then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        for key, val in pairs(decoded) do
            ToggleStates[key] = val
        end
        return true
    end
    return false
end

-- Aplica as configurações carregadas
local ConfigLoaded = LoadConfig()

-- ================== FUNÇÃO DE ARRASTE ==================
local function MakeDraggable(frame)
    local dragging, startPos, dragStart
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================== CONSTRUÇÃO DA GUI ==================
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 400, 0, 500)
Main.Position = UDim2.new(0.5, -200, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.ClipsDescendants = true
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 0, 80)
Stroke.Thickness = 2

MakeDraggable(Main)

-- Título
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ZAKY HUB : FINAL BOSS"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0

-- Botão Minimizar
local Minimized = false
local OriginalSize = Main.Size
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        OriginalSize = Main.Size
        TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 40)
        }):Play()
        MinBtn.Text = "+"
    else
        TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = OriginalSize
        }):Play()
        MinBtn.Text = "-"
    end
end)

-- Botão Fechar (X) – fecha direto
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)

CloseBtn.MouseButton1Click:Connect(function()
    Screen:Destroy()
end)

-- Container com scroll
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.BorderSizePixel = 0
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- Função para criar Toggles (com suporte a carregar estado inicial)
local function AddToggle(text, key, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "OFF | " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn)

    local active = ToggleStates[key] and true or false
    local function updateVisual()
        btn.BackgroundColor3 = active and Color3.fromRGB(255, 0, 80) or Color3.fromRGB(30, 30, 35)
        btn.Text = (active and "ON" or "OFF") .. " | " .. text
    end
    updateVisual()
    if active then
        callback(true)  -- ativa a função se já estava salvo como ligado
    end

    btn.MouseButton1Click:Connect(function()
        active = not active
        ToggleStates[key] = active
        updateVisual()
        callback(active)
        SaveConfig()
    end)
end--[[ PARTE 2/4 ]]

-- ================== NOCLIP ==================
local NoclipActive = false
AddToggle("Noclip (Atravessar Paredes)", "Noclip", function(state)
    NoclipActive = state
end)
RS.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ================== ESP DE ITENS ==================
local ItemESP_Active = false
local ItemHighlights = {}
local ItemBills = {}
local ItemSearchTerms = {"Loot", "Item", "Chest", "Crate", "Box", "Supply", "Collectable", "Coin", "Gem"}

local function ScanItems()
    for _, h in pairs(ItemHighlights) do if h then h:Destroy() end end
    for _, b in pairs(ItemBills) do if b then b:Destroy() end end
    ItemHighlights = {}
    ItemBills = {}
    if not ItemESP_Active then return end

    for _, obj in pairs(WS:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 0.5 then
            local nameLower = obj.Name:lower()
            for _, term in pairs(ItemSearchTerms) do
                if nameLower:find(term:lower()) then
                    local hl = Instance.new("Highlight")
                    hl.Parent = obj
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                    hl.FillTransparency = 0.6
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    table.insert(ItemHighlights, hl)

                    local bill = Instance.new("BillboardGui")
                    bill.Parent = obj
                    bill.Size = UDim2.new(0, 80, 0, 16)
                    bill.StudsOffset = Vector3.new(0, 2, 0)
                    bill.AlwaysOnTop = true
                    local label = Instance.new("TextLabel", bill)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(0, 1, 0)
                    label.TextStrokeTransparency = 0.5
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 10
                    label.Text = obj.Name
                    table.insert(ItemBills, bill)
                    break
                end
            end
        end
    end
end

AddToggle("ESP de Itens (Baús/Loot)", "ItemESP", function(state)
    ItemESP_Active = state
    if state then
        ScanItems()
    else
        for _, h in pairs(ItemHighlights) do if h then h:Destroy() end end
        for _, b in pairs(ItemBills) do if b then b:Destroy() end end
        ItemHighlights = {}
        ItemBills = {}
    end
end)

-- Atualizar periodicamente
spawn(function()
    while true do
        if ItemESP_Active then
            ScanItems()
        end
        wait(5)
    end
end)--[[ PARTE 3/4 ]]

-- ================== HEALTH BAR ESP ==================
local HealthBar_Active = false
local HealthBarObjects = {}

local function UpdateHealthBarForPlayer(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("Head") then
        if HealthBarObjects[player] then
            HealthBarObjects[player].billboard:Destroy()
            HealthBarObjects[player] = nil
        end
        return
    end
    local hum = char.Humanoid
    local head = char.Head
    if not HealthBarObjects[player] then
        local bill = Instance.new("BillboardGui")
        bill.Name = "HealthBar"
        bill.Size = UDim2.new(0, 80, 0, 20)
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.AlwaysOnTop = true
        bill.Parent = head

        local nameLabel = Instance.new("TextLabel", bill)
        nameLabel.Size = UDim2.new(1, 0, 0, 12)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.Text = player.Name

        local bg = Instance.new("Frame", bill)
        bg.Size = UDim2.new(1, 0, 0, 6)
        bg.Position = UDim2.new(0, 0, 0, 14)
        bg.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        bg.BorderSizePixel = 0

        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = Color3.new(0, 1, 0)
        fill.BorderSizePixel = 0

        HealthBarObjects[player] = {
            billboard = bill,
            fill = fill,
            nameLabel = nameLabel
        }
    end
    local obj = HealthBarObjects[player]
    local ratio = hum.Health / hum.MaxHealth
    obj.fill.Size = UDim2.new(ratio, 0, 1, 0)
    obj.fill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
end

local function HealthBarLoop()
    if not HealthBar_Active then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            UpdateHealthBarForPlayer(player)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if HealthBarObjects[player] then
        HealthBarObjects[player].billboard:Destroy()
        HealthBarObjects[player] = nil
    end
end)

AddToggle("Health Bar ESP", "HealthBarESP", function(state)
    HealthBar_Active = state
    if not state then
        for _, obj in pairs(HealthBarObjects) do
            obj.billboard:Destroy()
        end
        HealthBarObjects = {}
    end
end)

-- ================== TELEPORT PARA JOGADORES ==================
local PlayersLabel = Instance.new("TextLabel", Container)
PlayersLabel.Size = UDim2.new(1, 0, 0, 20)
PlayersLabel.Text = "TELEPORTAR PARA:"
PlayersLabel.TextColor3 = Color3.new(1, 1, 1)
PlayersLabel.BackgroundTransparency = 1
PlayersLabel.Font = Enum.Font.GothamSemibold
PlayersLabel.TextSize = 13
PlayersLabel.BorderSizePixel = 0

local PlayerListFrame = Instance.new("Frame", Container)
PlayerListFrame.Size = UDim2.new(1, 0, 0, 120)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerListFrame.BorderSizePixel = 0
Instance.new("UICorner", PlayerListFrame)

local PLScroll = Instance.new("ScrollingFrame", PlayerListFrame)
PLScroll.Size = UDim2.new(1, 0, 1, 0)
PLScroll.BackgroundTransparency = 1
PLScroll.ScrollBarThickness = 2
PLScroll.BorderSizePixel = 0
PLScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local PLayout = Instance.new("UIListLayout", PLScroll)
PLayout.Padding = UDim.new(0, 2)
PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PLScroll.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 5)
end)

local function RefreshTeleportList()
    for _, child in pairs(PLScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local row = Instance.new("Frame", PLScroll)
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1

            local nameBtn = Instance.new("TextButton", row)
            nameBtn.Size = UDim2.new(0.7, 0, 1, 0)
            nameBtn.Text = player.Name
            nameBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            nameBtn.TextColor3 = Color3.new(1, 1, 1)
            nameBtn.BorderSizePixel = 0
            Instance.new("UICorner", nameBtn)

            local teleBtn = Instance.new("TextButton", row)
            teleBtn.Size = UDim2.new(0.28, 0, 1, 0)
            teleBtn.Position = UDim2.new(0.72, 0, 0, 0)
            teleBtn.Text = "Teleport"
            teleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            teleBtn.TextColor3 = Color3.new(1, 1, 1)
            teleBtn.BorderSizePixel = 0
            Instance.new("UICorner", teleBtn)

            teleBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character:MoveTo(player.Character.HumanoidRootPart.Position)
                end
            end)
        end
    end
end
RefreshTeleportList()
Players.PlayerAdded:Connect(RefreshTeleportList)
Players.PlayerRemoving:Connect(RefreshTeleportList)--[[ PARTE 4/4 ]]

-- ================== ANTIGAS FUNÇÕES ==================
-- ESP de Jogadores
local ESPPlayers_Active = false
local ESPHighlights = {}
local ESPBills = {}

local function UpdateESPColor()
    local hue = (tick() * 80) % 255
    local color = Color3.fromHSV(hue / 255, 1, 1)
    for _, hl in pairs(ESPHighlights) do
        if hl and hl.Parent then
            hl.FillColor = color
        end
    end
end

local function RemoveESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
    if ESPBills[player] then
        ESPBills[player]:Destroy()
        ESPBills[player] = nil
    end
end

local function SetupESP(player)
    RemoveESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.Parent = char
    ESPHighlights[player] = hl

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Text = player.Name
    bill.Parent = char.Head
    ESPBills[player] = bill
end

local function RefreshAllESP()
    if not ESPPlayers_Active then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            SetupESP(player)
        end
    end
end

local function BindESPForPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterRemoving:Connect(function()
        RemoveESP(player)
    end)
    player.CharacterAdded:Connect(function(char)
        if ESPPlayers_Active then
            char:WaitForChild("Head", 5)
            SetupESP(player)
        end
    end)
end

AddToggle("ESP Jogadores (RGB)", "ESP_Players", function(state)
    ESPPlayers_Active = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            BindESPForPlayer(player)
        end
        Players.PlayerAdded:Connect(function(player)
            BindESPForPlayer(player)
            if player.Character and player.Character:FindFirstChild("Head") then
                SetupESP(player)
            end
        end)
        RefreshAllESP()
    else
        for player, _ in pairs(ESPHighlights) do
            RemoveESP(player)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if ESPPlayers_Active then
        wait(0.5)
        RefreshAllESP()
    end
end)

-- Aimbot
local Aimbot_Active = false
local Aimbot_Distance = 150
local Aimbot_Smoothness = 0.3

local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end
    local origin = char.Head.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = WS:Raycast(origin, direction * distance, params)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function AimbotLoop()
    if not Aimbot_Active then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local closest, closestDist = nil, Aimbot_Distance
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local dist = (head.Position - char.Head.Position).Magnitude
            if dist < closestDist and IsVisible(head) then
                closest = head
                closestDist = dist
            end
        end
    end
    if closest then
        local lookAt = CFrame.lookAt(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, Aimbot_Smoothness)
    end
end

AddToggle("AIMBOT (Visível)", "Aimbot", function(state)
    Aimbot_Active = state
end)

-- AntiLag
local function RemoveHeavyObjects()
    for _, obj in pairs(WS:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local char = player.Character
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Accessory") then v:Destroy() end
            end
            local shirt = char:FindFirstChild("Shirt")
            if shirt then shirt:Destroy() end
            local pants = char:FindFirstChild("Pants")
            if pants then pants:Destroy() end
            local graphic = char:FindFirstChild("ShirtGraphic")
            if graphic then graphic:Destroy() end
            local bodyColors = char:FindFirstChild("BodyColors")
            if bodyColors then bodyColors:Destroy() end
        end
    end
    if WS:FindFirstChild("Atmosphere") then WS.Atmosphere:Destroy() end
    if WS:FindFirstChild("Sky") then WS.Sky:Destroy() end
    game:GetService("Lighting"):ClearAllChildren()
end

AddToggle("ANTI LAG", "AntiLag", function(state)
    if state then
        RemoveHeavyObjects()
    end
end)

-- ================== LOOPS ==================
RS.Heartbeat:Connect(function()
    if ESPPlayers_Active then
        UpdateESPColor()
    end
    if Aimbot_Active then
        AimbotLoop()
    end
    if HealthBar_Active then
        HealthBarLoop()
    end
end)
