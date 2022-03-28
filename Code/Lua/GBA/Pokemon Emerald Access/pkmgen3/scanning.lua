function create_scan_object(scan_func)
	
	local scan_object = {
		values = {},
		old_values = {},
		change_values = {},
	}
	
	scan_object.scan_func = scan_func
	
	scan_func(scan_object.values)
	
	local function create_nested_tables(vt,ovt,cvt)
		for k, v in pairs(vt) do
			if type(v) == "table" then
				ovt[k] = {}
				cvt[k] = {}
				
				create_nested_tables(v,ovt[k],cvt[k])
			end			
		end
	end
	
	create_nested_tables(scan_object.values,scan_object.old_values,scan_object.change_values)
	

		
	return scan_object
end

function change_table_update(t,old_t,change_t)
	local function is_changed(t,old_t,change_t)
		for k, v in pairs(t) do
			if type(v) == "table" then
				is_changed(v,old_t[k],change_t[k])
			else
				if v ~= old_t[k] then 
					change_t[k] = 1 
				else
					change_t[k] = 0
				end
			end	
		end		
	end

	--zero(change_t)
	is_changed(t,old_t,change_t)

end

function scan(scan_object)

	
	if scan_object.old_values ~= nil then scan_object.old_values = shallowcopy(scan_object.values) end

	scan_object.scan_func(scan_object.values)
	
	if scan_object.old_values == nil then 
		scan_object.old_values = shallowcopy(scan_object.values) 
		--debug_print("old value init")
		--debug_print(string.char(10))	
	end

	change_table_update(scan_object.values,scan_object.old_values,scan_object.change_values)
	
end


function tiles_scan_func(values)
	--[[
	local tiles_adresses = {
		 dialog = {value = 0x600fb80, size =  2},
		 intro_dialog = {value = 0x600f380, size =  2},
	}

	for k, v in pairs(tiles_adresses) do
		values[k] = Memory.read(v.value, v.size)
	end ]]
	
	values.dialog = memory.read_u16_le(0x600fb80)
	values.intro_dialog = memory.read_u16_le(0x600f380)

end
tiles = create_scan_object(tiles_scan_func)

function ingame_keyboard_scan_func(values)

	values.sNamingScreen_ptr = Memory.read(0x2039f94, 4) 
	values.y = Memory.read(0x02020664, 1)
	values.x = Memory.read(0x02020662, 1)
	values.page = Memory.read(values.sNamingScreen_ptr+0x1e22, 1)
	
	--values.sNamingScreen = Memory.read(sNamingScreen_ptr, v.size)
end
ingame_keyboard = create_scan_object(ingame_keyboard_scan_func)

function misc_scan_func(values)
		
	values.x = memory.read_u16_le(0x2037364)
	values.y = memory.read_u16_le(0x2037366)
	values.x_new = memory.read_u16_le(0x2037350 + 0x10)
	values.y_new = memory.read_u16_le(0x2037350 + 0x12)
	
	if bit.band(2, memory.read_u8(0x30026f9)) ~= 0 then values.inBattle = 1 else values.inBattle = 0 end

	values.map_name = PokemonData.map[Memory.readbyte(GameSettings.mapid) + 1]
	values.dialog_active = memory.read_u8(0x20201b0+27)
	values.dialog_state = memory.read_u8(0x20201b0+28)

	values.callback1 = memory.read_u32_le(0x30022c0)
	values.callback2 = memory.read_u32_le(0x30022c0+4)
	values.party_slotId = memory.read_u8(0x203ced1)
	values.party_slotId2 = memory.read_u8(0x203ced2)
	values.avatar_flags = memory.read_u8(0x2037590)
	values.runningState = memory.read_u8(0x2037590+3)
	values.avatar_oe_id = memory.read_u8(0x2037590+5)
	values.bike_speed = memory.read_u8(0x2037590+0xb)
	values.metatile = memory.read_u8(0x2037350+0x1e+values.avatar_oe_id*0x24)
	values.region_map = memory.read_u32_le(0x203a144)
	values.rm_x = memory.read_u16_le(values.region_map+0x54)
	values.rm_y = memory.read_u16_le(values.region_map+0x56)
	values.fly_map = memory.read_u32_le(0x203a148+12)
	values.fm_x = memory.read_u16_le(values.fly_map+9+0x54)
	values.fm_y = memory.read_u16_le(values.fly_map+9+0x56)
	values.gMapHeader = memory.read_u32_le(0x2037318)
	--values.old_printer_string = old_printer_string
end
misc = create_scan_object(misc_scan_func)


function object_events_scan_func(values)
	local gObjectEvents=0x2037350
	local map_events = memory.read_u32_le(0x2037318 + 0x04) --Memory.read(0x2037318 + 0x04, 4)
	values.count = 16 --Memory.read(map_events, 1)
	local oe_size = 0x24
	local recount = 0

	for i=0,15,1 do
		
		local pos_x = memory.read_u8(gObjectEvents+i*oe_size+0x10) --Memory.read(gObjectEvents+i*oe_size+0x10, 1)
		local pos_y = memory.read_u8(gObjectEvents+i*oe_size+0x12) --Memory.read(gObjectEvents+i*oe_size+0x12, 1)
		
		if pos_x == 0 and pos_y == 0 and recount == 0 then 
			values.count = i
			recount = 1
		end
		
		values[i] = {}
		
		local flags =  memory.read_u32_le(gObjectEvents+i*oe_size) --Memory.read(gObjectEvents+i*oe_size, 4)
		values[i].active = Utils.getbits(flags, 0, 1)
		--if values[i].active == 0 then goto continue end
		values[i].invisible = Utils.getbits(flags, 13, 1)
		
		values[i].graphicsId = memory.read_u8(gObjectEvents+i*oe_size+0x05) --Memory.read(gObjectEvents+i*oe_size+0x05, 1)
		values[i].pos_x = pos_x
		values[i].pos_y = pos_y
		
		local move_flags = memory.read_u16_le(gObjectEvents+i*oe_size+0x18) --Memory.read(gObjectEvents+i*oe_size+0x18, 2)
		values[i].facingDirection = Utils.getbits(move_flags, 0, 4)
		--::continue::
	end
end
object_events = create_scan_object(object_events_scan_func)

function joy_state_scan_func(values)
	local v = joypad.get()
	
	values["A"] = v["A"]
	values["B"] = v["B"]
	values["Up"] = v["Up"]
	values["Down"] = v["Down"]
	values["Left"] = v["Left"]
	values["Right"] = v["Right"]
	values["L"] = v["L"]
	values["R"] = v["R"]
	
end
joy_state = create_scan_object(joy_state_scan_func)

function main_menu_scan_func(values)
	values.cursor = memory.read_u8(0x03005e0a)
	values.menu_type = memory.read_u8(0x03005e08)
end
main_menu = create_scan_object(main_menu_scan_func)

function bag_scan_func(values)
	values.pocket = memory.read_u8(0x203ce58+5)
	local p = values.pocket
	values.pos = memory.read_u16_le(0x203ce58+8+p*2) + memory.read_u16_le(0x203ce58+8+10+p*2)
	local ListBuffer2_ptr = Memory.read(0x203ce78, 4)
	values.name = get_string_at_adress(ListBuffer2_ptr+values.pos*24)
	--bag_name = get_data_string_at_adress(ListBuffer2_ptr+bag_position.pos*24,true)
end
bag = create_scan_object(bag_scan_func)
