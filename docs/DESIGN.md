# Design notes

## Goal

Let ordinary Power weapons use the native smart-gun lock-on and tracking behavior, without
adding items to the inventory and without native code patches.

## Why evolution is changed

The native smart-gun handler is gated by the weapon record's `evolution` field. Experiments
showed that changing the attack package and smart stats alone is not enough: with
`evolution = Power` there is no lock UI and no tracking. With `evolution = Smart` plus
`Attacks.SmartBulletHighPackage` and the smart stats, native lock-on and tracking work.

TweakXL applies `evolution = WeaponEvolution.Smart` and
`crosshair = Crosshairs.SmartGun` at load time for 710 Power weapon records.
`rangedAttacks` is intentionally **not** changed: NPCs using the same records keep their
original hitscan attack package and behave normally.

## Runtime part

On equip (and once shortly after loading a save), the redscript:

1. Checks that the weapon is ranged, not a sniper/precision rifle, and `evolution == Smart`.
2. Reads the weapon's baseline `SmartGunHitProbability`. If it is already > 0, the weapon is
   a native smart gun and is skipped.
3. Applies additive stat modifiers to the weapon:
   - locking / targetable / tag-lock angles: 14° (hip and ADS);
   - acquisition range: 30 m;
   - time to lock: 0 s; starting accuracy: 1.0;
   - projectile velocity: 70 m/s;
   - one locked target, one lock point, chest only;
   - reload/aim/swap behavior matching a simple single-target setup.
4. Overrides the attack package with `Attacks.SmartBulletHighPackage`.
5. Sends `EnableSmartGunHandlerEvent` to the weapon.

## Why Tech weapons are excluded

Several Tech-weapon mechanics check `evolution == Tech` directly, for example:

- `weaponTransitions.script`: charge state and full-charge stamina penalty;
- `damageManager.script`: fully-charged damage flag;
- `weapon.script`: tech pierce charge handling;
- `NPCPuppet.script`: NPC tech-pierce sensor flag;
- Kiroshi tech preview.

Converting Tech weapons to Smart would remove those mechanics. The 195 Tech records in the
target list are therefore left untouched; they keep normal firing and no smart lock.

## Known side effects

- The 710 records are classified as Smart in shops/inventory (icons, labels, tooltips).
  Prices, vendor stock and loot tables are not modified.
- Enemy time-between-hits against cover uses `coverVsSmartWeaponsMultiplier` for these
  records because `targetShootComponent.script` branches on evolution.
- Power/Tech perk bonuses are driven by weapon tags (`PowerWeapon` / `TechWeapon`), which are
  not changed, so existing perks still apply. Smart perks require the `SmartWeapon` tag and
  do not apply to converted records.
- Ballistics change from hitscan to a smart projectile; damage and hit timing are not
  identical to the original weapon.

## Alternatives considered

- **Native RED4ext hook**: would avoid record-level changes, but the gate/handler internals
  were not located reliably; hooking experiments caused crashes.
- **Blackboard-only fake lock UI + `QueueHitEvent`**: no native tracking and higher damage
  consistency risk.
- **Duplicate smart weapon records**: avoids NPC effects but requires inventory/item swaps and
  loses mod attachments.

## Compatibility

Tested with game 2.31 (build 5294808), RED4ext 1.30.0, TweakXL 1.11.4 and redscript/scc 0.5.31.
A game update may change record names or stat behavior; regeneration of the YAML may be needed.
