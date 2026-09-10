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

# F021.4/F021.5: Permanent bonuses được inject từ main.gd khi start run
var perm_hp_bonus: int = 0          # Từ MetaProgression.get_perm_hp_bonus()
var perm_force_bonus: float = 0.0   # Từ MetaProgression.get_perm_force_bonus()
var perm_speed_bonus: float = 0.0   # Từ MetaProgression.get_perm_speed_bonus()
var perm_cd_reduction: float = 0.0  # Từ MetaProgression.get_perm_cd_reduction()
var perm_magnet_bonus: float = 0.0  # Từ MetaProgression.get_perm_magnet_bonus()
var rerolls_remaining: int = 0      # F021.6: 1 lần reroll/run nếu có Rune Foresight


func _init() -> void:
	upgrade_rng.randomize()
	reset()


func reset() -> void:
	current_tiers.clear()
	for upg in UPGRADE_POOL:
		current_tiers[upg["id"]] = 0
	rerolls_remaining = 0
	# F021.5: perm bonuses KHÔNG reset ở đây — chúng được set bởi inject_perm_bonuses()


## F021.5 & F021.6: Inject tất cả permanent bonuses từ MetaProgression.
## Gọi 1 lần khi start run, trước sync_upgrades đầu tiên.
func inject_perm_bonuses(
		hp_bonus: int = 0,
		force_bonus: float = 0.0,
		speed_bonus: float = 0.0,
		cd_reduction: float = 0.0,
		magnet_bonus: float = 0.0,
		has_reroll: bool = false,
) -> void:
	perm_hp_bonus = hp_bonus
	perm_force_bonus = force_bonus
	perm_speed_bonus = speed_bonus
	perm_cd_reduction = cd_reduction
	perm_magnet_bonus = magnet_bonus
	rerolls_remaining = 1 if has_reroll else 0


func can_reroll() -> bool:
	return rerolls_remaining > 0


func use_reroll() -> bool:
	if rerolls_remaining > 0:
		rerolls_remaining -= 1
		return true
	return false


func get_tier(upgrade_id: String) -> int:
	return current_tiers.get(upgrade_id, 0)


# ═══════════════════════════════════════════════════════════
# CÔNG THỨC ADDITIVE FROM BASELINE
# ═══════════════════════════════════════════════════════════

func get_effective_pulse_force() -> float:
	var tier := get_tier("UPG_FORCE")
	var in_run_bonus: float = 0.25 * tier
	# F021.5: True-additive = base * (1 + perm + in_run)
	return Config.PULSE_VELOCITY * (1.0 + perm_force_bonus + in_run_bonus)


func get_effective_pulse_radius() -> float:
	var tier := get_tier("UPG_RADIUS")
	return Config.PULSE_RADIUS * (1.0 + 0.20 * tier)  # Radius không có perm upgrade


func get_effective_pulse_cooldown() -> float:
	var tier := get_tier("UPG_CD")
	var in_run_reduction: float = 0.4 * tier
	# F021.5: True-additive subtractive = base - perm - in_run (có floor)
	return maxf(1.5, Config.PULSE_COOLDOWN - perm_cd_reduction - in_run_reduction)


func get_effective_player_speed() -> float:
	var tier := get_tier("UPG_SPEED")
	var in_run_bonus: float = 0.15 * tier
	# F021.5: True-additive = base * (1 + perm + in_run)
	return Config.PLAYER_SPEED * (1.0 + perm_speed_bonus + in_run_bonus)


func get_effective_magnet_radius() -> float:
	var tier := get_tier("UPG_MAGNET")
	var in_run_bonus: float = 0.50 * tier
	# F021.4: True-additive = base * (1 + perm + in_run)
	return Config.SHARD_MAGNET_RADIUS * (1.0 + perm_magnet_bonus + in_run_bonus)


func get_effective_max_hp() -> int:
	var tier := get_tier("UPG_HP")
	# F021.5: True-additive = base + perm + in_run
	return Config.PLAYER_MAX_HP + perm_hp_bonus + tier


# ═══════════════════════════════════════════════════════════
# RÚT THẺ VÀ NÂNG CẤP
# ═══════════════════════════════════════════════════════════

## Rút ngẫu nhiên count thẻ chưa đạt max tier, không trùng lặp, dùng upgrade_rng.
## Nếu exclude_ids được truyền, ưu tiên loại bỏ các thẻ bị exclude (nếu pool còn đủ count thẻ).
func draw_cards(count: int = 3, exclude_ids: Array = []) -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for upg in UPGRADE_POOL:
		var upg_id: String = upg["id"]
		var tier: int = current_tiers.get(upg_id, 0)
		var max_t: int = upg.get("max_tier", MAX_TIER)
		if tier < max_t:
			available.append(upg)

	if available.is_empty():
		return []

	# Nếu có exclude_ids và sau khi lọc vẫn còn ít nhất count thẻ, loại bỏ các thẻ bị exclude
	if not exclude_ids.is_empty():
		var filtered: Array[Dictionary] = []
		for card in available:
			if not exclude_ids.has(card["id"]):
				filtered.append(card)
		if filtered.size() >= count:
			available = filtered

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
