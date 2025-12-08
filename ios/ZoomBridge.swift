import Flutter
import MobileRTC
import UIKit

final class ZoomBridge: NSObject {
    private var eventSink: FlutterEventSink?
    private var isInitialized = false
    private var isInitializing = false
    private var isJoining = false
    private var pendingJoinRequest: [String: Any]?
    private var initResult: FlutterResult?

    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel

    init(methodChannel: FlutterMethodChannel, eventChannel: FlutterEventChannel) {
        self.methodChannel = methodChannel
        self.eventChannel = eventChannel
        super.init()

        setupEventChannel()
        logSDKVersion()
    }

    private func setupEventChannel() {
        eventChannel.setStreamHandler(self)
    }

    private func logSDKVersion() {
        NSLog("[ZoomBridge] Zoom Meeting SDK v6.6.0 for iOS")
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initZoom":
            guard let args = call.arguments as? [String: Any],
                let jwt = args["jwt"] as? String
            else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "JWT token required", details: nil))
                return
            }
            initZoom(jwt: jwt, result: result)

        case "joinMeeting":
            guard let args = call.arguments as? [String: Any],
                let meetingNumber = args["meetingNumber"] as? String,
                let displayName = args["displayName"] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGS", message: "meetingNumber and displayName required",
                        details: nil))
                return
            }
            let passcode = args["passcode"] as? String ?? ""
            joinMeeting(
                meetingNumber: meetingNumber, passcode: passcode, displayName: displayName,
                result: result)

        case "leaveMeeting":
            leaveMeeting(result: result)

        case "getSdkVersion":
            result("6.6.0")

        case "minimizeMeeting":
            minimizeMeeting(result: result)

        case "showMeeting":
            showMeeting(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initZoom(jwt: String, result: @escaping FlutterResult) {
        if isInitialized {
            NSLog("[ZoomBridge] Zoom SDK already initialized")
            result(["success": true, "message": "Already initialized"])
            return
        }

        if isInitializing {
            NSLog("[ZoomBridge] Zoom SDK initialization already in progress")
            result(
                FlutterError(
                    code: "ALREADY_INITIALIZING", message: "SDK initialization already in progress",
                    details: nil))
            return
        }

        isInitializing = true
        initResult = result
        NSLog("[ZoomBridge] Initializing Zoom SDK with JWT")

        let context = MobileRTCSDKInitContext()
        context.domain = "zoom.us"
        context.enableLog = true

        let sdk = MobileRTC.shared()

        if sdk.initialize(context) {
            NSLog("[ZoomBridge] MobileRTC.shared().initialize succeeded")

            guard let authService = sdk.getAuthService() else {
                isInitializing = false
                let error = FlutterError(
                    code: "INIT_FAIL", message: "Failed to get auth service", details: nil)
                initResult?(error)
                initResult = nil
                sendEvent([
                    "status": "FAILED", "errorCode": -1, "message": "Failed to get auth service",
                ])
                return
            }

            authService.delegate = self
            authService.jwtToken = jwt
            authService.sdkAuth()

            NSLog("[ZoomBridge] SDK authentication started, waiting for callback...")

        } else {
            isInitializing = false
            NSLog("[ZoomBridge] MobileRTC.shared().initialize failed")
            let error = FlutterError(
                code: "INIT_FAIL", message: "Failed to initialize SDK", details: nil)
            initResult?(error)
            initResult = nil
            sendEvent(["status": "FAILED", "errorCode": -1, "message": "Failed to initialize SDK"])
        }
    }

    private func joinMeeting(
        meetingNumber: String, passcode: String, displayName: String,
        result: @escaping FlutterResult
    ) {
        if !isInitialized {
            if isInitializing {
                NSLog("[ZoomBridge] Queuing join request until initialization completes")
                pendingJoinRequest = [
                    "meetingNumber": meetingNumber,
                    "passcode": passcode,
                    "displayName": displayName,
                    "result": FlutterResultWrapper(result: result),
                ]
                return
            }

            NSLog("[ZoomBridge] Cannot join meeting: SDK not initialized")
            result(
                FlutterError(
                    code: "NOT_INITIALIZED", message: "SDK not initialized. Call initZoom first.",
                    details: nil))
            return
        }

        if isJoining {
            NSLog("[ZoomBridge] Join already in progress")
            result(
                FlutterError(
                    code: "ALREADY_JOINING", message: "Join meeting already in progress",
                    details: nil))
            return
        }

        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            NSLog("[ZoomBridge] Failed to get meeting service")
            result(
                FlutterError(
                    code: "NO_MEETING_SERVICE", message: "Failed to get meeting service",
                    details: nil))
            return
        }

        meetingService.delegate = self

        isJoining = true
        NSLog("[ZoomBridge] Joining meeting: \(meetingNumber)")

        sendEvent(["status": "CONNECTING", "errorCode": 0, "message": "Connecting to meeting..."])

        let params = MobileRTCMeetingJoinParam()
        params.meetingNumber = meetingNumber
        params.password = passcode
        params.userName = displayName
        params.noAudio = false
        params.noVideo = false

        let joinResult = meetingService.joinMeeting(with: params)

        if joinResult == .success {
            NSLog("[ZoomBridge] Join meeting request sent successfully")
            result(["success": true, "message": "Join request sent"])
        } else {
            isJoining = false
            let errorMessage = getMeetingErrorMessage(joinResult)
            NSLog("[ZoomBridge] Join meeting failed: \(errorMessage)")
            result(
                FlutterError(
                    code: "JOIN_FAIL", message: errorMessage,
                    details: ["errorCode": joinResult.rawValue]))
            sendEvent([
                "status": "FAILED", "errorCode": joinResult.rawValue, "message": errorMessage,
            ])
        }
    }

    private func leaveMeeting(result: @escaping FlutterResult) {
        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            result(
                FlutterError(
                    code: "NO_MEETING_SERVICE", message: "Failed to get meeting service",
                    details: nil))
            return
        }

        let meetingState = meetingService.getMeetingState()
        if meetingState == .idle {
            NSLog("[ZoomBridge] Not in a meeting")
            result(["success": true, "message": "Not in a meeting"])
            return
        }

        NSLog("[ZoomBridge] Leaving meeting")
        meetingService.leaveMeeting(with: .leave)
        result(["success": true, "message": "Leave request sent"])
    }

    private func registerMeetingListeners() {
        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            NSLog("[ZoomBridge] Failed to get meeting service for listener registration")
            return
        }

        meetingService.delegate = self
        NSLog("[ZoomBridge] Meeting listeners registered")
    }

    private func sendEvent(_ event: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(event)
        }
    }

    private func getMeetingErrorMessage(_ error: MobileRTCMeetError) -> String {
        switch error {
        case .success:
            return "Success"
        case .connectionError:
            return "Network unavailable"
        case .reconnectError:
            return "Reconnection failed"
        case .mmrError:
            return "MMR error"
        case .passwordError:
            return "Incorrect passcode"
        case .sessionError:
            return "Session error"
        case .meetingOver:
            return "Meeting is over"
        case .meetingNotStart:
            return "Meeting not started"
        case .meetingNotExist:
            return "Meeting does not exist"
        case .meetingUserFull:
            return "Meeting is full"
        case .meetingClientIncompatible:
            return "Client incompatible"
        case .noMMR:
            return "No MMR"
        case .meetingLocked:
            return "Meeting is locked"
        case .meetingRestricted:
            return "Meeting is restricted"
        case .meetingRestrictedJBH:
            return "Join before host not allowed"
        case .cannotEmitWebRequest:
            return "Cannot emit web request"
        case .cannotStartTokenExpire:
            return "Token expired"
        case .videoError:
            return "Video error"
        case .audioAutoStartError:
            return "Audio auto start error"
        case .registerWebinarFull:
            return "Webinar is full"
        case .registerWebinarHostRegister:
            return "Host cannot register webinar"
        case .registerWebinarPanelistRegister:
            return "Panelist cannot register webinar"
        case .registerWebinarDeniedEmail:
            return "Email denied for webinar"
        case .registerWebinarEnforceLogin:
            return "Login required"
        case .invalidArguments:
            return "Invalid arguments"
        case .invalidUserType:
            return "Invalid user type"
        case .inAnotherMeeting:
            return "Already in another meeting"
        case .unknown:
            return "Unknown error"
        @unknown default:
            return "Meeting error code: \(error.rawValue)"
        }
    }

    private func getAuthErrorMessage(_ error: MobileRTCAuthError) -> String {
        switch error {
        case .success:
            return "Success"
        case .keyOrSecretEmpty:
            return "Key or secret empty"
        case .keyOrSecretWrong:
            return "Invalid or expired JWT token"
        case .accountNotSupport:
            return "Account not supported"
        case .accountNotEnableSDK:
            return "Account SDK not enabled"
        case .unknown:
            return "Unknown error"
        default:
            return "Auth error code: \(error.rawValue)"
        }
    }

    private func minimizeMeeting(result: @escaping FlutterResult) {
        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            NSLog("[ZoomBridge] Failed to get meeting service")
            result(
                FlutterError(
                    code: "NO_MEETING_SERVICE", message: "Failed to get meeting service",
                    details: nil))
            return
        }

        let meetingState = meetingService.getMeetingState()
        if meetingState == .idle {
            NSLog("[ZoomBridge] Not in a meeting")
            result(
                FlutterError(
                    code: "NOT_IN_MEETING", message: "Not currently in a meeting", details: nil))
            return
        }

        NSLog("[ZoomBridge] Minimizing meeting (hiding meeting view)")
        meetingService.hideMobileRTCMeeting {
            NSLog("[ZoomBridge] Meeting view hidden successfully")
        }
        result(["success": true, "message": "Meeting minimized"])
    }

    private func showMeeting(result: @escaping FlutterResult) {
        guard let meetingService = MobileRTC.shared().getMeetingService() else {
            NSLog("[ZoomBridge] Failed to get meeting service")
            result(
                FlutterError(
                    code: "NO_MEETING_SERVICE", message: "Failed to get meeting service",
                    details: nil))
            return
        }

        let meetingState = meetingService.getMeetingState()
        if meetingState == .idle {
            NSLog("[ZoomBridge] Not in a meeting")
            result(
                FlutterError(
                    code: "NOT_IN_MEETING", message: "Not currently in a meeting", details: nil))
            return
        }

        NSLog("[ZoomBridge] Showing meeting")
        meetingService.showMobileRTCMeeting {
            NSLog("[ZoomBridge] Meeting view shown successfully")
        }
        result(["success": true, "message": "Meeting view shown"])
    }
}

