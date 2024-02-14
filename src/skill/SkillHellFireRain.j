// 陨石雨
function SkillHellFireRain takes unit caster returns nothing
    // 施放距离
    local real rd = 2000.
    // 影响范围
    local real scope = 500.
    // 陨石数量
    local integer subQuantity = 10
    // 陨石影响范围
    local real subScope = 160.
    // 每个陨石伤害
    local integer minDamage = 80
    local integer maxDamage = 300
    // 每个陨石间隔
    local real interval = 0.6
    local unit target = SelectSkillTarget(caster, rd)
    local unit u
    local effect effect0
    local location loc
    local effect effect1
    local rect r
    local location randomLoc
    if target == null then
        set target = null
        // call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "no target")
        return
    endif
    // 特效
    // foreach 1-10
    set bj_forLoopAIndex = 2
    set bj_forLoopAIndexEnd = subQuantity
    set loc = GetUnitLoc(target)
    set effect0 = AddSpecialEffectLocBJ( loc, "Units\\Demon\\Infernal\\InfernalBirth.mdl" )
    call BlzSetSpecialEffectScale( effect0, 0.8 )
    call UnitDamagePointLoc( caster, 0.8, subScope, loc, GetRandomInt(minDamage, maxDamage), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
    call TriggerSleepAction(interval)
    // 创建受影响区域
    // 创建target为中心的矩形
    set r = RectFromCenterSizeBJ(GetUnitLoc(target), scope, scope)
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        set bj_forLoopAIndex = bj_forLoopAIndex + 1
        // do
        set randomLoc = GetRandomLocInRect(r)
        set effect1 = AddSpecialEffectLocBJ( randomLoc , "Units\\Demon\\Infernal\\InfernalBirth.mdl" )
        call BlzSetSpecialEffectScale( effect1, 0.8 )
        // 伤害
        call UnitDamagePointLoc( caster, 0.8, subScope, randomLoc, GetRandomInt(minDamage, maxDamage), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
        call TriggerSleepAction(interval)
        call DestroyEffect(effect1)
        set effect1 = null
    endloop
    // 清理
    set target = null
    call DestroyEffect(effect0)
    set effect0 = null
    call RemoveLocation(loc)
    set loc = null
    call RemoveLocation(randomLoc)
    set randomLoc = null
    set r = null
endfunction
