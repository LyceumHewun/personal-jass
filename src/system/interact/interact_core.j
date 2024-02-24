// requires - FileIO.j
globals
    constant string Interact_System_Connect_Flags = "con"
    constant string Interact_System_Flags = "intsys"
    constant string Interact_System_Separator = ";"
    constant string Interact_System_File_Extension = ".pld"
    string Interact_System_RandomName
    timer Interact_System_Timer
    integer Interact_System_Counter = 0
    constant real Interact_System_Delay = 1.
endglobals

function Interact_System takes nothing returns nothing
    local string file_name
    local string msg
    local integer separator_index
    local string command

    set file_name = Interact_System_Flags + "_" + Interact_System_RandomName + "_" + I2S(Interact_System_Counter) + Interact_System_File_Extension
    set msg = File.open( file_name ).readAndClose()

    if StringLength( msg ) > 0 then
        loop
            set separator_index = FindIndex( msg, Interact_System_Separator )
            if separator_index > 0 then
                set command = SubString( msg, 0, separator_index )
                set msg = SubString( msg, separator_index + 1, StringLength( msg ) )
            else
                set command = msg
            endif
            // goto command_manager.j
            call BroadcastCommand( command )
            exitwhen separator_index == -1
        endloop

        set Interact_System_Counter = Interact_System_Counter + 1
    endif
endfunction

function Init_Interact_System takes nothing returns nothing
    set Interact_System_Timer = CreateTimer()
    set Interact_System_RandomName = I2S( GetRandomInt( 0, 1000000 ) )

    // show flags and wait to connect
    call File.open( Interact_System_Flags + "_" + Interact_System_Connect_Flags + Interact_System_File_Extension ).write( Interact_System_RandomName ).close()

    call TimerStart( Interact_System_Timer, Interact_System_Delay, true, function Interact_System )
endfunction
