
export default class SessionManager {
  constructor() {
    this.ticket = null;
  }
  isLoggedIn() {
    return !!this.ticket;
  }
  setTicket(ticket) {
    this.ticket = ticket;
  }
  getTicket() {
    return this.ticket;
  }
  deleteTicket() {
    this.ticket = null;
  }
}
