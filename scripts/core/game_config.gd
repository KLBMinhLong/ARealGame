## game_config.gd — Stone Knight M0
## Nguồn sự thật duy nhất cho MỌI magic numbers.
## Không hardcode số ở bất kỳ file nào khác.
## Khi tuning: CHỈ SỬA FILE NÀY.
class_name Config

# ─── VIEWPORT & ARENA ────────────────────────────────────
const VIEWPORT_W := 480
const VIEWPORT_H := 270
const TILE_SIZE := 30  # px
const GRID_COLS := 16  # 480 / 30
const GRID_ROWS := 9   # 270 / 30
const BORDER_TILES := 1

# Playable area (trừ border)
const ARENA_ORIGIN := Vector2(TILE_SIZE * BORDER_TILES, TILE_SIZE * BORDER_TILES)  # (30, 30)
const ARENA_W := (GRID_COLS - BORDER_TILES * 2) * TILE_SIZE  # 14 * 30 = 420
const ARENA_H := (GRID_ROWS - BORDER_TILES * 2) * TILE_SIZE  # 7 * 30 = 210
const ARENA_END := Vector2(ARENA_ORIGIN.x + ARENA_W, ARENA_ORIGIN.y + ARENA_H)  # (450, 240)
const ARENA_CENTER := Vector2(ARENA_ORIGIN.x + ARENA_W / 2.0, ARENA_ORIGIN.y + ARENA_H / 2.0)

# ─── PLAYER ──────────────────────────────────────────────
const PLAYER_SIZE := 12  # px (placeholder square)
const PLAYER_HALF := PLAYER_SIZE / 2.0
const PLAYER_START := Vector2(240, 135)  # Giữa playable area
const PLAYER_SPEED := 120.0  # px/s
const PLAYER_MAX_HP := 3
const PLAYER_GRACE_PERIOD := 1.2  # s — bất tử sau nhận damage
const PLAYER_CONTACT_DAMAGE := 1

# ─── PLAYER DASH ─────────────────────────────────────────
const DASH_SPEED := 360.0  # px/s (3× player speed)
const DASH_DURATION := 0.15  # s — khoảng cách lướt ~54 px
const DASH_COOLDOWN := 2.0  # s — thử nghiệm ban đầu (F014)
const DASH_GHOST_INTERVAL := 0.03  # s — tần suất tạo bóng mờ
const DASH_GHOST_LIFETIME := 0.2  # s — thời gian tồn tại bóng mờ

# ─── ARCANE PULSE ────────────────────────────────────────
const PULSE_RADIUS := 50.0  # px — bán kính ảnh hưởng
const PULSE_VELOCITY := 400.0  # px/s — tốc độ quái bị bắn ra
const PULSE_DECELERATION := 800.0  # px/s² — giảm tốc tuyến tính
const PULSE_COOLDOWN := 3.5  # s
const PULSE_DISTANCE_FALLOFF := 0.5  # Tại rìa radius, quái nhận 50% velocity

# Tính toán:
# Travel distance (lý thuyết) = v² / (2 * a) = 400² / (2 * 800) = 100 px
# Travel time = v / a = 400 / 800 = 0.5s

# ─── PUSHED STATE ────────────────────────────────────────
const PUSHED_VELOCITY_THRESHOLD := 30.0  # px/s — dưới ngưỡng này = hết PUSHED
const PUSHED_TIMEOUT := 0.8  # s — safety timeout cho PUSHED state
const PUSHED_FORCE_TRANSFER := 0.6  # 60% velocity truyền khi domino

# ─── DYING STATE ─────────────────────────────────────────
const DYING_DURATION := 0.15  # s — xác bay tiếp, giữ collision

# ─── CHAIN REACTION ──────────────────────────────────────
const CHAIN_WINDOW := 0.6  # s — thời gian chain còn active sau va chạm cuối
const CHAIN_MAX_DEPTH := 8  # Safety limit

# ─── DAMAGE ──────────────────────────────────────────────
const DAMAGE_WALL_SLAM := 1
const DAMAGE_SPIKE_SLAM := 2  # F019: Sát thương đập tường gai (2x)
const DAMAGE_DOMINO := 1  # Cả 2 entity nhận
const DAMAGE_ALTAR_SEAL := 999  # Instant kill
const DAMAGE_PIT_FALL := 999  # Instant kill, no shard drop

# ─── GAME FEEL ───────────────────────────────────────────
const HITSTOP_PULSE := 0.03  # s (30ms) — slow-mo khi pulse
const HITSTOP_CHAIN_ADD := 0.005  # s — thêm per chain level
const HITSTOP_MAX := 0.05  # s (50ms cap)
const HITSTOP_TIMESCALE := 0.05  # slow-motion speed (5% = gần freeze nhưng mượt)

