//
//  ViewController.swift
//  QRCodeReader
//
//  Created by 今枝 稔晴 on 2018/05/23.
//  Copyright © 2018年 iXIT Corporation. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var detectiveView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 入力（背面カメラ）
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            do {
                let videoInput = try AVCaptureDeviceInput.init(device: videoDevice)
                captureSession.addInput(videoInput)
                // 出力（メタデータ）
                let metadataOutput = AVCaptureMetadataOutput()
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureSession.addOutput(metadataOutput)
                
                // 読み取るオブジェクトの種類
                metadataOutput.metadataObjectTypes = [.qr]
                
                // プレビュー
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = view.frame
                previewLayer.videoGravity = .resizeAspect
                view.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer

                // 検出エリアの指定
                detectiveView.layer.borderWidth = 4
                detectiveView.layer.borderColor = UIColor.red.cgColor
                view.addSubview(detectiveView)
                // 全体に対する比率（0.0 ~ 1.0）で指定
                let width: CGFloat = 0.5
                let height: CGFloat = view.frame.width * width / view.frame.height
                let x: CGFloat = (1-width)/2
                let y: CGFloat = (1-height)/2
                // 座標に注意！！
                // 参考記事：https://qiita.com/tomosooon/items/9cb7bf161a9f76f3199b
                metadataOutput.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
                detectiveView.frame = CGRect(x: view.frame.size.width * x, y: view.frame.size.height * y, width: view.frame.size.width * width, height: view.frame.size.height * height)
                
                // セッションスタート
                DispatchQueue.global().async {[unowned self] in
                    self.captureSession.startRunning()
                }

            } catch {
                print("Error")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 複数のメタデータを検出できる
        for metadata in metadataObjects {
            
            switch metadata.type {
            case .qr:
                // 検出位置をマーク
                if  let data = metadata as? AVMetadataMachineReadableCodeObject,
                    let stringValue = data.stringValue {
                    let ac = UIAlertController(title: "QR読み込み成功", message: stringValue, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default) {[unowned self] _ in
                        DispatchQueue.global().async {[unowned self] in
                            self.captureSession.startRunning()
                        }
                    })
                    self.captureSession.stopRunning()
                    self.present(ac, animated: true)
                }
                break
            default:
                break
            }
        }
    }
}

