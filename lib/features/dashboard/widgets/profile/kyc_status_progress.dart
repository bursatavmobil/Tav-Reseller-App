import 'package:flutter/material.dart';

class KycStatusStepper extends StatelessWidget {
  final String currentStatus;

  const KycStatusStepper({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = ['Pengajuan', 'Ditinjau', 'Disetujui'];

    int activeStep = 0;
    if (currentStatus == 'submission') activeStep = 0;
    if (currentStatus == 'in_review') activeStep = 1;
    if (currentStatus == 'approve' || currentStatus == 'approved')
      activeStep = 2;

    return Row(
      children: List.generate(steps.length, (index) {
        bool isCompleted = index < activeStep;
        bool isActive = index == activeStep;
        bool isPassed = index <= activeStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        // Mengubah warna checklist selesai menjadi Gold (0xFFD4AF37)
                        color: isActive
                            ? const Color(0xFFE52525)
                            : (isCompleted
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE52525,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : isCompleted
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: isPassed
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: isPassed
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: isActive || isCompleted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF222222)
                            : (isCompleted
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2.5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: index < activeStep
                          ? const Color(0xFFD4AF37)
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
