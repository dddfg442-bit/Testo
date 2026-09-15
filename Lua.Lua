--// ========== PREMIUM GODMODE UI ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// ========== НАСТРОЙКИ ==========
local CONFIG = {
    Accent      = Color3.fromRGB(140, 90, 255),  -- фиолетовый
    Accent2     = Color3.fromRGB(80, 200, 255),  -- голубой
    Danger      = Color3.fromRGB(255, 70, 90),   -- красный
    Success     = Color3.fromRGB(80, 255, 150),  -- зелёный
    BG          = Color3.fromRGB(14, 14, 20),
    BG2         = Color3.fromRGB(22, 22, 32),
}

local godmodeActive = false
local godmodeConn = nil

--// ========== УВЕДОМЛЕНИЯ ==========
local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "NotifyGui"
notifyGui.ResetOnSpawn = false
notifyGui.IgnoreGuiInset = true
notifyGui.DisplayOrder = 9999
notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function notify(text, color)
    color = color or CONFIG.Accent
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 280, 0, 50)
    holder.Position = UDim2.new(0.5, -140, 0, -60)
    holder.BackgroundColor3 = CONFIG.BG2
    holder.BorderSizePixel = 0
    holder.ZIndex = 10000
    holder.Parent = notifyGui

    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0, 12) hc.Parent = holder
    local hs = Instance.new("UIStroke") hs.Color = color hs.Thickness = 1.5 hs.Transparency = 0.3 hs.Parent = holder

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 4, 1, -12)
    line.Position = UDim2.new(0, 6, 0, 6)
    line.BackgroundColor3 = color
    line.BorderSizePixel = 0
    line.ZIndex = 10001
    line.Parent = holder
    local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(1, 0) lc.Parent = line

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 10001
    lbl.Parent = holder

    -- Анимация въезда
    TweenService:Create(holder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0, 20)
    }):Play()

    task.delay(2.5, function()
        local tw = TweenService:Create(holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -140, 0, -60),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function() holder:Destroy() end)
    end)
end

--// ========== ГЛАВНЫЙ GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumGodMode"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// ========== КНОПКА ОТКРЫТИЯ (пульсирующая) ==========
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 60)
openBtn.Position = UDim2.new(0, 15, 0, 100)
openBtn.BackgroundColor3 = CONFIG.Accent
openBtn.Text = "⚡"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 30
openBtn.Active = true
openBtn.Selectable = true
openBtn.AutoButtonColor = false
openBtn.ZIndex = 500
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner") openCorner.CornerRadius = UDim.new(1, 0) openCorner.Parent = openBtn
local openGrad = Instance.new("UIGradient")
openGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.Accent2)
}
openGrad.Rotation = 45
openGrad.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(255, 255, 255)
openStroke.Thickness = 2
openStroke.Transparency = 0.5
openStroke.Parent = openBtn

-- Пульсация кнопки открытия
task.spawn(function()
    while openBtn.Parent do
        TweenService:Create(openStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Transparency = 0.1}):Play()
        task.wait(1.2)
        TweenService:Create(openStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Transparency = 0.7}):Play()
        task.wait(1.2)
    end
end)

--// ========== МЕНЮ ==========
local panelW, panelH = 320, 400

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, panelW, 0, panelH)
mainFrame.Position = UDim2.new(0.5, -panelW/2, 0.5, -panelH/2)
mainFrame.BackgroundColor3 = CONFIG.BG
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 400
mainFrame.Parent = screenGui

local mfc = Instance.new("UICorner") mfc.CornerRadius = UDim.new(0, 18) mfc.Parent = mainFrame

local mfs = Instance.new("UIStroke")
mfs.Color = CONFIG.Accent
mfs.Thickness = 1.5
mfs.Transparency = 0.4
mfs.Parent = mainFrame

-- Градиентный фон
local mfGrad = Instance.new("UIGradient")
mfGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.BG),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 18, 45))
}
mfGrad.Rotation = 135
mfGrad.Parent = mainFrame

