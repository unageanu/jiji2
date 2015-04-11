import React      from "react";
import MUI        from "material-ui";
import AppBar     from "./app-bar";
import LeftNavi   from "./left-navi";
import TextCard   from "./text-card";
import ImageCard  from "./image-card";
import ChartCard  from "./chart-card";

const AppCanvas = MUI.AppCanvas;

export default React.createClass({
    render() {
        return (
          <AppCanvas predefinedLayout={1}>
            <AppBar onMenuIconTapped={this.toggleLeftNavi}>
            </AppBar>
            <LeftNavi ref="leftNav" />

            <div className="content">
              <TextCard />
              <ImageCard />
              <ChartCard />
              <TextCard />
              <TextCard />
              <TextCard />
              <TextCard />
            </div>
          </AppCanvas>
        );
    },

    toggleLeftNavi() {
        this.refs.leftNav.toggle();
    }
});
