//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Zach Zeleznick on 9/20/16.
//  Copyright © 2016 zzeleznick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var w: CGFloat!
    var h: CGFloat!
    var resultLabel = UILabel()
    var accumulator = 0.0
    var decimalMode = false
    var decimal: String = ""
    private var pending: PendingOpInfo?
    var userIsTyping = false
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    var operations: Dictionary<String, Operation> = [
        "C" : Operation.Constant(0.0),
        "+/-": Operation.UnaryOperation({ -$0 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "*" : Operation.BinaryOperation({ $0 * $1 }),
        "/" : Operation.BinaryOperation({ $0 / $1 }),
        "=" : Operation.Equals
    ]
    struct PendingOpInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    func updateSomeDataStructure(_ content: String) {}
    
    func updateResultLabel() {
        var result: String
        if decimalMode {
            result = String(Int(accumulator)) + "." + decimal
        }else {
            if accumulator == Double(Int(accumulator)) {
                result = String(Int(accumulator))
            } else {
                decimalMode = true
                result = String(accumulator)
            }
        }
        if result.characters.count <= 7 {
            resultLabel.text = result
        }
    }
    
    func numberPressed(_ sender: CustomButton) {
        // 1,2,3,4,5,6,7,8,9
        guard Int(sender.content) != nil else { return }
        let input = Double(sender.content)!
        if decimalMode {
            decimal = decimal + String(Int(input))
            updateResultLabel()
        } else {
            if userIsTyping {
                accumulator = accumulator*10 + input
                updateResultLabel()
            } else {
                accumulator = input
                updateResultLabel()
            }
        }
        userIsTyping = true
    }
    
    func operatorPressed(_ sender: CustomButton) {
        // "/", "*", "-", "+", "="] others = ["C", "+/-", "%"]
        userIsTyping = false
        if decimalMode {
            accumulator = Double(resultLabel.text!)!
            decimalMode = false
            decimal = ""
        }
        if let operation = operations[sender.content] {
            switch operation{
            case .Constant:
                pending = nil
                accumulator = 0
                decimalMode = false
                decimal = ""
            case .UnaryOperation(let neg):
                accumulator = neg(accumulator)
            case .BinaryOperation(let function):
                if pending != nil {
                    accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
                }
                pending = PendingOpInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                if pending != nil {
                    accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
                    pending = nil
                }
            }
        }
        updateResultLabel()
    }
    
    func buttonPressed(_ sender: CustomButton) {
        // '0' , '.'
        switch sender.content {
        case "0":
            numberPressed(sender)
        case ".":
            if !decimalMode {
                resultLabel.text = resultLabel.text! + "."
                decimalMode = true
            }
        default:
            print("unrecognized button ", sender.content)
        }
    }
    
    // IMPORTANT: Do NOT change any of the code below.
    //            We will be using these buttons to run autograded tests.
    func makeButtons() {
        // MARK: Adds buttons
        let digits = (1..<10).map({
            return String($0)
        })
        let operators = ["/", "*", "-", "+", "="]
        let others = ["C", "+/-", "%"]
        let special = ["0", "."]
        
        let displayContainer = UIView()
        view.addUIElement(displayContainer, frame: CGRect(x: 0, y: 0, width: w, height: 160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }
        displayContainer.addUIElement(resultLabel, text: "0", frame: CGRect(x: 70, y: 70, width: w-70, height: 90)) {
            element in
            guard let label = element as? UILabel else { return }
            label.textColor = UIColor.white
            label.font = UIFont(name: label.font.fontName, size: 60)
            label.textAlignment = NSTextAlignment.right
        }
        
        let calcContainer = UIView()
        view.addUIElement(calcContainer, frame: CGRect(x: 0, y: 160, width: w, height: h-160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }
        
        let margin: CGFloat = 1.0
        let buttonWidth: CGFloat = w / 4.0
        let buttonHeight: CGFloat = 100.0
        
        // MARK: Top Row
        for (i, el) in others.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
                                       frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                                        guard let button = element as? UIButton else { return }
                                        button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Second Row 3x3
        for (i, digit) in digits.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: digit), text: digit,
                                       frame: CGRect(x: x, y: y+101.0, width: buttonWidth, height: buttonHeight)) { element in
                                        guard let button = element as? UIButton else { return }
                                        button.addTarget(self, action: #selector(numberPressed), for: .touchUpInside)
            }
        }
        // MARK: Vertical Column of Operators
        for (i, el) in operators.enumerated() {
            let x = (CGFloat(3) + 1.0) * margin + (CGFloat(3) * buttonWidth)
            let y = (CGFloat(i) + 1.0) * margin + (CGFloat(i) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
                                       frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                                        guard let button = element as? UIButton else { return }
                                        button.backgroundColor = UIColor.orange
                                        button.setTitleColor(UIColor.white, for: .normal)
                                        button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Last Row for big 0 and .
        for (i, el) in special.enumerated() {
            let myWidth = buttonWidth * (CGFloat((i+1)%2) + 1.0) + margin * (CGFloat((i+1)%2))
            let x = (CGFloat(2*i) + 1.0) * margin + buttonWidth * (CGFloat(i*2))
            calcContainer.addUIElement(CustomButton(content: el), text: el,
                                       frame: CGRect(x: x, y: 405, width: myWidth, height: buttonHeight)) { element in
                                        guard let button = element as? UIButton else { return }
                                        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        w = view.bounds.size.width
        h = view.bounds.size.height
        navigationItem.title = "Calculator"
        resultLabel.accessibilityValue = "resultLabel"
        makeButtons()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

