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
        }

        private func updateTerminalSize() {
                let framesz = super.frameSize
                let fontsz  = super.fontSize
                let vspace  = super.lineSpacing

                mTerminalSize.width  = Int(framesz.width  / fontsz.width)
                mTerminalSize.height = Int(framesz.height / (fontsz.height + vspace))
                NSLog("TerminalSize: \(mTerminalSize.width) x \(mTerminalSize.height)")
        }

        private func updateContext() {
                /* rebuild context */
                var newlines: Array<NSAttributedString> = []
                let attrs    = self.currentAttributes
                let orglines = super.context.divideByNewline()
                for line in orglines {
                        let newline = line.adjustLength(width: mTerminalSize.width, attribute: attrs)
                        newlines.append(newline)
                }
                let restnum = mTerminalSize.height - orglines.count
                for _ in 0..<restnum {
                        let spaces  = String(repeating: " ", count: mTerminalSize.width)
                        let aspaces = NSAttributedString(string: spaces, attributes: attrs)
                        newlines.append(aspaces)
                }
                let newcontext = NSMutableAttributedString(string: "")
                for line in newlines {
                        newcontext.append(line)
                        newcontext.append(NSAttributedString(string: "\n"))
                }

                /* replace context */
                let commands0: Array<MITextStorage.Command> = [
                        .font(mFont),                   // required for initialize
                        .fullReplace(newcontext)
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
                        let cursize = super.frameSize
                        if cursize.width != newval.width || cursize.height != newval.height {
                                super.frameSize = newval
                                updateTerminalSize()
                                updateContext()
                        }
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
