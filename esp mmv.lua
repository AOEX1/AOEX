-- > الخدمات < --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local originalSheriff = nil
local gunDropped = false

-- > دالة فحص الأدوار < --
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
        -- إذا لم يكن هناك شريف أصلي مسجل، نعتبر أول حامل للمسدس هو الشريف الأصلي
        if not originalSheriff or not originalSheriff.Parent then
            originalSheriff = player
            return "Sheriff"
        end

        -- إذا كان الحامل هو نفس الشريف الأصلي ولم يسقط المسدس
        if player == originalSheriff and not gunDropped then
            return "Sheriff"
        else
            -- أي شخص آخر يحمل المسدس (أو الشريف إذا أخذ المسدس بعد سقوطه) يصبح هيرو
            return "Hero"
        end
    end

    return "Innocent"
end

-- > متابعة المسدس الساقط في الخريطة < --
local function checkWorldGun()
    -- البحث عن المسدس الساقط في الـ Workspace
    local workspaceGun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun")
    if workspaceGun then
        gunDropped = true
    end
end

-- > إعادة ضبط الجولة عند انتهاء الأسلحة < --
local function checkRoundReset()
    local anyGunFound = false
    
    -- فحص اللاعبين
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local bp = p:FindFirstChild("Backpack")
            local function hasGun(cont)
                if not cont then return false end
                for _, item in ipairs(cont:GetChildren()) do
                    if item:IsA("Tool") then
                        local n = item.Name:lower()
                        if n:find("gun") or n:find("revolver") or n:find("sheriff") or n:find("pistol") then
                            return true
                        end
                    end
                end
                return false
            end
            if hasGun(bp) or hasGun(p.Character) then
                anyGunFound = true
                break
            end
        end
    end

    -- فحص الأرض
    if workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun") then
        anyGunFound = true
    end

    -- إذا اختفت كل الأسلحة (انتهاء الجولة)، يتم التصفير
    if not anyGunFound then
        originalSheriff = nil
        gunDropped = false
    end
end

-- > تطبيق الـ Highlights < --
local function applyHighlights()
    checkWorldGun()
    checkRoundReset()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local highlight = char:FindFirstChild("MMV_Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "MMV_Highlight"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                end

                local role = getRole(player)

                if role == "Murderer" then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)     -- أحمر للمجرم
                elseif role == "Sheriff" then
                    highlight.FillColor = Color3.fromRGB(0, 150, 255)   -- أزرق للشريف الأصلي
                elseif role == "Hero" then
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)   -- أصفر للهيرو
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)     -- أخضر للمدنيين
                end
            else
                if char:FindFirstChild("MMV_Highlight") then
                    char.MMV_Highlight:Destroy()
                end
            end
        end
    end
end

-- > التشغيل الحلقي < --
task.spawn(function()
    while true do
        applyHighlights()
        task.wait(0.2)
    end
end)
