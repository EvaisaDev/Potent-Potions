dofile("data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")

materials = {"acid", "magic_liquid_polymorph", "magic_liquid_random_polymorph", "magic_liquid_berserk", "magic_liquid_charm","magic_liquid_movement_faster"}
materials2 = {}

for k, v in pairs(actions)do
	if(v.type == ACTION_TYPE_MODIFIER)then
        table.insert(materials2, string.lower("POTENT_POTIONS_"..v.id.."_LIQUID"));
    end
end

potion_a_materials = function()
	local r_value = Random( 1, 100 )
	if( r_value <= 65 ) then
		r_value = Random( 1, 100 )

		if( r_value <= 10 ) then return "mud" end
		if( r_value <= 20 ) then return "water_swamp" end
		if( r_value <= 30 ) then return "water_salt" end
		if( r_value <= 40 ) then return "swamp" end
		if( r_value <= 50 ) then return "snow" end

		return "water"
	elseif( r_value <= 70 ) then
		return "blood"
	elseif( r_value <= 85 ) then
		r_value = Random( 0, 100 )
		return random_from_array( materials )
	elseif( r_value <= 99 )then
		r_value = Random( 0, 100 )
		return random_from_array( materials2 )
	else
		-- one in a million shot
		r_value = Random( 0, 100000 )
		if( r_value == 666 ) then return "urine" end
		if( r_value == 79 ) then return "gold" end 
		return random_from_array( { "slime", "gunpowder_unstable" } )
	end
end