Server.Functions.RegisterCallback("hud:server:getAccounts", function (source, cb)
   local Player = Server.Functions.GetPlayerFromId(source)
   if not Player then return end

   local bank = Config.Framework == "ESX" and Player.getAccount("bank").money or Player.PlayerData.money['bank']
   local money = Config.Framework == "ESX" and Player.getAccount("money").money or Player.PlayerData.money['cash']

   cb({
      Bank = bank,
      Money = money
   })
end)

Server.Functions.RegisterCallback("hud:server:getJob", function (source, cb)
   local Player = Server.Functions.GetPlayerFromId(source)
   if not Player then return end

   local JobLabel = Server.Functions.GetJobLabel(Player)
   local JobRank = Server.Functions.GetJobRank(Player)

   cb({
      Label = JobLabel,
      Rank = JobRank
   })
end)

Server.Functions.RegisterCallback("hud:server:getDate", function(source, cb)
   local date = os.date("%d-%m-%Y") 
   cb(date)
end)

Server.Functions.RegisterCallback("hud:server:getTime", function(source, cb)
   local time = os.date("%H:%M:%S") 
   cb(time)
end)

Server.Functions.RegisterCallback("hud:server:getIdentifier", function(source, cb)
   local Player = Server.Functions.GetPlayerFromId(source)
   if not Player then return end
   cb(Server.Functions.GetPlayerIdentifier(Player))
end)