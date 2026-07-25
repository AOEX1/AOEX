local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function applyAnimations(character)
    local animate = character:WaitForChild("Animate", 10)
    if not animate then return end

    local function setAnim(folderName, animName, id)
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. id
            end
        end
    end

    -- 1. وقفة OldSchool
    setAnim("idle", "Animation1", "10921230744")
    setAnim("idle", "Animation2", "10921232093")

    -- 2. المشية Mage
    setAnim("walk", "RunAnim", "707897309")

    -- 3. الجري Mage
    setAnim("run", "RunAnim", "10921148209")

    -- 4. القفزة OldSchool
    setAnim("jump", "JumpAnim", "10921242013")

    -- 5. السقوط Toy
    setAnim("fall", "FallAnim", "782846423")

    -- 6. التسلق OldSchool
    setAnim("climb", "ClimbAnim", "10921229866")

    -- إعادة تنشيط سكربت Animate لتحديث الـ Animator وإظهار الحركة للجميع
    animate.Disabled = true
    task.wait(0.1)
    animate.Disabled = false
end

if player.Character then
    task.spawn(applyAnimations, player.Character)
end

player.CharacterAdded:Connect(applyAnimations)
