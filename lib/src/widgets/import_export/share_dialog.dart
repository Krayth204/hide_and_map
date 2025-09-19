import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareDialog extends StatelessWidget {
  final String base64String;

  const ShareDialog({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share Game State",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      base64String,
                      style: const TextStyle(fontSize: 14, overflow: TextOverflow.fade),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: "Copy to clipboard",
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: base64String));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("Share"),
                onPressed: () =>
                    SharePlus.instance.share(ShareParams(text: base64String)),
              ),

              const SizedBox(height: 16),

              if (base64String.length <= 2900)
                Center(
                  child: QrImageView(
                    data: base64String,
                    version: QrVersions.auto,
                    size: 250,
                  ),
                )
              else
                Center(
                  child: const Text(
                    "Game File to big for QR Code",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
