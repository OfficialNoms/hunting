# hunting Activity

[REQUIREMENTS]
  
* ESX Legacy
* Linden_inventory ``https://github.com/thelindat/linden_inventory``
* PolyZone ``https://github.com/mkafrin/PolyZone``
* Noms' Experimental version of Bt-Target ``https://github.com/OfficialNoms/bt-target``
* mythic_notify ``https://github.com/thelindat/mythic_notify``
* mythic_progbar ``https://github.com/thelindat/mythic_progbar``
* Changes to Linden Inventory (see below)
* There is included a second client/main.lua file if the first one is not functioning for your version of ESX as the way it handles GetClosestPed changes from version to version.


# Inspired by qalle-esx-hunting used as reference in creation.
# Contributed to by thelindat, DRKM43 ``network code and ped spawner respectively``
# Optimisations and rewrites by noms and Linden

# No Promises if it will function for previous version of ESX with the nature of the natives called, if it does, poggers, if not, I'm sure someone'll figure it out.
You are free to edit whatever it is that might tickle your fancy, just don't try to profit off of it or anything dickish like that.

[INSTALLATION]

1) Download/copy files/open in desktop etc.

2) Add to your server.cfg :
``ensure PolyZone``

``ensure bt-target``
``ensure hunting``

3) Import tiny SQL file, perhaps find pictures for your inventory hud etc.
``import items.sql``


4) (TEMPORARY) Make the following changes to linden_inventory\server\functions.lua

Find `CreateNewDrop = function(xPlayer, data)` replace with `CreateNewDrop = function(xPlayer, data, newid)`
Under `local invid2 = xPlayer.source` in the same function, add: 
```lua
if newid ~= nil then 
	invid = newid
end
```

find the `end` of the `if data.type == 'freeslot' then` statement and replace with 
```lua
elseif data.type == 'create' then 
    Drops[invid].inventory[data.toSlot] = {name = data.item.name, label = data.item.label, weight = data.item.weight, slot = data.toSlot, count = data.item.count, description = data.item.description, metadata = data.item.metadata, stackable = data.item.stackable, closeonuse = Items[data.item.name].closeonuse}
    Opened[xPlayer.source] = nil
    TriggerClientEvent('linden_inventory:createDrop', -1, Drops[invid], xPlayer.source)
end
```

add `exports('CreateNewDrop', CreateNewDrop)` under the function to export it




## Changelog (noms)

* Uses statebags to check if a carcass is being skinned
* Grammar changes
* Creates a drop with the meat instead of giving it directly to you
* Does NOT give leather yet, change is pending
* Includes a table to track animal weight instead of straight RNG (goodbye rats having 16KG of meat on them)