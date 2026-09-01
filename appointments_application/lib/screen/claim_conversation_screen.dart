import 'package:flutter/material.dart';

import '../Service/claim_service.dart';
import '../models/claim_model.dart';
import '../models/ClaimMessageModel.dart';

class ClaimConversationScreen extends StatefulWidget {
  final ClaimModel claim;

  const ClaimConversationScreen({
    super.key,
    required this.claim,
  });

  @override
  State<ClaimConversationScreen> createState() =>
      _ClaimConversationScreenState();
}

class _ClaimConversationScreenState
    extends State<ClaimConversationScreen> {

  final TextEditingController _messageController =
  TextEditingController();

  List<ClaimMessageModel> _messages = [];

  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
    });

    try {
      final messages =
      await ClaimService.fetchClaimMessages(
        widget.claim.claimNumber,
      );

      // Messages du plus ancien au plus récent
      messages.sort((a, b) {
        final dateA =
            a.messageDateTime ?? DateTime(2000);
        final dateB =
            b.messageDateTime ?? DateTime(2000);

        return dateA.compareTo(dateB);
      });

      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible de charger les messages : $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text =
    _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await ClaimService.sendClaimMessage(
        claimNo: widget.claim.claimNumber,
        message: text,
      );

      _messageController.clear();

      // Recharger la conversation
      await _loadMessages();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d\'envoyer le message : $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final day =
    date.day.toString().padLeft(2, '0');
    final month =
    date.month.toString().padLeft(2, '0');
    final hour =
    date.hour.toString().padLeft(2, '0');
    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Échanges avec STA',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '#${widget.claim.claimNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // ============================
          // DESCRIPTION INITIALE
          // ============================

          Container(
            width: double.infinity,
            margin:
            const EdgeInsets.all(16),
            padding:
            const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color:
                Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  'Votre réclamation',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey.shade600,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.claim.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ============================
          // MESSAGES
          // ============================

          Expanded(
            child: _loading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .forum_outlined,
                    size: 45,
                    color: Colors
                        .grey.shade400,
                  ),
                  const SizedBox(
                      height: 10),
                  Text(
                    'Aucune réponse pour le moment',
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount:
              _messages.length,
              itemBuilder:
                  (context, index) {

                final message =
                _messages[
                index];

                final isClient =
                    message
                        .senderType
                        .toLowerCase() ==
                        'client';

                return Align(
                  alignment: isClient
                      ? Alignment
                      .centerRight
                      : Alignment
                      .centerLeft,
                  child: Container(
                    constraints:
                    BoxConstraints(
                      maxWidth:
                      MediaQuery.of(
                          context)
                          .size
                          .width *
                          0.78,
                    ),
                    margin:
                    const EdgeInsets
                        .only(
                      bottom: 10,
                    ),
                    padding:
                    const EdgeInsets
                        .all(12),
                    decoration:
                    BoxDecoration(
                      color: isClient
                          ? const Color(
                          0xFFA32D2D)
                          : Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                          14),
                      border: isClient
                          ? null
                          : Border.all(
                        color: Colors
                            .grey
                            .shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [

                        Text(
                          isClient
                              ? 'Vous'
                              : 'Agent STA',
                          style:
                          TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight
                                .w700,
                            color: isClient
                                ? Colors
                                .white70
                                : const Color(
                                0xFFA32D2D),
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          message.message,
                          style:
                          TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isClient
                                ? Colors
                                .white
                                : Colors
                                .black87,
                          ),
                        ),

                        if (message
                            .messageDateTime !=
                            null) ...[
                          const SizedBox(
                              height: 5),
                          Text(
                            _formatDate(
                                message
                                    .messageDateTime),
                            style:
                            TextStyle(
                              fontSize: 10,
                              color: isClient
                                  ? Colors
                                  .white60
                                  : Colors
                                  .grey
                                  .shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ============================
          // RÉPONSE DU CLIENT
          // ============================

          Container(
            padding:
            const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color:
                  Colors.grey.shade200,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [

                  Expanded(
                    child: TextField(
                      controller:
                      _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration:
                      InputDecoration(
                        hintText:
                        'Écrire une réponse...',
                        filled: true,
                        fillColor:
                        Colors.grey.shade100,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(20),
                          borderSide:
                          BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: _sending
                        ? null
                        : _sendMessage,
                    style:
                    IconButton.styleFrom(
                      backgroundColor:
                      const Color(
                          0xFFA32D2D),
                      foregroundColor:
                      Colors.white,
                    ),
                    icon: _sending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                        Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}