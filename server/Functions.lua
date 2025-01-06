Server = {
   Functions = {}
}

Server.Functions.RegisterCallback = function(name, cb)
   if Config.Framework == "ESX" then
      Framework.RegisterServerCallback(name, cb)
   else
      Framework.Functions.CreateCallback(name, cb)
   end
end

Server.Functions.GetPlayerFromId = function (id)
   if Config.Framework == "ESX" then
      return Framework.GetPlayerFromId(id)
   else
      return Framework.Functions.GetPlayer(id)
   end
end

Server.Functions.GetPlayerIdentifier = function (Player)
   if Config.Framework == "ESX" then
      return Player.identifier
   else
      return Player.PlayerData.citizenid
   end
end

Server.Functions.GetJobLabel = function (Player)
   if Config.Framework == "ESX" then
      return Player.getJob().label
   else
      return Player.PlayerData.job.name
   end
end

Server.Functions.GetJobRank = function (Player)
   if Config.Framework == "ESX" then
      return Player.getJob().grade_label
   else
      return Player.PlayerData.job.grade.name
   end
end