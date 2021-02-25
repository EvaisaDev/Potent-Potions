dofile("data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")

ModLuaFileAppend( "data/scripts/lib/utilities.lua", "mods/modifier_potions/files/scripts/append_utilities.lua" );

dofile_once("mods/modifier_potions/files/scripts/utilities.lua")

local b = bit

local hash = {}

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function hashcode(o)
	local t = type(o)
	if t == 'string' then
		local len = #o
		local h = len
		local step = b.rshift(len, 5) + 1

		for i=len, step, -step do
			h = b.bxor(h, b.lshift(h, 5) + b.rshift(h, 2) + string.byte(o, i))
		end
		return h
	elseif t == 'number' then
		local h = math.floor(o)
		if h ~= o then
			h = b.bxor(o * 0xFFFFFFFF)
		end
		while o > 0xFFFFFFFF do
			o = o / 0xFFFFFFFF
			h = b.bxor(h, o)
		end
		return h
	elseif t == 'bool' then
		return t and 1 or 2
	elseif t == 'table' and o.hashcode then
		local n = o:hashcode()
		assert(math.floor(n) == n, "hashcode is not an integer")
		return n
	end

	return nil
end

function random_argb_string()
	return string.format("%02x%02x%02x%02x", math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
end


ModLuaFileAppend( "data/scripts/gun/gun_extra_modifiers.lua", "mods/modifier_potions/files/scripts/append_extra_modifiers.lua")
ModLuaFileAppend( "data/scripts/status_effects/status_list.lua", "mods/modifier_potions/files/scripts/append_status_effects.lua" );

function string_ends_in_vowel(in_string)
	local vowels = {"a", "e", "i", "o", "u"}

	in_string = string.lower(in_string)
	in_string = trim(in_string)

	local last_character = string.sub(in_string, -1)

	for k, v in pairs(vowels)do
		if(last_character == v)then
			return true
		end
	end
	return false
end

function build_potion_name(in_string)
	SetRandomSeed( math.abs(hashcode(in_string)), math.abs(hashcode(in_string)) )
	if(string_ends_in_vowel(in_string))then
		affixes = {"sia", "sium", "tium"}
		return in_string..affixes[Random(1, #affixes)]
	else
		affixes = {"ium", "ia", "ine"}
		return in_string..affixes[Random(1, #affixes)]
	end
end	

potion_count = 0

dofile("data/scripts/gun/gun.lua")
dofile("data/scripts/gun/gunaction_generated.lua")
dofile("data/scripts/gun/gunshoteffects_generated.lua")

oldEntityLoad = EntityLoad
EntityLoad = function() end
Reflection_RegisterProjectile = function() end
BeginProjectile = function() end
EndProjectile = function() end
RegisterProjectile = function() end
RegisterGunAction = function() end
RegisterGunShotEffects = function() end
BeginTriggerTimer = function() end
BeginTriggerHitWorld = function() end
BeginTriggerDeath = function() end
EndTrigger = function() end
SetProjectileConfigs = function() end
StartReload = function() end
ActionUsesRemainingChanged = function() end
ActionUsed = function() end
LogAction = function() end
OnActionPlayed = function() end
OnNotEnoughManaForAction = function() end
draw_actions = function() end
draw_action = function() end
-- no changes
function OnMagicNumbersAndWorldSeedInitialized()
	local xml2lua = dofile("mods/modifier_potions/lib/xml2lua/xml2lua.lua")
	local handler = dofile("mods/modifier_potions/lib/xml2lua/xmlhandler/tree.lua")


	local parser = xml2lua.parser(handler)
	local modifier_base = ModTextFileGetContent("mods/modifier_potions/files/entities/base_modifier_effect.xml")
	for k, v in pairs(actions)do
		if(v.type == ACTION_TYPE_MODIFIER)then
			--extra_modifiers["POTENT_POTIONS_"..v.id] = v.action

			shot_effects = {}
			c = {}
			ConfigGunActionInfo_Init(c)
			ConfigGunShotEffects_Init(shot_effects)

			c_defaults = {}
			ConfigGunActionInfo_Init(c_defaults)

			dont_draw_actions = true
			reflecting = true
			
			v.action( 1, 1 )

			reflecting = false
			dont_draw_actions = false



		
			
		
			parser:parse(modifier_base)


			for i, p in pairs(handler.root.Entity) do
				if(i == "GameEffectComponent")then
					if(p._attr == nil)then
						p._attr = {}
					end
					if(p._attr ~= nil)then
						p._attr.custom_effect_id = "POTENT_POTIONS_"..v.id
					end
				elseif(i == "ShotEffectComponent")then
					if(p._attr == nil)then
						p._attr = {}
					end
					if(p._attr ~= nil)then
						p._attr.extra_modifier = "POTENT_POTIONS_"..v.id
					end
				end
			end


			
			handler.root.Entity.VariableStorageComponent = {

			}

			handler.root.Entity._attr = {
				name = "POTENT_POTIONS_"..v.id
			}

			for k, v in pairs(c)do
				--if(v ~= c_defaults[k])then
					table.insert(handler.root.Entity.VariableStorageComponent, {
						_attr = {
							name = tostring(k),
							value_string = tostring(v)
						}
					})
				--end
			end
			

			local file_content = xml2lua.toXml(handler.root, "Entity", 0)

			--print(file_content)

			ModTextFileSetContent("mods/modifier_potions/files/entities/status_entities/POTENT_POTIONS_"..v.id..".xml", file_content)

			--print(ModTextFileGetContent("mods/modifier_potions/files/entities/status_entities/POTENT_POTIONS_"..v.id..".xml"))
			
		end
	end

	
	material_base = ModTextFileGetContent("data/materials.xml")

	xml2lua = dofile("mods/modifier_potions/lib/xml2lua/xml2lua.lua")
	handler = dofile("mods/modifier_potions/lib/xml2lua/xmlhandler/tree.lua")


	parser = xml2lua.parser(handler)

	parser:parse(material_base)
	for k, v in pairs(actions)do
		if(v.type == ACTION_TYPE_MODIFIER)then

			
			SetRandomSeed( math.abs(hashcode("POTENT_POTIONS_"..v.id.."_LIQUID")), math.abs(hashcode("POTENT_POTIONS_"..v.id.."_LIQUID")) )

			

			particle_effects = {
				{
					["vel.y"]="17.14",
					["vel_random.min_y"]="-100",
					["vel_random.max_y"]="25.71",
					["lifetime.min"]="0",
					["gravity.y"]="-8.57",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["friction"]="-3.429",
					["probability"]="0.0518",
				},
				{
					["vel.y"]="0",
					["vel_random.min_x"]="-17.43",
					["vel_random.max_x"]="17.43",
					["vel_random.min_y"]="-25.75",
					["vel_random.max_y"]="20",
					["lifetime.min"]="5",
					["lifetime.max"]="10",
					["gravity.y"]="0",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["airflow_force"]="0.474",
					["airflow_scale"]="0.1371",
					["friction"]="3.714",
					["probability"]="0.0857",
					["count.min"]="0",
					["count.max"]="1",
				},
				{
					["vel.y"]="17.14",
					["vel_random.min_x"]="-100",
					["vel_random.max_x"]="25.71",
					["vel_random.min_y"]="-20",
					["vel_random.max_y"]="20",
					["lifetime.min"]="0",
					["lifetime.max"]="0.5",
					["gravity.y"]="-8.57",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["friction"]="-3.429",
					["probability"]="0.0518",
				},
				{
					["vel.y"]="14.28",
					["vel_random.min_x"]="-0.285",
					["vel_random.max_x"]="0.285",
					["vel_random.min_y"]="-11.43",
					["vel_random.max_y"]="11.43",
					["lifetime.min"]="0",
					["lifetime.max"]="20",
					["gravity.y"]="0",
					["render_on_grid"]="1",
					["airflow_force"]="0.1146",
					["airflow_scale"]="-0.028",
					["probability"]="0.018",
					["count.min"]="0"
				},
				{
					["vel.y"]="-2.857",
					["vel_random.min_x"]="-6",
					["vel_random.max_x"]="6",
					["vel_random.min_y"]="-17.18",
					["vel_random.max_y"]="8.914",
					["lifetime.min"]="5",
					["lifetime.max"]="10",
					["gravity.y"]="0",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["airflow_force"]="0.8314",
					["airflow_scale"]="0.1371",
					["friction"]="3.143",
					["probability"]="0.0857",
					["count.min"]="0",
					["count.max"]="1",
				},
				{
					["vel.y"]="0",
					["vel_random.min_x"]="-17.43",
					["vel_random.max_x"]="17.43",
					["vel_random.min_y"]="-45.75",
					["vel_random.max_y"]="40",
					["lifetime.min"]="5",
					["lifetime.max"]="10",
					["gravity.y"]="0",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["airflow_force"]="1.974",
					["airflow_scale"]="0.1371",
					["friction"]="3.714",
					["probability"]="0.0857",
					["count.min"]="0",
					["count.max"]="1",
				},
				{
					["vel.y"]="17.14",
					["vel_random.min_y"]="-31",
					["vel_random.max_y"]="74",
					["lifetime.min"]="0.0285",
					["lifetime.min"]="0.5",
					["gravity.y"]="100",
					["gravity.x"]="-100",
					["render_on_grid"]="1",
					["draw_as_long"]="1",
					["friction"]="5",
					["count_min"]="0",
				},
			}




			table.insert(handler.root.Materials.CellData, {
				_attr = {
					name = string.lower("POTENT_POTIONS_"..v.id.."_LIQUID"),
					ui_name = build_potion_name(GameTextGetTranslatedOrNot(v.name)),
					tags = "[liquid],[water],[magic_liquid]",
					burnable="0",
					density="1.11",
					cell_type="liquid",
					wang_color=random_argb_string(),
					generates_smoke="0",
					liquid_gravity="0.8",
					liquid_sand="0",
					gfx_glow="100",
					on_fire="0",
					requires_oxygen="0",
					liquid_stains="1",
					liquid_sprite_stain_shaken_drop_chance="1",
					audio_materialaudio_type="MAGICAL" ,
					show_in_creative_mode="1",
				},
				ParticleEffect = {
					_attr = particle_effects[Random(1, #particle_effects)]
				},
				Graphics = {
					_attr = {
						color = random_argb_string(),
					}
				},
				StatusEffects = {
					Stains = {
						StatusEffect = {
							_attr = {
								type = "POTENT_POTIONS_"..v.id,
							}
						}
					},
					Ingestion = {
						StatusEffect = {
							_attr = {
								type = "POTENT_POTIONS_"..v.id,
								amount = "0.2"
							}
						}
					}
				}
			})





			---ModMaterialsFileAdd( "mods/modifier_potions/files/POTENT_POTIONS_"..v.id.."_MATERIAL.xml" )

			potion_count = potion_count + 1
		end
	end

	file_content = xml2lua.toXml(handler.root, "Materials", 0)

	ModTextFileSetContent("data/materials.xml", file_content)
	EntityLoad = oldEntityLoad
end
--[[
function OnPlayerSpawned(player)

	dofile("data/scripts/gun/gun_enums.lua")
	dofile("data/scripts/gun/gun_actions.lua")
	dofile("data/scripts/gun/gun.lua")
	dofile("data/scripts/gun/gunaction_generated.lua")
	dofile("data/scripts/gun/gunshoteffects_generated.lua")

	oldEntityLoad = EntityLoad
	EntityLoad = function() end

	Reflection_RegisterProjectile = function() end
	BeginProjectile = function() end
	EndProjectile = function() end
	RegisterProjectile = function() end
	RegisterGunAction = function() end
	RegisterGunShotEffects = function() end
	BeginTriggerTimer = function() end
	BeginTriggerHitWorld = function() end
	BeginTriggerDeath = function() end
	EndTrigger = function() end
	SetProjectileConfigs = function() end
	StartReload = function() end
	ActionUsesRemainingChanged = function() end
	ActionUsed = function() end
	LogAction = function() end
	OnActionPlayed = function() end
	OnNotEnoughManaForAction = function() end
	draw_actions = function() end
	draw_action = function() end


	for k, v in pairs(actions)do

		shot_effects = {}
		c = {}
		ConfigGunActionInfo_Init(c)
		ConfigGunShotEffects_Init(shot_effects)


		dont_draw_actions = true
		reflecting = true
		
		v.action( 1, 1 )

		reflecting = false
		dont_draw_actions = false

	end
		
	EntityLoad = oldEntityLoad
end
]]
ModLuaFileAppend( "data/scripts/items/potion.lua", "mods/modifier_potions/files/scripts/append_potion.lua" );
ModLuaFileAppend( "data/scripts/items/potion_starting.lua", "mods/modifier_potions/files/scripts/append_potion_start.lua" );

