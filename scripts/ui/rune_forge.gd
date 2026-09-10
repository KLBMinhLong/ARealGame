## rune_forge.gd — Stone Knight F021.3 (Reworked)
## Giao diện Rune Forge: Mua nâng cấp vĩnh viễn bằng Rune Stones.
##
## Thiết kế theo 12 điểm review:
## 1. Chỉ bán upgrade có implemented=true AND enabled_for_purchase=true.
## 2. Two-step: Select → xem Before/After → Enter/Space mua. Không double-click.
## 3. Giá lấy 100% từ PERM_UPGRADES definition, không hardcode.
## 4. Modal thật: dim_overlay chặn click, mọi input được consume.
## 5. Transaction lock: disable BUY khi save đang chạy.
## 6. Refresh toàn bộ cards sau mỗi giao dịch.
## 7. Split layout: list trái + detail phải cho viewport 480×270.
extends CanvasLayer

signal forge_closed

var is_open: bool = false
var meta_ref = null  # MetaProgression reference
var selected_index: int = -1
var purchase_in_progress: bool = false
var just_opened: bool = false
var last_purchase_failed: bool = false
var last_error_message: String = ""

# ── UI nodes ──
var dim_overlay: ColorRect
var root_container: Control
var title_label: Label
var balance_label: Label

# Left panel: compact list
var list_panel: VBoxContainer
var list_items: Array[Control] = []

# Right panel: detail
var detail_panel: Control
var detail_name_label: Label
var detail_tier_label: Label
var detail_desc_label: Label
var detail_preview_label: Label
var detail_cost_label: Label
var detail_status_label: Label

var hint_label: Label
var back_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 11
	_setup_ui()
	hide_forge()


# ═══════════════════════════════════════════════════════════
# UI SETUP — Split layout: List (left) + Detail (right)
# ═══════════════════════════════════════════════════════════

