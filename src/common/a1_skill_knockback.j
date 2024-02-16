globals
    // Start Configuration

    constant real Common_SkillKnockback_TimerInterval = 0.03
    constant integer Common_SkillKnockback_KnockbackCount = 10
    constant real Common_SkillKnockback_KnockbackCompensate = 0.0563

    // End Configuration

    hashtable Common_SkillKnockback_Hash = InitHashtable()
endglobals

function SkillKnockbackFunc_TimerFunc takes nothing returns nothing
    local timer t
    local integer id
    local unit u
    local real distance
    local real angle
    local location loc
    local hashtable distance_Hash
    local real temp_distance
    local integer count

    set t = GetExpiredTimer()
    set id = GetHandleId(t)

    set u = LoadUnitHandle(Common_SkillKnockback_Hash, id, 0)
    set distance = LoadReal(Common_SkillKnockback_Hash, id, 1)
    set angle = LoadReal(Common_SkillKnockback_Hash, id, 2)
    set count = LoadInteger(Common_SkillKnockback_Hash, id, 3)
    set distance_Hash = LoadHashtableHandle(Common_SkillKnockback_Hash, id, 4)

    if count < Common_SkillKnockback_KnockbackCount then
        set temp_distance = LoadReal(distance_Hash, id, count)
        set loc = GenerateLocByUnit(u, temp_distance, angle)
        call SetUnitPosition(u, GetLocationX(loc), GetLocationY(loc))

        set count = count + 1
        call SaveInteger(Common_SkillKnockback_Hash, id, 3, count)
    else
        call PauseTimer(t)
        call FlushChildHashtable(Common_SkillKnockback_Hash, id)
        call FlushChildHashtable(distance_Hash, id)
        call DestroyTimer(t)

        // Unfreezing
        call PauseUnit(u, false)
    endif

    // Clear leaks
    set t = null
    set u = null
    call RemoveLocation(loc)
    set loc = null
    set distance_Hash = null
endfunction

// 通用击退技能
// 参数：单位，距离，角度
// 返回：持续时间
function SkillKnockbackFunc takes unit u, real distance, real angle returns real
    local timer t
    local integer id
    local hashtable distance_Hash
    local real temp_distance
    local real remaining_distance
    local real compensate
    local integer i

    set t = CreateTimer()
    set id = GetHandleId(t)
    set distance_Hash = InitHashtable()

    call SaveUnitHandle(Common_SkillKnockback_Hash, id, 0, u)
    call SaveReal(Common_SkillKnockback_Hash, id, 1, distance)
    call SaveReal(Common_SkillKnockback_Hash, id, 2, angle)
    call SaveInteger(Common_SkillKnockback_Hash, id, 3, 0)

    // linear decrease
    set i = 0
    set temp_distance = 0
    set remaining_distance = distance
    set compensate = distance * Common_SkillKnockback_KnockbackCompensate / Common_SkillKnockback_KnockbackCount
    loop
        exitwhen i > Common_SkillKnockback_KnockbackCount
        set temp_distance = remaining_distance / 4
        set remaining_distance = remaining_distance - temp_distance
        set temp_distance = temp_distance + compensate
        if temp_distance < 0.01 then
            set temp_distance = 0.01
        endif
        call SaveReal(distance_Hash, id, i, temp_distance)
        set i = i + 1
    endloop

    call SaveHashtableHandle(Common_SkillKnockback_Hash, id, 4, distance_Hash)

    // Freezing
    call PauseUnit(u, true)

    call TimerStart(t, Common_SkillKnockback_TimerInterval, true, function SkillKnockbackFunc_TimerFunc)

    // Clear leaks
    set t = null
    set distance_Hash = null

    return Common_SkillKnockback_TimerInterval * Common_SkillKnockback_KnockbackCount
endfunction
