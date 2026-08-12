package dk.kopa.app

import android.content.Intent
import android.net.Uri
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val deepLinkChannelName = "dk.kopa.app/deep_links"
    private val deepLinkEventChannelName = "dk.kopa.app/deep_link_events"
    private val deepLinkPreferencesName = "dk.kopa.app.deep_links"
    private val installReferrerConsumedKey = "install_referrer_consumed"
    private var initialDeepLink: String? = null
    private var eventSink: EventChannel.EventSink? = null
    private var installReferrerClient: InstallReferrerClient? = null
    private var installReferrerLookupStarted = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initialDeepLink = deepLinkFromIntent(intent)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deepLinkChannelName
        ).setMethodCallHandler { call, result ->
            if (call.method != "getInitialLink") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val launchLink = initialDeepLink
            if (launchLink != null) {
                initialDeepLink = null
                result.success(launchLink)
                return@setMethodCallHandler
            }

            getInstallReferrerDeepLink(result)
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deepLinkEventChannelName
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                initialDeepLink?.let {
                    events?.success(it)
                    initialDeepLink = null
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val link = deepLinkFromIntent(intent) ?: return
        if (eventSink != null) {
            eventSink?.success(link)
        } else {
            initialDeepLink = link
        }
    }

    override fun onDestroy() {
        installReferrerClient?.endConnection()
        installReferrerClient = null
        super.onDestroy()
    }

    private fun getInstallReferrerDeepLink(result: MethodChannel.Result) {
        if (installReferrerLookupStarted || hasConsumedInstallReferrer()) {
            result.success(null)
            return
        }

        installReferrerLookupStarted = true
        val client = InstallReferrerClient.newBuilder(this).build()
        installReferrerClient = client

        client.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                if (responseCode != InstallReferrerClient.InstallReferrerResponse.OK) {
                    result.success(null)
                    closeInstallReferrer()
                    return
                }

                val details: ReferrerDetails = try {
                    client.installReferrer
                } catch (_: RuntimeException) {
                    result.success(null)
                    closeInstallReferrer()
                    return
                }

                markInstallReferrerConsumed()
                result.success(deepLinkFromInstallReferrer(details.installReferrer))
                closeInstallReferrer()
            }

            override fun onInstallReferrerServiceDisconnected() {
                closeInstallReferrer()
            }
        })
    }

    private fun closeInstallReferrer() {
        installReferrerClient?.endConnection()
        installReferrerClient = null
    }

    private fun hasConsumedInstallReferrer(): Boolean {
        return getSharedPreferences(deepLinkPreferencesName, MODE_PRIVATE)
            .getBoolean(installReferrerConsumedKey, false)
    }

    private fun markInstallReferrerConsumed() {
        getSharedPreferences(deepLinkPreferencesName, MODE_PRIVATE)
            .edit()
            .putBoolean(installReferrerConsumedKey, true)
            .apply()
    }

    private fun deepLinkFromIntent(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null

        val uri = intent.data ?: return null
        return if (isKopaInviteLink(uri)) uri.toString() else null
    }

    private fun deepLinkFromInstallReferrer(referrer: String?): String? {
        if (referrer.isNullOrBlank()) return null

        val directLink = listOf(referrer, Uri.decode(referrer))
            .firstNotNullOfOrNull { candidate ->
                val uri = Uri.parse(candidate)
                if (isKopaInviteLink(uri)) uri.toString() else null
            }
        if (directLink != null) return directLink

        return listOf(referrer, Uri.decode(referrer))
            .firstNotNullOfOrNull { candidate ->
                val link = Uri.parse("https://kopa.dk/?$candidate")
                    .getQueryParameter("link")
                    ?: return@firstNotNullOfOrNull null
                val linkUri = Uri.parse(link)

                if (isKopaInviteLink(linkUri)) linkUri.toString() else null
            }
    }

    private fun isKopaInviteLink(uri: Uri): Boolean {
        val path = uri.path.orEmpty()

        if (uri.scheme == "https" && uri.host == "kopa.dk") {
            return path == "/join" || path == "/invite"
        }

        if (uri.scheme == "kopa") {
            if (uri.host == "kopa.dk") {
                return path == "/join" || path == "/invite"
            }

            return uri.host == "join" || uri.host == "invite" ||
                path == "/join" || path == "/invite"
        }

        return false
    }
}
