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
                mTerminalView.backgroundColor = MIColor.black

                let strg = mTerminalView.storage
                let idx  = strg.currentIndex
                let char = strg.character(at: idx)
                let attr = strg.attribute(at: idx)
                NSLog("VC: char=\"\(char)\", attr=\(attr.description)")

                // store message
                let commands: Array<MITextEditCommand> = [
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

