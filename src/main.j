// 选择技能目标
// 参数：施法者，施法范围
function SelectSkillTarget takes unit caster, real rd returns unit
    local unit target = null
    local group g = GetUnitsInRangeOfLocAll( rd / 2 , GetUnitLoc(caster))
    local unit u
    call GroupRemoveUnit(g, caster)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if IsUnitEnemy(u, GetOwningPlayer(caster)) and IsUnitAliveBJ(u) then
            set target = u
            if IsUnitType(u, UNIT_TYPE_HERO) then
                exitwhen true
            endif
        endif
    endloop
    call DestroyGroup(g)
    return target
endfunction