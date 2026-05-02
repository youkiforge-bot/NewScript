--[[
    ZAKY HUB - FINAL BOSS EDITION (ESP, AIMBOT, ANTILAG)
    GUI arrastável, minimizável, confirmação ao fechar.
]]

-- Serviços
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Limpeza
if CoreGui:FindFirstChild("ZakyFinalBoss") then
    CoreGui.ZakyFinalBoss:Destroy()
end

-- Interface
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyFinalBoss"
Screen.ResetOnSpawn = false

-- Função de arraste (funciona tanto expandido quanto minimizado)
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

-- Janela principal
local Main = Instance.new("Frame", Screen)
Main.Name = "Main"
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.3, 0)
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

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)

-- Popup de confirmação
local Confirm = Instance.new("Frame", Screen)
Confirm.Size = UDim2.new(0, 250, 0, 120)
Confirm.Position = UDim2.new(0.5, -125, 0.4, 0)
Confirm.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Confirm.Visible = false
Confirm.ZIndex = 10
Confirm.BorderSizePixel = 0
Instance.new("UICorner", Confirm)
local s2 = Instance.new("UIStroke", Confirm)
s2.Color = Color3.new(1, 1, 1)
s2.Thickness = 1.5

local Msg = Instance.new("TextLabel", Confirm)
Msg.Size = UDim2.new(1, 0, 0, 50)
Msg.Text = "REALMENTE DESEJA SAIR?"
Msg.TextColor3 = Color3.new(1, 1, 1)
Msg.BackgroundTransparency = 1
Msg.Font = Enum.Font.GothamBold
Msg.TextSize = 14
Msg.BorderSizePixel = 0

local Yes = Instance.new("TextButton", Confirm)
Yes.Size = UDim2.new(0, 100, 0, 40)
Yes.Position = UDim2.new(0, 20, 0, 60)
Yes.Text = "SIM"
Yes.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Yes.TextColor3 = Color3.new(1, 1, 1)
Yes.BorderSizePixel = 0
Instance.new("UICorner", Yes)

local No = Instance.new("TextButton", Confirm)
No.Size = UDim2.new(0, 100, 0, 40)
No.Position = UDim2.new(1, -120, 0, 60)
No.Text = "NÃO"
No.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
No.TextColor3 = Color3.new(1, 1, 1)
No.BorderSizePixel = 0
Instance.new("UICorner", No)

CloseBtn.MouseButton1Click:Connect(function()
    Confirm.Visible = true
end)
No.MouseButton1Click:Connect(function()
    Confirm.Visible = false
end)
Yes.MouseButton1Click:Connect(function()
    Screen:Destroy()
end)

-- Container com rolagem
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

-- Função para criar Toggle
local function AddToggle(text, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "OFF | " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(255, 0, 80) or Color3.fromRGB(30, 30, 35)
        btn.Text = (active and "ON" or "OFF") .. " | " .. text
        callback(active)
    end)
end

-- ================== ESP ==================
-- Armazena os Highlights/Billboards criados
local ESPHighlights = {}
local ESPBills = {}
local ESP_Enabled = false

local function UpdateESPColor()
    -- Cores RGB em ciclo (arco-íris)
    local hue = (tick() * 100) % 255  -- velocidade do ciclo
    local color = Color3.fromHSV(hue/255, 1, 1)
    for _, hl in pairs(ESPHighlights) do
        if hl and hl.Parent then
            hl.FillColor = color
        end
    end
end

local function SetupESP(player)
    if ESPBills[player] and ESPHighlights[player] then return end
    local char = player.Character
    if not char then return end
    -- Highlight ao redor do corpo
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.Parent = char
    ESPHighlights[player] = hl

    -- Billboard com o nome
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_Name"
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
    bill.Parent = char:WaitForChild("Head", 5)
    ESPBills[player] = bill
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

local function RefreshAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("Head") then
                SetupESP(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if EPS_Enabled and player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            SetupESP(player)
        end)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ================== AIMBOT ==================
local Aimbot_Enabled = false
local Aimbot_Distance = 150  -- studs
local Aimbot_Smoothness = 0.3 -- 0 a 1 (quanto menor, mais suave)

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = WS:Raycast(origin, direction * distance, params)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function AimbotLoop()
    if not Aimbot_Enabled then return end
    local closest, closestDist = nil, Aimbot_Distance
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local dist = (head.Position - Camera.CFrame.Position).Magnitude
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

-- ================== ANTILAG ==================
local function RemoveHeavyObjects()
    -- Remove texturas e decalques
    for _, obj in pairs(WS:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""   -- remove textura de malhas especiais
        end
    end
    -- Remove roupas/acessórios de todos os personagens (incluindo o local)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local char = player.Character
            -- Remove acessórios (chapéus, óculos, etc.)
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Accessory") then
                    v:Destroy()
                end
            end
            -- Remove as roupas (Shirt, Pants, ShirtGraphic)
            local shirt = char:FindFirstChild("Shirt")
            if shirt then shirt:Destroy() end
            local pants = char:FindFirstChild("Pants")
            if pants then pants:Destroy() end
            local graphic = char:FindFirstChild("ShirtGraphic")
            if graphic then graphic:Destroy() end
            -- Remove qualquer BodyColors
            local bodyColors = char:FindFirstChild("BodyColors")
            if bodyColors then bodyColors:Destroy() end
        end
    end
    -- Remove neblina e efeitos atmosféricos
    if WS:FindFirstChild("Atmosphere") then WS.Atmosphere:Destroy() end
    if WS:FindFirstChild("Sky") then WS.Sky:Destroy() end
    game:GetService("Lighting"):ClearAllChildren()  -- remove efeitos de luz pós-processamento
end

-- Conectar toggles da UI
AddToggle("ESP (Nomes + RGB)", function(state)
    ESP_Enabled = state
    if state then
        RefreshAllESP()
    else
        for player, _ in pairs(ESPHighlights) do
            RemoveESP(player)
        end
    end
end)

AddToggle("AIMBOT (Visível / Próximo)", function(state)
    Aimbot_Enabled = state
end)

AddToggle("ANTI LAG (Remove decorações pesadas)", function(state)
    if state then
        RemoveHeavyObjects()
        -- Desliga automaticamente o toggle após execução (não dá para reverter)
        -- (Opcional: pode deixar ligado, mas sem efeito visual)
    end
end)

-- Loops
RS.Heartbeat:Connect(function()
    if ESP_Enabled then
        UpdateESPColor()
    end
    if Aimbot_Enabled then
        AimbotLoop()
    end
end)

-- Reaplicar ESP quando um personagem novo surgir
LocalPlayer.CharacterAdded:Connect(function(char)
    if ESP_Enabled then
        wait(1) -- aguardar carregar
        RefreshAllESP()
    end
end)
