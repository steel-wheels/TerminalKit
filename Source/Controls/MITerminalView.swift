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
        private var mFileInterface              = MIFileInterface()
        private var mCursorTimer: Timer?        = nil

        deinit {
                if let timer = mCursorTimer {
                        timer.invalidate()
                        mCursorTimer = nil
                }
        }

        open override func setup(frame frm: CGRect) {
                super.setup(frame: frm)

                mFileInterface.setInputReader(readFunctionn: {
                        (_ str: String) -> Void in
                        switch MIEscapeCode.decode(string: str) {
                        case .success(let codes):
                                Task {
                                        await self.execute(escapeCodes: codes)
                                }
                        case .failure(let err):
                                NSLog("[Error] \(MIError.toString(error: err)) at \(#file)")
                        }
                })

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
                                let ecode: MIEscapeCode = .blinkCursor(!self.cursor.blink)
                                self.mFileInterface.inputWriteHandle.write(string: ecode.encode())
                        }
                }
                #endif

                self.cursor.visible = true
        }

        public var inputWriteHandle: FileHandle { get {
                return mFileInterface.inputWriteHandle
        }}

        public func setOutputReader(readFunctionn readf: @escaping MIFileInterface.ReadFunction) {
                mFileInterface.setOutputReader(readFunctionn: readf)
        }

        public func setErrorReader(readFunctionn readf: @escaping MIFileInterface.ReadFunction) {
                mFileInterface.setErrorReader(readFunctionn: readf)
        }

        private func execute(escapeCodes codes: Array<MIEscapeCode>) {
                for code in codes {
                        execute(escapeCode: code)
                }
        }

        private func execute(escapeCode code: MIEscapeCode) {
                var commands: Array<MITextEditCommand> = []
                switch code {
                case .insertString(let str):
                        commands.append(.insertText(str))
                case .moveCursorForward(let num):
                        commands.append(.moveCursorForward(num))
                case .moveCursorBackward(let num):
                        commands.append(.moveCursorBackward(num))
                case .moveCursorToHome:
                        commands.append(.moveCursorToHome)
                case .makeCursorVisible(let flag):
                        commands.append(.setCursorVisible(flag))
                case .blinkCursor(let flag):
                        commands.append(.blinkCursor(flag))
                default:
                        break
                }
                super.execute(commands: commands)
        }

        #if os(OSX)
        private func keydown(isKeyDown down: Bool, event evt: NSEvent) -> Bool {
                if down {
                        let codes = MIKeyCode.generate(event: evt)
                        for code in codes {
                                //NSLog("keydown: \(code.description)")
                                execute(keyCode: code)
                        }
                }
                return true // needless to continue
        }
        #endif

        private func execute(keyCode code: MIKeyCode) {
                let ecodes = generateCommandFromKeyInput(keyCode: code)

                /* dump ecode */
                var keynum = 0
                for ecode in ecodes {
                        NSLog("keycode: \(keynum) \(ecode.description())")
                        keynum += 1
                }

                /* put code into file stream */
                var codestr = ""
                for ecode in ecodes {
                        codestr += ecode.encode()
                }
                mFileInterface.inputWriteHandle.write(string: codestr)
        }

        private func generateCommandFromKeyInput(keyCode code: MIKeyCode) -> Array<MIEscapeCode> {
                let encoding: String.Encoding = .utf8

                var result: Array<MIEscapeCode> = []

                let curvis = super.cursor.visible
                if curvis {
                        result.append(.makeCursorVisible(false))
                }

                switch code {
                case .string(let str):
                        let len = str.lengthOfBytes(using: encoding)
                        result.append(.insertString(str))
                        result.append(.moveCursorForward(len))
                case .command(let key):
                        let cmds = generateCommandFromCommandKeyInput(commandKey: key)
                        result.append(contentsOf: cmds)
                case .control(let key):
                        let cmds = generateCommandFromControlKeyInput(controlKey: key)
                        result.append(contentsOf: cmds)
                case .funcCode(let num):
                        let cmds = generateCommandFromFunctionKeyInput(functionNum: num)
                        result.append(contentsOf: cmds)
                case .deleteCode:
                        result.append(.moveCursorBackward(1))
                        result.append(.eraceFromCursorWithLength(1))
                case .carriageReturnCode, .newlineCode:
                        result.append(.insertString("\n"))
                        result.append(.moveCursorForward(1))
                case .leftArrowCode:
                        result.append(.moveCursorBackward(1))
                case .rightArrowCode:
                        result.append(.moveCursorForward(1))
                default:
                        break
                /*
                 case backtabCode
                 case beginCode
                 case breakCode
                 case clearDisplayCode
                 case clearLineCode
                 case deleteCharacterCode
                 case deleteForwardCode
                 case deleteLineCode
                 case downArrowCode
                 case endCode
                 case enterCode
                 case executeCode
                 case findCode
                 case formfeedCode
                 case helpCode
                 case homeCode
                 case insertCode
                 case insertCharacterCode
                 case insertLineCode
                 case leftArrowCode
                 case lineSeparatorCode
                 case menuCode
                 case menuSwitchCode
                 case newlineCode
                 case nextCode
                 case pageDownCode
                 case pageUpCode
                 case paragraphSeparatorCode
                 case pauseCode
                 case prevCode
                 case printCode
                 case printScreenCode
                 case redoCode
                 case resetCode
                 case scrollLockCode
                 case selectCode
                 case stopCode
                 case sysReqCode
                 case systemCode
                 case tabCode
                 case undoCode
                 case upArrowCode
                 case userCode
                 */
                }
                if curvis {
                        result.append(.makeCursorVisible(true))
                }
                return result
        }

        private func generateCommandFromCommandKeyInput(commandKey key: String) -> Array<MIEscapeCode> {
                return []
        }

        private func generateCommandFromControlKeyInput(controlKey key: Character) -> Array<MIEscapeCode> {
                return []
        }

        private func generateCommandFromFunctionKeyInput(functionNum num: Int) -> Array<MIEscapeCode> {
                return []
        }
}

