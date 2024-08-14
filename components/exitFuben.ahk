/**
 * - step8
 * - 退出副本
 */
exitFuben() {
  activateZZZ()
  debugLog("【step8】退出副本")
  Press("Escape")
  pixelSearchAndClick(c.空洞.退出副本.放弃*)
  pixelSearchAndClick(c.空洞.退出副本.确定*)
  RandomSleep(4400, 4600)
}