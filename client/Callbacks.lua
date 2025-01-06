RegisterNuiCallback("JSLoaded", function(data, cb)
   SendNUIMessage({
      action = "showFoot"
   })
   cb({
      ServerName = Config.ServerName,
      Show = Config.Show
   })
   if Config.Show.Info then
      Client.Functions.TriggerCallback("hud:server:getDate", function (date)
         Client.Time.Date = date
      end)
   end
end)

RegisterNuiCallback("close", function(data, cb)
   SetNuiFocus(false, false)
end)

RegisterNuiCallback("changeMap", function(data, cb)
   SetNuiFocus(false, false)
   SetResourceKvp(Client.Data.Identifier.."_hudSettings", data.map)
   Client.Data.Map = data.map
   if data.map == "square" then
      Client.Functions.LoadSquareMap()
   else
      Client.Functions.LoadCircleMap()
   end
end)