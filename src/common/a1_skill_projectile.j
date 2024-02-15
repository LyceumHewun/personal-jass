globals
    // Start Configuration


    // End Configuration

    hashtable Common_SkillProjectile_Hash = InitHashtable()
endglobals

// 通用抛物线飞行物
// 参数1：施法者
// 参数2：目标位置
// 参数3：飞行物模型
// 参数4：飞行速度
// 参数5：重力
function SkillProjectileFunc takes location source_loc, location target_loc, string projectileModelName, real height, real speed, real gravity returns nothing
    local real distance
    local real angle
    local real time
    local real elapsed_time
    local real dx
    local real dy
    local real z
    local effect e

    // 计算
    set distance = CalcDistance( GetLocationX(source_loc), GetLocationY(source_loc), GetLocationX(target_loc), GetLocationY(target_loc) )
    set angle = Atan2( GetLocationY(target_loc) - GetLocationY(source_loc), GetLocationX(target_loc) - GetLocationX(source_loc) )
    set time = distance / speed
    set dx = speed * Cos(angle)
    set dy = speed * Sin(angle)
    set z = height

    set e = AddSpecialEffect(projectileModelName, GetLocationX(source_loc), GetLocationY(source_loc))
    set elapsed_time = 0

    loop
        exitwhen elapsed_time >= time
        set z = z - gravity
        set elapsed_time = elapsed_time + 0.05
        call BlzSetSpecialEffectPosition(e, GetLocationX(source_loc) + dx * elapsed_time, GetLocationY(source_loc) + dy * elapsed_time, z)
        call TriggerSleepAction(0.2)
    endloop

    // Clear leaks
    call DestroyEffect(e)
    set e = null
endfunction
