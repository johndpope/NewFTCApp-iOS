//
//  AudioPlayer.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/5.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices


// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class AudioContent {
    static let sharedInstance = AudioContent()
    var body = [String: String]()
}

class AudioPlayer: UIViewController,WKScriptMessageHandler,UIScrollViewDelegate,WKNavigationDelegate {
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    private let download = DownloadHelper(directory: "audio")
    
    var item: ContentItem?
    var themeColor: String?
    
    @IBOutlet weak var containerView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var buttonPlayAndPause: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadButton: UIButtonEnhanced!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playStatus: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var playerView: UIView!
    
    @IBAction func ButtonPlayPause(_ sender: UIBarButtonItem) {
        if let player = player {
            if player.rate != 0 && player.error == nil {
                player.pause()
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            } else {
                // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                // MARK: - Continue audio when device is in background
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
                player.replaceCurrentItem(with: playerItem)
                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
                
                // TODO: - Need to find a way to display media duration and current time in lock screen
                var mediaLength: NSNumber = 0
                if let d = self.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        mediaLength = duration as NSNumber
                    }
                }
                
                var currentTime: NSNumber = 0
                if let c = self.playerItem?.currentTime() {
                    let currentTime1 = CMTimeGetSeconds(c)
                    if currentTime1.isNaN == false {
                        currentTime = currentTime1 as NSNumber
                    }
                }
                nowPlayingCenter.updateInfo(
                    title: audioTitle,
                    artist: "FT中文网",
                    albumArt: UIImage(named: "cover.jpg"),
                    currentTime: currentTime,
                    mediaLength: mediaLength,
                    PlaybackRate: 1.0
                )
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    
    
    
    fileprivate var isSaved = false
    @IBAction func love(_ sender: UIBarButtonItem) {
        if let item = item {
            if isSaved == false {
                Download.save(item, to: "clip", uplimit: 50, action: "save")
                isSaved = true
                sender.image = UIImage(named: "Delete")
            } else {
                Download.save(item, to: "clip", uplimit: 50, action: "delete")
                isSaved = false
                sender.image = UIImage(named: "Clip")
            }
        }
    }
    
    @IBOutlet weak var loveButton: UIBarButtonItem!
    fileprivate func checkLoveButton() {
        if let item = item {
        let key = "Saved clip"
        let savedItems = UserDefaults.standard.array(forKey: key) as? [[String: String]] ?? [[String: String]]()
        for savedItem in savedItems {
            if item.id == savedItem["id"] && item.type == savedItem["type"] {
                isSaved = true
                break
            }
        }
        if isSaved == true {
            loveButton.image = UIImage(named: "Delete")
        } else {
            loveButton.image = UIImage(named: "Clip")
        }
        }
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        /*
         let share = ShareHelper()
         let ccodeInActionSheet = ccode["actionsheet"] ?? "iosaction"
         let url = URL(string: "http://www.ftchinese.com/interactive/\(audioId)#ccode=\(ccodeInActionSheet)")
         share.popupActionSheet(self as UIViewController, url: url)
         */
        if let item = item {
            self.launchActionSheet(for: item)
        }
    }
    
    @IBAction func download(_ sender: Any) {
        if audioUrlString != "" {
            if let button = sender as? UIButtonEnhanced {
                // FIXME: should handle all the status and actions to the download helper
                download.takeActions(audioUrlString, currentStatus: button.status)
            }
        }
    }
    
    
    @IBAction func settings(_ sender: Any) {
        let alert = UIAlertController(title: "请选择您的操作设置", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "清除所有音频",
            style: UIAlertActionStyle.default,
            handler: {_ in self.removeAllAudios() }
        ))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        removePlayerItemObservers()
        
        // MARK: - Remove Observe download status change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadStatusNotificationName),
            object: nil
        )
        
