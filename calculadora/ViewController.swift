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
        
        return stackElements
    }
}
extension String{
    var cleanFormat: String{
        return self
    }
}
extension Double {
    var cleanFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 8
        
        return  formatter.string(from: NSNumber(value:self))!
    }
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
      
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
        cajaComandos.text="0"
        cajaResultado.text=""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func precedencia(_ operador:String)-> Int{
        switch operador{
        case "+","-": return 1
        case "x","÷": return 2
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
            case "+","-","x","÷":
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
    
    func evaluarExpresion(_ ultimoValor:Int) -> Double?{
        var pilaValores=Stack<Double>()
        var operando1:Double=0
        var operando2:Double=0
        var resultado:Double=0
        
        generarPostFix(ultimoValor)
        for item in expresonPostFix{
            switch item{
            case "+","-","x","÷":
                operando2=pilaValores.pop()!
                operando1=pilaValores.pop()!
            default:
                pilaValores.push(Double(item)!)
            }
            switch item{
            case "+": resultado = operando1 + operando2
                  pilaValores.push(resultado)
            case "-":resultado = operando1 - operando2
                pilaValores.push(resultado)
            case "x":resultado = operando1 * operando2
                pilaValores.push(resultado)
            case "÷":resultado = operando1 / operando2
                pilaValores.push(resultado)
                
            default: break
              	
            }
            
        }
        if pilaValores.isEmpty{
            return nil
        }else{
            return pilaValores.pop()!//expresonPostFix.joined()
        }
    }
    
    func agregaDigito(digito:Int){
        if operadorActual == "="{
            operadorActual=""
            expresionInFix.clear()
        }
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
        let resultado = evaluarExpresion(numeroActual)
        if resultado == nil{
            cajaResultado.text = ""
        }else{
            cajaResultado.text = resultado?.cleanFormat
        }
    }
    func presionaComando (operador:String) {
        if operadorActual == "="{
            operadorActual=""
        }
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
        
        
        let resultado = evaluarExpresion(0)
        if resultado == nil{
            cajaResultado.text = ""
        }else{
            cajaResultado.text = resultado?.cleanFormat
        }
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
    
    @IBAction func clickIgual(_ sender: UIButton) {
        var tope:String=""
        if numeroActual != 0{
            expresionInFix.push(String(numeroActual))
        }else{
            tope=expresionInFix.peek()!
            switch tope{
            case "+","-","x","÷":expresionInFix.pop()
            default:break
            }
        }
        let resultado = evaluarExpresion(0)
        expresionInFix.clear()
        if resultado == nil{
            cajaComandos.text = "0"
        }else{
            cajaComandos.text = resultado?.cleanFormat
            let resultadoStr = resultado?.cleanValue
            expresionInFix.push(resultadoStr!)
        }
        cajaResultado.text=""
        numeroActual=0
        digitandoNumero=false
        digitandoOperador=false
        operadorActual="="
        negativoNumero=false
    }
    
    @IBAction func clickBorrar(_ sender: UIButton) {
        expresionInFix.clear()
        cajaComandos.text = "0"
        cajaResultado.text=""
        numeroActual=0
        digitandoNumero=false
        digitandoOperador=false
        operadorActual=""
        negativoNumero=false
    }
    
}


