/**
 * - 战斗
 */
fight(step := 4) {
  activateZZZ()
  stepLog("【step" step "】战斗")

  ; 进入战斗
  Press("1", 3)

  /** 通过三个特殊定位点判断所处界面 */
  patterns := [
    c.空洞.1.战斗.计时,
    c.空洞.1.战斗.确定键,
    c.空洞.1.战斗.确定绿勾
  ]

  ; 加载动画
  Sleep(10000)
  while (!PixelSearchPre(&X, &Y, c.空洞.1.战斗.开始*)) {
    if (A_Index > 251) {
      if (!setting.errHandler) {
        throw Error('识别战斗开始画面失败')
      }
      break
    }
    Sleep(100)
  }

  ; 战斗循环
  ; 通用战斗模式
  if (setting.fightMode = 1) {
    Send("{w Down}") ; 向前
    autoDodge(1400, 1500)
    Send("{w Up}")
    ; 约3s一循环
    loop (30) {
      ; 战斗动作
      sAttack() ; 使用技能
      attack(4) ; 普攻
      if (fightIsOver(patterns)) {
        return true
      }
      sAttack() ; 使用技能
      attack(8) ; 普攻
      if (fightIsOver(patterns)) {
        return true
      }
      Send("{w Down}") ; 向前
      autoDodge(500, 600)
      Send("{w Up}") ; 向前
    }
    ; 艾莲战斗模式
  } else if (setting.fightMode = 2) {
    ; 约8s一循环
    loop (10) {
      if (A_Index != 1 && !setting.isAutoDodge) {
        Press("Shift") ; 闪避
      }
      Send("{w Down}") ; 向前
      autoDodge(300, 320)
      Click("Right Down") ; 右键蓄力，进入快蓄
      autoDodge(580, 600)
      Click("Right Up") ; 快蓄完毕，释放右键
      autoDodge()
      Click("Left Down") ; 普攻蓄力
      if (fightIsOver(patterns)) {
        return true
      }
      autoDodge(1500, 1800)
      Click("Left Up") ; 完成蓄力普攻
      Send("{w Up}") ; 停止移动
      autoDodge()
      ; 战斗动作
      loop (2) {
        sAttack() ; 使用技能
        attack(4) ; 普攻
        sAttack() ; 使用技能
        attack(8) ; 普攻
        if (!setting.isAutoDodge) {
          Press("Shift") ; 闪避
        }
        if (fightIsOver(patterns)) {
          return true
        }
      }
    }
  }

  ; 如果战斗时长超过设置好的循环次数，可能是因为周上限提示需要点击确定，尝试使用Esc退出确认窗口，否则可以暂停战斗
  Press('Escape')
  RandomSleep(800, 1000)
  return fightIsOver(patterns)

  /** 自动闪避 */
  autoDodge(ms1 := 50, ms2 := 100) {
    if (!setting.isAutoDodge) {
      return Sleep(Random(ms1, ms2))
    }
    static X1 := Integer(A_ScreenWidth * 0.2), X2 := Integer(A_ScreenWidth * 0.38)
    static X3 := Integer(A_ScreenWidth * 0.42), X4 := Integer(A_ScreenWidth * 0.58)
    static X5 := Integer(A_ScreenWidth * 0.62), X6 := Integer(A_ScreenWidth * 0.8)
    static Y1 := Integer(A_ScreenHeight * 0.12), Y2 := Integer(A_ScreenHeight * 0.88)
    static lastTick := 0
    static variation := Max(Round(setting.variation * 0.5), 20)
    randomMs := Random(ms1, ms2)
    start := A_TickCount
    X := 0, Y := 0
    loop (251) {
      if (PixelSearch(&X, &Ymatch1, X1, Y1, X2, Y2, 0xff5e57, variation)
        && PixelSearch(&X, &Ymatch2, X3, Y1, X4, Y2, 0xff5e57, variation)
        && PixelSearch(&X, &Ymatch3, X5, Y1, X6, Y2, 0xff5e57, variation)) {
        if ((A_TickCount - lastTick > 251) && (Abs(Ymatch1 - Ymatch2) < 100 && Abs(Ymatch2 - Ymatch3) < 100)) {
          lastTick := A_TickCount
          Press("Shift")
          passed := A_TickCount - start
          if (passed > randomMs) {
            return
          }
          Sleep(passed - randomMs)
        }
      }
      if (A_TickCount - start > randomMs - 50) {
        return
      }
    }
  }

  /** 普攻 */
  attack(times) {
    Loop (times) {
      Click("Left Down")
      autoDodge()
      Click("Left Up")
      autoDodge(160, 200)
    }
  }

  /** E技能 */
  sAttack() {
    Send("{e Down}")
    autoDodge()
    Send("{e Up}")
    autoDodge(200, 220)
  }

  /** 判断战斗是否结束 */
  static fightIsOver(patterns) {
    judge() {
      loop (10) {
        for (pattern in patterns) {
          if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
            return false
          }
        }
        Sleep(10)
      }
      return true
    }
    FoundX := 0, FoundY := 0
    if (!judge()) {
      return false
    }
    stepLog("【战斗】战斗结束")
    ; 点击确定
    SimulateClick(FoundX, FoundY, 2)
    RandomSleep(500, 600)
    ; 选择铭徽
    MingHui()
    ; 加载动画
    RandomSleep(7500, 8000)
    return true
  }
}