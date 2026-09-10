## meta_progression.gd — Stone Knight F021 (Save Foundation Prototype)
## Quản lý tiến trình vĩnh viễn (Rune Stones, Permanent Upgrades, Thống kê).
## 
## Nguyên tắc kỹ thuật:
## 1. Atomic Write: Ghi file tạm (.tmp) -> verify -> backup (.bak) -> ghi đè file chính.
## 2. Load an toàn: File hỏng thử backup; nếu cả 2 hỏng thì đổi tên .corrupt, nạp default vào RAM, không ghi đè bừa bãi.
## 3. Data Validation: Chặn số âm, clamp tier [0, max_tier], từ chối version tương lai.
## 4. Candidate Transaction: Chỉ commit vào bộ nhớ khi ghi đĩa thành công; rollback nếu lưu thất bại.
## 5. Test Path Injection: Cho phép chỉ định save_path riêng để Unit Test không chạm vào file save thật.
class_name MetaProgression
extends RefCounted

signal purchase_succeeded(upgrade_id: String, new_tier: int)
signal purchase_failed(upgrade_id: String, reason: String)
signal data_changed

const CURRENT_VERSION := 1
const DEFAULT_SAVE_PATH := "user://save_data.json"

const PERM_UPGRADES: Array[Dictionary] = [
	{
		"id": "PERM_HP",
		"name": "Stone Body",
		"max_tier": 2,
		"costs": [15, 45],
		"stat_desc": "+1 Max HP per tier",
		"bonus_per_tier": 1,
		"implemented": true,
		"enabled_for_purchase": true,
	},
	{
		"id": "PERM_FORCE",
		"name": "Heavy Core",
		"max_tier": 2,
		"costs": [15, 40],
		"stat_desc": "+7.5% Pulse Force per tier",
		"bonus_per_tier": 0.075,
		"implemented": true,
		"enabled_for_purchase": true,
	},
	{
		"id": "PERM_SPEED",
		"name": "Quick Feet",
		"max_tier": 2,
		"costs": [15, 40],
		"stat_desc": "+4% Move Speed per tier",
		"bonus_per_tier": 0.04,
		"implemented": true,
		"enabled_for_purchase": true,
	},
	{
		"id": "PERM_CD",
		"name": "Charged Core",
		"max_tier": 2,
		"costs": [20, 50],
		"stat_desc": "-0.2s Pulse Cooldown per tier",
		"bonus_per_tier": 0.2,
		"implemented": true,
		"enabled_for_purchase": true,
	},
	{
		"id": "PERM_MAGNET",
		"name": "Soul Attunement",
		"max_tier": 1,
		"costs": [30],
		"stat_desc": "+30% Shard Magnet Radius",
		"bonus_per_tier": 0.30,
		"implemented": true,
		"enabled_for_purchase": true,
	},
	{
		"id": "PERM_FORESIGHT",
		"name": "Rune Foresight",
		"max_tier": 1,
		"costs": [40],
		"stat_desc": "1 In-Run Upgrade Reroll per run",
		"bonus_per_tier": 1,
		"implemented": true,
		"enabled_for_purchase": true,
	},
]

var save_path: String = DEFAULT_SAVE_PATH

# Runtime State
var rune_stones: int = 0
var total_runs: int = 0
var best_wave: int = 0
var perm_tiers: Dictionary = {}


func _init(custom_path: String = "") -> void:
	if not custom_path.is_empty():
		save_path = custom_path
	reset_to_defaults()


## Đặt lại trạng thái mặc định trong RAM (không tự ghi ra file)
func reset_to_defaults() -> void:
	rune_stones = 0
	total_runs = 0
	best_wave = 0
	perm_tiers.clear()
	for upg in PERM_UPGRADES:
		perm_tiers[upg["id"]] = 0


# ═══════════════════════════════════════════════════════════
# ATOMIC SAVE & SAFE LOAD
# ═══════════════════════════════════════════════════════════

## Xuất trạng thái thành Dictionary chuẩn schema
func to_dict() -> Dictionary:
	var tiers_copy: Dictionary = {}
	for k in perm_tiers:
		tiers_copy[k] = perm_tiers[k]

	return {
		"version": CURRENT_VERSION,
		"rune_stones": rune_stones,
		"total_runs": total_runs,
		"best_wave": best_wave,
		"perm_tiers": tiers_copy,
	}


## Ghi dữ liệu dictionary xuống đĩa theo cơ chế Atomic Write
func save_to_file(target_path: String = "") -> bool:
	var path_to_use := target_path if not target_path.is_empty() else save_path
	var payload := to_dict()
	return _atomic_write_dict(path_to_use, payload)