--// Верхняя светящаяся полоса
local glowBar = Instance.new("Frame")
glowBar.Size = UDim2.new(1, -40, 0, 3)
glowBar.Position = UDim2.new(0, 20, 0, 0)
glowBar.BackgroundColor3 = CONFIG.Accent
glowBar.BorderSizePixel = 0
glowBar.ZIndex = 401
glowBar.Parent = mainFrame
local gbc = Instance.new("UICorner") gbc.CornerRadius = UDim.new(1, 0) gbc.Parent = glowBar
local gbGrad = Instance.new("UIGradient")
gbGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(0.5, CONFIG.Accent2),
    ColorSequenceKeypoint.new(1, CONFIG.Accent)
}
gbGrad.Parent = glowBar

--// Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1
header.ZIndex = 402
header.Parent = mainFrame

-- Иконка
local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0, 40, 0, 40)
iconFrame.Position = UDim2.new(0, 18, 0, 12)
iconFrame.BackgroundColor3 = CONFIG.Accent
iconFrame.BorderSizePixel = 0
iconFrame.ZIndex = 403
iconFrame.Parent = header
local ifc = Instance.new("UICorner") ifc.CornerRadius = UDim.new(0, 10) ifc.Parent = iconFrame
local ifg = Instance.new("UIGradient")
ifg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, CONFIG.Accent), ColorSequenceKeypoint.new(1, CONFIG.Accent2)}
ifg.Rotation = 45
ifg.Parent = iconFrame

local iconTxt = Instance.new("TextLabel")
iconTxt.Size = UDim2.new(1, 0, 1, 0)
iconTxt.BackgroundTransparency = 1
iconTxt.Text = "⚡"
iconTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
iconTxt.Font = Enum.Font.GothamBold
iconTxt.TextSize = 22
iconTxt.ZIndex = 404
iconTxt.Parent = iconFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 22)
title.Position = UDim2.new(0, 68, 0, 12)
title.BackgroundTransparency = 1
title.Text = "GOD MODE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 403
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -100, 0, 16)
subtitle.Position = UDim2.new(0, 68, 0, 33)
subtitle.BackgroundTransparency = 1
subtitle.Text = "premium edition"
subtitle.TextColor3 = CONFIG.Accent2
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 403
subtitle.Parent = header

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -46, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 35)
closeBtn.Text = "✖"
closeBtn.TextColor3 = CONFIG.Danger
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Active = true
closeBtn.Selectable = true
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 403
closeBtn.Parent = header
local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0, 8) cbc.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Danger}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 25, 35)}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = CONFIG.Danger}):Play()
end)

--// Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -36, 0, 1)
divider.Position = UDim2.new(0, 18, 0, 62)
divider.BackgroundColor3 = Color3.fromRGB(60, 50, 90)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.ZIndex = 402
divider.Parent = mainFrame

--// Статус
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -36, 0, 44)
statusFrame.Position = UDim2.new(0, 18, 0, 78)
statusFrame.BackgroundColor3 = CONFIG.BG2
statusFrame.BorderSizePixel = 0
statusFrame.ZIndex = 402
statusFrame.Parent = mainFrame
local sfc = Instance.new("UICorner") sfc.CornerRadius = UDim.new(0, 12) sfc.Parent = statusFrame
local sfs = Instance.new("UIStroke") sfs.Color = Color3.fromRGB(60, 50, 90) sfs.Thickness = 1 sfs.Transparency = 0.5 sfs.Parent = statusFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = CONFIG.Danger
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 403
statusDot.Parent = statusFrame
local sdc = Instance.new("UICorner") sdc.CornerRadius = UDim.new(1, 0) sdc.Parent = statusDot

local statusTxt = Instance.new("TextLabel")
statusTxt.Size = UDim2.new(1, -40, 1, 0)
statusTxt.Position = UDim2.new(0, 34, 0, 0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "Бессмертие: ВЫКЛ"
statusTxt.TextColor3 = Color3.fromRGB(220, 220, 230)
statusTxt.Font = Enum.Font.GothamBold
statusTxt.TextSize = 13
statusTxt.TextXAlignment = Enum.TextXAlignment.Left
statusTxt.ZIndex = 403
statusTxt.Parent = statusFrame

--// ========== БОЛЬШАЯ КНОПКА GODMODE ==========
local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(1, -36, 0, 70)
godBtn.Position = UDim2.new(0, 18, 0, 138)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
godBtn.Text = ""
godBtn.Active = true
godBtn.Selectable = true
godBtn.AutoButtonColor = false
godBtn.ZIndex = 402
godBtn.Parent = mainFrame

local gbc2 = Instance.new("UICorner") gbc2.CornerRadius = UDim.new(0, 14) gbc2.Parent = godBtn

local godGrad = Instance.new("UIGradient")
godGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 40, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 90, 150))
}
godGrad.Rotation = 45
godGrad.Parent = godBtn

