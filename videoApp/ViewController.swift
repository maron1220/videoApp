//
//  ViewController.swift
//  videoApp
//
//  Created by 細川聖矢 on 2019/06/16.
//  Copyright © 2019 Seiya. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


//AVCaptureFileOutputRecordingDelegateは必須
class ViewController: UIViewController , AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }){( completed,error) in
            if completed{
                print("保存完了！")
            }
            
        }
    }
    
    
    //設定に必要なもの
    var captureSession = AVCaptureSession()
    
    //カメラ設定につかうもの
    var backCamera : AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    
    //オーディオ設定
    var audioDevice = AVCaptureDevice.default(for:AVMediaType.audio)
    
    var videoFileOutput : AVCaptureMovieFileOutput?
    
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    //buttonを押したときに使用
    var isRecording = false /*Bool型*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDevice()
        setupCapturSession()
        setupInputOutput()
        setupPreviewLayer()
        setupRunningCaptureSession()
    }
    
    //関数を作る
    
    //カメラ設定
    func setupDevice(){
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        //フロントカメラとバックカメラの切り替えを設定した場合はいらない↓
        currentCamera = backCamera
    }
    
    //カメラ設定
    func setupCapturSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    //出入力
    //do,catch エラーの回避に使う｡あんまり使わない｡
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)
            
            videoFileOutput = AVCaptureMovieFileOutput()
            captureSession.addOutput(videoFileOutput!)
            
        }catch{
            print(error)
        }
    }
    
    //画面に表示させる
    //この中身は基本固定
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session : captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        //違うviewに写したいときは､selfに他のビューを紐付ける
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    //再生
    func setupRunningCaptureSession(){
        captureSession.startRunning()
        
    }
    
    //アニメーションつけたいからOutletも用意
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func captureAction(_ sender: Any) {
        
        //isRecordingでカメラのオンオフの切り替え
        
        if !isRecording {
            isRecording = true
            
            UIView.animate(withDuration: 0.5, delay:0.0,options:[.repeat,.autoreverse,.allowUserInteraction],animations:{() -> Void in self.recordButton.transform = CGAffineTransform(scaleX:0.5,y:0.5)},completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mp4"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
            
        } else {
            isRecording = false
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.recordButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            
            recordButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
            
            let title = "動画が保存されました"
            
            let message = "わーい"
            let text = "Done"
            let alert = UIAlertController(title:title ,message:message, preferredStyle: UIAlertController.Style.alert)
            let Button = UIAlertAction(title:text,style:UIAlertAction.Style.cancel,handler: nil)
            alert.addAction(Button)
            
            present(alert,animated: true,completion: nil)
        }
        
    }
    
}

