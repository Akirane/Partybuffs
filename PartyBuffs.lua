--[[Copyright © 2017, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PartyBuffs nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'PartyBuffs'
_addon.author = 'Kenshi, Akirane'
_addon.version = '3.0'
_addon.commands = {'pb', 'partybuffs'}

images = require('images')
texts = require('texts')
packets = require('packets')
config = require('config')
require('pack')
require('tables')
require('filters')

defaults = {}
defaults.size = 20
defaults.important_bar = {
	x=math.floor(windower.get_windower_settings().ui_x_res*0.33),
	y=math.floor(windower.get_windower_settings().ui_y_res*0.95), 
	is_enabled=true
}
defaults.mode = 'whitelist'

settings = config.load(defaults)

aliases = T{
    w            = 'whitelist',
    wlist        = 'whitelist',
    white        = 'whitelist',
    whitelist    = 'whitelist',
    b            = 'blacklist',
    blist        = 'blacklist',
    black        = 'blacklist',
    blacklist    = 'blacklist'
}

alias_strs = aliases:keyset()

local ready = false
local time_modulus = 30
local frame_counter = 0
local current_job = "init"

local icon_size = (settings.size == 20 or defaults.size == 20) and 20 or 10
local important_icon_size = 20
local party_buffs = {'p1', 'p2', 'p3', 'p4', 'p5'}
local self_buffs_images = {}
local important_buffs_images = {}
local important_buffs_label = {}
local timer_buffs = {}
local old_self_buffs = {}
local self_y_pos = windower.get_windower_settings().ui_y_res - 5
local important_y_pos = windower.get_windower_settings().ui_y_res - settings.important_bar.y
local important_x_pos = windower.get_windower_settings().ui_x_res - settings.important_bar.x
local old_party_count = 1
local current_packet = {}
do
    local x_pos = windower.get_windower_settings().ui_x_res - 190
    for x = 1, 10 do 
        self_buffs_images[x] = images.new({
            color = {
                alpha = 255
            },
            texture = {
                fit = false
            },
            draggable = false,
        })
    end
    for x = 1, 32 do 
        important_buffs_label[x] = texts.new({
			flags = {bold=true,draggable=false},
			bg = {visible=false},
			text = {
				size = 10,
				alpha = 185,
				stroke={width=2,alpha=255,red=0,green=0,blue=0}
			}
        })
    end
    for x = 1, 32 do 
        important_buffs_images[x] = images.new({
            color = {
                alpha = 255
            },
            texture = {
                fit = false
            },
            draggable = false,
        })
    end
    for k = 1, 5 do
        party_buffs[k] = T{}
        
        for i = 1, 32 do
            party_buffs[k][i] = images.new({
                color = {
                    alpha = 255
                },
                texture = {
                    fit = false
                },
                draggable = false,
            })
        end
    end
end

local member_table = S{nil, nil, nil, nil, nil}

buffs = T{}
buffs['whitelist'] = {}
buffs['blacklist'] = {}
job_dict = L{'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN'}
-- self_buffs = T{}
-- self_buffs['whitelist'] = {}

windower.register_event('job change',function(main_job)
	current_job = job_dict[main_job]
end)

windower.register_event('login', 'load', function()
    if windower.ffxi.get_player() ~= nil then
        current_job = windower.ffxi.get_player().main_job
    end
end)

windower.register_event('incoming chunk', function(id, data)

    if id == 0x0DD then
        local packet = packets.parse('incoming', data)
        
        if not member_table:contains(packet['Name']) then
            member_table:append(packet['Name'])
            member_table[packet['Name']] = packet['ID']
        end
        coroutine.schedule(buff_sort, 0.5)
    end

    if id == 0x063 then
        if data:byte(0x05) == 0x09 then
			local new_buffs = {}
			timer_buffs = {}
            for i= 1,32 do 
                local buff_id = data:unpack('H', i*2+7)
                if buff_id ~= 255 and buff_id ~= 0 then --255 "no buff"
                    new_buffs[#new_buffs+1] = buff_id
					if settings.important_bar.is_enabled then
						if important_buffs[current_job]:contains(buff_id) then 
							timer_buffs[#timer_buffs+1] = {}
							timer_buffs[table.getn(timer_buffs)]['id'] = buff_id
							timer_buffs[table.getn(timer_buffs)]['timer'] = math.floor((data:unpack('I', 33*2+7+((i-1)*4))/60)+ 572662306 + 1009810800)
						end
					end
                end
            end
            self_buff_sort(new_buffs)
			important_buff_sort(timer_buffs)
        end
    end
    
    if id == 0x076 then
        for  k = 0, 4 do
            local id = data:unpack('I', k*48+5)
            buffs['whitelist'][id] = {}
			buffs['blacklist'][id] = {}
            
            if id ~= 0 then
                for i = 1, 32 do
                    local buff = data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) -- Credit: Byrth, GearSwap
                    if buffs['whitelist'][id][i] ~= buff then
                        buffs['whitelist'][id][i] = buff
                    end
					if buffs['blacklist'][id][i] ~= buff then
                        buffs['blacklist'][id][i] = buff
                    end
                end
            end
        end
        buff_sort()
    end
    
    if id == 0xB then
        zoning_bool = true
        buff_sort()
    elseif id == 0xA and zoning_bool then
        zoning_bool = false
        coroutine.schedule(buff_sort, 10)
    end
end)

local x_pos = windower.get_windower_settings().ui_x_res - 185
local party_buffs_y_pos = {}
for i = 2, 6 do
    local y_pos = windower.get_windower_settings().ui_y_res - 5
    party_buffs_y_pos[i] = y_pos - 20 * i
end

function buff_sort()
    local player = windower.ffxi.get_player()
    local party = windower.ffxi.get_party()
    local key_indices = {'p1', 'p2', 'p3', 'p4', 'p5'}
    
    if not player then return end
    
    for k = 1, 5 do
        local member = party[key_indices[k]]
        for i = 1, 32 do
            if member then
                if buffs[settings.mode][member_table[member.name]] and buffs[settings.mode][member_table[member.name]][i] then
                    -- blaclist or whitelist
                    if buffs[settings.mode][member_table[member.name]][i] == 255 then
                        buffs[settings.mode][member_table[member.name]][i] = 1000
                    elseif blacklist[player.main_job] and blacklist[player.main_job]:contains(buffs['blacklist'][member_table[member.name]][i]) then
                        buffs['blacklist'][member_table[member.name]][i] = 1000
                    elseif whitelist and not whitelist:contains(buffs['whitelist'][member_table[member.name]][i]) then
                        buffs['whitelist'][member_table[member.name]][i] = 1000
                    end
                end
            end
        end
        if member and buffs[settings.mode][member_table[member.name]] then
			table.sort(buffs['blacklist'][member_table[member.name]])
			table.sort(buffs['whitelist'][member_table[member.name]])
		end
    end
	Update(buffs[settings.mode])
end

function self_buff_sort(buff_table)
    local self_buffs = {}
    for i, buff in ipairs(buff_table) do 
        if buff_table[i] == nil then 
            self_buffs[#self_buffs+1] = 1000
        elseif whitelist:contains(buff_table[i]) then
            self_buffs[#self_buffs+1] = buff_table[i]
        else
            self_buffs[#self_buffs+1] = 1000
        end
    end
    table.sort(self_buffs)
    if check_if_equal(self_buffs, old_self_buffs) == false then
        old_self_buffs = self_buffs
        self_update(self_buffs)
    else 
        return
    end
end

function important_buff_sort(buff_table)
    for i=1 ,#buff_table, 1 do 
        if buff_table[i]['id'] == nil then 
            buff_table[i]['id'] = 1000
        end
    end
    --important_update(buff_table)
end

function check_if_equal(new_buffs, old_buffs)
    return table.concat(new_buffs) == table.concat(old_buffs)
end

windower.register_event('prerender', function()

	local party = T(windower.ffxi.get_party())
	local party_count = party.party1_count
	if old_party_count ~= party_count then
		self_update(old_self_buffs)
	end
	frame_counter = frame_counter +1
	if (math.mod(frame_counter, time_modulus) == 0 and settings.important_bar.is_enabled) then
		important_update(timer_buffs)
		frame_counter = 0
	end
end)

function self_update(buff_table)
    local party_info = windower.ffxi.get_party_info()
    for i=1,10 do 
        if buff_table[i] == 1000 or buff_table[i] == nil then 
            self_buffs_images[i]:clear()
            self_buffs_images[i]:hide()
        else
            self_buffs_images[i]:path(windower.windower_path .. 'addons/PartyBuffs/icons/' .. buff_table[i] .. '.png')
            self_buffs_images[i]:transparency(0)
            self_buffs_images[i]:size(icon_size, icon_size)
            local y =  self_y_pos - 20*(party_info.party1_count + 1)
            local x =  x_pos - (i*20)
            self_buffs_images[i]:pos_y(y)
            self_buffs_images[i]:pos_x(x)
            self_buffs_images[i]:show()
        end
    end
end
function important_update(buff_table)

	local cur_time = os.time()
    for i=1,#buff_table,1 do 
		local duration = buff_table[i]['timer'] - cur_time
        if buff_table[i]['id'] == 1000 or buff_table[i]['id'] == nil then 
            important_buffs_images[i]:clear()
            important_buffs_images[i]:hide()
			important_buffs_label[i]:hide()
        else
            local y =  important_y_pos
            local x =  important_x_pos - (i*30)
            important_buffs_images[i]:path(windower.windower_path .. 'addons/PartyBuffs/icons/' .. buff_table[i]['id'] .. '.png')
            important_buffs_images[i]:transparency(0)
            important_buffs_images[i]:size(important_icon_size, important_icon_size)
            important_buffs_images[i]:pos_y(y)
            important_buffs_images[i]:pos_x(x)
            important_buffs_images[i]:show()

			-- Labels
            local text_y =  important_y_pos + 25 
            local text_x =  important_x_pos - (i*30)
			important_buffs_label[i]:text(get_duration(duration))
            important_buffs_images[i]:size(important_icon_size + 5, important_icon_size +5)
			important_buffs_label[i]:pos_y(text_y)
			important_buffs_label[i]:pos_x(text_x)
			important_buffs_label[i]:show()
        end
    end
    for i=#buff_table+1,32,1 do 
		important_buffs_images[i]:clear()
		important_buffs_images[i]:hide()
		important_buffs_label[i]:hide()
	end

end

function get_duration(timer)
	if timer >= 3600 then 
		return string.format("%dh", math.floor(timer/3600))
	elseif timer >= 60 then 
		return string.format("%dm", math.floor(timer/60))
	elseif timer >= 0 then 
		return string.format("%ds", timer)
	end
end

function Update(buff_table)
    local party_info = windower.ffxi.get_party_info()
    local zone = windower.ffxi.get_info().zone
    local party = windower.ffxi.get_party()
    local key_indices = {'p1', 'p2', 'p3', 'p4', 'p5'}
   
    for k = 1, 5 do
        local member = party[key_indices[k]]
        
        for image, i in party_buffs[k]:it() do
            if member then
                if buff_table[member_table[member.name]] and buff_table[member_table[member.name]][i] then
                    if zoning_bool or member.zone ~= zone or buff_table[member_table[member.name]][i] == 1000 then
                        buff_table[member_table[member.name]][i] = 1000
                        image:clear()
                        image:hide()
                    elseif buff_table[member_table[member.name]][i] == 255 or buff_table[member_table[member.name]][i] == 0 then
                        image:clear()
                        image:hide()
                    else            
                        image:path(windower.windower_path .. 'addons/PartyBuffs/icons/' .. buff_table[member_table[member.name]][i] .. '.png')
                        image:transparency(0)
                        image:size(icon_size, icon_size)
                        -- Adjust position for party member count
                        if party_info.party1_count > 1 then
                            local pt_y_pos = party_buffs_y_pos[party_info.party1_count] 
                            local x = (icon_size == 20 and x_pos - (i*20)) or (i <= 16 and x_pos - (i*10)) or x_pos - ((i-16)*10)
                            local y = (icon_size == 20 and pt_y_pos + ((k-1)*20)) or (i <= 16 and pt_y_pos + ((k-1)*20)) or  pt_y_pos + (((k-1)*20)+10)
                            image:pos_x(x)
                            image:pos_y(y)
                        end
                        image:show()
                    end
                end
            else
                image:clear()
                image:hide()
            end
            image:update()
        end
    end
    
end

function clear_important_buffs()
    for i=1,32,1 do 
		important_buffs_images[i]:clear()
		important_buffs_images[i]:hide()
		important_buffs_label[i]:hide()
	end
end

windower.register_event('load', function() --Create member table if addon is loaded while already in pt
    if not windower.ffxi.get_info().logged_in then return end
    
    local party = windower.ffxi.get_party()
    local key_indices = {'p1', 'p2', 'p3', 'p4', 'p5'}
    
    for k = 1, 5 do
        local member = party[key_indices[k]]
        
        if member and member.mob then
            if not member.mob.is_npc and not member_table:contains(member.name) then
                member_table[k] = member.name
                member_table[member.name] = member.mob.id
            end
        end
    end
end)

windower.register_event('addon command', function(...)
    local args = T{...}
    local command = args[1] and args[1]:lower()
	local number_match = "%d+"
	local on_match = T{'1', 'on', 'true'}
	local off_match = T{'0', 'off', 'false'}
    if command then
		if command == 'important' then
			if args[2] == 'toggle' then
				local is_enabled = ""
				settings.important_bar.is_enabled = not settings.important_bar.is_enabled
				if (settings.important_bar.is_enabled) then is_enabled = "ON" end
				if (not settings.important_bar.is_enabled) then 
					is_enabled = "OFF" 
					clear_important_buffs()
				end
				settings:save()
				windower.add_to_chat(207,string.format("Important buffs bar is now set to: %s", is_enabled))
			elseif args[2] == 'offset' then 
				if not args[4] then
					windower.add_to_chat(207,"Need X and Y parameters in order to update important buffs position.")
				else 
					settings.important_bar.x = tonumber(string.sub(args[3], string.find(args[3], number_match)))
					settings.important_bar.y = tonumber(string.sub(args[4], string.find(args[4], number_match)))
					important_x_pos = windower.get_windower_settings().ui_x_res - settings.important_bar.x
					important_y_pos = windower.get_windower_settings().ui_y_res - settings.important_bar.y
					windower.add_to_chat(207,string.format("Important buffs location is now [X:%s, Y:%s]", settings.important_bar.x, settings.important_bar.y))
					settings:save()
					important_update(timer_buffs)
				end
			end
        elseif command == 'help' then
            windower.add_to_chat(207,"Partybuffs Commands:")
            windower.add_to_chat(207,"//pb|partybuffs important toggle (toggles the important bar ON/OFF)")
            windower.add_to_chat(207,"//pb|partybuffs important offset x y (sets important offset's right-margin (X) and bottom-margin (Y)")
        end
    else
        windower.add_to_chat(207,"First argument not specified, use size, mode or help.")
    end
end)
