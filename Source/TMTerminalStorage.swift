/*
 * @file TMTerminalStorage.swift
 * @description Define TMTerminalStorage class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import MultiDataKit
import Foundation

public class TMTerminalStorage: MITextStorage
{
        public struct Size {
                public var width:  Int
                public var height: Int
                public init() {
                        width = 0 ; height = 0 ;
                }
        }

        private var mTerminalSize:      Size
        private var mFont:              MIFont

        public var terminalSize: Size   { get { return mTerminalSize }}

        public override init(){
                mTerminalSize   = Size()
                mFont           = TMTerminalStorage.terminalFont(size: 20.0)
                super.init()

                /* setup font */
                let commands: Array<MITextStorage.Command> = [
                        .font(mFont)
                ]
                super.execute(commands: commands)
                /* update */
                updateTerminalSize()
                /* initialize context */
                initContext()
        }

        private func updateTerminalSize() {
                let framesz = super.frameSize
                let fontsz  = super.fontSize

                mTerminalSize.width  = Int(framesz.width  / fontsz.width)
                mTerminalSize.height = Int(framesz.height / fontsz.height)
                NSLog("TerminalSize: \(mTerminalSize.width) x \(mTerminalSize.height)")
        }

        private func initContext() {
                /* fill by spaces */
                var str: String = ""
                for i in 0..<mTerminalSize.height {
                        let line = String(repeating: " ", count: mTerminalSize.width)
                        if i > 0 { str += "\n" }
                        str += line
                }
                let commands0: Array<MITextStorage.Command> = [
                        .insert(str)
                ]
                super.execute(commands: commands0)

                /* rewind the cursor */
                let idx = super.currentIndex
                let commands1: Array<MITextStorage.Command> = [
                        .moveBackward(idx)
                ]
                super.execute(commands: commands1)
        }

        public func setContentsSize(width w: Int, height h: Int) {
                let lspace  = super.lineSpacing
                let fontsz  = super.fontSize
                let width   = CGFloat(w) * fontsz.width
                let height  = CGFloat(h) * (fontsz.height + lspace)
                self.contentsSize = CGSize(width: width, height: height)
        }

        open override var frameSize: CGSize {
                get { return super.frameSize }
                set(newval){
                        super.frameSize = newval
                        updateTerminalSize()
                }
        }

        public func execute(codes: Array<TMEscapeCode>) {
                var cmds: Array<MITextStorage.Command> = []
                let (curx, _) = self.cursorPosition
                for code in codes {
                        switch code {
                        case .string(let str):
                                let rspace = mTerminalSize.width - curx
                                let len    = min(str.count, rspace)
                                if len > 0 {
                                        let mstr = String(str.prefix(len))
                                        cmds.append(.removeRight(len))
                                        cmds.append(.insert(mstr))
                                }
                        }
                }
                super.execute(commands: cmds)
        }

        private var cursorPosition: (Int, Int) {
                let index = super.currentIndex
                let width = mTerminalSize.width
                if width > 0 {
                        let x     = index % width
                        let y     = index / width
                        if y < mTerminalSize.height {
                                return (x, y)
                        } else {
                                NSLog("[Error] Unexpected cursor index (1) \(index)")
                                return (0, 0)
                        }
                } else {
                        NSLog("[Error] Unexpected cursor index (2) \(index)")
                        return (0, 0)
                }
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
}
