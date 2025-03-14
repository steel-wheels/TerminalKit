/*
 * @file TMEscapeCode.swift
 * @description Define TMEscapeCode class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

#if os(OSX)
import  AppKit
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)
import MultiUIKit
import MultiDataKit

/* Reference:
 *  - https://en.wikipedia.org/wiki/ANSI_escape_code
 *  - https://qiita.com/PruneMazui/items/8a023347772620025ad6
 *  - http://www.termsys.demon.co.uk/vtansi.htm
 */
public enum TMEscapeCode
{
        case        string(String)
}

