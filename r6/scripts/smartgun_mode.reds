module SmartGunMode

// 已施加的 stat 修饰（记录目标，便于完整移除）
public class SgmStatMod extends IScriptable
{
  public let target: StatsObjectID;
  public let mod: ref<gameStatModifierData>;
}

// 读档/进世界后延迟一次应用，确保当前手持武器也被处理
public class SmartGunApplyDelay extends DelayCallback
{
  public let m_applier: wref<SmartGunApplier>;

  public func Call() -> Void
  {
    if IsDefined(this.m_applier) {
      this.m_applier.ApplyToActiveWeapon();
    };
  }
}

public class SmartGunApplier extends IScriptable
{
  private let m_player: wref<PlayerPuppet>;
  private let m_mods: array<ref<SgmStatMod>>;
  private let m_lastState: Int32;

  public static func Create(player: ref<PlayerPuppet>) -> ref<SmartGunApplier>
  {
    let applier: ref<SmartGunApplier> = new SmartGunApplier();
    applier.m_player = player;
    applier.m_lastState = -1;
    return applier;
  }

  private final func Notify(text: String) -> Void
  {
    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = 2.00;
    msg.message = text;
    msg.isInstant = true;
    msg.type = SimpleMessageType.Neutral;
    GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
  }

  public final func ScheduleInitialApply() -> Void
  {
    let cb: ref<SmartGunApplyDelay> = new SmartGunApplyDelay();
    cb.m_applier = this;
    GameInstance.GetDelaySystem(this.m_player.GetGame()).DelayCallback(cb, 2.00, false);
  }

  public final func ApplyToActiveWeapon() -> Void
  {
    let applied: Bool;
    let nativeSmart: Bool;
    let weapon: ref<WeaponObject>;
    this.ClearMods();
    weapon = GameObject.GetActiveWeapon(this.m_player);
    if IsDefined(weapon) {
      nativeSmart = GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatType.SmartGunHitProbability) > 0.00;
    };
    applied = this.Apply(weapon);
    if (applied || nativeSmart) && this.m_lastState != 1 {
      this.m_lastState = 1;
      this.Notify("SMG ON");
    } else {
      if !(applied || nativeSmart) && this.m_lastState == 1 {
        this.m_lastState = 0;
        this.Notify("SMG OFF");
      };
    };
  }

  public final func Apply(weapon: ref<WeaponObject>) -> Bool
  {
    let wid: StatsObjectID;
    let package: ref<RangedAttackPackage_Record>;

    if !this.IsSupportedWeapon(weapon) {
      return false;
    };
    wid = Cast<StatsObjectID>(weapon.GetEntityID());

    // 原生智能枪自带 SmartGunHitProbability > 0，跳过
    if GameInstance.GetStatsSystem(this.m_player.GetGame()).GetStatValue(wid, gamedataStatType.SmartGunHitProbability) > 0.00 {
      return false;
    };

    // 秒锁 + 14° 锁定角 + 单目标单锁点
    this.SetStat(wid, gamedataStatType.SmartGunHitProbability, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunTargetAcquisitionRange, 30.00);
    this.SetStat(wid, gamedataStatType.SmartGunTargetingRectangleSizeIncrease, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipLockingAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipLockingAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsLockingAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsLockingAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipTargetableAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipTargetableAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsTargetableAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsTargetableAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipTagLockAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipTagLockAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsTagLockAngleYaw, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsTagLockAnglePitch, 14.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipTimeToLock, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsTimeToLock, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTimeToMaxAccuracy, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunStartingAccuracy, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunPlayerProjectileVelocity, 70.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackChestComponents, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackHeadComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackLegComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackBreachComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackWeakSpotComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackVehicleComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunTrackMechanicalComponents, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunContinousLockEnabled, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunAdsMaxLockedTargets, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunHipMaxLockedTargets, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunMaxLockedPointsPerTarget, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunDisableOnReload, 1.00);
    this.SetStat(wid, gamedataStatType.SmartGunKeepTargetsOnAimStateChange, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunKeepTargetsOnWeaponSwap, 0.00);
    this.SetStat(wid, gamedataStatType.SmartGunUseEvenDistributionTargeting, 1.00);

    package = TweakDBInterface.GetRangedAttackPackageRecord(t"Attacks.SmartBulletHighPackage");
    if IsDefined(package) {
      weapon.OverrideRangedAttackPackage(package);
    };

    this.SendHandlerEvent(weapon, true);
    return true;
  }

  public final func Shutdown() -> Void
  {
    this.ClearMods();
  }

  private final func SetStat(target: StatsObjectID, stat: gamedataStatType, desired: Float) -> Void
  {
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_player.GetGame());
    let entry: ref<SgmStatMod> = new SgmStatMod();
    entry.target = target;
    entry.mod = RPGManager.CreateStatModifier(stat, gameStatModifierType.Additive, desired - stats.GetStatValue(target, stat));
    ArrayPush(this.m_mods, entry);
    stats.AddModifier(target, entry.mod);
  }

  private final func ClearMods() -> Void
  {
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_player.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(this.m_mods) {
      stats.RemoveModifier(this.m_mods[i].target, this.m_mods[i].mod);
      i += 1;
    };
    ArrayClear(this.m_mods);
  }

  private final func SendHandlerEvent(weapon: ref<WeaponObject>, enable: Bool) -> Void
  {
    let evt: ref<EnableSmartGunHandlerEvent> = new EnableSmartGunHandlerEvent();
    evt.owner = this.m_player;
    evt.enable = enable;
    weapon.QueueEvent(evt);
  }

  private final func IsSupportedWeapon(weapon: ref<WeaponObject>) -> Bool
  {
    let itemType: gamedataItemType;
    if !IsDefined(weapon) || !weapon.IsRanged() {
      return false;
    };

    itemType = WeaponObject.GetWeaponType(weapon.GetItemID());
    if Equals(itemType, gamedataItemType.Wea_SniperRifle) || Equals(itemType, gamedataItemType.Wea_PrecisionRifle) {
      return false;
    };
    // 只处理被 mod 转成 Smart 的 Power 枪；Tech/未转换枪保持原样
    return Equals(RPGManager.GetWeaponEvolution(weapon.GetItemID()), gamedataWeaponEvolution.Smart);
  }
}

@addField(PlayerPuppet)
private let m_sgmApplier: ref<SmartGunApplier>;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool
{
  let result: Bool = wrappedMethod();
  if this.IsControlledByLocalPeer() || IsHost() {
    this.m_sgmApplier = SmartGunApplier.Create(this);
    this.m_sgmApplier.ScheduleInitialApply();
  };
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool
{
  if IsDefined(this.m_sgmApplier) {
    this.m_sgmApplier.Shutdown();
    this.m_sgmApplier = null;
  };
  return wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnWeaponEquipEvent(evt: ref<WeaponEquipEvent>) -> Bool
{
  let result: Bool = wrappedMethod(evt);
  if IsDefined(this.m_sgmApplier) {
    this.m_sgmApplier.ApplyToActiveWeapon();
  };
  return result;
}