extension ZoomBridge: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        NSLog("[ZoomBridge] EventChannel listener attached")
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        NSLog("[ZoomBridge] EventChannel listener cancelled")
        return nil
    }
}

extension ZoomBridge: MobileRTCAuthDelegate {
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        isInitializing = false

        NSLog("[ZoomBridge] Auth returned: \(returnValue.rawValue)")

        if returnValue == .success {
            isInitialized = true
            NSLog("[ZoomBridge] Zoom SDK initialized successfully")

            registerMeetingListeners()

            initResult?(["success": true, "message": "SDK initialized"])
            initResult = nil

            sendEvent(["status": "IDLE", "errorCode": 0, "message": "SDK initialized"])

            if let pendingRequest = pendingJoinRequest {
                NSLog("[ZoomBridge] Processing pending join request")
                if let meetingNumber = pendingRequest["meetingNumber"] as? String,
                    let passcode = pendingRequest["passcode"] as? String,
                    let displayName = pendingRequest["displayName"] as? String,
                    let resultWrapper = pendingRequest["result"] as? FlutterResultWrapper
                {
                    joinMeeting(
                        meetingNumber: meetingNumber, passcode: passcode, displayName: displayName,
                        result: resultWrapper.result)
                }
                pendingJoinRequest = nil
            }
        } else {
            let errorMessage = getAuthErrorMessage(returnValue)
            NSLog("[ZoomBridge] Auth failed: \(errorMessage)")

            let error = FlutterError(
                code: "AUTH_FAILED", message: errorMessage,
                details: ["errorCode": returnValue.rawValue])
            initResult?(error)
            initResult = nil

            if returnValue == .keyOrSecretWrong {
                sendEvent([
                    "status": "FAILED", "errorCode": returnValue.rawValue,
                    "message": "JWT token is invalid or expired",
                ])
            } else {
                sendEvent([
                    "status": "FAILED", "errorCode": returnValue.rawValue, "message": errorMessage,
                ])
            }
        }
    }

    func onMobileRTCLoginReturn(_ returnValue: Int) {
    }

    func onMobileRTCLogoutReturn(_ returnValue: Int) {
    }
}

