/**
 * 进入HDD页面
 */
enterHDD(step := 1) {
  activateZZZ()
  stepLog("【step" step "】进入HDD页面")

  patterns := [
    c.地图.RandomPlay,
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
  Press('m')
  RandomSleep(800, 900)
  RandomMouseMove(c.width // 2, c.height // 2)
  loop (32) {
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
    Click('WD')
    RandomSleep(700, 720)
  }
  return false
}