func _setup_ui() -> void:
	# 1. Dim overlay — chặn click xuyên xuống (MOUSE_FILTER_STOP)
	dim_overlay = ColorRect.new()
	dim_overlay.name = "ForgeDim"
	dim_overlay.color = Color(0.01, 0.02, 0.05, 0.92)
	dim_overlay.anchor_right = 1
	dim_overlay.anchor_bottom = 1
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim_overlay)

	# 2. Root container
	root_container = Control.new()
	root_container.name = "ForgeRoot"
	root_container.anchor_right = 1
	root_container.anchor_bottom = 1
	root_container.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root_container)

	# 3. Title
	title_label = Label.new()
	title_label.name = "ForgeTitle"
	title_label.text = "RUNE FORGE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.anchor_left = 0
	title_label.anchor_right = 1
	title_label.offset_top = 8
	title_label.offset_bottom = 22
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	root_container.add_child(title_label)

	# 4. Balance (fixed top)
	balance_label = Label.new()
	balance_label.name = "BalanceLabel"
	balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	balance_label.anchor_left = 0
	balance_label.anchor_right = 1
	balance_label.offset_top = 22
	balance_label.offset_bottom = 33
	balance_label.add_theme_font_size_override("font_size", 8)
	balance_label.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
	root_container.add_child(balance_label)

	# 5. Left panel — compact list (x: 8..188, y: 38..232)
	list_panel = VBoxContainer.new()
	list_panel.name = "ListPanel"
	list_panel.offset_left = 8
	list_panel.offset_right = 188
	list_panel.offset_top = 38
	list_panel.offset_bottom = 232
	list_panel.add_theme_constant_override("separation", 2)
	root_container.add_child(list_panel)

	# 6. Right panel — detail view (x: 196..472, y: 38..232)
	detail_panel = Control.new()
	detail_panel.name = "DetailPanel"
	detail_panel.offset_left = 196
	detail_panel.offset_right = 472
	detail_panel.offset_top = 38
	detail_panel.offset_bottom = 232
	root_container.add_child(detail_panel)

	# Detail panel background
	var detail_bg := ColorRect.new()
	detail_bg.name = "DetailBG"
	detail_bg.color = Color(0.06, 0.07, 0.12, 0.8)
	detail_bg.anchor_right = 1
	detail_bg.anchor_bottom = 1
	detail_panel.add_child(detail_bg)

	# Detail: Name
	detail_name_label = Label.new()
	detail_name_label.name = "DetailName"
	detail_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_name_label.anchor_left = 0
	detail_name_label.anchor_right = 1
	detail_name_label.offset_top = 6
	detail_name_label.offset_bottom = 20
	detail_name_label.add_theme_font_size_override("font_size", 10)
	detail_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	detail_panel.add_child(detail_name_label)

	# Detail: Tier
	detail_tier_label = Label.new()
	detail_tier_label.name = "DetailTier"
	detail_tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_tier_label.anchor_left = 0
	detail_tier_label.anchor_right = 1
	detail_tier_label.offset_top = 22
	detail_tier_label.offset_bottom = 34
	detail_tier_label.add_theme_font_size_override("font_size", 8)
	detail_tier_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	detail_panel.add_child(detail_tier_label)

	# Detail: Description
	detail_desc_label = Label.new()
	detail_desc_label.name = "DetailDesc"
	detail_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_desc_label.anchor_left = 0
	detail_desc_label.anchor_right = 1
	detail_desc_label.offset_left = 8
	detail_desc_label.offset_right = -8
	detail_desc_label.offset_top = 38
	detail_desc_label.offset_bottom = 52
	detail_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc_label.add_theme_font_size_override("font_size", 7)
	detail_desc_label.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
	detail_panel.add_child(detail_desc_label)

	# Detail: Before → After preview
	detail_preview_label = Label.new()
	detail_preview_label.name = "DetailPreview"
	detail_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_preview_label.anchor_left = 0
	detail_preview_label.anchor_right = 1
	detail_preview_label.offset_left = 4
	detail_preview_label.offset_right = -4
	detail_preview_label.offset_top = 58
	detail_preview_label.offset_bottom = 108
	detail_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_preview_label.add_theme_font_size_override("font_size", 8)
	detail_preview_label.add_theme_color_override("font_color", Color(0.85, 0.95, 0.7))
	detail_panel.add_child(detail_preview_label)

	# Detail: Cost line
	detail_cost_label = Label.new()
	detail_cost_label.name = "DetailCost"
	detail_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_cost_label.anchor_left = 0
	detail_cost_label.anchor_right = 1
	detail_cost_label.offset_top = 114
	detail_cost_label.offset_bottom = 128
	detail_cost_label.add_theme_font_size_override("font_size", 9)
	detail_cost_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	detail_panel.add_child(detail_cost_label)

	# Detail: Status / action text
	detail_status_label = Label.new()
	detail_status_label.name = "DetailStatus"
	detail_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_status_label.anchor_left = 0
	detail_status_label.anchor_right = 1
	detail_status_label.offset_top = 134
	detail_status_label.offset_bottom = 155
	detail_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_status_label.add_theme_font_size_override("font_size", 7)
	detail_status_label.add_theme_color_override("font_color", Color(0.55, 0.65, 0.5))
	detail_panel.add_child(detail_status_label)

	# 7. Bottom hint
	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.anchor_left = 0
	hint_label.anchor_right = 1
	hint_label.offset_top = 240
	hint_label.offset_bottom = 252
	hint_label.add_theme_font_size_override("font_size", 7)
	hint_label.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	root_container.add_child(hint_label)

	# 8. Back label
	back_label = Label.new()
	back_label.name = "BackLabel"
	back_label.text = "ESC - Back"
	back_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_label.anchor_left = 0
	back_label.anchor_right = 1
	back_label.offset_top = 254
	back_label.offset_bottom = 264
	back_label.add_theme_font_size_override("font_size", 7)
	back_label.add_theme_color_override("font_color", Color(0.45, 0.5, 0.55))
	root_container.add_child(back_label)


# ═══════════════════════════════════════════════════════════
# OPEN / CLOSE
# ═══════════════════════════════════════════════════════════

func show_forge(meta: Object) -> void:
	if is_open:
		return  # Không mở chồng
	meta_ref = meta
	is_open = true
	visible = true
	selected_index = -1
	purchase_in_progress = false
	last_purchase_failed = false
	last_error_message = ""
	just_opened = true
	_refresh_list()
	_update_detail_panel()


func hide_forge() -> void:
	is_open = false
	visible = false
	selected_index = -1
	purchase_in_progress = false


func _close_forge() -> void:
	if purchase_in_progress:
		return  # Không đóng giữa transaction
	hide_forge()
	forge_closed.emit()


