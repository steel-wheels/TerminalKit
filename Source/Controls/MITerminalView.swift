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
import  MultiUIKit
import MultiDataKit

public class MITerminalView: MITextView
{
        private var mFileInterface      = MIFileInterface()
        private var mCursor             = MICursor()
        private var mTimer:             Timer?    = nil

        deinit {
                if let timer = mTimer {
                        timer.invalidate()
                        mTimer = nil
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

                /*
                mTimer  = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true, block: {
                        (_ timer: Timer) -> Void in self.blink()
                })*/
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
                case .moveCursorToHome:
                        commands.append(.moveCursorToHome)
                default:
                        break
                }
                super.execute(commands: commands)
        }

        private func blink() {
                if mCursor.isVisible {
                        execute(escapeCodes: mCursor.generateCode())
                }
        }
}

