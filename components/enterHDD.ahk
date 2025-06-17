/**
 * 进入HDD页面
 */
enterHDD(step := 1) {
  activateZZZ()
  stepLog("【step" step "】进入HDD页面")

  ; 连续运行，无需重复传送
  if (Ctrl.continuous) {
    Press('f', 3)
    RandomSleep(1400, 1500)
    return true
  }
  patterns := [
    c.地图.2F,
    c.地图.HDD
  ]
  FoundX := 0, FoundY := 0
  judge() {
    for (pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }
  Press(setting.quickNav)
  RandomSleep(800, 900)
  RandomPlay_X := 320, RandomPlay_Y := 220
  preprocess(&RandomPlay_X, &RandomPlay_Y)
  SimulateClick(RandomPlay_X, RandomPlay_Y)
  loop (5) {
    if (judge()) {
      SimulateClick(FoundX, FoundY)
      pixelSearchAndClick(c.空洞.退出副本.确认*)
      while (recogLocation() != 1) {
        if (A_Index > 6) {
          break
        }
        if (PixelSearchPre(&FoundX, &FoundY, c.空洞.退出副本.确认*)) {
          SimulateClick(FoundX, FoundY)
        }
        Sleep(500)
      }
      Press('f', 3)
      RandomSleep(1400, 1500)
      return true
    }
    Click('WU')
    RandomSleep(600, 620)
    SimulateClick(RandomPlay_X, RandomPlay_Y)
  }
  return false
}