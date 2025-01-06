Client = {
   Functions = {},
   Loaded = false,
   Data = {
      Hunger = 0,
      Thirst = 0,
      Health = 100,
      Armor = 0,
      Stamina = 100,
      Voice = false,
      Accounts = {
         Bank = 0,
         Money = 0
      },
      Job = {
         Label = "",
         Rank = ""
      },
      Identifier = "",
      Map = ""
   },
   Vehicle = {
      Gear = 1,
      RPM = 0,
      Speed = 0,
      Fuel = 0,
      MaxFuel = 0,
      Health = 0,
      Location = {
         Street = "",
         StreetDesc = "",
         Direction = ""
      }
   },
   Time = {
      Date = "",
      Time = ""
   }
}

Client.Functions.TriggerCallback = function(name, cb, ...)
   if Config.Framework == "ESX" then
       Framework.TriggerServerCallback(name, function (Fcb)
           if Fcb then
               cb(Fcb)
           end
       end, ...)
   else
       Framework.Functions.TriggerCallback(name,function (Fcb)
           if Fcb then
               cb(Fcb)
           end
       end, ...)
   end
end

Client.Functions.PlayerLoaded = function ()
   Client.Loaded = true
   DisplayRadar(true)
   SetRadarBigmapEnabled(false, false)

   Client.Functions.TriggerCallback("hud:server:getIdentifier", function(identifier)
       Client.Data.Identifier = identifier
       local mapType = GetResourceKvpString(Client.Data.Identifier.."_hudSettings") or Config.DefaultMap
       Client.Data.Map = mapType

       if mapType == "square" then
           Client.Functions.LoadSquareMap()
       else
           Client.Functions.LoadCircleMap()
       end
   end)
end

Client.Functions.isPlayerLoaded = function ()
   if Client.Loaded then return true end

   if Config.Framework == "ESX" then
      return Framework.PlayerLoaded
   elseif Config.Framework == "QBCore" or Config.Framework == "QBOX" then
       return LocalPlayer.state.isLoggedIn
   else
       print("Config.Framework not supported or not started.")
       return false
   end
end


-- PLAYER UPDATE DATA


Client.Functions.UpdateData = function ()
   local PlayerData = Config.Framework == "ESX" and Framework.GetPlayerData() or Framework.Functions.GetPlayerData()

   if Config.Framework == "QBCore" or Config.Framework == "QBOX" then
      Client.Data.Thirst = PlayerData.metadata['thirst']
      Client.Data.Hunger = PlayerData.metadata['hunger']
   end

   if Client.Data.Voice ~= "radio" then
      if MumbleIsPlayerTalking(PlayerId()) then
         Client.Data.Voice = "voice"
      else
         Client.Data.Voice = false
      end
   end

   if Config.Show.Accounts then
      Client.Functions.TriggerCallback("hud:server:getAccounts", function (accounts)
         Client.Data.Accounts = accounts
      end)
   end

   if Config.Show.Job then
      Client.Functions.TriggerCallback("hud:server:getJob", function (Job)
         Client.Data.Job = Job
      end)
   end

   Client.Data.Health = GetEntityHealth(PlayerPedId()) / 2
   Client.Data.Armor = GetPedArmour(PlayerPedId()) / 2
   local staminaRaw = GetPlayerSprintStaminaRemaining(PlayerId())
   Client.Data.Stamina = math.floor(100 - staminaRaw)
end


-- VEHICLE UPDATE


local function GetVehicleRPMPercentage(vehicle)
   if not DoesEntityExist(vehicle) then return 0 end

   local currentRPM = GetVehicleCurrentRpm(vehicle)

   local maxFlatVel = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
   local driveForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce")
   local inertia = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
   local clutchChangeRate = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift")

   local estimatedMaxRPM = (maxFlatVel * driveForce * inertia * clutchChangeRate * 10)
   if estimatedMaxRPM <= 0 then
       estimatedMaxRPM = 6500
   end

   local rpmPercentage = (currentRPM * estimatedMaxRPM) / estimatedMaxRPM * 100

   return math.floor(rpmPercentage + 0.5)
