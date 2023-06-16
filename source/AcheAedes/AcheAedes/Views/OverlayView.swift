//
//  OverlayView.swift
//  AcheAedes
//
//  Created by Caio César on 14/08/22.
//

import UIKit

struct OverlayObjeto {
    let nome: String
    let bordaDetecta: CGRect
    let nomeTamanhoString: CGSize
    let cor: UIColor
    let fonte: UIFont
}

class CamadaOverlay: UIView {
    var overlaysObjeto: [OverlayObjeto] = []
    private let radioCanto: CGFloat = 10.0
    private let stringBgAlpha: CGFloat = 0.7
    private let linhaLargura: CGFloat = 3
    private let stringCorFonte = UIColor.white
    private let stringEspacoHorizontal: CGFloat = 13.0
    private let stringEspacoVertical: CGFloat = 7.0

    override func draw(_ rect: CGRect) {
        for overlayObjeto in overlaysObjeto {
            criarBordas(of: overlayObjeto)
            criarBackground(of: overlayObjeto)
            criarNome(of: overlayObjeto)
        }
    }
    
    func criarBordas(of overlayObjeto: OverlayObjeto) {
    let caminho = UIBezierPath(rect: overlayObjeto.bordaDetecta)
    caminho.lineWidth = linhaLargura
    overlayObjeto.cor.setStroke()
    
    caminho.stroke()
}
    
    func criarBackground(of overlayObjeto: OverlayObjeto) {
        let stringBgDetecta = CGRect(x: overlayObjeto.bordaDetecta.origin.x, y: overlayObjeto.bordaDetecta.origin.y , width: 2 * stringEspacoHorizontal + overlayObjeto.nomeTamanhoString.width, height: 2 * stringEspacoVertical + overlayObjeto.nomeTamanhoString.height)
        
        let stringBgCaminho = UIBezierPath(rect: stringBgDetecta)
        overlayObjeto.cor.withAlphaComponent(stringBgAlpha).setFill()
        stringBgCaminho.fill()
    }
    
    func criarNome(of overlayObjeto: OverlayObjeto) {
        let stringDetecta = CGRect(x: overlayObjeto.bordaDetecta.origin.x + stringEspacoHorizontal, y: overlayObjeto.bordaDetecta.origin.y + stringEspacoVertical, width: overlayObjeto.nomeTamanhoString.width, height: overlayObjeto.nomeTamanhoString.height)
        
        let stringAtribuida = NSAttributedString(string: overlayObjeto.nome, attributes: [NSAttributedString.Key.foregroundColor : stringCorFonte, NSAttributedString.Key.font : overlayObjeto.fonte])
        stringAtribuida.draw(in: stringDetecta)
    }

}

