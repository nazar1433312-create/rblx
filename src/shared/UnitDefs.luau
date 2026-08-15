export type UnitStats = {
	displayName: string,
	maxHealth: number,
	damage: number,
	attackCooldown: number,
	attackRange: number,
	moveSpeed: number,
	canGather: boolean,
	gatherRate: number,
	cost: number,
	buildTime: number,
	color: Color3,
}

local UnitDefs: { [string]: UnitStats } = {
	Worker = {
		displayName = "Worker",
		maxHealth = 30,
		damage = 3,
		attackCooldown = 1.2,
		attackRange = 4,
		moveSpeed = 14,
		canGather = true,
		gatherRate = 2,
		cost = 10,
		buildTime = 3,
		color = Color3.fromRGB(139, 94, 60),
	},
	Soldier = {
		displayName = "Soldier",
		maxHealth = 60,
		damage = 9,
		attackCooldown = 0.8,
		attackRange = 5,
		moveSpeed = 16,
		canGather = false,
		gatherRate = 0,
		cost = 25,
		buildTime = 5,
		color = Color3.fromRGB(178, 34, 34),
	},
}

return UnitDefs
