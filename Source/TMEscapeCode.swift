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

public enum TMEscapeCode {
        case text(String)
}

