import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _scanning = false;
  bool _canImport = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canImport = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _scanning
              ? _buildScanner(context)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Import Game State",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Paste your GameState string here",
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan QR Code"),
                      onPressed: () {
                        setState(() => _scanning = true);
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Import"),
                          onPressed: _canImport
                              ? () {
                                  final text = _controller.text.trim();
                                  if (text.isNotEmpty) {
                                    Navigator.of(context).pop(text);
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Scan QR Code",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: MobileScanner(
            key: GlobalKey(debugLabel: 'QR'),
            onDetect: (result) {
              var scanData = result.barcodes.first.rawValue;
              if (scanData != null) {
                Navigator.of(context).pop(scanData);
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.close),
          label: const Text("Cancel"),
          onPressed: () => setState(() => _scanning = false),
        ),
      ],
    );
  }
}
