/**
 * 识别所处界面
 * 
 * 返回值：
 * - 1：角色操作界面
 * - 2：零号空洞关卡选择界面
 * - 3：HDD关卡选择界面
 */
recogLocation(loopTimes := 30) {
  activateZZZ()

  /** 通过三个特殊定位点判断所处界面 */
  patterns1 := [
    c.角色操作.M,
    c.角色操作.Q,
    c.角色操作.T
  ]
  patterns2 := [
    c.零号选择.资质考核,
    c.零号选择.旧都列车,
    c.零号选择.施工废墟
  ]
  patterns3 := [
    c.拿命验收.返回键,
    c.拿命验收.难度格,
    c.拿命验收.推荐等级
  ]
  static judge(patterns) {
    for (pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }
  page := 0
  loop (loopTimes) {
    if (judge(patterns1)) {
      page := 1
      break
    }
    if (judge(patterns2)) {
      page := 2
      break
    }
    if (judge(patterns3)) {
      page := 3
      break
    }
    Sleep(100)
  }
  return page
}