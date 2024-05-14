-- Lua Script1
-- Author: CrossfireCam
-- DateCreated: 5/9/2024 9:10:03 PM

-- With help from these sources:
-- https://modiki.civfanatics.com/index.php?title=IsHasBuilding
--------------------------------------------------------------


function Tadc1DigitalCircusRandomSpawn(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a TADC_CIRCUS and run randomspawn
	local iTadcCircus = GameInfoTypes["BUILDING_TADC_CIRCUS"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcCircus) then
		print("A player has just built Digital Circus.");
		local eligibleUnits = {}

		-- Tech/Era/Unit Checks
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_ANCIENT", "TECH_ARCHERY", "UNIT_ARCHER"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_ANCIENT", "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_ANCIENT", "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_CLASSICAL", "TECH_HORSEBACK_RIDING", "UNIT_HORSEMAN"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_CLASSICAL", "TECH_MATHEMATICS", "UNIT_CATAPULT"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_CLASSICAL", "TECH_CONSTRUCTION", "UNIT_COMPOSITE_BOWMAN"));
		table.insert(eligibleUnits, insertUnitIfResearchedAndThisEra(pPlayer, "ERA_CLASSICAL", "TECH_IRON_WORKING", "UNIT_SWORDSMAN"));

		if pPlayer:GetCurrentEra() == GameInfoTypes["ERA_ANCIENT"] then
			table.insert(eligibleUnits, "UNIT_WARRIOR");
		end


		-- Debugging
		print("----- Digital Circus building was completed. These are the eligible units to spawn -----");
		for k, v in pairs(eligibleUnits) do
			print(k,v);
		end

		-- Find city, spawn the units inside city
		local pCity = pPlayer:GetCityByID(iCity)
		local chosenUnit = eligibleUnits[math.random(#eligibleUnits)];
		local pUnit = pPlayer:InitUnit(GameInfoTypes[chosenUnit], pCity:GetX(), pCity:GetY());
		local chosenUnit2 = eligibleUnits[math.random(#eligibleUnits)];
		local pUnit2 = pPlayer:InitUnit(GameInfoTypes[chosenUnit2], pCity:GetX(), pCity:GetY());
		
		local cityName = pCity:GetName();
		local text = cityName .. "'s newly built Digital Circus has welcomed two NPCs to join the fight!";
		local heading = "Units summoned by " .. cityName .. "'s new Digital Circus";
     	pPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading);
		print("Units Spawned");
	end
end

function insertUnitIfResearchedAndThisEra(pPlayer, requiredEraName, techName, unitName)
	--print("----------");
	--print(GameInfoTypes[requiredEraName]);
	--print(GameInfoTypes[techName]);
	--print(GameInfoTypes[unitName]);
	pTeam = Teams[pPlayer:GetTeam()];
	-- If a player has researched a certain tech, and they're within the same Era, then add it as an elibible unit for the Digital Circus ability
	if pPlayer:GetCurrentEra() == GameInfoTypes[requiredEraName] then
		--print("We're in the right era");
		if pTeam:IsHasTech(GameInfoTypes[techName]) then
			--print("We got the right tech. It's morbin time");
			-- Disqualify units that need Iron, if we have no Iron for them
			if unitName == "UNIT_SWORDSMAN" then
				if pPlayer:GetNumResourceAvailable( GameInfoTypes["RESOURCE_IRON"], true ) < 1 then
					return nil
				end
			end
			return unitName
		end
	end
	return nil
end


function IsValidPlayer(player)
	return player ~= nil and player:IsAlive() and not player:IsBarbarian()
end

print("TADC Lua loaded successfully")
GameEvents.CityConstructed.Add( Tadc1DigitalCircusRandomSpawn );