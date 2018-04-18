//
//  ViewController.swift
//  calculadora
//
//  Created by Estudiantes on 14/4/18.
//  Copyright © 2018 Juan Carlos Marin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblComandos: UILabel!
    @IBOutlet weak var lblResultado: UILabel!
    var numeroActual:Int=0
    var resultadoAcumulado:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lblResultado.text="0"
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
        numeroActual = (numeroActual*10)+digito
        lblResultado.text = lblResultado.text! + String(digito)
        
    }
    func presionaComando (comando:String) {
        //lblComandos.text = lblComandos.text! + comando
        switch comando {
        case "+":
            resultadoAcumulado = suma(a:resultadoAcumulado,b:numeroActual)
        case "-":
            resultadoAcumulado = resta(a:resultadoAcumulado,b:numeroActual)
        case "*": suma(a:1,b:2)
        case "/": suma(a:1,b:2)
        default: "Nothing"
            
        }
        lblResultado.text = lblResultado.text! + comando
        //presionaComando(comando:(sender:UIButton).titleLabel!.text!)
    }
    
    @IBAction func clickNumero(_ sender: UIButton) {
        agregaDigito(digito:sender.tag)
    }
    
    @IBAction func clickComando(_ sender: UIButton) {
        presionaComando(comando:sender.titleLabel!.text!)
    }
    
    @IBAction func clickDone(_ sender: UIButton) {
        lblComandos.text = String(resultadoAcumulado)
        lblResultado.text=""
        resultadoAcumulado=0
        numeroActual=0
        
    }
    
}


