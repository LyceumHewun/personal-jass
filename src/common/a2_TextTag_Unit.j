globals

    constant real Common_TextTag_Unit_TimerInterval = 0.02

    hashtable Common_TextTag_Unit_Hash = InitHashtable()
    hashtable Common_TextTag_Unit_Timer_Hash = InitHashtable()

    trigger Common_TextTag_Unit_Trigger
endglobals

function CreateUnitTextTag_TimerFunc takes nothing returns nothing
    local timer t
    local integer id
    local unit u
    local texttag tt
    local real offsetX
    local real offsetY
    local real offsetZ
    local location u_loc
    local real u_flyheight

    set t = GetExpiredTimer()
    set id = GetHandleId( t )
    set u = LoadUnitHandle( Common_TextTag_Unit_Hash, id, 0 )
    set tt = LoadTextTagHandle( Common_TextTag_Unit_Hash, id, 1 )
    set offsetX = LoadReal( Common_TextTag_Unit_Hash, id, 2 )
    set offsetY = LoadReal( Common_TextTag_Unit_Hash, id, 3 )
    set offsetZ = LoadReal( Common_TextTag_Unit_Hash, id, 4 )

    set u_loc = GetUnitLoc(u)
    set u_flyheight = GetUnitFlyHeight(u)

    call SetTextTagPos(tt, GetLocationX(u_loc) + offsetX, GetLocationY(u_loc) + offsetY, offsetZ + u_flyheight)

    // Clear leaks
    call RemoveLocation( u_loc )
    set t = null
    set u = null
    set tt = null
    set u_loc = null
endfunction

function CreateUnitTextTag takes unit u, string text, real size, real red, real green, real blue, real transparency, real offsetX, real offsetY, real offsetZ returns nothing
    local timer t
    local integer id
    local location u_loc
    local location loc
    local texttag tt
    local real u_flyheight

    set t = CreateTimer()
    set id = GetHandleId( t )
    set u_loc = GetUnitLoc(u)
    set u_flyheight = GetUnitFlyHeight(u)
    set loc = OffsetLocation(u_loc, offsetX, offsetY)
    set tt = CreateTextTagLocBJ( text, loc, offsetZ + u_flyheight, size, red, green, blue, transparency )

    call SaveUnitHandle( Common_TextTag_Unit_Hash, id, 0, u )
    call SaveTextTagHandle( Common_TextTag_Unit_Hash, id, 1, tt )
    call SaveReal( Common_TextTag_Unit_Hash, id, 2, offsetX )
    call SaveReal( Common_TextTag_Unit_Hash, id, 3, offsetY )
    call SaveReal( Common_TextTag_Unit_Hash, id, 4, offsetZ )
    call SaveTimerHandle( Common_TextTag_Unit_Timer_Hash, GetHandleId(u), 0, t )

    call TimerStart( t, Common_TextTag_Unit_TimerInterval, true, function CreateUnitTextTag_TimerFunc )

    // Clear leaks
    call RemoveLocation( u_loc )
    call RemoveLocation( loc )
    set t = null
    set u_loc = null
    set loc = null
    set tt = null
endfunction

function RemoveUnitTextTag takes unit u returns nothing
    local integer id
    local timer t
    local integer t_id
    local texttag tt

    set id = GetHandleId(u)
    set t = LoadTimerHandle( Common_TextTag_Unit_Timer_Hash, id, 0 )

    if t == null then
        // if the timer is null, then the texttag is already removed
        return
    endif

    set t_id = GetHandleId(t)

    // if the timer is not null, then the texttag is still active
    set tt = LoadTextTagHandle( Common_TextTag_Unit_Hash, t_id, 1 )

    // Clear leaks
    call FlushChildHashtable( Common_TextTag_Unit_Hash, t_id )
    call FlushChildHashtable( Common_TextTag_Unit_Timer_Hash, id )
    call PauseTimer( t )
    call DestroyTimer( t )
    set t = null
    call DestroyTextTag( tt )
    set tt = null
endfunction

//===========================================================================
// 单位死亡时移除单位的文字标签
function Trig_Common_TextTag_Unit_Death_Actions takes nothing returns nothing
    call RemoveUnitTextTag( GetTriggerUnit() )
endfunction

//===========================================================================
function InitTrig_Common_TextTag_Unit_Death takes nothing returns nothing
    set Common_TextTag_Unit_Trigger = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( Common_TextTag_Unit_Trigger, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddAction( Common_TextTag_Unit_Trigger, function Trig_Common_TextTag_Unit_Death_Actions )
endfunction