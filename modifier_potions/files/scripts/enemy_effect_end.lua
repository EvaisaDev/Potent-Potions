dofile_once("mods/modifier_potions/files/scripts/utilities.lua")

local entity_id = GetUpdatedEntityID()


if(entity_id == nil or entity_id == 0)then
	return
end

local parent_id = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform(entity_id)

if(parent_id == entity_id)then return end


if(EntityHasTag(parent_id, "player_unit"))then
	return
end


dofile("data/scripts/gun/gunaction_generated.lua")



c = {}

c_defaults = {}
ConfigGunActionInfo_Init(c_defaults)

for i, comp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
	name = ComponentGetValue2(comp, "name")
	value = ComponentGetValue2(comp, "value_string")

	c[name] = value
end


--print(table.dump(c))


if EntityHasFlag(parent_id, "modified_potion"..EntityGetName(entity_id)) then
	EntityRemoveFlag(parent_id, "modified_potion"..EntityGetName(entity_id))
	
	if tonumber(c.fire_rate_wait) > 0 and tonumber(c.reload_time) > 0 then
		attack_speed_adjust = math.max(c.fire_rate_wait, c.reload_time)
	elseif tonumber(c.fire_rate_wait) < 0 and tonumber(c.reload_time) < 0 then
		attack_speed_adjust = math.min(c.fire_rate_wait, c.reload_time)
	else
		attack_speed_adjust = c.fire_rate_wait + c.reload_time
	end
	
	for i, animal_ai_comp in ipairs(EntityGetComponent(parent_id, "AnimalAIComponent") or {}) do
		default_attack_speed = ComponentGetValue2(animal_ai_comp, "attack_ranged_frames_between")
		ComponentSetValue2(animal_ai_comp, "attack_ranged_frames_between", default_attack_speed - attack_speed_adjust)
	end

	for i, ai_attack_comp in ipairs(EntityGetComponent(parent_id, "AIAttackComponent") or {}) do
		default_attack_speed = ComponentGetValue2(ai_attack_comp, "frames_between")
		ComponentSetValue2(ai_attack_comp, "frames_between", default_attack_speed - attack_speed_adjust)
		ComponentSetValue2(ai_attack_comp, "frames_between_global", default_attack_speed - attack_speed_adjust)
	end
end