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

                let commands: Array<MITextEditCommand> = [
                        .setFont(MIFont.terminalFont(size: 12.0)),
                        .setTextColor(MIColor.green),
                        .setBackgroundColor(MIColor.black)
                ]
                self.execute(commands: commands)

                self.insertionPointColor = MIColor.green
        }
}
