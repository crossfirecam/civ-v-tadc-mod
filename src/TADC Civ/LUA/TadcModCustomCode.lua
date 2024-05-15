-- Lua Script1
-- Author: CrossfireCam
-- DateCreated: 5/9/2024 9:10:03 PM

-- With help from these sources:
-- https://modiki.civfanatics.com/index.php?title=IsHasBuilding
--------------------------------------------------------------


function Tadc1DigitalCircusAbility(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a TADC_CIRCUS and run randomspawn
	local iTadcCircus = GameInfoTypes["BUILDING_TADC_CIRCUS"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcCircus) then
		print("-- Tadc1DigitalCircusAbility: A player has just built Digital Circus.");

		-- Eligible Units for the random spawn depends on current Era.
		-- The bonus provides units from the player's current or previous Era, maxing out at granting Medieval Era units (prevents the bonus from being bad later in the game)
		local eligibleUnits = {}
		local pEra = pPlayer:GetCurrentEra();
		local ancientEraUnitsAreValid = pEra <= GameInfoTypes["ERA_CLASSICAL"];
		local classicalEraUnitsAreValid = pEra >= GameInfoTypes["ERA_CLASSICAL"] and pEra <= GameInfoTypes["ERA_MEDIEVAL"];
		local medievalEraUnitsAreValid = pEra >= GameInfoTypes["ERA_MEDIEVAL"];
		print(ancientEraUnitsAreValid)
		print(classicalEraUnitsAreValid);
		if ancientEraUnitsAreValid then
			print("-- Tadc1DigitalCircusAbility: Ancient Era units are valid, checking techs...");
			table.insert(eligibleUnits, "UNIT_WARRIOR");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_ARCHERY", "UNIT_ARCHER"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
		end
		if classicalEraUnitsAreValid then
			print("-- Tadc1DigitalCircusAbility: Classical Era units are valid, checking techs...");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_HORSEBACK_RIDING", "UNIT_HORSEMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MATHEMATICS", "UNIT_CATAPULT"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CONSTRUCTION", "UNIT_COMPOSITE_BOWMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_IRON_WORKING", "UNIT_SWORDSMAN"));
		end
		if medievalEraUnitsAreValid then
			print("-- Tadc1DigitalCircusAbility: Medieval Era units are valid, checking techs...");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CIVIL_SERVICE", "UNIT_PIKEMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CHIVALRY", "UNIT_KNIGHT"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MACHINERY", "UNIT_CROSSBOWMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_STEEL", "UNIT_LONGSWORDSMAN"));
		end

		if #eligibleUnits == 0 then
			print("-- Tadc1DigitalCircusAbility: EDGE CASE - Player rushed Theology without studying any classical era unit techs. Resort to Classical Era checks. -----");
			table.insert(eligibleUnits, "UNIT_WARRIOR");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_ARCHERY", "UNIT_ARCHER"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
		end
		strAllEligibleUnits = table.concat(eligibleUnits, ", ");
		print("-- Tadc1DigitalCircusAbility: Digital Circus complete. These are the eligible units to spawn: " .. strAllEligibleUnits);

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
		print("-- Tadc1DigitalCircusAbility: Units spawned successfully");
	end
end

function insertUnitIfResearched(pPlayer, techName, unitName)

	pTeam = Teams[pPlayer:GetTeam()];
	-- If a player has researched a certain tech, then add it as an elibible unit for the Digital Circus ability
	if pTeam:IsHasTech(GameInfoTypes[techName]) then
		print("------ InsertUnitIfResearched: We have " .. techName .. ", add " .. unitName);
		return unitName
	end
	print("------ InsertUnitIfResearched: We don't have " .. techName .. ", ignore " .. unitName);
	return nil
end


function IsValidPlayer(player)
	return player ~= nil and player:IsAlive() and not player:IsBarbarian()
end

print("TADC Lua loaded successfully")
GameEvents.CityConstructed.Add( Tadc1DigitalCircusAbility );