# ═══════════════════════════════════════════════════════════
# INPUT — True modal: consume ALL input khi mở
# ═══════════════════════════════════════════════════════════

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if just_opened:
		# Consume nhưng không xử lý frame đầu
		if event is InputEventKey or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				_close_forge()
			KEY_1, KEY_KP_1:
				_select_card(0)
			KEY_2, KEY_KP_2:
				_select_card(1)
			KEY_3, KEY_KP_3:
				_select_card(2)
			KEY_4, KEY_KP_4:
				_select_card(3)
			KEY_5, KEY_KP_5:
				_select_card(4)
			KEY_6, KEY_KP_6:
				_select_card(5)
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_confirm_purchase()
			KEY_F:
				pass  # Swallow — không mở thêm Forge
		# Consume MỌI key event khi Forge mở
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed:
		# Mouse clicks bị dim_overlay bắt (MOUSE_FILTER_STOP),
		# nhưng consume ở đây phòng trường hợp propagation
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if just_opened:
		just_opened = false


# ═══════════════════════════════════════════════════════════
# CARD SELECTION & PURCHASE
# ═══════════════════════════════════════════════════════════

func _select_card(index: int) -> void:
	if meta_ref == null or purchase_in_progress:
		return
	var upgrades: Array = meta_ref.PERM_UPGRADES
	if index < 0 or index >= upgrades.size():
		return
	selected_index = index
	last_purchase_failed = false
	last_error_message = ""
	_refresh_list()
	_update_detail_panel()


func _confirm_purchase() -> void:
	if meta_ref == null or selected_index < 0 or purchase_in_progress:
		return

	var upgrades: Array = meta_ref.PERM_UPGRADES
	if selected_index >= upgrades.size():
		return

	var upg: Dictionary = upgrades[selected_index]
	var upg_id: String = upg["id"]

	# Gate: must be implemented AND enabled
	if not meta_ref.is_purchasable(upg_id):
		return

	if not meta_ref.can_buy(upg_id):
		return

	# Transaction lock
	purchase_in_progress = true
	last_purchase_failed = false
	last_error_message = ""
	_update_detail_panel()  # Hiển thị trạng thái "Đang xử lý..."

	var success: bool = meta_ref.buy_upgrade(upg_id)
	purchase_in_progress = false

	if success:
		last_purchase_failed = false
		# Refresh toàn bộ — balance mới ảnh hưởng tất cả thẻ
		_refresh_list()
		_update_detail_panel()
	else:
		last_purchase_failed = true
		last_error_message = "Save failed. Transaction not applied."
		_update_detail_panel()


# ═══════════════════════════════════════════════════════════
# LEFT PANEL: Compact list of 6 upgrades
# ═══════════════════════════════════════════════════════════

func _refresh_list() -> void:
	if meta_ref == null:
		return

	# Update balance
	balance_label.text = "Rune Stones: %d" % meta_ref.rune_stones

	# Clear old items
	for child in list_panel.get_children():
		child.queue_free()
	list_items.clear()

	var upgrades: Array = meta_ref.PERM_UPGRADES
	for i in upgrades.size():
		var upg: Dictionary = upgrades[i]
		var item := _create_list_item(i, upg)
		list_panel.add_child(item)
		list_items.append(item)


