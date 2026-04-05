import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secretvaultoneforall/features/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:secretvaultoneforall/features/authentication/authentication_enums.dart';
import 'package:secretvaultoneforall/features/authentication/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, authState) {
        if (authState.status != AuthenticationStatus.authenticated) {
          return const LoginScreen();
        }
        final userId = authState.user.id;
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Safepad'),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthenticationBloc>().add(
                  const LogoutRequested(),
                ),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notes')
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load notes: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 64,
                          color: cs.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No notes yet',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap New note to create your first private note.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final title = (data['title'] as String?)?.trim();
                  final content = (data['content'] as String?)?.trim();
                  final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
                  return Card(
                    child: ListTile(
                      title: Text(
                        (title == null || title.isEmpty)
                            ? 'Untitled note'
                            : title,
                      ),
                      subtitle: Text(
                        (content == null || content.isEmpty)
                            ? 'No content'
                            : content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: updatedAt == null
                          ? null
                          : Text(
                              _formatTime(updatedAt),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createNote(userId),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('New note'),
          ),
        );
      },
    );
  }

  Future<void> _createNote(String userId) async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty && content.isEmpty) {
                  navigator.pop(false);
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notes')
                    .add({
                      'title': title,
                      'content': content,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                navigator.pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note created')));
    }
    titleCtrl.dispose();
    contentCtrl.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final meridian = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridian';
  }
}
