defaultMrtsGameData = {
	info={
		name="MRTS: Vanilla",
		author="Marum",
		description="Many factions fight over the final remains of the most valuable resource: Water",
		additive=false
	},
	teams={
		{
			name="Neutral",
			color={r=100, g=100, b=100},
			order=1,
			neutral=true
		},
		{
			name="Red",
			color={r=255,g=50,b=50},
			order=2
		},
		{
			name="Blue",
			color={r=80,g=100,b=255},
			order=3
		},
		{
			name="Yellow",
			color={r=255,g=200,b=50},
			order=4
		},
		{
			name="Green",
			color={r=60,g=180,b=60},
			order=5
		},
		{
			name="Purple",
			color={r=150,g=30,b=150},
			order=6
		},
		{
			name="Cyan",
			color={r=50,g=240,b=255},
			order=7
		},
		{
			name="Orange",
			color={r=255,g=120,b=0},
			order=8
		},
		{
			name="Pink",
			color={r=255,g=100,b=150},
			order=9
		}
	},
	factions={
		{
			name="Default",
			uniqueName="default",
			icon="icon16/circle_cross.png",
			order=1
		}
		,{
			name="Testing faction",
			uniqueName="testfaction",
			icon="icon16/monkey.png",
			whitelist={
				"warbanner",
				"engineer"
			},
			replacements={
				{"hq", "monkeyhq"},
				{"scout", "monkey"},
				{"medic", "battlemedic"},
				{"shield", "berserker"},
				{"sniper", "railgunner"},
				{"scoutbarracks", "monkeybarracks"}
			},
			order=2
		}
	},
	resources= {
		{
			name="Water",
			uniqueName="water",
			order=1,
			description="A versatile and valuable material used to create most weapons, and pay most soldiers.",
			icon="💧",
			startingAmount=100
		},
		{
			name="Energy",
			uniqueName="energy",
			order=2,
			description="A rare fuel used to power the mightiest machines.",
			icon="⚡"
		},
		{
			name="Influence",
			uniqueName="influence",
			order=3,
			description="You can spend influense to atract freelancers",
			icon="🚩",
			startingAmount=10
		}
	},
	status= {
		{
			name="Speed boost",
			description="Increase speed by 100%",
			uniqueName="status_speedboost",
			icon="icon16/control_fastforward.png",
			speed=2
		},
		{
			name="Fire",
			description="Deals 1.5 damage per second",
			uniqueName="status_fire",
			icon="icon16/fire.png",
			dot=1.5
		},
		{
			name="Regen",
			description="Heal 2 health per second",
			uniqueName="status_regen",
			icon="icon16/heart_add.png",
			heal=2
		},
		{
			name="Resistance",
			description="Decrease damage taken by 40%",
			uniqueName="status_resistance",
			icon="icon16/shield.png",
			damageTaken=0.6
		},
		{
			name="Invulnerability",
			description="Becomes invulnerable",
			uniqueName="status_invulnerability",
			icon="icon16/star.png",
			damageTaken=0
		},
		{
			name="Damage boost",
			description="Increase damage dealt by 50%",
			uniqueName="status_damageboost",
			icon="icon16/asterisk_orange.png",
			damageDealt=1.5
		},
		{
			name="Sick",
			description="Decrease damage dealt, fire rate and movement speed by 25%, and increases damage taken by 25%",
			uniqueName="status_sick",
			icon="icon16/bug.png",
			damageDealt=0.75,
			speed=0.75,
			fireRate=0.75,
			damageTaken=1.25
		},
		{
			name="Rage",
			description="Increase fire rate by 100%",
			uniqueName="status_rage",
			icon="icon16/emoticon_evilgrin.png",
			fireRate=2
		}
	},
	troops = {
		{
			name= "Scout",
			uniqueName= "scout",
			category="Troops",
			order=1,
			description= "The cheapest and weakest unit, useful for capturing, exploring and occationally absorb bullets, but you didn't hear that from me. Don't underestimate its damage when in groups.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 200,
			attack= {
				type= "basic",
				delay= 0.7,
				windup= 0.1,
				damage= 3,
				chaseRange= 160,
				range= 10,
				effect= {
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "physics/body/body_medium_impact_hard4.wav",
					pitch= 150,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=10},
			income= {},
			buildTime= 2,
			housing=0,
			population=1,
			mass= 1,
			size= 5,
			maxHealth= 7,
			speed= 60,
			icon="👟",
			model="models/dav0r/hoverball.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			color={r=50,g=50,b=50,a=0.6},
			accessories={{
				model="models/weapons/w_stunbaton.mdl",
				scale={x=0.75,y=1,z=1},
				idle={
					offset={x=0,y=-6,z=0},
					rotation={x=0,y=-80,z=0}
				},
				attack={
					offset={x=-10,y=-6,z=15},
					rotation={x=-25,y=180,z=0}
				}
			}}
		},
		{
			name= "War Banner",
			uniqueName= "warbanner",
			category="Troops",
			factionSpecific=true,
			order=1,
			description= "Provides speed to nearby troops",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			passive= {
				type="self",
				delay= 0.75,
				radius=60,
				status={
					type="status_speedboost",
					duration=1
				},
				targeting={
					allies=true
				}
			},
			sight= 100,
			attack= {
				type= "basic",
				delay= 0.7,
				windup= 0.1,
				damage= 3,
				chaseRange= 30,
				range= 10,
				effect= {
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "physics/body/body_medium_impact_hard4.wav",
					pitch= 150,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=100},
			income= {},
			buildTime= 3,
			housing=0,
			population=1,
			mass= 1,
			size= 5,
			maxHealth= 7,
			speed= 40,
			icon="✊",
			model="models/dav0r/hoverball.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			barOffset=20,
			color={r=50,g=50,b=50,a=0.6},
			accessories={
				{
					model="models/weapons/w_stunbaton.mdl",
					scale={x=0.75,y=1,z=1},
					idle={
						offset={x=0,y=-6,z=0},
						rotation={x=0,y=-80,z=0}
					},
					attack={
						offset={x=-10,y=-6,z=15},
						rotation={x=-25,y=180,z=0}
					},
				},
				{
					model="models/props_trainstation/TrackSign03.mdl",
					scale={x=0.5,y=0.5,z=0.5},
					idle={
						offset={x=0,y=0,z=0},
						rotation={x=0,y=0,z=0}
					},
					backpack=true
				}
			}
		},
		{
			name= "Monkey",
			uniqueName= "monkey",
			category="Troops",
			order=1,
			factionSpecific= true,
			description= "A wild one, let me tell yah (This is a test unit for the Factions feature)",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 0.7,
				windup= 0.1,
				damage= 3,
				chaseRange= 160,
				range= 10,
				effect= {
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "ambient/voices/m_scream1.wav",
					pitch= 255,
					volume= 75
				}
			},
			captureSpeed = 0.025,
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=10},
			income= {},
			buildTime= 1.5,
			housing=0,
			population=1,
			mass= 1,
			size= 5,
			maxHealth= 3,
			speed= 90,
			icon="🐵",
			model="models/dav0r/hoverball.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			color={r=0,g=0,b=0,a=0.6},
			accessories={{
				model="models/Gibs/HGIBS_spine.mdl",
				material="models/props_pipes/GutterMetal01a",
				scale={x=1,y=1,z=1},
				idle={
					offset={x=0,y=0,z=8},
					rotation={x=90,y=90,z=180}
				},
				backpack=true
			}}
		},
		{
			name= "Hound",
			uniqueName= "hound",
			category="Troops",
			order=99,
			unlisted= true,
			description= "A wild one, let me tell yah (This is a test unit for the Factions feature)",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			autonomous= true,
			sight= 80,
			attack= {
				type= "basic",
				delay= 0.7,
				windup= 0.1,
				damage= 3,
				chaseRange= 160,
				range= 10,
				effect= {
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "ambient/voices/m_scream1.wav",
					pitch= 200,
					volume= 75
				}
			},
			captureSpeed = 0.025,
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "infantry",
			cost= {water=0},
			income= {},
			buildTime= 1.5,
			housing=0,
			population=0,
			mass= 0.1,
			force=0.1,
			size= 5,
			maxHealth= 4,
			lifetime= 5,
			speed= 90,
			icon="🐺",
			model="models/dav0r/hoverball.mdl",
			scale={x=0,y=0,z=0},
			rolling=true,
			material="phoenix_storms/cube",
			accessories={{
				model="models/props_lab/tpplug.mdl",
				scale={x=1,y=1,z=1},
				idle={
					offset={x=0,y=0,z=0},
					rotation={x=0,y=0,z=180}
				},
				tint=true,
				backpack=true
			}}
		},
		{
			name= "Soldier",
			uniqueName= "soldier",
			category="Troops",
			order=2,
			description= "A basic troop, cheap and realiable. They find their strength in numbers, but aren't that effective on their own. With some support troops, the Soldier can add a lot of damage per second to a squad.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 0.75,
				windup= 0,
				damage= 3,
				range= 150,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 200,
					volume= 68
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=20},
			income= {},
			buildTime= 3,
			housing=0,
			population=1,
			mass= 1,
			size= 8,
			maxHealth= 10,
			speed= 40,
			icon="🎖",
			model="models/props_junk/watermelon01.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			accessories={{
				model="models/weapons/w_smg1.mdl",
				scale={x=0.75,y=1,z=1},
				idle={
					offset={x=10,y=-8,z=0},
					rotation={x=0,y=0,z=0}
				},
				attack={
					offset={x=5,y=-8,z=0},
					rotation={x=0,y=20,z=0}
				},
				weapon=true
			}}
		},
		{
			name= "Medic",
			uniqueName= "medic",
			category="Troops",
			order=3,
			description= "Great for keeping troops at top health after tough battles. Useful against area damage if its not enough to take your troops out, or as a support to keep the frontlines alive for longer.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 1.5,
				windup= 0,
				healing= 1,
				range= 150,
				status= {
					type="status_regen",
					duration=2
				},
				targeting= {
					allies= true,
					hurt= true,
					types= {"infantry"},
					blacklist = {"medic"}
				},
				effect= {
					trail= "healbeam",
					hit="heal"
				},
				sound= {
					path= "items/medshot4.wav",
					pitch= 200,
					volume= 68
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=50},
			income= {},
			buildTime= 5,
			housing=0,
			population=1,
			mass= 1,
			size= 6,
			maxHealth= 10,
			speed= 40,
			icon="⚕",
			model="models/dav0r/hoverball.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			color={r=255,g=255,b=255,a=0.5},
			accessories={{
				model="models/healthvial.mdl",
				scale={x=1,y=1,z=1},
				idle={
					offset={x=7,y=0,z=-3},
					rotation={x=0,y=0,z=0}
				},
				attack={
					offset={x=9,y=0,z=0},
					rotation={x=0,y=-20,z=0}
				},
				weapon=true
			}}
		},
		{
			name= "Battle Medic",
			uniqueName= "battlemedic",
			category="Troops",
			factionSpecific= true,
			order=3,
			description= "Fight the enemy and heal your teammates when there's time.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			charge={
				max=20,
				passiveGain=1,
				cost=5,
				attack= {
					type= "basic",
					delay= 1.5,
					windup= 0,
					healing= 1,
					range= 150,
					status= {
						type="status_regen",
						duration=2
					},
					targeting= {
						allies= true,
						hurt= true,
						types= {"infantry"},
						blacklist = {"medic"}
					},
					effect= {
						trail= "healbeam",
						hit="heal"
					},
					sound= {
						path= "items/medshot4.wav",
						pitch= 200,
						volume= 68
					}
				},
			},
			attack= {
				type= "basic",
				delay= 0.75,
				windup= 0,
				damage= 3,
				range= 150,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 200,
					volume= 68
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=75},
			income= {},
			buildTime= 5,
			housing=0,
			population=1,
			mass= 1,
			size= 8,
			maxHealth= 10,
			speed= 40,
			icon="💉",
			model="models/props_junk/watermelon01.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			accessories={
				{
					model="models/weapons/w_smg1.mdl",
					scale={x=0.75,y=1,z=1},
					idle={
						offset={x=10,y=-8,z=0},
						rotation={x=0,y=0,z=0}
					},
					attack={
						offset={x=5,y=-8,z=0},
						rotation={x=0,y=20,z=0}
					},
					weapon=true,
				},
				{
					model="models/Items/HealthKit.mdl",
					scale={x=0.75,y=0.75,z=0.75},
					idle={
						offset={x=-2,y=0,z=5},
						rotation={x=0,y=90,z=0}
					},
					backpack=true
				}
			}
		},
		{
			name= "Shield",
			uniqueName= "shield",
			category="Troops",
			order=4,
			description= "These guys can tank a lot of damage, making them the ideal front-line infantry bullet sponges. They don't do a lot of damage on their own, but can help those troops that actually deal good damage to do their job for longer.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 2,
				windup= 0.2,
				damage= 3,
				range= 150,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/alyx_gun/alyx_gun_fire5.wav",
					pitch= 150,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=50},
			income= {},
			buildTime= 5,
			housing=0,
			population=2,
			mass= 1,
			size= 6,
			maxHealth= 70,
			speed= 40,
			icon="🛡",
			model="models/props_junk/watermelon01.mdl",
			barOffset=5,
			color={r=180,g=180,b=180,a=0.4},
			rolling=true,
			accessories={
				{
					model="models/weapons/w_pistol.mdl",
					scale={x=0.7,y=1.2,z=1.2},
					idle={
						offset={x=-8,y=7,z=0},
						rotation={x=0,y=0,z=180}
					},
					attack={
						offset={x=-5,y=7,z=0},
						rotation={x=0,y=30,z=180}
					},
					weapon=true
				},
				{
					model="models/props_doors/door03_slotted_left.mdl",
					scale={x=0.5,y=0.25,z=0.15},
					idle={
						offset={x=8,y=-3,z=0},
						rotation={x=0,y=10,z=0}
					}
				}
			}
		},
		{
			name= "Hunter",
			uniqueName= "hunter",
			category="Troops",
			order=5,
			description= "Fights with a short range shotgun and throws out hounds to distract.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type="spawn",
				troop="hound",
				spread=2,
				burst=3,
				forwardVelocity=1,
				upwardVelocity=1.5,
				stunTime=0.75,
				delay=6,
				range=150,
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=50},
			income= {},
			buildTime= 5,
			housing=0,
			population=2,
			mass= 1,
			size= 8,
			maxHealth= 12,
			speed= 40,
			icon="🐺",
			model="models/props_junk/watermelon01.mdl",
			scale={x=1,y=1,z=1},
			color={r=0,g=0,b=0,a=0.3},
			barOffset=5,
			rolling=true,
			accessories={
				{
					model="models/props_interiors/pot02a.mdl",
					material="models/props_foliage/tree_deciduous_01a_trunk",
					scale={x=1.2, y=1.2, z=1.2},
					color={r=0,g=0,b=0,a=0.5},
					idle={
						offset={x=0,y=-6,z=-8},
						rotation={x=180,y=0,z=-90}
					},
					backpack=true
				},
				{
					model="models/props_lab/kennel_physics.mdl",
					scale={x=0.2,y=0.2,z=0.2},
					idle={
						offset={x=0,y=10,z=-5},
						rotation={x=0,y=0,z=0},
					}
				}
			}
		},
		{
			name= "Berserker",
			uniqueName= "berserker",
			category="Troops",
			factionSpecific= true,
			order=5,
			description= "These guys heal themselves when facing an enemy.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			charge= {
				max=4,
				startingAmount=4,
				passiveGain=1,
				cost= 4,
				hideBar= true,
				attack= {
					type= "self",
					delay= 0.1,
					windup= 0.1,
					healing= 5,
					range= 150,
					effect= {
						start= "heal"
					},
					targeting= {
						types= {"infantry", "vehicle", "building"}
					},
					status= {
						type="status_regen",
						duration=5
					},
					sound= {
						path= "vo/npc/male01/pain07.wav",
						pitch= 150,
						volume= 75
					}
				}
			},
			attack= {
				type= "basic",
				delay= 1.4,
				windup= 0.2,
				damage= 3,
				range= 150,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/alyx_gun/alyx_gun_fire5.wav",
					pitch= 150,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=75},
			income= {},
			buildTime= 5,
			housing=0,
			population=2,
			mass= 1,
			size= 6,
			maxHealth= 65,
			speed= 40,
			icon="🛡",
			model="models/props_junk/watermelon01.mdl",
			barOffset=5,
			color={r=180,g=180,b=180,a=0.4},
			rolling=true,
			accessories={
				{
					model="models/weapons/w_pistol.mdl",
					scale={x=0.7,y=1.2,z=1.2},
					idle={
						offset={x=-8,y=7,z=0},
						rotation={x=0,y=0,z=180}
					},
					attack={
						offset={x=-5,y=7,z=0},
						rotation={x=0,y=30,z=180}
					},
					weapon=true
				}
			}
		},
		{
			name= "Bazooka",
			uniqueName= "bazooka",
			category="Troops",
			order=6,
			description= "A solid response against tanky targets, this troop can fire a quick shot that deals massive damage, crippling sturdy units and buildings. With their slow firing rate they struggle against swarms.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft6.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 4.5,
				windup= 0.5,
				damage= 75,
				range= 150,
				effect= {
					start= "heavymuzzle",
					trail= "heavysmoketrail",
					hit="explosion"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/rpg/rocketfire1.wav",
					pitch= 200,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=80},
			buildTime= 8,
			housing=0,
			population=2,
			mass= 1,
			size= 12,
			maxHealth= 15,
			speed= 40,
			icon="🧨",
			model="models/props_junk/plasticbucket001a.mdl",
			scale={x=1,y=1,z=1},
			offset={x=0,y=0,z=0},
			barOffset=5,
			rolling=false,
			color={r=0,g=0,b=0,a=0.5},
			accessories={{
				model="models/weapons/w_rocket_launcher.mdl",
				scale={x=0.7,y=1,z=1},
				idle={
					offset={x=-15,y=7,z=8},
					rotation={x=0,y=0,z=180}
				},
				attack={
					offset={x=-15,y=7,z=8},
					rotation={x=0,y=5,z=180}
				},
				weapon=true
			}}
		},
		{
			name= "Flamer",
			uniqueName= "flamer",
			category="Troops",
			order=7,
			description= "A troop with decent area damage that can chip away at groups of infantry, softening them up for other troops to finish the job faster. Really good at clearing hoards of weak units. The fire doesn't stack so having more than one or two flamers will not increase their damage by much.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "basic",
				offset= 10,
				radius= 25,
				delay= 0.33,
				windup= 0.5,
				damage= 0.25,
				range= 150,
				status={
					type="status_fire",
					duration=1
				},
				effect= {
					start= "heavymuzzle",
					bullettrail= "smoketrail"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"},
					allies= false
				},
				sound= {
					path= "weapons/iceaxe/iceaxe_swing1.wav",
					pitch= 20,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=80},
			income= {},
			buildTime= 8,
			housing=0,
			population=2,
			mass= 1,
			size= 13,
			maxHealth= 20,
			speed= 40,
			icon="🔥",
			model="models/props_junk/PropaneCanister001a.mdl",
			rolling=false,
			color={r=0,g=0,b=0,a=0.5},
			accessories={
				{
					model="models/props_c17/FurnitureBoiler001a.mdl",
					scale={x=0.2,y=0.2,z=0.2},
					weapon=true,
					idle={
						offset={x=0,y=-4,z=6},
						rotation={x=0,y=-90,z=0}
					}
				},
				{
					model="models/props_junk/gascan001a.mdl",
					scale={x=0.5,y=0.5,z=0.5},
					backpack=true,
					idle={
						offset={x=-8,y=0,z=0},
						rotation={x=0,y=0,z=0}
					}
				}
			}
		},
		{
			name= "Bomb",
			uniqueName= "bomb",
			category="Troops",
			order=8,
			description= "A self destructing troop with a huge explosion radius that can anhialate infantry and delete buildings. A well placed bomb can turn the tide of a battle. Bombs need to detonate and won't explode if killed. They have low health so sending bombs in the open might not work. Use corners and cannon fodder to protect the bomb until it reaches its target.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/metal/metal_solid_impact_soft2.wav",
			sight= 160,
			attack= {
				type= "self",
				radius=50,
				damage= 100,
				selfDestruct=true,
				chaseRange= 160,
				range= 10,
				windup= 0.35,
				effect= {
					start= "giantexplosion"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "ambient/explosions/explode_1.wav",
					pitch= 100,
					volume= 75
				}
			},
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "vehicle",
			cost= {influence=1,water=100},
			buildTime= 8,
			housing=0,
			population=2,
			mass= 2,
			size= 7,
			maxHealth= 25,
			speed= 60,
			icon="💣",
			model="models/dynamite/dynamite.mdl",
			material="models/shiny",
			modelOffset={x=0,y=0,z=-6},
			rolling= true
		}
		,
		{
			name= "Gunner",
			uniqueName= "gunner",
			category="Troops",
			order=9,
			description= "Gunners have a long range and are great anti-infantry troop, but they have to stay still and setup for a while before they can shoot. Great for area denial and defense, or giving your pushing forces a safe place to retreat.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 200,
			attack= {
				type= "trace",
				spread= 2,
				setup= 4,
				delay= 0.5,
				burst= 3,
				burstDelay= 0.1,
				windup= 0,
				damage= 4,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 90,
					volume= 68
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=150, energy=10},
			income= {},
			buildTime= 10,
			housing=0,
			population=2,
			mass= 1,
			size= 10,
			maxHealth= 20,
			speed= 40,
			icon="icon16/gun.png",
			model="models/Roller.mdl",
			scale={x=1,y=1,z=1},
			rolling=true,
			color={r=0,g=0,b=0,a=0.5},
			accessories={{
				model="models/weapons/w_irifle.mdl",
				scale={x=0.75,y=1,z=1},
				idle={
					offset={x=-15,y=7,z=0},
					rotation={x=0,y=0,z=180}
				},
				attack={
					offset={x=-12,y=7,z=0},
					rotation={x=0,y=5,z=180}
				},
				setup={
					offset={x=-15,y=7,z=0},
					rotation={x=10,y=90,z=180}
				},
				weapon=true
			}}
		},
		{
			name= "Sniper",
			uniqueName= "sniper",
			category="Troops",
			order=10,
			description= "Long range anti-infantry, not that effective against groups. Can fire over walls, and their range make them good defense against important low health units. They need some time to set up after moving. Can be useful to poke enemies and force them to either retreat or chase.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft6.wav",
			sight= 250,
			attack= {
				type= "basic",
				setup= 3,
				delay= 3,
				windup= 0.5,
				damage= 25,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/pistol/pistol_fire2.wav",
					pitch= 70,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=150, energy=10},
			buildTime= 10,
			housing=0,
			population=2,
			mass= 1,
			size= 20,
			maxHealth= 15,
			speed= 40,
			icon="🔍",
			model="models/props_junk/propane_tank001a.mdl",
			rolling=false,
			barOffset=5,
			firingOffset={x=0,y=0,z=15},
			accessories={{
				model="models/weapons/w_crossbow.mdl",
				scale={x=0.75,y=0.75,z=0.75},
				idle={
					offset={x=0,y=-5,z=10},
					rotation={x=0,y=0,z=0}
				},
				attack={
					offset={x=-1,y=-5,z=10},
					rotation={x=0,y=10,z=0}
				},
				setup={
					offset={x=-5,y=0,z=5},
					rotation={x=45,y=-90,z=0}
				},
				weapon=true
			}}
		},
		{
			name= "Railgunner",
			uniqueName= "railgunner",
			category="Troops",
			factionSpecific=true,
			order=10,
			description= "Long range anti-infantry, not that effective against groups. Can fire an extra powerful shot after getting enough charge.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft6.wav",
			sight= 200,
			charge= {
				max=3,
				attackGain=1,
				cost= 3,
				attack= {
					type= "basic",
					delay= 2,
					windup= 0.5,
					damage= 25,
					range= 250,
					effect= {
						start= "heavymuzzle",
						trail= "heavysmoketrail",
						hit="explosion"
					},
					targeting= {
						types= {"infantry", "vehicle", "building"}
					},
					sound= {
						path= "weapons/alyx_gun/alyx_gun_fire3.wav",
						pitch= 50,
						volume= 75
					}
				}
			},
			attack= {
				type= "basic",
				delay= 1,
				windup= 0.5,
				damage= 2.5,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/alyx_gun/alyx_gun_fire3.wav",
					pitch= 255,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=200, energy=25},
			buildTime= 10,
			housing=0,
			population=2,
			mass= 1,
			size= 20,
			maxHealth= 15,
			speed= 40,
			icon="🔍",
			model="models/props_junk/propane_tank001a.mdl",
			rolling=false,
			firingOffset={x=0,y=0,z=15},
			accessories={{
				model="models/props_combine/bunker_gun01.mdl",
				scale={x=0.75,y=0.75,z=0.75},
				idle={
					offset={x=8,y=-5,z=0},
					rotation={x=0,y=-5,z=0}
				},
				attack={
					offset={x=7,y=-5,z=0},
					rotation={x=0,y=-4,z=0}
				},
				weapon=true
			}}
		},
		{
			name= "Grenadier",
			uniqueName= "grenadier",
			category="Troops",
			order=11,
			description= "A troop with decent area damage that can chip away at groups of infantry, softening them up for other troops to finish the job faster. Having a lot of grenadiers can devastate big groups of enemies very quickly. Doesn't deal well with tanky units.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight= 160,
			attack= {
				type= "projectile_arc",
				arc= 1.25 ,
				prediction= 1,
				radius= 25,
				delay= 1.2,
				windup= 0.5,
				damage= 5,
				range= 150,
				effect= {
					start= "heavydiagonalmuzzle",
					bullet = "shell",
					bullettrail= "smoketrail",
					bullethit="explosion"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/crossbow/fire1.wav",
					pitch= 150,
					volume= 75
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "ground",
			type= "infantry",
			cost= {influence=1,water=200, energy=25},
			income= {},
			buildTime= 10,
			housing=0,
			population=3,
			mass= 1,
			size= 9,
			maxHealth= 25,
			speed= 40,
			icon="☀",
			model="models/props_phx/misc/soccerball.mdl",
			rolling=true,
			accessories={
				{
					model="models/weapons/w_rocket_launcher.mdl",
					scale={x=0.3,y=1,z=1},
					idle={
						offset={x=-15,y=-6,z=-5},
						rotation={x=0,y=210,z=0}
					},
					attack={
						offset={x=-12,y=-6,z=-5},
						rotation={x=0,y=230,z=0}
					},
					weapon=true
				}
			}
		},
		{
			name= "Mortar",
			uniqueName= "mortar",
			category="Troops",
			order=12,
			description= "After standing still for a while, the mortar becomes a long range poker that can destroy structures from afar, forcing the enemy to come out and fight on your terms. It can only attack buildings.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/metal/metal_barrel_impact_hard6.wav",
			sight= 90,
			attack= {
				type= "projectile_arc",
				arc=2 ,
				prediction= 0,
				radius= 10,
				setup= 5,
				windup= 0,
				delay= 3,
				damage= 50,
				range= 300,
				effect= {
					start= "heavydiagonalmuzzle",
					bullet = "shell",
					bullettrail= "shelltrail",
					bullethit="explosion"
				},
				targeting= {
					types= {"building"}
				},
				sound= {
					path= "weapons/357/357_fire2.wav",
					pitch= 50,
					volume= 75
				}
			},
			canAttackWhileMoving= false,
			ignoresWalls= true,
			moveType= "ground",
			type= "vehicle",
			cost= {influence=1,water=300, energy=75},
			income= {},
			buildTime= 15,
			population=3,
			housing=0,
			mass= 2,
			size= 10,
			maxHealth= 30,
			speed= 40,
			icon="☄",
			model="models/props_phx/games/chess/black_rook.mdl",
			offset={x=0,y=0,z=0},
			barOffset=20,
			accessories={
				{
					model="models/props_phx/wheels/drugster_back.mdl",
					scale={x=0.15,y=0.15,z=0.5},
					idle={
						offset={x=8,y=0,z=4},
						rotation={x=0,y=-20,z=0}
					},
					attack={
						offset={x=8,y=0,z=0},
						rotation={x=0,y=-20,z=0}
					},
					setup={
						offset={x=7,y=-10,z=-10},
						rotation={x=-90,y=0,z=0}
					},
				}
			}
		},
		{
			name= "Tank",
			uniqueName= "tank",
			category="Troops",
			order=13,
			description= "An endgame slow but tanky breacher that can attack while moving. Protect it from bazookas.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft6.wav",
			sight= 160,
			attack= {
				type= "basic",
				delay= 4,
				windup= 0.5,
				damage= 75,
				range= 150,
				effect= {
					start= "heavymuzzle",
					trail= "heavysmoketrail",
					hit="explosion"
				},
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
				sound= {
					path= "weapons/rpg/rocketfire1.wav",
					pitch= 200,
					volume= 75
				}
			},
			captureSpeed = 0,
			canAttackWhileMoving= true,
			moveType= "ground",
			type= "infantry",
			cost= {influence=2,water=500, energy=250},
			buildTime= 30,
			housing=0,
			population=5,
			mass= 20,
			force= 20,
			size= 18,
			maxHealth= 450,
			speed= 20,
			icon="🚙",
			model="models/Combine_Helicopter/helicopter_bomb01.mdl",
			scale={x=0,y=0,z=0},
			offset={x=0,y=0,z=0},
			barOffset=5,
			rolling=true,
			color={r=0,g=0,b=0,a=0.5},
			accessories={
				{
					model="models/props_combine/CombineTrain01a.mdl",
					scale={x=0.05,y=0.2,z=0.075},
					idle={
						offset={x=2,y=0,z=-20},
						rotation={x=0,y=0,z=180}
					},
					tint=true,
					lookForward=true
				},
				{
					model="models/Items/BoxSRounds.mdl",
					scale={x=2.5,y=0.8,z=1},
					idle={
						offset={x=0,y=0,z=-3},
						rotation={x=0,y=0,z=90}
					},
					material="models/debug/debugwhite",
					tint=true,
					backpack=true
				},
				{
					model="models/props_phx/wheels/drugster_back.mdl",
					scale={x=0.1,y=0.1,z=0.3},
					idle={
						offset={x=-3,y=0,z=0},
						rotation={x=0,y=-90,z=0}
					}
				}
			}
		}
	},
	buildings = {
		{
			name= "Sandbox HQ",
			uniqueName= "sandboxhq",
			order=1,
			description= "Your main base",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			type= "building",
			cost= {},
			income= {water=1000, energy=1000, influence=10,},
			capacity= {water=1000, energy=1000, influence=10,},
			buildTime= 0.5,
			population= 0,
			housing=200,
			maxHealth= 1000,
			objective= true,
			icon="icon16/building_edit.png",
			model="models/props_c17/statue_horse.mdl",
			offset={x=0,y=-8,z=0},
			size={x=25,y=25,z=30},
			makesTroop={
				troop="scout",
				cost= {water=10},
				time= 1,
				spawnMargin=20
			},
			buildingRange=300,
			barOffset=25,
			unlisted=true,
			sight= 300,
		},
		{
			name= "HQ",
			defaultHQ= true,
			uniqueName= "hq",
			order=2,
			description= "Your main base",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			firingOffset={x=0,y=0,z=20},
			sight= 300,
			attack= {
				type= "basic",
				delay= 1,
				windup= 0,
				damage= 3,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 50,
					volume= 68
				}
			},
			type= "building",
			cost= {},
			income= {water=5, influence=0.1},
			capacity= {water=250, energy=50, influence=5},
			buildTime= 0.5,
			population= 0,
			housing=20,
			maxHealth= 1000,
			objective= true,
			icon="icon16/building.png",
			model="models/props_combine/combinethumper002.mdl",
			offset={x=-10,y=20,z=-8},
			size={x=25,y=40,z=30},
			buildingRange=300,
			barOffset=25,
			unlisted=true
		},
		{
			name= "Monkey Clan HQ",
			uniqueName= "monkeyhq",
			order=2.1,
			description= "Your main base",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			sight= 300,
			attack= {
				type= "basic",
				delay= 1,
				windup= 0,
				damage= 3,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 50,
					volume= 68
				}
			},
			type= "building",
			cost= {},
			income= {water=5, influence=0.1},
			capacity= {water=250, energy=50, influence=5},
			buildTime= 0.5,
			population= 0,
			housing=25,
			maxHealth= 1000,
			objective= true,
			icon="icon16/building.png",
			model="models/props_foliage/tree_deciduous_01a-lod.mdl",
			offset={x=0,y=0,z=0},
			size={x=10,y=10,z=30},
			buildingRange=300,
			barOffset=25,
			unlisted=true,
			factionSpecific = true
		},
		{
			name= "Wall",
			uniqueName= "wall",
			category="Base",
			order=4,
			description= "Basic defense, blocks line of chaseRange. Its short enough to allow turrets and snipers to fire over it.",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			type= "building",
			cost= {water=75},
			income= {},
			buildTime= 10,
			population=0,
			housing=0,
			maxHealth= 150,
			icon="icon16/tab.png",
			model="models/props_trainstation/traincar_rack001.mdl",
			size={x=13,y=50,z=5},
			offset={x=0,y=0,z=11},
			angle={x=-90,y=0,z=180},
			sight= 50,
		}
		,
		{
			name= "Door",
			uniqueName= "door",
			category="Base",
			order=5,
			description= "A wall that can be opened and closed by pressing E on it",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			keepMaterial=true,
			type= "building",
			cost= {water=100},
			income= {},
			buildTime= 10,
			population=0,
			housing=0,
			maxHealth= 150,
			icon="icon16/door.png",
			model="models/props_phx/trains/track_32.mdl",
			size={x=13,y=50,z=5},
			offset={x=0,y=0,z=11},
			angle={x=-90,y=0,z=0},
			activation={
				type="move",
				time=1,
				offset={x=0,y=0,z=50}
			},
			accessories={
				{
					model="models/mechanics/solid_steel/sheetmetal_u_4.mdl",
					fixed=true,
					scale={x=2,y=2.5,z=1},
					offset={x=-30,y=0,z=0},
					rotation={x=0,y=0,z=0}
				}
			},
			sight= 50,
		}
		,
		{
			name= "Relay",
			uniqueName= "relay",
			category="Base",
			order=6,
			description= "Expands your building area",
			spawnSound= "doors/door_metal_large_close2.wav",
			deathSound= "ambient/explosions/explode_2.wav",
			type= "building",
			cost= {water=100},
			buildTime= 10,
			population=0,
			maxHealth= 100,
			icon="icon16/transmit.png",
			model="models/xqm/pistontype1big.mdl",
			offset={x=0,y=0,z=21},
			size={x=10,y=10,z=32},
			buildingRange=300,
			barOffset=25,
			sight= 300,
		},
		{
			name= "House",
			uniqueName= "housing",
			category="Economy",
			order=7,
			description= "Increase your population housing by 10, allowing you to build more troops. Housing spaces can only go up to 80.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=100},
			buildTime= 10,
			population=0,
			housing=10,
			maxHealth= 100,
			icon="icon16/house.png",
			model="models/Items/item_item_crate.mdl",
			offset={x=0,y=0,z=0},
			size={x=15,y=15,z=12},
			sight= 50,
		},
		{
			name= "Water tank",
			uniqueName= "watertank",
			category="Economy",
			order=8,
			description= "Increase your water capacity by 50, allowing the construction of more expensive buildings later on.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=100},
			capacity={water= 50},
			buildTime= 10,
			population=0,
			maxHealth= 250,
			icon="icon16/database.png",
			model="models/props_wasteland/laundry_washer001a.mdl",
			offset={x=0,y=5,z=20},
			size={x=38,y=38,z=27},
			sight= 50,
		},
		{
			name="Watch Tower",
			uniqueName= "watchtower",
			category="Base",
			order=9,
			description="A tall static long-range defense that can shoot over walls",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=150},
			buildTime= 10,
			population=1,
			maxHealth= 125,
			icon="icon16/joystick.png",
			model="models/mechanics/robotics/a2.mdl",
			material="models/props_wasteland/wood_fence01a",
			color={r=255,g=255,b=255,a=1},
			offset={x=0,y=0,z=10},
			angle={x=90,y=0,z=0},
			size={x=24,y=8,z=8},
			turretLength=16,
			firingOffset={x=-32,y=0,z=0},
			sight= 250,
			barOffset= 20,
			attack= {
				type= "trace",
				delay= 1,
				spread= 1,
				windup= 0,
				damage= 8,
				range= 250,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 50,
					volume= 68
				}
			},
			accessories={
				{
					model="models/props_junk/watermelon01.mdl",
					tint=true,
					backpack=true,
					material="models/debug/debugwhite",
					idle={
						offset={x=0,y=0,z=32},
						rotation={x=0,y=0,z=0}
					}
				},
				{
					model="models/props_phx/construct/windows/window1x1.mdl",
					material="models/props_wasteland/wood_fence01a",
					scale={x=0.4,y=0.4,z=2},
					fixed=true,
					offset={x=-28,y=0,z=0},
					rotation={x=90,y=0,z=0}
				},
				{
					model="models/weapons/w_smg1.mdl",
					scale={x=0.75,y=1,z=1},
					pivot={x=-32,y=0,z=0},
					idle={
						offset={x=10,y=-8,z=0},
						rotation={x=0,y=0,z=0}
					},
					attack={
						offset={x=5,y=-8,z=0},
						rotation={x=0,y=20,z=0}
					},
					weapon=true
				}
			}
		},
		{
			name="Radar",
			uniqueName= "radar",
			category="Base",
			order=10,
			fowOnly=true,
			description="A tower that provides a large sight range in Fog of War. It reveals itself when revealing enemies.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=200, energy=100},
			buildTime= 10,
			population=1,
			maxHealth= 125,
			icon="icon16/transmit_blue.png",
			model="models/props_phx/trains/double_wheels2.mdl",
			offset={x=0,y=0,z=0},
			angle={x=0,y=0,z=0},
			size={x=15,y=15,z=45},
			firingOffset={x=-16,y=0,z=0},
			sight= 500,
			attack= {
				type= "basic",
				delay=1,
				range= 500,
				targeting= {
					types= {"infantry", "vehicle", "building"}
				},
			},
			accessories={
				{
					model="models/props_rooftop/satellitedish02.mdl",
					scale={x=1,y=1,z=1},
					spin={x=0,y=0,z=45},
					lookForward=true,
					idle= {
						offset={x=0,y=0,z=108},
						rotation={x=0,y=0,z=0}
					}
				}
			}
		},
		{
			name= "Energy Collector",
			uniqueName= "energycollector",
			category="Economy",
			order=11,
			description= "Generates 1 energy per second.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=300},
			income= {energy=1},
			buildTime= 10,
			population=0,
			maxHealth= 100,
			icon="icon16/lightning.png",
			model="models/props_combine/weaponstripper.mdl",
			offset={x=64,y=0,z=0},
			angle={x=-90,y=0,z=0},
			size={x=10,y=64,z=64},
			accessories={
				{
					model="models/xqm/panel4x4.mdl",
					fixed=true,
					scale={x=1.2,y=1.2,z=1.2},
					offset={x=-50,y=-40,z=24},
					rotation={x=90,y=0,z=0}
				}
			},
			sight= 50,
		},
		{
			name= "Energy Accumulator",
			uniqueName= "energyaccumulator",
			category="Economy",
			order=12,
			description= "Increase your energy capacity by 50.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=300, energy=50},
			capacity={energy= 50},
			buildTime= 10,
			population=0,
			maxHealth= 250,
			icon="icon16/database_lightning.png",
			model="models/props_wasteland/laundry_washer003.mdl",
			offset={x=0,y=0,z=26},
			size={x=52,y=27,z=27},
			sight= 50,
		},
		{
			name= "Water pump",
			uniqueName = "waterpump",
			category="Economy",
			order=13,
			description= "Produces 1 water per second",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=200, energy=200},
			income= {water=1},
			buildTime= 10,
			maxHealth= 250,
			icon="icon16/water.png",
			model="models/props_wasteland/buoy01.mdl",
			offset={x=0,y=0,z=40},
			size={x=25,y=25,z=60},
			sight= 50,
		},
		{
			name= "Scout Barracks",
			uniqueName= "scoutbarracks",
			category="Barracks",
			order=13,
			description= "Train scouts by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=100},
			buildTime=10,
			population=0,
			maxHealth= 200,
			color={r=50,g=50,b=50,a=0.6},
			icon="👟",
			model="models/props_junk/TrashBin01a.mdl",
			offset={x=0,y=0,z=20},
			size={x=12,y=10,z=20},
			makesTroop={
				troop="scout",
				cost= {water=10},
				time= 1,
				spawnMargin=5
			},
			sight= 50,
		},
		{
			name= "Monkey Barracks",
			uniqueName= "monkeybarracks",
			category="Barracks",
			order=14,
			factionSpecific= true,
			description= "Train monkeys by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=100},
			buildTime=10,
			population=0,
			maxHealth= 200,
			color={r=50,g=50,b=50,a=0.6},
			icon="🐵",
			model="models/props_phx/wheels/drugster_front.mdl",
			offset={x=0,y=0,z=0},
			size={x=15,y=15,z=20},
			makesTroop={
				troop="monkey",
				cost= {water=7},
				time= 1,
				spawnMargin=5
			},
			accessories= {
				{
					model="models/props_foliage/tree_deciduous_01a.mdl",
					scale={x=0.1,y=0.1,z=0.1},
					offset={x=0,y=0,z=0},
					rotation={x=0,y=0,z=0},
					fixed= true
				}
			},
			sight= 50,
		},
		{
			name= "Soldier Barracks",
			uniqueName= "soldierbarracks",
			category="Barracks",
			order=15,
			description= "Train soldiers by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=200},
			buildTime=15,
			population=0,
			maxHealth= 300,
			icon="🎖",
			model="models/Items/ammoCrate_Rockets.mdl",
			offset={x=0,y=0,z=10},
			size={x=16,y=28,z=13},
			makesTroop={
				troop="soldier",
				cost= {water=20},
				time= 2
			},
			accessories={{
				model="models/Items/BoxMRounds.mdl",
				scale={x=1,y=1,z=1},
				offset={x=0,y=0,z=10},
				rotation={x=0,y=0,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Medic Barracks",
			uniqueName= "medicbarracks",
			category="Barracks",
			order=16,
			description= "Train medics by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=300},
			buildTime=20,
			population=0,
			maxHealth= 300,
			icon="⚕",
			model="models/props_c17/FurnitureWashingmachine001a.mdl",
			offset={x=0,y=0,z=20},
			angle={x=0,y=180,z=0},
			size={x=18,y=16,z=20},
			makesTroop={
				troop="medic",
				cost= {water=50},
				time= 5
			},
			color={r=255,g=255,b=255,a=0.4},
			accessories={{
				model="models/Items/HealthKit.mdl",
				scale={x=1.5,y=1.5,z=1.5},
				offset={x=-8,y=0,z=15},
				rotation={x=0,y=0,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Shield Barracks",
			uniqueName= "shieldbarracks",
			category="Barracks",
			order=17,
			description= "Train shields by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=300},
			buildTime=20,
			population=0,
			maxHealth= 300,
			icon="🛡",
			model="models/props_junk/wood_crate001a.mdl",
			offset={x=0,y=0,z=20},
			angle={x=0,y=0,z=0},
			size={x=20,y=20,z=20},
			makesTroop={
				troop="shield",
				cost= {water=50},
				time= 5
			},
			color={r=255,g=255,b=255,a=0.2},
			accessories={{
				model="models/props_debris/metal_panel02a.mdl",
				scale={x=0.8,y=0.8,z=0.4},
				offset={x=22,y=0,z=-8},
				rotation={x=0,y=0,z=0},
				fixed=true,
			},{
				model="models/props_debris/metal_panel02a.mdl",
				scale={x=0.8,y=0.8,z=0.4},
				offset={x=-22,y=0,z=-8},
				rotation={x=0,y=180,z=0},
				fixed=true,	
			},{
				model="models/props_debris/metal_panel02a.mdl",
				scale={x=0.8,y=0.8,z=0.4},
				offset={x=0,y=22,z=-8},
				rotation={x=0,y=90,z=0},
				fixed=true,	
			},{
				model="models/props_debris/metal_panel02a.mdl",
				scale={x=0.8,y=0.8,z=0.4},
				offset={x=0,y=-22,z=-8},
				rotation={x=0,y=270,z=0},
				fixed=true,	
			}},
			sight= 50,
		},
		{
			name= "Hunter Barracks",
			uniqueName= "hunterbarracks",
			category="Barracks",
			order=18,
			description= "Train hunters by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=300},
			buildTime=20,
			population=0,
			maxHealth= 300,
			icon="🐺",
			model="models/props_lab/kennel_physics.mdl",
			offset={x=0,y=0,z=0},
			angle={x=0,y=180,z=0},
			size={x=27,y=18,z=20},
			makesTroop={
				troop="hunter",
				cost= {water=50},
				time= 5
			},
			color={r=0,g=0,b=0,a=0.4},
			accessories={{
				model="models/props_interiors/pot02a.mdl",
				material="models/props_foliage/tree_deciduous_01a_trunk",
				scale={x=1.5, y=1.5, z=1.5},
				offset={x=0,y=0,z=43},
				rotation={x=180,y=-90,z=0},
				fixed=true
			},
			{
				model="models/props_lab/tpplug.mdl",
				scale={x=1,y=1,z=1},
				idle={
					offset={x=-5,y=5,z=8},
					rotation={x=0,y=0,z=30}
				},
				tint=true,
				backpack=true
			},
			{
				model="models/props_lab/tpplug.mdl",
				scale={x=1,y=1,z=1},
				idle={
					offset={x=5,y=-5,z=8},
					rotation={x=0,y=0,z=-30}
				},
				tint=true,
				backpack=true
			}},
			sight= 50,
		},
		{
			name= "Bazooka Barracks",
			uniqueName= "bazookabarracks",
			category="Barracks",
			order=19,
			description= "Train bazookas by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=350},
			buildTime= 25,
			population=0,
			maxHealth= 250,
			icon="🧨",
			model="models/props_junk/wood_crate002a.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=18},
			size={x=21,y=34,z=19},
			makesTroop={
				troop="bazooka",
				cost= {water=80},
				time= 8
			},
			accessories={{
				model="models/weapons/w_missile_closed.mdl",
				scale={x=1,y=1,z=1},
				offset={x=0,y=0,z=21.5},
				rotation={x=0,y=45,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Flamer Barracks",
			uniqueName= "flamerbarracks",
			category="Barracks",
			order=20,
			description= "Train flamers by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=350},
			buildTime= 25,
			population=0,
			maxHealth= 250,
			icon="🔥",
			model="models/props_c17/furnitureStove001a.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=15},
			size={x=17,y=25,z=17},
			
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="flamer",
				cost= {water=80},
				time= 8
			},
			accessories={{
				model="models/props_junk/gascan001a.mdl",
				scale={x=1,y=1,z=1},
				offset={x=0,y=29,z=0},
				rotation={x=0,y=90,z=0},
				fixed=true
			},{
				model="models/props_junk/gascan001a.mdl",
				scale={x=1,y=1,z=1},
				offset={x=0,y=-29,z=0},
				rotation={x=0,y=90,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Bomb Barracks",
			uniqueName= "bombbarracks",
			category="Barracks",
			order=21,
			description= "Train bombs by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=350},
			buildTime= 30,
			population=0,
			maxHealth= 250,
			icon="💣",
			model="models/props_phx/wheels/trucktire2.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=0},
			size={x=25,y=25,z=17},
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="bomb",
				cost= {water=100},
				time= 8,
				spawnMargin=10
			},
			accessories={{
				model="models/Combine_Helicopter/helicopter_bomb01.mdl",
				scale={x=1,y=1,z=1},
				offset={x=0,y=0,z=30},
				rotation={x=0,y=0,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Gunner Barracks",
			uniqueName= "gunnerbarracks",
			category="Barracks",
			order=22,
			description= "Train gunners by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=350, energy=100},
			buildTime= 25,
			population=0,
			maxHealth= 250,
			icon="icon16/gun.png",
			model="models/props_combine/combine_interface001.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=-4,y=-2,z=-18},
			size={x=20,y=38,z=20},
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="gunner",
				cost= {water=150, energy=10},
				time= 12,
				spawnMargin=10
			},
			accessories={{
				model="models/Items/BoxSRounds.mdl",
				scale={x=2,y=2,z=2},
				offset={x=16,y=2,z=33},
				rotation={x=-45,y=0,z=0},
				fixed=true
			}}
		},
		{
			name= "Sniper Barracks",
			uniqueName= "sniperbarracks",
			category="Barracks",
			order=23,
			description= "Train snipers by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=350, energy=100},
			buildTime= 30,
			population=0,
			maxHealth= 250,
			icon="🔍",
			model="models/props_wasteland/controlroom_filecabinet002a.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=34},
			size={x=14,y=12,z=35},
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="sniper",
				cost= {water=150, energy=10},
				time= 12
			},
			accessories={{
				model="models/props_phx/construct/metal_wire1x1x2.mdl",
				scale={x=0.8,y=0.55,z=0.7},
				offset={x=-18,y=0,z=18},
				rotation={x=90,y=0,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Grenadier Barracks",
			uniqueName= "grenadierbarracks",
			category="Barracks",
			order=24,
			description= "Train grenadiers by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=400, energy=200},
			buildTime= 30,
			population=0,
			maxHealth= 250,
			icon="☀",
			model="models/props_c17/FurnitureCouch002a.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=15},
			size={x=17,y=28,z=17},
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="grenadier",
				cost= {water=200, energy=25},
				time= 15
			},
			accessories={{
				model="models/Items/ammocrate_grenade.mdl",
				scale={x=0.85,y=0.9,z=0.9},
				offset={x=0,y=0,z=0},
				rotation={x=0,y=0,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Mortar Barracks",
			uniqueName= "mortarbarracks",
			category="Barracks",
			order=25,
			description= "Train mortars by pressing E. Creating units through barracks doesn't require Influence.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			cost= {water=500, energy=250},
			buildTime= 30,
			population=0,
			maxHealth= 250,
			icon="☄",
			model="models/props_junk/TrashDumpster01a.mdl",
			color={r=0,g=0,b=0,a=0.4},
			offset={x=0,y=0,z=24},
			size={x=25,y=25,z=17},
			angle={x=0,y=180,z=0},
			makesTroop={
				troop="mortar",
				cost= {water=300, energy=75},
				time= 20,
				spawnMargin=10
			},
			accessories={{
				model="models/Items/BoxFlares.mdl",
				scale={x=2,y=2,z=2},
				offset={x=0,y=0,z=20},
				rotation={x=0,y=90,z=0},
				fixed=true
			}},
			sight= 50,
		},
		{
			name= "Contraption Assembler",
			uniqueName= "contraptionassembler",
			category="Barracks",
			order=26,
			description= "Assemble a contraption by pressing E. Contraptions are custom vehicles designed outside of combat that you can then legally create in battle using resources.",
			spawnSound= "doors/door_metal_large_close2.wav",
			type= "building",
			unlisted= true,
			cost= {water=500, energy=250},
			buildTime= 1,
			population=0,
			maxHealth= 250,
			icon="🏭",
			model="models/props_phx/construct/metal_plate2x2.mdl",
			keepMaterial=true,
			color={r=255.0,g=255.0,b=255.0,a=0.8},
			offset={x=0,y=0,z=0},
			size={x=50,y=50,z=50},
			angle={x=0,y=180,z=0},
			makesContraptions={
				size=100
			},
			accessories={
				{
					fixed= true,
					offset= {
						y= 42.0,
						x= 42.0,
						z= 10.0
					},
					color= {
						r= 1.0,
						g= 1.0,
						b= 1.0
					},
					material= "models/debug/debugwhite",
					tint= true,
					rotation= {
						y= 45.0,
						x= 15.0,
						z= -90.0
					},
					model= "models/mechanics/robotics/claw.mdl"
				},
				{
					fixed= true,
					offset= {
						y= -42.0,
						x= 42.0,
						z= 10.0
					},
					color= {
						r= 1.0,
						g= 1.0,
						b= 1.0
					},
					material= "models/debug/debugwhite",
					tint= true,
					rotation= {
						y= -45.0,
						x= 15.0,
						z= -90.0
					},
					model= "models/mechanics/robotics/claw.mdl"
				},
				{
					fixed= true,
					offset= {
						y= -42.0,
						x= -42.0,
						z= 10.0
					},
					color= {
						r= 1.0,
						g= 1.0,
						b= 1.0
					},
					material= "models/debug/debugwhite",
					tint= true,
					rotation= {
						y= 225.0,
						x= 15.0,
						z= -90.0
					},
					model= "models/mechanics/robotics/claw.mdl"
				},
				{
					fixed= true,
					offset= {
						y= 42.0,
						x= -42.0,
						z= 10.0
					},
					color= {
						r= 1.0,
						g= 1.0,
						b= 1.0
					},
					material= "models/debug/debugwhite",
					tint= true,
					rotation= {
						y= 135.0,
						x= 15.0,
						z= -90.0
					},
					model= "models/mechanics/robotics/claw.mdl"
				}
			},
			sight= 50,
		}
	},
	parts = {
		{
			name= "Machinegun Turret",
			uniqueName= "machinegunturret",
			order=1,
			description= "A basic troop, cheap and realiable. They find their strength in numbers, but aren't that effective on their own. With some support troops, the Soldier can add a lot of damage per second to a squad.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			sight = 160,
			turretLength = 30,
			attack= {
				type= "basic",
				delay= 0.75,
				windup= 0,
				damage= 3,
				range= 150,
				effect= {
					start= "muzzle",
					trail= "smoketrail",
					hit="spark"
				},
				targeting= {
					types= {"infantry", "vehicle", "building", "air"}
				},
				sound= {
					path= "weapons/smg1/smg1_fire1.wav",
					pitch= 200,
					volume= 68
				}
			},
			captureSpeed = 0.25,
			canAttackWhileMoving= true,
			moveType= "none",
			type= "vehicle",
			cost= {water=30},
			income= {},
			buildTime= 5,
			housing=0,
			population=1,
			mass= 1,
			size= 4,
			maxHealth= 30,
			speed= 40,
			icon="icon16/medal_silver_2.png",
			model="models/maxofs2d/hover_classic.mdl",
			scale={x=1,y=1,z=1},
			accessories={{
				model="models/weapons/w_smg1.mdl",
				scale={x=0.75,y=1,z=1},
				idle={
					offset={x=10,y=0,z=0},
					rotation={x=0,y=0,z=0}
				},
				attack={
					offset={x=5,y=0,z=0},
					rotation={x=0,y=0,z=0}
				},
				weapon=true
			}}
		},
		{
			name= "Engine",
			uniqueName= "engine",
			order=2,
			description= "A basic troop, cheap and realiable. They find their strength in numbers, but aren't that effective on their own. With some support troops, the Soldier can add a lot of damage per second to a squad.",
			spawnSound= "items/ammopickup.wav",
			deathSound= "physics/body/body_medium_impact_soft7.wav",
			captureSpeed = 0.25,
			canAttackWhileMoving= false,
			moveType= "engine",
			type= "vehicle",
			cost= {water=30},
			income= {},
			buildTime= 5,
			housing=0,
			population=1,
			mass= 1,
			size= 4,
			maxHealth= 10,
			speed= 40,
			force= 10,
			icon="icon16/medal_silver_2.png",
			model="models/props_lab/reciever01b.mdl",
			scale={x=1,y=1,z=1},
			sight = 50,
		}
	}
}

function GetTroopByUniqueName(name)
	return troopsByUniqueName[name]
end

function GetTroopIDByUniqueName(name)
	return troopsIDsByUniqueName[name]
end

function GetBuildingByUniqueName(name)
	return buildingsByUniqueName[name]
end

function GetBuildingIDByUniqueName(name)
	return buildingsIDsByUniqueName[name]
end

function GetStatusByUniqueName(name)
	return statusByUniqueName[name]
end

function GetPartByUniqueName(name)
	return partsByUniqueName[name]
end

function GetPartIDByUniqueName(name)
	return partsIDsByUniqueName[name]
end

function GetResourceByUniqueName(name)
	return resourcesByUniqueName[name]
end

function MRTSGetTeamDataByID(id)
	return mrtsGameData.teams[id]
end