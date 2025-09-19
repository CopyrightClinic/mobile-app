import AVFoundation
import Flutter
import Speech
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var speechRecognizer: SFSpeechRecognizer?
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private var audioEngine: AVAudioEngine?
  private var methodResult: FlutterResult?
  private var maxSeconds: Int = 10
  private var recognitionTimer: Timer?
  private var lastRecognitionResult: String = ""
  private var silenceTimer: Timer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let speechChannel = FlutterMethodChannel(
      name: "com.example.speech", binaryMessenger: controller.binaryMessenger)

    speechChannel.setMethodCallHandler {
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "startSpeech":
        self?.startSpeech(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startSpeech(call: FlutterMethodCall, result: @escaping FlutterResult) {
    methodResult = result

    let arguments = call.arguments as? [String: Any]
    let locale = arguments?["locale"] as? String
    maxSeconds = arguments?["maxSeconds"] as? Int ?? 10

    if let locale = locale {
      speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
    } else {
      speechRecognizer = SFSpeechRecognizer()
    }

    guard let speechRecognizer = speechRecognizer else {
      result(
        FlutterError(
          code: "speech_not_available", message: "Speech recognition not available", details: nil))
      return
    }

    guard speechRecognizer.isAvailable else {
      result(
        FlutterError(
          code: "speech_not_available", message: "Speech recognition not available", details: nil))
      return
    }

    SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
      DispatchQueue.main.async {
        switch authStatus {
        case .authorized:
          self?.requestMicrophonePermission()
        case .denied:
          result(
            FlutterError(
              code: "speech_permission_denied", message: "Speech recognition permission denied",
              details: nil))
        case .restricted:
          result(
            FlutterError(
              code: "speech_permission_restricted",
              message: "Speech recognition permission restricted", details: nil))
        case .notDetermined:
          result(
            FlutterError(
              code: "speech_permission_not_determined",
              message: "Speech recognition permission not determined", details: nil))
        @unknown default:
          result(
            FlutterError(
              code: "speech_permission_unknown",
              message: "Unknown speech recognition permission status", details: nil))
        }
      }
    }
  }

  private func requestMicrophonePermission() {
    AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
      DispatchQueue.main.async {
        if granted {
          self?.startRecording()
        } else {
          self?.methodResult?(
            FlutterError(
              code: "mic_permission_denied", message: "Microphone permission denied", details: nil))
          self?.methodResult = nil
        }
      }
    }
  }

  private func startRecording() {
    recognitionTask?.cancel()
    recognitionTask = nil

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record, mode: .measurement, options: [])
      try audioSession.setActive(true)
    } catch {
      methodResult?(
        FlutterError(
          code: "audio_session_error", message: "Failed to configure audio session",
          details: error.localizedDescription))
      methodResult = nil
      return
    }

    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else {
      methodResult?(
        FlutterError(
          code: "recognition_request_error", message: "Failed to create recognition request",
          details: nil))
      methodResult = nil
      return
    }

    recognitionRequest.shouldReportPartialResults = true

    audioEngine = AVAudioEngine()
    guard let audioEngine = audioEngine else {
      methodResult?(
        FlutterError(
          code: "audio_engine_error", message: "Failed to create audio engine", details: nil))
      methodResult = nil
      return
    }

    let inputNode = audioEngine.inputNode
    let recordingFormat = inputNode.outputFormat(forBus: 0)

    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      recognitionRequest.append(buffer)
    }

    do {
      try audioEngine.start()
    } catch {
      methodResult?(
        FlutterError(
          code: "audio_engine_start_error", message: "Failed to start audio engine",
          details: error.localizedDescription))
      methodResult = nil
      return
    }

    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
      [weak self] result, error in
      if let error = error {
        self?.stopRecording()
        self?.methodResult?(
          FlutterError(
            code: "recognition_error", message: "Speech recognition error",
            details: error.localizedDescription))
        self?.methodResult = nil
        return
      }

      if let result = result {
        let transcription = result.bestTranscription.formattedString
        self?.lastRecognitionResult = transcription

        if result.isFinal {
          self?.stopRecording()
          self?.methodResult?(transcription.isEmpty ? nil : transcription)
          self?.methodResult = nil
        } else {
          self?.resetSilenceTimer()
        }
      }
    }

    resetSilenceTimer()

    recognitionTimer = Timer.scheduledTimer(
      withTimeInterval: TimeInterval(maxSeconds), repeats: false
    ) { [weak self] _ in
      self?.stopRecording()

      let transcription = self?.lastRecognitionResult ?? ""
      self?.methodResult?(transcription.isEmpty ? nil : transcription)
      self?.methodResult = nil
    }
  }

  private func resetSilenceTimer() {
    silenceTimer?.invalidate()
    silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
      self?.finishRecordingWithResult()
    }
  }

  private func finishRecordingWithResult() {
    let transcription = lastRecognitionResult
    stopRecording()
    methodResult?(transcription.isEmpty ? nil : transcription)
    methodResult = nil
  }

  private func stopRecording() {
    recognitionTimer?.invalidate()
    recognitionTimer = nil

    silenceTimer?.invalidate()
    silenceTimer = nil

    audioEngine?.stop()
    audioEngine?.inputNode.removeTap(onBus: 0)

    recognitionRequest?.endAudio()
    recognitionRequest = nil

    recognitionTask?.cancel()
    recognitionTask = nil

    audioEngine = nil
    lastRecognitionResult = ""

    try? AVAudioSession.sharedInstance().setActive(false)
  }
}
