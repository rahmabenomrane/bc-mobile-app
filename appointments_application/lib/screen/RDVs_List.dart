import 'package:appointments_application/config/Palette.dart';
import 'package:appointments_application/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Service/appointment_service.dart';

// Mock data model
class RdvModel {
  final String agence;
  final String service;
  final String date;
  final String heure;
  final String duree;
  final String status; // "confirmé", "en attente", "terminé"

  RdvModel({
    required this.agence,
    required this.service,
    required this.date,
    required this.heure,
    required this.duree,
    required this.status,
  });
}

class RdvsList extends StatefulWidget {



  get onNavigate => null;
  @override
  State<RdvsList> createState() => _RdvsListState();
}

class _RdvsListState extends State<RdvsList> {


  @override
  void initState() {
    super.initState();
    loadAppointments();
  }
  List<dynamic> rdvs = [];
  bool loading = true;

  final AppointmentService appointmentService = AppointmentService();

  // Couleur selon statut
  Color _statusColor(String status) {
    switch (status) {
      case "confirmé":    return Colors.green;
      case "en attente":  return Colors.orange;
      case "terminé":     return Colors.grey;
      default:            return Colors.blue;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "confirmé":    return Icons.check_circle_outline;
      case "en attente":  return Icons.hourglass_empty;
      case "terminé":     return Icons.history;
      default:            return Icons.info_outline;
    }
  }


  @override
  Widget build(BuildContext context) {
    final next = rdvs.isNotEmpty ? rdvs.first : null;
    print("Nombre de RDV : ${rdvs.length}");
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Palette.gradientFirst.withOpacity(0.9),
              Palette.gradientSecond,
            ],
            begin: const FractionalOffset(0.0, 0.4),
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          children: [

            // ── Header ──────────────────────────────
            Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre navigation
                  Row(
                    children: [
                      InkWell(
              onTap: () {
      Get.back();
      },
                        child: Icon(Icons.arrow_back_ios, size: 20, color: Palette.secondPageIconColor),
                      ),
                      Expanded(child: Container()),
                      Icon(Icons.question_mark_rounded, size: 20, color: Palette.secondPageIconColor),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Prochain RDV
                  Text("Prochain Rendez-vous",
                      style: TextStyle(fontSize: 16, color: Palette.secondPageTitleColor)),
                  const SizedBox(height: 4),
                  Text(next?.agence ?? "Aucun rendez-vous",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Palette.secondPageTitleColor)),
                  const SizedBox(height: 10),

                  // Badges date + service
                  Row(
                    children: [
                      // Badge date
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Palette.secondPageContainerGradient1stColor, Palette.secondPageContainerGradient2ndColor],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Palette.secondPageIconColor),
                            const SizedBox(width: 5),
                            Text("${next?.date}  ${next?.heure}",
                                style: TextStyle(fontSize: 11, color: Palette.secondPageIconColor)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Badge service
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Palette.secondPageContainerGradient1stColor, Palette.secondPageContainerGradient2ndColor],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.handyman_rounded, size: 16, color: Palette.secondPageIconColor),
                            const SizedBox(width: 6),
                            Text(next?.serviceCode?.toString() ?? "",
                                style: TextStyle(fontSize: 13, color: Palette.secondPageIconColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Liste blanche ────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(70)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Titre + compteur
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Text("Vos Rendez-vous",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.circuitsColor)),
                          Expanded(child: Container()),
                          Icon(Icons.numbers, size: 20, color: Palette.loopColor),
                          const SizedBox(width: 6),
                          Text("${rdvs.length} RDV",
                              style: TextStyle(fontSize: 15, color: Palette.setsColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── RDV List ──────────────────────
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: rdvs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final rdv = rdvs[index];
                          return Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  color: Palette.gradientSecond.withOpacity(0.1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [

                                // Icône service
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Palette.gradientFirst.withOpacity(0.8),
                                        Palette.gradientSecond.withOpacity(0.9),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 14),

                                // Infos
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rdv["serviceCode"],
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Palette.circuitsColor)),
                                      const SizedBox(height: 4),
                                      Text(rdv["agencyCode"],
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Palette.setsColor)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: Palette.loopColor),
                                          const SizedBox(width: 4),
                                          Text("${rdv["date"]} · ${rdv.heure}",
                                              style: TextStyle(fontSize: 12, color: Palette.loopColor)),
                                          const SizedBox(width: 10),
                                          Icon(Icons.timer, size: 12, color: Palette.loopColor),

                                         ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Véhicule : ${rdv["numVehicle"]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Badge statut
                                Column(
                                  children: [
                                    Icon(_statusIcon(rdv["status"]),
                                        color: _statusColor(rdv.status), size: 20),
                                    const SizedBox(height: 4),
                                    Text(rdv.status,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _statusColor(rdv.status),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],


        ),
      ),

    );
  }

  Future<void> loadAppointments() async {
    try {

      final customerNumber =
      Get.arguments["customerNumber"];

      final data =
      await appointmentService
          .getCustomerAppointments(
          customerNumber);

      setState(() {
        rdvs = data;
        loading = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        loading = false;
      });
    }
  }
}