// 选择技能目标
// 参数：施法者，施法范围
// 优先返回敌方英雄，其次返回敌方单位
// 优先返回距离施法者最近的目标
function SelectSkillTarget takes unit caster, real rd returns unit
    local unit target = null
    // FIXME
    local group g = GetUnitsInRangeOfLocAll( rd, GetUnitLoc(caster))
    local unit u
    local real dis = rd
    local real tempDis
    local boolean hasHero = false
    call GroupRemoveUnit(g, caster)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            // 判断是否为英雄
            if IsUnitType(u, UNIT_TYPE_HERO) and not hasHero then
                set hasHero = true
                set dis = CalcDistance(GetUnitX(caster), GetUnitY(caster), GetUnitX(u), GetUnitY(u))
                set target = u
            elseif IsUnitType(u, UNIT_TYPE_HERO) and hasHero then
                // 计算距离
                set tempDis = CalcDistance(GetUnitX(caster), GetUnitY(caster), GetUnitX(u), GetUnitY(u))
                if tempDis < dis then
                    set dis = tempDis
                    set target = u
                endif
            else
                if not hasHero then
                    // 计算距离
                    set tempDis = CalcDistance(GetUnitX(caster), GetUnitY(caster), GetUnitX(u), GetUnitY(u))
                    if tempDis < dis then
                        set dis = tempDis
                        set target = u
                    endif
                endif
            endif
        endif
    endloop
    call DestroyGroup(g)
    return target
endfunction

// 单位击退（根据角度和距离设置新位置）
function UnitKnockback takes unit u, real distance, real angle returns nothing
    local real angleRad = angle * bj_DEGTORAD
    local real x = GetUnitX(u) - distance * Cos(angleRad)
    local real y = GetUnitY(u) - distance * Sin(angleRad)
    call SetUnitPosition(u, x, y)
endfunction
