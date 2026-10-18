# Changelog

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
