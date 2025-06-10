-- ESP Togglebar Version
if _G.ESP_RUNNING then
    _G.ESP_ENABLED = not _G.ESP_ENABLED
    print("ESP toggled:", _G.ESP_ENABLED)
    return
end

_G.ESP_RUNNING = true
_G.ESP_ENABLED = true
print("ESP gestartet")

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera     = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local boxes = {}

local function createBox(player)
    local box = Drawing.new("Square")
    box.Visible      = false
    box.Thickness    = 2
    box.Transparency = 1
    box.Filled       = false
    box.Color        = Color3.new(1, 0, 0)
    boxes[player] = box
end

local function removeBox(player)
    if boxes[player] then
        boxes[player]:Remove()
        boxes[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        createBox(player)
    end)
    player.CharacterRemoving:Connect(function()
        removeBox(player)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            createBox(player)
        end
        player.CharacterAdded:Connect(function()
            createBox(player)
        end)
        player.CharacterRemoving:Connect(function()
            removeBox(player)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not _G.ESP_ENABLED then
        for _, box in pairs(boxes) do
            box.Visible = false
        end
        return
    end

    for player, box in pairs(boxes) do
        local char = player.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
            local head = char.Head
            local root = char.HumanoidRootPart
            local headPos, headVis = camera:WorldToViewportPoint(head.Position)
            local rootPos, rootVis = camera:WorldToViewportPoint(root.Position)

            if headVis and rootVis then
                local baseHeight = math.abs(headPos.Y - rootPos.Y)
                local verticalScale = 4
                local height = baseHeight * verticalScale
                local width  = baseHeight * 3
                local extraTop = (height - baseHeight) / 4

                box.Size     = Vector2.new(width, height)
                box.Position = Vector2.new(headPos.X - width/2, headPos.Y - extraTop)
                box.Visible  = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)
