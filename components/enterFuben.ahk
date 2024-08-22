/**
 * - 进入副本
 */
enterFuben(step := 1) {
  activateZZZ()
  stepLog("【step" step "】进入副本")

  pixelSearchAndClick(c.零号选择.旧都列车*)
  pixelSearchAndClick(c.旧都列车.前线*)
  pixelSearchAndClick(c.旧都列车.下一步*)
  RandomSleep(580, 600)
  pixelSearchAndClick(c.旧都列车.出战*)
  Sleep(10000)
  startX := Integer(A_ScreenWidth * 0.3), endX := Integer(A_ScreenWidth * 0.7)
  startY := Integer(A_ScreenHeight * 0.8), endY := Integer(A_ScreenHeight * 0.95)
  while (!PixelSearch(&X, &Y, startX, startY, endX, endY, 0x009dff, setting.variation)) {
    if (A_Index > 60) {
      if (!setting.errHandler) {
        throw Error('识别进入副本·第一层失败')
      }
      break
    }
    Sleep(200)
  }
  RandomSleep(2000, 2200)
}