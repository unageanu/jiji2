import EventQueue from "src/viewmodel/widgets/event-queue"

describe("EventQueue", () => {

  var queue;

  beforeEach(() => {
    queue = new EventQueue();
  });

  describe("#shift", () => {
    it("pushで追加したイベントを1つ取り出せる", () => {
      queue.push({ type: "error", message:"a" });
      queue.push({ type: "error", message:"b" });

      expect(queue.shift()).toEqual({ type: "error", message:"a" });
      expect(queue.queue.length).toEqual(1);
      expect(queue.queue).toEqual([{ type: "error", message:"b" }]);
    });
  });

  describe("#push", () => {
    it("イベントを追加できる", () => {
      queue.push({ type: "error", message:"a"});
      expect(queue.queue).toEqual([{ type: "error", message:"a" }]);

      queue.push({ type: "error", message:"b"});
      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" }
      ]);
    });

    it("メッセージが同じイベントは無視される", () => {
      queue.push({ type: "error", message:"a" });
      queue.push({ type: "error", message:"b" });
      queue.push({ type: "error", message:"c" });

      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" }
      ]);

      queue.push({ type: "error", message:"a" });
      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" }
      ]);

      queue.push({ type: "error", message:"b" });
      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" }
      ]);

      queue.push({ type: "error", message:"c" });
      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" }
      ]);

      queue.push({ type: "error", message:"d" });
      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" },
        { type: "error", message:"d" }
      ]);
    });

    it("ルーティングイベントが追加されると他のイベントは破棄される", () => {
      queue.push({ type: "error", message:"a" });
      queue.push({ type: "error", message:"b" });
      queue.push({ type: "error", message:"c" });

      expect(queue.queue).toEqual([
        { type: "error", message:"a" },
        { type: "error", message:"b" },
        { type: "error", message:"c" }
      ]);

      queue.push({type:"routing", route:"d"});
      expect(queue.queue).toEqual([
        {type:"routing", route:"d"}
      ]);

      queue.push({type:"routing", route:"e"});
      expect(queue.queue).toEqual([
        {type:"routing", route:"e"}
      ]);
    });

    it("ルーティングイベントが登録されている場合、メッセージイベントは追加されない", () => {
      queue.push({type:"routing", route:"d"});
      expect(queue.queue).toEqual([
        {type:"routing", route:"d"}
      ]);

      queue.push({ type: "error", message:"a" });
      expect(queue.queue).toEqual([
        {type:"routing", route:"d"}
      ]);
    });
  });

});
