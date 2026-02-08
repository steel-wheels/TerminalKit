//
//  ViewController.swift
//  UnitTest_macOS
//
//  Created by Tomoo Hamada on 2026/01/10.
//

import TerminalKit
import MultiUIKit
import Cocoa

class ViewController: NSViewController
{
        @IBOutlet var mTerminalView: MITerminalView!

        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
                let textcol = MIColor.green
                let backcol = MIColor.black
                mTerminalView.textColor       = textcol
                mTerminalView.backgroundColor = backcol

                // store message
                let commands: Array<MITextEditCommand> = [
                        .setTextColor(textcol),
                        .setBackgroundColor(backcol),
                        .insertText("Hello, World !!")
                ]
                mTerminalView.execute(commands: commands)
        }

        override var representedObject: Any? {
                didSet {
                // Update the view, if already loaded.
                }
        }


}

