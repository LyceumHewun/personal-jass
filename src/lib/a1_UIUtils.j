// 隐藏全部UI
// call UIUtils.FullScreenMode(true, false)
library UIUtils

    globals
        // Screen resolution used to design UI
        public constant real SCREEN_WIDTH  = 1360.0
        public constant real SCREEN_HEIGHT = 768.0

        // If true, all frames will be automatically adjusted on resolution change
        private constant boolean AUTOMATIC_ADJUSTMENT = true
        private constant real RESOLUTION_CHECK_INTERVAL = 0.1

        // If true, component's properties will be retained when it changes parent
        private constant boolean PERSISTENT_CHILD_PROPERTIES = true
    endglobals

    globals
        private real WidthFactor  = 1.0
        private real HeightFactor = 1.0
    endglobals

    private struct AllComponents extends array

        implement LinkedList

        static method add takes thistype this returns nothing
            call base.insertNode(this)
        endmethod

        static method remove takes thistype this returns nothing
            call removeNode()
        endmethod

    endstruct

    private module INIT
        private static method onInit takes nothing returns nothing

            local integer i

            call RefreshResolution()

            set FrameGameUI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            set FrameWorld         = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
            set FrameHeroBar    = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BAR, 0)
            set FramePortrait    = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
            set FrameMinimap    = BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP, 0)
            set FrameTooltip    = BlzGetOriginFrame(ORIGIN_FRAME_TOOLTIP, 0)
            set FrameUberTooltip = BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0)
            set FrameChatMsg    = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0)
            set FrameUnitMsg    = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0)
            set FrameTopMsg        = BlzGetOriginFrame(ORIGIN_FRAME_TOP_MSG, 0)

            set i = 0
            loop
                exitwhen i > 11
                set FrameHeroButton[i]       = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
                set FrameHeroHPBar[i]       = BlzGetOriginFrame(ORIGIN_FRAME_HERO_HP_BAR, i)
                set FrameHeroMPBar[i]       = BlzGetOriginFrame(ORIGIN_FRAME_HERO_MANA_BAR, i)
                set FrameHeroIndicator[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, i)
                set FrameItemButton[i]       = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i)
                set FrameCommandButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
                set FrameSystemButton[i]  = BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON, i)
                set FrameMinimapButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP_BUTTON, i)
                set i = i + 1
            endloop

            set FrameConsoleUI = BlzGetFrameByName("ConsoleUI", 0)

            static if AUTOMATIC_ADJUSTMENT then
                call TimerStart(CreateTimer(), RESOLUTION_CHECK_INTERVAL, true, function thistype.CheckResolution)
            endif

        endmethod
    endmodule

    struct UIUtils extends array

        readonly static integer ResolutionWidth  = 0
        readonly static integer ResolutionHeight = 0
        readonly static integer AspectWidth  = 0
        readonly static integer AspectHeight = 0

        readonly static boolean IsFullScreen = false
        readonly static boolean CommandButtonsVisible = true

        private static real RefAspectWorld  = 5.0
        private static real RefAspectWidth  = 4.0
        private static real RefAspectHeight = 3.0
        private static real RefExtraWidth   = 0.0

        readonly static real MinFrameX = 0.0
        readonly static real MaxFrameX = 0.0
        readonly static real DPIMinX = 0.0
        readonly static real DPIMaxX = 0.0
        readonly static real DPIMinY = 0.0
        readonly static real DPIMaxY = RefAspectHeight/RefAspectWorld
        private  static real PxToDPI = 0.0

        readonly static framehandle         FrameGameUI
        readonly static framehandle         FrameWorld
        readonly static framehandle         FrameHeroBar
        readonly static framehandle array     FrameHeroButton
        readonly static framehandle array     FrameHeroHPBar
        readonly static framehandle array     FrameHeroMPBar
        readonly static framehandle array     FrameHeroIndicator
        readonly static framehandle array     FrameItemButton
        readonly static framehandle array     FrameCommandButton
        readonly static framehandle array     FrameSystemButton
        readonly static framehandle         FramePortrait
        readonly static framehandle         FrameMinimap
        readonly static framehandle array     FrameMinimapButton
        readonly static framehandle         FrameTooltip
        readonly static framehandle         FrameUberTooltip
        readonly static framehandle         FrameChatMsg
        readonly static framehandle         FrameUnitMsg
        readonly static framehandle         FrameTopMsg

        readonly static framehandle         FrameConsoleUI

        private static method CalcAspectRatio takes real w, real h, real aw returns integer
            return R2I(aw*h/w+0.5)
        endmethod

        static method XCoordToDPI takes real x returns real
            return x*PxToDPI/RefAspectWidth+DPIMinX
        endmethod

        static method YCoordToDPI takes real y returns real
            return y*PxToDPI/RefAspectWidth
        endmethod

        static method SizeToDPI takes real r returns real
            return r*PxToDPI/RefAspectWidth
        endmethod

        static method DPIToXCoord takes real dpi returns real
            return (dpi-DPIMinX)*RefAspectWidth/PxToDPI
        endmethod

        static method DPIToYCoord takes real dpi returns real
            return dpi*RefAspectWidth/PxToDPI
        endmethod

        static method DPIToSize takes real dpi returns real
            return dpi*RefAspectWidth/PxToDPI
        endmethod

        static method RefreshResolution takes nothing returns nothing

            local AllComponents node

            set ResolutionWidth  = BlzGetLocalClientWidth()
            set ResolutionHeight = BlzGetLocalClientHeight()
            set WidthFactor  = ResolutionWidth/SCREEN_WIDTH
            set HeightFactor = ResolutionHeight/SCREEN_HEIGHT
            if CalcAspectRatio(ResolutionWidth, ResolutionHeight, 4) == 3 then
                set PxToDPI = RefAspectWidth/(ResolutionWidth/1024.0*1280.0)
                set AspectWidth   = 4
                set AspectHeight  = 3
                set RefExtraWidth = 0.0
            elseif CalcAspectRatio(ResolutionWidth, ResolutionHeight, 16) == 9 then
                set PxToDPI = RefAspectWidth/(ResolutionWidth/1360.0*1280.0)
                set AspectWidth   = 16
                set AspectHeight  = 9
                set RefExtraWidth = 0.525
            elseif CalcAspectRatio(ResolutionWidth, ResolutionHeight, 16) == 10 then
                set PxToDPI = RefAspectWidth/(ResolutionWidth/1280.0*1280.0)
                set AspectWidth   = 16
                set AspectHeight  = 10
                set RefExtraWidth = 0.4
            endif
            set MinFrameX = RefExtraWidth*320.0
            set MaxFrameX = ResolutionWidth-MinFrameX
            set DPIMinX   = -(RefExtraWidth/RefAspectWidth)
            set DPIMaxX   = RefAspectWidth/RefAspectWorld-DPIMinX

            set node = AllComponents.base.next
            loop
                exitwhen node.head or node == 0
                if UIComponent(node).parent == UIComponent.Null then
                    set UIComponent(node).localScale = UIComponent(node).localScale
                endif
                set node = node.next
            endloop

        endmethod

        static method FullScreenMode takes boolean state, boolean commandBtn returns nothing

            local integer i
            local real x
            local real y

            local real yo
            local real xo1
            local real xo2

            set IsFullScreen = state
            set CommandButtonsVisible = commandBtn
            call BlzHideOriginFrames(state)
            call BlzFrameClearAllPoints(FrameWorld)
            call BlzFrameClearAllPoints(FrameConsoleUI)
            if state then
                // Fit viewport to screen
                call BlzFrameSetAllPoints(FrameWorld, FrameGameUI)
                call BlzFrameSetAbsPoint(FrameConsoleUI, FRAMEPOINT_RIGHT, XCoordToDPI(-999.0), YCoordToDPI(-999.0))
                // Retain in-game message frame position
                set yo  = SizeToDPI(300.0)
                set xo1 = SizeToDPI(65.0)
                set xo2 = SizeToDPI(710.0)
                call BlzFrameClearAllPoints(FrameUnitMsg)
                call BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_TOPLEFT, xo1, 0.5)
                call BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_TOPRIGHT, xo2, 0.5)
                call BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_BOTTOMLEFT, xo1, yo)
                call BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_BOTTOMRIGHT, xo2, yo)
            else
                // Restore viewport
                call BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_TOPLEFT, 0.0, 0.58)
                call BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_TOPRIGHT, 0.8, 0.58)
                call BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_BOTTOMLEFT, 0.0, 0.13)
                  call BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_BOTTOMRIGHT, 0.8, 0.13)
                call BlzFrameSetAllPoints(FrameConsoleUI, FrameGameUI)
            endif

            if commandBtn or not state then
                set x = 959.0
                set y = 168.0
            endif
            set i = 0
            loop
                exitwhen FrameCommandButton[i] == null
                call BlzFrameClearAllPoints(FrameCommandButton[i])
                if commandBtn or not state then
                    // Restore command buttons position
                    call BlzFrameSetAbsPoint(FrameCommandButton[i], FRAMEPOINT_TOPLEFT, XCoordToDPI(x), YCoordToDPI(y))
                    if i == 3 or i == 7 then
                        set x = 959.0
                        set y = y - DPIToSize(BlzFrameGetHeight(FrameCommandButton[i])) - 6.0
                    else
                        set x = x + DPIToSize(BlzFrameGetWidth (FrameCommandButton[i])) + 7.0
                    endif
                else
                    // Get command buttons out of screen
                    call BlzFrameSetAbsPoint(FrameCommandButton[i], FRAMEPOINT_RIGHT, XCoordToDPI(-999.0), YCoordToDPI(-999.0))
                endif
                set i = i + 1
            endloop

        endmethod

        static method CalcFrameSpacing takes UIComponent from, UIComponent to, boolean topdown returns real

            local real size1
            local real size2
            local framepointtype anchor1 = from.anchorPoint
            local framepointtype anchor2 = to.anchorPoint

            if topdown then
                set size1 = from.height
                set size2 = to.height
                if anchor1 == FRAMEPOINT_TOPLEFT or anchor1 == FRAMEPOINT_TOP or anchor1 == FRAMEPOINT_TOPRIGHT then
                    set size1 = 0.0
                elseif anchor1 == FRAMEPOINT_LEFT or anchor1 == FRAMEPOINT_CENTER or anchor1 == FRAMEPOINT_RIGHT then
                    set size1 = size1*0.5
                endif
                if anchor2 == FRAMEPOINT_BOTTOMLEFT or anchor2 == FRAMEPOINT_BOTTOM or anchor2 == FRAMEPOINT_BOTTOMRIGHT then
                    set size2 = 0.0
                elseif anchor2 == FRAMEPOINT_LEFT or anchor2 == FRAMEPOINT_CENTER or anchor2 == FRAMEPOINT_RIGHT then
                    set size2 = size2*0.5
                endif
            else
                set size1 = from.width
                set size2 = to.width
                if anchor1 == FRAMEPOINT_TOPRIGHT or anchor1 == FRAMEPOINT_RIGHT or anchor1 == FRAMEPOINT_BOTTOMRIGHT then
                    set size1 = 0.0
                elseif anchor1 == FRAMEPOINT_TOP or anchor1 == FRAMEPOINT_CENTER or anchor1 == FRAMEPOINT_BOTTOM then
                    set size1 = size1*0.5
                endif
                if anchor2 == FRAMEPOINT_TOPLEFT or anchor2 == FRAMEPOINT_LEFT or anchor2 == FRAMEPOINT_BOTTOMLEFT then
                    set size2 = 0.0
                elseif anchor2 == FRAMEPOINT_TOP or anchor2 == FRAMEPOINT_CENTER or anchor2 == FRAMEPOINT_BOTTOM then
                    set size2 = size2*0.5
                endif
            endif

            return size1+size2
        endmethod

        private static method CheckResolution takes nothing returns nothing
            if BlzGetLocalClientWidth() != ResolutionWidth or BlzGetLocalClientHeight() != ResolutionHeight then
                call RefreshResolution()
            endif
        endmethod

        implement INIT

    endstruct

    struct UIComponent extends array

        implement LinkedList

        string name

        readonly framehandle frame
        private  framehandle textFrameH
        private  framehandle modelFrameH
        private  framehandle mainTextureH
        private  framehandle disabledTextureH
        private  framehandle pushedTextureH
        private  framehandle highlightTextureH
        private  framehandle backgroundTextureH
        private  framehandle borderTextureH
        private  framepointtype anchor

        readonly string frameType
        readonly real localX
        readonly real localY
        readonly real screenX
        readonly real screenY
        readonly real minValue
        readonly real maxValue
        readonly integer context

        private thistype par
        private thistype child
        private thistype tips
        private integer lvl
        private real localSize
        private real localWidth
        private real localHeight
        private real step
        private string mainTextureFile
        private string disabledTextureFile
        private string pushedTextureFile
        private string highlightTextureFile
        private string backgroundTextureFile
        private string borderTextureFile
        private string modelFile
        private trigger anyEventTrigg

        readonly static thistype Null = 0
        readonly static thistype EnumChild = 0
        readonly static thistype TriggerComponent = 0

        readonly static string TYPE_TEXT            = "UIUtilsText"
        readonly static string TYPE_SIMPLE_TEXT        = "UIUtilsSimpleText"
        readonly static string TYPE_TEXTURE            = "UIUtilsTexture"
        readonly static string TYPE_SIMPLE_TEXTURE     = "UIUtilsSimpleTexture"
        readonly static string TYPE_BUTTON             = "UIUtilsButton"
        readonly static string TYPE_BAR             = "UIUtilsBar"
        readonly static string TYPE_H_SLIDER        = "UIUtilsSliderH"
        readonly static string TYPE_V_SLIDER        = "UIUtilsSliderV"

        private static trigger ExecTrigg = CreateTrigger()
        private static gamecache GC
        private static hashtable HT

        private static method IsSimple takes string frameType, boolean isSimple returns boolean
            return frameType == TYPE_SIMPLE_TEXT or frameType == TYPE_SIMPLE_TEXTURE or frameType == TYPE_BAR or isSimple and not (frameType == TYPE_TEXT or frameType == TYPE_TEXTURE or frameType == TYPE_BUTTON or frameType == TYPE_H_SLIDER or frameType == TYPE_V_SLIDER)
        endmethod

        private static method GetTriggerComponent takes nothing returns boolean
            set TriggerComponent = LoadInteger(HT, GetHandleId(BlzGetTriggerFrame()), 0)
            return false
        endmethod

        method operator onAnyEvent= takes code func returns triggercondition

            local integer i

            if .anyEventTrigg == null then
                set .anyEventTrigg = CreateTrigger()
                set i = 1
                loop
                    exitwhen i > 16
                    call BlzTriggerRegisterFrameEvent(.anyEventTrigg, .frame, ConvertFrameEventType(i))
                    set i = i + 1
                endloop
                call TriggerAddCondition(.anyEventTrigg, Condition(function thistype.GetTriggerComponent))
            endif

            return TriggerAddCondition(.anyEventTrigg, Condition(func))
        endmethod

        method operator anchorPoint= takes framepointtype point returns nothing
            set .anchor = point
              call BlzFrameClearAllPoints(.frame)
            call move(.localX, .localY)
        endmethod

        method operator anchorPoint takes nothing returns framepointtype
            return .anchor
        endmethod

        method operator parent= takes thistype comp returns nothing
            if comp != Null then
                if .par != comp then
                    call .removeNode()
                endif
                call comp.child.insertNode(this)
            endif

            static if not PERSISTENT_CHILD_PROPERTIES then
                if .par != Null then
                    set .localScale = .localScale*.par.localScale
                endif
                set .localX = .screenX - comp.screenX
                set .localY = .screenY - comp.screenY
            endif

            set .par = comp
            set .par.localScale = .par.localScale

        endmethod

        method operator parent takes nothing returns thistype
            return .par
        endmethod

        method operator text= takes string str returns nothing
            call BlzFrameSetText(.textFrameH, str)
        endmethod

        method operator text takes nothing returns string
            return BlzFrameGetText(.textFrameH)
        endmethod

        method operator maxLength= takes integer len returns nothing
            call BlzFrameSetTextSizeLimit(.textFrameH, len)
        endmethod

        method operator maxLength takes nothing returns integer
            return BlzFrameGetTextSizeLimit(.textFrameH)
        endmethod

        method operator textColor= takes integer color returns nothing
            call BlzFrameSetTextColor(.textFrameH, color)
        endmethod

        method operator texture= takes string filePath returns nothing
            set .mainTextureFile = filePath
            call BlzFrameSetTexture(.mainTextureH, filePath, 0, true)
            if StringLength(.disabledTextureFile) == 0 then
                set .disabledTexture = filePath
            endif
            if StringLength(.pushedTextureFile) == 0 then
                set .pushedTexture = filePath
            endif
        endmethod

        method operator texture takes nothing returns string
            return .mainTextureFile
        endmethod

        method operator disabledTexture= takes string filePath returns nothing
            set .disabledTextureFile = filePath
            call BlzFrameSetTexture(.disabledTextureH, filePath, 0, true)
        endmethod

        method operator disabledTexture takes nothing returns string
            return .disabledTextureFile
        endmethod

        method operator highlightTexture= takes string filePath returns nothing
            set .highlightTextureFile = filePath
            call BlzFrameSetTexture(.highlightTextureH, filePath, 0, true)
        endmethod

        method operator highlightTexture takes nothing returns string
            return .highlightTextureFile
        endmethod

        method operator pushedTexture= takes string filePath returns nothing
            set .pushedTextureFile = filePath
            call BlzFrameSetTexture(.pushedTextureH, filePath, 0, true)
        endmethod

        method operator pushedTexture takes nothing returns string
            return .pushedTextureFile
        endmethod

        method operator backgroundTexture= takes string filePath returns nothing
            set .backgroundTextureFile = filePath
            call BlzFrameSetTexture(.backgroundTextureH, filePath, 0, true)
        endmethod

        method operator backgroundTexture takes nothing returns string
            return .backgroundTextureFile
        endmethod

        method operator borderTexture= takes string filePath returns nothing
            set .borderTextureFile = filePath
            call BlzFrameSetTexture(.borderTextureH, filePath, 0, true)
        endmethod

        method operator borderTexture takes nothing returns string
            return .borderTextureFile
        endmethod

        method operator model= takes string filePath returns nothing
            set .modelFile = filePath
            call BlzFrameSetModel(.modelFrameH, filePath, 0)
        endmethod

        method operator model takes nothing returns string
            return .modelFile
        endmethod

        method operator vertexColor= takes integer color returns nothing
            call BlzFrameSetVertexColor(.modelFrameH, color)
        endmethod

        method operator value= takes real r returns nothing
            call BlzFrameSetValue(.frame, r)
        endmethod

        method operator value takes nothing returns real
            return BlzFrameGetValue(.frame)
        endmethod

        method operator stepSize= takes real r returns nothing
            set .step = RMaxBJ(r, 0.0001)
            call BlzFrameSetStepSize(.frame, .step)
        endmethod

        method operator stepSize takes nothing returns real
            return .step
        endmethod

        method operator localScale= takes real r returns nothing

            local thistype node = .child.next

            set .localSize = RMaxBJ(r, 0.0001)
            call setSize(.width, .height)
            call move(.localX, .localY)

            loop
                exitwhen node.head or node == 0
                set node.localScale = node.localScale
                set node = node.next
            endloop

        endmethod

        method operator localScale takes nothing returns real
            return .localSize
        endmethod

        method operator scale takes nothing returns real
            if .parent == Null then
                return .localScale
            else
                return .localScale * .parent.scale
            endif
        endmethod

        method operator opacity= takes integer amount returns nothing
            call BlzFrameSetAlpha(.frame, amount)
        endmethod

        method operator opacity takes nothing returns integer
            return BlzFrameGetAlpha(.frame)
        endmethod

        method operator level= takes integer level returns nothing
            set .lvl = level
            call BlzFrameSetLevel(.frame, level)
        endmethod

        method operator level takes nothing returns integer
            return .lvl
        endmethod

        method operator tooltips= takes thistype comp returns nothing
            set .tips = comp
            call BlzFrameSetTooltip(.frame, comp.frame)
        endmethod

        method operator tooltips takes nothing returns thistype
            return .tips
        endmethod

        method operator visible= takes boolean state returns nothing
            call BlzFrameSetVisible(.frame, state)
        endmethod

        method operator visible takes nothing returns boolean
            return BlzFrameIsVisible(.frame)
        endmethod

        method operator enabled= takes boolean state returns nothing
            call BlzFrameSetEnable(.frame, state)
        endmethod

        method operator enabled takes nothing returns boolean
            return BlzFrameGetEnable(.frame)
        endmethod

        method operator width takes nothing returns real
            return .localWidth
        endmethod

        method operator height takes nothing returns real
            return .localHeight
        endmethod

        method setSize takes real width, real height returns nothing
            set .localWidth  = RMaxBJ(width,  0)
            set .localHeight = RMaxBJ(height, 0)
            call BlzFrameSetSize(frame, UIUtils.SizeToDPI(.localWidth*.scale*WidthFactor), UIUtils.SizeToDPI(.localHeight*.scale*WidthFactor))
        endmethod

        method move takes real x, real y returns nothing

            local thistype node = .child.next

            set .localX = x
            set .localY = y
            if .parent == Null then
                set .screenX = x
                set .screenY = y
            else
                set .screenX = .parent.screenX+.localX*.parent.scale
                set .screenY = .parent.screenY+.localY*.parent.scale
            endif
            call BlzFrameSetAbsPoint(.frame, .anchor, UIUtils.XCoordToDPI(.screenX*WidthFactor), UIUtils.YCoordToDPI(.screenY*HeightFactor))

            loop
                exitwhen node.head or node == 0
                call node.move(node.localX, node.localY)
                set node = node.next
            endloop

        endmethod

        method moveEx takes real x, real y returns nothing
            if .parent == Null then
                call move(x, y)
            else
                call move((x-.parent.screenX)/.parent.localScale, (y-.parent.screenY)/.parent.localScale)
            endif
        endmethod

        method relate takes thistype relative, real x, real y returns nothing
            if .parent == Null then
                call move(relative.screenX+x, relative.screenY+y)
            else
                call moveEx(relative.screenX+x, relative.screenY+y)
            endif
        endmethod

        method click takes nothing returns nothing
            call BlzFrameClick(.frame)
        endmethod

        method cageMouse takes boolean state returns nothing
            call BlzFrameCageMouse(.frame, state)
        endmethod

        method setFocus takes boolean state returns nothing
            call BlzFrameSetFocus(.frame, state)
        endmethod

        method setSpriteAnimate takes integer primaryProp, integer flags returns nothing
            call BlzFrameSetSpriteAnimate(.frame, primaryProp, flags)
        endmethod

        method setMinMaxValue takes real min, real max returns nothing
            set .minValue = min
            set .maxValue = max
            call BlzFrameSetMinMaxValue(.frame, min, max)
        endmethod

        method setFont takes string fontPath, real height, integer flags returns nothing
            call BlzFrameSetFont(.textFrameH, fontPath, height, flags)
        endmethod

        method setTextAlignment takes textaligntype vertical, textaligntype horizontal returns nothing
            call BlzFrameSetTextAlignment(.textFrameH, vertical, horizontal)
        endmethod

        method getSubFrame takes string name returns framehandle
            return BlzGetFrameByName(name, .context)
        endmethod

        method forChilds takes code func returns nothing

            local thistype node = .child.next

            call TriggerAddAction(ExecTrigg, func)
            loop
                exitwhen node.head or node == 0
                set EnumChild = node
                call TriggerExecute(ExecTrigg)
                set node = node.next
            endloop
            call TriggerClearActions(ExecTrigg)

        endmethod

        method destroy takes nothing returns nothing

            local thistype node = .child.next

            loop
                exitwhen node.head or node == 0
                call node.destroy()
                set node = node.next
            endloop

            call BlzDestroyFrame(.frame)
            call DestroyTrigger(.anyEventTrigg)
            call StoreInteger(GC, name, I2S(.context), GetStoredInteger(GC, name, "0"))
            call StoreInteger(GC, name, "0", .context)
            call AllComponents.remove(this)
            call .child.flushNode()
            call removeNode()
            call deallocate()
            set .anyEventTrigg         = null
            set .mainTextureH        = null
            set .disabledTextureH     = null
            set .highlightTextureH     = null
            set .pushedTextureH     = null
            set .backgroundTextureH = null
            set .borderTextureH     = null
            set .textFrameH         = null
            set .modelFrameH         = null
            set .frame                 = null
            set .name                  = null
            set .frameType             = null
            set .child                 = 0

        endmethod

        static method create takes boolean isSimple, string frameType, thistype par, real x, real y, integer level returns thistype

            local thistype this = allocate()
            local integer tempInt

            set .context = GetStoredInteger(GC, frameType, "0")
            set tempInt  = GetStoredInteger(GC, frameType, I2S(context))
            if tempInt == 0 then
                call StoreInteger(GC, frameType, "0", context+1)
            else
                call StoreInteger(GC, frameType, "0", tempInt)
            endif

            if IsSimple(frameType, isSimple) then
                set .frame             = BlzCreateSimpleFrame(frameType, UIUtils.FrameGameUI, .context)
            else
                set .frame             = BlzCreateFrame(frameType, UIUtils.FrameGameUI, 0, .context)
            endif
            set .mainTextureH        = getSubFrame(frameType + "Texture")
            set .disabledTextureH     = getSubFrame(frameType + "Disabled")
            set .highlightTextureH     = getSubFrame(frameType + "Highlight")
            set .pushedTextureH     = getSubFrame(frameType + "Pushed")
            set .backgroundTextureH = getSubFrame(frameType + "Background")
            set .borderTextureH     = getSubFrame(frameType + "Border")
            set .textFrameH         = getSubFrame(frameType + "Text")
            set .modelFrameH         = getSubFrame(frameType + "Model")
            if .mainTextureH == null then
                set .mainTextureH     = frame
            endif

            set .localWidth         = UIUtils.DPIToSize(BlzFrameGetWidth(.frame))
            set .localHeight        = UIUtils.DPIToSize(BlzFrameGetHeight(.frame))
            set .anchor             = FRAMEPOINT_BOTTOMLEFT
            set .child                 = createNode()
            set .frameType            = frameType
            set .name                 = frameType + I2S(.context)
            set .parent             = par
            set .level                 = level
            set .value                 = 0.0
            set .localScale         = 1.0

            set .mainTextureFile        = ""
            set .disabledTextureFile    = ""
            set .pushedTextureFile        = ""
            set .highlightTextureFile    = ""
            set .backgroundTextureFile    = ""
            set .borderTextureFile        = ""
            set .modelFile                = ""

            call move(x, y)
            call setMinMaxValue(0.0, 1.0)
            call AllComponents.add(this)
            call SaveInteger(HT, GetHandleId(.frame), 0, this)

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set HT = InitHashtable()
            set GC = InitGameCache("UIUtils.w3v")
              call BlzLoadTOCFile("war3mapimported\\UIUtils.toc")
        endmethod

    endstruct

endlibrary