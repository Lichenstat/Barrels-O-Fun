
AddCSLuaFile()
include("barrels_o_fun_genfuncs.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."
ENT.PrintName = "Barrel O Fun (Spawner)"
ENT.Information = "Barrel that spawns another explosive barrel when current explosive barrel is destroyed"

ENT.Category = "Barrels O Fun"
ENT.Spawnable = true
ENT.AdminOnly = false

--print("---BOF (Spawner) initialized---")

if (SERVER) then

    ENT:GenericBarrelSpawnFunction()

    -- Set values for entity barrel
    function ENT:Initialize()
        self:SetModel("models/props_c17/oildrum001.mdl")
        self:SetMaterial("models/wireframe")
        self:SetColor(Color(127, 255, 0))
        self:DrawShadow(false)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self:EnableCustomCollisions(true)
        self:GetPhysicsObject():Wake()
        
        -- Call to create explosive barrel
        self.RespawnBarrel = self:CreateNewBarrel()
    end

    -- Moves entity barrel via blast damage to store velocity and momentum from damage
    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
    end
    
    -- Entity barrel that spawns explosive barrels avoids bullet traces of any form
    function ENT:TestCollision( startpos, delta, isbox, extents, mask )
	    if bit.band( mask, CONTENTS_GRATE ) ~= 0 then return true end
    end

    -- Generic function to stop spawn barrel entity from being copied and pasted to stop erroring
    function ENT:OnEntityCopyTableFinish( data )
        for k, v in pairs( data ) do data[ k ] = nil end
    end

    -- Create a new barrel from the entity barrel and respawn it when it is destroyed
    function ENT:CreateNewBarrel()
        local expbarrel = self:CreateExplosiveBarrel(self:GetPos(), self:GetAngles())
        expbarrel:SetRenderMode(RENDERMODE_TRANSCOLOR)
        constraint.NoCollide(self, expbarrel, 0, 0)
        -- On destruction of explosive barrel respawn explosive barrel at spawn barrel location and angle
        -- as well as apply forces from spawn barrel if any were applied
        expbarrel:CallOnRemove("ThisBarrelDupe_01x", function()
            local bofproptable = self:GetBarrelProperties(self.RespawnBarrel)
            timer.Simple(.1, function()
                if(self:IsValid()) then 
                    self.RespawnBarrel = self:CreateNewBarrel()
                    self:SetBarrelProperties(self.RespawnBarrel, bofproptable)
                    self:ApplyBarrelVelocity(self, self.RespawnBarrel)
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
