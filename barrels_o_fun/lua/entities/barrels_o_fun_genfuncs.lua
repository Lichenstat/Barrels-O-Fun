
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Things happen..."

-- Lua file for general function(s) used in all or some of the barrel files
-- *explosive barrels are considered an entity, limited by entity limit, not prop limit*

cleanup.Register("barrels_o_fun")

if (CLIENT) then
    language.Add("Cleanup_barrels_o_fun", "Barrels O Fun")
    language.Add("Cleaned_barrels_o_fun", "Cleaned up all Barrels O Fun")
end

if (SERVER) then
    -- Generic spawn function to create entity 
    function ENT:GenericBarrelSpawnFunction()

        function ENT:SpawnFunction(ply, tr, entitybarrel)
            -- nothing to spawn on, so return
            if (!tr.Hit) then return end 
            
            local SpawnPos = tr.HitPos + tr.HitNormal * 10
            local SpawnAng = ply:EyeAngles()
            SpawnAng.p = 0
            SpawnAng.y = SpawnAng.y + 180

            local entbarrel = ents.Create(entitybarrel)
            entbarrel:SetPos( SpawnPos )
            entbarrel:SetAngles( SpawnAng )
            --entbarrel:SetName(bofentitybarrel)
            entbarrel:Spawn()

            ply:AddCleanup("barrels_o_fun", entbarrel)

            return entbarrel
        end

    end

    -- Creates a generic explosive barrel prop at a desired position and a desired angle
    function ENT:CreateExplosiveBarrel(despos, desang)
        local expbarrel = ents.Create("prop_physics")
        expbarrel:SetPos(despos)
        expbarrel:SetAngles(desang)
        expbarrel:SetModel("models/props_c17/oildrum001_explosive.mdl")
        expbarrel:Spawn()
        --util.SpriteTrail( barrel, 0, Color( 255, 0, 0 ), false, 15, 1, 4, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
        return expbarrel
    end

    -- Applies velocity and momentum from said entity object to said entity object
    function ENT:ApplyBarrelVelocity(froment, toent)
        toent:GetPhysicsObject():SetVelocity(froment:GetPhysicsObject():GetVelocity())
        toent:GetPhysicsObject():AddAngleVelocity(froment:GetPhysicsObject():GetAngleVelocity())
    end

    -- Applies random velocity and momentum to entity object when barrel is blown up (-700 to 700 in this case)
    function ENT:ApplyRandomBarrelVelocity(toent)
        toent:GetPhysicsObject():SetVelocity(VectorRand(-700, 700))
        toent:GetPhysicsObject():AddAngleVelocity(VectorRand(-700, 700))
    end
    
    -- Get a barrel o fun's properties (color, material, physics material, gravity, mass, collison group)
    -- *Was originally going to use duplicator functions for this, but seems to miss some functions and has some unneeded functions* 
    function ENT:GetBarrelProperties(thisbof)
        local bofproperties = {}
        bofproperties[0] = thisbof:GetColor()
        bofproperties[1] = thisbof:GetMaterial()
        bofproperties[2] = thisbof:GetPhysicsObject():GetMaterial()
        bofproperties[3] = thisbof:GetPhysicsObject():IsGravityEnabled()
        bofproperties[4] = thisbof:GetPhysicsObject():GetMass()
        bofproperties[5] = thisbof:GetCollisionGroup()
        return bofproperties
    end

    -- Set barrel o fun's properties using a previous made barrel o fun table on a given barrel
    function ENT:SetBarrelProperties(barrel, thisbofproptable)
        barrel:SetColor(thisbofproptable[0])
        barrel:SetMaterial(thisbofproptable[1])
        barrel:GetPhysicsObject():SetMaterial(thisbofproptable[2])
        barrel:GetPhysicsObject():EnableGravity(thisbofproptable[3])
        barrel:GetPhysicsObject():SetMass(thisbofproptable[4])
        barrel:SetCollisionGroup(thisbofproptable[5])
    end
    
    -- Just to display if barrels loaded in server/client, simple print function call
    function ENT:DisplayIfBarrelLoaded()
        print("Barrels O Fun - Loaded")
    end

end
