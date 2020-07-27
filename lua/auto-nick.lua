--[[
        Name: auto-nick.lua
      Author: Brian Ferguson
     Website: https://github.com/brianferguson/hexchat-scripts/
        Date: 2020.07.27
     Version: 1.0
     License: CC BY-NC-SA 4.0  https://creativecommons.org/licenses/by-nc-sa/4.0/
 Description: This regains your preferred nick when logging onto a server.
    Platform: Hexchat 2.14.3
     Network: freenode#rainmeter (brian)
]]

local script_name = "auto-nick.lua"
local script_version = "1.0"
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

	local curr_nick = hexchat.get_info("nick")
	local pref_nick = hexchat.prefs["irc_nick1"]

	-- Debug
--[[
	hexchat.print("Current nick: " .. curr_nick)
	hexchat.print("Preferred nick: " .. pref_nick)
	hexchat.print("word[1]: " .. word[1])
	hexchat.print("word[2]: " .. word[2])
	hexchat.print("word[3]: " .. word[3])
	hexchat.print("word[4]: " .. word[4])
	hexchat.print("word[5]: " .. word[5])
	hexchat.print("eol[1]: " .. eol[1])
]]

	if hexchat.nickcmp(word[4], pref_nick) == 0 then
		if hexchat.nickcmp(curr_nick, pref_nick) ~= 0 then
--			hexchat.print("Debug: current nick not equal to preferred nick.")
			local server = hexchat.get_info("server")
			if server then
--				hexchat.print("Debug: server name is: " .. server)
				local server_context = hexchat.find_context(server, nil)
				if server_context then
--					hexchat.print("Debug: server context found: " .. server)
					server_context:command("msg nickserv regain " .. pref_nick)
					server_context:print(script_name .. ": " .. curr_nick .. " to " .. pref_nick)
				else
--					hexchat.print("Error 2: cannot get server context for server: " .. server)
				end
			else
--				hexchat.print("Error 1: cannot get server name.")
			end
		end
	end

	return hexchat.EAT_NONE
end

hexchat.hook_server("JOIN", on_join_autonick, hexchat.PRI_HIGHEST)

hexchat.print("* " .. script_name .. ":" .. script_version .. " is loaded.")