const SHAKE_PULSE := 0.2  # trauma add — Pulse activation
const SHAKE_WALL_SLAM := 0.15  # trauma add — enemy hits wall
const SHAKE_CHAIN_3 := 0.3  # trauma add — chain reaches x3
const SHAKE_CHAIN_5 := 0.4  # trauma add — chain reaches x5
const SHAKE_CHAIN_10 := 0.5  # trauma add — chain reaches x10 (PROPOSED)
const SHAKE_ALTAR_SEAL := 0.25  # trauma add — altar void seal (F015)
const SHAKE_DECAY := 0.8  # trauma/second — decay rate
const SHAKE_MAX_OFFSET := 3.0  # logical px — max camera displacement (PROPOSED)
const SHAKE_NOISE_SPEED := 12.0  # Hz — noise sample rate for smooth shake (PROPOSED)
const SHAKE_STRENGTH := 1.0  # multiplier [0,1] — 0 disables shake entirely (PROPOSED)

const PULSE_VFX_DURATION := 0.2  # s — expanding ring (F005: 0.15→0.2)
const WALL_DUST_LIFETIME := 0.3  # s
const ALTAR_FLASH_DURATION := 0.2  # s
const ALTAR_SEAL_DURATION := 0.25  # s — quái bị hút và thu nhỏ vào hư không (F015)

# ─── AUDIO (F016) ────────────────────────────────────────
const SFX_ENABLED := true
const SFX_MASTER_VOLUME_DB := 0.0  # dB offset applied to all SFX

# ─── ENEMIES ─────────────────────────────────────────────
const SLIME_HP := 1
const SLIME_SPEED := 30.0  # px/s
const SLIME_SIZE := 10  # px
const SLIME_PUSH_WEIGHT := 1.0
const SLIME_SHARD_DROP := 1

# F009: Speeder — nhanh, nhỏ, nhẹ
const SPEEDER_HP := 1
const SPEEDER_SPEED := 60.0  # px/s (2× slime)
const SPEEDER_SIZE := 7  # px (nhỏ hơn)
const SPEEDER_PUSH_WEIGHT := 0.6  # nhẹ → bay xa hơn
const SPEEDER_SHARD_DROP := 1

# F011: Brute — to, chậm, 2 HP, nặng
const BRUTE_HP := 2
const BRUTE_SPEED := 20.0  # px/s (chậm hơn slime)
const BRUTE_SIZE := 14  # px (hình vuông to)
const BRUTE_PUSH_WEIGHT := 1.8  # nặng → bay ít hơn
const BRUTE_SHARD_DROP := 2

# ─── SPAWN ───────────────────────────────────────────────
const SPAWN_INTERVAL := 2.0  # s — 1 con / 2s (starting)
const SPAWN_MAX_CONCURRENT := 15  # starting cap

# F010: Difficulty scaling over time (t=0 -> t=180s)
const SCALE_DURATION := 180.0  # s — full ramp over 3 minutes
const SPAWN_INTERVAL_MIN := 0.8  # s — fastest spawn rate
const SPAWN_MAX_CAP := 25  # max concurrent at full ramp
const SPAWN_MIN_DISTANCE := 80.0  # px — khoảng cách tối thiểu từ player

# F012: Phased enemy pacing
const PHASE_SPEEDER_START := 60.0  # s (phút 1: speeder bắt đầu xuất hiện)
const PHASE_BRUTE_START := 150.0  # s (phút 2.5: brute bắt đầu xuất hiện)
const PHASE_RAMP_END := 180.0  # s (phút 3: đạt tỉ lệ tối đa)

# Target ratios
const PHASE2_SPEEDER_MAX := 0.40  # Speeder đạt 40% ở mốc 150s
const PHASE3_SPEEDER_FINAL := 0.45  # Speeder ở mốc 180s+
const PHASE3_BRUTE_FINAL := 0.25  # Brute ở mốc 180s+ (Slime còn lại 30%)

# ─── WAVE SYSTEM (F017) ──────────────────────────────────
const TOTAL_WAVES := 5
const WAVE_PRE_DURATION := 1.2  # s — khoảng chuẩn bị vị trí trước khi quái bắt đầu spawn
const WAVE_INTERMISSION_DURATION := 3.0  # s — khoảng nghỉ chuẩn bị vị trí giữa các wave
const WAVE_BANNER_DURATION := 1.5  # s — thời gian hiện banner

const WAVES_DATA: Array[Dictionary] = [
	{
		"name": "Awakening",
		"duration": 35.0,
		"spawn_budget": 14,
		"max_active": 8,
		"interval_start": 2.2,
		"interval_end": 1.5,
		"speeder_chance": 0.0,
		"brute_chance": 0.0,
		"guaranteed_spawns": [],
	},
	{
		"name": "The Hunt",
		"duration": 40.0,
		"spawn_budget": 18,
		"max_active": 10,
		"interval_start": 1.8,
		"interval_end": 1.2,
		"speeder_chance": 0.30,
		"brute_chance": 0.0,
		"guaranteed_spawns": ["speeder"],
	},
	{
		"name": "Heavy Impact",
		"duration": 45.0,
		"spawn_budget": 22,
		"max_active": 12,
		"interval_start": 1.6,
		"interval_end": 1.0,
		"speeder_chance": 0.30,
		"brute_chance": 0.15,
		"guaranteed_spawns": ["brute"],
	},
	{
		"name": "The Swarm",
		"duration": 50.0,
		"spawn_budget": 28,
		"max_active": 15,
		"interval_start": 1.3,
		"interval_end": 0.8,
		"speeder_chance": 0.40,
		"brute_chance": 0.20,
		"guaranteed_spawns": ["speeder", "brute"],
	},
	{
		"name": "Final Stand",
		"duration": 60.0,
		"spawn_budget": 36,
		"max_active": 18,
		"interval_start": 1.1,
		"interval_end": 0.6,
		"speeder_chance": 0.40,
		"brute_chance": 0.25,
		"guaranteed_spawns": ["speeder", "brute"],
	},
]

