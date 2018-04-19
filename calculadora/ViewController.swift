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
    
    public mutating func clear(){
        array.removeAll()
    }
}
extension Stack: CustomStringConvertible {
    public var description: String {
        let stackElements = array.map { "\($0)" }.joined(separator: "")
        //
        return stackElements
    }
}
class ViewController: UIViewController {
    
    @IBOutlet weak var lblComandos: UILabel!
    @IBOutlet weak var lblResultado: UILabel!
    var numeroActual:Int=0
    var operadorActual:String=""
    var resultadoAcumulado:Int=0
    var expresionInFix = Stack<String>()//String=""
    var pilaOperadores = Stack<String>()
    var expresonPostFix = [String]()
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
    
    func precedencia(_ operador:String)-> Int{
        switch operador{
        case "+","-": return 1
        case "*","/": return 2
        default: return 0
        }

    }
    func mayorPrecedencia(_ operador:String, _ comparador:String) -> Bool {
        if precedencia(operador)>precedencia(comparador){
            return true
        }else{
            return false
        }
    }
    func generarPostFix(){
        for valor in expresionInFix.array{
            switch valor{
            case "+","-","*","/":
                if pilaOperadores.isEmpty{
                    pilaOperadores.push(valor)
                }else{
                    if mayorPrecedencia(valor, pilaOperadores.peek()!){
                        pilaOperadores.push(valor)
                    }else{
                        
                    }
                }
            default:
                expresonPostFix.append(valor)
            }
        }
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
        lblResultado.text = expresionInFix.description + String(numeroActual)
        
    }
    func presionaComando (operador:String) {
        digitandoNumero = false
        if (numeroActual != 0){
            expresionInFix.push(String(numeroActual)) //+= String(numeroActual)
        }
        if digitandoOperador {
            if (operador != "-" || (operador == "-" && operador == operadorActual)){
                if operador != "-"{
                    expresionInFix.pop()//.removeLast()
                    expresionInFix.push(operador) //+= operador
                    lblResultado.text = expresionInFix.description
                    operadorActual = operador
                    negativoNumero=false
                }
                return
            }
            else{
                negativoNumero = true
                lblResultado.text = expresionInFix.description + operador
                return
            }
        }else{
            if (operador != "-" && expresionInFix.isEmpty){
                return
            }
            if (operador == "-" && expresionInFix.isEmpty){
                negativoNumero = true
                lblResultado.text = expresionInFix.description + operador
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
        expresionInFix.push(operador) //+= operador
        lblResultado.text = expresionInFix.description
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


