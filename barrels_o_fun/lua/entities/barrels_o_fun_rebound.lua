
AddCSLuaFile()
include("barrels_o_fun_genfuncs.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."
ENT.PrintName = "Barrel O Fun (Rebound)"
ENT.Information = "Explosive barrel that creates a rebounding explosive barrel when destroyed"

ENT.Category = "Barrels O Fun"
ENT.Spawnable = true
ENT.AdminOnly = false

--print("---BOF (Rebound) initialized---")

if (SERVER) then

    ENT:GenericBarrelSpawnFunction()
    
    -- Entity barrel physics set to clip through player and avoid bullet trace 
    -- only affected by blasts or movement of explosive barrel, as well as attempt to
    -- keep the barrel from clipping through world and props (as much as possible)
    function ENT:Initialize()
        self:SetModel("models/props_c17/oildrum001.mdl")
        self:SetNoDraw(true)
        self:DrawShadow(false)
        self:PhysicsInit(SOLID_CUSTOM)
        self:SetMoveType(MOVETYPE_CUSTOM) -- movetype should be using vphysics, but seems to work better with custom
        self:SetSolid(SOLID_CUSTOM)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        self:GetPhysicsObject():Wake()

        -- Call to create rebound barrel
        self.ReboundBarrel = self:CreateReboundBarrel()
    end

    -- Moves entity barrel via blast damage to store velocity and momentum
    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
    end

    -- Generic function to stop spawn barrel entity from being copied and pasted to stop erroring
    function ENT:OnEntityCopyTableFinish( data )
        for k, v in pairs( data ) do data[ k ] = nil end
    end

    -- Think to set entity barrel location to explosive barrel location (track movement of explosive barrel)
    function ENT:Think()
        self:NextThink(CurTime() + .1)
        if(self.ReboundBarrel:IsValid()) then
        self:SetPos(self.ReboundBarrel:GetPos())
        self:SetAngles(self.ReboundBarrel:GetAngles())
        end
        return true
    end
       
    -- Create generic explosive barrel at entity barrel position
    function ENT:CreateReboundBarrel()
        local expbarrel = self:CreateExplosiveBarrel(self:GetPos(), self:GetAngles())
        expbarrel:SetRenderMode(RENDERMODE_TRANSCOLOR)
        constraint.NoCollide(self, expbarrel, 0, 0)
        -- On destruction of explosive barrel respawn explosive barrel and apply rebound forces
        expbarrel:CallOnRemove("ThisBarrelDupe_01x", function()
            local bofproptable = self:GetBarrelProperties(self.ReboundBarrel)
            timer.Simple(.1, function()
                if(self:IsValid()) then 
                    self.ReboundBarrel = self:CreateReboundBarrel()
                    self:SetBarrelProperties(self.ReboundBarrel, bofproptable)
                    self:ApplyBarrelVelocity(self, self.ReboundBarrel)
                end 
            end)
        end)
        -- On removal of entity barrel, get rid of explosive barrel
        self:CallOnRemove("ThisBarrelDupe_02x", function()
            if(expbarrel:IsValid()) then
                expbarrel:RemoveCallOnRemove("ThisBarrelDupe_01x") 
                expbarrel:Remove()
            end 
        end)
        return expbarrel
    end

end

    --[[ *at first switching positive to negative and vice versa was tried when getting a previous barrel's vector 
         velocity, but it was lacking and seemed to be unreliable in direction and velocity, so think was used to 
        track explosive barrel position using the entity barrel following the explosive barrel running on think.
        When said explosive barrel explodes it applys it's forces unto the entity barrel and the entity barrel
        applies said forces unto the new explosive barrel, thus the rebound. (this is also why rebound barrels 
        cause lag easier due to think and another barrel needed to be used to track the explosive barrel -_-)*
      ]]
