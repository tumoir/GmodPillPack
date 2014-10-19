/*
 *	DO NOT USE THIS YET. IT IS NOT READY TO BE USED FOR ANYTHING.
 */

AddCSLuaFile()
module("momo",package.seeall)
_VERSION=0

include("momo/compat.lua")
include("momo/tf2lib.lua")
include("momo/console.lua")
include("momo/editor.lua")

_components={}
function registerComponent(compProto)
	if !compProto.name or type(compProto.name)!="string" then error("Attempted to register MoMo component with missing/invalid name!") end
	if !compProto.info or type(compProto.info)!="string" then error("Attempted to register MoMo component with missing/invalid info!") end
	if !compProto.schema or type(compProto.schema)!="table" then error("Attempted to register MoMo component with missing/invalid schema!") end
	_components[compProto.name]=compProto
end

/*Prevalidation:
	confirm id is set
	confirm parent is set to a valid type
	set abstract if not set
*/

local function validateForm(formTable)
	local id
	local extable = {}
	for k,v in pairs(formTable) do
		if type(v)=="table" then
			local compTable = v
			local compName = compTable[1]
			if !compName or type(compName)!="string" then return "Component #"..k.." has a missing/invalid type!" end
			if !_components[compName] then return 'Attempted to use nonexistent component type "'..compName..'"!' end
			
			local defTable = _components[compName]

			if defTable.exgroup then
				if extable[defTable.exgroup] then
					return 'Components "'..compName..'" and "'..extable[defTable.exgroup]..'" cannot be used together!'
				else
					extable[defTable.exgroup]=compName
				end
			end

			for k,propDef in pairs(defTable.schema) do
				local compError
				local optional = propDef.optional or (propDef.visible and not propDef.visible(compTable))

				local propValue = compTable[k]
				if propValue then
					if propDef.type and propDef.type!=type(propValue) then
						compError="must be a "..propDef.type
					elseif propDef.options and !table.HasValue(propDef.options,propValue) then
						compError="is not set to a valid option"
					elseif propDef.min and propValue<propDef.min then
						compError="is less than the minimum of "..propDef.min
					elseif propDef.max and propValue>propDef.max then
						compError="is greater than the maximum of "..propDef.max
					elseif propDef.mincomp and (propValue.x<propDef.mincomp or propValue.y<propDef.mincomp or propValue.z<propDef.mincomp) then
						compError="has a component value less than the minimum of "..propDef.mincomp
					elseif propDef.maxcomp and (propValue.x>propDef.maxcomp or propValue.y>propDef.maxcomp or propValue.z>propDef.maxcomp) then
						compError="has a component value greater than the maximum of "..propDef.maxcomp
					end
				elseif !optional then
					compError="must be set"
				end

				if compError then
					return 'Problem with component "'..compName..'": Property "'..k..'" '..compError..'!'
				end
			end

			//check agaist schema!
		elseif type(v)=="string" then
			if id then
				return "Multiple IDs have been set."
			end
			id = v
		end
	end
end



/*
local function validate_numeric(schema_table,obj)
	if obj._min then
		if f<obj._min then return false end
	end

	if obj._max then
		if f<obj._max then return false end
	end
end

local schema_types = {}

schema_types["int"]={
	validate=function(schema_table,obj)
		local i,f = math.modf(obj)
		if f!=0 then return false end
		
		return validate_numeric(schema_table,obj)
	end
}
*/

function registerForm(formTable)
	if CLIENT then return end
	//Force abstract to false if not true
	//Set metatable from parent
	//Do schema validation
	//Do custom validation?
	//Call register hooks
	//Register!
	local validate_error = validateForm(formTable)
	if validate_error then
		--print("Validation failed! "..validate_error)
	else
		--print("Validation successful!")
	end
end