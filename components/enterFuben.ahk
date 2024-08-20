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
  RandomSleep(17000, 18000)
}