-- Configuration & Target Animations set directly according to AOEX framework
local SelectedAnims = {
    ["Idle"] = {"10921230744", "10921232093"}, -- Oldschool Idle (Animation1 & Animation2)
    ["Walk"] = "707897309",                   -- Mage Walk
    ["Run"]  = "10921148209",                 -- Mage Run/Dance
    ["Jump"] = "10921242013",                 -- Oldschool Jump
    ["Fall"] = "782846423",                   -- Toy Fall
    ["Climb"]= "10921229866"                  -- Oldschool Climb
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function applyAOEXAnimations(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local animate = character:WaitForChild("Animate", 10)
    if not humanoid or not animate then return end

    -- Helper to safely update Animation Object IDs inside the Animate script tree
    local function updateAnim(folderName, animName, id)
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local animObj = folder:FindFirstChild(animName)
            if animObj and animObj:IsA("Animation") then
                animObj.AnimationId = "rbxassetid://" .. tostring(id)
            end
        end
    end

    -- Apply Idle
    updateAnim("idle", "Animation1", SelectedAnims["Idle"][1])
    updateAnim("idle", "Animation2", SelectedAnims["Idle"][2])

    -- Apply Walk
    updateAnim("walk", "RunAnim", SelectedAnims["Walk"])

    -- Apply Run
    updateAnim("run", "RunAnim", SelectedAnims["Run"])

    -- Apply Jump
    updateAnim("jump", "JumpAnim", SelectedAnims["Jump"])

    -- Apply Fall
    updateAnim("fall", "FallAnim", SelectedAnims["Fall"])

    -- Apply Climb
    updateAnim("climb", "ClimbAnim", SelectedAnims["Climb"])
end

-- Execute on current character
if player.Character then
    task.spawn(applyAOEXAnimations, player.Character)
end

-- Auto re-apply seamlessly on respawn
player.CharacterAdded:Connect(applyAOEXAnimations)
