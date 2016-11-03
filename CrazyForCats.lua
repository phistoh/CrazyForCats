----------------------------------
-- Changes
----------------------------------

-- 1.1b: Fixed combat check
-- 1.1: Added combat check
-- 1.0: Initial release

----------------------------------
-- Addon
----------------------------------
SLASH_CFC1 = "/crazyforcats"
SLASH_CFC2 = "/cfc"

SlashCmdList["CFC"] = function(args)
	-- test if the user is in combat and don't do anything if so
	if UnitAffectingCombat("player") then
		print("Cannot summon a pet in combat.")
		return
	end
	
	-- gets the default table in the separate lua file
	local table_of_pets = pet_tables[cats]
	
	-- 
	-- local args=SecureCmdOptionParse(args);
	
	-- if a argument was given get the corresponding table
	if args ~= nil then
		table_of_pets = pet_tables[args:lower()]
		-- if there is no such table return an error
		if table_of_pets == nil then
			print("Table " .. args .. " is nil. :(")
			return
		end
	end
	
	-- selects a random pet in the table cat and stores the name in pet_to_summon
	local pet_to_summon = GetRandomArgument(unpack(table_of_pets))
	
	-- returns petGUID of pet_to_summon
	local _,p=C_PetJournal.FindPetIDByName(pet_to_summon)
	
	-- if the pet doesn't exist return an error
	if p == nil then
		print("Cannot summon " .. pet_to_summon .. ". :(")
		return
	end
	
	-- if the pet is not currently summoned then summon it
	if C_PetJournal.GetSummonedPetGUID()~=p then
		C_PetJournal.SummonPetByGUID(p)
	end
end
