/**
 * - step9
 * - 判断是否上限
 */
isLimited() {
  activateZZZ()
  MsgBox("【step9】判断是否上限", , "T1")
  ; 结算界面判断是否达到周上限
  loop (20) {
    if (PixelSearchPre(&FoundX, &FoundY, 1326, 625, 1440, 666, 0xffb500, 80)) {
      return false
    }
    Sleep(100)
  }
  return true
}