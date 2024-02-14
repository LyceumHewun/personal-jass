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

// 生成随机伤害函数
function GenerateRandomDamage takes integer minDamage, integer maxDamage returns integer
    return GetRandomInt(minDamage, maxDamage)
endfunction

// 计算两点之间的角度
function GetAngleBetweenPoints takes real x1, real y1, real x2, real y2 returns real
    local real dx = x2 - x1
    local real dy = y2 - y1
    local real angle = bj_RADTODEG * Atan2(dy, dx)
    // debug
    // call BJDebugMsg("angle: " + I2S(R2I(angle)))
    return angle
endfunction

// 单位击退（根据角度和距离设置新位置）
function UnitKnockback takes unit u, real distance, real angle returns nothing
    local real angleRad = angle * bj_DEGTORAD
    local real x = GetUnitX(u) - distance * Cos(angleRad)
    local real y = GetUnitY(u) - distance * Sin(angleRad)
    call SetUnitPosition(u, x, y)
endfunction

// 获取单位面向角度<distance>距离的点
function GetUnitFacingNewLoc takes unit u, real distance returns location
    local real angle = GetUnitFacing(u)
    local real angleRad = angle * bj_DEGTORAD
    local real x = GetUnitX(u) + distance * Cos(angleRad)
    local real y = GetUnitY(u) + distance * Sin(angleRad)
    return Location(x, y)
endfunction
