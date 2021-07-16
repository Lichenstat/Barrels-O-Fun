
AddCSLuaFile()
include("barrels_o_fun_genfuncs.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."
ENT.PrintName = "Barrel O Fun (Freeze)"
ENT.Information = "Explosive barrel that creates a frozen explosive barrel when destroyed (until touched or explosive knocks it)"

ENT.Category = "Barrels O Fun"
ENT.Spawnable = true
ENT.AdminOnly = false

--print("---BOF (Freeze) initialized---")

if (SERVER) then

    ENT:GenericBarrelSpawnFunction()

    function ENT:Initialize()
        --self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:SetNoDraw(true)

        -- Call to create freeze barrel
        self.FrozenBarrel = self:CreateFrozenBarrel()
    end

    -- Create an explosive barrel that will freeze after explosion
    function ENT:CreateFrozenBarrel()
        local expbarrel = self:CreateExplosiveBarrel(self:GetPos(), self:GetAngles())
        expbarrel:SetRenderMode(RENDERMODE_TRANSCOLOR)
        -- On destruction of explosive barrel respawn explosive barrel at last location and angle
        -- and freeze it until something interacts with it
        expbarrel:CallOnRemove("ThisBarrelDupe_01x", function()
            self:SetPos(self.FrozenBarrel:GetPos())
            self:SetAngles(self.FrozenBarrel:GetAngles())
            local bofproptable = self:GetBarrelProperties(self.FrozenBarrel)
            timer.Simple(.1, function()
                if(self:IsValid()) then 
                    self.FrozenBarrel = self:CreateFrozenBarrel()
                    self:SetBarrelProperties(self.FrozenBarrel, bofproptable)
                    self.FrozenBarrel:GetPhysicsObject():Sleep()
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
