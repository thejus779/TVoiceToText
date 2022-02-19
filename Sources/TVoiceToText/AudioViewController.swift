import UIKit
import AVKit
import Speech

protocol AudioViewControllerDelegate: AnyObject {
    func audioViewController(audioViewController: AudioViewController, didRecognize text: String?)
}
class AudioViewController: UIViewController, CasinoSpeechRecognizer {
    var defaultMessageForTextFromSpeech: String
    var shouldRestartSpeechRecognition: Bool = false
    var speechRecognizer: SFSpeechRecognizer?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine: AVAudioEngine?
    var textFromSpeech: String? {
        didSet {
            message.text = textFromSpeech
            print("[AudioViewController] textFromSpeech \(textFromSpeech ?? "")")
        }
    }
    
    @IBOutlet private weak var message: UILabel!
    @IBOutlet private weak var okButton: UIButton!
    
    weak var delegate: AudioViewControllerDelegate?

    init(delegate: AudioViewControllerDelegate?, defaultMessageForTextFromSpeech: String) {
        self.delegate = delegate
        self.defaultMessageForTextFromSpeech = defaultMessageForTextFromSpeech
        super.init(nibName: "AudioViewController", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the recorder with the locale
        setupSpeechRecognizer(
            speechRecognizer: SFSpeechRecognizer(locale: Locale(identifier: "fr_FR"))
        )

        // Start recording
        startSpeechRecording()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        okButton.layer.removeAllAnimations()
    }
    @IBAction func onTouchUpInsideCloseSpeech(_ sender: Any) {
        stopSpeechRecording()
        guard let textFromSpeech = textFromSpeech,
        textFromSpeech != defaultMessageForTextFromSpeech
        else {
            delegate?.audioViewController(audioViewController: self, didRecognize: nil)
            return
        }

        delegate?.audioViewController(audioViewController: self, didRecognize: textFromSpeech)
    }
        
    private func animate() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.okButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                self?.okButton.transform = .identity
            }, completion: { [weak self] finished in
                if finished {
                    self?.animate()
                }
            })
        })
    }
}
