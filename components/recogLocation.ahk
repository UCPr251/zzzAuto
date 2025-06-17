/**
 * 识别所处界面
 * 
 * 返回值：
 * - 0：未知界面
 * - 1：角色操作界面
 * - 2：零号空洞关卡选择界面
 * - 3：HDD关卡选择界面
 */
recogLocation(loopTimes := 30) {
  activateZZZ()

  /** 通过特殊定位点判断所处界面 */
  patterns := [[
    c.角色操作.鼠标右键,
    c.角色操作.Q,
    [c.角色操作.T, c.角色操作.Tab]
  ], [
    c.零号选择.资质考核,
    c.零号选择.旧都列车,
    c.零号选择.施工废墟
  ], [
    c.拿命验收.返回键,
    c.拿命验收.难度格,
    c.拿命验收.推荐等级
  ]]
  static judge(patterns) {
    UC:
    for (pattern in patterns) {
      if (pattern[1] is Array) {
        for (p in pattern) {
          if (PixelSearchPre(&FoundX, &FoundY, p*)) {
            continue UC
          }
        }
      } else if (PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        continue
      }
      return false
    }
    return true
  }
  page := 0
  UC:
  loop (loopTimes) {
    for (i, pattern in patterns) {
      if (judge(pattern)) {
        page := i 
        break UC
      }
    }
    Sleep(200)
  }
  return page
}