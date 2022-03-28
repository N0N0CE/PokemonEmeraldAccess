Utils = {}

function Utils.ifelse(condition, ifcase, elsecase)
	if condition then
		return ifcase
	else
		return elsecase
	end
end

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1 ,d)
end

function Utils.gettop(a)
	return bit.rshift(a, 16)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a,0,16)
	local c = Utils.getbits(a,16,16)
	return b + c
end

function Utils.mult32(a, b)
	local c = bit.rshift(a, 16)
	local d = a % 0x10000
	local e = bit.rshift(b, 16)
	local f = b % 0x10000
	local g = (c*f + d*e) % 0x10000
	local h = d*f
	local i = g*0x10000 + h
	return i
end

function Utils.rngDecrease(a)
	return (Utils.mult32(a,0xEEB9EB65) + 0x0A3561A1) % 0x100000000
end

function Utils.rngAdvance(a)
	return (Utils.mult32(a, 0x41C64E6D) + 0x6073) % 0x100000000
end

function Utils.rngAdvanceMulti(a, n) -- TODO, use tables to make this in O(logn) time
	for i = 1, n, 1 do
		a = (Utils.mult32(a, 0x41C64E6D) + 0x6073) % 0x100000000
	end
	return a
end

function Utils.rng2Advance(a)
	return (Utils.mult32(a, 0x41C64E6D) + 0x3039) % 0x100000000
end

function Utils.getRNGDistance(b,a)
    local distseed = 0
    for j=0,31,1 do
		if Utils.getbits(a,j,1) ~= Utils.getbits(b,j,1) then
			b = Utils.mult32(b, RNGData.multspa[j+1])+ RNGData.multspb[j+1]
			distseed = distseed + bit.lshift(1, j)
			if j == 31 then
				distseed = distseed + 0x100000000
			end
		end
    end
	return distseed
end

function Utils.tohex(a)
	local mystr = bizstring.hex(a)
	while string.len(mystr) < 8 do
		mystr = "0" .. mystr
	end
	return mystr
end

function Utils.getNatureColor(stat, nature)
	local color = "white"
	if nature % 6 == 0 then
		color = "white"
	elseif stat == "atk" then
		if nature < 5 then
			color = 0xFF00FF00
		elseif nature % 5 == 0 then
			color = "red"
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			color = 0xFF00FF00
		elseif nature % 5 == 1 then
			color = "red"
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			color = 0xFF00FF00
		elseif nature % 5 == 2 then
			color = "red"
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			color = 0xFF00FF00
		elseif nature % 5 == 3 then
			color = "red"
		end
	elseif stat == "spd" then
		if nature > 19 then
			color = 0xFF00FF00
		elseif nature % 5 == 4 then
			color = "red"
		end
	end
	return color
end

function Utils.getTableValueIndex(myvalue, mytable)
	for i=1,table.getn(mytable),1 do
		if myvalue == mytable[i] then
			return i
		end
	end
	return 1
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function clear_last_4_bits(var)
	var = bit.clear(var,12)
	var = bit.clear(var,13)
	var = bit.clear(var,14)
	var = bit.clear(var,15)
	return var
end

function set_bit(var,bit_number,bit_value)
	local bit = Utils.getbits(var, bit_number, 1)
	--debug_print(bit)
	
	local value_to_change = 2^bit_number
	if bit == 1 and bit_value == 0 then		
		var = var - value_to_change
	elseif bit == 0 and bit_value == 1 then
		var = var + value_to_change
	end
	return var
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function debug_print(str)
	if access_settings.debuging == 1 then
		console.write(str)
	end
end

function try_concat(t)
	local str = ""
	for k,v in pairs(t) do
		if v == nil then return " "
		else
			str = str .. v
		end
	end

	return str
end

function get_gender(personality,specie)
	debug_print("specie: " .. PokemonData.name[specie] )
	console.write(string.char(10))	
	local gender_ratio = PokemonData.gender_ratio[specie] --Memory.read(0x8321324+specie*0x20+0x10,1)

	debug_print("gender_ratio: " .. gender_ratio)
	console.write(string.char(10))	
	
	if gender_ratio == 0x00 then return "male"
	elseif gender_ratio == 0xFE then return "female"
	elseif gender_ratio == 0xFF then return "genderless"
	end
	
	if gender_ratio > bit.band(personality,0xFF) then return "female" else return "male" end
end

function is_shiny(tid,sid,personality)
	local lp = Utils.getbits(personality, 0, 16)
	local hp = Utils.getbits(personality, 16, 16)
	
	local shiny_value = bit.bor(bit.bor(bit.bor(sid,tid),hp),lp)
	
	if shiny_value < 8 then return true else return false end

end

function write_byte_table(p,t)
	for i=1,#t,1 do
		memory.writebyte(p+i-1, t[i],"System Bus") 
	end
end

function is_in_boundary(xt,yt,x1,y1,x2,y2)
	if xt >= x1 and xt <= x2 and yt >= y1 and yt <= y2 then return true else return false end
end

function get_string_at_adress(addr)
	local str = ""
	local chr = "@"
	local i = 0
	while(1) do
		if i > 1024 then break end
		local value = memory.read_u8(addr+i)--memory.readbyte(addr+i,"System Bus") --Memory.read(addr+i,1)	
		if value == 0xFF then break end
		
		--byte_array[i] = value
		
		chr = chars[value]		
		if chr == nil then chr = ",".. value.."," end
		if (chr == "?" and value ~= 0xAC) then chr = ",".. value.."," end
		--if chr == 0xFC then i = i+1 end 
		
		str = str .. chr
		i = i + 1
	end
	return str --.. "Size:" .. i
end