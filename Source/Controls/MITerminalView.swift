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
        private var mFileInterface:     MIFileInterface? = nil
        private var mCursorTimer:       Timer? = nil

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
                        .setBackgroundColor(.black)
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

        public var fileInterface: MIFileInterface? {
                get      { return mFileInterface     }
                set(src) {
                        mFileInterface = src
                        if let fileif = src {
                                fileif.setReader(reader: { (_ str: String) in
                                        switch MIEscapeCode.decode(string: str) {
                                        case .success(let ecodes):
                                                Task { await self.execute(escapeCodes: ecodes) }
                                        case .failure(let err):
                                                NSLog("[Error] \(MIError.errorToString(error: err)) at \(#file)")
                                        }
                                })
                        }
                }
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
                case .insertString(let str):
                        commands.append(.insertText(str))
                /* key */
                case .carriageReturnKey:
                        commands.append(.insertNewline)
                case .arrowKey(let dir):
                        switch dir {
                        case .right:    commands.append(.moveCursorForward(1))
                        case .left:     commands.append(.moveCursorBackward(1))
                        case .up:       commands.append(.moveCursorUp(1))
                        case .down:     commands.append(.moveCursorDown(1))
                        @unknown default:
                                NSLog("[Error] Can not happen at \(#file)")
                        }
                case .moveCursorForward(let num):
                        commands.append(.moveCursorForward(num))
                case .moveCursorBackward(let num):
                        commands.append(.moveCursorBackward(num))
                case .tabKey:
                        commands.append(.insertTab)
                case .homeKey:
                        commands.append(.moveCursorToHome)
                case .makeCursorVisible(let flag):
                        commands.append(.setCursorVisible(flag))
                case .deleteKey, .backspaceKey:
                        commands.append(.removeBackward(1))
                case .blinkCursor(let flag):
                        commands.append(.blinkCursor(flag))
                default:
                        break
                /*
                 /* Key */
                 //case enterKey                         -> merged with newline
                 case functionKey(Int)
                 case formFeedKey
                 case helpKey
                 case homeKey
                 case insertKey
                 case menuKey
                 case newlineKey
                 case pageUpKey
                 case pageDownKey
                 case tabKey
                 case commandKey(Character)
                 case controlKey(Character)

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
                 case setColor(MITextColor)
                 */
                }

                if self.cursor.visible {
                        commands.append(.blinkCursor(true))
                }
                super.execute(commands: commands)
        }

        private func respond(escapeCodes codes: Array<MIEscapeCode>) {
                var exestr = ""
                for execode in codes {
                        exestr += execode.encode()
                }
                if let fileif = mFileInterface {
                        fileif.write(string: exestr)
                } else {
                        NSLog("[Error] No file interface at \(#file)")
                }
        }
}

