library angular2.src.forms.validators;

import "package:angular2/src/facade/lang.dart" show isBlank, isPresent;
import "package:angular2/src/facade/collection.dart"
    show List, ListWrapper, StringMapWrapper;
import "model.dart"
    as modelModule; /**
 * Provides a set of validators used by form controls.
 *
 * # Example
 *
 * ```
 * var loginControl = new Control("", Validators.required)
 * ```
 *
 * @exportedAs angular2/forms
 */

class Validators {
  static required(modelModule.Control c) {
    return isBlank(c.value) || c.value == "" ? {"required": true} : null;
  }
  static nullValidator(dynamic c) {
    return null;
  }
  static Function compose(List<Function> validators) {
    return (modelModule.Control c) {
      var res = ListWrapper.reduce(validators, (res, validator) {
        var errors = validator(c);
        return isPresent(errors) ? StringMapWrapper.merge(res, errors) : res;
      }, {});
      return StringMapWrapper.isEmpty(res) ? null : res;
    };
  }
  static group(modelModule.ControlGroup c) {
    var res = {};
    StringMapWrapper.forEach(c.controls, (control, name) {
      if (c.contains(name) && isPresent(control.errors)) {
        Validators._mergeErrors(control, res);
      }
    });
    return StringMapWrapper.isEmpty(res) ? null : res;
  }
  static array(modelModule.ControlArray c) {
    var res = {};
    ListWrapper.forEach(c.controls, (control) {
      if (isPresent(control.errors)) {
        Validators._mergeErrors(control, res);
      }
    });
    return StringMapWrapper.isEmpty(res) ? null : res;
  }
  static _mergeErrors(control, res) {
    StringMapWrapper.forEach(control.errors, (value, error) {
      if (!StringMapWrapper.contains(res, error)) {
        res[error] = [];
      }
      ListWrapper.push(res[error], control);
    });
  }
}
