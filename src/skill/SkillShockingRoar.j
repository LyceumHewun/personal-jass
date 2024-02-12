// 咆哮
// 无目标技能
// 咆哮
function SkillShockingRoar takes unit caster returns nothing
    // 影响范围
    local real scope = 600.
    // 击退间隔
    local real knockbackDuration = 0.01
    // 每次击退距离
    local real knockbackDistance = 100.
    // 击退次数
    local integer knockbackCount = 3
    // 每次击退伤害
    local integer knockbackDamage = 150
    // 伤害的单位
    local group g = GetUnitsInRangeOfLocAll( scope / 2, GetUnitLoc(caster))
    local unit u
    local integer temp_count
    local real temp_angle
    local real array angle_array
    local effect e0
    local effect e1
    local effect temp_e
    local group temp_g = CreateGroup()
    local integer i
    // 移除自己
    call GroupRemoveUnit(g, caster)

    // 眩晕单位
    call GroupAddGroup(g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        call UnitPauseTimedLife(u, true)
    endloop

    // 计算角度
    set i = 0
    call GroupAddGroup(g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        // 计算角度
        set temp_angle = GetAngleBetweenPoints(GetUnitX(u), GetUnitY(u), GetUnitX(caster), GetUnitY(caster))
        set angle_array[i] = temp_angle
        set i = i + 1
    endloop

    // 效果
    // 创建咆哮特效
    set e0 = AddSpecialEffectLoc("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", GetUnitLoc(caster))
    set e1 = AddSpecialEffectLoc("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", GetUnitLoc(caster))
    // 群体效果
    set temp_count = 0
    loop
        exitwhen temp_count >= knockbackCount
        set i = 0
        call GroupAddGroup(g, temp_g)
        loop
            set u = FirstOfGroup(temp_g)
            exitwhen u == null
            call GroupRemoveUnit(temp_g, u)
            set temp_angle = angle_array[i]
            set i = i + 1

            // 击退
            call UnitKnockback(u, knockbackDistance, temp_angle)
            // 特效
            set temp_e = AddSpecialEffectLoc("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", GetUnitLoc(u))
            // 伤害
            call UnitDamageTarget(caster, u, knockbackDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
            // 移除特效
            call DestroyEffect(temp_e)
            set temp_e = null
        endloop
        // 间隔
        call TriggerSleepAction(knockbackDuration)
        set temp_count = temp_count + 1
    endloop

    // 解除眩晕
    call GroupAddGroup(g, temp_g)
    loop
        set u = FirstOfGroup(temp_g)
        exitwhen u == null
        call GroupRemoveUnit(temp_g, u)
        call UnitPauseTimedLife(u, false)
    endloop

    // 清理
    call DestroyGroup(g)
    set g = null
    call DestroyEffect(e0)
    set e0 = null
    call DestroyEffect(e1)
    set e1 = null
    call DestroyGroup(temp_g)
    set temp_g = null
endfunction
