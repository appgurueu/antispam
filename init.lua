local PLAYERS_MSG={}
local SPAM_WARN=5
local SPAM_KICK=SPAM_WARN+5
local RESET_TIME=30 --In seconds
local RESET_TIME_MSECS=RESET_TIME*1000 --Convert to microsecs
local WARNING_COLOR=minetest.get_color_escape_sequence("#FFBB33")
minetest.register_on_leaveplayer(function (player)
    PLAYERS_MSG[player:get_player_name()]=nil
end)
minetest.register_on_joinplayer(function (player)
	minetest.after(0,function(player)
		PLAYERS_MSG[player:get_player_name()]={}
    end,player)
end)
minetest.register_on_chat_message(function(name,message)
    for msg,info in pairs(PLAYERS_MSG[name]) do
        if minetest.get_us_time()-info[2] >= RESET_TIME_MSECS then
            PLAYERS_MSG[name][msg]=nil
        end
    end
    if PLAYERS_MSG[name][message] then
        local amount=PLAYERS_MSG[name][message][1]+1
        PLAYERS_MSG[name][message][1]=amount
        PLAYERS_MSG[name][message][2]=minetest.get_us_time()
        if amount >= SPAM_KICK then
            minetest.kick_player(name,"Kicked for spamming.")
        elseif amount >= SPAM_WARN then
            minetest.chat_send_player(name,WARNING_COLOR.."Warning ! You've sent the message '"..message.."' too often. Wait at least "..RESET_TIME.." seconds before sending it again.")
        end
    else
        PLAYERS_MSG[name][message]={1,minetest.get_us_time()}
    end
    return true
end)