extension ZoomBridge: MobileRTCMeetingServiceDelegate {
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        NSLog("[ZoomBridge] Meeting state changed: \(state.rawValue)")

        let statusString: String
        switch state {
        case .idle:
            isJoining = false
            statusString = "IDLE"
        case .connecting:
            statusString = "CONNECTING"
        case .waitingForHost:
            statusString = "WAITING_FOR_HOST"
        case .inMeeting:
            isJoining = false
            statusString = "IN_MEETING"
        case .disconnecting:
            statusString = "DISCONNECTING"
        case .reconnecting:
            statusString = "RECONNECTING"
        case .failed:
            isJoining = false
            statusString = "FAILED"
        case .ended:
            isJoining = false
            statusString = "ENDED"
        case .locked:
            statusString = "LOCKED"
        case .unlocked:
            statusString = "UNLOCKED"
        case .inWaitingRoom:
            statusString = "IN_WAITING_ROOM"
        case .webinarPromote:
            statusString = "WEBINAR_PROMOTE"
        case .webinarDePromote:
            statusString = "WEBINAR_DEPROMOTE"
        case .joinBO:
            statusString = "JOIN_BREAKOUT_ROOM"
        case .leaveBO:
            statusString = "LEAVE_BREAKOUT_ROOM"
        @unknown default:
            statusString = "UNKNOWN"
        }

