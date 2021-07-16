
AddCSLuaFile()
include("barrels_o_fun_genfuncs.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."
ENT.PrintName = "Barrel O Fun (Random)"
ENT.Information = "Explosive barrel that creates another explosive barrel with random forces when destroyed"

ENT.Category = "Barrels O Fun"
ENT.Spawnable = true
ENT.AdminOnly = false

--print("---BOF (Random) initialized---")

if (SERVER) then

    ENT:GenericBarrelSpawnFunction()

    function ENT:Initialize()
        --self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:SetNoDraw(true)

        -- Call to create random barrel
        self.RandomBarrel = self:CreateRandomBarrel()
    end

    -- Function to create an explosive barrel with a randomly generated velocity 
    function ENT:CreateRandomBarrel()
        local expbarrel = self:CreateExplosiveBarrel(self:GetPos(), self:GetAngles())
        expbarrel:SetRenderMode(RENDERMODE_TRANSCOLOR)
        -- On destruction of explosive barrel respawn explosive barrel at last location and angle
        -- as well as apply random forces
        expbarrel:CallOnRemove("ThisBarrelDupe_01x", function()
            self:SetPos(self.RandomBarrel:GetPos())
            self:SetAngles(self.RandomBarrel:GetAngles())
            local bofproptable = self:GetBarrelProperties(self.RandomBarrel)
            timer.Simple(.1, function()
                if(self:IsValid()) then
                    self.RandomBarrel = self:CreateRandomBarrel()
                    self:SetBarrelProperties(self.RandomBarrel, bofproptable)
                    self:ApplyRandomBarrelVelocity(self.RandomBarrel)
                end
            end)
        end)
        -- On removal of entity, get rid of explosive barrel
        self:CallOnRemove("ThisBarrelDupe_02x", function()
            if(expbarrel:IsValid()) then
                expbarrel:RemoveCallOnRemove("ThisBarrelDupe_01x") 
                expbarrel:Remove()
            end 
        end)
        return expbarrel
    end

end
