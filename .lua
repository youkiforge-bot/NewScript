--[[
    ZAKY HUB - FINAL BOSS EDITION
    - ESP com nomes e highlight RGB (auto‑recria ao renascer)
    - Aimbot suave com raycast (salvo após morte)
    - AntiLag (remove texturas, partículas, roupas)
    - GUI arrastável, minimizável, fecha diretamente
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

-- Limpeza de GUI anterior
if CoreGui:FindFirstChild("ZakyFinalBoss") then
    CoreGui.ZakyFinalBoss:Destroy()
end

-- Cria a interface
local Screen = Instance.new("ScreenGui", CoreGui)
Screen.Name = "ZakyFinalBoss"
Screen.ResetOnSpawn = false   -- sobrevive a renascimentos

-- ========== FUNÇÃO DE ARRASTE ==========
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

-- ========== CONSTRUÇÃO DO HUB ==========
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

-- Botão Fechar (X) – agora fecha direto, sem confirmação
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)

CloseBtn.MouseButton1Click:Connect(function()
    Screen:Destroy()  -- some o hub, mas as funções continuam ativas
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

-- Função genérica para Toggle
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
local ESPHighlights = {}  -- [player] = Highlight
local ESPBills = {}       -- [player] = BillboardGui
local ESP_Enabled = false

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
    -- Remove qualquer ESP antigo antes de criar o novo
    RemoveESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.Parent = char
    ESPHighlights[player] = hl

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
    bill.Parent = char.Head
    ESPBills[player] = bill
end

-- Atualiza todos os jogadores atuais
local function RefreshAllESP()
    if not ESP_Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            SetupESP(player)
        end
    end
end

-- Conecta os eventos de morte/renascimento de cada jogador
local function BindESPForPlayer(player)
    if player == LocalPlayer then return end
    -- Quando o personagem for removido (morreu), limpa o ESP
    player.CharacterRemoving:Connect(function()
        RemoveESP(player)
    end)
    -- Quando um novo personagem aparecer, recria o ESP
    player.CharacterAdded:Connect(function(char)
        if ESP_Enabled then
            -- Espera a cabeça carregar
            char:WaitForChild("Head", 5)
            SetupESP(player)
        end
    end)
end

-- Ativa o sistema ESP
local function EnableESP()
    ESP_Enabled = true
    -- Conecta eventos para todos os jogadores já presentes e futuros
    for _, player in pairs(Players:GetPlayers()) do
        BindESPForPlayer(player)
    end
    Players.PlayerAdded:Connect(function(player)
        if ESP_Enabled then
            BindESPForPlayer(player)
            -- Se o jogador já tiver personagem, cria o ESP imediatamente
            if player.Character and player.Character:FindFirstChild("Head") then
                SetupESP(player)
            end
        end
    end)
    -- Recria para o estado atual
    RefreshAllESP()
end

local function DisableESP()
    ESP_Enabled = false
    for player, _ in pairs(ESPHighlights) do
        RemoveESP(player)
    end
end

-- Recria ESP quando o personagem local renasce (pois o jogo pode recriar do zero)
LocalPlayer.CharacterAdded:Connect(function()
    if ESP_Enabled then
        wait(0.5)
        RefreshAllESP()
    end
end)

-- ================== AIMBOT ==================
local Aimbot_Enabled = false
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
    if not Aimbot_Enabled then return end
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

-- ================== ANTILAG ==================
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
                if v:IsA("Accessory") then
                    v:Destroy()
                end
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

-- ================== TOGGLES ==================
AddToggle("ESP (Nomes + Highlight RGB)", function(state)
    if state then
        EnableESP()
    else
        DisableESP()
    end
end)

AddToggle("AIMBOT (Visível / Próximo)", function(state)
    Aimbot_Enabled = state
end)

AddToggle("ANTI LAG (Remove gráficos pesados)", function(state)
    if state then
        RemoveHeavyObjects()
    end
end)

-- ================== LOOPS ==================
RS.Heartbeat:Connect(function()
    if ESP_Enabled then
        UpdateESPColor()
    end
    if Aimbot_Enabled then
        AimbotLoop()
    end
end)
