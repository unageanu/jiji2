import UUID from "src/utils/uuid"

describe("UUID", () => {

    it("UUIDを生成できる", () => {
      const uuid1 = UUID.generate();
      const uuid2 = UUID.generate();

      expect( uuid1.length ).toEqual(36);
      expect( uuid2.length ).toEqual(36);
      expect( uuid1 ).not.toEqual( uuid2 );
    });

});
