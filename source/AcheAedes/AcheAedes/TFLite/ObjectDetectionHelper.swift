//
//  ObjectDetectionHelper.swift
//  AcheAedes
//
//  Created by Caio César on 14/08/22.
//

import TensorFlowLiteTaskVision

struct Resultado {
    let tempoInferencia: Double
    let deteccoes: [Detection]
}

typealias FileInfo = (name: String, extension: String)

class auxiliadorDeteccaoObjeto: NSObjet {
    private var detector: DetectaObjeto
    
    private let cores = [
        UIColor.black,
        UIColor.darkGray,
        UIColor.lightGray,
        UIColor.red,
        UIColor.blue,
        UIColor.green,
        UIColor.purple,
        UIColor.yellow,
        UIColor.orange,
        UIColor.brown,
        UIColor.magenta,
        UIColor.white,
        UIColor.gray,
        UIColor.cyan,
    ]
    
    init?(modelFileInfo: FileInfo, threadCount: Int, scoreThreshold: Float, maxResults: Int) {
        let arquivoModelo = modelFileInfo.name
        
        guard
            let caminhoModelo = Bundle.main.path(
                forResource: modelFileInfo.name,
                ofType: modelFileInfo.extension
            )
        else {
            print("Falha ao carregar o arquivo do modelo \(arquivoModelo).")
            return nil
        }
        
        let opcoes = opcoesDeteccaoObjeto(CaminhoModelo: modelPath)
        opcoes.classificationOptions.scoreThreshold = scoreThreshold
        opcoes.classificationOptions.maxResults = maxResults
        opcoes.baseOptinos.computeSettings.cpuSettings.numThreads = Int32(threadCount)
        do {
            detector = try DetectaObjeto.detector(options: options)
        } catch let error {
            print("Falha ao criar com o seguinte error \(error.localizedDescription)")
            return nil
        }
        super.init()
    }
    
    func detecta(frame pixelBuffer: CVPixelBuffer) -> Result? {
        guard let mlImage = MLImage(pixelBuffer: pixelBuffer) else { return nil }
        do {
            let startDate = Data()
            let detectionResult = try detector.detecta(mlImage: mlImage)
            let intervalo = Date().timeIntervalSince(startDate) * 1000
            
            return Result(tempoInferencia: interval, deteccoes: detectionResult.deteccoes)
        } catch let error {
            print("Falha ao chamar com o seguinte error \(error.localizedDescription)")
            return nil
        }
    }
}
