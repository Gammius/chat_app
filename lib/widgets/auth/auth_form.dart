import 'dart:io';

import 'package:chat_app/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
      String,
      String,
      String,
      File,
      bool,
      BuildContext
      ) callback;
  final bool loading;

  const AuthForm({super.key, required this.callback, required this.loading,});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  GlobalKey<FormState> _formKey = GlobalKey();
  var _isLogin = true;
  var _userEmail = "";
  var _userName = "";
  var _userPass = "";
  File? _userImageFile;

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if(_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Пожалуйста выберите картинку"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    if(!valid || _userImageFile == null) return;
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    widget.callback(
        _userEmail.trim(),
        _userPass.trim(),
        _userName.trim(),
        _userImageFile!,
        _isLogin,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!_isLogin) ImagePickerWidget(
                    imageSize: 50,
                    imagePickFunction: (image) {
                      _userImageFile = image;
                    },
                  ),
                  TextFormField(
                    onSaved: (newValue) => _userEmail = newValue!,
                    validator: (value) {
                      if(value == null || value.isEmpty || !value.contains("@")) {
                        return "Пожалуйства введите корректную почту";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Почта",),
                  ),
                  if(!_isLogin)
                  TextFormField(
                    key: const ValueKey("userName"),
                    onSaved: (newValue) => _userName = newValue!,
                    validator: (value) {
                      if(value == null || value.isEmpty || value.length < 4) {
                        return "Имя пользователя должно быть не короче 4 символов";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: "Имя пользователя",),
                  ),
                  TextFormField(
                    onSaved: (newValue) => _userPass = newValue!,
                    validator: (value) {
                      if(value == null || value.isEmpty || value.length < 10) {
                        return "Пароль должно быть не короче 10 символов";
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Пароль",),
                  ),
                  const SizedBox(height: 12,),
                  ...(() { if(!widget.loading) {
                    return [
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                            _isLogin
                                ? "Войти"
                                : "зарегистрироваться",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {_isLogin = !_isLogin;});
                          },
                        child: Text(_isLogin
                            ? "У меня нет аккаунта"
                            : "У меня есть учетная запись",
                        ),
                      ),
                    ];
                  } else {
                    return [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ];
                  }
                  }())
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
