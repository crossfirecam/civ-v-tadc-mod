-- Lua Script1
-- Author: CrossfireCam
-- DateCreated: 5/9/2024 9:10:03 PM

-- With help from these sources:
-- https://modiki.civfanatics.com/index.php?title=IsHasBuilding
--------------------------------------------------------------


--
-- TADC1: Cainic Empire: Custom Circus code
--
function Tadc1DigitalCircusAbility(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a TADC_CIRCUS and run randomspawn
	local iTadcCircus = GameInfoTypes["BUILDING_TADC_CIRCUS"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcCircus) then
		print("-- Tadc1DigitalCircusAbility: A player has just built Digital Circus.");

		-- Eligible Units for the random spawn depends on current Era, maxing out at granting Medieval Era units
		-- If no eligible Techs from this Era are found, the search continues to Techs from the previous Era
		-- At the very least (Rushing Camping then Theology) a Warrior is valid and can be granted
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
			print("-- Tadc1DigitalCircusAbility: Ancient Era units are valid, checking techs...");
			table.insert(eligibleUnits, "UNIT_WARRIOR");
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_ARCHERY", "UNIT_ARCHER"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_BRONZE_WORKING", "UNIT_SPEARMAN"));
			table.insert(eligibleUnits, insertUnitIfResearched(pPlayer, "TECH_THE_WHEEL", "UNIT_CHARIOT_ARCHER"));
		end
		strAllEligibleUnits = table.concat(eligibleUnits, ", ");
		print("-- Tadc1DigitalCircusAbility: Digital Circus complete. These are the eligible units to spawn: " .. strAllEligibleUnits);

		-- Find city, spawn unit inside city
		local pCity = pPlayer:GetCityByID(iCity)
		local chosenUnit = eligibleUnits[math.random(#eligibleUnits)];
		local pUnit = pPlayer:InitUnit(GameInfoTypes[chosenUnit], pCity:GetX(), pCity:GetY());

		-- Grant XP from Barracks etc, grant free promotions from wonders in the city.
		-- Thanks to whoward69 & Irkalla on CivFanatics for these snippets https://forums.civfanatics.com/threads/lua-spawn-a-unit-without-addfreeunit.486267/
		pUnit:SetExperience(pCity:GetDomainFreeExperience(pUnit:GetDomainType()))
		for promotion in GameInfo.UnitPromotions() do
			iPromotion = promotion.ID
			if ( pCity:GetFreePromotionCount( iPromotion ) > 0 ) then
				pUnit:SetHasPromotion( iPromotion, true )
			end
		end
		
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
-- TADC1: Cainic Empire: Custom Golden Age code
--
local notifSentGoldenAge = false;
function Tadc1GoldenAgeTrait(playerID)
	-- If player is Caine, manage their Golden Age bonus. Thanks to DJSHenninger for this snippet (Additional Civilizations Mod)
	local player = Players[playerID]
	if player:GetCivilizationType() == GameInfoTypes["CIVILIZATION_TADC1"] and player:IsAlive() then
		for city in player:Cities() do
			if (city:GetNumBuilding(GameInfoTypes["BUILDING_TADC_CAINETRAIT"]) > 0) then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_TADC_CAINETRAIT"], 0)
			end
			if player:IsGoldenAge() then
				city:SetNumRealBuilding(GameInfoTypes["BUILDING_TADC_CAINETRAIT"], 1)
				if (notifSentGoldenAge == false) then
					notifSentGoldenAge = true;
					local heading = "Digital Feast has begun!";
					local text = "During this Golden Age, all cities enjoy a Digital Feast, providing +20% Food generation!";
     				player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading);
				end
			else
				if (notifSentGoldenAge == true) then
					notifSentGoldenAge = false;
				end
			end
		end
	end
end

function Tadc1BonusGoldenAgeStart(iTeamID, eTech, iChange)
	-- If a team completes Electricity tech, check every player on the map to see if they're part of this team.
	-- If they are, and are also the Cainic Civ, they'll get a free Golden Age.
	-- Thanks to Firaxis for this snippet (NewWorldScenario.TurnsRemaining.OnTechResearched).
	if (GameInfoTypes["TECH_ELECTRICITY"] == eTech) then
 		for iLoopPlayer = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		    local pLoopPlayer = Players[iLoopPlayer];
		    if (pLoopPlayer:GetTeam() == iTeamID) then
				if (iChange == 1) then -- The wiki says regarding what iChange means: "No idea". But it's in Firaxis' snippet, I'm keeping it here.
					pLoopPlayer:ChangeGoldenAgeTurns(pLoopPlayer:GetGoldenAgeLength());
				end
		    end
		end
	end
end





--
-- TADC2: Cast-Members Alliance
--
function Tadc2GanglesTheaterAbility(iPlayer, iCity, iBuilding)
	-- Each time a construction finishes, check if it's a BUILDING_TADC_GANGLES_THEATER.
	local iTadcGangleTheater = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER"];
	local iTadcGangleTheaterAlt1 = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_COMEDY"];
	local iTadcGangleTheaterAlt2 = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER_TRAGEDY"];
	local pPlayer = Players[iPlayer];
	if (iBuilding == iTadcGangleTheater) then
		local pCity = pPlayer:GetCityByID(iCity)
		if (pCity:GetNumBuilding(iTadcGangleTheaterAlt1) == 0 and pCity:GetNumBuilding(iTadcGangleTheaterAlt2) == 0) then
			print("-- Tadc2GanglesTheaterAbility: A player has just built Gangle's Theater. Grant a random Hall.");
			local cityName = pCity:GetName();
			local heading;
			local text;

			if (math.random() < 0.5) then
				pCity:SetNumRealBuilding(iTadcGangleTheaterAlt1, 1);
				heading = "Comedy Theater is complete";
				text = "The newly built Gangle's Theater in ".. cityName .." has opened their Comedy Hall, which provides +1 Happiness!";
			else
				pCity:SetNumRealBuilding(iTadcGangleTheaterAlt2, 1);
				heading = "Tragedy Theater is complete";
				text = "The newly built Gangle's Theater in ".. cityName .." has opened their Tragedy Hall, which provides +1 Culture!";
			end

			-- Show notification
     		pPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading);
		end
	end
