/**
 * - step8
 * - 退出副本
 */
exitFuben() {
  activateZZZ()
  debugLog("【step8】退出副本")
  RandomSleep()

  ; 退出副本
  Press("Escape")
  RandomSleep(1000, 1200)
  ; 点击放弃
  pixelSearchAndClick(1580, 960, 1600, 1050, 1712, 1026, 0xcb0000)
  RandomSleep(600, 700)
  ; 点击确定
  pixelSearchAndClick(1000, 600, 1020, 650, 1121, 625, 0x00cc0d)
  RandomSleep(3800, 4000)
}