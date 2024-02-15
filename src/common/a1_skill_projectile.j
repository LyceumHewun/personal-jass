globals
    // Start Configuration

    constant real Common_SkillProjectile_TimerInterval = 0.03

    // End Configuration

    hashtable Common_SkillProjectile_Hash = InitHashtable()
endglobals

function SkillProjectileFunc_TimerFunc takes nothing returns nothing
    local timer t
    local integer id
    local location source_loc
    local location target_loc
    local effect e
    local real gravity
    local real time
    local real speed
    local real angle
    local real height
    local real elapsed_time
    local real temp_height
    local real temp_distance
    local location temp_loc

    set t = GetExpiredTimer()
    set id = GetHandleId(t)

    set source_loc = LoadLocationHandle(Common_SkillProjectile_Hash, id, 0)
    set target_loc = LoadLocationHandle(Common_SkillProjectile_Hash, id, 1)
    set e = LoadEffectHandle(Common_SkillProjectile_Hash, id, 2)
    set gravity = LoadReal(Common_SkillProjectile_Hash, id, 3)
    set time = LoadReal(Common_SkillProjectile_Hash, id, 4)
    set speed = LoadReal(Common_SkillProjectile_Hash, id, 5)
    set angle = LoadReal(Common_SkillProjectile_Hash, id, 6)
    set height = LoadReal(Common_SkillProjectile_Hash, id, 7)
    set elapsed_time = LoadReal(Common_SkillProjectile_Hash, id, 8)

    if elapsed_time < time then
        set elapsed_time = elapsed_time + Common_SkillProjectile_TimerInterval
        call SaveReal(Common_SkillProjectile_Hash, id, 8, elapsed_time)

        set temp_height = height - gravity * elapsed_time * elapsed_time / 2
        if temp_height < 0 then
            set temp_height = 0
        endif
        set temp_distance = speed * elapsed_time
        set temp_loc = GenerateLocByLoc(source_loc, temp_distance, angle)

        call BlzSetSpecialEffectPosition(e, GetLocationX(temp_loc), GetLocationY(temp_loc), temp_height)
    else
        call PauseTimer(t)
        call FlushChildHashtable(Common_SkillProjectile_Hash, id)
        call DestroyTimer(t)
        call DestroyEffect(e)
    endif

    call RemoveLocation(temp_loc)
    set t = null
    set source_loc = null
    set target_loc = null
    set e = null
    set temp_loc = null
endfunction

// 通用抛物线飞行物
// 参数1：起始位置
// 参数2：目标位置
// 参数3：飞行物模型
// 参数4：重力
// 返回时间
function SkillProjectileFunc takes location source_loc, location target_loc, string projectileModelName, real height, real gravity returns real
    local timer t
    local integer id
    local real distance
    local real angle
    local real time
    local real speed
    local real elapsed_time
    local real dx
    local real dy
    local effect e

    set t = CreateTimer()
    set id = GetHandleId(t)

    // 计算
    set distance = CalcDistanceByLoc( source_loc, target_loc )
    set angle = CalcAngleByLoc( source_loc, target_loc )
    set time = SquareRoot( 2 * height / gravity )
    set speed = distance / time

    set e = AddSpecialEffect(projectileModelName, GetLocationX(source_loc), GetLocationY(source_loc))
    call BlzSetSpecialEffectPosition(e, GetLocationX(source_loc), GetLocationY(source_loc), height)
    set elapsed_time = 0

    call SaveLocationHandle(Common_SkillProjectile_Hash, id, 0, source_loc)
    call SaveLocationHandle(Common_SkillProjectile_Hash, id, 1, target_loc)
    call SaveEffectHandle(Common_SkillProjectile_Hash, id, 2, e)
    call SaveReal(Common_SkillProjectile_Hash, id, 3, gravity)
    call SaveReal(Common_SkillProjectile_Hash, id, 4, time)
    call SaveReal(Common_SkillProjectile_Hash, id, 5, speed)
    call SaveReal(Common_SkillProjectile_Hash, id, 6, angle)
    call SaveReal(Common_SkillProjectile_Hash, id, 7, height)
    call SaveReal(Common_SkillProjectile_Hash, id, 8, elapsed_time)

    call TimerStart(t, Common_SkillProjectile_TimerInterval, true, function SkillProjectileFunc_TimerFunc)

    // Clear leaks
    set e = null
    set t = null

    return time
endfunction