local godStroke = Instance.new("UIStroke")
godStroke.Color = CONFIG.Accent
godStroke.Thickness = 2
godStroke.Transparency = 0.3
godStroke.Parent = godBtn

local godIcon = Instance.new("TextLabel")
godIcon.Size = UDim2.new(0, 50, 1, 0)
godIcon.Position = UDim2.new(0, 6, 0, 0)
godIcon.BackgroundTransparency = 1
godIcon.Text = "🛡️"
godIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
godIcon.Font = Enum.Font.GothamBold
godIcon.TextSize = 28
godIcon.ZIndex = 403
godIcon.Parent = godBtn

local godTitle = Instance.new("TextLabel")
godTitle.Size = UDim2.new(1, -70, 0, 26)
godTitle.Position = UDim2.new(0, 60, 0, 12)
godTitle.BackgroundTransparency = 1
godTitle.Text = "ВКЛЮЧИТЬ БЕССМЕРТИЕ"
godTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
godTitle.Font = Enum.Font.GothamBold
godTitle.TextSize = 14
godTitle.TextXAlignment = Enum.TextXAlignment.Left
godTitle.ZIndex = 403
godTitle.Parent = godBtn

local godSub = Instance.new("TextLabel")
godSub.Size = UDim2.new(1, -70, 0, 18)
godSub.Position = UDim2.new(0, 60, 0, 36)
godSub.BackgroundTransparency = 1
godSub.Text = "GodMode ON"
godSub.TextColor3 = CONFIG.Accent2
godSub.Font = Enum.Font.Gotham
godSub.TextSize = 11
godSub.TextXAlignment = Enum.TextXAlignment.Left
godSub.ZIndex = 403
godSub.Parent = godBtn

-- Наведение
godBtn.MouseEnter:Connect(function()
    TweenService:Create(godStroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
end)
godBtn.MouseLeave:Connect(function()
    TweenService:Create(godStroke, TweenInfo.new(0.2), {Transparency = 0.3, Thickness = 2}):Play()
end)

--// ========== БОЛЬШАЯ КНОПКА STOP ==========
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, -36, 0, 70)
stopBtn.Position = UDim2.new(0, 18, 0, 220)
stopBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
stopBtn.Text = ""
stopBtn.Active = true
stopBtn.Selectable = true
stopBtn.AutoButtonColor = false
stopBtn.ZIndex = 402
stopBtn.Parent = mainFrame

local sbc = Instance.new("UICorner") sbc.CornerRadius = UDim.new(0, 14) sbc.Parent = stopBtn

local stopGrad = Instance.new("UIGradient")
stopGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 20, 30))
}
stopGrad.Rotation = 45
stopGrad.Parent = stopBtn

local stopStroke = Instance.new("UIStroke")
stopStroke.Color = CONFIG.Danger
stopStroke.Thickness = 2
stopStroke.Transparency = 0.3
stopStroke.Parent = stopBtn

local stopIcon = Instance.new("TextLabel")
stopIcon.Size = UDim2.new(0, 50, 1, 0)
stopIcon.Position = UDim2.new(0, 6, 0, 0)
stopIcon.BackgroundTransparency = 1
stopIcon.Text = "⛔"
stopIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
stopIcon.Font = Enum.Font.GothamBold
stopIcon.TextSize = 26
stopIcon.ZIndex = 403
stopIcon.Parent = stopBtn

local stopTitle = Instance.new("TextLabel")
stopTitle.Size = UDim2.new(1, -70, 0, 26)
stopTitle.Position = UDim2.new(0, 60, 0, 12)
stopTitle.BackgroundTransparency = 1
stopTitle.Text = "ОСТАНОВИТЬ"
stopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stopTitle.Font = Enum.Font.GothamBold
stopTitle.TextSize = 14
stopTitle.TextXAlignment = Enum.TextXAlignment.Left
stopTitle.ZIndex = 403
stopTitle.Parent = stopBtn

