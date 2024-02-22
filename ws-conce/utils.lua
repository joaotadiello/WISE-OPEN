RegisterNUICallback('startBlur',function()
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end)

RegisterNUICallback('stopBlur',function()
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNetEvent('ws:fadeOut')
AddEventHandler('ws:fadeOut',function(time)
    DoScreenFadeOut(time)
end)

RegisterNetEvent('ws:fadeIn')
AddEventHandler('ws:fadeIn',function(time)
    DoScreenFadeIn(time)
end)