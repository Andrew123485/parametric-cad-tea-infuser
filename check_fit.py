"""Clamshell pod on a stem: reach the liquor, dump by opening, roomy PP case."""

CUP_H, CUP_TOP_ID, CUP_BOT_ID = 100.0, 57.0, 40.0
CUP_TOP_OD = 60.0
POD_R, WALL, WALL_GAP, NEST = 15.0, 1.3, 3.0, 2.4
STEM_H = 28.0
HOOK_W, HOOK_INNER_D, HOOK_THROAT = 9.0, 3.4, 2.4
OPEN_DEG = 140.0
CASE_L, CASE_W, CASE_H = 130.0, 56.0, 38.0
DIV_X, DIV_T = -22.0, 2.4
DRY_L = CASE_L / 2 + DIV_X - DIV_T / 2
WET_L = CASE_L / 2 - DIV_X - DIV_T / 2
DRY_ML = DRY_L * (CASE_W - 6) * 18 / 1000
POD_ML = 4 / 3 * 3.1416 * (POD_R - WALL) ** 3 / 1000
WATER_Z = 70.0
Z_BOT = CUP_H - NEST - STEM_H - 2 * POD_R
INFUSER_L = STEM_H + 2 * POD_R + 14


def cup_r(z):
    return CUP_BOT_ID / 2 + (CUP_TOP_ID / 2 - CUP_BOT_ID / 2) * (z / CUP_H)


axis = min(
    cup_r(z) - POD_R - WALL_GAP
    for z in range(int(Z_BOT), int(Z_BOT + 2 * POD_R) + 1)
)
sip = cup_r(CUP_H - NEST) + axis - POD_R

for z in range(int(Z_BOT), int(Z_BOT + 2 * POD_R) + 1):
    assert axis + POD_R + 1.4 <= cup_r(z), (z, axis + POD_R + 1.4, cup_r(z))

assert CUP_TOP_OD == 60 and CUP_H == 100
assert HOOK_W <= 10
assert HOOK_THROAT < HOOK_INNER_D
assert sip >= 18
assert Z_BOT < WATER_Z - 18
assert 2 * POD_R <= 32  # shallow bowl: wet leaf cannot hide up a tube
assert OPEN_DEG >= 120  # bottom swings past vertical, contents fall
assert 8 <= POD_ML <= 16
assert DRY_ML >= 35  # packet pocket, not a thimble
assert INFUSER_L <= WET_L - 8  # toss-in clearance, not a glove
assert CASE_W >= 50 and CASE_H >= 34  # roomy PP, not a pen sleeve
assert axis + POD_R + 2.0 <= cup_r(Z_BOT)

print("ok")
print(f"  pod D{2*POD_R:.0f} mm, {POD_ML:.0f} ml, depth {POD_R:.0f} mm, open {OPEN_DEG:.0f} deg")
print(f"  stem {STEM_H:.0f} mm, z_bot={Z_BOT:.0f}, sip {sip:.0f} mm, axis {axis:.1f}")
print(f"  case {CASE_L:.0f}x{CASE_W:.0f}x{CASE_H:.0f} mm, dry {DRY_ML:.0f} ml, wet {WET_L:.0f} mm")