        // MARK: - Remove Observe download progress change
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: download.downloadProgressNotificationName),
            object: nil
        )
        
        // MARK: - Remove Observe Audio Route Change and Update UI accordingly
        NotificationCenter.default.removeObserver(
            self,
            // MARK: - It has to be NSNotification, not Notification
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        
        
        
        NotificationCenter.default.removeObserver(self)
        
        // MARK: - Stop loading and remove message handlers to avoid leak
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        
        // MARK: - Remove delegate to deal with crashes on iOS 8
        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        
        print ("deinit successfully and observer removed")
    }
    
    override func loadView() {
        super.loadView()
        ShareHelper.sharedInstance.webPageTitle = ""
        ShareHelper.sharedInstance.webPageDescription = ""
        ShareHelper.sharedInstance.webPageImage = ""
        ShareHelper.sharedInstance.webPageImageIcon = ""
        parseAudioMessage()
        prepareAudioPlay()
        enableBackGroundMode()
        let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';} var gCoverImage = getContentByMetaTagName('og:image') || '';var gIconImage = getContentByMetaTagName('thumbnail') || '';var gDescription = getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || '';gIconImage=encodeURIComponent(gIconImage);webkit.messageHandlers.callbackHandler.postMessage(gCoverImage + '|' + gIconImage + '|' + gDescription);"
        let userScript = WKUserScript(
            source: jsCode,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        // MARK: - Use a LeakAvoider to avoid leak
        contentController.add(
            LeakAvoider(delegate:self),
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
        self.containerView.addSubview(self.webView!)
        self.containerView.clipsToBounds = true
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ShareHelper.sharedInstance.webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)"
        let url = "\(ShareHelper.sharedInstance.webPageUrl)?hideheader=yes&ad=no&inNavigation=yes&v=1"
        if let url = URL(string:url) {
            let req = URLRequest(url:url)
            webView?.load(req)
        }
        navigationItem.title = item?.headline
        initStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let screenName = "/\(DeviceInfo.checkDeviceType())/audio/\(audioId)/\(audioTitle)"
        Track.screenView(screenName)
        checkLoveButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if self.isMovingFromParentViewController {
            if let player = player {
                player.pause()
                self.player = nil
            }
        } else {
            print ("Audio is not being popped")
        }
    }
    
    private func initStyle() {
        if let themeColor = themeColor {
            let theme = UIColor(hex: themeColor)
            visualEffectView.backgroundColor = theme
            playerView.backgroundColor = theme
            toolBar.backgroundColor = theme
            toolBar.barTintColor = theme
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("page loaded!")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            if let infoForShare = message.body as? String{
                print(infoForShare)
                let toArray = infoForShare.components(separatedBy: "|")
                ShareHelper.sharedInstance.webPageDescription = toArray[2]
                ShareHelper.sharedInstance.webPageImage = toArray[0]
                ShareHelper.sharedInstance.webPageImageIcon = toArray[1]
                print("get image icon from web page: \(ShareHelper.sharedInstance.webPageImageIcon)")
            }
        }
    }
    
    func removeAllAudios() {
        Download.removeFiles(["mp3"])
        downloadButton.status = .remote
    }
    
    
    // MARK: - When users click on a link from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openInView (urlString)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    
    
    
    // FIXME: - This is very simlar to the same func in ViewController. Consider optimize the code.
    func openInView(_ urlString : String) {
        ShareHelper.sharedInstance.webPageUrl = urlString
        let segueId = "Audio To WKWebView"
        if #available(iOS 9.0, *) {
            // MARK: - Use Safariview for iOS 9 and above
            if urlString.range(of: "www.ftchinese.com") == nil && urlString.range(of: "i.ftimg.net") == nil {
                // MARK: - When opening an outside url which we have no control over
                if let url = URL(string:urlString) {
                    if let urlScheme = url.scheme?.lowercased() {
                        if ["http", "https"].contains(urlScheme) {
                            // MARK: - Can open with SFSafariViewController
                            let webVC = SFSafariViewController(url: url)
                            webVC.delegate = self
                            self.present(webVC, animated: true, completion: nil)
                        } else {
                            // MARK: - When Scheme is not supported or no scheme is given, use openURL
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            } else {
                // MARK: Open a url on a page that we have control over
                self.performSegue(withIdentifier: segueId, sender: nil)
            }
        } else {
            // MARK: Fallback on earlier versions
            self.performSegue(withIdentifier: segueId, sender: nil)
        }
    }
    
    private func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            print (title)
            audioTitle = title
            audioUrlString = audioFileUrl.replacingOccurrences(of: " ", with: "%20")
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            ShareHelper.sharedInstance.webPageTitle = title
        }
    }
    
    private func updateAVPlayerWithLocalUrl() {
        if let localAudioFile = download.checkDownloadedFileInDirectory(audioUrlString) {
            let currentSliderValue = self.progressSlider.value
            let audioUrl = URL(fileURLWithPath: localAudioFile)
            let asset = AVURLAsset(url: audioUrl)
            removePlayerItemObservers()
            playerItem = AVPlayerItem(asset: asset)
            player?.replaceCurrentItem(with: playerItem)
            addPlayerItemObservers()
            let currentTime = CMTimeMake(Int64(currentSliderValue), 1)
            playerItem?.seek(to: currentTime)
            nowPlayingCenter.updateTimeForPlayerItem(player)
            print ("now use local file to play at \(currentTime)")
        }
    }
    
    private func removePlayerItemObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
    }
    
    private func addPlayerItemObservers() {
        // MARK: - Observe Play to the End
        NotificationCenter.default.addObserver(self,selector:#selector(AudioPlayer.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // MARK: - Update buffer status
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
    }
    
    private func updatePlayTime(current time: CMTime, duration: CMTime) {
        playDuration.text = "-\((duration-time).durationText)"
        playTime.text = time.durationText
    }
    
    private func prepareAudioPlay() {
        // MARK: - Use https url so that the audio can be buffered properly on actual devices
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://du3rcmbgk4e8q.cloudfront.net/album/")
        // MARK: - Remove toolBar's top border. This cannot be done in interface builder.
        toolBar.clipsToBounds = true
        
        if let url = URL(string: audioUrlString) {
            // MARK: - Check if the file already exists locally
            var audioUrl = url
            //print ("checking the file in documents: \(audioUrlString)")
            let cleanAudioUrl = audioUrlString.replacingOccurrences(of: "%20", with: "")
            if let localAudioFile = download.checkDownloadedFileInDirectory(cleanAudioUrl) {
                print ("The Audio is already downloaded")
                audioUrl = URL(fileURLWithPath: localAudioFile)
                downloadButton.status = .success
                //                downloadButton.setImage(UIImage(named:"DeleteButton"), for: .normal)
            }
            
            // MARK: - Draw a circle around the downloadButton
            downloadButton.drawCircle()
            
            // MARK: - Set sourceVC as self so that the alert can be popped out
            // download.sourceVC = self
            
            // MARK: - Change the size of progressSlider
            let ftPink = UIColor(netHex: 0xFFF1E0)
            let ftRed = UIColor(netHex: 0x9E2F50)
            let progressThumbImage = UIImage(color: ftPink, size: CGSize(width: 1, height: 4))
            let progressThumbImageForHighted = UIImage(color: ftRed, size: CGSize(width: 2, height: 8))
            
            // MARK: - Apple: "The control state whose thumb image you want to use. Specify a single control state value for this parameter. "
            progressSlider.setThumbImage(progressThumbImage, for: .normal)
            progressSlider.setThumbImage(progressThumbImageForHighted, for: .highlighted)
            
            
            let asset = AVURLAsset(url: audioUrl)
            
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer()
            
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = self?.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                        self?.updatePlayTime(current: time, duration: d)
                    }
                }
            }
            
            // MARK: - Observe download status change
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayer.handleDownloadStatusChange(_:)),
                name: Notification.Name(rawValue: download.downloadStatusNotificationName),
                object: nil
            )
            
            // MARK: - Observe download progress change
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayer.handleDownloadProgressChange(_:)),
                name: Notification.Name(rawValue: download.downloadProgressNotificationName),
                object: nil
            )
            
            // MARK: - Observe Audio Route Change and Update UI accordingly
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(AudioPlayer.updatePlayButtonUI),
                // MARK: - It has to be NSNotification, not Notification
                name: NSNotification.Name.AVAudioSessionRouteChange,
                object: nil
            )
            addPlayerItemObservers()
        }
    }
    
    public func updatePlayButtonUI() {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            } else {
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            }
        }
    }
    
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume music")
            self?.player?.play()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            return .success
        }
        //        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {[weak self] event in
        //            print ("next audio")
        //            return .success
        //        }
        //        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {[weak self] event in
        //            print ("previous audio")
        //            return .success
        //        }
    }
    
    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    playStatus.text = "加载中..."
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing. Duration is \(String(describing: playerItem?.duration))")
                    playStatus.text = audioTitle
                case "playbackBufferFull":
                    // Hide loader
                    print ("load successfully")
                    playStatus.text = audioTitle
                default:
                    playStatus.text = audioTitle
                    break
                }
            }
            if let time = playerItem?.currentTime(), let duration = playerItem?.duration {
                updatePlayTime(current: time, duration: duration)
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    
    public func handleDownloadStatusChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, status: DownloadStatus) {
                let status = object.status
                let id = object.id
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                print ("Handle download Status Change: \(cleanAudioUrl) =? \(id)")
                if cleanAudioUrl.contains(id) == true {
                    switch status {
                    case .downloading, .remote:
                        self.downloadButton.progress = 0
                    case .paused, .resumed:
                        break
                    case .success:
                        // MARK: if a file is downloaded, prepare the audio asset again
                        self.updateAVPlayerWithLocalUrl()
                        self.downloadButton.progress = 0
                    }
                    print ("notification received for \(status)")
                    self.downloadButton.status = status
                    //self.downloadButton.progress = 0
                }
            }
        }
    }
    
    public func handleDownloadProgressChange(_ notification: Notification) {
        DispatchQueue.main.async() {
            if let object = notification.object as? (id: String, percentage: Float, downloaded: String, total: String) {
                let id = object.id
                let percentage = object.percentage
                // MARK: The Player Need to verify that the current file matches status change
                let cleanAudioUrl = self.audioUrlString.replacingOccurrences(of: "%20", with: "")
                if cleanAudioUrl.contains(id) == true {
                    self.downloadButton.progress = percentage/100
                    self.downloadButton.status = .resumed
                }
            }
        }
    }
    
}




// MARK: - Done: Share
// MARK: - Done: Download Management: Download or Delete
// MARK: - Done: When unplug earphone, pause button should be updated
// TODO: Subscribe
// TODO: Display Background Images for Radio Columns
// MARK: - Done: Deinit 1. remove observers 2. quit background play mode
// MARK: - Done: Enable background play
// MARK: - Done: Display the audio text
// MARK: - Done: Update play progress
// MARK: - Done: Update progressSlider thumb image with customized ones
// MARK: - Done: Post and Receive Status Change Notifications
// MARK: - Done: Update UI Based on Status Change
// MARK: - Done: Update UI Based on Download Progress
// MARK: - Done: Choose streaming or local file to play based on availability of audio files
// MARK: - Done: Allow users to clean files with one tap
// TODO: Let users easily find downloaded file to play
// MARK: - Done: Display current status so that users/reviewers know what it is going on. 1. Buffering. 2. Playtime and Duration.
// MARK: - Done: If a user is trying to download while not on wifi, pop out an alert with friendly suggestions
// MARK: - https://www.raywenderlich.com/94302/implement-circular-image-loader-animation-cashapelayer


