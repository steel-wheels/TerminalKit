/*
 * @file MITerminalView.swift
 * @description Define MITerminalView class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import  MultiUIKit
#if os(OSX)
import  AppKit
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)

public class MITerminalView: MIInterfaceView
{
        public override func setup(frame frm: CGRect) {
                super.setup(nibName: "MMITerminalViewCore", frameSize: frm.size)
        }

        private func coreTerminalView() -> MITerminalViewCore {
                if let core: MITerminalViewCore = super.coreView() {
                        return core
                } else {
                        fatalError("Failed to get core view")
                }
        }
}

