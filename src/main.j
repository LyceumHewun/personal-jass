// 计算两点之间距离
function CalcDistance takes real x1, real y1, real x2, real y2 returns real
    return SquareRoot(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
endfunction

// 选择技能目标
// 参数：施法者，施法范围
function SelectSkillTarget takes unit caster, real rd returns unit
    local unit target = null
    local group g = GetUnitsInRangeOfLocAll( rd / 2, GetUnitLoc(caster))
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