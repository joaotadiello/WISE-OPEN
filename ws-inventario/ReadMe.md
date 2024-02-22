# Codigos para instalação:
## Adicionar no vrp/base.lua

```lua
vRP.removeWeaponDataTable = function(user_id,weapon)
	if user_id then
		if vRP.user_tables[user_id].weapons and vRP.user_tables[user_id].weapons[weapon] then
			vRP.user_tables[user_id].weapons[weapon] = nil
			return true
		else
			return false
		end
	end
end
vRP.getWeaponsDataTable = function(user_id)
	if user_id then
		if vRP.user_tables[user_id].weapons then
			return vRP.user_tables[user_id].weapons
		end
	end
end
```

## Adicionar/trocar no vrp/modules/inventory.lua

```lua
	local Proxy = module('vrp','lib/Proxy')
	ws = Proxy.getInterface('ws-inventario')

function vRP.itemNameList(item)
	if item ~= nil then
		return ws.getItemName(item)
	end
end

function vRP.itemIndexList(item)
	if item ~= nil then
		return ws.getIndexItem(item)
	end
end

function vRP.itemTypeList(item)
	if item ~= nil then
		return ws.getItemType(item)
	end
end

function vRP.itemBodyList(item)
	if item ~= nil then
		return ws.getInfoItem(item)
	end
end

vRP.items = {}
function vRP.defInventoryItem()
	local itens = ws.defInventoryItem()
	if itens then
		vRP.items = itens
	else
		print('[INVENTORY ERROR] Erro ao criar os itens no VRP')
	end
end

function vRP.computeItemWeight(item)
	if item then
		return ws.getItemWeight(item)
	end
end



function vRP.getItemWeight(idname)
	return ws.getItemWeight(idname)
end


```

## Criar a função no vrp_homes
```lua
Proxy.addInterface("vrp_homes",src)
srv = Proxy.getInterface('ws-inventario')
src.getHomeChsestSize = function()
	return homes
end	
```
## 	Procurar a função src.checkIntPermissions(homeName) 
>	srv.openHomeChest(source,user_id,homeName)

UPDATE srv_data SET dvalue = REPLACE(dvalue,"wbody","wbody|");
UPDATE srv_data SET dvalue = REPLACE(dvalue,"wammo","wammo|");







