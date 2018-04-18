//
//  ViewController.swift
//  calculadora
//
//  Created by Estudiantes on 14/4/18.
//  Copyright © 2018 Juan Carlos Marin. All rights reserved.
//

import UIKit
public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var count: Int {
        return array.count
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public func peek() -> T? {
        return array.last
    }
}
class ViewController: UIViewController {
    
    @IBOutlet weak var lblComandos: UILabel!
    @IBOutlet weak var lblResultado: UILabel!
    var numeroActual:Int=0
    var operadorActual:String=""
    var resultadoAcumulado:Int=0
    var expresionInFix:String=""
    var digitandoNumero:Bool=false
    var digitandoOperador:Bool=false
    var negativoNumero:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lblResultado.text=""
        lblComandos.text=""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func suma(a:Int,b:Int)-> Int{
        return (a+b)
    }
    func resta(a:Int,b:Int)-> Int{
        return (a-b)
    }
    func agregaDigito(digito:Int){
        if (digito == 0 && numeroActual==0){
            return
        }
        digitandoNumero = true
        digitandoOperador = false
        operadorActual = ""
        if numeroActual >= 0{
           numeroActual = (numeroActual*10)+digito
        }else{
            numeroActual = (numeroActual*10)-digito
        }
        
        if negativoNumero{
            numeroActual *= -1
            negativoNumero = false
        }
        lblResultado.text = expresionInFix + String(numeroActual)
        
    }
    func presionaComando (operador:String) {
        digitandoNumero = false
        if (expresionInFix != "" || numeroActual != 0){
            expresionInFix += String(numeroActual)
        }
        if digitandoOperador {
            if (operador != "-" || (operador == "-" && operador != operadorActual)){
               return
            }
            else{
                negativoNumero = true
            }
        }else{
            if (operador != "-" && expresionInFix == ""){
                return
            }
            if (operador == "-" && expresionInFix == ""){
                negativoNumero = true
                lblResultado.text = expresionInFix + operador
                return
            }
        }
        digitandoOperador = true
        operadorActual = operador
        //lblComandos.text = lblComandos.text! + comando
        switch operador {
        case "+":
            resultadoAcumulado = suma(a:resultadoAcumulado,b:numeroActual)
        case "-":
            resultadoAcumulado = resta(a:resultadoAcumulado,b:numeroActual)
        case "*": suma(a:1,b:2)
        case "/": suma(a:1,b:2)
        default: "Nothing"
            
        }
        
        numeroActual = 0
        expresionInFix += operador
        lblResultado.text = expresionInFix
        //presionaComando(comando:(sender:UIButton).titleLabel!.text!)
    }
    
    @IBAction func clickNumero(_ sender: UIButton) {
        agregaDigito(digito:sender.tag)
        
    }
    
    @IBAction func clickOperador(_ sender: UIButton) {
        presionaComando(operador:sender.titleLabel!.text!)
    }
    
    
    @IBAction func clickDone(_ sender: UIButton) {
        lblComandos.text = String(resultadoAcumulado)
        lblResultado.text=""
        resultadoAcumulado=0
        numeroActual=0
        
    }
    
}


