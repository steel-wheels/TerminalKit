/*
 * @file MITerminalView.swift
 * @description Define MITerminalView class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

#if os(OSX)
import  Cocoa
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)
import MultiUIKit
import MultiDataKit

public class MITerminalView: MITextView
{
        private var mStandardInput:     FileHandle
        private var mStandardOutput:    FileHandle
        private var mStandardError:     FileHandle
        private var mCursorTimer:       Timer? = nil

        public override init(frame: CGRect) {
                mStandardInput  = FileHandle.standardInput
                mStandardOutput = FileHandle.standardOutput
                mStandardError  = FileHandle.standardError
                super.init(frame: frame)
        }
        
        @MainActor @preconcurrency required dynamic init?(coder: NSCoder) {
                mStandardInput  = FileHandle.standardInput
                mStandardOutput = FileHandle.standardOutput
                mStandardError  = FileHandle.standardError
                super.init(coder: coder)
        }
        
        deinit {
                if let timer = mCursorTimer {
                        timer.invalidate()
                        mCursorTimer = nil
                }
        }

        open override func setup(frame frm: CGRect) {
                super.setup(frame: frm)

                let commands: Array<MITextEditCommand> = [
                        .setFont(MIFont.terminalFont(size: 12.0)),
                        .setTextColor(.green),
                        .setBackgroundColor(.black),
                        .insertText(" ")                // space for cursor
                ]
                self.execute(commands: commands)

                self.insertionPointColor = MIColor.green

                #if os(OSX)
                super.set(keyEventReceiver: {
                        (_ down: Bool, _ event: NSEvent) -> Bool in
                        return self.keydown(isKeyDown: down, event: event)
                })
                #endif

                #if os(OSX)
                mCursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                        DispatchQueue.main.async {
                                self.execute(commands: [.blinkCursor(!self.cursor.blink)])
                        }
                }
                #endif

                self.cursor.visible = true
        }

        public var standardInput: FileHandle {
                get {
                        return mStandardInput
                }
                set(hdl){
                        mStandardInput = hdl
                        hdl.setReader(reader: { (_ str: String) in
                                switch MIEscapeCode.decode(string: str) {
                                case .success(let ecodes):
                                        Task { await self.execute(escapeCodes: ecodes) }
                                case .failure(let err):
                                        NSLog("[Error] \(MIError.errorToString(error: err)) at \(#file)")
                                }
                        })
                }
        }

        public var standardOutput: FileHandle {
                get      { return mStandardOutput }
                set(hdl) { mStandardOutput = hdl }
        }

        public var standardError: FileHandle {
                get      { return mStandardError }
                set(hdl) { mStandardError = hdl }
        }

        #if os(OSX)
        private func keydown(isKeyDown down: Bool, event evt: NSEvent) -> Bool {
                guard down else {
                        return true
                }
                let ecodes = MIEscapeCode.decode(event: evt)
                respond(escapeCodes: ecodes)
                return true
        }
        #endif

        private func execute(escapeCodes codes: Array<MIEscapeCode>) {
                for code in codes {
                        execute(escapeCode: code)
                }
        }

        private func execute(escapeCode code: MIEscapeCode) {
                var commands: Array<MITextEditCommand> = []

                if self.cursor.visible {
                        commands.append(.blinkCursor(false))
                }

                switch code {
                case .string(let str):
                        let strcmds = encode(string: str)
                        commands.append(contentsOf: strcmds)
                /* key */
                case .key(let key):
                        switch key {
                        case .lineFeed, .enter, .carriageReturn:
                                commands.append(.insertNewline)
                        case .arrow(let atype):
                                switch atype {
                                case .right:    commands.append(.moveCursorForward(1))
                                case .left:     commands.append(.moveCursorBackward(1))
                                case .up:       commands.append(.moveCursorUp(1))
                                case .down:     commands.append(.moveCursorDown(1))
                                @unknown default:
                                        NSLog("[Error] Can not happen at \(#file)")
                                }
                        case .tab:
                                commands.append(.insertTab)
                        case .home:
                                commands.append(.moveCursorToHome)
                        case .delete, .backspace:
                                commands.append(.removeBackward(1))
                        default:
                                NSLog("Unsupported key: \(key.description) at \(#file))")
                        }
                /* cursor operation */
                case .moveCursorForward(let num):
                        commands.append(.moveCursorForward(num))
                case .moveCursorBackward(let num):
                        commands.append(.moveCursorBackward(num))
                case .makeCursorVisible(let flag):
                        commands.append(.setCursorVisible(flag))
                /* color operation */
                case .setColor(let txtcol):
                        let (isfg, color) = txtcol.toNativeColor()
                        if isfg {
                                commands.append(.setTextColor(color))
                        } else {
                                commands.append(.setBackgroundColor(color))
                        }
                /* blink cursor s*/
                case .blinkCursor(let flag):
                        commands.append(.blinkCursor(flag))
                default:
                        NSLog("Unsupported sequence: \(code.description()) at \(#file))")
                /*
                 /* Key */

                 /* Cursor Controls */
                 case moveCursorTo(Int, Int)                     // (line, column)
                 case moveCursorToBeginingOfNextLine(Int)         // (lines)
                 case moveCursorToBeginingOfPrevLine(Int)         // (lines)
                 case moveCursorToColumn(Int)                    // (column)
                 case requestCursorPosition
                 case moveCursor1LineUp
                 case saveCursorPosition(Int)                    // 0:DEC, 1:SCO
                 case restoreCursorPosition(Int)                 // 0:DEC, 1:SCO
                 case makeCursorVisible(Bool)
                 case blinkCursor(Bool)                          // Custom defined

                 /* screen */
                 case restoreScreen
                 case saveScreen
                 case enableAlternativeBuffer(Bool)

                 /* Erace operation */
                 case eraceFromCursorWithLength(Int)             // (length)
                 case eraceFromCursorUntilEndOfScreen
                 case eraceFromToBeginningOfScreen
                 case eraceEntireScreen
                 case eraceSavedLines
                 case eraceFromCusorToEndOfLine
                 case eraceStartOfLineToCursor
                 case eraceEntireLine

                 /*  Charactet Attribute */
                 case setCharacterAttribute(Array<MICharacterAttribute>)
                 case resetAllCharacterAttributes

                 /* Character Color */

                 */
                }

                if self.cursor.visible {
                        commands.append(.blinkCursor(true))
                }
                super.execute(commands: commands)
        }

        private func encode(string str: String) -> Array<MITextEditCommand> {
                var result: Array<MITextEditCommand> = []
                var idx    = str.startIndex
                let endidx = str.endIndex

                var line: String = ""
                while idx < endidx {
                        let c = str[idx]
                        if c.isNewline {
                                if !line.isEmpty{
                                        let len = line.count
                                        result.append(.insertText(line))
                                        result.append(.moveCursorForward(len))
                                        line = ""
                                }
                                result.append(.insertNewline)
                        } else {
                                line += String(c)
                        }
                        idx = str.index(after: idx)
                }
                if !line.isEmpty {
                        let len = line.count
                        result.append(.insertText(line))
                        result.append(.moveCursorForward(len))
                }
                /*for cmd in result {
                        NSLog("\(#file) command: \(cmd.description)")
                }*/
                return result
        }

        private func respond(escapeCodes codes: Array<MIEscapeCode>) {
                var exestr = ""
                for execode in codes {
                        exestr += execode.encode()
                }
                mStandardOutput.write(string: exestr)
        }
}

