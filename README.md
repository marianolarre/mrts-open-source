# MRTS: the Garry's Mod sandbox RTS minigame

This is an addon for Garry's Mod that gives the players the ability to set up their own Real Time Strategy match inside of the normal sandbox gamemode.

## Identity and guidelines

MRTS follows a few design principles that are required for pull requests to be accepted into the master branch:
- The addon should not require models, sounds, textures or any file that could fail or look like an error to a player that joins a server without downloads enabled.
- All troops, buildings and contraption parts should be data driven, meaning that all of their properties should be modifiable via text files known as datapacks.
- The game should be able to handle atleast 100 units in total without severe lag.

## Open Source

In order to update the addon in the workshop page, submit a pull request using git, and if it gets approved, the original author will upload it to the workshop.
If you are a trusted collaborator, you may be added as a collaborator in the workshop page and be able to upload by yourself.

## Final touches before release

These are the things I'd like the addon to have before getting a full release
- Contraptions: the player is able to, in their own time and out of battle, build machines using props and special parts to create vehicles. These vehicles can then be spawned during a match using a special building. The contraption costs time and money to spawn, and its destroyable, either part by part or all at once.
- Balance: the balance of the game is in a state where its fun and not frustrating to play, and matches aren't prolonged for more than one or two minutes once a victory or defeat is inevitable.
- Minimal micromanagement: the effectiveness of micromanagement is as low as possible. A player that uses good team composition and tactics should be able to win without an inmense amount of physical skill and speed.