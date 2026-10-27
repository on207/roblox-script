-- ============================================================
-- 穿墙 / 无限体力 / 变速 / 无限跳（所有人可用）
-- 放在 LocalScript 或执行器中运行
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------
-- 状态
------------------------------------------------------------
local State = {
    Noclip = false,
    InfiniteStamina = false,
    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
}

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

------------------------------------------------------------
-- 穿墙
------------------------------------------------------------
RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

------------------------------------------------------------
-- 无限体力
------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not State.InfiniteStamina then return end
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.JumpPower = State.JumpPower
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("LocalScript") then
                local n = obj.Name:lower()
                if n:find("stamina") or n:find("run") then
                    obj.Disabled = true
                end
            end
        end
    end
end)

------------------------------------------------------------
-- 无限跳
------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if not State.InfiniteJump then return end
    local hum = getHumanoid()
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------------------------------------
-- UI
------------------------------------------------------------
local function createUI()
    local old = LocalPlayer.PlayerGui:FindFirstChild("AuthorTestUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AuthorTestUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 330)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 34)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    title.BorderSizePixel = 0
    title.Text = "测试面板"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Parent = frame

    local function makeToggle(name, y, getState, setState)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 34)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = getState() and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
        btn.BorderSizePixel = 0
        btn.Text = name .. (getState() and "：开" or "：关")
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextScaled = true
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            setState(not getState())
            btn.BackgroundColor3 = getState() and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
            btn.Text = name .. (getState() and "：开" or "：关")
        end)
    end

    makeToggle("穿墙", 46, function() return State.Noclip end, function(v) State.Noclip = v end)
    makeToggle("无限体力", 90, function() return State.InfiniteStamina end, function(v) State.InfiniteStamina = v end)
    makeToggle("无限跳", 134, function() return State.InfiniteJump end, function(v) State.InfiniteJump = v end)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 24)
    speedLabel.Position = UDim2.new(0, 10, 0, 178)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "速度：" .. State.WalkSpeed
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextScaled = true
    speedLabel.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 206)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((State.WalkSpeed - 16) / (500 - 16), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local function updateSliderFromX(x)
        local rel = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local speed = math.floor(16 + rel * (500 - 16))
        State.WalkSpeed = speed
        fill.Size = UDim2.new(rel, 0, 1, 0)
        speedLabel.Text = "速度：" .. speed
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = speed end
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            local dragging = true
            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderFromX(inp.Position.X)
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -36, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextScaled = true
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        gui.Enabled = not gui.Enabled
    end)
end

createUI()
