import Flutter
import UserNotifications
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let deepLinkChannelName = "dk.kopa.app/deep_links"
  private let deepLinkEventChannelName = "dk.kopa.app/deep_link_events"
  private var initialDeepLink: String?
  private var deepLinkEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(
        name: deepLinkChannelName,
        binaryMessenger: controller.binaryMessenger
      ).setMethodCallHandler { [weak self] call, result in
        guard call.method == "getInitialLink" else {
          result(FlutterMethodNotImplemented)
          return
        }

        result(self?.initialDeepLink)
        self?.initialDeepLink = nil
      }

      FlutterEventChannel(
        name: deepLinkEventChannelName,
        binaryMessenger: controller.binaryMessenger
      ).setStreamHandler(self)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL,
       handleKopaDeepLink(url) {
      return true
    }

    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleKopaDeepLink(url) {
      return true
    }

    return super.application(app, open: url, options: options)
  }

  private func handleKopaDeepLink(_ url: URL) -> Bool {
    guard isKopaInviteLink(url) else {
      return false
    }

    let link = url.absoluteString
    if let deepLinkEventSink {
      deepLinkEventSink(link)
    } else {
      initialDeepLink = link
    }
    return true
  }

  private func isKopaInviteLink(_ url: URL) -> Bool {
    let path = url.path

    if url.scheme == "https", url.host == "kopa.dk" {
      return path == "/join"
    }

    if url.scheme == "kopa" {
      if url.host == "kopa.dk" {
        return path == "/join"
      }

      return url.host == "join" || path == "/join"
    }

    return false
  }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    deepLinkEventSink = events

    if let initialDeepLink {
      events(initialDeepLink)
      self.initialDeepLink = nil
    }

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    deepLinkEventSink = nil
    return nil
  }
}
