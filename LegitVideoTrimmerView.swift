//
//  LegitVideoTrimmerView.swift
//  VideoTrimmer
//
//  Created by Andrii Novoselskyi on 27.08.2020.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import Photos

@objc(LegitVideoTrimmerView)
class LegitVideoTrimmerView: UIView {
    
    @objc var source: NSString = "" {
        didSet {
            print("source: \(source)")
        }
    }
    
    @objc var minDuration: NSNumber = 0 {
        didSet {
        }
    }
    
    @objc var maxDuration: NSNumber = 0 {
        didSet {
        }
    }

    private var playerView: UIView!
    private var trimmerView: TrimmerView!
    
    private var asset: AVAsset? {
        didSet {
            trimmerView.asset = asset
            if let asset = asset {
                addVideoPlayer(with: asset, playerView: playerView)
            }
        }
    }
    
//    @IBAction func backButtonAction(_ sender: Any) {
//        guard let asset = player?.currentItem?.asset else { return }
//        cropVideo(asset: asset, startTime: trimmerView.startTime!.seconds, endTime: trimmerView.endTime!.seconds) { url in
//            print("Result url: \(url)")
//        }
//    }
    
    private var player: AVPlayer?
    private var playbackTimeCheckerTimer: Timer?
    private var trimmerPositionChangedTimer: Timer?
    
    init() {
        super.init(frame: .zero)
        playerView = UIView()
        trimmerView = TrimmerView()
        addSubview(playerView)
        addSubview(trimmerView)
        
        backgroundColor = .red
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        trimmerView.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        playerView.backgroundColor = .green
        
        if #available(iOS 11.0, *) {
            trimmerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            trimmerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        trimmerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        trimmerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        trimmerView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        trimmerView.backgroundColor = .orange
        
        setupTrimmerView()
        
        loadAssetRandomly()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadAssetRandomly() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let fetchResult = PHAsset.fetchAssets(with: .video, options: nil)
                
                let randomAssetIndex = Int(arc4random_uniform(UInt32(fetchResult.count - 1)))
                let asset = fetchResult.object(at: randomAssetIndex)
                PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                    DispatchQueue.main.async {
                        if let avAsset = avAsset {
                            self.asset = avAsset
                        }
                    }
                }
            }
        }
    }
}

extension LegitVideoTrimmerView {
    
    private func setupTrimmerView() {
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        trimmerView.delegate = self
    }
}

extension LegitVideoTrimmerView {
    
    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LegitVideoTrimmerView.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }

    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    private func play() {
        guard let player = player else { return }
        if !player.isPlaying {
            player.play()
            startPlaybackTimeChecker()
        } else {
            player.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(self, selector: #selector(LegitVideoTrimmerView.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
        
        play()
    }
    
    @objc
    private func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
        }
    }
    
    @objc
    private func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

extension LegitVideoTrimmerView: TrimmerViewDelegate {
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
}

extension AVPlayer {

    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}

extension LegitVideoTrimmerView {
    
    func cropVideo(asset: AVAsset, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        let date = Date()

        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(formatter.string(from: date)).mp4")
        }catch let error {
            print(error)
        }

        //Remove existing file
        try? fileManager.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))

        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
}
