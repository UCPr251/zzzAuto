/**
 * - step1
 * - 进入副本
 */
enterFuben() {
  activateZZZ()
  debugLog("【step1】进入副本")
  RandomSleep()

  ; 进入旧都列车
  pixelSearchAndClick(610, 750, 750, 820, 665, 792, 0xffffff)
  ; 加载动画
  RandomSleep(1000, 1200)
  ; 进入旧都列车·前线
  pixelSearchAndClick(1600, 349, 1800, 420, 1706, 374, 0xbff700)
  ; 下一步
  pixelSearchAndClick(1660, 960, 1740, 1040, 1707, 1028, 0xffffff)
  ; 加载动画
  RandomSleep(1000, 1200)
  ; 出战
  pixelSearchAndClick(1660, 960, 1740, 1040, 1707, 1028, 0xffffff)
  ; 加载动画
  RandomSleep(17000, 18000)
}