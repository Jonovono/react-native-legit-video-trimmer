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
    
    private let kMinDuration: Double = 1
    private let kMaxDuration: Double = 10 * 60
    private let kSelectedDurationFormat = "%.1fs selected"
    
    @objc var source: NSString = "" {
        didSet {
            print("source: \(source)")
            if asset != nil {
                loadAsset(for: source as String)
            }
        }
    }
    
    @objc var minDuration: NSNumber = 0 {
        didSet {
            if minDuration.doubleValue < kMinDuration {
                minDuration = NSNumber(value: kMinDuration)
            }
            
            trimmerView.minDuration = minDuration.doubleValue
        }
    }
    
    @objc var maxDuration: NSNumber = 0 {
        didSet {
            if maxDuration.doubleValue > kMaxDuration {
                maxDuration = NSNumber(value: kMaxDuration)
            }
            
            trimmerView.maxDuration = maxDuration.doubleValue
        }
    }
    
    @objc var mainColor: NSString = "" {
        didSet {
            if let color = UIColor(string: mainColor as String) {
                trimmerView.mainColor = color
            }
        }
    }
    
    @objc var handleColor: NSString = "" {
        didSet {
            if let color = UIColor(string: handleColor as String) {
                trimmerView.handleColor = color
            }
        }
    }

    @objc var positionBarColor: NSString = "" {
        didSet {
            if let color = UIColor(string: positionBarColor as String) {
                trimmerView.positionBarColor = color
            }
        }
    }
    
    @objc var doneButtonBackgroundColor: NSString = "" {
        didSet {
            if let color = UIColor(string: doneButtonBackgroundColor as String) {
                doneButton.backgroundColor = color
            }
        }
    }

    private var playerView: UIView!
    private var backButton: UIButton!
    private var selectedDurationLabel: UILabel!
    private var doneButton: UIButton!
    private var trimmerView: TrimmerView!
    
    private var asset: AVAsset? {
        didSet {
            trimmerView.asset = asset
            let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
            selectedDurationLabel.text = String(format: kSelectedDurationFormat, duration)
            if let asset = asset {
                addVideoPlayer(with: asset, playerView: playerView)
            }
        }
    }
        
    private var player: AVPlayer?
    private var playbackTimeCheckerTimer: Timer?
    private var trimmerPositionChangedTimer: Timer?
    
    init() {
        super.init(frame: .zero)
        
        playerView = UIView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerView)
        playerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonDidPress(button:)), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
                
        doneButton = UIButton(type: .system)
        doneButton.setTitle("DONE", for: .normal)
        doneButton.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        doneButton.layer.cornerRadius = 5
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(doneButtonDidPress(button:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(doneButton)
        if #available(iOS 11.0, *) {
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            doneButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        doneButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
        selectedDurationLabel = UILabel()
        selectedDurationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        selectedDurationLabel.textColor = .white
        selectedDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectedDurationLabel)
        selectedDurationLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        selectedDurationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true

        trimmerView = TrimmerView()
        trimmerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trimmerView)
        trimmerView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20).isActive = true
        trimmerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        trimmerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        trimmerView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        setupTrimmerView()        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if asset == nil {
            DispatchQueue.main.async {
                self.loadAsset(for: self.source as String)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func backButtonDidPress(button: UIButton) {
    }
    
    @objc
    private func doneButtonDidPress(button: UIButton) {
        guard let asset = asset else { return }
        trimVideo(asset: asset, startTime: trimmerView.startTime!.seconds, endTime: trimmerView.endTime!.seconds) { url in
            print("Result url: \(url)")
        }
    }
}

extension LegitVideoTrimmerView {
    
    private func setupTrimmerView() {
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        trimmerView.delegate = self
    }
    
    private func loadAsset(for source: String) {
        if let url = URL(string: source), (url.isFileURL || source.hasPrefix("http")) {
            asset = AVAsset(url: url)
        } else {
            let sourceComponents = source.components(separatedBy: ".")
            if let url = Bundle.main.url(forResource: sourceComponents.first, withExtension: sourceComponents.last) {
                asset = AVAsset(url: url)
            }
        }
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
        selectedDurationLabel.text = String(format: kSelectedDurationFormat, duration)
    }
}

extension LegitVideoTrimmerView {
    
    func trimVideo(asset: AVAsset, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
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
