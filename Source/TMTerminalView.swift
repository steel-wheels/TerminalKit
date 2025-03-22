/*
 * @file TMTerminalView.swift
 * @description Define TMTerminalView class
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

public class TMTerminalView: MITextView
{
        open override func setup(frame frm: CGRect) {
                NSLog("TMTerminalView: setup")
                super.setup(frame: frm)
        }

        open override func allocateStorage() -> MITextStorage {
                return TMTerminalStorage()
        }

        public var terminalStorage: TMTerminalStorage { get {
                if let storage = super.textStorage as? TMTerminalStorage {
                        return storage
                } else {
                        fatalError("can not happen")
                }
        }}
}
