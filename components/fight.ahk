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

  static XStart := 0.2, XEnd := 0.8, XHierarchy := 3, XInteval := 0.03
  static YStart := 0.1, YEnd := 0.8, YHierarchy := 4, YInteval := 0
  variation := Min(Max(Round(setting.variation * 0.5), 10), 50)
  X := Cal(c.width, XStart, XEnd, XHierarchy, XInteval)
  Y := Cal(c.height, YStart, YEnd, YHierarchy, YInteval)
  ; 战斗开始
  Ctrl.startFight()
  ; 通用·普通攻击战斗模式
  if (setting.fightMode = 1) {
    Send("{w Down}") ; 向前
    Press("Shift", 2)
    autoDodge(200, 300)
    Send("{w Up}")
    ; 约5s一循环
    loop (16) {
      ; 战斗动作
      sAttack() ; 使用技能
      attack(4)
      if (!setting.isAutoDodge) {
        Press("Shift") ; 闪避
      }
      if (fightIsOver(patterns)) {
        return true
      }
      sAttack() ; 使用技能
      attack(8)
      if (fightIsOver(patterns)) {
        return true
      }
      if (!setting.isAutoDodge) {
        Press("Shift") ; 闪避
      }
      Send("{w Down}") ; 向前
      autoDodge(500, 600)
      Send("{w Up}") ; 向前
    }
    ; 艾莲战斗模式
  } else if (setting.fightMode = 2) {
    ; 约10s一循环
    loop (8) {
      if (A_Index != 1 && !setting.isAutoDodge) {
        Press("Shift") ; 闪避
      }
      Send("{w Down}") ; 向前
      autoDodge(80, 100)
      Click("Right Down") ; 右键蓄力，进入快蓄
      autoDodge(420, 430)
      Click("Right Up") ; 快蓄完毕，释放右键
      Click("Left Down") ; 普攻蓄力
      autoDodge()
      if (fightIsOver(patterns)) {
        return true
      }
      autoDodge(1500, 1600)
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
    ; 雅战斗模式
  } else if (setting.fightMode = 3) {
    ; 约12s一循环
    loop (6) {
      if (A_Index = 1) {
        ; 长闪避近身
        Send("{w Down}")
        Send("{Shift Down}")
        Sleep(Random(360, 400))
        Send("{Shift Up}")
        RandomSleep(200, 220)
        Send("{w Up}")
      }
      ; 蓄力斩
      Click("Left Down")
      Sleep(Random(1660, 1720))
      Click("Left Up")
      attack(10)
      if (fightIsOver(patterns)) {
        return true
      }
      attack(6)
      autoDodge(500, 520)
      sAttack()
      sAttack()
      autoDodge(460, 520)
      sAttack()
      sAttack()
      if (fightIsOver(patterns)) {
        return true
      }
      attack(12)
    }
  }

  ; 如果战斗时长超过设置好的循环次数，可能是因为周上限提示需要点击确定，尝试使用Esc退出确认窗口，否则可以暂停战斗
  Press('Escape')
  RandomSleep(800, 1000)
  return fightIsOver(patterns)

  /** 自动闪避 */
  autoDodge(ms1 := 50, ms2 := 100) {
    if (!setting.isAutoDodge) {
      return RandomSleep(ms1, ms2)
    }
    static lastTick := 0
    randomMs := Random(ms1, ms2)
    start := A_TickCount
    loop {
      if (A_TickCount - lastTick < 500) { ; 闪避CD中
        leftCD := 500 - (A_TickCount - lastTick) ; 剩余CD时长
        passed := A_TickCount - start ; 已过的时长
        if (passed + leftCD > randomMs) { ; 如果剩余CD时长+已过的时长>需休眠时长，休眠至函数结束
          return Sleep(randomMs - passed)
        } else { ; 否则休眠至CD结束，继续下一次检测
          Sleep(leftCD)
        }
      }
      if (HierarchicalSearch(X, XHierarchy, Y, YHierarchy, 0xff6565, variation)) {
        lastTick := A_TickCount
        Send("{Shift Down}")
        Sleep(Random(80, 100))
        Send("{Shift Up}")
        Sleep(Random(120, 140))
        attack(1)
      }
      if (A_TickCount - start > randomMs - 30) {
        return
      }
    }
  }

  ; 分层搜索，需Y轴某一层匹配成功，X轴每一层都匹配成功
  static HierarchicalSearch(X, XHierarchy, Y, YHierarchy, Color, variation) {
    loop (YHierarchy) { ; 对Y轴每层进行遍历
      YNowStart := Y[A_Index * 2 - 1] ; Y轴该层的起始坐标
      YNowEnd := Y[A_Index * 2] ; Y轴该层的终止坐标
      if (PixelSearch(&Xmatch, &Ymatch, X[1], YNowStart, X[2], YNowEnd, Color, variation)) { ; 对X轴第一层进行匹配
        loop (XHierarchy - 1) { ; 对X轴其余每一层进行匹配
          if (!PixelSearch(&Xmatch, &Ymatch, X[A_Index * 2 + 1], Ymatch - 30, X[A_Index * 2 + 2], Ymatch + 30, Color, variation)) {
            return false
          }
        }
        return true ; X轴每层都匹配成功
      }
    }
    return false
  }

  static Cal(len, Start, End, Hierarchy, Inteval) {
    data := [Round(len * Start)]
    IntevalLen := Round(len * Inteval)
    HierarchyLen := Round((len * (End - Start) - IntevalLen * (Hierarchy - 1)) / Hierarchy)
    loop (Hierarchy * 2 - 1) {
      data.Push(data[A_Index] + (Mod(A_Index, 2) ? HierarchyLen : IntevalLen))
    }
    return data
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
    Ctrl.finishFight()
    stepLog("【战斗】战斗结束")
    ; 点击确定
    SimulateClick(FoundX, FoundY, 2)
    RandomSleep(800, 1000)
    MingHui()

    Sleep(3000)
    awaitLoading() {
      static startX := Integer(c.width * 0.3), endX := Integer(c.width * 0.7)
      static startY := Integer(c.height * 0.7), endY := Integer(c.height * 0.95)
      loop (5) {
        if (!PixelSearch(&X, &Y, startX, startY, endX, endY, 0x009dff, setting.variation)) {
          return false
        }
        Sleep(100)
      }
      return true
    }
    loop {
      if (awaitLoading()) {
        break
      }
      if (A_Index > 50) {
        if (!setting.errHandler) {
          throw Error('识别进入副本·第二层失败')
        }
        break
      }
      Sleep(200)
    }
    RandomSleep(1000, 1200)
    return true
  }
}