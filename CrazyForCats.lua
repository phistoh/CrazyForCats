local addonName, phis = ...

local phisFrame = CreateFrame('Frame', 'phisCheckFrame', UIParent)
phisFrame:RegisterEvent('ADDON_LOADED')

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
	
	newInset.content = newInset:CreateFontString(name..'ContentFontString', 'ARTWORK', 'GameFontHighlightSmall')
	newInset.content:SetPoint('RIGHT', -10, 0)
	newInset.content:SetJustifyH('RIGHT')
	newInset.content:SetText(content)
	
	newInset.label = newInset:CreateFontString(name..'LabelFontString', 'ARTWORK', 'GameFontNormalSmall')
	newInset.label:SetPoint('LEFT', 10, 0)
	newInset.label:SetPoint('RIGHT', newInset.content, 'LEFT', -3, 0)
	newInset.label:SetJustifyH('LEFT')
	newInset.label:SetText(label)
	
	return newInset
end

local function createCheckbox(name, parent, anchor, relativeFrame, relativePoint, ofsX, ofsY, tooltip, bgPath)
	local newCheckbox = CreateFrame('CheckButton', name, parent, 'UICheckButtonTemplate')
	newCheckbox:SetPoint(anchor, relativeFrame, relativePoint, ofsX, ofsY)
	
	newCheckbox:SetHeight(38)
	newCheckbox:SetWidth(38)
	
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
	newCheckbox.background:SetTexture(bgPath)
	newCheckbox.background:SetPoint('CENTER',newCheckbox)

	return newCheckbox
end

-------------------------
--   ADDON FUNCTIONS   --
-------------------------
local function summonRandom()
	-- if addon not initialized
	if personalPetCount == nil or personalPetDB == nil then
		addonPrint('Addon not yet initialized. Open the pet journal...')
		return
	end

	-- cannot cummon pets in combat
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
		local petID = GetRandomArgument(unpack(tmpIDs))
		C_PetJournal.SummonPetByGUID(petID)
	else
		addonPrint('No personal pet favorites set.')
	end
end
-- add to globals for keybindings
CrazyForCatsGlobals.summonRandom = summonRandom

-- mountIDs are used as keys for more efficient lookup
local function updateDB(petID, addMount)
	if addMount and personalPetDB[petID] == nil then
		personalPetDB[petID] = true
		personalPetCount = personalPetCount + 1
	elseif not addMount and personalPetDB[petID] ~= nil then
		personalPetDB[petID] = nil
		personalPetCount = math.max(personalPetCount - 1, 0)
	end
end

local function initAddon()
	--- SETUP VARIABLES ---
	
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
	local petInset = createInset('petInset', PetJournal, 150, 20, 'BOTTOMRIGHT', -270, 4, 'Personal favorites: ', personalPetCount)
	
	local checkBoxPet = createCheckbox('CrazyForPetsCheckBox', PetJournalPetCard, 'TOPRIGHT', PetJournalPetCard, 'BOTTOMRIGHT', -175, 54, 'Add this pet to your personal favorites', 'Interface\\Addons\\CrazyForCats\\Icons\\paw')
	checkBoxPet:SetScript('OnClick', function(self)
		local checked = self:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		local petID = PetJournalPetCard.petID
		updateDB(petID, checked)
		petInset.content:SetText(personalPetCount)
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
	
	personalPetCount = getLength(personalPetDB)
end

-- checks if both the addon itself and the Blizzard Collections addon are loaded
local function checkInit(self, event, addon)
	if addon == addonName then
		if IsAddOnLoaded('Blizzard_Collections') then
			initAddon()
			phisFrame:UnregisterEvent('ADDON_LOADED')
		end
	elseif addon == 'Blizzard_Collections' then
		initAddon()
		phisFrame:UnregisterEvent('ADDON_LOADED')
	end
end

-------------------------
--    SLASH COMMANDS   --
-------------------------

SLASH_CFC1 = '/crazyforcats'
SLASH_CFC2 = '/cfc'

SlashCmdList['CFC'] = function(msg)
	summonRandom()
end

phisFrame:SetScript('OnEvent', checkInit)