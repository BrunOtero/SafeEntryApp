import 'package:flutter/material.dart';
import 'package:safeentry/constants/app_colors.dart';
import 'package:safeentry/services/auth_service.dart';
import 'package:safeentry/dto/register_request.dart';
import 'package:safeentry/dto/user_type.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  UserType? _selectedUserType;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedUserType == null ||
        (_selectedUserType == UserType.morador && _apartmentController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegisterRequest(
        nome: _nameController.text,
        email: _emailController.text,
        senha: _passwordController.text,
        tipoUsuario: _selectedUserType!,
        apartamento: _selectedUserType == UserType.morador ? _apartmentController.text : null,
      );
      await _authService.register(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Criar Nova Conta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Nome Completo', Icons.person),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration('E-mail', Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Senha', Icons.lock),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserType>(
                  decoration: _inputDecoration('Tipo de Usuário', Icons.person_outline),
                  value: _selectedUserType,
                  dropdownColor: AppColors.surface,
                  items: UserType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.name.capitalize(),
                        style: const TextStyle(color: AppColors.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUserType = newValue;
                    });
                  },
                ),
                if (_selectedUserType == UserType.morador) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apartmentController,
                    decoration: _inputDecoration('Número do Apartamento', Icons.apartment),
                    keyboardType: TextInputType.text,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'CADASTRAR',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Já tem uma conta? Faça login',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}