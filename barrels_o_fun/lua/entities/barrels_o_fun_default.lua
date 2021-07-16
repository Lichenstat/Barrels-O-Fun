
AddCSLuaFile()
include("barrels_o_fun_genfuncs.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."
ENT.PrintName = "Barrel O Fun"
ENT.Information = "Explosive barrel that creates another explosive barrel when destroyed"

ENT.Category = "Barrels O Fun"
ENT.Spawnable = true
ENT.AdminOnly = false

--print("---BOF initialized---")

if (SERVER) then

    ENT:DisplayIfBarrelLoaded()

    ENT:GenericBarrelSpawnFunction()

    function ENT:Initialize()
        --self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:SetNoDraw(true)

        -- Call to create default barrel
        self.DefaultBarrel = self:CreateDefaultBarrel()
    end

    -- Create an explosive barrel following velocity path of old explosive barrel
    function ENT:CreateDefaultBarrel()
        local expbarrel = self:CreateExplosiveBarrel(self:GetPos(), self:GetAngles())
        expbarrel:SetRenderMode(RENDERMODE_TRANSCOLOR)
        -- On destruction of explosive barrel respawn explosive barrel at last location and angle
        -- as well as apply forces
        expbarrel:CallOnRemove("ThisBarrelDupe_01x", function()
            self:SetPos(self.DefaultBarrel:GetPos())
            self:SetAngles(self.DefaultBarrel:GetAngles())
            local bofproptable = self:GetBarrelProperties(self.DefaultBarrel)
            local vel = self.DefaultBarrel:GetPhysicsObject():GetVelocity()
            local angvel = self.DefaultBarrel:GetPhysicsObject():GetAngleVelocity()
            timer.Simple(.1, function()
                if(self:IsValid()) then
                    self.DefaultBarrel = self:CreateDefaultBarrel()
                    self:SetBarrelProperties(self.DefaultBarrel, bofproptable)
                    self.DefaultBarrel:GetPhysicsObject():SetVelocity(Vector(vel))
                    self.DefaultBarrel:GetPhysicsObject():AddAngleVelocity(Vector(angvel))
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
