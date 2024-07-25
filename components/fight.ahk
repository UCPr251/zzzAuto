/**
 * - step4
 * - 战斗
 */
fight() {
  activateZZZ()
  debugLog("【step4】战斗")
  RandomSleep()

  ; 点击进入战斗
  SimulateClick(1361, 572, 3)

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
    [1230, 430, 1370, 610, 0xffc300, 40], ; 战斗计时
    [1000, 870, 1030, 1020, 0x00cc0d, 40], ; 绿勾
    [1130, 880, 1190, 1020, 0xffffff, 40] ; 确定键
  ]

  /** 判断战斗是否结束 */
  fightIsOver() {
    ; 周上限提示确定
    if (PixelSearchPre(&X, &Y, 954, 614, 1001, 636, 0xffffff, 30)) {
      SimulateClick(X, Y)
      Sleep(1000)
    }
    loop (10) {
      for (index, pattern in patterns) {
        if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
          return false
        }
      }
      Sleep(50)
    }
    MsgBox("【战斗】战斗结束", , "T2")
    RandomSleep()
    ; 点击确定
    SimulateClick(FoundX, FoundY, 2)
    RandomSleep(500, 800)
    ; 选择铭徽
    SimulateClick(960, 790, 3)
    ; 加载动画
    Sleep(7000)
    return true
  }

  ; 加载动画
  Sleep(16000)

  ; 战斗循环
  loop (40) {
    Send("{w Down}") ; 向前
    RandomSleep(300, 400)
    Click("Right Down") ; 右键蓄力，进入快蓄
    RandomSleep(580, 620)
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
    loop (5) {
      Press("e") ; 使用技能
      SimulateClick(, , 6) ; 普攻
      Press("Shift") ; 闪避
      Press("e") ; 使用技能
      SimulateClick(, , 6) ; 普攻
      if (fightIsOver()) {
        return true
      }
    }
  }
  return false
}