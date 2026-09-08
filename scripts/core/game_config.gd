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
const SHAKE_DECAY := 0.8  # trauma/second — decay rate
const SHAKE_MAX_OFFSET := 3.0  # logical px — max camera displacement (PROPOSED)
const SHAKE_NOISE_SPEED := 12.0  # Hz — noise sample rate for smooth shake (PROPOSED)
const SHAKE_STRENGTH := 1.0  # multiplier [0,1] — 0 disables shake entirely (PROPOSED)

const PULSE_VFX_DURATION := 0.2  # s — expanding ring (F005: 0.15→0.2)
const WALL_DUST_LIFETIME := 0.3  # s
const ALTAR_FLASH_DURATION := 0.2  # s

# ─── ENEMIES ─────────────────────────────────────────────
# M0: Chỉ có Slime
const SLIME_HP := 1
const SLIME_SPEED := 30.0  # px/s — chậm vì sân nhỏ (420×210)
const SLIME_SIZE := 10  # px
const SLIME_PUSH_WEIGHT := 1.0  # Standard (nhận đầy đủ push velocity)
const SLIME_SHARD_DROP := 1

# ─── SPAWN ───────────────────────────────────────────────
const SPAWN_INTERVAL := 2.0  # s — 1 con / 2s
const SPAWN_MAX_CONCURRENT := 15
const SPAWN_MIN_DISTANCE := 80.0  # px — khoảng cách tối thiểu từ player

# ─── SHARDS ──────────────────────────────────────────────
const SHARD_SIZE := 4  # px
const SHARD_MAGNET_RADIUS := 40.0  # px
const SHARD_MAGNET_SPEED := 200.0  # px/s — tốc độ bay về player
const SHARD_LIFETIME := 8.0  # s — biến mất nếu không nhặt
const SHARD_ALTAR_BONUS := 2  # Shards bonus khi altar seal (thay vì drop 1)

# ─── ALTAR ───────────────────────────────────────────────
const ALTAR_SIZE := 24  # px (zone)
const ALTAR_POSITION := Vector2(240, 90)  # Giữa-trên playable area

# ─── COLORS (Placeholder) ───────────────────────────────
const COLOR_BACKGROUND := Color(0.039, 0.055, 0.078)  # #0a0e14
const COLOR_ARENA_FLOOR := Color(0.086, 0.110, 0.141)  # #161c24
const COLOR_WALL := Color(0.145, 0.180, 0.231)  # #252e3b

const COLOR_PLAYER := Color(0.0, 0.898, 1.0)  # #00e5ff cyan
const COLOR_PLAYER_HIT := Color(1.0, 0.3, 0.3)  # Red flash

const COLOR_SLIME := Color(0.176, 0.353, 0.153)  # #2d5a27
const COLOR_SLIME_PUSHED := Color(0.3, 0.5, 0.2)  # Lighter when pushed

const COLOR_ALTAR := Color(0.659, 0.545, 0.980)  # #a78bfa
const COLOR_ALTAR_FLASH := Color(0.8, 0.7, 1.0, 0.8)

const COLOR_SHARD := Color(0.980, 0.800, 0.082)  # #facc15
const COLOR_PULSE_RING := Color(0.0, 0.898, 1.0, 0.9)  # Cyan, match player (F005)
const COLOR_COMBO_TEXT := Color(1.0, 1.0, 1.0)  # White
