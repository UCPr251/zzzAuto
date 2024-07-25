/**
 * - step6
 * - 获得零号业绩
 */
getMoney() {
  activateZZZ()
  debugLog("【step6】获得零号业绩")
  RandomSleep()
  ; 进入零号业绩格子
  Press('d')
  Press('w', 2)
  Press('d', 2)
  RandomSleep(2200, 2500)
  Press('Space', 8)
  RandomSleep(2200, 2500)
  Press('d')
  Press('w')
  RandomSleep(2500, 3000)
  ; 点击确定，如果已达上限则无确定按键
  if (PixelSearchPre(&X, &Y, 930, 740, 1000, 780, 0xffffff, 20)) {
    SimulateClick(X, Y)
  }
  RandomSleep(1200, 1500)
}