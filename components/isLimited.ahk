/**
 * - step9
 * - 判断是否上限
 */
isLimited() {
  activateZZZ()
  ; debugLog("【step9】判断是否上限")
  ; 结算界面判断是否达到周上限
  loop (20) {
    if (PixelSearchPre(&FoundX, &FoundY, c.空洞.结算.零号业绩*)) {
      return false
    }
    Sleep(100)
  }
  return true
}