## Nạp và kiểm tra tính toàn vẹn dữ liệu từ đĩa
func load_from_file(source_path: String = "") -> bool:
	var path_to_use := source_path if not source_path.is_empty() else save_path

	if not FileAccess.file_exists(path_to_use):
		# Chưa từng có file save: Khởi tạo mặc định hợp lệ
		reset_to_defaults()
		return true

	var parsed_data: Variant = _read_and_parse_json(path_to_use)

	# Nếu file chính bị hỏng (parse ra null/lỗi), thử đọc file backup .bak
	if parsed_data == null:
		var bak_path := path_to_use + ".bak"
		if FileAccess.file_exists(bak_path):
			parsed_data = _read_and_parse_json(bak_path)

	# Nếu cả file chính và backup đều hỏng: cách ly file, nạp mặc định, không đè
	if parsed_data == null or typeof(parsed_data) != TYPE_DICTIONARY:
		_isolate_corrupted_file(path_to_use)
		reset_to_defaults()
		return false

	var dict: Dictionary = parsed_data

	# 1. Kiểm tra version
	var file_version: int = int(dict.get("version", 1))
	if file_version > CURRENT_VERSION:
		# Phiên bản tương lai: từ chối nạp, giữ nguyên RAM hiện tại để tránh làm hỏng save
		push_warning("MetaProgression: Save version %d is newer than current %d. Aborting load." % [file_version, CURRENT_VERSION])
		return false

	if file_version < CURRENT_VERSION:
		dict = _migrate(dict, file_version, CURRENT_VERSION)

	# 2. Validate và nạp vào bộ nhớ (chặn số âm, ép tier)
	rune_stones = maxi(0, int(dict.get("rune_stones", 0)))
	total_runs = maxi(0, int(dict.get("total_runs", 0)))
	best_wave = clampi(int(dict.get("best_wave", 0)), 0, 5)

	var raw_tiers: Variant = dict.get("perm_tiers", {})
	perm_tiers.clear()
	for upg in PERM_UPGRADES:
		var upg_id: String = upg["id"]
		var max_t: int = upg["max_tier"]
		var loaded_tier: int = 0
		if typeof(raw_tiers) == TYPE_DICTIONARY and raw_tiers.has(upg_id):
			loaded_tier = int(raw_tiers[upg_id])
		perm_tiers[upg_id] = clampi(loaded_tier, 0, max_t)

	data_changed.emit()
	return true


func _read_and_parse_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var content := file.get_as_text()
	file.close()

	if content.strip_edges().is_empty():
		return null

	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		return null
	return json.data


func _atomic_write_dict(target_file_path: String, data: Dictionary) -> bool:
	var json_string := JSON.stringify(data, "\t")
	var tmp_path := target_file_path + ".tmp"
	var bak_path := target_file_path + ".bak"

	# 1. Ghi vào file tạm
	var tmp_file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if tmp_file == null:
		push_error("MetaProgression: Cannot open tmp file for write: %s" % tmp_path)
		return false

	tmp_file.store_string(json_string)
	tmp_file.flush()
	tmp_file.close()

	# 2. Đọc lại file tạm để xác thực tính toàn vẹn trước khi commit
	var verify_data: Variant = _read_and_parse_json(tmp_path)
	if verify_data == null or typeof(verify_data) != TYPE_DICTIONARY:
		push_error("MetaProgression: Verification failed for written tmp file!")
		if FileAccess.file_exists(tmp_path):
			DirAccess.remove_absolute(tmp_path)
		return false

	# 3. Tạo bản sao lưu file chính cũ sang .bak nếu file chính đã tồn tại
	if FileAccess.file_exists(target_file_path):
		if FileAccess.file_exists(bak_path):
			DirAccess.remove_absolute(bak_path)
		DirAccess.copy_absolute(target_file_path, bak_path)

	# 4. Đổi tên .tmp thành file chính thức
	if FileAccess.file_exists(target_file_path):
		DirAccess.remove_absolute(target_file_path)
	var rename_err := DirAccess.rename_absolute(tmp_path, target_file_path)
	if rename_err != OK:
		push_error("MetaProgression: Failed to rename %s to %s, err code: %d" % [tmp_path, target_file_path, rename_err])
		return false

	return true


