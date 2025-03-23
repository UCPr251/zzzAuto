/**
 * - 判断是否上限
 */
isLimited() {
  activateZZZ()
  ; stepLog("【step9】判断是否上限")
  ; 结算界面判断是否达到周/日上限
  static search() {
    if (setting.mode = 'YeJi' && (setting.subLoopMode != 1)) {
      return PixelSearchPre(&FoundX, &FoundY, c.空洞.结算.零号业绩*)
    } else {
      return PixelSearchPre(&FoundX, &FoundY, c.拿命验收.丁尼*)
    }
  }
  loop (20) {
    if (search()) {
      Sleep(500)
      if (search()) {
        return false
      }
    }
    Sleep(300)
  }
  return true
}