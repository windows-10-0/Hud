AddEventHandler("pma-voice:radioActive", function(radioTalking)
   Client.Data.Voice = radioTalking and 'radio' or false
end)

if Config.Framework == "ESX" then
   AddEventHandler("esx_status:onTick", function(data)
      for i = 1, #data do
         if data[i].name == "thirst" then
            Client.Data.Thirst = math.floor(data[i].percent)
         end
         if data[i].name == "hunger" then
            Client.Data.Hunger = math.floor(data[i].percent)
         end
      end
   end)
end

if Config.Show.Info then
   CreateThread(function()
      while true do
         Client.Functions.TriggerCallback("hud:server:getTime", function (time)
            Client.Time.Time = time
         end)
         SendNUIMessage({
            action = "updateTime",
            time = Client.Time
         })
         Wait(Config.Refresh.Time)
      end
   end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function()
   Client.Functions.PlayerLoaded()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
   Client.Functions.PlayerLoaded()
end)

CreateThread(function()
   while true do
       Wait(500)

       if not Client.Functions.isPlayerLoaded() then
           DisplayRadar(false)
       else
           if not Client.Loaded then
               Client.Functions.PlayerLoaded()
               break
            else
               break
           end
       end
   end
end)

CreateThread(function()
   while true do
      if Client.Loaded then
         Client.Functions.UpdateData()
         SendNUIMessage({
            action = "updateHud",
            data = Client.Data
         })
         if IsPedInAnyVehicle(PlayerPedId(), false) then
            SendNUIMessage({
               action = "showCar"
            })
            Client.Functions.UpdateVehicleData()
            SendNUIMessage({
               action = "updateVehicle",
               vehData = Client.Vehicle
            })
            Wait(Config.Refresh.car)
         else
            SendNUIMessage({
               action = "hideCar"
            })
            Wait(Config.Refresh.onFoot)
         end
      else
         Wait(100)
      end
   end
end)

RegisterCommand("hud", function()
   SetNuiFocus(true, true)
   SendNUIMessage({
      action = "openSettings"
   })
end)