func _isolate_corrupted_file(corrupt_file_path: String) -> void:
	if not FileAccess.file_exists(corrupt_file_path):
		return
	var timestamp := int(Time.get_unix_time_from_system())
	var isolated_name := corrupt_file_path + ".corrupt_" + str(timestamp)
	DirAccess.rename_absolute(corrupt_file_path, isolated_name)
	push_warning("MetaProgression: Corrupted save isolated as %s" % isolated_name)


func _migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	var result := data.duplicate(true)
	# Khung migration theo từng bước: v1 -> v2, v2 -> v3
	for v in range(from_version, to_version):
		# Hiện tại đang ở v1, khi nâng cấp version sẽ bổ sung nhánh tại đây
		pass
	result["version"] = to_version
	return result


# ═══════════════════════════════════════════════════════════
# TRANSACTION & BUY LOGIC
# ═══════════════════════════════════════════════════════════

func get_upgrade_def(upgrade_id: String) -> Dictionary:
	for upg in PERM_UPGRADES:
		if upg["id"] == upgrade_id:
			return upg
	return {}


func get_perm_tier(upgrade_id: String) -> int:
	return perm_tiers.get(upgrade_id, 0)


func get_next_cost(upgrade_id: String) -> int:
	var def := get_upgrade_def(upgrade_id)
	if def.is_empty():
		return -1
	var cur_tier: int = get_perm_tier(upgrade_id)
	var max_tier: int = def["max_tier"]
	if cur_tier >= max_tier:
		return -1
	var costs: Array = def["costs"]
	if cur_tier < costs.size():
		return int(costs[cur_tier])
	return -1


func can_buy(upgrade_id: String) -> bool:
	var def := get_upgrade_def(upgrade_id)
	if def.is_empty():
		return false
	if not def.get("implemented", false):
		return false
	if not def.get("enabled_for_purchase", false):
		return false
	var cost := get_next_cost(upgrade_id)
	if cost < 0:
		return false
	return rune_stones >= cost


## Kiểm tra nhanh upgrade có đủ điều kiện hiển thị nút Buy hay không
## (không kiểm tra balance, chỉ kiểm tra trạng thái triển khai)
func is_purchasable(upgrade_id: String) -> bool:
	var def := get_upgrade_def(upgrade_id)
	if def.is_empty():
		return false
	return def.get("implemented", false) and def.get("enabled_for_purchase", false)


## Giao dịch mua: Atomic Commit
## Chỉ cập nhật RAM và emit tín hiệu thành công khi file đĩa đã được lưu an toàn.
func buy_upgrade(upgrade_id: String) -> bool:
	if not can_buy(upgrade_id):
		purchase_failed.emit(upgrade_id, "Cannot buy: insufficient funds or max tier")
		return false

	var cost := get_next_cost(upgrade_id)
	var cur_tier := get_perm_tier(upgrade_id)

	# 1. Tạo candidate state
	var candidate_stones := rune_stones - cost
	var candidate_tiers := perm_tiers.duplicate()
	candidate_tiers[upgrade_id] = cur_tier + 1

	var candidate_payload := {
		"version": CURRENT_VERSION,
		"rune_stones": candidate_stones,
		"total_runs": total_runs,
		"best_wave": best_wave,
		"perm_tiers": candidate_tiers,
	}

	# 2. Thử lưu candidate xuống đĩa
	var save_ok := _atomic_write_dict(save_path, candidate_payload)
	if not save_ok:
		purchase_failed.emit(upgrade_id, "Transaction failed: Disk write error")
		return false

	# 3. Commit vào RAM khi lưu đĩa thành công
	rune_stones = candidate_stones
	perm_tiers = candidate_tiers
	purchase_succeeded.emit(upgrade_id, cur_tier + 1)
	data_changed.emit()
	return true


func add_rune_stones(amount: int) -> void:
	if amount <= 0:
		return
	rune_stones += amount
	save_to_file()
	data_changed.emit()


# ═══════════════════════════════════════════════════════════
# TRUE-ADDITIVE BASELINE MODIFIERS (Dùng cho UpgradeManager)
# ═══════════════════════════════════════════════════════════

func get_perm_hp_bonus() -> int:
	return get_perm_tier("PERM_HP") * 1


func get_perm_force_bonus() -> float:
	return get_perm_tier("PERM_FORCE") * 0.075


func get_perm_speed_bonus() -> float:
	return get_perm_tier("PERM_SPEED") * 0.04


func get_perm_cd_reduction() -> float:
	return get_perm_tier("PERM_CD") * 0.2


func get_perm_magnet_bonus() -> float:
	return get_perm_tier("PERM_MAGNET") * 0.30


func has_reroll() -> bool:
	return get_perm_tier("PERM_FORESIGHT") >= 1
