//
//  ViewController.swift
//  UnitTest_macOS
//
//  Created by Tomoo Hamada on 2026/01/10.
//

import TerminalKit
import ShellKit
import MultiUIKit
import MultiDataKit
import Cocoa

class ViewController: NSViewController
{
        @IBOutlet var mTerminalView: MITerminalView!
        private   var mTerminalToShellPipe:     Pipe?    = nil
        private   var mShellToTerminalPipe:     Pipe?    = nil
        private   var mErrorPile:               Pipe?    = nil

        override func viewDidLoad() {
                super.viewDidLoad()

                let terminalToShellPipe = Pipe()
                let shellToTerminalPipe = Pipe()
                let errorPipe           = Pipe()
                mTerminalToShellPipe    = terminalToShellPipe
                mShellToTerminalPipe    = shellToTerminalPipe
                mErrorPile              = errorPipe

                mTerminalView.standardInput  = shellToTerminalPipe.fileHandleForReading
                mTerminalView.standardOutput = terminalToShellPipe.fileHandleForWriting
                mTerminalView.standardError  = errorPipe.fileHandleForWriting

                // Do any additional setup after loading the view.
                let textcol = MIColor.green
                let backcol = MIColor.black
                mTerminalView.textColor       = textcol
                mTerminalView.backgroundColor = backcol

                // connect standart output
                terminalToShellPipe.fileHandleForReading.setReader(reader: {
                        (_ str: String) -> Void in
                        switch MIEscapeCode.decode(string: str) {
                        case .success(let ecodes):
                                for ecode in ecodes {
                                        NSLog("[stdout] \(ecode.description())")
                                }
                        case .failure(let err):
                                let msg = MIError.toString(error: err)
                                NSLog("[output error] \(msg)")
                        }
                })
                // connect standard error
                errorPipe.fileHandleForWriting.setReader(reader: {
                        (_ str: String) -> Void in NSLog("[stderr] \(str)")
                })
                // store initial message
                let commands0: Array<MITextEditCommand> = [
                        .setTextColor(textcol),
                        .setBackgroundColor(backcol),
                        .insertText(" ")
                ]
                mTerminalView.execute(commands: commands0)

                // test
                let str0 = "Hello, world !!"
                let str1 = "Good morning"
                let commands1: Array<MITextEditCommand> = [
                        .blinkCursor(false),
                        .insertText(str0),
                        .moveCursorForward(str0.lengthOfBytes(using: .utf8)),
                        .insertNewline,
                        //.insertText(str1),
                        //.moveCursorForward(str1.lengthOfBytes(using: .utf8))
                        .blinkCursor(true)
                ]
                mTerminalView.execute(commands: commands1)
        }

        override var representedObject: Any? {
                didSet {
                // Update the view, if already loaded.
                }
        }


}

