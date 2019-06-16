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



class ViewController: UIViewController {
    
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
    var idRecording = false /*Bool型*/

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

}

