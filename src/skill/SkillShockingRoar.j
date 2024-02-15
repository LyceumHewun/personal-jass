// 弱者退散 - 咆哮技能
globals
    // Start Configuration

    real SkillShockingRoar_AoE = 300.
    real SkillShockingRoar_KnockbackDuration = 0.02
    integer SkillShockingRoar_KnockbackCount = 10
    integer SkillShockingRoar_KnockbackDamage = 20
    real SkillShockingRoar_DizzinessTime = 1.5

    // End Configuration

    hashtable SkillShockingRoar_Hash = InitHashtable()
endglobals

function SkillShockingRoar_TimerFunc takes nothing returns nothing
    local timer t
    local integer id
    local unit caster
    local group target_g
    local group temp_g
    local unit u
    local hashtable angle_Hash
    local real temp_angle
    local effect temp_e
    local integer temp_KnockbackCount
    local hashtable distance_Hash
    local real temp_distance

    set t = GetExpiredTimer()
    set id = GetHandleId(t)
    set caster = LoadUnitHandle(SkillShockingRoar_Hash, id, 0)
    set target_g = LoadGroupHandle(SkillShockingRoar_Hash, id, 1)
    set angle_Hash = LoadHashtableHandle(SkillShockingRoar_Hash, id, 2)
    set temp_KnockbackCount = LoadInteger(SkillShockingRoar_Hash, id, 3)
    set distance_Hash = LoadHashtableHandle(SkillShockingRoar_Hash, id, 4)

    set temp_g = CreateGroup()

    if ( temp_KnockbackCount < SkillShockingRoar_KnockbackCount ) then
        set temp_KnockbackCount = temp_KnockbackCount + 1
        call SaveInteger(SkillShockingRoar_Hash, id, 3, temp_KnockbackCount)
        call GroupAddGroup(target_g, temp_g)
        loop
            set u = FirstOfGroup(temp_g)
            exitwhen u == null
            call GroupRemoveUnit(temp_g, u)
            set temp_angle = LoadReal(angle_Hash, GetHandleId(u), 0)

            if IsUnitAliveBJ(u) then
                // 击退
                set temp_distance = LoadReal(distance_Hash, GetHandleId(u), 0)
                set temp_distance = temp_distance / SkillShockingRoar_KnockbackCount
                call UnitKnockback(u, temp_distance, temp_angle)
                // 伤害
                call UnitDamageTarget(caster, u, SkillShockingRoar_KnockbackDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
            endif
        endloop
    else
        call PauseTimer(t)
        call DestroyTimer(t)
        call FlushChildHashtable(SkillShockingRoar_Hash, id)
    endif
endfunction

function SkillShockingRoar takes unit caster returns nothing
    local timer t
    local integer id
    local location loc_caster
    local group target_g
    local group temp_g
    local unit u
    local hashtable angle_Hash
    local real temp_angle
    local effect temp_e
    local hashtable effect_Hash
    local hashtable distance_Hash
    local real temp_distance

    set t = CreateTimer()
    set id = GetHandleId(t)

    call SaveUnitHandle(SkillShockingRoar_Hash, id, 0, caster)

    set temp_g = CreateGroup()
    set angle_Hash = InitHashtable()
    set effect_Hash = InitHashtable()
    set distance_Hash = InitHashtable()

    set loc_caster = GetUnitLoc(caster)
    set target_g = GetUnitsInRangeOfLocAll(SkillShockingRoar_AoE, loc_caster)

    // 移除单位
    call GroupRemoveUnit(target_g, caster)
    call GroupAddGroup(target_g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        // 友军单位
        if ( not IsUnitEnemy( u, GetOwningPlayer( caster ) ) ) or ( not IsUnitAliveBJ(u) ) then
            call GroupRemoveUnit(target_g, u)
        endif
        // 无敌单位
        if ( IsUnitType(u, UNIT_TYPE_STRUCTURE) ) then
            call GroupRemoveUnit(target_g, u)
        endif
        // 魔免单位
        if ( IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) ) then
            call GroupRemoveUnit(target_g, u)
        endif
        // 空中单位
        if ( IsUnitType(u, UNIT_TYPE_FLYING) ) then
            call GroupRemoveUnit(target_g, u)
        endif
    endloop

    call SaveGroupHandle(SkillShockingRoar_Hash, id, 1, target_g)

    // 禁止单位移动
    call GroupAddGroup(target_g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        call SetUnitPropWindow(u, 0)
        call BlzUnitInterruptAttack(u)
        set temp_e = AddSpecialEffectTargetUnitBJ( "overhead", u, "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl" )
        call SaveEffectHandle(effect_Hash, GetHandleId(u), 0, temp_e)
    endloop

    // 计算角度
    call GroupAddGroup(target_g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        // 计算角度
        set temp_angle = CalcAngleByUnit(u, caster)
        call SaveReal(angle_Hash, GetHandleId(u), 0, temp_angle)
    endloop

    call SaveHashtableHandle(SkillShockingRoar_Hash, id, 2, angle_Hash)

    // 计算距离
    call GroupAddGroup(target_g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        // 计算距离
        set temp_distance = CalcDistance(GetUnitX(u), GetUnitY(u), GetUnitX(caster), GetUnitY(caster))
        set temp_distance = SkillShockingRoar_AoE - temp_distance
        call SaveReal(distance_Hash, GetHandleId(u), 0, temp_distance)
    endloop

    call SaveHashtableHandle(SkillShockingRoar_Hash, id, 4, distance_Hash)

    // 施法者效果
    set temp_e = AddSpecialEffectLoc("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", loc_caster)
    call BlzSetSpecialEffectScale( temp_e, 1.5 )
    call DestroyEffect(temp_e)
    set temp_e = AddSpecialEffectLoc("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", loc_caster)
    call DestroyEffect(temp_e)
    set temp_e = null
    // 群体效果
    // KnockbackCount
    call SaveInteger(SkillShockingRoar_Hash, id, 3, 0)
    // timer
    call TimerStart(t, SkillShockingRoar_KnockbackDuration, true, function SkillShockingRoar_TimerFunc)

    // 等待眩晕结束
    call TriggerSleepAction(SkillShockingRoar_DizzinessTime)

    // 恢复单位移动
    call GroupAddGroup(target_g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        call SetUnitPropWindow(u, GetUnitDefaultPropWindow(u))
        call DestroyEffect(LoadEffectHandle(effect_Hash, GetHandleId(u), 0))
    endloop

    // Clear leaks
    call RemoveLocation(loc_caster)
    call DestroyGroup(target_g)
    call DestroyGroup(temp_g)
    call DestroyTimer(t)
    set t = null
    set loc_caster = null
    set target_g = null
    set temp_g = null
    set angle_Hash = null
    set effect_Hash = null
    set distance_Hash = null
endfunction
