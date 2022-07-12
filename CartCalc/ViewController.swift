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
}

