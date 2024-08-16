local addonName, phis = ...

local phisFrame = CreateFrame('Frame', addonName..'CheckFrame', UIParent)
phisFrame:RegisterEvent('ADDON_LOADED')

-- to control automatic summoning of pets
phisFrame:RegisterEvent('PLAYER_STARTED_MOVING')
phisFrame:RegisterEvent('UNIT_EXITED_VEHICLE')
phisFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
phisFrame:RegisterEvent('ZONE_CHANGED')
phisFrame:RegisterEvent('ZONE_CHANGED_INDOORS')
phisFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
phisFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
phisFrame:RegisterEvent('PLAYER_UPDATE_RESTING')
phisFrame:RegisterEvent('PLAYER_ALIVE')
phisFrame:RegisterEvent('PLAYER_UNGHOST')

-- controls the icons to indicate personal favorites
local personalFavoriteIcons = {}


-- globals for keybindings
BINDING_HEADER_CRAZYFORCATS = addonName
BINDING_NAME_CRAZYFORCATS_SUMMON_RANDOM = "Summon random pet"
CrazyForCatsGlobals = {}

-------------------------
--   AUXILIARY STUFF   --
-------------------------

local function getLength(tbl)
	length = 0
	for k,v in pairs(tbl) do
		length = length + 1
	end
	return length
end

local function addonPrint(str)
	print('|cFFABD473'..addonName..':|r '..str)
end

-------------------------
--   FRAME FACTORIES   --
-------------------------

local function createInset(name, parent, w, h, anchor, ofsX, ofsY, label, content)
	local newInset = CreateFrame('Frame', name, parent, 'InsetFrameTemplate3')
	newInset:SetSize(w,h)
	newInset:SetPoint(anchor, ofsX, ofsY)
	
	newInset.content = newInset:CreateFontString(addonName..name..'ContentFontString', 'ARTWORK', 'GameFontHighlightSmall')
	newInset.content:SetPoint('RIGHT', -10, 0)
	newInset.content:SetJustifyH('RIGHT')
	newInset.content:SetText(content)
	
	newInset.label = newInset:CreateFontString(addonName..name..'LabelFontString', 'ARTWORK', 'GameFontNormalSmall')
	newInset.label:SetPoint('LEFT', 10, 0)
	newInset.label:SetPoint('RIGHT', newInset.content, 'LEFT', -3, 0)
	newInset.label:SetJustifyH('LEFT')
	newInset.label:SetText(label)
	
	return newInset
end

local function createCheckbox(name, parent, anchor, relativeFrame, relativePoint, ofsX, ofsY, tooltip, bgPath, height, width, label, default)
	local newCheckbox = CreateFrame('CheckButton', addonName..name, parent, 'InterfaceOptionsCheckButtonTemplate')
	newCheckbox:SetPoint(anchor, relativeFrame, relativePoint, ofsX, ofsY)
	
	newCheckbox:SetHeight(height)
	newCheckbox:SetWidth(width)
	
	if label ~= nil then
		newCheckbox.Text:SetFontObject("GameFontNormalSmall")
		newCheckbox.Text:SetPoint("LEFT", newCheckbox, "RIGHT", 0, 1)
		newCheckbox.Text:SetText(label)
	end
	
	newCheckbox:SetScript('OnEnter', function()
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetPoint('BOTTOMRIGHT', newCheckbox, 'TOPRIGHT', 0, 0);
		GameTooltip:SetText(tooltip)
		GameTooltip:Show()
	end)
	
	newCheckbox:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	
	newCheckbox.background = newCheckbox:CreateTexture(nil, 'BACKGROUND')
	newCheckbox.background:SetWidth(24)
	newCheckbox.background:SetHeight(24)
	if bgPath ~= nil then
		newCheckbox.background:SetTexture(bgPath)
	end
	newCheckbox.background:SetPoint('CENTER',newCheckbox)
	
	newCheckbox:SetChecked(default)

	return newCheckbox
