library LinkedListModule /* v2.3.1

Easy implementation of linked lists into structs.

***********************************************************************
*
*   module LinkedList
*
*       -   Implement at the top of your struct, must extend array
*
*       thistype next
*       thistype prev
*       boolean  head
*
*       readonly static thistype base
*           -   Precreated head, useful for non-dynamic lists.
*
*       static method allocate takes nothing returns thistype
*       method deallocate takes nothing returns nothing
*
*       static method createNode takes nothing returns thistype
*           -   Allocates a new node pointing towards itself.
*           -   These nodes are considered "heads" therefore it's head
*           -   boolean member is set to true.
*       method insertNode takes thistype toInsert returns thistype
*           -   Inserts the instance before the node.
*       method removeNode takes nothing returns nothing
*           -   Removes the node from the list.
*       method clearNode takes nothing returns nothing
*           -   Deallocates all the instances within the node's range.
*       method flushNode takes nothing returns nothing
*           -   Clears and deallocates the node.
*
*   module LinkedListLite
*       -   Only has the members and the allocation methods.
*       -   To be used with the provided textmacros.
*
*       textmacro LINKED_LIST_HEAD takes node
*           -   Turns the node into a head.
*       textmacro LINKED_LIST_INSERT takes node, toInsert
*           -   Inserts the instance before the node.
*       textmacro LINKED_LIST_REMOVE takes node
*           -   Removes the node from the list.
*       textmacro LINKED_LIST_CLEAR takes node
*           -   Deallocates all the instances within the node's range.
*       textmacro LINKED_LIST_FLUSH takes node
*           -   Clears and deallocates the node.
*       textmacro LINKED_LIST_MERGE takes nodeA, nodeB
*           -   Merges two lists together (Don't merge loose nodes!)
*
**********************************************************************/

    module LinkedListLite

        private static integer instanceCount = 0

        thistype next
        thistype prev
        boolean  head

        static method allocate takes nothing returns thistype
            local thistype this = thistype(0).prev
            if this==0 then
                debug if instanceCount==8190 then
                    debug call BJDebugMsg("[LinkedList] Error: attempted to allocate too many instances.")
                    debug return 0
                debug endif
                set instanceCount = instanceCount+1
                return instanceCount
            endif
            set thistype(0).prev = prev
            return this
        endmethod

        method deallocate takes nothing returns nothing
            set this.prev=thistype(0).prev
            set thistype(0).prev=this
            set this.head=false
        endmethod

    endmodule

    module LinkedList
        implement LinkedListLite

        static method operator base takes nothing returns thistype
            return 8190
        endmethod

        static method createNode takes nothing returns thistype
            local thistype this=allocate()
            //! runtextmacro LINKED_LIST_HEAD("this")
            return this
        endmethod

        method clearNode takes nothing returns nothing
            //! runtextmacro LINKED_LIST_CLEAR("this")
        endmethod

        method flushNode takes nothing returns nothing
            //! runtextmacro LINKED_LIST_FLUSH("this")
        endmethod

        method insertNode takes thistype toInsert returns nothing
            //! runtextmacro LINKED_LIST_INSERT("this","toInsert")
        endmethod

        method removeNode takes nothing returns nothing
            //! runtextmacro LINKED_LIST_REMOVE("this")
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype(8190).next = 8190
            set thistype(8190).prev = 8190
            set thistype(8190).head = true
        endmethod

        static if DEBUG_MODE then
            method print takes nothing returns nothing
                local string s=""
                local thistype exit=this
                loop
                    set s=s+I2S(this)
                    set this = next
                    exitwhen this==exit
                    set s = s+" - "
                endloop
                call BJDebugMsg("[ "+s+" ]")
            endmethod
        endif

    endmodule

    //! textmacro LINKED_LIST_HEAD takes node
        set $node$.next = this
        set $node$.prev = this
        set $node$.head = true
    //! endtextmacro

    //! textmacro LINKED_LIST_CLEAR takes node
        if $node$!=$node$.next then
            set $node$.next.prev = thistype(0).prev
            set thistype(0).prev = $node$.prev
            set $node$.next = $node$
            set $node$.prev = $node$
        endif
    //! endtextmacro

    //! textmacro LINKED_LIST_FLUSH takes node
        set $node$.next.prev = thistype(0).prev
        set thistype(0).prev = $node$
        set $node$.head = false
    //! endtextmacro

    //! textmacro LINKED_LIST_INSERT takes node, toInsert
        set $node$.prev.next = $toInsert$
        set $toInsert$.prev = $node$.prev
        set $node$.prev = $toInsert$
        set $toInsert$.next = $node$
    //! endtextmacro

    //! textmacro LINKED_LIST_REMOVE takes node
        set $node$.prev.next = $node$.next
        set $node$.next.prev = $node$.prev
    //! endtextmacro

    //! textmacro LINKED_LIST_MERGE takes nodeA, nodeB
        set $nodeA$.next.prev = $nodeB$.prev
        set $nodeB$.prev.next = $nodeA$.next
        set $nodeA$.next = $nodeB$
        set $nodeB$.prev = $nodeA$
    //! endtextmacro

endlibrary
