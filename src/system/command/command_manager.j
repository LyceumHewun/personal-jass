// 用于广播command的系统
// 用法：
// 1. 在需要监听command的地方调用AddCommandListener，传入一个函数
// 2. 函数中使用GetCommand获取当前command
globals
    string Command_System_Current_Command = ""
    trigger Command_System_Manager_Trigger = CreateTrigger()
endglobals

//===========================================================================
// 广播command
function AddCommandListener takes code func returns nothing
    call TriggerAddAction(Command_System_Manager_Trigger, func)
endfunction

function BroadcastCommand takes string command returns nothing
    set Command_System_Current_Command = command
    call TriggerExecute(Command_System_Manager_Trigger)
endfunction

function GetCommand takes nothing returns string
    return Command_System_Current_Command
endfunction
