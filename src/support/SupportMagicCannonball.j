globals

    hashtable support_MagicCannonball_Hash = InitHashtable()

endglobals

//伤害
function SupportMagicCannonballDamage takes nothing returns nothing
    local timer t
    local integer id
    local location loc
    local location startl
    local unit u
    local effect temp_e

    set t = GetExpiredTimer()
    set id = GetHandleId(t)

    set loc = LoadLocationHandle( support_MagicCannonball_Hash, id, 0)
    set startl = LoadLocationHandle( support_MagicCannonball_Hash, id, 1)
    set u = LoadUnitHandle( support_MagicCannonball_Hash, id, 2)

    set temp_e = AddSpecialEffectLocBJ( loc, "Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl" )
    call UnitDamagePointLoc( u, 0, 180, loc, 100, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )

    call PolledWait( 2.00 )
    call PauseTimer(t)
    call FlushChildHashtable(Common_SkillProjectile_Hash, id)
    call DestroyTimer(t)
    call RemoveLocation(loc)
    call RemoveLocation(startl)
    call DestroyEffect(temp_e)
    set t = null
    set loc = null
    set startl = null
    set u = null
endfunction

//弹道
function SupportMagicCannonball takes unit caster returns nothing
    local timer t
    local integer id
    local rect r
    local location loc0
    local location loc
    local location startl
    local real holding
    local integer i

    set t = CreateTimer()
    set id = GetHandleId(t)

    set loc0 = CameraSetupGetDestPositionLoc(GetCurrentCameraSetup())
    set loc = GetRandomLocInRect(GetRectFromCircleBJ( loc0, 1200))

    set startl = GetUnitLoc(caster)

    call SaveLocationHandle( support_MagicCannonball_Hash, id, 0, loc)
    call SaveLocationHandle( support_MagicCannonball_Hash, id, 1, startl)
    call SaveUnitHandle( support_MagicCannonball_Hash, id, 2, caster)

    set holding = SkillProjectileFunc( startl, loc, "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl",1600 ,980)
    call TimerStart( t, holding, false, function SupportMagicCannonballDamage)

    set t = null
    set loc = null
    set startl = null
endfunction
