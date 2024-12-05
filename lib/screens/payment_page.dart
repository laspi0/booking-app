import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  Future<void> initiatePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://www.pay.moneyfusion.net/immo/90c545e1d30b5cc3/pay/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'totalPrice': 200,
          'article': [{'sac': 100, 'chaussure': 100}],
          'personal_Info': [{'userId': 1, 'orderId': 123}],
          'numeroSend': '0101010101',
          'nomclient': 'John Doe',
          'return_url': 'https://votre-site-de-retour.com/payment-return',
          'currency': 'XOF',
          'country': 'CI'
        }),
      );

      final paymentData = jsonDecode(response.body);

      if (paymentData['statut'] == true && paymentData['url'] != null) {
        final Uri url = Uri.parse(paymentData['url']);
        try {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } catch (e) {
          _showErrorSnackBar('Impossible d\'ouvrir l\'URL de paiement: $e');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erreur de connexion: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Procéder au paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  final String token;

  const PaymentWebView({Key? key, required this.url, required this.token})
      : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    print('URL dans WebView : ${widget.url}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Chargement de l\'URL : $url');
          },
          onPageFinished: (String url) {
            print('Chargement terminé : $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Erreur de chargement : ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation vers : ${request.url}');
            if (request.url.startsWith(
                'https://votre-site-de-retour.com/payment-return')) {
              _verifyPaymentStatus();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _verifyPaymentStatus() async {
    try {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement vérifié avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur de vérification: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
