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
		-- For every Era after Medieval, Medieval units are always available
		table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CIVIL_SERVICE", "UNIT_PIKEMAN"));
		table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CHIVALRY", "UNIT_KNIGHT"));
		table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MACHINERY", "UNIT_CROSSBOWMAN"));
		table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_STEEL", "UNIT_LONGSWORDSMAN"));
		-- In Renaissance, no longer offer Classical Era units
		if pPlayer:GetCurrentEra() <= GameInfoTypes["ERA_MEDIEVAL"] then
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_HORSEBACK_RIDING", "UNIT_HORSEMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MATHEMATICS", "UNIT_CATAPULT"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CONSTRUCTION", "UNIT_COMPOSITE_BOWMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_IRON_WORKING", "UNIT_SWORDSMAN"));
		end
		-- In Medieval, no longer offer Ancient Era units
		if pPlayer:GetCurrentEra() <= GameInfoTypes["ERA_CLASSICAL"] then
			table.insert(eligibleUnits, "UNIT_WARRIOR");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_ARCHERY", "UNIT_ARCHER"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
		end
		if #eligibleUnits == 0 then
			print("----- Player rushed Theology without studying ANY classical era unit techs. Resort to Classical Era picks. -----");
			table.insert(eligibleUnits, "UNIT_WARRIOR");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_ARCHERY", "UNIT_ARCHER"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
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

function insertUnitIfResearched(pPlayer, requiredEraName, techName, unitName)
	--print("----------");
	--print(GameInfoTypes[requiredEraName]);
	--print(GameInfoTypes[techName]);
	--print(GameInfoTypes[unitName]);

	pTeam = Teams[pPlayer:GetTeam()];
	-- If a player has researched a certain tech, then add it as an elibible unit for the Digital Circus ability
	if pTeam:IsHasTech(GameInfoTypes[techName]) then
		--print("We got the right tech. It's morbin time");
		return unitName
	end
	return nil
end


function IsValidPlayer(player)
	return player ~= nil and player:IsAlive() and not player:IsBarbarian()
end

print("TADC Lua loaded successfully")
GameEvents.CityConstructed.Add( Tadc1DigitalCircusRandomSpawn );