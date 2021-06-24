--[[
        Name: auto-nick.lua
      Author: Brian Ferguson
     Website: https://github.com/brianferguson/hexchat-scripts/
        Date: 2021.06.24
     Version: 1.1
     License: CC BY-NC-SA 4.0  https://creativecommons.org/licenses/by-nc-sa/4.0/
 Description: This regains your preferred nick when logging onto a server.
    Platform: Hexchat 2.14.3
     Network: freenode#rainmeter (brian), Libera.Chat#rainmeter (brian)
]]

local script_name = "auto-nick.lua"
local script_version = "1.1"
local script_description = "Automatically regains your preferred nick"

hexchat.register(script_name, script_version, script_description)

local function on_join_autonick(word, eol)
	--[[ word:
			1: account ("brian!~brian@unaffiliated/brian")
			2: cmd ("JOIN")
			3: channel ("#channel")
			4: nick ("brian") - Seems to be a registered nick or "*"
			5: client (":http://webchat.freenode.net") or "real name"
	]]

	-- Debug
--[[
	hexchat.print("word[1]: " .. word[1])
	hexchat.print("word[2]: " .. word[2])
	hexchat.print("word[3]: " .. word[3])
	hexchat.print("word[4]: " .. word[4])
	hexchat.print("word[5]: " .. word[5])
	hexchat.print("eol[1]: " .. eol[1])
]]

	local server = hexchat.get_info("server")
	if server == nil then
--		hexchat.print("Server Error 1: Cannot get server name")
		return hexchat.EAT_NONE
	end

	local accounts = {
		  freenode = { user = "brian"    , nick = "brian" },
		  libera =   { user = "bferguson", nick = "_brian"}
	}

	local user_name = nil
	local pref_nick = nil

	for k,v in pairs(accounts) do
		if server:find(k) then
			user_name = v["user"]
			pref_nick = v["nick"]
			break
		end
	end

	if user_name == nil or pref_nick == nil then
--		hexchat.print("Server Debug 1: Could not find account information")
		return hexchat.EAT_NONE
	end

--[[
	The "JOIN" command is executed for every person that joins a channel.
	The following code only need to be executed for "you", so compare
	the "joined" nick with your own preferred nick.
]]
	local curr_nick = hexchat.get_info("nick")

	if hexchat.nickcmp(word[4], user_name) == 0 then
		if hexchat.nickcmp(curr_nick, pref_nick) ~= 0 then
--			hexchat.print("Debug: current nick not equal to preferred nick.")
--			hexchat.print("Debug: server name is: " .. server)
			local server_context = hexchat.find_context(server, nil)
			if server_context then
--				hexchat.print("Debug: server context found: " .. server)
				server_context:command("msg nickserv regain " .. pref_nick)
				server_context:print(script_name .. ": " .. curr_nick .. " to " .. pref_nick)
			else
--				hexchat.print("Server Error 2: Cannot get server context for server: " .. server)
			end
		end
	end

	return hexchat.EAT_NONE
end

hexchat.hook_server("JOIN", on_join_autonick, hexchat.PRI_HIGHEST)

hexchat.print("* " .. script_name .. ":" .. script_version .. " is loaded.")
