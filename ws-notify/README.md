# Como utilizar

```lua
--- Client-side
exports['ws-notify']:NotifyItens(image,name,amount,action)

--- Server-side
TriggerClientEvent('NotifyItens',source,image,name,amount,action)