func _create_list_item(index: int, upg: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(172, 28)

	var upg_id: String = upg["id"]
	var cur_tier: int = meta_ref.get_perm_tier(upg_id)
	var max_tier: int = upg["max_tier"]
	var is_maxed: bool = cur_tier >= max_tier
	var is_impl: bool = meta_ref.is_purchasable(upg_id)
	var is_selected: bool = (index == selected_index)

	# Style
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2

	if is_selected:
		style.bg_color = Color(0.12, 0.1, 0.22, 0.95)
		style.border_color = Color(1.0, 0.85, 0.3, 1.0)
	elif not is_impl:
		style.bg_color = Color(0.05, 0.05, 0.07, 0.7)
		style.border_color = Color(0.2, 0.2, 0.25, 0.4)
	elif is_maxed:
		style.bg_color = Color(0.08, 0.12, 0.08, 0.9)
		style.border_color = Color(0.3, 0.55, 0.3, 0.6)
	else:
		style.bg_color = Color(0.07, 0.07, 0.13, 0.85)
		style.border_color = Color(0.35, 0.4, 0.65, 0.5)

	panel.add_theme_stylebox_override("panel", style)

	# Horizontal layout: [#] Name | Tier/Status
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	panel.add_child(hbox)

	# Hotkey
	var hotkey_lbl := Label.new()
	hotkey_lbl.text = "[%d]" % (index + 1)
	hotkey_lbl.add_theme_font_size_override("font_size", 7)
	if is_selected:
		hotkey_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	else:
		hotkey_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	hbox.add_child(hotkey_lbl)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = upg.get("name", "???")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 8)
	if not is_impl:
		name_lbl.add_theme_color_override("font_color", Color(0.4, 0.42, 0.48))
	elif is_maxed:
		name_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	elif is_selected:
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	else:
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	hbox.add_child(name_lbl)

	# Status badge
	var status_lbl := Label.new()
	status_lbl.add_theme_font_size_override("font_size", 7)
	if not is_impl:
		status_lbl.text = "COMING SOON"
		status_lbl.add_theme_color_override("font_color", Color(0.45, 0.4, 0.35))
	elif is_maxed:
		status_lbl.text = "MAX"
		status_lbl.add_theme_color_override("font_color", Color(0.5, 0.75, 0.5))
	else:
		status_lbl.text = "%d/%d" % [cur_tier, max_tier]
		status_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	hbox.add_child(status_lbl)

	# Click handler: select only (NO double-click purchase)
	panel.gui_input.connect(_on_list_item_click.bind(index))

	return panel


func _on_list_item_click(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_card(index)


# ═══════════════════════════════════════════════════════════
# RIGHT PANEL: Detail view (Before→After, Cost, BUY)
# ═══════════════════════════════════════════════════════════

func _update_detail_panel() -> void:
	if meta_ref == null:
		_show_empty_detail()
		return

	if selected_index < 0:
		_show_empty_detail()
		hint_label.text = "Press 1-6 or click to select an upgrade"
		return

	var upgrades: Array = meta_ref.PERM_UPGRADES
	if selected_index >= upgrades.size():
		_show_empty_detail()
		return

	var upg: Dictionary = upgrades[selected_index]
	var upg_id: String = upg["id"]
	var cur_tier: int = meta_ref.get_perm_tier(upg_id)
	var max_tier: int = upg["max_tier"]
	var is_maxed: bool = cur_tier >= max_tier
	var is_impl: bool = meta_ref.is_purchasable(upg_id)

	# Name
	detail_name_label.text = upg.get("name", "???")

	# Description
	detail_desc_label.text = upg.get("stat_desc", "")

	# ── NOT IMPLEMENTED ──
	if not is_impl:
		detail_tier_label.text = "COMING SOON"
		detail_tier_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.35))
		detail_preview_label.text = "This upgrade is not yet\navailable for purchase."
		detail_preview_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		detail_cost_label.text = ""
		detail_status_label.text = ""
		hint_label.text = "This upgrade is not yet implemented"
		return

	# ── MAXED ──
	if is_maxed:
		detail_tier_label.text = "Tier %d / %d  --  MAX" % [cur_tier, max_tier]
		detail_tier_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		detail_preview_label.text = _build_current_stat_text(upg_id, upg, cur_tier)
		detail_preview_label.add_theme_color_override("font_color", Color(0.5, 0.75, 0.5))
		detail_cost_label.text = "Fully upgraded"
		detail_cost_label.add_theme_color_override("font_color", Color(0.4, 0.6, 0.4))
		detail_status_label.text = ""
		hint_label.text = "This upgrade is at maximum tier"
		return

	# ── PURCHASABLE (not maxed, implemented) ──
	detail_tier_label.text = "Tier %d  ->  %d  (max %d)" % [cur_tier, cur_tier + 1, max_tier]
	detail_tier_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))

	# Before → After text (reads from definition, not hardcoded)
	detail_preview_label.text = _build_before_after_text(upg_id, upg, cur_tier)

	# Cost and balance
	var next_cost: int = meta_ref.get_next_cost(upg_id)
	var can_afford: bool = meta_ref.can_buy(upg_id)
	var after_balance: int = meta_ref.rune_stones - next_cost

	detail_cost_label.text = "Cost: %d RS  |  Balance: %d -> %d" % [next_cost, meta_ref.rune_stones, after_balance]

	# Transaction state
	if purchase_in_progress:
		detail_preview_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5))
		detail_cost_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		detail_status_label.text = "Saving..."
		detail_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.4))
		hint_label.text = "Transaction in progress..."
	elif last_purchase_failed:
		detail_preview_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.4))
		detail_cost_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.35))
		detail_status_label.text = last_error_message
		detail_status_label.add_theme_color_override("font_color", Color(0.8, 0.35, 0.3))
		hint_label.text = "ENTER/SPACE to retry  |  ESC to exit"
	elif can_afford:
		detail_preview_label.add_theme_color_override("font_color", Color(0.85, 0.95, 0.7))
		detail_cost_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		detail_status_label.text = "ENTER or SPACE to buy"
		detail_status_label.add_theme_color_override("font_color", Color(0.55, 0.8, 0.5))
		hint_label.text = "ENTER / SPACE to confirm purchase"
	else:
		detail_preview_label.add_theme_color_override("font_color", Color(0.7, 0.6, 0.55))
		detail_cost_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.35))
		detail_status_label.text = "Not enough Rune Stones"
		detail_status_label.add_theme_color_override("font_color", Color(0.65, 0.35, 0.3))
		hint_label.text = "Insufficient balance"


