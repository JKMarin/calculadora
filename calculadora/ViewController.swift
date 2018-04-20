//
//  ViewController.swift
//  calculadora
//
//  Created by Estudiantes on 14/4/18.
//  Copyright © 2018 Juan Carlos Marin. All rights reserved.
//

import UIKit
public struct Stack<T> {
    //Estructura de Pila(Stack) utililizada para el control de precedencia de operadores
    //tomado y adaptado de https://github.com/raywenderlich/swift-algorithm-club
    //
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
    //Extension de la clase para convertir el arreglo en un string https://github.com/raywenderlich/swift-algorithm-club
    public var description: String {
        let stackElements = array.map { "\($0)" }.joined(separator: "")
        
        return stackElements
    }
}

extension Double {
    //Se extiende la Clase Double para darle formato de miles y decimales para mostarlo en pantalla
    var cleanFormat: String {//formato miles
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 8
        
        return  formatter.string(from: NSNumber(value:self))!
    }
    var cleanValue: String {//formato con o sin decimales segun el valor
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
      
    }

}

class ViewController: UIViewController {
    //Referencias a los componentes de etiquetas
    @IBOutlet weak var cajaComandos: UILabel!
    @IBOutlet weak var cajaResultado: UILabel!
    
    //Declaracion de variables globales
    var numeroActual:Int = 0                //Valor de numero que se forma a usar 0..9
    var operadorActual:String = ""          //Valor del ultimo operador digitado
    var expresionInFix = Stack<String>()    //Estructura de pila que almacena la expresion en "infix"
    var expresonPostFix = [String]()        //Arreglo para almacenar expresion en "postfix"
    var digitandoNumero:Bool = false        //Indica si se esta digitando numeros
    var digitandoOperador:Bool = false      //Indica si se esta digitanto operadores
    var negativoNumero:Bool = false         //Indica si se digita un "-" luego de algun operador para manejar negativos
    
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
        //Define el valor de precedencia de operadores
        switch operador{
        case "+","-": return 1
        case "x","÷": return 2
        default: return 0
        }
    }
    
    func mayorPrecedencia(_ operador:String, _ comparador:String) -> Bool {
        //Compara y define si un operador tiene mayor precedecia que otro
        if precedencia(operador)>precedencia(comparador){
            return true
        }else{
            return false
        }
    }
    
    func generarPostFix(_ ultimoValor:Int){
        //Transforma una expresion en "infix" 1+2x3 a "postfix" 1,2,3,x,+
        //Algoritmo adaptado de la pagina http://www.paulgriffiths.net/program/c/calc1.php
        
        var pilaOperadores = Stack<String>()    //Estructura de pila que almacena operadores
        
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
    
    func evaluarExpresion(_ ultimoValor:Int) -> Double? {
        //Evalua la expresion en "postfix" y retorna el resultado de la misma
        //Algoritmo adaptado de la pagina http://www.paulgriffiths.net/program/c/calc1.php
        
        var pilaValores = Stack<Double>()
        var operando1:Double = 0
        var operando2:Double = 0
        var resultado:Double = 0
        
        generarPostFix(ultimoValor)
        for item in expresonPostFix{
            switch item{
                case "+","-","x","÷":
                    operando2 = pilaValores.pop()!
                    operando1 = pilaValores.pop()!
                default:
                    pilaValores.push(Double(item)!)
            }
            switch item{    //Ejecuta las operaciones
                case "+":
                    resultado = operando1 + operando2
                    pilaValores.push(resultado)
                case "-":
                    resultado = operando1 - operando2
                    pilaValores.push(resultado)
                case "x":
                    resultado = operando1 * operando2
                    pilaValores.push(resultado)
                case "÷":
                    resultado = operando1 / operando2
                    pilaValores.push(resultado)
                
                default: break
              	
            }
            
        }
        if pilaValores.isEmpty{
            return nil
        }else{
            return pilaValores.pop()!
        }
    }
    
    func agregaDigito(digito:Int){
        //Maneja los eventos de presionar numeros del 0..9
        
        if operadorActual == "="{
            operadorActual = ""
            expresionInFix.clear()
        }
        if (digito == 0 && numeroActual==0){
            return
        }
        digitandoNumero = true
        digitandoOperador = false
        operadorActual = ""
        if numeroActual >= 0{
           numeroActual = (numeroActual * 10) + digito
        }else{
            numeroActual = (numeroActual * 10) - digito
        }
        
        if negativoNumero{ //Controlando los negativos
            numeroActual *= -1
            negativoNumero = false
        }
        
        //Muestra en la etiqueta la expresion completa
        //Evalua y retorna el resultado
        cajaComandos.text = expresionInFix.description + String(numeroActual)
        let resultado = evaluarExpresion(numeroActual)
        if resultado == nil{
            cajaResultado.text = ""
        }else{
            cajaResultado.text = resultado?.cleanFormat
        }
    }
    
    func presionaComando (operador:String) {
        //Maneja los eventos al presionar los operadores "+","-","x","÷"
        
        if operadorActual == "="{
            operadorActual=""
        }
        digitandoNumero = false
        if (numeroActual != 0){
            expresionInFix.push(String(numeroActual))
        }
        if digitandoOperador {
            //Ya se ha presionado un operador antes
            //O se cambia el operador o es un negativo
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
            //se procesa el signo negativo
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
        
        //Se procesa el operador
        //Muestra en la etiqueta la expresion completa
        //Evalua y retorna el resultado
         let resultado = evaluarExpresion(0)
        if resultado == nil{
            cajaResultado.text = ""
        }else{
            cajaResultado.text = resultado?.cleanFormat
        }
        numeroActual = 0
        expresionInFix.push(operador)
        cajaComandos.text = expresionInFix.description
        
    }
    
    //Eventos de interfaz de usuario para los botones
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


