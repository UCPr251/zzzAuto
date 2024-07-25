/**
 * - step1
 * - 进入副本
 */
enterFuben() {
  activateZZZ()
  debugLog("【step1】进入副本")
  RandomSleep()

  ; 进入旧都列车
  pixelSearchAndClick(619, 785, 710, 803, 665, 792, 0xffffff)
  ; 加载动画
  RandomSleep(1000, 1200)
  ; 进入旧都列车·前线
  pixelSearchAndClick(1620, 349, 1792, 408, 1706, 374, 0xbff700)
  ; 下一步
  pixelSearchAndClick(1670, 1018, 1739, 1037, 1707, 1028, 0xffffff)
  ; 加载动画
  RandomSleep(1000, 1200)
  ; 出战
  pixelSearchAndClick(1670, 1018, 1739, 1037, 1707, 1028, 0xffffff)
  ; 加载动画
  RandomSleep(17000, 18000)
}