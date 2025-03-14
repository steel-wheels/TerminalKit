/*
 * @file TMTerminalStorage.swift
 * @description Define TMTerminalStorage class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import Foundation

public class TMTerminalStorage
{
        public struct Size {
                public var width:  Int
                public var height: Int
                public init() {
                        width = 0 ; height = 0 ;
                }
        }

        private var mTextStorage:       MITextStorage
        private var mTerminalSize:      Size
        private var mFont:              MIFont

        public init(storage strg: MITextStorage){
                mTextStorage  = strg
                mTerminalSize = Size()
                /* setup font */
                mFont     = TMTerminalStorage.terminalFont(size: 20.0)
                let commands: Array<MITextStorage.Command> = [
                        .font(mFont)
                ]
                strg.execute(commands: commands)
                /* update */
                updateTerminalSize()
        }

        public var terminalSize: Size   { get { return mTerminalSize }}
        public var fontSize:     CGSize { get { return mTextStorage.fontSize }}

        public func execute(codes: Array<TMEscapeCode>) {
                var cmds: Array<MITextStorage.Command> = []
                for code in codes {
                        switch code {
                        case .string(let str):
                                cmds.append(.insert(str))
                        }
                }
                mTextStorage.execute(commands: cmds)
        }

        private static func terminalFont(size fontsize: CGFloat) -> MIFont {
                let font: MIFont
                if let fnt = MIFont.terminalFont(size: fontsize) {
                        NSLog("use terminal font: \(fontsize)")
                        font = fnt
                } else {
                        NSLog("use default font: \(fontsize)")
                        font = MIFont.monospacedSystemFont(ofSize: fontsize, weight: .regular)
                }
                return font
        }

        private func updateTerminalSize() {
                let framesz = mTextStorage.frameSize
                let fontsz  = mTextStorage.fontSize

                mTerminalSize.width  = Int(framesz.width  / fontsz.width)
                mTerminalSize.height = Int(framesz.height / fontsz.height)
                NSLog("TerminalSize: \(mTerminalSize.width) x \(mTerminalSize.height)")
        }
}

