import AVFoundation

@Observable
final class AudioRecordingService: NSObject {
    private var recorder: AVAudioRecorder?
    private var recordedFileURL: URL?
    private var timer: Timer?

    var isRecording = false
    var elapsedSeconds: Int = 0

    static let maxDuration: Int = 300    // 5 minutes
    static let warningAt: Int = 270      // warn at 4:30

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)

        let fileName = "voice_\(Int(Date().timeIntervalSince1970)).m4a"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        recordedFileURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let newRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        newRecorder.record()
        recorder = newRecorder
        isRecording = true
        elapsedSeconds = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 1
            if self.elapsedSeconds >= Self.maxDuration {
                self.stopRecording()
            }
        }
    }

    func stopRecording() -> URL? {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
        isRecording = false
        return recordedFileURL
    }

    var shouldWarn: Bool {
        elapsedSeconds >= Self.warningAt && elapsedSeconds < Self.maxDuration
    }

    var remainingSeconds: Int {
        max(0, Self.maxDuration - elapsedSeconds)
    }
}
