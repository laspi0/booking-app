import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final int id;

  const PaymentPage({Key? key, required this.id}) : super(key: key);

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
      print('Début de la requête de paiement');
      
      final response = await http.post(
        Uri.parse('https://www.pay.moneyfusion.net/immo/90c545e1d30b5cc3/pay/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'totalPrice': 200,
          'article': [{
            'sac': 100,
            'chaussure': 100
          }],
          'personal_Info': [{
            'userId': 1,
            'orderId': 123
          }],
          'numeroSend': '0101010101',
          'nomclient': 'John Doe',
          'return_url': 'https://votre-site-de-retour.com/payment-return',
          'currency': 'XOF',
          'country': 'CI'
        }),
      );

      print('Statut de la réponse : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');

      if (response.statusCode == 200) {
        final paymentData = jsonDecode(response.body);
        
        print('Données de paiement : $paymentData');

        if (paymentData['statut'] == true && paymentData['url'] != null) {
          print('URL de paiement : ${paymentData['url']}');
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebView(
                url: paymentData['url'],
                token: paymentData['token'],
              ),
            ),
          );
        } else {
          _showErrorSnackBar('Impossible de traiter le paiement');
        }
      } else {
        _showErrorSnackBar('Erreur de serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur complète : $e');
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

  const PaymentWebView({Key? key, required this.url, required this.token}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            print('Chargement de l\'URL : $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            print('Chargement terminé : $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Erreur de chargement : ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation vers : ${request.url}');
            
            // Gestion des liens mobile money et autres liens externes
            if (request.url.startsWith('intent://') ||
                request.url.startsWith('mtn://') ||
                request.url.startsWith('orange://') ||
                request.url.startsWith('moov://') ||
                request.url.startsWith('wave://') ||
                !request.url.startsWith('http')) {
              _handleExternalLink(request.url);
              return NavigationDecision.prevent;
            }
            
            // Gestion du retour après paiement
            if (request.url.startsWith('https://votre-site-de-retour.com/payment-return')) {
              _verifyPaymentStatus();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _verifyPaymentStatus() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paiement vérifié avec succès'))
    );
  }
    Future<void> _handleExternalLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir l\'application: ${e.toString()}')),
        );
      }
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}