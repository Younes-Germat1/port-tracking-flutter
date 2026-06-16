import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../services/inspection_service.dart';
import '../../models/inspection.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;
  bool _loading = false;
  String? _error;
  bool _torchOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _loading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    setState(() {
      _scanned = true;
      _loading = true;
      _error = null;
    });

    await cameraController.stop();

    try {
      int? conteneurId;
      if (rawValue.contains('conteneur:')) {
        conteneurId = int.tryParse(rawValue.split('conteneur:').last);
      } else {
        conteneurId = int.tryParse(rawValue);
      }

      if (conteneurId == null) {
        setState(() {
          _error = 'QR Code invalide';
          _loading = false;
          _scanned = false;
        });
        await cameraController.start();
        return;
      }

      setState(() => _loading = false);
      _showConteneurDetails(conteneurId);
    } catch (e) {
      setState(() {
        _error = 'Erreur: ${e.toString()}';
        _loading = false;
        _scanned = false;
      });
      await cameraController.start();
    }
  }

  void _showConteneurDetails(int conteneurId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConteneurBottomSheet(
        conteneurId: conteneurId,
        onClose: () {
          Navigator.pop(ctx);
          setState(() => _scanned = false);
          cameraController.start();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Dark overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Futuristic corners
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0,
                    child: _Corner(top: true, left: true),
                  ),
                  Positioned(
                    top: 0, right: 0,
                    child: _Corner(top: true, left: false),
                  ),
                  Positioned(
                    bottom: 0, left: 0,
                    child: _Corner(top: false, left: true),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: _Corner(top: false, left: false),
                  ),
                ],
              ),
            ),
          ),

          // Scan line animation
          if (!_scanned) _ScanLine(),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton retour
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                    ),

                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Scanner QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // Torch
                    GestureDetector(
                      onTap: () {
                        cameraController.toggleTorch();
                        setState(() => _torchOn = !_torchOn);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _torchOn
                              ? const Color(0xFF2563EB)
                              : Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _torchOn
                                  ? const Color(0xFF2563EB)
                                  : Colors.white.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _torchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(
              children: [
                if (_loading)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Chargement...',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                else if (_error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(_error!,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      const Icon(Icons.qr_code_scanner,
                          color: Colors.white54, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Pointez vers le QR code du conteneur',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;

  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40, height: 40,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, 30);
      path.lineTo(0, 0);
      path.lineTo(30, 0);
    } else if (top && !left) {
      path.moveTo(size.width - 30, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, 30);
    } else if (!top && left) {
      path.moveTo(0, size.height - 30);
      path.lineTo(0, size.height);
      path.lineTo(30, size.height);
    } else {
      path.moveTo(size.width - 30, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - 30);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260, height: 260,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ScanLinePainter(_animation.value),
            );
          },
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF2563EB).withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = size.height * progress;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConteneurBottomSheet extends StatefulWidget {
  final int conteneurId;
  final VoidCallback onClose;

  const _ConteneurBottomSheet({
    required this.conteneurId,
    required this.onClose,
  });

  @override
  State<_ConteneurBottomSheet> createState() =>
      _ConteneurBottomSheetState();
}

class _ConteneurBottomSheetState extends State<_ConteneurBottomSheet> {
  List<Inspection> _inspections = [];
  bool _loading = true;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    try {
      final all = await InspectionService.getAllInspections();
      setState(() {
        _inspections = all
            .where((i) => i.conteneurId == widget.conteneurId)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _enregistrerResultat(
      int inspectionId, String resultat) async {
    try {
      await InspectionService.enregistrerResultat(
          inspectionId, resultat, _commentCtrl.text);
      await _loadInspections();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultat == 'CONFORME'
                ? '✅ Marqué comme Conforme'
                : '❌ Marqué comme Non Conforme'),
            backgroundColor: resultat == 'CONFORME'
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conteneur #${widget.conteneurId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('QR Code scanné ✅',
                          style: TextStyle(
                              color: Color(0xFF16A34A), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const Divider(height: 24),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_inspections.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune inspection pour ce conteneur',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            )
          else ...[
              const Text('Inspections assignées',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              ...(_inspections.map((ins) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${ins.organisme ?? '-'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ins.resultat == 'CONFORME'
                                  ? const Color(0xFFF0FDF4)
                                  : ins.resultat == 'NON_CONFORME'
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ins.resultat == 'CONFORME'
                                  ? '✅ Conforme'
                                  : ins.resultat == 'NON_CONFORME'
                                  ? '❌ Non Conforme'
                                  : '⏳ En Attente',
                              style: TextStyle(
                                color: ins.resultat == 'CONFORME'
                                    ? const Color(0xFF16A34A)
                                    : ins.resultat == 'NON_CONFORME'
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFD97706),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (ins.resultat == null) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Commentaire optionnel...',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _enregistrerResultat(
                                        ins.id, 'CONFORME'),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Conforme'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _enregistrerResultat(
                                        ins.id, 'NON_CONFORME'),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Non Conforme'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ))),
            ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}