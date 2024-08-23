/** 识别所处界面 1：角色操作界面，2：关卡选择界面 */
recogLocation() {
  activateZZZ()

  /** 通过三个特殊定位点判断所处界面 */
  patterns1 := [
    c.角色操作.M,
    c.角色操作.Q,
    c.角色操作.Tab
  ]
  patterns2 := [
    c.零号选择.资质考核,
    c.零号选择.旧都列车,
    c.零号选择.施工废墟
  ]
  static judge(patterns) {
    for (pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }
  mode := 0
  loop (30) {
    if (judge(patterns1)) {
      mode := 1
      break
    }
    if (judge(patterns2)) {
      mode := 2
      break
    }
    Sleep(100)
  }
  return mode
}