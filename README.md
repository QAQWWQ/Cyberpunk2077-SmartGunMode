# Cyberpunk2077-SmartGunMode

给《赛博朋克 2077》的普通 Power 武器加上智能枪的**锁定框、秒锁和追踪弹道**。
Tech 武器保持原样；原生智能枪不会被修改。

> 测试环境：游戏 2.31（build 5294808）、RED4ext 1.30.0、TweakXL 1.11.4、redscript/scc 0.5.31。
> 不包含任何游戏资源文件；仅通过 TweakDB 记录名与 redscript 实现。

## 功能

- **710 条 Power 武器记录**改为智能武器（`evolution = WeaponEvolution.Smart` + 智能准星）；
- 玩家当前手持的这类武器自动获得：
  - **14° 锁定角**、**30 m** 锁定距离、**0 秒锁定**；
  - 单目标、单锁点（胸部）；
  - `Attacks.SmartBulletHighPackage` 追踪弹；
- **195 条 Tech 武器完全排除**（Ticon / Kenshin / Omaha 等）：充能、穿透、科技 perk 不受影响；
- 原生智能枪（Chao 等）会被脚本跳过，保持原厂数据；
- 敌人使用这些武器时保持原攻击包，正常开枪，**不会锁定玩家**；
- 装备到生效武器时屏幕提示 **SMG ON**，切到不生效武器时提示 **SMG OFF**。

## 依赖

| 依赖 | 版本 |
|---|---|
| RED4ext | 1.30.0（已测） |
| TweakXL | 1.11.4（已测） |
| redscript / scc | 0.5.31（游戏 2.31 自带 `engine/tools/scc.exe`） |

不需要 CET。

## 安装 / 启用

1. 下载本仓库（或 Release zip）；
2. 运行 `enable.bat`，按提示输入游戏根目录，例如：
   ```bat
   enable.bat "D:\SteamLibrary\steamapps\common\Cyberpunk 2077"
   ```
   也可以在本目录创建 `game_path.txt`，里面只写游戏根目录一行；
3. **重启游戏**。

脚本会把两个文件复制到：

```
<游戏>/r6/scripts/smartgun_mode.reds
<游戏>/r6/tweaks/smartgun_smart_full.yaml
```

## 关闭 / 卸载

```bat
disable.bat "D:\SteamLibrary\steamapps\common\Cyberpunk 2077"
```

然后**重启游戏**。关闭后 evolution、准星、商店图标、敌人掩体系数、Tech 行为全部恢复原版。

> CET 覆盖层的 “Reload all mods” 不会重载 TweakXL 的 yaml，也不会重新编译 redscript；必须重启游戏。

## 原理

1. TweakXL 在启动时把 710 条 Power 武器记录写成 `evolution = Smart` 和 `crosshair = Crosshairs.SmartGun`，**不改 `rangedAttacks`**，所以 NPC 仍使用原攻击包。
2. redscript 在玩家装备武器时，对“被转换的武器”（evolution=Smart 且基线 `SmartGunHitProbability = 0`）施加：
   - `Attacks.SmartBulletHighPackage`；
   - 一组智能枪 stat（锁定角、距离、锁定时间、追踪部位、弹速等）；
   - `EnableSmartGunHandlerEvent`。
3. 原生智能枪处理器负责锁定框与追踪弹。
4. 关闭（删除文件并重启）后所有记录恢复原版。

## 已知副作用（启用期间）

- 商店/背包中这 710 条武器显示为 Smart 图标和分类；**价格、库存、掉落表未改**；
- 敌人使用这些武器攻击你时，掩体计算使用 `coverVsSmartWeaponsMultiplier`（与普通武器系数不同）；
- Power/Tech perk 依据 weapon tag 生效，tag 未改，因此原有加成仍在；Smart perk 不会误加到这些枪上；
- 武器以追踪弹代替原 hitscan，伤害/命中时机与原版不完全一致；
- 切换启用/关闭需要重启游戏。

## 调整参数

编辑 `r6/scripts/smartgun_mode.reds` 中 `Apply` 里的 stat 值：

- 锁定角：`SmartGunHipLockingAngleYaw/Pitch`、`SmartGunAdsLockingAngleYaw/Pitch`（当前 14）；
- 距离：`SmartGunTargetAcquisitionRange`（当前 30）；
- 锁定时间：`SmartGunHipTimeToLock` / `SmartGunAdsTimeToLock`（当前 0）；
- 弹速：`SmartGunPlayerProjectileVelocity`（当前 70）。

修改后重启游戏，游戏会自动调用 scc 重新编译。

## 目录结构

```
enable.bat
disable.bat
r6/scripts/smartgun_mode.reds
r6/tweaks/smartgun_smart_full.yaml
docs/DESIGN.md
docs/tech_excluded.txt
tools/gen_smart_weapons_yaml.py
```

## 排错

- 脚本编译日志：`<游戏>/r6/logs/redscript_rCURRENT.log`
- RED4ext 日志：`<游戏>/red4ext/logs/`
- TweakXL 日志：`<游戏>/red4ext/plugins/TweakXL/`
- 确认 RED4ext、TweakXL 已安装；游戏更新后可能需要重新适配记录名/API。

## English overview

SmartGunMode gives Power weapons native smart-gun lock-on and tracking in Cyberpunk 2077.
TweakXL converts 710 Power weapon records to the Smart evolution with the SmartGun crosshair;
a small redscript applies the smart projectile package and smart stats to the player's converted
weapon at equip time. Tech weapons are excluded and keep their charge/pierce behavior. Native
smart weapons are left untouched. Use `enable.bat` / `disable.bat` and restart the game to toggle.
Requires RED4ext, TweakXL and redscript/scc. Tested on game 2.31.

## License

MIT. This project is not affiliated with CD Projekt Red.
