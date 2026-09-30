import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_exception.dart';
import '../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _email;
  XFile? _selected;
  bool _working = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.email);
  }
  @override
  void dispose() { _name.dispose(); _email.dispose(); super.dispose(); }

  Future<void> _selectAvatar() async {
    setState(() { _working = true; _message = null; });
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) { return; }
      if (await file.length() > 2 * 1024 * 1024) {
        throw const AuthException('Ukuran gambar maksimal 2 MB.');
      }
      final extension = file.name.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw const AuthException('Pilih gambar JPG atau PNG.');
      }
      if (mounted) { setState(() => _selected = file); }
    } on PlatformException {
      if (mounted) { setState(() => _message = 'Galeri belum dapat dibuka. Coba lagi.'); }
    } on AuthException catch (error) {
      if (mounted) { setState(() => _message = error.message); }
    } catch (_) {
      if (mounted) { setState(() => _message = 'Gambar belum dapat dibaca. Pilih kembali.'); }
    } finally {
      if (mounted) { setState(() => _working = false); }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) { return; }
    setState(() { _working = true; _message = null; });
    try {
      await context.read<AuthProvider>().updateProfile(_name.text, _email.text);
      if (mounted) { setState(() => _message = 'Nama dan email berhasil disimpan.'); }
    } on AuthException catch (error) {
      if (mounted) { setState(() => _message = error.message); }
    } catch (_) {
      if (mounted) { setState(() => _message = 'Profil belum dapat disimpan. Coba lagi.'); }
    } finally {
      if (mounted) { setState(() => _working = false); }
    }
  }

  Future<void> _uploadAvatar() async {
    final selected = _selected;
    if (selected == null) { return; }
    setState(() { _working = true; _message = null; });
    try {
      await context.read<AuthProvider>().uploadAvatar(selected.path, selected.name);
      if (mounted) { setState(() {
        _selected = null;
        _message = 'Avatar berhasil diunggah.';
      }); }
    } on AuthException catch (error) {
      if (mounted) { setState(() => _message = error.message); }
    } catch (_) {
      if (mounted) { setState(() => _message = 'Avatar belum dapat diunggah. Coba lagi.'); }
    } finally {
      if (mounted) { setState(() => _working = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final enabled = !_working && !auth.busy;
    return Scaffold(appBar: AppBar(title: const Text('Edit profil')),
      body: Form(key: _formKey, child: ListView(
        padding: const EdgeInsets.all(24), children: [
          Center(child: _selected == null ? UserAvatar(url: auth.user?.avatarUrl)
            : ClipOval(child: Image.file(File(_selected!.path), width: 88, height: 88,
                fit: BoxFit.cover))),
          TextButton(onPressed: enabled ? _selectAvatar : null,
            child: const Text('Pilih avatar dari galeri')),
          if (_selected != null) OutlinedButton(onPressed: enabled ? _uploadAvatar : null,
            child: const Text('Unggah avatar')),
          TextFormField(controller: _name, enabled: enabled,
            decoration: const InputDecoration(labelText: 'Nama'),
            maxLength: 255, validator: (value) => value == null || value.trim().isEmpty
              ? 'Nama wajib diisi.' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _email, enabled: enabled,
            keyboardType: TextInputType.emailAddress, maxLength: 255,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => value == null ||
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
                ? 'Email tidak valid.' : null),
          const SizedBox(height: 16),
          FilledButton(onPressed: enabled ? _saveProfile : null,
            child: const Text('Simpan nama dan email')),
          if (_working || auth.busy) const LinearProgressIndicator(),
          if (_message != null) Padding(padding: const EdgeInsets.only(top: 16),
            child: Text(_message!)),
        ],
      )),
    );
  }
}
