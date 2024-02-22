vRP.prepare("vRP/money_init_user","INSERT IGNORE INTO vrp_user_moneys(user_id,wallet,bank) VALUES(@user_id,@wallet,@bank)")
vRP.prepare("ws/get_money","SELECT bank FROM vrp_users WHERE id = @id")
vRP.prepare("ws/set_bank","UPDATE vrp_users SET bank = @bank WHERE id = @id")

function vRP.getBank(user_id)
	local consult = vRP.getInformation(user_id)
	if consult[1] then
		return consult[1].bank
	end
end

vRP.getMoney = function(user_id)
	if user_id then
		local amount = vRP.getInventoryItemAmount(user_id,"dollars")
		if amount then
			return amount
		else
			return 0
		end
	end
end

vRP.giveMoney = function(user_id,value)
	if user_id and value then
		vRP.giveInventoryItem(user_id,"dollars",parseInt(value))
	end
end

vRP.getBankMoney = function(user_id)
	if user_id then
		local bank = vRP.query('ws/get_money',{id= user_id})
		if bank then
			return bank[1].bank
		else
			return 0
		end
	end
end

vRP.setBankMoney = function(user_id,value)
	if user_id and value then
		vRP.execute('ws/set_bank',{bank = value,id = user_id})
	end
end

vRP.giveBankMoney = function(user_id,value)
	if user_id then
		local old = vRP.getBankMoney(user_id)
		if old then
			local new = parseInt(old + value)
			vRP.setBankMoney(user_id,new)
		end
	end
end

vRP.tryPayment = function(user_id,value)
	if user_id then
		local amount = vRP.getInventoryItemAmount(user_id,"dollars")
		if value <= amount then
			vRP.tryGetInventoryItem(user_id,"dollars",value)
			return true
		else	
			return false
		end
	end
end

vRP.tryFullPayment = function(user_id,value)
	if user_id and value then 
		if vRP.tryPayment(user_id,value) then
			return true
		else
			local bank = vRP.getBankMoney(user_id)
			if value <= bank then
				vRP.setBankMoney(user_id,parseInt(bank - value))
				return true
			else
				return false
			end
 		end
	end
end