/*
 * @file MITerminalView.swift
 * @description Define MITerminalView class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import  MultiUIKit
#if os(OSX)
import  Cocoa
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)
import MultiDataKit

public class MITerminalView: MITextView
{
        private var mFileInterface      = MIFileInterface()

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
                        .setTextColor(MIColor.green),
                        .setBackgroundColor(MIColor.black)
                ]
                self.execute(commands: commands)

                self.insertionPointColor = MIColor.green
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
        }
}

