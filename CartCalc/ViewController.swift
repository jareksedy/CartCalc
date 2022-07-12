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
    var scanResults: [String] = []
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    //MARK: - Outlets
    @IBOutlet var cameraView: UIView!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var scanResultsTableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scanResultsTableView.dataSource = self
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideoCapture()
    }
    
    //MARK: - Actions
    @IBAction func captureButtonPressed(_ sender: Any) {
        guard captureSession.isRunning
        else {
            captureButton.setTitle("Capture", for: .normal)
            captureSession.startRunning()
            return
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
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
        
        stillImageOutput = AVCapturePhotoOutput()
        
        guard captureSession.canAddOutput(stillImageOutput) else {
            print("Can't add output")
            return
        }
        
        captureSession.addOutput(stillImageOutput)
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
        scanResults = recognizedStrings
        scanResultsTableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = scanResults[indexPath.row]
        return cell
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("No data")
            return
        }

        guard let cgImage = UIImage(data: imageData)?.cgImage else {
            print("No image")
            return
        }
        
        captureButton.setTitle("Reset", for: .normal)
        captureSession.stopRunning()

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        do { try requestHandler.perform([request]) } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
}

