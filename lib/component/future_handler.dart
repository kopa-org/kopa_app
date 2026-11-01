import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/loading_indicator.dart';

class FutureHandler<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) onSuccess;
  final Widget Function(BuildContext)? onError;
  final Widget? loadingIndicator;
  final String? noDataFoundMessage;
  final bool allowEmpty;

  FutureHandler({
    required this.future,
    required this.onSuccess,
    this.onError,
    this.loadingIndicator,
    this.noDataFoundMessage,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingIndicator ?? LoadingIndicator();
        }

        if (snapshot.hasError) {
          if (onError != null) return onError!(context);
          return ErrorMessage(
            message: AppLocalizations.of(context)!
                .uiSomethingWentWrongPleaseTryAgain,
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text((noDataFoundMessage ??
                AppLocalizations.of(context)!.uiNoDataAvailable)),
          );
        }

        final data = snapshot.data as T;
        if (!allowEmpty && data is List && data.isEmpty) {
          return Center(
            child: Text((noDataFoundMessage ??
                AppLocalizations.of(context)!.uiNoDataAvailable)),
          );
        }

        return onSuccess(context, data);
      },
    );
  }
}
