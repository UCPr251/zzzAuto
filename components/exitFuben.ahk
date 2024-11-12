/**
 * - 退出副本
 */
exitFuben(step := 8) {
  activateZZZ()
  stepLog("【step" step "】退出副本")

  Press("Escape")
  success := 0
  loop (40) {
    success := PixelSearchPre(&X, &Y, c.空洞.退出副本.放弃*)
    if (success) {
      SimulateClick(X, Y)
      break
    }
    Sleep(100)
  }
  if (!success) { ; 可能是存银行的时候卡四铭徽了
    MingHui(true)
    RandomSleep(600, 800)
    Press("Escape")
    pixelSearchAndClick(c.空洞.退出副本.放弃*)
  }
  pixelSearchAndClick(c.空洞.退出副本.确认*)
  RandomSleep(200, 251)
}