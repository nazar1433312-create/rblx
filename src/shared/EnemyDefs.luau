export type EnemyStats = {
	displayName: string,
	maxHealth: number,
	damage: number,
	attackCooldown: number,
	attackRange: number,
	moveSpeed: number,
	color: Color3,
}

local EnemyDefs: { [string]: EnemyStats } = {
	Termite = {
		displayName = "Termite",
		maxHealth = 25,
		damage = 5,
		attackCooldown = 1,
		attackRange = 4,
		moveSpeed = 12,
		color = Color3.fromRGB(210, 180, 140),
	},
}

return EnemyDefs
