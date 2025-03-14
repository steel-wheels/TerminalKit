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
        private var mStorage: TMTerminalStorage? = nil

        open override func setup(frame frm: CGRect) {
                NSLog("TMTerminalView: setup")
                super.setup(frame: frm)
                mStorage = TMTerminalStorage(storage: super.textStorage)
        }

        public var terminalStorage: TMTerminalStorage { get {
                if let storage = mStorage {
                        return storage
                } else {
                        fatalError("can not happen")
                }
        }}
}
