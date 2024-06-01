-- Lua Script1
-- Author: CrossfireCam
-- DateCreated: 5/9/2024 9:10:03 PM

-- With help from these sources:
-- https://modiki.civfanatics.com/index.php?title=IsHasBuilding
--------------------------------------------------------------


--
-- TADC1: Cainic Empire
--
function Tadc1DigitalCircusAbility(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a TADC_CIRCUS and run randomspawn
	local iTadcCircus = GameInfoTypes["BUILDING_TADC_CIRCUS"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcCircus) then
		print("-- Tadc1DigitalCircusAbility: A player has just built Digital Circus.");

		-- Eligible Units for the random spawn depends on current Era, maxing out at granting Medieval Era units
		-- If no eligible Techs from this Era are found, the search continues to Techs from the previous Era
		local eligibleUnits = {}
		if (pPlayer:GetCurrentEra() >= GameInfoTypes["ERA_MEDIEVAL"]) then
			print("-- Tadc1DigitalCircusAbility: Medieval Era units are valid, checking techs...");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CIVIL_SERVICE", "UNIT_PIKEMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CHIVALRY", "UNIT_KNIGHT"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MACHINERY", "UNIT_CROSSBOWMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_STEEL", "UNIT_LONGSWORDSMAN"));
		end
		if (pPlayer:GetCurrentEra() == GameInfoTypes["ERA_CLASSICAL"] or #eligibleUnits == 0) then
			print("-- Tadc1DigitalCircusAbility: Classical Era units are valid, checking techs...");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_HORSEBACK_RIDING", "UNIT_HORSEMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_MATHEMATICS", "UNIT_CATAPULT"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_CONSTRUCTION", "UNIT_COMPOSITE_BOWMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_IRON_WORKING", "UNIT_SWORDSMAN"));
		end
		if (pPlayer:GetCurrentEra() == GameInfoTypes["ERA_ANCIENT"] or #eligibleUnits == 0) then
			print("-- Tadc1DigitalCircusAbility: Classical Era units are valid, checking techs...");
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
		
		-- Show notification
		local cityName = pCity:GetName();
		local heading = "Unit summoned by " .. cityName .. "'s new Digital Circus";
		local text = cityName .. "'s newly built Digital Circus has welcomed an NPC to join the fight!";
     	pPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading);
		print("-- Tadc1DigitalCircusAbility: Unit spawned successfully");
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



--
-- TADC2: Cast-Members Alliance
--
function Tadc2GanglesTheaterAbility(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a BUILDING_TADC_GANGLES_THEATER_PLACEHOLDER and run replacement code
	local iTadcGangleTheater = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_PLACEHOLDER"];
	local iTadcGangleTheaterAlt1 = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_COMEDY"];
	local iTadcGangleTheaterAlt2 = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_TRAGEDY"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcGangleTheater) then
		print("-- Tadc2GanglesTheaterAbility: A player has just built Gangle's Theater Placeholder.");
		local pCity = pPlayer:GetCityByID(iCity)
		pCity:SetNumRealBuilding(iTadcGangleTheater, 0);
		
		local cityName = pCity:GetName();
		local heading;
		local text;

		if (math.random() < 0.5) then
			pCity:SetNumRealBuilding(iTadcGangleTheaterAlt1, 1);
			heading = "Comedy Theater is complete";
			text = cityName .. "'s newly built Comedy Theater provides an extra +1 Happiness!";
		else
			pCity:SetNumRealBuilding(iTadcGangleTheaterAlt2, 1);
			heading = "Tragedy Theater is complete";
			text = cityName .. "'s newly built Tragedy Theater provides an extra +1 Culture!";
		end

		-- Show notification
     	pPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading);
		print("-- Tadc2GanglesTheaterAbility: Building replaced successfully");
	end
end

function Tadc2GanglesTheaterGrantFreeAtIndustrialStart(iPlayer, iCityX, iCityY)
	-- If the game grants a building using the <FreeStartEra> attribute, then the 'CityConstructed' GameEvent is not broadcasted.
	-- So, every time a Cast-Allied city is founded, check if they contain a Gangles Theater Placeholder.
	local iCiv = GameInfoTypes["CIVILIZATION_TADC2"]
	local pPlayer = Players[iPlayer];
	if (pPlayer:GetCivilizationType() == iCiv) then
		local pCity = Map.GetPlot(iCityX,iCityY):GetPlotCity();
		local iCity = pCity:GetID();
		local iTadcGangleTheater = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_PLACEHOLDER"];
		if (pCity:GetNumBuilding(iTadcGangleTheater) > 0) then
			print("-- New Cast-Allied city founded in Industrial Era ('" .. iCity .. "' X:" .. iCityX .. " & Y:" .. iCityY .. "). A Gangle's Theater is given for free, so force Gangle's Theater replacement.");
			Tadc2GanglesTheaterAbility(iPlayer, iCity, iTadcGangleTheater);
		end
	end
end

--
-- Generic Functions
--
function IsValidPlayer(player)
	return player ~= nil and player:IsAlive() and not player:IsBarbarian()
end



--
-- Start Main Code
--
print("TADC Lua loaded successfully")
GameEvents.CityConstructed.Add( Tadc1DigitalCircusAbility );
GameEvents.CityConstructed.Add( Tadc2GanglesTheaterAbility );
GameEvents.PlayerCityFounded.Add( Tadc2GanglesTheaterGrantFreeAtIndustrialStart );