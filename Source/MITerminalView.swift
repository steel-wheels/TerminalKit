/*
 * @file MITerminalView.swift
 * @description Define MITerminalView class
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

public class MITerminalView: MITextView
{
        open override func setup(frame frm: CGRect) {
                NSLog("MITerminalView: setup")
                super.setup(frame: frm)
        }

        open override func allocateStorage() -> MITextStorage {
                return MITerminalStorage()
        }

        public var terminalStorage: MITerminalStorage { get {
                if let storage = super.textStorage as? MITerminalStorage {
                        return storage
                } else {
                        fatalError("can not happen")
                }
        }}
}
