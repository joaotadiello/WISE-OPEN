local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPServer = Tunnel.getInterface('vRP')

config = {}

config.weapons = {
    "WEAPON_DAGGER",
	"WEAPON_BAT",
	"WEAPON_BOTTLE",
	"WEAPON_CROWBAR",
	"WEAPON_FLASHLIGHT",
	"WEAPON_GOLFCLUB",
	"WEAPON_HAMMER",
	"WEAPON_HATCHET",
	"WEAPON_KNUCKLE",
	"WEAPON_KNIFE",
	"WEAPON_MACHETE",
	"WEAPON_SWITCHBLADE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_WRENCH",
	"WEAPON_BATTLEAXE",
	"WEAPON_POOLCUE",
	"WEAPON_STONE_HATCHET",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_SNSPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_REVOLVER",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_MUSKET",
	"WEAPON_FLARE",
	"GADGET_PARACHUTE",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_MICROSMG",
	"WEAPON_SMG",
	"WEAPON_ASSAULTSMG",
	"WEAPON_COMBATPDW",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_GUSENBERG",
	"WEAPON_PETROLCAN",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_COMPACTRIFLE"
}

config.core = {
	slotNumber = 24,

	giveWeaponToPlayer = function(weapon)
        print(weapon)
        local hash = split(weapon,"|")[2]
        GiveWeaponToPed(PlayerPedId(),hash,0)
		vRP.giveWeapons({[hash] = { ammo = 0 }})
	end,

	giveAmmoToPlayer = function(weapon,amount)
        local hash = split(weapon,"|")[2]
        AddAmmoToPed(PlayerPedId(),hash,tonumber(amount))
	end,

	vehInfo = function(radius)
		local vehicle,vnetid,placa,vname,lock,banned,trunk = vRP.vehList(radius)
		return vehicle,vnetid,placa,vname,lock,banned,trunk
	end,

	setarColete = function(value)
		SetPedArmour(PlayerPedId(),value)
	end,

	itemColete = 'colete',
}

config.chest = {
	['teste'] = {
		cds = vec3(977.1,-104.08,74.85),
		permi = "admin.permissao",
		tamanho = 5000,
		exibir = true,
		log = "https://discord.com/api/webhooks/790835904818315275/K93jrNNVRJq510zFboHvQxzdRzrCQIT9LGygwe5QsorLqkaSBRwzvzwnBIupxGufrTkp",
		icon = "cofre22"
	},
}

----------------------------------------------------------------------
--- [ Confiuração para shop ]
----------------------------------------------------------------------
config.coordenadaDepartamento = {
    [1] = {coord = vec3(27.8,-1346.94,29.5),type = "arsenal" },
    [2] = {coord = vec3(0,0,0),type = "ammo" },
	
}

config.keyMappin = function()
	RegisterKeyMapping('inv', 'Abrir inventario', 'keyboard', "oem_3")
	RegisterKeyMapping('_trunk', 'Porta mala', 'keyboard', "PAGEUP")

	RegisterKeyMapping('bind1', 'Invetario', 'keyboard', "1")
    RegisterKeyMapping('bind2', 'Invetario', 'keyboard', "2")
    RegisterKeyMapping('bind3', 'Invetario', 'keyboard', "3")
    RegisterKeyMapping('bind4', 'Invetario', 'keyboard', "4")
end

split = function(str, sep)
    if sep == nil then sep = "%s" end
    local t={}
    local i=1
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

return config
