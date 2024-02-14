globals
    // Start Configuration

    constant real Common_SkillKnockback_TimerInterval = 0.03
    constant integer Common_SkillKnockback_KnockbackCount = 20

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
        // Volume touch
        call SetUnitPathing(u, true)
    endif

    // Clear leaks
    set t = null
    set u = null
    call RemoveLocation(loc)
    set loc = null
    set distance_Hash = null
endfunction

function SkillKnockbackFunc takes unit u, real distance, real angle returns nothing
    local timer t
    local integer id
    local hashtable distance_Hash
    local real temp_distance
    local real temp_distance_sum
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
    set temp_distance_sum = 0
    loop
        exitwhen i > Common_SkillKnockback_KnockbackCount
        set temp_distance = (distance - temp_distance_sum) / 3
        set temp_distance_sum = temp_distance_sum + temp_distance
        if temp_distance < 0.01 then
            set temp_distance = 0.01
        endif
        call SaveReal(distance_Hash, id, i, temp_distance)
        set i = i + 1
    endloop

    call SaveHashtableHandle(Common_SkillKnockback_Hash, id, 4, distance_Hash)

    // Freezing
    call PauseUnit(u, true)
    // Volume touch
    call SetUnitPathing(u, false)

    call TimerStart(t, Common_SkillKnockback_TimerInterval, true, function SkillKnockbackFunc_TimerFunc)

    // Clear leaks
    set t = null
    set distance_Hash = null
endfunction
