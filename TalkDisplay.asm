
.weak
  WARNINGS :?= "None"
.endweak

GUARD_ZQOL_TALK_DISPLAY :?= false
.if (GUARD_ZQOL_TALK_DISPLAY && (WARNINGS == "Strict"))

  .warn "File included more than once."

.elsif (!GUARD_ZQOL_TALK_DISPLAY)
  GUARD_ZQOL_TALK_DISPLAY := true

  .include "TOOLS/VoltEdge.h"

  ; Definitions

    .weak

      rlPushToOAMBuffer                             :?= address($808881)
      rlDMAByStruct                                 :?= address($80AE2E)
      rlGetPixelDistanceFromScreenEdge              :?= address($81B544)
      rlProcEngineCreateProc                        :?= address($829BF1)
      rsUnknown838764                               :?= address($838764)
      rlGetMapTileIndexByCoords                     :?= address($838E76)
      rlCopyCharacterDataToBufferByDeploymentNumber :?= address($83901C)
      rlRunRoutineForAllUnits                       :?= address($839861)
      rlClearJoyNewInputs                           :?= address($839B7F)
      rlUnknown83CD2B                               :?= address($83CD2B)
      procBMenu                                     :?= address($8A82D7)
      rlCheckAvailableTalks                         :?= address($8C9C59)
      g4bppExclamationBubble                        :?= address($A0E060)

      ; Slightly hacky workaround for
      ; defining a redefinable local label.

      rlUpdateBurstWindow .namespace

        _ClearWindow :?= address($84A125)

      .endn

    .endweak

  ; Fixed location inclusions

    * := $0186A4
    .logical mapped($0186A4)

      rsDrawMovementRangeOrBMenu ; 83/86A4

        .al
        .autsiz
        .databank `aPlayerVisibleUnitMap

        jsl rlClearJoyNewInputs

        lda #-1
        sta wTerrainWindowTerrain

        jsl rlUpdateBurstWindow._ClearWindow

        ; If the player can't see
        ; the unit at that tile, draw
        ; B menu

        ldx wCursorTileIndex,b
        lda aPlayerVisibleUnitMap,x
        and #$00FF
        beq _BMenu

          ; Otherwise get unit data
          ; and check if unit is
          ; selectable

          sta wR0

          lda #<>aSelectedCharacterBuffer
          sta wR1

          jsl rlCopyCharacterDataToBufferByDeploymentNumber

          lda aSelectedCharacterBuffer.UnitState,b
          and #UnitStateGrayed
          bne _BMenu

            ; Lastly, check if unit is asleep.

            lda aSelectedCharacterBuffer.Status,b
            and #$00FF
            cmp #StatusSleep
            beq _BMenu

              ; Draw unit's range

              jsr rsUnknown838764

              ; Originally recopied menu tiles,
              ; replaced with talk display hook.

              ; jsl rlUnknown83CD2B

              jsl rlTalkDisplay

              rts

        _BMenu

        ; Seems like some redundant actions
        ; but it's possible that some other
        ; routine enters here.

        jsl rlClearJoyNewInputs

        lda #-1
        sta wTerrainWindowTerrain

        jsl rlUpdateBurstWindow._ClearWindow

        lda #0
        sta wUnknown000E25,b

        phx

        lda #(`procBMenu)<<8
        sta lR44+1
        lda #<>procBMenu
        sta lR44
        jsl rlProcEngineCreateProc

        plx

        rts

        .checkfit $848708

        .databank 0

    .here

  ; Freespace inclusions

    .section TalkDisplaySection

      rlTalkDisplay

        .al
        .xl
        .autsiz
        .databank `aPlayerVisibleUnitMap

        ; Holdover from rsDrawMovementRangeOrBMenu

        jsl rlUnknown83CD2B

        ; Use character as an input
        ; into the talk partner search loop.

        lda aSelectedCharacterBuffer.Character,b
        sta wR2

        ; Search through all units for
        ; talk partners.

        lda #(`rlTalkDisplayFilter)<<8
        sta lR25+1
        lda #<>rlTalkDisplayFilter
        sta lR25

        jsl rlRunRoutineForAllUnits

        rtl

        .databank 0

    .send TalkDisplaySection

    .section TalkDisplayFilterSection

      rlTalkDisplayFilter

        .al
        .xl
        .autsiz
        .databank ?

        ; Inputs:
        ; wR2: Talk initiator
        ; aTargetingCharacterBuffer: potential target

        ; Outputs:
        ; procTalkDisplay or nothing

        ; Check if unit is alive/deployed/visible.

        lda aTargetingCharacterBuffer.UnitState,b
        bit #(UnitStateDead | UnitStateUnknown1 | UnitStateActing | UnitStateInvisible | UnitStateCaptured)
        bne _End

          ; Check if unit is within vision range.

          lda aTargetingCharacterBuffer.X,b
          and #$00FF
          sta wR0

          lda aTargetingCharacterBuffer.Y,b
          and #$00FF
          sta wR1

          jsl rlGetMapTileIndexByCoords

          tax
          lda aPlayerVisibleUnitMap,x
          and #$00FF
          beq _End

            ; Check for talks.

            lda aTargetingCharacterBuffer.Character,b
            sta wR1

            lda wR2
            sta wR0

            jsl rlCheckAvailableTalks
            bcc _End

              ; Talk available, create bubble proc

              lda aTargetingCharacterBuffer.X,b
              and #$00FF
              sta aProcSystem.wInput0,b

              lda aTargetingCharacterBuffer.Y,b
              and #$00FF
              sta aProcSystem.wInput1,b

              lda #(`procTalkDisplay)<<8
              sta lR44+1
              lda #<>procTalkDisplay
              sta lR44

              jsl rlProcEngineCreateProc

        _End
        rtl

        .databank 0

    .send TalkDisplayFilterSection

    .section ProcTalkDisplaySection

      procTalkDisplay .dstruct structProcInfo, "TK", rlProcTalkDisplayInit, rlProcTalkDisplayOnCycle, None

      rlProcTalkDisplayInit

        .autsiz
        .databank ?

        ; Copy coordinates into proc body.

        lda aProcSystem.wInput0,b
        sta aProcSystem.aBody0,b,x

        lda aProcSystem.wInput1,b
        sta aProcSystem.aBody1,b,x

        rtl

        .databank 0

      rlProcTalkDisplayOnCycle

        .al
        .xl
        .autsiz
        .databank ?

        ; Wait until we're free to DMA

        lda bDMAArrayFlag,b
        ora bDecompressionArrayFlag,b
        bne +

          jsl rlDMAByStruct

          _UpperTiles .dstruct structDMAToVRAM, g4bppExclamationBubble, (size(Tile4bpp) * 2), VMAIN_Setting(true), $2880

          jsl rlDMAByStruct

          _LowerTiles .dstruct structDMAToVRAM, g4bppExclamationBubble+$200, (size(Tile4bpp) * 2), VMAIN_Setting(true), $2A80

          ldx aProcSystem.wOffset,b

          lda #<>rlProcTalkDisplayOnCycle2
          sta aProcSystem.aHeaderOnCycle,b,x

        +

        lda #1
        sta aProcSystem.aHeaderSleepTimer,b,x

        rtl

        .databank 0

      rlProcTalkDisplayOnCycle2

        .al
        .autsiz
        .databank ?

        ; Kill proc if not displaying range.

        lda wUnknown000E25,b
        cmp #$0002
        beq +

          stz aProcSystem.aHeaderTypeOffset,b,x
          rtl

        +
        ; Otherwise display sprite.

        php
        phb

        sep #$20

        lda #`_Sprite
        pha

        rep #$30

        plb

        .databank `_Sprite

        lda aProcSystem.aBody0,b,x
        sta wR0

        lda aProcSystem.aBody1,b,x
        sta wR1

        jsl rlGetPixelDistanceFromScreenEdge

        stz wR4
        stz wR5

        ldy #<>_Sprite

        jsl rlPushToOAMBuffer

        plb
        plp

        rtl

        _Sprite .structSpriteArray [[[0, -16], $00, SpriteLarge, $144, 3, 4, false, false]]

        .databank 0

    .send ProcTalkDisplaySection

.endif ; GUARD_ZQOL_TALK_DISPLAY
