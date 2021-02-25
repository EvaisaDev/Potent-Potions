dofile("data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")

materials_potent = {}

for k, v in pairs(actions)do
	if(v.type == ACTION_TYPE_MODIFIER)then
        table.insert(materials_potent, {
            material=string.lower("POTENT_POTIONS_"..v.id.."_LIQUID"),
            cost=500,
        });
    end
end

local old_init = init
function init( entity_id )
	local x,y = EntityGetTransform( entity_id )
	SetRandomSeed( x, y ) -- so that all the potions will be the same in every position with the same seed
    local potion_material = "water"
    
    if(Random(0, 100) < 15)then

        potion_material = random_from_array( materials_potent)
        potion_material = potion_material.material


        -- load the material from VariableStorageComponent
        local components = EntityGetComponent( entity_id, "VariableStorageComponent" )
    
        if( components ~= nil ) then
            for key,comp_id in pairs(components) do 
                local var_name = ComponentGetValue( comp_id, "name" )
                if( var_name == "potion_material") then
                    potion_material = ComponentGetValue( comp_id, "value_string" )
                end
            end
        end
        
        local year,month,day = GameGetDateAndTimeLocal()
        
        if ((( month == 5 ) and ( day == 1 )) or (( month == 4 ) and ( day == 30 ))) and (Random( 0, 100 ) <= 20) then
            potion_material = "sima"
        end
    
        local total_capacity = tonumber( GlobalsGetValue( "EXTRA_POTION_CAPACITY_LEVEL", "1000" ) ) or 1000
        if ( total_capacity > 1000 ) then
            local comp = EntityGetFirstComponentIncludingDisabled( entity_id, "MaterialSuckerComponent" )
                
            if ( comp ~= nil ) then
                ComponentSetValue( comp, "barrel_size", total_capacity )
            end
            
            EntityAddTag( entity_id, "extra_potion_capacity" )
        end
    
        AddMaterialInventoryMaterial( entity_id, potion_material, total_capacity )
    else
        old_init(entity_id)
    end
end