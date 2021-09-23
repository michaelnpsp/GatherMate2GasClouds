local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate2")

local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2", true)

local importStyle = 'Merge'

local Config = GatherMate:GetModule("Config")
Config:RegisterImportModule('GatherMate2_GasData', {
	type = "group",
	name = L["Gas Clouds"] .. " <by MiCHaEL>",
	args = {
		desc = {
			order = 1,
			type = "description",
			name = "Importing Gas Clouds Data for Burning Crusade <by MiCHaEL>",
		},
		loadType = {
			order = 2,
			name = L["Import Style"],
			desc = "Merge will add Gas Clouds to your database. Overwrite will replace your Gas Clouds database.",
			type = "select",
			set = function(info,value) importStyle = value end,
			get = function() return importStyle	end,
			values = { Merge = L["Merge"], Overwrite = L["Overwrite"] },			
		},
		import = {
			order = 3,
			name = "Import Gas Clouds",
			type = "execute",
			func = function()
				if importStyle == 'Overwrite' then 
					GatherMate:ClearDB("Extract Gas") 
				end
				for zoneID, node_table in pairs(GatherMateData2GasCloudsDB) do
					if not zoneFilter or zoneFilter[zoneID] then
						for coord, nodeID in pairs(node_table) do
							GatherMate:InjectNode2(zoneID,coord,"Extract Gas", nodeID)
						end
					end
				end
				print("GatherMate2: Gas Clouds Database has been imported.")
				Config:SendMessage("GatherMate2ConfigChanged")
			end,			
		},
		separator = {
			order = 4,
			type = "description",
			name = "\nGas Clouds Database Maintenance"
		},	
		repair = {
			order = 5,
			width = 'double',
			name = "Repair Gas Clouds Database",
			desc = "Gathermate2 may incorrect marks all new discovered nodes as Steam Clouds. This process repairs the gas clouds database assigning the correct nodes types.",
			type = "execute",
			func = function()
				local count = 0
				for zone, nodes in pairs(GatherMate2GasDB) do
					local validNodes = GatherMateData2GasCloudsDB[zone]
					if validNodes then
						local _, validNodeID = next(validNodes)
						if validNodeID then
							for coord, nodeID in pairs(nodes) do
								if nodeID~=validNodeID then
									nodes[coord] = validNodeID
									count = count + 1
								end
							end
						end	
					end	
				end
				print( count>0 and string.format( "GatherMate2: Gas Clouds Database Repaired, %d gas clouds have been fixed!", count) or "GatherMate2: Gas Clouds Database verified, there is nothing to fix!" )
				Config:SendMessage("GatherMate2ConfigChanged")
			end,
			confirm = true,
			confirmText = "Are you sure you want to verify and repair the Gas Clouds Database ?",
		}
	},
})