# ─── SHARDS ──────────────────────────────────────────────
const SHARD_SIZE := 4  # px
const SHARD_MAGNET_RADIUS := 40.0  # px
const SHARD_MAGNET_SPEED := 200.0  # px/s — tốc độ bay về player
const SHARD_LIFETIME := 8.0  # s — biến mất nếu không nhặt
const SHARD_ALTAR_BONUS := 2  # Shards bonus khi altar seal (thay vì drop 1)

# ─── ALTAR ───────────────────────────────────────────────
const ALTAR_SIZE := 24  # px (zone)
const ALTAR_POSITION := Vector2(240, 90)  # Giữa-trên playable area

# ─── HAZARDS & SPIKE WALLS (F019) ────────────────────────
const SPIKE_DEPTH := 6.0   # px — độ nhô của gai vào trong sân

const ARENA_LAYOUTS: Array[Dictionary] = [
	{
		"wave": 1,
		"spike_walls": [],
	},
	{
		"wave": 2,
		"spike_walls": [],
	},
	{
		"wave": 3,
		# Giới thiệu Spike Wall: 2 đoạn ngắn ở giữa thành trái & phải
		"spike_walls": [
			Rect2(30, 105, 6, 60),   # Thành trái (y: 105 -> 165)
			Rect2(444, 105, 6, 60),  # Thành phải (y: 105 -> 165)
		],
	},
	{
		"wave": 4,
		# 2 đoạn gai ở thành trên (2 bên Altar)
		"spike_walls": [
			Rect2(110, 30, 60, 6),  # Trên bên trái (x: 110 -> 170)
			Rect2(310, 30, 60, 6),  # Trên bên phải (x: 310 -> 370)
		],
	},
	{
		"wave": 5,
		# 3 đoạn gai phân bổ chiến lược (Trái, Phải, Đáy trung tâm)
		"spike_walls": [
			Rect2(30, 105, 6, 60),   # Thành trái
			Rect2(444, 105, 6, 60),  # Thành phải
			Rect2(210, 234, 60, 6),  # Thành đáy trung tâm (x: 210 -> 270)
		],
	},
]

# ─── COLORS (Placeholder) ───────────────────────────────
const COLOR_BACKGROUND := Color(0.039, 0.055, 0.078)  # #0a0e14
const COLOR_ARENA_FLOOR := Color(0.086, 0.110, 0.141)  # #161c24
const COLOR_WALL := Color(0.145, 0.180, 0.231)  # #252e3b

const COLOR_PLAYER := Color(0.0, 0.898, 1.0)  # #00e5ff cyan
const COLOR_PLAYER_HIT := Color(1.0, 0.3, 0.3)  # Red flash

const COLOR_SLIME := Color(0.176, 0.353, 0.153)  # #2d5a27
const COLOR_SLIME_PUSHED := Color(0.3, 0.5, 0.2)
const COLOR_SPEEDER := Color(0.953, 0.486, 0.125)  # #f37c20 cam
const COLOR_SPEEDER_PUSHED := Color(1.0, 0.65, 0.3)
const COLOR_BRUTE := Color(0.75, 0.15, 0.2)  # #bf2633 deep red
const COLOR_BRUTE_PUSHED := Color(0.9, 0.35, 0.35)
const COLOR_BRUTE_DAMAGED := Color(0.95, 0.45, 0.45)  # Lighter red with crack (1 HP)

const COLOR_ALTAR := Color(0.659, 0.545, 0.980)  # #a78bfa
const COLOR_ALTAR_FLASH := Color(0.8, 0.7, 1.0, 0.8)

const COLOR_PILLAR := Color(0.18, 0.22, 0.28)  # Xám đá cổ
const COLOR_PILLAR_BORDER := Color(0.98, 0.80, 0.15)  # Vàng rune phát sáng
const COLOR_PILLAR_RUNE := Color(1.0, 0.92, 0.4, 0.8)  # Ký tự rune
const COLOR_SPIKE_WALL := Color(0.94, 0.25, 0.25)  # Đỏ gai
const COLOR_SPIKE_TIP := Color(1.0, 0.5, 0.3)  # Cam đầu gai

const COLOR_SHARD := Color(0.980, 0.800, 0.082)  # #facc15
const COLOR_PULSE_RING := Color(0.0, 0.898, 1.0, 0.9)  # Cyan, match player (F005)
const COLOR_COMBO_TEXT := Color(1.0, 1.0, 1.0)  # White
