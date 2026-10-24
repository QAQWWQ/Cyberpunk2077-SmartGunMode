# Changelog

## Unreleased — game 2.5 compatibility

- Game 2.5 (3.0.88.46235) compatibility verified for the mod files; no
  script or yaml changes are required.
- Game 2.5 requires redscript 0.5.32 and, if used, CET 1.38.0.
- **Blocked on TweakXL**: the official TweakXL has no 2.5-compatible release
  yet. v1.0.2 will be published after it ships.
- v1.0.1 and earlier support game 2.31 only. On 2.5, the old TweakXL
  (1.11.4/1.11.5) crashes the game at startup — do not install v1.0.1 on 2.5.

## 1.0.1 — 2026-10-18

- Fix: bullets stopped tracking after equip. The game resets the weapon's
  instance-level ranged attack package during equip/draw, so the one-time
  override applied on equip was lost (the lock-on UI and stats stayed because
  they live elsewhere). The script now re-asserts
  `Attacks.SmartBulletHighPackage` from `WeaponTransition.GetDesiredAttackRecord`,
  immediately before the player state machine picks the attack record.

## 1.0.0 — 2026-10-18

- Initial release.
- Converts 710 Power weapon records to the Smart evolution with the SmartGun crosshair.
- Player's converted weapons receive `Attacks.SmartBulletHighPackage` and smart-gun stats at equip time:
  - 14° hip/ADS locking and targetable angles, 30 m range, 0 s lock time;
  - one target, one lock point (chest);
  - 70 m/s player projectile velocity.
- Tech weapons excluded (195 records) to preserve charge/pierce behavior.
- Native smart weapons are detected and skipped.
- `SMG ON` / `SMG OFF` notifications on state changes.
- `enable.bat` / `disable.bat` for restart-level toggling.