func _show_empty_detail() -> void:
	detail_name_label.text = "Select an Upgrade"
	detail_name_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
	detail_tier_label.text = ""
	detail_desc_label.text = ""
	detail_preview_label.text = "Use keys 1-6 or click\nan upgrade on the left\nto see its details."
	detail_preview_label.add_theme_color_override("font_color", Color(0.45, 0.5, 0.55))
	detail_cost_label.text = ""
	detail_status_label.text = ""
	hint_label.text = "Press 1-6 or click to select an upgrade"


# ═══════════════════════════════════════════════════════════
# BEFORE→AFTER TEXT BUILDERS (reads from definition only)
# ═══════════════════════════════════════════════════════════

func _build_before_after_text(upg_id: String, upg: Dictionary, cur_tier: int) -> String:
	var bonus_per_tier = upg.get("bonus_per_tier", 0)
	match upg_id:
		"PERM_HP":
			var before_hp: int = 3 + cur_tier * int(bonus_per_tier)  # Config.PLAYER_MAX_HP + current perm
			var after_hp: int = before_hp + int(bonus_per_tier)
			return "Max HP: %d -> %d" % [before_hp, after_hp]
		"PERM_FORCE":
			var before_pct: float = cur_tier * bonus_per_tier * 100.0
			var after_pct: float = (cur_tier + 1) * bonus_per_tier * 100.0
			return "Pulse Force: +%.1f%% -> +%.1f%%" % [before_pct, after_pct]
		"PERM_SPEED":
			var before_pct: float = cur_tier * bonus_per_tier * 100.0
			var after_pct: float = (cur_tier + 1) * bonus_per_tier * 100.0
			return "Move Speed: +%.1f%% -> +%.1f%%" % [before_pct, after_pct]
		"PERM_CD":
			var before_s: float = cur_tier * bonus_per_tier
			var after_s: float = (cur_tier + 1) * bonus_per_tier
			return "Cooldown: -%.1fs -> -%.1fs" % [before_s, after_s]
		"PERM_MAGNET":
			var before_pct: float = cur_tier * bonus_per_tier * 100.0
			var after_pct: float = (cur_tier + 1) * bonus_per_tier * 100.0
			return "Magnet Radius: +%.0f%% -> +%.0f%%" % [before_pct, after_pct]
		"PERM_FORESIGHT":
			if cur_tier == 0:
				return "Reroll: None -> 1/run"
			return "Reroll: Active"
	return ""


func _build_current_stat_text(upg_id: String, upg: Dictionary, cur_tier: int) -> String:
	var bonus_per_tier = upg.get("bonus_per_tier", 0)
	match upg_id:
		"PERM_HP":
			var current_hp: int = 3 + cur_tier * int(bonus_per_tier)
			return "Current Max HP: %d" % current_hp
		"PERM_FORCE":
			return "Current: +%.1f%% Pulse Force" % (cur_tier * bonus_per_tier * 100.0)
		"PERM_SPEED":
			return "Current: +%.1f%% Move Speed" % (cur_tier * bonus_per_tier * 100.0)
		"PERM_CD":
			return "Current: -%.1fs Cooldown" % (cur_tier * bonus_per_tier)
		"PERM_MAGNET":
			return "Current: +%.0f%% Magnet Radius" % (cur_tier * bonus_per_tier * 100.0)
		"PERM_FORESIGHT":
			return "Reroll: Active (1/run)"
	return ""
