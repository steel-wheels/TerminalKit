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

public class MITerminalView: MITextView
{
        open override func setup(frame frm: CGRect) {
                super.setup(frame: frm)

                let storage = self.textStorage

                let commands: Array<MITextStorage.Command> = [
                        .setFont(MIFont.terminalFont(size: 12.0))
                ]
                storage.execute(commands: commands)
        }
}
