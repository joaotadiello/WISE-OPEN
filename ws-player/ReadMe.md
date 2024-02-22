```lua
vRP.check_weapon = function(user_id,weapon)
	if user_id then
		if vRP.user_tables[user_id].weapons and vRP.user_tables[user_id].weapons[weapon] then
			return true
		else
			return false
		end
	end
end
```
