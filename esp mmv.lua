-- > الخدمات الأساسية < --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local originalSheriff = nil
local gunDropped = false

-- > دالة تفعيل كشف القاتل (تأخذ شكل جسمه 3D بدقة وبدون أي مكعبات) < --
local function createRedDot(character)
    local tracker = character:FindFirstChild("MurdererESP_Tracker")
    if not tracker then
        local hl = Instance.new("Highlight")
        hl.Name = "MurdererESP_Tracker"
        hl.FillColor = Color3.fromRGB(255, 0, 0)         -- لون أحمر نيون داخل الجسم
        hl.FillTransparency = 0.25                       -- شفافية لتحديد معالم الجسم
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)   -- إطار أبيض يحدد أبعاد الشكل ثلاثي الأبعاد
        hl.OutlineTransparency = 0                        -- إطار واضح جداً
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- يضمن الظهور عند الاختفاء وخلف الجدران
        hl.Parent = character
    end
end

-- > دالة حذف كشف القاتل < --
local function removeRedDot(character)
    local tracker = character:FindFirstChild("MurdererESP_Tracker")
    if tracker then
        tracker:Destroy()
    end
end

-- > كشف الفخاخ (Traps) < --
local function highlightTraps()
    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Model") and item ~= LocalPlayer.Character then
            for _, obj in ipairs(item:GetChildren()) do
                local name = obj.Name:lower()
                if name:find("trap") or name:find("bear") then
                    if not obj:FindFirstChild("TrapHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "TrapHighlight"
                        hl.FillColor = Color3.fromRGB(255, 100, 0)
                        hl.FillTransparency = 0.3
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = obj
                    end
                end
            end
        end
    end
end

-- > فحص وجود المسدس على الأرض < --
local function isGunOnGround()
    for _, child in ipairs(Workspace:GetChildren()) do
        local name = child.Name:lower()
        if (name:find("gun") or name:find("revolver")) and not Players:GetPlayerFromCharacter(child) then
            return true
        end
    end
    return false
end

-- > دالة تحديد الدور بدقة < --
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("murderer") or name:find("blade") then
                    return "Murderer"
                elseif name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then
                    return "GunHolder"
                end
            end
        end
        return nil
    end

    local result = checkContainer(backpack) or checkContainer(character)
    
    if result == "Murderer" then
        return "Murderer"
    elseif result == "GunHolder" then
        if gunDropped then
            return "Hero"
        end

        if not originalSheriff then
            originalSheriff = player
            return "Sheriff"
        end

        if player == originalSheriff then
            return "Sheriff"
        else
            return "Hero"
        end
    end

    return "Innocent"
end

-- > تحديث حالة الجولة < --
local function updateGameState()
    if isGunOnGround() then
        gunDropped = true
    end

    local anyGunFound = isGunOnGround()
    if not anyGunFound then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local backpack = p:FindFirstChild("Backpack")
                local char = p.Character
                local function hasTool(cont)
                    if not cont then return false end
                    for _, tool in ipairs(cont:GetChildren()) do
                        if tool:IsA("Tool") then
                            local n = tool.Name:lower()
                            if n:find("gun") or n:find("revolver") or n:find("sheriff") or n:find("pistol") then
                                return true
                            end
                        end
                    end
                    return false
                end
                if hasTool(backpack) or hasTool(char) then
                    anyGunFound = true
                    break
                end
            end
        end
    end

    if not anyGunFound then
        originalSheriff = nil
        gunDropped = false
    end
end

-- > تطبيق الألوان والـ ESP < --
local function applyHighlights()
    updateGameState()
    highlightTraps()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local highlight = char:FindFirstChild("MMV_Highlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "MMV_Highlight"
                        highlight.FillTransparency = 0.4
                        highlight.OutlineTransparency = 0
                        highlight.Parent = char
                    end

                    local role = getRole(player)

                    if role == "Murderer" then
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)     -- أحمر للقاتل
                        createRedDot(char)                                   -- تغطية حمراء ناعمة جداً تتبع شكل الجسم 3D
                    elseif role == "Sheriff" then
                        highlight.FillColor = Color3.fromRGB(0, 150, 255)   -- أزرق للشريف
                        removeRedDot(char)
                    elseif role == "Hero" then
                        highlight.FillColor = Color3.fromRGB(255, 255, 0)   -- أصفر للهيرو
                        removeRedDot(char)
                    else
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)     -- أخضر للمدنيين
                        removeRedDot(char)
                    end
                else
                    if char:FindFirstChild("MMV_Highlight") then
                        char.MMV_Highlight:Destroy()
                    end
                    removeRedDot(char)
                end
            end
        end
    end
end

-- > الحلقة الرئيسية < --
task.spawn(function()
    while true do
        applyHighlights()
        task.wait(0.3)
    end
end)
