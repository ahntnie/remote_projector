// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String LinkValueKey = 'link';
const String VideoDurationValueKey = 'videoDuration';

final Map<String, TextEditingController> _EditCampPageTextEditingControllers =
    {};

final Map<String, FocusNode> _EditCampPageFocusNodes = {};

final Map<String, String? Function(String?)?> _EditCampPageTextValidations = {
  LinkValueKey: null,
  VideoDurationValueKey: null,
};

mixin $EditCampPage {
  TextEditingController get linkController =>
      _getFormTextEditingController(LinkValueKey);
  TextEditingController get videoDurationController =>
      _getFormTextEditingController(VideoDurationValueKey);

  FocusNode get linkFocusNode => _getFormFocusNode(LinkValueKey);
  FocusNode get videoDurationFocusNode =>
      _getFormFocusNode(VideoDurationValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_EditCampPageTextEditingControllers.containsKey(key)) {
      return _EditCampPageTextEditingControllers[key]!;
    }

    _EditCampPageTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _EditCampPageTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_EditCampPageFocusNodes.containsKey(key)) {
      return _EditCampPageFocusNodes[key]!;
    }
    _EditCampPageFocusNodes[key] = FocusNode();
    return _EditCampPageFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    linkController.addListener(() => _updateFormData(model));
    videoDurationController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    linkController.addListener(() => _updateFormData(model));
    videoDurationController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          LinkValueKey: linkController.text,
          VideoDurationValueKey: videoDurationController.text,
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

    for (var controller in _EditCampPageTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _EditCampPageFocusNodes.values) {
      focusNode.dispose();
    }

    _EditCampPageTextEditingControllers.clear();
    _EditCampPageFocusNodes.clear();
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

  String? get linkValue => this.formValueMap[LinkValueKey] as String?;
  String? get videoDurationValue =>
      this.formValueMap[VideoDurationValueKey] as String?;

  set linkValue(String? value) {
    this.setData(
      this.formValueMap..addAll({LinkValueKey: value}),
    );

    if (_EditCampPageTextEditingControllers.containsKey(LinkValueKey)) {
      _EditCampPageTextEditingControllers[LinkValueKey]?.text = value ?? '';
    }
  }

  set videoDurationValue(String? value) {
    this.setData(
      this.formValueMap..addAll({VideoDurationValueKey: value}),
    );

    if (_EditCampPageTextEditingControllers.containsKey(
        VideoDurationValueKey)) {
      _EditCampPageTextEditingControllers[VideoDurationValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasLink =>
      this.formValueMap.containsKey(LinkValueKey) &&
      (linkValue?.isNotEmpty ?? false);
  bool get hasVideoDuration =>
      this.formValueMap.containsKey(VideoDurationValueKey) &&
      (videoDurationValue?.isNotEmpty ?? false);

  bool get hasLinkValidationMessage =>
      this.fieldsValidationMessages[LinkValueKey]?.isNotEmpty ?? false;
  bool get hasVideoDurationValidationMessage =>
      this.fieldsValidationMessages[VideoDurationValueKey]?.isNotEmpty ?? false;

  String? get linkValidationMessage =>
      this.fieldsValidationMessages[LinkValueKey];
  String? get videoDurationValidationMessage =>
      this.fieldsValidationMessages[VideoDurationValueKey];
}

extension Methods on FormStateHelper {
  setLinkValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[LinkValueKey] = validationMessage;
  setVideoDurationValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[VideoDurationValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    linkValue = '';
    videoDurationValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      LinkValueKey: getValidationMessage(LinkValueKey),
      VideoDurationValueKey: getValidationMessage(VideoDurationValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _EditCampPageTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _EditCampPageTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      LinkValueKey: getValidationMessage(LinkValueKey),
      VideoDurationValueKey: getValidationMessage(VideoDurationValueKey),
    });
