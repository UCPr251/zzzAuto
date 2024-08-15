/**
 * - step1
 * - 进入副本
 */
enterFuben() {
  activateZZZ()
  debugLog("【step1】进入副本")
  pixelSearchAndClick(c.零号选择.旧都列车*)
  pixelSearchAndClick(c.旧都列车.前线*)
  pixelSearchAndClick(c.旧都列车.下一步*)
  RandomSleep(480, 500)
  pixelSearchAndClick(c.旧都列车.出战*)
  RandomSleep(17000, 18000)
}