LoadLibrary() {
   if (!DllCall("GetModuleHandle", "str", "gdiplus", "UPtr"))
      DllCall("LoadLibrary", "str", "gdiplus")
   si := Buffer(A_PtrSize = 8 ? 32 : 20, 0)
   DllCall("RtlFillMemory", "UPtr", si.Ptr, "UInt", 1, "UChar", 1)
   DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "UPtr", si.Ptr, "UPtr", 0)
   return pToken
}

ScreenBitmap(x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight) {
   w := x2 - x1
   h := y2 - y1
   chdc := DllCall("CreateCompatibleDC", "UPtr", 0)
   BI := Buffer(40, 0)
   NumPut("UInt", 40, BI, 0)
   NumPut("UInt", w, BI, 4)
   NumPut("UInt", h, BI, 8)
   NumPut("Ushort", 1, BI, 12)
   NumPut("Ushort", 32, BI, 14)
   NumPut("UInt", 0, BI, 16)
   hBitMap := DllCall("CreateDIBSection", "UPtr", chdc, "UPtr", BI.Ptr, "UInt", 0, "UPtr*", 0, "UPtr", 0, "UInt", 0, "UPtr")
   oldBitMap := DllCall("SelectObject", "UPtr", chdc, "UPtr", hBitMap)
   hhdc := DllCall("GetDC", "UPtr", 0)
   DllCall("gdi32\BitBlt", "UPtr", chdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "UPtr", hhdc, "Int", x1, "Int", y1, "UInt", 0x00CC0020)
   DllCall("ReleaseDC", "UPtr", 0, "UPtr", hhdc)
   DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitMap, "UPtr", 0, "UPtr*", &newBitmap := 0)
   DllCall("SelectObject", "UPtr", chdc, "UPtr", oldBitMap)
   DllCall("DeleteObject", "UPtr", hBitMap)
   DllCall("DeleteDC", "UPtr", hhdc)
   DllCall("DeleteDC", "UPtr", chdc)
   return newBitmap
}

GetBitMapPixel(pBitmap, x, y) {
   DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", x, "Int", y, "UInt*", &ARGB := 0)
   if (!IsInteger(ARGB)) {
      throw Error('ARGB值非整数')
   }
   Red := (ARGB >> 16) & 0xFF
   Green := (ARGB >> 8) & 0xFF
   Blue := ARGB & 0xFF
   return Format("0x{:02X}{:02X}{:02X}", Red, Green, Blue)
}

DisposeImage(pBitmap) {
   DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

FreeLibrary(pToken) {
   DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
   hModule := DllCall("GetModuleHandle", "Str", "gdiplus", "UPtr")
   if (hModule)
      DllCall("FreeLibrary", "UPtr", hModule)
}