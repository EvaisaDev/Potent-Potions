dofile("data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")
for k, v in pairs(actions)do
	if(v.type == ACTION_TYPE_MODIFIER)then
		table.insert(status_effects, {
			id="POTENT_POTIONS_"..v.id,
			ui_name=v.name,
			ui_description=v.description,
			ui_icon=v.sprite,
			effect_entity="mods/modifier_potions/files/entities/status_entities/".."POTENT_POTIONS_"..v.id..".xml",
		})
	end
end