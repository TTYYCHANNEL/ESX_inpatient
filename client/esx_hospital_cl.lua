local Keys = {
	["ESC"] = 322, ["BACKSPACE"] = 177, ["E"] = 38, ["ENTER"] = 18,	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173
}

local menuIsShowed				  = false
local hasAlreadyEnteredMarker     = false
local lastZone                    = nil
local isInhospitalistingMarker 	  = false
 
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function ShowHospitalListingMenu(data)
	

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'hospitalisting',
			{
				title    = _U('hospital_center'),
				elements = {
				{label = _U('citizen_wear'), value = 'citizen_wear'},
				{label = _U('hospital_wear'), value = 'hospital_wear'},
			},
			},
			function(data, menu)
			local ped = GetPlayerPed(-1)
			menu.close()

			if data.current.value == 'citizen_wear' then
				if Config.EnableNonFreemodePeds then
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
						local isMale = skin.sex == 0
	
						TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
							ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
								TriggerEvent('skinchanger:loadSkin', skin)
								TriggerEvent('esx:restoreLoadout')
							end)
						end)
	
					end)
				else
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
						TriggerEvent('skinchanger:loadSkin', skin)
					end)
				end
			end

			if data.current.value == 'hospital_wear' then 

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, hospitalSkin)
					if skin.sex == 0 then
						--SetPedPropIndex(GetPlayerPed(-1), 0, 5, 0, 2)             -- Head
						--SetPedPropIndex(GetPlayerPed(-1), 1, 0, 0, 2)             -- Mask
						--SetPedComponentVariation(GetPlayerPed(-1), 2, 55, 0, 2)   -- Hair Styles
						SetPedComponentVariation(GetPlayerPed(-1), 3, 190, 0, 2)   -- glooves
						SetPedComponentVariation(GetPlayerPed(-1), 4, 65, 0, 2)   -- Pants
						--SetPedComponentVariation(GetPlayerPed(-1), 5, 24, 0, 2)   -- Bag
						SetPedComponentVariation(GetPlayerPed(-1), 6, 6, 0, 2)    -- Shoes
						--SetPedComponentVariation(GetPlayerPed(-1), 7, 8, 0, 2)    -- Accesories
						--SetPedComponentVariation(GetPlayerPed(-1), 8, 8, 0, 2)    -- Undershirt
						--SetPedComponentVariation(GetPlayerPed(-1), 9, 8, 0, 2)    -- BodyArmor
						--SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 0, 2)   -- Decal
						SetPedComponentVariation(GetPlayerPed(-1), 11, 144, 0, 2)   -- Torso
					elseif skin.sex == 1 then
						--SetPedPropIndex(GetPlayerPed(-1), 0, 5, 0, 2)             -- Head
						--SetPedPropIndex(GetPlayerPed(-1), 1, 0, 0, 2)             -- Mask
						--SetPedComponentVariation(GetPlayerPed(-1), 2, 55, 0, 2)   -- Hair Styles
						SetPedComponentVariation(GetPlayerPed(-1), 3, 190, 0, 2)   -- glooves
						SetPedComponentVariation(GetPlayerPed(-1), 4, 65, 0, 2)   -- Pants
						--SetPedComponentVariation(GetPlayerPed(-1), 5, 24, 0, 2)   -- Bag
						SetPedComponentVariation(GetPlayerPed(-1), 6, 6, 0, 2)    -- Shoes
						--SetPedComponentVariation(GetPlayerPed(-1), 7, 8, 0, 2)    -- Accesories
						--SetPedComponentVariation(GetPlayerPed(-1), 8, 8, 0, 2)    -- Undershirt
						--SetPedComponentVariation(GetPlayerPed(-1), 9, 8, 0, 2)    -- BodyArmor
						--SetPedComponentVariation(GetPlayerPed(-1), 10, 8, 0, 2)   -- Decal
						SetPedComponentVariation(GetPlayerPed(-1), 11, 144, 0, 2)   -- Torso
					else
						TriggerEvent('skinchanger:loadClothes', skin, hospitalSkin.skin_female)
					end
					
				end)
			end
		end,

			function(data, menu)
				menu.close()
			end
		)

end

AddEventHandler('eden_hospital:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))
		for i=1, #Config.Zones, 1 do
			if(GetDistanceBetweenCoords(coords, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z, true) < Config.DrawDistance) then
				DrawMarker(Config.MarkerType, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		isInHospitallistingMarker  = false
		local currentZone = nil
		for i=1, #Config.Zones, 1 do
			if(GetDistanceBetweenCoords(coords, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z, true) < Config.ZoneSize.x) then
				isInHospitallistingMarker  = true
				SetTextComponentFormat('STRING')
            	AddTextComponentString(_U('access_hospital_center'))
            	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
		end
		if isInHospitallistingMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end
		if not isInHospitallistingMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('eden_hospital:hasExitedMarker')
		end
	end
end)



-- Menu Controls
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustReleased(0, Keys['E']) and isInHospitallistingMarker and not menuIsShowed then
			ShowHospitalListingMenu()
		end
	end
end)
