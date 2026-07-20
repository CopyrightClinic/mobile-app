package com.brainx.copyrightclinic

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import us.zoom.sdk.*

class ZoomBridge(
        private val context: Context,
        private val methodChannel: MethodChannel,
        private val eventChannel: EventChannel
) {
    private val TAG = "ZoomBridge"
    private var eventSink: EventChannel.EventSink? = null
    private var isInitialized = false
    private var isInitializing = false
    private var isJoining = false
    private var pendingJoinRequest: Map<String, Any>? = null

    private val zoomSDK: ZoomSDK
        get() = ZoomSDK.getInstance()

    init {
        setupEventChannel()
        logSdkVersion()
    }

    private fun setupEventChannel() {
        eventChannel.setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                        Log.d(TAG, "EventChannel listener attached")
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink = null
                        Log.d(TAG, "EventChannel listener cancelled")
                    }
                }
        )
    }

    private fun logSdkVersion() {
        try {
            Log.i(TAG, "Zoom Meeting SDK v6.6.0 initialized")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to log SDK info: ${e.message}")
        }
    }

    fun handleMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initZoom" -> {
                val jwt = call.argument<String>("jwt")
                if (jwt.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "JWT token is required", null)
                    return
                }
                initZoom(jwt, result)
            }
            "joinMeeting" -> {
                val meetingNumber = call.argument<String>("meetingNumber")
                val passcode = call.argument<String>("passcode")
                val displayName = call.argument<String>("displayName")

                if (meetingNumber.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "Meeting number is required", null)
                    return
                }
                if (displayName.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "Display name is required", null)
                    return
                }

                joinMeeting(meetingNumber, passcode ?: "", displayName, result)
            }
            "leaveMeeting" -> {
                leaveMeeting(result)
            }
            "getSdkVersion" -> {
                try {
                    result.success("6.5.10")
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get SDK version: ${e.message}", null)
                }
            }
            "minimizeMeeting" -> {
                minimizeMeeting(result)
            }
            "showMeeting" -> {
                showMeeting(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initZoom(jwt: String, result: MethodChannel.Result) {
        if (isInitialized) {
            Log.d(TAG, "Zoom SDK already initialized")
            result.success(mapOf("success" to true, "message" to "Already initialized"))

            if (pendingJoinRequest != null) {
                val request = pendingJoinRequest!!
                pendingJoinRequest = null
                joinMeeting(
                        request["meetingNumber"] as String,
                        request["passcode"] as String,
                        request["displayName"] as String,
                        request["result"] as MethodChannel.Result
                )
            }
            return
        }

        if (isInitializing) {
            Log.d(TAG, "Initialization already in progress")
            result.error("ALREADY_INITIALIZING", "SDK initialization already in progress", null)
            return
        }

        isInitializing = true
        Log.d(TAG, "Initializing Zoom SDK with JWT")

        val params =
                ZoomSDKInitParams().apply {
                    jwtToken = jwt
                    domain = "zoom.us"
                    enableLog = true
                }

        val initListener =
                object : ZoomSDKInitializeListener {
                    override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
                        isInitializing = false

                        when (errorCode) {
                            ZoomError.ZOOM_ERROR_SUCCESS -> {
                                isInitialized = true
                                Log.i(TAG, "Zoom SDK initialized successfully")

                                registerMeetingListeners()

                                result.success(
                                        mapOf(
                                                "success" to true,
                                                "message" to "Initialized successfully"
                                        )
                                )

                                if (pendingJoinRequest != null) {
                                    val request = pendingJoinRequest!!
                                    pendingJoinRequest = null
                                    joinMeeting(
                                            request["meetingNumber"] as String,
                                            request["passcode"] as String,
                                            request["displayName"] as String,
                                            request["result"] as MethodChannel.Result
                                    )
                                }
                            }
                            ZoomError.ZOOM_ERROR_ILLEGAL_APP_KEY_OR_SECRET -> {
                                Log.e(TAG, "JWT token is invalid or expired")
                                result.error(
                                        "JWT_INVALID",
                                        "JWT token is invalid or expired. Please fetch a fresh token.",
                                        mapOf(
                                                "errorCode" to errorCode,
                                                "internalErrorCode" to internalErrorCode
                                        )
                                )
                                sendEvent(
                                        mapOf(
                                                "status" to "FAILED",
                                                "errorCode" to errorCode,
                                                "message" to "JWT token is invalid or expired"
                                        )
                                )
                            }
                            ZoomError.ZOOM_ERROR_NETWORK_UNAVAILABLE -> {
                                Log.e(TAG, "Network unavailable during initialization")
                                result.error(
                                        "NETWORK_UNAVAILABLE",
                                        "Network unavailable. Please check your connection.",
                                        mapOf(
                                                "errorCode" to errorCode,
                                                "internalErrorCode" to internalErrorCode
                                        )
                                )
                            }
                            else -> {
                                val errorMessage = getInitErrorMessage(errorCode)
                                Log.e(
                                        TAG,
                                        "Zoom SDK initialization failed: $errorMessage (code: $errorCode, internal: $internalErrorCode)"
                                )
                                result.error(
                                        "INIT_FAILED",
                                        errorMessage,
                                        mapOf(
                                                "errorCode" to errorCode,
                                                "internalErrorCode" to internalErrorCode
                                        )
                                )
                            }
                        }
                    }

                    override fun onZoomAuthIdentityExpired() {
                        Log.w(TAG, "Zoom auth identity expired")
                        isInitialized = false
                        sendEvent(
                                mapOf(
                                        "status" to "AUTH_EXPIRED",
                                        "message" to "Authentication expired. Please re-initialize."
                                )
                        )
                    }
                }

        try {
            zoomSDK.initialize(context, initListener, params)
        } catch (e: Exception) {
            isInitializing = false
            Log.e(TAG, "Exception during initialization: ${e.message}", e)
            result.error("INIT_EXCEPTION", "Initialization exception: ${e.message}", null)
        }
    }

    private fun registerMeetingListeners() {
        try {
            val meetingService = zoomSDK.meetingService
            meetingService?.addListener(
                    object : MeetingServiceListener {
                        override fun onMeetingParameterNotification(
                                meetingParameter: MeetingParameter?
                        ) {
                            // Optional: handle meeting parameter notifications
                        }

                        override fun onMeetingStatusChanged(
                                status: MeetingStatus?,
                                errorCode: Int,
                                internalErrorCode: Int
                        ) {
                            Log.d(
                                    TAG,
                                    "Meeting status changed: $status, error: $errorCode, internal: $internalErrorCode"
                            )

                            val statusString =
                                    when (status) {
                                        MeetingStatus.MEETING_STATUS_IDLE -> "IDLE"
                                        MeetingStatus.MEETING_STATUS_CONNECTING -> "CONNECTING"
                                        MeetingStatus.MEETING_STATUS_WAITINGFORHOST ->
                                                "WAITING_FOR_HOST"
                                        MeetingStatus.MEETING_STATUS_INMEETING -> {
                                            isJoining = false
                                            "IN_MEETING"
                                        }
                                        MeetingStatus.MEETING_STATUS_DISCONNECTING ->
                                                "DISCONNECTING"
                                        MeetingStatus.MEETING_STATUS_RECONNECTING -> "RECONNECTING"
                                        MeetingStatus.MEETING_STATUS_FAILED -> {
                                            isJoining = false
                                            "FAILED"
                                        }
                                        MeetingStatus.MEETING_STATUS_ENDED -> {
                                            isJoining = false
                                            "ENDED"
                                        }
                                        MeetingStatus.MEETING_STATUS_UNKNOWN -> "UNKNOWN"
                                        MeetingStatus.MEETING_STATUS_LOCKED -> "LOCKED"
                                        MeetingStatus.MEETING_STATUS_UNLOCKED -> "UNLOCKED"
                                        MeetingStatus.MEETING_STATUS_IN_WAITING_ROOM ->
                                                "IN_WAITING_ROOM"
                                        MeetingStatus.MEETING_STATUS_WEBINAR_PROMOTE ->
                                                "WEBINAR_PROMOTE"
                                        MeetingStatus.MEETING_STATUS_WEBINAR_DEPROMOTE ->
                                                "WEBINAR_DEPROMOTE"
                                        MeetingStatus.MEETING_STATUS_JOIN_BREAKOUT_ROOM ->
                                                "JOIN_BREAKOUT_ROOM"
                                        MeetingStatus.MEETING_STATUS_LEAVE_BREAKOUT_ROOM ->
                                                "LEAVE_BREAKOUT_ROOM"
                                        else -> "UNKNOWN"
                                    }

                            val event =
                                    mutableMapOf<String, Any>(
                                            "status" to statusString,
                                            "errorCode" to errorCode
                                    )

                            if (errorCode != MeetingError.MEETING_ERROR_SUCCESS) {
                                val errorMessage = getMeetingErrorMessage(errorCode)
                                event["message"] = errorMessage
                                Log.e(TAG, "Meeting error: $errorMessage (code: $errorCode)")
                            }

                            sendEvent(event)
                        }
                    }
            )

            Log.d(TAG, "Meeting listeners registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register meeting listeners: ${e.message}", e)
        }
    }

    private fun joinMeeting(
            meetingNumber: String,
            passcode: String,
            displayName: String,
            result: MethodChannel.Result
    ) {
        if (!isInitialized) {
            if (isInitializing) {
                Log.d(TAG, "Queuing join request until initialization completes")
                pendingJoinRequest =
                        mapOf(
                                "meetingNumber" to meetingNumber,
                                "passcode" to passcode,
                                "displayName" to displayName,
                                "result" to result
                        )
                return
            }

            Log.e(TAG, "Cannot join meeting: SDK not initialized")
            result.error("NOT_INITIALIZED", "SDK not initialized. Call initZoom first.", null)
            return
        }

        if (isJoining) {
            Log.d(TAG, "Join already in progress")
            result.error("ALREADY_JOINING", "Join meeting already in progress", null)
            return
        }

        val meetingService = zoomSDK.meetingService
        if (meetingService == null) {
            Log.e(TAG, "Meeting service is null")
            result.error("SERVICE_UNAVAILABLE", "Meeting service unavailable", null)
            return
        }

        val meetingStatus = meetingService.meetingStatus
        if (meetingStatus != null && meetingStatus != MeetingStatus.MEETING_STATUS_IDLE) {
            Log.d(TAG, "Already in a meeting or connecting. Current status: $meetingStatus")
            result.error("ALREADY_IN_MEETING", "Already in a meeting or connecting", null)
            return
        }

        isJoining = true
        Log.d(TAG, "Joining meeting: $meetingNumber as $displayName")

        val options =
                JoinMeetingOptions().apply {
                    no_driving_mode = true
                    no_invite = true
                    no_meeting_end_message = false
                    no_meeting_error_message = false
                }

        val params =
                JoinMeetingParams().apply {
                    this.meetingNo = meetingNumber
                    this.password = passcode
                    this.displayName = displayName
                }

        val joinResult = meetingService.joinMeetingWithParams(context, params, options)

        when (joinResult) {
            MeetingError.MEETING_ERROR_SUCCESS -> {
                Log.d(TAG, "Join meeting request sent successfully")
                result.success(mapOf("success" to true, "message" to "Join request sent"))
            }
            MeetingError.MEETING_ERROR_INVALID_ARGUMENTS -> {
                isJoining = false
                Log.e(TAG, "Invalid meeting arguments")
                result.error("INVALID_ARGUMENTS", "Invalid meeting number or passcode", null)
            }
            MeetingError.MEETING_ERROR_NETWORK_UNAVAILABLE -> {
                isJoining = false
                Log.e(TAG, "Network unavailable")
                result.error("NETWORK_UNAVAILABLE", "Network unavailable", null)
            }
            else -> {
                isJoining = false
                val errorMessage = getMeetingErrorMessage(joinResult)
                Log.e(TAG, "Join meeting failed: $errorMessage (code: $joinResult)")
                result.error("JOIN_FAILED", errorMessage, mapOf("errorCode" to joinResult))
            }
        }
    }

    private fun leaveMeeting(result: MethodChannel.Result) {
        try {
            val meetingService = zoomSDK.meetingService
            if (meetingService == null) {
                result.success(mapOf("success" to true, "message" to "No meeting service"))
                return
            }

            val meetingStatus = meetingService.meetingStatus
            if (meetingStatus == null || meetingStatus == MeetingStatus.MEETING_STATUS_IDLE) {
                result.success(mapOf("success" to true, "message" to "Not in a meeting"))
                return
            }

            Log.d(TAG, "Leaving meeting")
            meetingService.leaveCurrentMeeting(false)
            isJoining = false
            result.success(mapOf("success" to true, "message" to "Left meeting"))
        } catch (e: Exception) {
            Log.e(TAG, "Error leaving meeting: ${e.message}", e)
            result.error("ERROR", "Failed to leave meeting: ${e.message}", null)
        }
    }

    private fun sendEvent(event: Map<String, Any>) {
        eventSink?.success(event)
    }

    private fun getInitErrorMessage(errorCode: Int): String {
        return when (errorCode) {
            ZoomError.ZOOM_ERROR_SUCCESS -> "Success"
            ZoomError.ZOOM_ERROR_DEVICE_NOT_SUPPORTED -> "Device not supported"
            ZoomError.ZOOM_ERROR_ILLEGAL_APP_KEY_OR_SECRET -> "Invalid or expired JWT token"
            ZoomError.ZOOM_ERROR_NETWORK_UNAVAILABLE -> "Network unavailable"
            ZoomError.ZOOM_ERROR_UNKNOWN -> "Unknown error"
            else -> "Initialization error code: $errorCode"
        }
    }

    private fun getMeetingErrorMessage(errorCode: Int): String {
        return when (errorCode) {
            MeetingError.MEETING_ERROR_SUCCESS -> "Success"
            MeetingError.MEETING_ERROR_NETWORK_UNAVAILABLE -> "Network unavailable"
            MeetingError.MEETING_ERROR_INVALID_ARGUMENTS -> "Invalid arguments"
            MeetingError.MEETING_ERROR_MEETING_NOT_EXIST -> "Meeting does not exist"
            MeetingError.MEETING_ERROR_INCORRECT_MEETING_NUMBER -> "Incorrect meeting number"
            MeetingError.MEETING_ERROR_MEETING_OVER -> "Meeting is over"
            MeetingError.MEETING_ERROR_LOCKED -> "Meeting is locked"
            MeetingError.MEETING_ERROR_RESTRICTED -> "Meeting is restricted"
            MeetingError.MEETING_ERROR_RESTRICTED_JBH -> "Join before host not allowed"
            MeetingError.MEETING_ERROR_INVALID_STATUS -> "Invalid status"
            MeetingError.MEETING_ERROR_EXIT_WHEN_WAITING_HOST_START ->
                    "Exited while waiting for host"
            else -> "Meeting error code: $errorCode"
        }
    }

    private fun minimizeMeeting(result: MethodChannel.Result) {
        try {
            val meetingService = zoomSDK.meetingService
            if (meetingService == null) {
                result.error("NO_SERVICE", "Meeting service unavailable", null)
                return
            }

            val meetingStatus = meetingService.meetingStatus
            if (meetingStatus == null || meetingStatus == MeetingStatus.MEETING_STATUS_IDLE) {
                result.error("NOT_IN_MEETING", "Not currently in a meeting", null)
                return
            }

            Log.d(TAG, "Minimizing meeting - bringing Flutter app to front")
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                intent.addFlags(android.content.Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                context.startActivity(intent)
                result.success(mapOf("success" to true, "message" to "Meeting minimized"))
            } else {
                result.error("ERROR", "Could not get launch intent", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error minimizing meeting: ${e.message}", e)
            result.error("ERROR", "Failed to minimize meeting: ${e.message}", null)
        }
    }

    private fun showMeeting(result: MethodChannel.Result) {
        try {
            val meetingService = zoomSDK.meetingService
            if (meetingService == null) {
                result.error("NO_SERVICE", "Meeting service unavailable", null)
                return
            }

            val meetingStatus = meetingService.meetingStatus
            if (meetingStatus == null || meetingStatus == MeetingStatus.MEETING_STATUS_IDLE) {
                result.error("NOT_IN_MEETING", "Not currently in a meeting", null)
                return
            }

            Log.d(TAG, "Showing meeting - moving app to background to reveal Zoom")
            if (context is android.app.Activity) {
                (context as android.app.Activity).moveTaskToBack(true)
                result.success(mapOf("success" to true, "message" to "Meeting view shown"))
            } else {
                result.error("ERROR", "Context is not an Activity", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error showing meeting: ${e.message}", e)
            result.error("ERROR", "Failed to show meeting: ${e.message}", null)
        }
    }
}
