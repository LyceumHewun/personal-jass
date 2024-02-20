globals
    // Start Configuration

    constant real Common_SkillKnockback_TimerDefaultTime = 0.8
    constant real Common_SkillKnockback_TimerInterval = 0.02

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
    local integer current_count

    set t = GetExpiredTimer()
    set id = GetHandleId(t)

    set u = LoadUnitHandle(Common_SkillKnockback_Hash, id, 0)
    set angle = LoadReal(Common_SkillKnockback_Hash, id, 1)
    set count = LoadInteger(Common_SkillKnockback_Hash, id, 2)
    set current_count = LoadInteger(Common_SkillKnockback_Hash, id, 3)
    set distance_Hash = LoadHashtableHandle(Common_SkillKnockback_Hash, id, 4)

    if current_count < count then
        set temp_distance = LoadReal(distance_Hash, id, current_count)
        set loc = GenerateLocByUnit(u, temp_distance, angle)
        call SetUnitPosition(u, GetLocationX(loc), GetLocationY(loc))

        set current_count = current_count + 1
        call SaveInteger(Common_SkillKnockback_Hash, id, 3, current_count)
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
function SkillKnockbackFunc_Time takes unit u, real distance, real angle, real time returns real
    local timer t
    local integer id
    local hashtable distance_Hash
    local real speed
    local real acceleration
    local integer count
    local integer i
    local real temp_distance
    local real distance_sum
    local real temp_time

    set t = CreateTimer()
    set id = GetHandleId(t)
    set distance_Hash = InitHashtable()

    set speed = distance / ( time / 2 )
    set acceleration = -speed / time
    set count = R2I( time / Common_SkillKnockback_TimerInterval )

    call SaveUnitHandle(Common_SkillKnockback_Hash, id, 0, u)
    call SaveReal(Common_SkillKnockback_Hash, id, 1, angle)
    call SaveInteger(Common_SkillKnockback_Hash, id, 2, count)
    call SaveInteger(Common_SkillKnockback_Hash, id, 3, 1)
    call SaveHashtableHandle(Common_SkillKnockback_Hash, id, 4, distance_Hash)

    // linear decrease
    set i = 1
    set temp_distance = 0
    set distance_sum = 0
    loop
        exitwhen i > count

        set temp_time = Common_SkillKnockback_TimerInterval * i
        set temp_distance = speed * temp_time + acceleration * temp_time * temp_time / 2

        call SaveReal(distance_Hash, id, i, temp_distance - distance_sum)

        set distance_sum = temp_distance

        set i = i + 1
    endloop

    // Freezing
    call PauseUnit(u, true)

    call TimerStart(t, Common_SkillKnockback_TimerInterval, true, function SkillKnockbackFunc_TimerFunc)

    // Clear leaks
    set t = null
    set distance_Hash = null

    return time
endfunction

function SkillKnockbackFunc takes unit u, real distance, real angle returns real
    return SkillKnockbackFunc_Time(u, distance, angle, Common_SkillKnockback_TimerDefaultTime)
endfunction
