// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String EmailValueKey = 'email';
const String PasswordValueKey = 'password';
const String CodeValueKey = 'code';

final Map<String, TextEditingController>
    _RemoveAccountPageTextEditingControllers = {};

final Map<String, FocusNode> _RemoveAccountPageFocusNodes = {};

final Map<String, String? Function(String?)?>
    _RemoveAccountPageTextValidations = {
  EmailValueKey: null,
  PasswordValueKey: null,
  CodeValueKey: null,
};

mixin $RemoveAccountPage {
  TextEditingController get emailController =>
      _getFormTextEditingController(EmailValueKey);
  TextEditingController get passwordController =>
      _getFormTextEditingController(PasswordValueKey);
  TextEditingController get codeController =>
      _getFormTextEditingController(CodeValueKey);

  FocusNode get emailFocusNode => _getFormFocusNode(EmailValueKey);
  FocusNode get passwordFocusNode => _getFormFocusNode(PasswordValueKey);
  FocusNode get codeFocusNode => _getFormFocusNode(CodeValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_RemoveAccountPageTextEditingControllers.containsKey(key)) {
      return _RemoveAccountPageTextEditingControllers[key]!;
    }

    _RemoveAccountPageTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _RemoveAccountPageTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_RemoveAccountPageFocusNodes.containsKey(key)) {
      return _RemoveAccountPageFocusNodes[key]!;
    }
    _RemoveAccountPageFocusNodes[key] = FocusNode();
    return _RemoveAccountPageFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    emailController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    codeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    emailController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    codeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          EmailValueKey: emailController.text,
          PasswordValueKey: passwordController.text,
          CodeValueKey: codeController.text,
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

    for (var controller in _RemoveAccountPageTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _RemoveAccountPageFocusNodes.values) {
      focusNode.dispose();
    }

    _RemoveAccountPageTextEditingControllers.clear();
    _RemoveAccountPageFocusNodes.clear();
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

  String? get emailValue => this.formValueMap[EmailValueKey] as String?;
  String? get passwordValue => this.formValueMap[PasswordValueKey] as String?;
  String? get codeValue => this.formValueMap[CodeValueKey] as String?;

  set emailValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmailValueKey: value}),
    );

    if (_RemoveAccountPageTextEditingControllers.containsKey(EmailValueKey)) {
      _RemoveAccountPageTextEditingControllers[EmailValueKey]?.text =
          value ?? '';
    }
  }

  set passwordValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PasswordValueKey: value}),
    );

    if (_RemoveAccountPageTextEditingControllers.containsKey(
        PasswordValueKey)) {
      _RemoveAccountPageTextEditingControllers[PasswordValueKey]?.text =
          value ?? '';
    }
  }

  set codeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CodeValueKey: value}),
    );

    if (_RemoveAccountPageTextEditingControllers.containsKey(CodeValueKey)) {
      _RemoveAccountPageTextEditingControllers[CodeValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasEmail =>
      this.formValueMap.containsKey(EmailValueKey) &&
      (emailValue?.isNotEmpty ?? false);
  bool get hasPassword =>
      this.formValueMap.containsKey(PasswordValueKey) &&
      (passwordValue?.isNotEmpty ?? false);
  bool get hasCode =>
      this.formValueMap.containsKey(CodeValueKey) &&
      (codeValue?.isNotEmpty ?? false);

  bool get hasEmailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey]?.isNotEmpty ?? false;
  bool get hasPasswordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey]?.isNotEmpty ?? false;
  bool get hasCodeValidationMessage =>
      this.fieldsValidationMessages[CodeValueKey]?.isNotEmpty ?? false;

  String? get emailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey];
  String? get passwordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey];
  String? get codeValidationMessage =>
      this.fieldsValidationMessages[CodeValueKey];
}

extension Methods on FormStateHelper {
  setEmailValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmailValueKey] = validationMessage;
  setPasswordValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PasswordValueKey] = validationMessage;
  setCodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CodeValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    emailValue = '';
    passwordValue = '';
    codeValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      EmailValueKey: getValidationMessage(EmailValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      CodeValueKey: getValidationMessage(CodeValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _RemoveAccountPageTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _RemoveAccountPageTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      EmailValueKey: getValidationMessage(EmailValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      CodeValueKey: getValidationMessage(CodeValueKey),
    });
