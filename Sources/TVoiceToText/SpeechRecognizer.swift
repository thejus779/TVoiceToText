
import Foundation
import Speech
import AVKit

protocol CasinoSpeechRecognizer: UIViewController, SFSpeechRecognizerDelegate {
    var speechRecognizer: SFSpeechRecognizer? { get set }
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? { get set }
    var recognitionTask: SFSpeechRecognitionTask? { get set }
    var audioEngine: AVAudioEngine? { get set }
    var textFromSpeech: String? { get set }
    var shouldRestartSpeechRecognition: Bool { get set }
    var defaultMessageForTextFromSpeech: String { get set }
}
extension CasinoSpeechRecognizer {
    func setupSpeechRecognizer(speechRecognizer: SFSpeechRecognizer?) {
        self.speechRecognizer = speechRecognizer
        audioEngine = AVAudioEngine()
        self.speechRecognizer?.delegate = self
        
    }
    @discardableResult
    func startSpeechRecording() -> Bool {
        if audioEngine?.isRunning ?? false {
            stopSpeechRecording()
            return false
        } else {
            
            shouldRestartSpeechRecognition = false
            startRecording()
            return true
        }
    }
    
    func stopSpeechRecording() {
        audioEngine?.stop()
        recognitionRequest?.endAudio()
    }
    
    func clearPreviousRequest() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
    func tet(session: AVAudioSession) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            if granted {
                do {
                    try session.setCategory(.record)
                    try session.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    self?.unableToStartAudioSession()
                }
            } else {
                self?.unableToStartAudioSession()
            }
        }
    }

    func resetSpeech() {
        stopSpeechRecording()
        shouldRestartSpeechRecognition = true
    }

    // Should not be called before the previous recognitionTask ends
    private func startRecording() {
        
        // Clear all previous session data and cancel task
        clearPreviousRequest()
        
        
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        tet(session: audioSession)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard   let inputNode = audioEngine?.inputNode,
                let recognitionRequest = recognitionRequest
        else {
            unableToStartAudioSession()
            print("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(
            with: recognitionRequest,
            resultHandler: {[weak self] (result, error) in
                var isFinal = false
                if result != nil {
                    self?.textFromSpeech = result?.bestTranscription.formattedString
                    isFinal = (result?.isFinal)!
                }

                if error != nil || isFinal {
                    
                    self?.audioEngine?.stop()
                    self?.recognitionRequest = nil
                    self?.recognitionTask = nil
                    if isFinal && (self?.shouldRestartSpeechRecognition ?? false) {
                        self?.startSpeechRecordingAgain()
                    }
                }
            }
        )
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(
            onBus: 0, bufferSize: 1024, format: recordingFormat
        ) { [weak self] (buffer, _) in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine?.prepare()

        do {
            try audioEngine?.start()
        } catch {
            unableToStartAudioSession()
            print("audioEngine couldn't start because of an error.")
        }

        textFromSpeech = defaultMessageForTextFromSpeech
    }
    
    private func unableToStartAudioSession() {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(
                title: "Error",
                message: "Unable to start audio session, might be used by some other application",
                okHandler: { _ in
                    self?.dismiss(animated: true, completion: nil)
                }
            )
        }
    }
    
    func startSpeechRecordingAgain() {
        textFromSpeech = ""
        startSpeechRecording()
    }
}
