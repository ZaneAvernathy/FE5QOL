
.cpu "65816"

.weak
  WARNINGS :?= "None"
.endweak

GUARD_ZQOL_INSTALLER :?= false
.if (GUARD_ZQOL_INSTALLER && (WARNINGS == "Strict"))

  .warn "File included more than once."

.elsif (!GUARD_ZQOL_INSTALLER)

  .include "TOOLS/VoltEdge.h"

  ; Definitions

    .include "QOLConfiguration.txt"

  ; Fixed location inclusions

    .include "BaseROM.asm"

    .if (INSTALL_QOL_GUARD_AI)

      .include "GuardAI.asm"

    .endif ; INSTALL_QOL_GUARD_AI

    .if (INSTALL_QOL_MOVEMENT_SPEEDUP)

      .include "MovementSpeedup.asm"

    .endif ; INSTALL_QOL_MOVEMENT_SPEEDUP

    .if (INSTALL_QOL_SWAP_ANIMATION_MODE)

      .include "SwapAnimationMode.asm"

    .endif ; INSTALL_QOL_SWAP_ANIMATION_MODE

    .if (INSTALL_QOL_TALK_DISPLAY)

      .include "TalkDisplay.asm"

    .endif ; INSTALL_QOL_TALK_DISPLAY

    .if (INSTALL_QOL_EQUIPPED_ITEM_PREVIEW)

      .include "EquippedItemPreview.asm"

    .endif ; INSTALL_QOL_EQUIPPED_ITEM_PREVIEW

    .if (INSTALL_QOL_HP_BARS)

      .include "HPBars.asm"

    .endif ; INSTALL_QOL_HP_BARS

  ; Freespace inclusions

    * := QOL_FREESPACE
    .logical mapped(QOL_FREESPACE)

      .if (INSTALL_QOL_GUARD_AI)

        .dsection GetEffectiveMoveSection

      .endif ; INSTALL_QOL_GUARD_AI

      .if (INSTALL_QOL_MOVEMENT_SPEEDUP)

        .dsection GetMovingMapSpriteMovementSpeedSection

      .endif ; INSTALL_QOL_MOVEMENT_SPEEDUP

      .if (INSTALL_QOL_SWAP_ANIMATION_MODE)

        .dsection GetPossibleAnimationModeSection

      .endif ; INSTALL_QOL_SWAP_ANIMATION_MODE

      .if (INSTALL_QOL_TALK_DISPLAY)

        .dsection TalkDisplaySection
        .dsection TalkDisplayFilterSection
        .dsection ProcTalkDisplaySection

      .endif ; INSTALL_QOL_TALK_DISPLAY

      .if (INSTALL_QOL_EQUIPPED_ITEM_PREVIEW)

        .dsection KillEquippedItemPreviewProcSection
        .dsection DrawEquippedItemPreviewSection
        .dsection ProcEquippedItemPreviewSection
        .dsection DMAEquippedItemIconSection
        .dsection BurstWindowTilemapSection
        .dsection ClearBurstWindowTilemapLayerSection
        .dsection BurstWindowTilesSection

      .endif ; INSTALL_QOL_EQUIPPED_ITEM_PREVIEW

      .if (INSTALL_QOL_HP_BARS)

        .dsection TryRegisterHPBarSection
        .dsection RenderTallMapSpriteAndStatusLoopSection
        .dsection MissSpriteFrameSection
        .dsection ObjectiveMarkerHPBarEditsSection

      .endif ; INSTALL_QOL_HP_BARS

    .here

.endif ; GUARD_ZQOL_INSTALLER