local stopSub = Instance.new("TextLabel")
stopSub.Size = UDim2.new(1, -70, 0, 18)
stopSub.Position = UDim2.new(0, 60, 0, 36)
stopSub.BackgroundTransparency = 1
stopSub.Text = "Отключить всё"
stopSub.TextColor3 = Color3.fromRGB(255, 150, 160)
stopSub.Font = Enum.Font.Gotham
stopSub.TextSize = 11
stopSub.TextXAlignment = Enum.TextXAlignment.Left
stopSub.ZIndex = 403
stopSub.Parent = stopBtn

stopBtn.MouseEnter:Connect(function()
    TweenService:Create(stopStroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2.5}):Play()
end)
stopBtn.MouseLeave:Connect(function()
    TweenService:Create(stopStroke, TweenInfo.new(0.2), {Transparency = 0.3, Thickness = 2}):Play()
end)

--// Футер
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -36, 0, 20)
footer.Position = UDim2.new(0, 18, 1, -32)
footer.BackgroundTransparency = 1
footer.Text = "premium • v1.0"
footer.TextColor3 = Color3.fromRGB(100, 100, 130)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 402
footer.Parent = mainFrame

--// ========== GODMODE ЛОГИКА ==========
local function enableGodmode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.MaxHealth = math.huge
    hum.Health = math.huge
    hum.BreakJointsOnDeath = false

    -- Защита от падения
    local function onHealthChanged()
        if godmodeActive and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end
    godmodeConn = hum.HealthChanged:Connect(onHealthChanged)
end

local function disableGodmode()
    if godmodeConn then
        godmodeConn:Disconnect()
        godmodeConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            if hum.Health > 100 then hum.Health = 100 end
        end
    end
end

local function setGodmodeState(state)
    godmodeActive = state
    if state then
        enableGodmode(LocalPlayer.Character)
        statusTxt.Text = "Бессмертие: ВКЛ"
        statusDot.BackgroundColor3 = CONFIG.Success
        TweenService:Create(statusDot, TweenInfo.new(0.3), {}):Play()
        godTitle.Text = "БЕССМЕРТИЕ ВКЛЮЧЕНО"
        godBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
        godGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 80, 120))
        }
        godStroke.Color = CONFIG.Success
        notify("🛡️ Бессмертие включено", CONFIG.Success)
    else
        disableGodmode()
        statusTxt.Text = "Бессмертие: ВЫКЛ"
        statusDot.BackgroundColor3 = CONFIG.Danger
        godTitle.Text = "ВКЛЮЧИТЬ БЕССМЕРТИЕ"
        godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        godGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 40, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 90, 150))
        }
        godStroke.Color = CONFIG.Accent
    end
end

godBtn.MouseButton1Click:Connect(function()
    setGodmodeState(not godmodeActive)
    -- Анимация нажатия
    TweenService:Create(godBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, -40, 0, 66)}):Play()
    task.wait(0.1)
    TweenService:Create(godBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, -36, 0, 70)}):Play()
end)

stopBtn.MouseButton1Click:Connect(function()
    setGodmodeState(false)
    notify("⛔ Всё остановлено", CONFIG.Danger)
    TweenService:Create(stopBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, -40, 0, 66)}):Play()
    task.wait(0.1)
    TweenService:Create(stopBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, -36, 0, 70)}):Play()
end)

--// Авто-восстановление при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if godmodeActive then enableGodmode(char) end
end)

--// ========== КНОПКИ ОТКРЫТИЯ ==========
local isOpen = false
openBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, panelW, 0, 0)
        mainFrame.BackgroundTransparency = 1
        TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, panelW, 0, panelH),
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(openBtn, TweenInfo.new(0.2), {Rotation = 135}):Play()
    else
        local tw = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, panelW, 0, 0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            mainFrame.Visible = false
        end)
        TweenService:Create(openBtn, TweenInfo.new(0.2), {Rotation = 0}):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if isOpen then openBtn.MouseButton1Click:Fire() end
end)

-- Горячая клавиша для ПК
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        openBtn.MouseButton1Click:Fire()
    end
end)

notify("⚡ Premium GodMode загружен", CONFIG.Accent)
