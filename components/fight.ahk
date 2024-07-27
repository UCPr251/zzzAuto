/**
 * - step4
 * - 战斗
 */
fight() {
  activateZZZ()
  debugLog("【step4】战斗")
  RandomSleep()

  ; 点击进入战斗
  pixelSearchAndClick(1390, 540, 1500, 570, 1650, 570, 0xffffff)

  /** 判断是否位于对应界面 */
  judge(patterns) {
    for (index, pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }

  /** 通过三个特殊定位点判断所处界面 */
  patterns := [
    [1230, 430, 1370, 610, 0xffc300], ; 战斗计时
    [1000, 840, 1040, 1020, 0x00cc0d], ; 确定绿勾
    [1130, 840, 1190, 1020, 0xffffff] ; 确定键
  ]

  /** 判断战斗是否结束 */
  fightIsOver() {
    judge() {
      loop (10) {
        for (index, pattern in patterns) {
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
      ; 周上限提示确定
      if (PixelSearchPre(&X, &Y, 950, 610, 1000, 640, 0xffffff, variation // 2)) {
        SimulateClick(X, Y)
        RandomSleep(800, 1000)
      }
      return false
    }
    debugLog("【战斗】战斗结束")
    RandomSleep()
    ; 点击确定
    SimulateClick(FoundX, FoundY, 2)
    RandomSleep(500, 800)
    ; 选择铭徽
    MingHui()
    ; 加载动画
    RandomSleep(7500, 8000)
    return true
  }

  ; 加载动画
  RandomSleep(16000, 16200)
  ; 战斗循环，约8s一循环
  loop (12) {
    if (A_Index != 1) {
      Press("Shift") ; 闪避
    }
    Send("{w Down}") ; 向前
    RandomSleep(300, 400)
    Click("Right Down") ; 右键蓄力，进入快蓄
    RandomSleep(580, 600)
    Click("Right Up") ; 快蓄完毕，释放右键
    RandomSleep()
    Click("Left Down") ; 普攻蓄力
    if (fightIsOver()) {
      return true
    }
    RandomSleep(1500, 1800)
    Click("Left Up") ; 完成蓄力普攻
    Send("{w Up}") ; 停止移动
    RandomSleep()
    ; 战斗动作
    loop (2) {
      Press("e") ; 使用技能
      SimulateClick(, , 4) ; 普攻
      Press("e") ; 使用技能
      SimulateClick(, , 8) ; 普攻
      Press("Shift") ; 闪避
      if (fightIsOver()) {
        return true
      }
    }
  }
  return false
}