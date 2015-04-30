import StringFormatter  from "src/viewmodel/utils/string-formatter";

describe("StringFormatter", () => {

  describe("processTemplate", () => {
    it("文字列置換", () => {
      expect( StringFormatter.processTemplate("#{a}と#{a}と\n#{b}と#{c}と\n#{d}と#{b}", {
        a: "aaa",
        b: "テスト",
        c: "#{xx}"
      }) ).toBe( "aaaとaaaと\nテストと#{xx}と\nとテスト");
    });

    it("3つめのフラグを指定すると、パラメータ中の<>等のエスケープが行われる", () => {
      expect( StringFormatter.processTemplate("<b>aaa</b>#{a}と#{b}と#{c}", {
        a: "aaa",
        b: "bb<b>b</b>",
        c: "c<span id='xxx'>c&</span>"
      }, true) ).toBe( "<b>aaa</b>aaaとbb&lt;b&gt;b&lt;/b&gt;とc&lt;span id=&#039;xxx&#039;&gt;c&amp;&lt;/span&gt;");

      expect( StringFormatter.processTemplate("<b>aaa</b>#{a}と#{b}と#{c}", {
        a: "aaa",
        b: "bb<b>b</b>",
        c: "c<span id='xxx'>c&</span>"
      }) ).toBe( "<b>aaa</b>aaaとbb<b>b</b>とc<span id='xxx'>c&</span>");
    });
  });

  describe("escape", () => {
    it("<>", () => {
      expect( StringFormatter.escape("<span>テスト</span>"))
          .toBe( "&lt;span&gt;テスト&lt;/span&gt;");
    });
    it("'\"", () => {
      expect( StringFormatter.escape("'テスト'\"テスト\""))
          .toBe( "&#039;テスト&#039;&#034;テスト&#034;");
    });
    it("&", () => {
      expect( StringFormatter.escape("テスト&テスト"))
          .toBe( "テスト&amp;テスト");
    });
  });

  describe("toAscii", () => {
    it("数値", () => {
      expect( StringFormatter.toAscii("１２３４５６７８９０") ).toBe( "1234567890");
    });
    it("大文字", () => {
      expect( StringFormatter.toAscii("ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ") )
          .toBe( "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    });
    it("小文字", () => {
      expect( StringFormatter.toAscii("ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ") )
          .toBe( "abcdefghijklmnopqrstuvwxyz");
    });
    it("記号その他", () => {
      expect( StringFormatter.toAscii("!\"#$%&'()=~|{`+*}_?><[];:/\\") ).toBe( "!\"#$%&'()=~|{`+*}_?><[];:/\\");
      expect( StringFormatter.toAscii("！”＃＄％＆’（）＝￣｜｛‘＋＊｝＿？＞＜［］；：／￥") )
          .toBe( "！”＃＄％＆’（）＝￣｜｛‘＋＊｝＿？＞＜［］；：／￥");
      expect( StringFormatter.toAscii("あいうえお") ).toBe( "あいうえお" );
    });
  });


});
