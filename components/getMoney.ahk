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
  ; 判断是否有零号业绩
  has := 0
  loop(10) {
    if (PixelSearchPre(&X, &Y, 850, 250, 1100, 450, 0x4d3dc6, 20)) {
      has := 1
      break
    }
    Sleep(100)
  }
  Press('w')
  if (has) {
    ; 加载动画
    RandomSleep(2500, 3000)
    ; 点击确定
    pixelSearchAndClick(930, 740, 1000, 780, 960, 760, 0xffffff)
    RandomSleep(1200, 1500)
  }
}