end

local function createPersonalFavoriteIcon(name, parent)
	local personalFavoriteIcon = parent:CreateTexture(addonName..name, 'OVERLAY', nil, 0)
	personalFavoriteIcon:SetAtlas('PetJournal-FavoritesIcon', true)
	personalFavoriteIcon:SetPoint('RIGHT', parent, 'RIGHT', -2, 0)
	personalFavoriteIcon:SetDesaturated(true)
	personalFavoriteIcon:SetVertexColor(0.250, 0.780, 0.921)

	return personalFavoriteIcon
end

-------------------------
--   ADDON FUNCTIONS   --
-------------------------
-- updates the list to show star icons in the scroll frame on personal favorites
local function updateList()
	
	-- since frames get reused, hide all favorite icons before opening the journal to make sure that a frame which now shows a non favorite pet does not keep its icon
	for _, v in pairs(personalFavoriteIcons) do
		v:Hide()
	end
	
	if PetJournal:IsVisible() then
		local currentView = PetJournal.ScrollBox:GetView()
		local visiblePetCards = currentView:GetFrames()
		
		for k, v in pairs(visiblePetCards) do
			local petID = v.petID
			
			if personalFavoriteIcons[v] == nil then
				personalFavoriteIcons[v] = createPersonalFavoriteIcon('.visiblePetCards.personalFavoriteIcon', v)
			end
			personalFavoriteIcons[v]:Hide()
			
			-- only show the icon again if the frame contains a pet whose petID is in the set of personal favorites
			if personalPetDB[petID] then
				personalFavoriteIcons[v]:Show()
			end
		end
	end
end

local function summonRandom()
	-- if addon not initialized
	if personalPetCount == nil or personalPetDB == nil then
		addonPrint('Addon not yet initialized. Open the pet journal...')
		return
	end

	-- cannot summon pets in combat
	if UnitAffectingCombat('player') then
		addonPrint('Cannot summon a pet in combat.')
		return
	end
	
	-- add all pets from the chosen table to an (ordinary) array to make unpack() work
	if personalPetCount > 0 then
		local tmpIDs = {}
		for k in pairs(personalPetDB) do
			table.insert(tmpIDs, k)
		end
		local petID = tmpIDs[math.random(#tmpIDs)]
		C_PetJournal.SummonPetByGUID(petID)
	else
		addonPrint('No personal pet favorites set.')
	end
end
-- add to globals for keybindings
CrazyForCatsGlobals.summonRandom = summonRandom

-- petIDs are used as keys for more efficient lookup
local function updateDB(petID, addPet)
	if addPet and personalPetDB[petID] == nil then
		personalPetDB[petID] = true
		personalPetCount = personalPetCount + 1
	elseif not addPet and personalPetDB[petID] ~= nil then
		personalPetDB[petID] = nil
		personalPetCount = math.max(personalPetCount - 1, 0)
	end
end

local function initAddon()
	
	--- SETUP VARIABLES ---
	
	if personalAutoSummonToggle == nil then
		personalAutoSummonToggle = false
	end
	
	if personalPetDB == nil then
		personalPetDB = {}
	end
	
	if personalPetCount == nil then
		personalPetCount = 0
		local playerName, playerRealm = UnitFullName('player')
		local _, playerClass = UnitClass('player')
		local _, _, _, classColor = GetClassColor(playerClass)
		addonPrint('Addon loaded for the first time on |c'..classColor..playerName..'|r-'..playerRealm..'.')
	end

	--- CREATE AND ATTACH FRAMES ---
	local petInset = createInset('PersonalFavoritesPetInset', PetJournal, 150, 20, 'BOTTOMRIGHT', -270, 4, 'Personal favorites: ', personalPetCount)
	
	local checkBoxPet = createCheckbox('PersonalFavoriteCheckBox', PetJournalPetCard, 'TOPRIGHT', PetJournalPetCard, 'BOTTOMRIGHT', -175, 54, 'Add this pet to your personal favorites', 'Interface\\Addons\\CrazyForCats\\Icons\\paw', 38, 38)
	checkBoxPet:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local petID = PetJournalPetCard.petID
		updateDB(petID, checked)
		updateList()
		petInset.content:SetText(personalPetCount)
	end)
	-- local function createCheckbox(name, parent, anchor, relativeFrame, relativePoint, ofsX, ofsY, tooltip, bgPath, height, width)
	local checkBoxAutoSummon = createCheckbox('AutoSummonCheckBox', PetJournal, 'LEFT', petInset, 'RIGHT', 5, 0, 'Toggle the automatic summoning of pets', nil, 26, 26, 'Auto summon', personalAutoSummonToggle)
	checkBoxAutoSummon:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		personalAutoSummonToggle = checked
	end)
	
	hooksecurefunc('PetJournal_UpdatePetCard', function()
		local petID = PetJournalPetCard.petID
		if petID == nil then
			checkBoxPet:Hide()
		else
			checkBoxPet:Show()
			checkBoxPet:SetChecked(personalPetDB[petID] == true)
		end
	end)
	
	hooksecurefunc('PetJournal_UpdatePetList', updateList)
	PetJournal.ScrollBox:HookScript('OnMouseWheel', updateList)
	
	
	personalPetCount = getLength(personalPetDB)
