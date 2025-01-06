Framework = (GetResourceState("es_extended") == "started" and exports['es_extended']:getSharedObject()) or (GetResourceState("qb-core") == "started" and exports['qb-core']:GetCoreObject()) or (GetResourceState("qbx_core") == "started" and exports['qbx_core']:GetCoreObject()) or nil

Config = {}
Config.Framework = (GetResourceState("es_extended") == "started" and "ESX") or (GetResourceState("qb-core") == "started" and "QBCore") or (GetResourceState("qbx_core") == "started" and "QBOX") or nil

Config.sppedType = "kmh" -- @string | kmh // mph
Config.ServerName = "Kastm RP"
Config.DefaultMap = "circle" -- @string | circle // square (if player didn't change map in settings)

Config.Show = {
   Accounts = true, -- money hud top right
   Job = true, -- job hud top left 
   Info = true -- info hud top map
}

Config.Refresh = {
   car = 300,
   onFoot = 1000,
   Time = 2000 -- if using info hud
}

Config.GetFuel = function (vehicle)
   return GetVehicleFuelLevel(vehicle)
end
