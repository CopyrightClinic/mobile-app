import AVFoundation
import FirebaseCore
import FirebaseMessaging
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
  private var accumulatedRecognitionResult: String = ""

  private var zoomBridge: ZoomBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController

    let speechChannel = FlutterMethodChannel(
      name: "com.example.speech", binaryMessenger: controller.binaryMessenger)

    speechChannel.setMethodCallHandler {
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "startSpeech":
        self?.startSpeech(call: call, result: result)
      case "stopSpeech":
        self?.stopSpeech(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let zoomMethodChannel = FlutterMethodChannel(
      name: "com.example.zoom", binaryMessenger: controller.binaryMessenger)
    let zoomEventChannel = FlutterEventChannel(
      name: "com.example.zoom/events", binaryMessenger: controller.binaryMessenger)

    zoomBridge = ZoomBridge(methodChannel: zoomMethodChannel, eventChannel: zoomEventChannel)

    zoomMethodChannel.setMethodCallHandler {
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.zoomBridge?.handleMethodCall(call, result: result)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }

  private func combineTranscriptions(_ accumulated: String, _ current: String) -> String {
    if accumulated.isEmpty {
      return current
    }
    if current.isEmpty {
      return accumulated
    }

    if current.hasPrefix(accumulated) {
      return current
    }

    return accumulated + " " + current
  }

  private func stopSpeech(result: @escaping FlutterResult) {
    let finalTranscription = combineTranscriptions(
      accumulatedRecognitionResult, lastRecognitionResult)

    methodResult = nil

    stopRecording()

    result(finalTranscription.isEmpty ? nil : finalTranscription)
  }

  private func startSpeech(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if recognitionTask != nil {
      stopRecording()
    }

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
          code: "speech_not_available",
          message: NSLocalizedString("speech_recognition_not_available", comment: ""),
          details: nil))
      return
    }

    guard speechRecognizer.isAvailable else {
      result(
        FlutterError(
          code: "speech_not_available",
          message: NSLocalizedString("speech_recognition_network_error", comment: ""),
          details: nil))
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
              code: "speech_permission_denied",
              message: NSLocalizedString("speech_recognition_permission_denied", comment: ""),
              details: nil))
        case .restricted:
          result(
            FlutterError(
              code: "speech_permission_restricted",
              message: NSLocalizedString("speech_recognition_permission_restricted", comment: ""),
              details: nil))
        case .notDetermined:
          result(
            FlutterError(
              code: "speech_permission_not_determined",
              message: NSLocalizedString(
                "speech_recognition_permission_not_determined", comment: ""),
              details: nil))
        @unknown default:
          result(
            FlutterError(
              code: "speech_permission_unknown",
              message: NSLocalizedString("speech_recognition_permission_unknown", comment: ""),
              details: nil))
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
              code: "mic_permission_denied",
              message: NSLocalizedString("microphone_permission_denied", comment: ""),
              details: nil))
          self?.methodResult = nil
        }
      }
    }
  }

  private func startRecording() {
    recognitionTask?.cancel()
    recognitionTask = nil

    accumulatedRecognitionResult = ""
    lastRecognitionResult = ""

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record, mode: .measurement, options: [])
      try audioSession.setActive(true)
    } catch {
      methodResult?(
        FlutterError(
          code: "audio_session_error",
          message: NSLocalizedString("audio_session_error", comment: ""),
          details: error.localizedDescription))
      methodResult = nil
      return
    }

    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else {
      methodResult?(
        FlutterError(
          code: "recognition_request_error",
          message: NSLocalizedString("recognition_request_error", comment: ""),
          details: nil))
      methodResult = nil
      return
    }

    recognitionRequest.shouldReportPartialResults = true

    if #available(iOS 13.0, *) {
      recognitionRequest.requiresOnDeviceRecognition = true
    }

    audioEngine = AVAudioEngine()
    guard let audioEngine = audioEngine else {
      methodResult?(
        FlutterError(
          code: "audio_engine_error",
          message: NSLocalizedString("audio_engine_error", comment: ""),
          details: nil))
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
          code: "audio_engine_start_error",
          message: NSLocalizedString("audio_engine_start_error", comment: ""),
          details: error.localizedDescription))
      methodResult = nil
      return
    }

    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
      [weak self] result, error in
      if let error = error {
        self?.stopRecording()

        guard let methodResult = self?.methodResult else {
          return
        }

        let errorMessage = error.localizedDescription
        let isNetworkError =
          errorMessage.contains("network") || errorMessage.contains("internet")
          || errorMessage.contains("connection")

        let finalMessage: String
        if isNetworkError {
          finalMessage = NSLocalizedString("speech_recognition_network_error", comment: "")
        } else if errorMessage.contains("Siri and Dictation are disabled") {
          finalMessage = NSLocalizedString("speech_recognition_disabled_error", comment: "")
        } else {
          finalMessage = String(
            format: NSLocalizedString("speech_recognition_generic_error", comment: ""), errorMessage
          )
        }

        methodResult(
          FlutterError(
            code: "recognition_error",
            message: finalMessage,
            details: error.localizedDescription))
        self?.methodResult = nil
        return
      }

      if let result = result {
        let transcription = result.bestTranscription.formattedString

        let previousResult = self?.lastRecognitionResult ?? ""
        let lengthCondition = Double(transcription.count) < Double(previousResult.count) * 0.7
        let prefixCondition = !transcription.hasPrefix(
          String(previousResult.prefix(min(10, previousResult.count))))
        let isNewUtterance =
          !transcription.isEmpty && !previousResult.isEmpty
          && lengthCondition
          && prefixCondition

        if isNewUtterance {
          if let currentAccumulated = self?.accumulatedRecognitionResult {
            let combined =
              self?.combineTranscriptions(currentAccumulated, previousResult) ?? previousResult
            self?.accumulatedRecognitionResult = combined
          }
        }

        self?.lastRecognitionResult = transcription

        if result.isFinal {
          if let currentAccumulated = self?.accumulatedRecognitionResult,
            let currentResult = self?.lastRecognitionResult
          {
            let combined =
              self?.combineTranscriptions(currentAccumulated, currentResult) ?? currentResult
            self?.accumulatedRecognitionResult = combined
          }
          self?.lastRecognitionResult = ""
        }
      }
    }

    recognitionTimer = Timer.scheduledTimer(
      withTimeInterval: TimeInterval(maxSeconds), repeats: false
    ) { [weak self] _ in
      self?.stopRecording()

      let transcription = self?.lastRecognitionResult ?? ""
      self?.methodResult?(transcription.isEmpty ? nil : transcription)
      self?.methodResult = nil
    }
  }

  private func stopRecording() {
    recognitionTimer?.invalidate()
    recognitionTimer = nil

    audioEngine?.stop()
    audioEngine?.inputNode.removeTap(onBus: 0)

    recognitionRequest?.endAudio()
    recognitionRequest = nil

    recognitionTask?.cancel()
    recognitionTask = nil

    audioEngine = nil
    lastRecognitionResult = ""
    accumulatedRecognitionResult = ""

    do {
      try AVAudioSession.sharedInstance().setActive(false)
    } catch {
    }
  }
}
