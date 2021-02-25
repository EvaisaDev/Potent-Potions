dofile_once("data/scripts/gun/gun_actions.lua")
dofile_once("data/scripts/gun/gun_enums.lua")

active_modifiers = function()
    return EntityGetWithTag("modifier_potion_effect")
end

for k, v in pairs(actions)do
    if(v.type == ACTION_TYPE_MODIFIER)then
        extra_modifiers["POTENT_POTIONS_"..v.id] = function( recursion_level, iteration ) 
            dont_draw_actions = true
            
            v.action( recursion_level, iteration )

            dont_draw_actions = false
        end
    end
end
