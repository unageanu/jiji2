import ContainerJS             from "container-js"
import Chart                   from "./chart/chart"
import PositionsTableModel     from "./positions/positions-table-model"
import NotificationsTableModel from "./notifications/notifications-table-model"
import TradingSummaryViewModel from "./trading-summary/trading-summary-view-model"
import LogViewerModel          from "./logs/log-viewer-model"
import SecuritiesSettingModel  from "./settings/securities-setting-model"
import MailAddressSettingModel from "./settings/mail-address-setting-model"
import PasswordSettingModel    from "./settings/password-setting-model"

export default class ViewModelFactory {

  constructor() {
    this.rates                   = ContainerJS.Inject;
    this.preferences             = ContainerJS.Inject;
    this.rateService             = ContainerJS.Inject;
    this.positionService         = ContainerJS.Inject;
    this.notificationService     = ContainerJS.Inject;
    this.actionService           = ContainerJS.Inject;
    this.graphService            = ContainerJS.Inject;
    this.logService              = ContainerJS.Inject;
    this.tradingSummariesService = ContainerJS.Inject;
    this.backtests               = ContainerJS.Inject;
    this.eventQueue              = ContainerJS.Inject;

    this.securitiesSettingService = ContainerJS.Inject;
    this.smtpServerSettingService = ContainerJS.Inject;
    this.userSettingService       = ContainerJS.Inject;
    this.passwordResettingService = ContainerJS.Inject;
    this.initialSettingService    = ContainerJS.Inject;
  }
  createChart(config={displayPositionsAndGraphs:false}) {
    return new Chart( config, this );
  }
  createPositionsTableModel(pageSize=100,
    sortOrder={order:"profit_or_loss", direction:"asc"}) {
    return new PositionsTableModel(
      pageSize, sortOrder, this.positionService );
  }
  createNotificationsTableModel(pageSize=100,
    sortOrder={order:"timestamp", direction:"desc"}) {
    return new NotificationsTableModel(
      pageSize, sortOrder, this.notificationService,
      this.actionService, this.backtests, this.eventQueue );
  }
  createTradingSummaryViewModel(enablePeriodSelector=false) {
    const model = new TradingSummaryViewModel( this.tradingSummariesService );
    model.enablePeriodSelector = enablePeriodSelector;
    return model;
  }
  createLogViewerModel() {
    return new LogViewerModel( this.logService );
  }
  createSecuritiesSettingModel() {
    return new SecuritiesSettingModel( this.securitiesSettingService );
  }
  createMailAddressSettingModel() {
    return new MailAddressSettingModel(
      this.userSettingService, this.smtpServerSettingService );
  }
  createPasswordSettingModel() {
    return new PasswordSettingModel( this.userSettingService );
  }
}
