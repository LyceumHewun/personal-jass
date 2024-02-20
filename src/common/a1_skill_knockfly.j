globals
    // Start Configuration

    constant real Common_SkillKnockfly_TimerDefaultTime = 0.8
    constant real Common_SkillKnockfly_TimerInterval = 0.02

    // End Configuration

    hashtable Common_SkillKnockfly_Hash = InitHashtable()
endglobals

function SkillKnockflyFunc_TimerFunc takes nothing returns nothing
    local timer t
    local integer id
    local unit u
    local integer count
    local integer current_count
    local hashtable height_Hash
    local real temp_height

    set t = GetExpiredTimer()
    set id = GetHandleId(t)

    set u = LoadUnitHandle(Common_SkillKnockfly_Hash, id, 0)
    set count = LoadInteger(Common_SkillKnockfly_Hash, id, 1)
    set current_count = LoadInteger(Common_SkillKnockfly_Hash, id, 2)
    set height_Hash = LoadHashtableHandle(Common_SkillKnockfly_Hash, id, 3)

    if current_count < count then
        set temp_height = LoadReal(height_Hash, id, current_count)

        call UnitAddAbility(u, 'Amrf')
        call UnitRemoveAbility(u, 'Amrf')
        call SetUnitFlyHeight(u, temp_height, 100000000.)

        set current_count = current_count + 1
        call SaveInteger(Common_SkillKnockfly_Hash, id, 2, current_count)
    else
        call PauseTimer(t)
        call FlushChildHashtable(Common_SkillKnockfly_Hash, id)
        call FlushChildHashtable(height_Hash, id)
        call DestroyTimer(t)

        // Unfreezing
        call PauseUnit(u, false)
    endif

    // Clear leaks
    set t = null
    set height_Hash = null
    set u = null
endfunction

function SkillKnockflyFunc_Time takes unit u, real height, real time returns real
    local timer t
    local integer id
    local hashtable height_Hash
    local real up_time
    local real up_speed
    local real up_acceleration
    local real down_time
    local real down_acceleration
    local integer count
    local integer i
    local real temp_height
    local real temp_time

    set t = CreateTimer()
    set id = GetHandleId(t)
    set height_Hash = InitHashtable()

    set up_time = time / 2
    set up_speed = height / ( up_time / 2 )
    set up_acceleration = -up_speed / up_time
    set down_time = time - up_time
    set down_acceleration = up_speed / down_time
    set count = R2I( time / Common_SkillKnockfly_TimerInterval ) + 1

    // if count is odd number, then add 1
    if IsOdd( count ) then
        set count = count + 1
    endif

    call SaveUnitHandle(Common_SkillKnockfly_Hash, id, 0, u)
    call SaveInteger(Common_SkillKnockfly_Hash, id, 1, count)
    call SaveInteger(Common_SkillKnockfly_Hash, id, 2, 1)
    call SaveHashtableHandle(Common_SkillKnockfly_Hash, id, 3, height_Hash)

    set i = 1
    set temp_height = 0
    loop
        exitwhen i > count

        set temp_time = Common_SkillKnockfly_TimerInterval * i
        if temp_time < up_time then
            set temp_height = up_speed * temp_time + up_acceleration * temp_time * temp_time / 2
        else
            set temp_time = temp_time - up_time
            set temp_height = height - down_acceleration * temp_time * temp_time / 2
            if temp_height < 0 then
                set temp_height = 0
            endif
        endif

        call SaveReal(height_Hash, id, i, temp_height)

        set i = i + 1
    endloop

    // Freezing
    call PauseUnit(u, true)

    call TimerStart(t, Common_SkillKnockfly_TimerInterval, true, function SkillKnockflyFunc_TimerFunc)

    // Clear leaks
    set t = null
    set height_Hash = null

    return time
endfunction

function SkillKnockflyFunc takes unit u, real height returns real
    return SkillKnockflyFunc_Time(u, height, Common_SkillKnockfly_TimerDefaultTime)
endfunction
