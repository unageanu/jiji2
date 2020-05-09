import ContainerJS         from "container-js"
import Observable          from "../../utils/observable"
import Validators          from "../../utils/validation/validators"
import ValidationUtils     from "../utils/validation-utils"

export default class RangeSelectorModel extends Observable {

  constructor(startTimeValidator, endTimeValidator) {
    super();
    this.startTimeValidator = startTimeValidator;
    this.endTimeValidator   = endTimeValidator;
    this.enable = true;
  }

  initialize(minDate, maxDate, defaultStartTime, defaultEndTime) {
    this.minDate = minDate;
    this.maxDate = maxDate;
    this.startTime = defaultStartTime;
    this.endTime   = defaultEndTime;
    this.startTimeError = null;
    this.endTimeError = null;
  }

  validate(formatMessage) {
    return Validators.all(
      this.validateStartTime(this.startTime, formatMessage),
      this.validateEndTime(this.endTime, formatMessage),
      this.validateStartTimeIsBeforeEndTime(this.startTime, this.endTime, formatMessage)
    );
  }

  validateStartTime(startTime, formatMessage) {
    return ValidationUtils.validate(this.startTimeValidator, startTime,
      {field: formatMessage({id:'validation.fields.startTime'})}, (error) => this.startTimeError = error, formatMessage );
  }
  validateEndTime(endTime, formatMessage) {
    return ValidationUtils.validate(this.endTimeValidator, endTime,
      {field: formatMessage({id:'validation.fields.endTime'})}, (error) => this.endTimeError = error, formatMessage );
  }
  validateStartTimeIsBeforeEndTime(startTime, endTime, formatMessage) {
    if ( !startTime || !endTime ) return false;
    if ( this.startTimeError ) return false;
    if ( startTime.getTime() >= endTime.getTime() ) {
      this.startTimeError = formatMessage({id:'validation.messages.illegalStartTime'});
      return false;
    } else {
      return true;
    }
  }

  get startTime() {
    return this.getProperty("startTime");
  }
  set startTime(startTime) {
    this.setProperty("startTime", startTime);
  }
  get startTimeError() {
    return this.getProperty("startTimeError");
  }
  set startTimeError(error) {
    this.setProperty("startTimeError", error);
  }

  get endTime() {
    return this.getProperty("endTime");
  }
  set endTime(endTime) {
    this.setProperty("endTime", endTime);
  }
  get endTimeError() {
    return this.getProperty("endTimeError");
  }
  set endTimeError(error) {
    this.setProperty("endTimeError", error);
  }

  get minDate() {
    return this.getProperty("minDate");
  }
  set minDate(minDate) {
    this.setProperty("minDate", minDate);
  }
  get maxDate() {
    return this.getProperty("maxDate");
  }
  set maxDate(maxDate) {
    this.setProperty("maxDate", maxDate);
  }
  get enable() {
    return this.getProperty("enable");
  }
  set enable(enable) {
    this.setProperty("enable", enable);
  }

}