end

-- checks if both the addon itself and the Blizzard Collections addon are loaded
local function checkInit(self, addon)
	if addon == addonName then
		_, isLoaded = C_AddOns.IsAddOnLoaded('Blizzard_Collections')
		if isLoaded then
			initAddon()
			phisFrame:UnregisterEvent('ADDON_LOADED')
		end
	elseif addon == 'Blizzard_Collections' then
		initAddon()
		phisFrame:UnregisterEvent('ADDON_LOADED')
	end
end

local function checkAutoSummon(self)
	-- auto summoning is not initialized
	if personalAutoSummonToggle == nil then
		personalAutoSummonToggle = false
		return
	-- the addon is disabled
	elseif not personalAutoSummonToggle then
		return
	-- don't overwrite the already summoned pet
	elseif C_PetJournal.GetSummonedPetGUID() ~= nil then
		return
	-- cannot summon a pet in combat
	elseif UnitAffectingCombat('player') then
		return
	-- don't interfere with grouped content
	elseif IsInInstance() then
		return
	-- don't waste global cooldown so emergency actions (flight form, glider, ...) are possible
	elseif IsFalling() then
		return
	-- summoning a pet removes stealth
	elseif IsStealthed() then
		return
	-- don't possibly dismount the player in the air
	elseif IsFlying() then
		return
	-- cannot summon a pet in pet battle
	elseif C_PetBattles.IsInBattle() then
		return
	-- cannot summon a pet on gryphon service
	elseif UnitOnTaxi('player') then
		return
	-- cannot summon a pet in vehicles
	elseif UnitInVehicle('player') then
		return
	else
		summonRandom()
	end
end

-------------------------
--    SLASH COMMANDS   --
-------------------------

SLASH_CFC1 = '/crazyforcats'
SLASH_CFC2 = '/cfc'

SlashCmdList['CFC'] = function(msg)
	if msg:lower() == 'toggle' then
		personalAutoSummonToggle = not personalAutoSummonToggle
		addonPrint('Automatic summoning of pets is now '..(personalAutoSummonToggle and 'active' or 'inactive')..'.')
	else
		summonRandom()
	end
end

-- phisFrame:SetScript('OnEvent', checkInit)
phisFrame:SetScript('OnEvent', function(self, event, addon)
	if event == 'ADDON_LOADED' then
		checkInit(self, addon)
	else
		checkAutoSummon(self)
	end
end)