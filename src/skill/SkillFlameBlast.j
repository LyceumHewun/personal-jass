// 烈焰冲击
globals

    integer SkillFlameBlast_KnockbackDamage = 150

endglobals

// jass
function SkillFlameBlast takes unit caster returns nothing
    local location array loc_array
    local effect array temp_e_arry
    local integer i

    set i = 0
    loop
        exitwhen i > 3
        // 新点
        set loc_array[i] = GenerateLocByUnit(caster, (i + 1) * 200, GetUnitFacing(caster))
        set i = i + 1
    endloop

    set i = 0
    loop
        exitwhen i > 3
        // 特效
        set temp_e_arry[i] = AddSpecialEffectLocBJ( loc_array[i] , "Abilities\\Spells\\Human\\FlameStrike\\FlameStrike1.mdl" )
        // 伤害
        call UnitDamagePointLoc( caster, 0.3, 400, loc_array[i], SkillFlameBlast_KnockbackDamage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
        set i = i + 1
        call TriggerSleepAction(0.3)
    endloop

    call TriggerSleepAction(2.)

    set i = 0
    loop
        exitwhen i > 3
        call RemoveLocation(loc_array[i])
        set temp_e_arry[i] = null
        call DestroyEffect(temp_e_arry[i])
        set temp_e_arry[i] = null
        set i = i + 1
    endloop
endfunction
