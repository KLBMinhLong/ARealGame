## upgrade_manager.gd — Stone Knight M0 + F018
## Quản lý kho 6 thẻ nâng cấp trong lượt chơi (In-Run Roguelite Upgrades).
## Quy tắc cốt lõi:
## 1. Additive from baseline: mọi chỉ số tính từ Config, không compound, không sửa Config.
## 2. UpgradeManager chỉ quản lý tiers: Dictionary.
## 3. Cách ly RNG: upgrade_rng riêng biệt, không dùng randf/randi toàn cục.
class_name UpgradeManager
extends RefCounted

const MAX_TIER := 3

const UPGRADE_POOL: Array[Dictionary] = [
	{
		"id": "UPG_FORCE",
		"name": "Heavy Push",
		"icon": "[FORCE]",
		"desc": "Lực đẩy Pulse +25%",
		"stat_label": "Push Force",
		"max_tier": MAX_TIER,
	},
	{
		"id": "UPG_RADIUS",
		"name": "Wider Reach",
		"icon": "[RANGE]",
		"desc": "Bán kính Pulse +20%",
		"stat_label": "Pulse Radius",
		"max_tier": MAX_TIER,
	},
	{
		"id": "UPG_CD",
		"name": "Quick Charge",
		"icon": "[PULSE]",
		"desc": "Hồi chiêu Pulse -0.4s",
		"stat_label": "Cooldown",
		"max_tier": MAX_TIER,
	},
	{
		"id": "UPG_SPEED",
		"name": "Swift Stone",
		"icon": "[SPEED]",
		"desc": "Tốc độ chạy +15%",
		"stat_label": "Move Speed",
		"max_tier": MAX_TIER,
	},
	{
		"id": "UPG_MAGNET",
		"name": "Soul Magnet",
		"icon": "[SHARD]",
		"desc": "Hút Shard xa hơn +50%",
		"stat_label": "Magnet Range",
		"max_tier": MAX_TIER,
	},
	{
		"id": "UPG_HP",
		"name": "Stone Heart",
		"icon": "[HEART]",
		"desc": "+1 Max HP & hồi 1 HP",
		"stat_label": "Vitality",
		"max_tier": MAX_TIER,
	},
]

# Lưu trữ tier hiện tại của từng upgrade: { "UPG_FORCE": 1, ... }
var current_tiers: Dictionary = {}

# RNG riêng biệt cho việc rút thẻ, không làm lệch seed sinh quái của Wave
var upgrade_rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init() -> void:
	upgrade_rng.randomize()
	reset()


func reset() -> void:
	current_tiers.clear()
	for upg in UPGRADE_POOL:
		current_tiers[upg["id"]] = 0


func get_tier(upgrade_id: String) -> int:
	return current_tiers.get(upgrade_id, 0)


# ═══════════════════════════════════════════════════════════
# CÔNG THỨC ADDITIVE FROM BASELINE
# ═══════════════════════════════════════════════════════════

func get_effective_pulse_force() -> float:
	var tier := get_tier("UPG_FORCE")
	return Config.PULSE_VELOCITY * (1.0 + 0.25 * tier)


func get_effective_pulse_radius() -> float:
	var tier := get_tier("UPG_RADIUS")
	return Config.PULSE_RADIUS * (1.0 + 0.20 * tier)


func get_effective_pulse_cooldown() -> float:
	var tier := get_tier("UPG_CD")
	return maxf(1.5, Config.PULSE_COOLDOWN - 0.4 * tier)


func get_effective_player_speed() -> float:
	var tier := get_tier("UPG_SPEED")
	return Config.PLAYER_SPEED * (1.0 + 0.15 * tier)


func get_effective_magnet_radius() -> float:
	var tier := get_tier("UPG_MAGNET")
	return Config.SHARD_MAGNET_RADIUS * (1.0 + 0.50 * tier)


func get_effective_max_hp() -> int:
	var tier := get_tier("UPG_HP")
	return Config.PLAYER_MAX_HP + tier


# ═══════════════════════════════════════════════════════════
# RÚT THẺ VÀ NÂNG CẤP
# ═══════════════════════════════════════════════════════════

## Rút ngẫu nhiên count thẻ chưa đạt max tier, không trùng lặp, dùng upgrade_rng.
func draw_cards(count: int = 3) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for upg in UPGRADE_POOL:
		var upg_id: String = upg["id"]
		var tier: int = current_tiers.get(upg_id, 0)
		var max_t: int = upg.get("max_tier", MAX_TIER)
		if tier < max_t:
			available.append(upg)

	if available.is_empty():
		return []

	# Fisher-Yates shuffle bằng upgrade_rng riêng biệt
	var n := available.size()
	for i in range(n - 1, 0, -1):
		var j := upgrade_rng.randi_range(0, i)
		var temp: Dictionary = available[i]
		available[i] = available[j]
		available[j] = temp

	var picked: Array[Dictionary] = []
	var pick_count: int = mini(count, available.size())
	for i in pick_count:
		var card_data: Dictionary = available[i].duplicate()
		var card_id: String = card_data["id"]
		var cur_tier: int = current_tiers.get(card_id, 0)
		card_data["current_tier"] = cur_tier
		card_data["next_tier"] = cur_tier + 1
		picked.append(card_data)

	return picked


## Tăng tier cho thẻ đã chọn, trả về true nếu thành công
func apply_upgrade(upgrade_id: String) -> bool:
	if not current_tiers.has(upgrade_id):
		return false

	var cur_tier: int = current_tiers[upgrade_id]
	if cur_tier >= MAX_TIER:
		return false

	current_tiers[upgrade_id] = cur_tier + 1
	return true
