/*
////////////////////////////// 12-06-2025 b
Added 3 player map: `mrts_triage`
Updated `mrts_playground`'s thumbnail
Improved watch tower's ability to fire over walls

////////////////////////////// 12-06-2025
Changed capture zone visuals and collision shape to be a circle (the fixed square didn't fit well in maps with triangular symmetry)
Reduced general capture rate to half speed, and limited capture speed to take a minimum of 8 seconds
Fixed the 'Place HQ' button placing capturable HQs
Claimable buildings remain claimable even after claiming so that they can change teams in case you change your mind. They become unclaimable on match start
Added a button that resets every building, troop and capture zone to the way it was just before the last Match Start

////////////////////////////// 11-06-2025
Added entities 'ent_mrts_unit_marker' to be able to add entities directly in the hammer editor
You can configure unit markers using key-values in hammer
> type: building / troop
> uniquename: <the uniquename of the building or troop>
> capturable: 0 / 1
> claimable: 0 / 1
For example, to make a claimable HQ you need an ent_mrts_unit_marker entity with the following key-values:
> type: building
> uniquename: hq
> claimable: 1
To make a capturable water pump, you need the following key-values:
> type: building
> uniquename: waterpump
> capturable: 1
Added entity 'ent_mrts_kill_pole'. Old 'ent_mrts_bound_pole' no longer kills units outside its bounds, it just prevents building. To make a death zone, use the new kill poles instead.
You can now connect poles together using key-values in hammer
> targetname: <a name to refer to this pole>
> next: <the targetname of the pole to connect to>
There is now a setting to make MRTS entities like poles, capture zones and kill planes unmovable and indestructible if they are part of the map
Capture zones now show the progress in the outline aswell, since the old square was usually blocked if there was a building in the center
Unclaimed claimable buildings now disappear on match start
Added a map called 'mrts_playground' (I'm very new at hammer, this map is mostly for testing. Better maps will come later)
Reduced HQ housing from 25 to 20

////////////////////////////// 09-06-2025
Fixed ally area targeting
Increased hunter's hound's health from 2 to 4
Fixed housing description saying it provides 5 housing when it should say 10
Changed max population from 75 to 80
Fixed bound pole clientside 'out of bounds' indicator, and bound poles now work correctly when copy-pasted

////////////////////////////// 03-08-2024
Water pump:
    cost changed from 300 water and 100 energy, to 200 water and 200 energy
Added categories to split buildings into 'Base', 'Economy' and 'Barracks' tabs
fixed error when units lost their target in fog of war
fixed building overlap detection

////////////////////////////// 26-12-2024
Added a hint when trying to build somewhere you can't build
Made it so that you can't build on objects with the Super Ice physics material (wasn't working before)
Working on contraption assembler. The building can spawn contraptions, but contraptions themselves are pretty jank still