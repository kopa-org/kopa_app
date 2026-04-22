import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/main.dart';
import 'package:kopa/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> logout() async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.logout();

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (context.mounted) context.go('/login');
      } else {
        setState(() {
          _errorMessage = 'Brugeren kunne ikke logges ud.';
        });
      }
    }

    return SizedBox(
        height: double.infinity,
        child: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGrey6,
            child: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Column(children: <Widget>[
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                                color: theme.colorScheme.error, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _isLoading
                          ? const LoadingIndicator()
                          : FullWidthButton(
                              buttonText: 'Log ud',
                              onPressed: logout,
                            ),
                    ])))));
  }
}
