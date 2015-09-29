
export default class PageSelectorBuilder {

  constructor(totalCount, offset, model) {
    this.totalCount = totalCount;
    this.offset = offset;
    this.model = model;
    this.selectors = [];
  }

  build() {
    this.addLatestSelector();
    if (this.offset + 2 < this.totalCount -1 ) this.addSeparator();
    this.addCenterSelectors();
    if (this.offset -2 > 0 ) this.addSeparator();
    this.addOldestselector();
    return this.selectors;
  }
  addSeparator() {
    this.selectors.push( this.createSelectorSeparator() );
  }
  addLatestSelector() {
    if (this.totalCount > 1) {
      this.selectors.push( this.createSelector( this.totalCount -1 ) );
    }
  }
  addCenterSelectors() {
    [this.offset+1, this.offset, this.offset-1].forEach((page) => {
      if (page >= this.totalCount - 1 || page <= 0 ) return;
      this.selectors.push( this.createSelector( page ) );
    });
  }
  addOldestselector() {
    if (this.totalCount > 0) {
      this.selectors.push( this.createSelector( 0 ) );
    }
  }
  createSelector( page ) {
    return {
      label :  page,
      action: () => this.model.goTo(page),
      selected: page === this.offset
    };
  }
  createSelectorSeparator() {
    return { label: "..." };
  }
}
