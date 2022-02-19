import Foundation
import Speech
import AVKit

protocol SpeechRecognizerPresenter: UIViewController, AudioViewControllerDelegate {
    func casinoSpeechRecognize(_ speechRecognizerPresenter: SpeechRecognizerPresenter, didRecognize text: String?)
}

extension SpeechRecognizerPresenter {
    
    // Must request before presenting
    private func requestSpeechAuthorization(onDone: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            onDone(authStatus)
        }
    }

    public func presentSpeechRecognizer(title: String, message: String?, okText: String, cancelText: String, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?,  animated: Bool = true, defaultMessageForTextFromSpeech: String) {
        requestSpeechAuthorization(onDone: { [weak self] status in
            switch status {
            case .authorized:
                // Present only from main queue
                DispatchQueue.main.async {
                    self?.presentAudioViewController(
                        animated: animated,
                        defaultMessageForTextFromSpeech: defaultMessageForTextFromSpeech
                    )
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self?.presentAlert(
                        title: title,
                        message: message,
                        cancelHandler: cancelHandler,
                        okHandler: okHandler,
                        cancelText: cancelText,
                        okText: okText
                    )
                }
                
            default:
                break
            }
        })
    }
    
    // Present the AudioViewController
    private func presentAudioViewController(animated: Bool, defaultMessageForTextFromSpeech: String) {
        let audioViewController = AudioViewController(
            delegate: self, defaultMessageForTextFromSpeech: defaultMessageForTextFromSpeech
        )
        audioViewController.modalPresentationStyle = .overFullScreen
        present(audioViewController, animated: animated, completion: nil)
    }
}

// Mark:- AudioViewController Delegates
extension SpeechRecognizerPresenter {
    func audioViewController(audioViewController: AudioViewController, didRecognize text: String?) {
        casinoSpeechRecognize(self, didRecognize: text)
        dismiss(animated: true, completion: nil)
    }
}