        sendEvent(["status": statusString, "errorCode": 0])
    }

    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        isJoining = false

        let errorMessage = message ?? getMeetingErrorMessage(error)
        NSLog("[ZoomBridge] Meeting error: \(errorMessage) (code: \(error.rawValue))")

        sendEvent([
            "status": "FAILED",
            "errorCode": error.rawValue,
            "message": errorMessage,
        ])
    }

    func onJoinMeetingConfirmed() {
        NSLog("[ZoomBridge] Join meeting confirmed")
    }

    func onMeetingEndedReason(_ reason: MobileRTCMeetingEndReason) {
        isJoining = false

        NSLog("[ZoomBridge] Meeting ended with reason: \(reason.rawValue)")

        let message: String
        switch reason {
        case .none:
            message = "User left meeting"
        case .removedByHost:
            message = "Removed by host"
        case .endByHost:
            message = "Meeting ended by host"
        case .jbhTimeout:
            message = "Join before host timeout"
        case .freeMeetingTimeout:
            message = "Free meeting time limit reached"
        case .noAteendee:
            message = "No attendees in meeting"
        case .hostEndForAnotherMeeting:
            message = "Host started another meeting"
        case .undefined:
            message = "Meeting ended"
        @unknown default:
            message = "Meeting ended"
        }

        sendEvent([
            "status": "ENDED",
            "errorCode": 0,
            "message": message,
        ])
    }
}

class FlutterResultWrapper {
    let result: FlutterResult

    init(result: @escaping FlutterResult) {
        self.result = result
    }
}
