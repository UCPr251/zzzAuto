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
  RandomSleep(1000, 1500)
  pixelSearchAndClick(1585, 1010, 1601, 1044, 1712, 1026, 0xcb0000)
  RandomSleep(500, 800)
  pixelSearchAndClick(1000, 608, 1020, 643, 1121, 625, 0x00cc0d)
  RandomSleep(3000, 4000)
}