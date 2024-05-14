-- Lua Script1
-- Author: CrossfireCam
-- DateCreated: 5/9/2024 9:10:03 PM

-- With help from these sources:
-- https://modiki.civfanatics.com/index.php?title=IsHasBuilding
--------------------------------------------------------------


function Tadc1DigitalCircusRandomSpawn(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a TADC_CIRCUS and run randomspawn
	local iTadcCircus = GameInfoTypes["BUILDING_TADC_CIRCUS"];
	local player = Players[iPlayer];
	if (iBuilding == iTadcCircus) then
		print("A player has just built Digital Circus.")
	end
end



function IsValidPlayer(player)
	return player ~= nil and player:IsAlive() and not player:IsBarbarian()
end

print("TADC Lua loaded")
GameEvents.CityConstructed.Add( Tadc1DigitalCircusRandomSpawn );