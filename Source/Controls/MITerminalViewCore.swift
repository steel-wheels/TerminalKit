/*
 * @file MITerminalViewCore.swift
 * @description Define MITerminalViewCore class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import  MultiUIKit
#if os(OSX)
import  AppKit
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)

public class MITerminalViewCore: MICoreView
{
        #if os(OSX)
        @IBOutlet var mTextView: NSTextView!
        #else
        @IBOutlet var mTextView: UITextView!
        #endif
}

