import ContainerJS             from "container-js"
import AccountViewModel        from "./accounts/account-view-model"
import Chart                   from "./chart/chart"
import BacktestListModel       from "./backtests/backtest-list-model"
import PositionsTableModel     from "./positions/positions-table-model"
import NotificationsTableModel from "./notifications/notifications-table-model"
import TradingSummaryViewModel from "./trading-summary/trading-summary-view-model"
import LogViewerModel          from "./logs/log-viewer-model"
import SecuritiesSettingModel  from "./settings/securities-setting-model"
import MailAddressSettingModel from "./settings/mail-address-setting-model"
import PasswordSettingModel    from "./settings/password-setting-model"
import SMTPServerSettingModel  from "./settings/smtp-server-setting-model"

export default class ViewModelFactory {

  constructor() {
    this.rates                   = ContainerJS.Inject;
    this.pairs                   = ContainerJS.Inject;
    this.preferences             = ContainerJS.Inject;
    this.rateService             = ContainerJS.Inject;
    this.rmtService              = ContainerJS.Inject;
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
  createAccountViewModel() {
    return new AccountViewModel( this.rmtService );
  }
  createChart(config={displaySubGraph:false, enablePointer:true}) {
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
  createBacktestListModel() {
    return new BacktestListModel( this.backtests );
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
  createSMTPServerSettingModel() {
    return new SMTPServerSettingModel( this.smtpServerSettingService );
  }
}
