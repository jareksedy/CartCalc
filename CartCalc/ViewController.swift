//
//  ViewController.swift
//  CartCalc
//
//  Created by Ярослав on 12.07.2022.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {

    //MARK: - Properties
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    //MARK: - Outlets
    @IBOutlet var cameraView: UIView!
    @IBOutlet var scanResultLabel: UILabel!
    @IBOutlet var captureButton: UIButton!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideoCapture()
    }
    
    //MARK: - Actions
    
    @IBAction func captureButtonPressed(_ sender: Any) {
        captureSession.stopRunning()
        
        let renderer = UIGraphicsImageRenderer(size: cameraView.bounds.size)
        
        let image = renderer.image { ctx in
            view.drawHierarchy(in: cameraView.bounds, afterScreenUpdates: true)
        }
        
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        try? requestHandler.perform([request])

    }
    
    //MARK: - Private methods
    private func setupUI() {
        cameraView.backgroundColor = .systemBackground
        cameraView.layer.cornerRadius = 12.0
        cameraView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cameraView.clipsToBounds = true
    }
    
    private func setupVideoCapture() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .vga640x480
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to access camera device.")
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = cameraView.frame
        cameraView.layer.insertSublayer(previewLayer, at: 0)
        captureSession.startRunning()
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        processResults(recognizedStrings)
    }
    
    private func processResults(_ recognizedStrings: [String]) {
        print(recognizedStrings.count)
    }
}

