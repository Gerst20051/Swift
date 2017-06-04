import AVFoundation
import Material
import SnapKit
import UIKit

class EpisodeViewController: BaseViewController {

    var podcastFeed: PodcastFeedResult?
    var podcastEpisodeId: String?
    var podcastEpisode: PodcastFeedEpisode? {
        get {
            return podcastFeed?.episodes?.first { $0.id! == podcastEpisodeId! }
        }
    }
    lazy var playerQueue: AVQueuePlayer = {
        return AVQueuePlayer()
    }()
    var timeObserverToken: Any?
    var lastLabel: UILabel?
    var progressLabel: UILabel?
    var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        loadEpisode()
        addPeriodicTimeObserver()
    }

    func setupInterface() {
        view.backgroundColor = .white
        createLabels()
        createProgressLabel()
        createImageView()
        createButtons()
    }

    func createLabels() {
        guard let feed = podcastFeed, let episode = podcastEpisode else { return }
        let labels = [
            feed.title!,
            feed.author!,
            episode.title!,
            episode.subtitle!,
            episode.date!
        ]
        for text in labels {
            let label = UILabel()
            label.text = text
            label.textAlignment = .left
            view.addSubview(label)
            label.snp.makeConstraints { make -> Void in
                make.height.equalTo(40.0)
                make.top.equalTo(lastLabel?.snp.bottom ?? view)
                make.width.equalTo(view)
            }
            lastLabel = label
        }
    }

    func createProgressLabel() {
        progressLabel = UILabel()
        guard let progressLabel = progressLabel else { return }
        progressLabel.textAlignment = .left
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make -> Void in
            make.height.equalTo(40.0)
            make.top.equalTo(lastLabel!.snp.bottom)
            make.width.equalTo(view)
        }
    }

    func createImageView() {
        imageView = UIImageView(image: URL(string: podcastFeed!.image!).flatMap { NSData(contentsOf: $0) }!.flatMap { UIImage(data: $0 as Data) }!)
        guard let imageView = imageView else { return }
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make -> Void in
            make.centerX.equalTo(view)
            make.height.width.equalTo(60.0)
            make.top.equalTo(progressLabel!.snp.bottom).offset(20.0)
        }
    }

    func createButtons() {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Stop", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make -> Void in
            make.centerX.equalTo(view)
            make.height.width.equalTo(60.0)
            make.top.equalTo(imageView!.snp.bottom).offset(20.0)
        }
    }

    func buttonAction(sender: UIButton!) {
        playerQueue.removeAllItems()
        app.restoreRootViewController()
    }

    func loadEpisode() {
        if let episode = podcastEpisode, let episodeURL = episode.url, let url = URL(string: episodeURL) {
            let playerItem = AVPlayerItem.init(url: url)
            playerQueue.insert(playerItem, after: nil)
            playerQueue.play()
        }
    }

    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = playerQueue.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = Int(round(CMTimeGetSeconds(time)))
            if let duration = self?.podcastEpisode?.duration, let formattedSeconds = self?.getFormattedDuration(duration: TimeInterval(seconds)) {
                self?.progressLabel?.text = "\(formattedSeconds)/\(duration)"
            }
        }
    }

    func getFormattedDuration(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter.string(from: duration)!
    }

}
