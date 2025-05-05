// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String NameValueKey = 'name';
const String EmailValueKey = 'email';
const String PhoneValueKey = 'phone';
const String PasswordValueKey = 'password';
const String ConfirmPasswordValueKey = 'confirmPassword';

final Map<String, TextEditingController> _SignUpPageTextEditingControllers = {};

final Map<String, FocusNode> _SignUpPageFocusNodes = {};

final Map<String, String? Function(String?)?> _SignUpPageTextValidations = {
  NameValueKey: null,
  EmailValueKey: null,
  PhoneValueKey: null,
  PasswordValueKey: null,
  ConfirmPasswordValueKey: null,
};

mixin $SignUpPage {
  TextEditingController get nameController =>
      _getFormTextEditingController(NameValueKey);
  TextEditingController get emailController =>
      _getFormTextEditingController(EmailValueKey);
  TextEditingController get phoneController =>
      _getFormTextEditingController(PhoneValueKey);
  TextEditingController get passwordController =>
      _getFormTextEditingController(PasswordValueKey);
  TextEditingController get confirmPasswordController =>
      _getFormTextEditingController(ConfirmPasswordValueKey);

  FocusNode get nameFocusNode => _getFormFocusNode(NameValueKey);
  FocusNode get emailFocusNode => _getFormFocusNode(EmailValueKey);
  FocusNode get phoneFocusNode => _getFormFocusNode(PhoneValueKey);
  FocusNode get passwordFocusNode => _getFormFocusNode(PasswordValueKey);
  FocusNode get confirmPasswordFocusNode =>
      _getFormFocusNode(ConfirmPasswordValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_SignUpPageTextEditingControllers.containsKey(key)) {
      return _SignUpPageTextEditingControllers[key]!;
    }

    _SignUpPageTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _SignUpPageTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_SignUpPageFocusNodes.containsKey(key)) {
      return _SignUpPageFocusNodes[key]!;
    }
    _SignUpPageFocusNodes[key] = FocusNode();
    return _SignUpPageFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    nameController.addListener(() => _updateFormData(model));
    emailController.addListener(() => _updateFormData(model));
    phoneController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    confirmPasswordController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    nameController.addListener(() => _updateFormData(model));
    emailController.addListener(() => _updateFormData(model));
    phoneController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    confirmPasswordController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          NameValueKey: nameController.text,
          EmailValueKey: emailController.text,
          PhoneValueKey: phoneController.text,
          PasswordValueKey: passwordController.text,
          ConfirmPasswordValueKey: confirmPasswordController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (var controller in _SignUpPageTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _SignUpPageFocusNodes.values) {
      focusNode.dispose();
    }

    _SignUpPageTextEditingControllers.clear();
    _SignUpPageFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get nameValue => this.formValueMap[NameValueKey] as String?;
  String? get emailValue => this.formValueMap[EmailValueKey] as String?;
  String? get phoneValue => this.formValueMap[PhoneValueKey] as String?;
  String? get passwordValue => this.formValueMap[PasswordValueKey] as String?;
  String? get confirmPasswordValue =>
      this.formValueMap[ConfirmPasswordValueKey] as String?;

  set nameValue(String? value) {
    this.setData(
      this.formValueMap..addAll({NameValueKey: value}),
    );

    if (_SignUpPageTextEditingControllers.containsKey(NameValueKey)) {
      _SignUpPageTextEditingControllers[NameValueKey]?.text = value ?? '';
    }
  }

  set emailValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmailValueKey: value}),
    );

    if (_SignUpPageTextEditingControllers.containsKey(EmailValueKey)) {
      _SignUpPageTextEditingControllers[EmailValueKey]?.text = value ?? '';
    }
  }

  set phoneValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PhoneValueKey: value}),
    );

    if (_SignUpPageTextEditingControllers.containsKey(PhoneValueKey)) {
      _SignUpPageTextEditingControllers[PhoneValueKey]?.text = value ?? '';
    }
  }

  set passwordValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PasswordValueKey: value}),
    );

    if (_SignUpPageTextEditingControllers.containsKey(PasswordValueKey)) {
      _SignUpPageTextEditingControllers[PasswordValueKey]?.text = value ?? '';
    }
  }

  set confirmPasswordValue(String? value) {
    this.setData(
      this.formValueMap..addAll({ConfirmPasswordValueKey: value}),
    );

    if (_SignUpPageTextEditingControllers.containsKey(
        ConfirmPasswordValueKey)) {
      _SignUpPageTextEditingControllers[ConfirmPasswordValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasName =>
      this.formValueMap.containsKey(NameValueKey) &&
      (nameValue?.isNotEmpty ?? false);
  bool get hasEmail =>
      this.formValueMap.containsKey(EmailValueKey) &&
      (emailValue?.isNotEmpty ?? false);
  bool get hasPhone =>
      this.formValueMap.containsKey(PhoneValueKey) &&
      (phoneValue?.isNotEmpty ?? false);
  bool get hasPassword =>
      this.formValueMap.containsKey(PasswordValueKey) &&
      (passwordValue?.isNotEmpty ?? false);
  bool get hasConfirmPassword =>
      this.formValueMap.containsKey(ConfirmPasswordValueKey) &&
      (confirmPasswordValue?.isNotEmpty ?? false);

  bool get hasNameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey]?.isNotEmpty ?? false;
  bool get hasEmailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey]?.isNotEmpty ?? false;
  bool get hasPhoneValidationMessage =>
      this.fieldsValidationMessages[PhoneValueKey]?.isNotEmpty ?? false;
  bool get hasPasswordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey]?.isNotEmpty ?? false;
  bool get hasConfirmPasswordValidationMessage =>
      this.fieldsValidationMessages[ConfirmPasswordValueKey]?.isNotEmpty ??
      false;

  String? get nameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey];
  String? get emailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey];
  String? get phoneValidationMessage =>
      this.fieldsValidationMessages[PhoneValueKey];
  String? get passwordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey];
  String? get confirmPasswordValidationMessage =>
      this.fieldsValidationMessages[ConfirmPasswordValueKey];
}

extension Methods on FormStateHelper {
  setNameValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[NameValueKey] = validationMessage;
  setEmailValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmailValueKey] = validationMessage;
  setPhoneValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PhoneValueKey] = validationMessage;
  setPasswordValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PasswordValueKey] = validationMessage;
  setConfirmPasswordValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[ConfirmPasswordValueKey] =
          validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    nameValue = '';
    emailValue = '';
    phoneValue = '';
    passwordValue = '';
    confirmPasswordValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      NameValueKey: getValidationMessage(NameValueKey),
      EmailValueKey: getValidationMessage(EmailValueKey),
      PhoneValueKey: getValidationMessage(PhoneValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      ConfirmPasswordValueKey: getValidationMessage(ConfirmPasswordValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _SignUpPageTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _SignUpPageTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      NameValueKey: getValidationMessage(NameValueKey),
      EmailValueKey: getValidationMessage(EmailValueKey),
      PhoneValueKey: getValidationMessage(PhoneValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      ConfirmPasswordValueKey: getValidationMessage(ConfirmPasswordValueKey),
    });
