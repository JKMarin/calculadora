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
extension Float {
    var cleanValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 8
        
        //self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
        return  formatter.string(from: NSNumber(value:self))!
    }
}
class ViewController: UIViewController {
    
    @IBOutlet weak var cajaComandos: UILabel!
    @IBOutlet weak var cajaResultado: UILabel!
    
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
        cajaComandos.text=""
        cajaResultado.text=""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func precedencia(_ operador:String)-> Int{
        switch operador{
        case "+","-": return 1
        case "x","/": return 2
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
    func generarPostFix(_ ultimoValor:Int){
        expresonPostFix.removeAll()
        for valor in expresionInFix.array{
            switch valor{
            case "+","-","x","/":
                if pilaOperadores.isEmpty{
                    pilaOperadores.push(valor)
                }else{
                    if mayorPrecedencia(valor, pilaOperadores.peek()!){
                        pilaOperadores.push(valor)
                    }else{
                        repeat{
                            expresonPostFix.append(pilaOperadores.pop()!)
                        }while( !pilaOperadores.isEmpty &&
                            !mayorPrecedencia(valor,pilaOperadores.peek()!))
                        pilaOperadores.push(valor)
                    }
                }
            default:
                expresonPostFix.append(valor)
            }
        }
        if ultimoValor != 0 {
            expresonPostFix.append(String(ultimoValor))
        }
        while !pilaOperadores.isEmpty {
            expresonPostFix.append(pilaOperadores.pop()!)
        }
    }
    
    func evaluarExpresion(_ ultimoValor:Int){
        var pilaValores=Stack<Float>()
        var operando1:Float=0
        var operando2:Float=0
        var resultado:Float=0
        
        generarPostFix(ultimoValor)
        for item in expresonPostFix{
            switch item{
            case "+","-","x","/":
                operando2=pilaValores.pop()!
                operando1=pilaValores.pop()!
            default:
                pilaValores.push(Float(item)!)
            }
            switch item{
            case "+": resultado = operando1 + operando2
                  pilaValores.push(resultado)
            case "-":resultado = operando1 - operando2
                pilaValores.push(resultado)
            case "x":resultado = operando1 * operando2
                pilaValores.push(resultado)
            case "/":resultado = operando1 / operando2
                pilaValores.push(resultado)
                
            default: break
                
            }
            
        }
        if pilaValores.isEmpty{
            cajaResultado.text=""
        }else{
            cajaResultado.text=pilaValores.pop()!.cleanValue//expresonPostFix.joined()
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
        cajaComandos.text = expresionInFix.description + String(numeroActual)
        evaluarExpresion(numeroActual)
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
                    cajaComandos.text = expresionInFix.description
                    operadorActual = operador
                    negativoNumero=false
                }
                return
            }
            else{
                negativoNumero = true
                cajaComandos.text = expresionInFix.description + operador
                return
            }
        }else{
            if (operador != "-" && expresionInFix.isEmpty){
                return
            }
            if (operador == "-" && expresionInFix.isEmpty){
                negativoNumero = true
                cajaComandos.text = expresionInFix.description + operador
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
        case "X": suma(a:1,b:2)
        case "/": suma(a:1,b:2)
        default: "Nothing"
            
        }
        evaluarExpresion(0)
        numeroActual = 0
        expresionInFix.push(operador) //+= operador
        cajaComandos.text = expresionInFix.description
        //presionaComando(comando:(sender:UIButton).titleLabel!.text!)
    }
    
    @IBAction func clickNumero(_ sender: UIButton) {
        agregaDigito(digito:sender.tag)
        
    }
    
    @IBAction func clickOperador(_ sender: UIButton) {
        presionaComando(operador:sender.titleLabel!.text!)
    }
    
    
    @IBAction func clickDone(_ sender: UIButton) {
        //lblComandos.text = String(resultadoAcumulado)
        cajaComandos.text=""
        resultadoAcumulado=0
        numeroActual=0
        
    }
    
}


