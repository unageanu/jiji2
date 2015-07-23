import Observable   from "../../utils/observable";

export default class eventQueue extends Observable {

  constructor() {
    super();
    this.queue = [];
  }

  shift() {
    return this.queue.shift();
  }
  push(event) {
    if (event.type !== "routing") {
      if (this.exist(event)) return;
        // 通信エラー等同じメッセージを複数回出しても意味がないので、
        // 同じエラーがすでにあれば登録しない
      if (this.existRoutingEvent()) return;
        // 画面遷移イベントがある場合は、エラーイベントを追加しない。
        // 遷移した先でメッセージを出しても意味がないため。

      this.queue.push(event);
    } else {
      this.queue = []; // 他のイベントを全キャンセルして最優先で遷移する。
      this.queue.push(event);
    }
    this.fire("pushed", {event: event});
  }

  exist(event) {
    return this.queue.find((e) => {
      return e.message != null && e.message === event.message;
    }) != null;
  }
  existRoutingEvent() {
    return this.queue.find((event) => event.route != null ) != null;
  }
}
