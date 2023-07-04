//
//  ScannerViewController.swift
//  PickiTTicket
//
//  Created by Devin King on 1/14/23.
//
    import AVFoundation
    import UIKit
    import SCLAlertView

protocol ScannerViewControllerDelegate {
    func didScanBarcode(_ barcode: String)
}
  

 
    class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate  {
        
        
        let barcodeManager = DeviceBarcodeManager()
        
        var delegate: ScannerViewControllerDelegate?
      
        
      
        
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = UIColor.black
            view.layer.frame = CGRect(x: 0, y: 0, width: 400, height: 120)
            let secondView = UIView()
            view.addSubview(secondView)
            secondView.backgroundColor = .white
            
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce,.code128,.code39,  .code93,  .dataMatrix]
            } else {
                failed()
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
         
            DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
        }

        func failed() {
          
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            captureSession = nil
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if (captureSession?.isRunning == false) {
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in self?.captureSession.startRunning() }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()

            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                found(code: stringValue)
                print(stringValue)
            }
            
            dismiss(animated: true)
        }

        func found(code: String) {
          

            let deviceCode = code.dropFirst(2)
            
              let newDeviceBarcode = String(format: String(deviceCode))
            //print(code)
            delegate?.didScanBarcode(newDeviceBarcode)
            _ = self.navigationController?.popViewController(animated: true)
        
          
          
            
           
       
        
                
        
        }

        override var prefersStatusBarHidden: Bool {
            return true
        }

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
    }