end

local getHeadingText = function(heading)
   if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
       return "N"
   elseif (heading >= 45 and heading < 135) then
       return "W"
   elseif (heading >= 135 and heading < 225) then
       return "S"
   elseif (heading >= 225 and heading < 315) then
       return "E"
   end
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}
local getCrossroads = function(vehicle)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(vehicle)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck
end

Client.Functions.UpdateVehicleData = function ()
   local playerPed = PlayerPedId()
   local vehicle = GetVehiclePedIsIn(playerPed, false)
   local multiplier = Config.sppedType == "kmh" and 3.6 or 2.236936

   Client.Vehicle.Speed = math.floor(GetEntitySpeed(playerPed) * multiplier)

   Client.Vehicle.Gear = GetVehicleCurrentGear(vehicle)
   if (Client.Vehicle.Speed == 0 and Client.Vehicle.Gear == 0) or (Client.Vehicle.Speed == 0 and Client.Vehicle.Gear == 1) then
      Client.Vehicle.Gear = 'N'
   elseif Client.Vehicle.Speed > 0 and Client.Vehicle.Gear == 0 then
      Client.Vehicle.Gear = 'R'
   end

   Client.Vehicle.RPM = GetVehicleRPMPercentage(vehicle)
   Client.Vehicle.MaxFuel = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fPetrolTankVolume")
   Client.Vehicle.Fuel = Config.GetFuel(vehicle)
   Client.Vehicle.Health = math.floor(GetVehicleEngineHealth(vehicle))

   local streets = getCrossroads(vehicle)

   Client.Vehicle.Location.Direction = getHeadingText(GetEntityHeading(playerPed))
   Client.Vehicle.Location.Street = streets[1]
   Client.Vehicle.Location.StreetDesc = streets[2]
end

---------------------------------------------------------

Client.Functions.LoadSquareMap = function()
   local defaultAspectRatio = 1920 / 1080 -- Don't change this.
   local resolutionX, resolutionY = GetActiveScreenResolution()
   local aspectRatio = resolutionX / resolutionY
   local minimapOffset = 0

   if aspectRatio > defaultAspectRatio then
       minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
   end

   RequestStreamedTextureDict("squaremap", false)
   while not HasStreamedTextureDictLoaded("squaremap") do
       Wait(150)
   end

   SetMinimapClipType(0)
   AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
   AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
   
   SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
   SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
   SetMinimapComponentPosition("minimap_blur", "L", "B", -0.01 + minimapOffset, 0.025, 0.262, 0.300)
   SetBlipAlpha(GetNorthRadarBlip(), 0)
   SetRadarBigmapEnabled(true, false)
   SetMinimapClipType(0)
   Wait(0)
   SetRadarBigmapEnabled(false, false)
end

Client.Functions.LoadCircleMap = function()
   local defaultAspectRatio = 1920 / 1080
   local resolutionX, resolutionY = GetActiveScreenResolution()
   local aspectRatio = resolutionX / resolutionY
   local minimapOffset = 0

   if aspectRatio > defaultAspectRatio then
       minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
   end

   RequestStreamedTextureDict("circlemap", false)
   while not HasStreamedTextureDictLoaded("circlemap") do
       Wait(150)
   end

   SetMinimapClipType(1)
   AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
   AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "circlemap", "radarmasksm")

   SetMinimapComponentPosition("minimap", "L", "B", -0.0100 + minimapOffset, -0.030, 0.180, 0.258)
   SetMinimapComponentPosition("minimap_mask", "L", "B", 0.200 + minimapOffset, 0.0, 0.065, 0.20)
   SetMinimapComponentPosition("minimap_blur", "L", "B", -0.00 + minimapOffset, 0.015, 0.252, 0.338)
   SetBlipAlpha(GetNorthRadarBlip(), 0)
   SetMinimapClipType(1)
   SetRadarBigmapEnabled(true, false)
   Wait(0)
   SetRadarBigmapEnabled(false, false)
end