end

function Tadc2CheckForFreeGanglesTheater(iPlayer)
	-- The game grants a free Ampitheater in two scenarios: With an 'Industrial Era' game start, or when Legalism is adopted.
	-- There's no GameEvent for when a free building is granted by Legalism. Therefore, we need to check every turn if this Civ has a theater in their city.
	local pPlayer = Players[iPlayer];
	if pPlayer:GetCivilizationType() == GameInfoTypes["CIVILIZATION_TADC2"] and pPlayer:IsAlive() then
		local iTadcGangleTheater = GameInfoTypes["BUILDING_TADC_GANGLES_THEATER"];
		for pCity in pPlayer:Cities() do
			if (pCity:GetNumBuilding(iTadcGangleTheater) > 0) then
				iCity = pCity:GetID();
				print("-- Cast-Allied city found with a Gangle's Theater (ID: " .. iCity .. "). Check if it needs to receive a free Hall...");
				Tadc2GanglesTheaterAbility(iPlayer, iCity, iTadcGangleTheater);
			end
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
-- Tadc1 Events
GameEvents.CityConstructed.Add( Tadc1DigitalCircusAbility );
GameEvents.PlayerDoTurn.Add( Tadc1GoldenAgeTrait );
GameEvents.TeamTechResearched.Add( Tadc1BonusGoldenAgeStart );
-- Tadc2 Events
GameEvents.CityConstructed.Add( Tadc2GanglesTheaterAbility );
GameEvents.PlayerDoTurn.Add( Tadc2CheckForFreeGanglesTheater );