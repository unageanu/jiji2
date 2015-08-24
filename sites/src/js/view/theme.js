import MUI from "material-ui"
import _   from "underscore"

const Colors           = MUI.Styles.Colors;
const Spacing          = MUI.Styles.Spacing;
const ColorManipulator = MUI.Utils.ColorManipulator;

export default {
  spacing: _.defaults({
  }, Spacing),
  contentFontFamily: "Roboto, 'Roboto Condensed', 'ヒラギノ角ゴ Pro W3',"
   + "'Hiragino Kaku Gothic Pro', 'メイリオ', Meiryo, "
   + "'Noto Sans Japanese', sans-serif",
  getPalette() {
    return {
      primary1Color:  "#356868",
      primary2Color:  "#2B5353", // dark
      primary3Color:  "#417E7E", // light
      accent1Color:   "#00BFA5",
      accent2Color:   "#1DE9B6", // light
      accent3Color:   "#64FFDA", // super light
      accent4Color:   "#FF3350", // red
      textColor:      "#666666",
      textColorLight: "#999999",
      positiveColor:  "#00BFA5",
      nagativeColor:  "#FF3350",
      canvasColor: Colors.white,
      borderColor: Colors.grey300,
      disabledColor: ColorManipulator.fade("#666666", 0.3),
      backgroundColor: "#FFF",
      backgroundColorDark: "#F0F0F0"
    };
  },
  getComponentThemes(palette, spacing) {
    spacing = spacing || Spacing;
    let obj = {
      appBar: {
        color: palette.primary1Color,
        textColor: Colors.darkWhite,
        height: spacing.desktopKeylineIncrement
      },
      button: {
        height: 36,
        minWidth: 88,
        iconButtonSize: spacing.iconSize * 2
      },
      checkbox: {
        boxColor: palette.textColor,
        checkedColor: palette.primary1Color,
        requiredColor: palette.primary1Color,
        disabledColor: palette.disabledColor,
        labelColor: palette.textColor,
        labelDisabledColor: palette.disabledColor
      },
      datePicker: {
        color: palette.primary1Color,
        textColor: Colors.white,
        calendarTextColor: palette.textColor,
        selectColor: palette.primary2Color,
        selectTextColor: Colors.white
      },
      dropDownMenu: {
        accentColor: palette.borderColor
      },
      flatButton: {
        color: palette.canvasColor,
        textColor: palette.textColor,
        primaryTextColor: palette.accent1Color,
        secondaryTextColor: palette.primary1Color
      },
      floatingActionButton: {
        buttonSize: 56,
        miniSize: 40,
        color: palette.accent1Color,
        iconColor: Colors.white,
        secondaryColor: palette.primary1Color,
        secondaryIconColor: Colors.white
      },
      leftNav: {
        width: 288,
        color: Colors.white
      },
      menu: {
        backgroundColor: Colors.white,
        containerBackgroundColor: Colors.white
      },
      menuItem: {
        dataHeight: 32,
        height: 48,
        hoverColor: "inherited", //"rgba(0, 0, 0, .045)",
        padding: spacing.desktopGutterLess,
        selectedTextColor: palette.accent1Color
      },
      menuSubheader: {
        padding: spacing.desktopGutterLess,
        borderColor: palette.borderColor,
        textColor: palette.textColorLight
      },
      paper: {
        backgroundColor: Colors.white
      },
      radioButton: {
        borderColor:  palette.textColor,
        backgroundColor: Colors.white,
        checkedColor: palette.primary1Color,
        requiredColor: palette.primary1Color,
        disabledColor: palette.disabledColor,
        size: 24,
        labelColor: palette.textColor,
        labelDisabledColor: palette.disabledColor
      },
      raisedButton: {
        color: Colors.white,
        textColor: palette.textColor,
        primaryColor: palette.accent1Color,
        primaryTextColor: Colors.white,
        secondaryColor: palette.primary1Color,
        secondaryTextColor: Colors.white
      },
      slider: {
        trackSize: 2,
        trackColor: Colors.minBlack,
        trackColorSelected: Colors.grey500,
        handleSize: 12,
        handleSizeDisabled: 8,
        handleColorZero: Colors.grey400,
        handleFillColor: Colors.white,
        selectionColor: palette.primary3Color,
        rippleColor: palette.primary1Color
      },
      snackbar: {
        textColor: Colors.white,
        backgroundColor: "#323232",
        actionColor: palette.accent1Color
      },
      table: {
        backgroundColor: Colors.white
      },
      tableHeader: {
        borderColor: palette.borderColor
      },
      tableHeaderColumn: {
        textColor: Colors.lightBlack,
        height: 56,
        spacing: 28
      },
      tableFooter: {
        borderColor: palette.borderColor,
        textColor: Colors.lightBlack
      },
      tableRow: {
        hoverColor: Colors.grey200,
        stripeColor: ColorManipulator.lighten(palette.primary1Color, 0.55),
        selectedColor: Colors.grey300,
        textColor: Colors.darkBlack,
        borderColor: palette.borderColor
      },
      tableRowColumn: {
        height: 48,
        spacing: 28
      },
      timePicker: {
        color: Colors.white,
        textColor: Colors.grey600,
        accentColor: palette.primary1Color,
        clockColor: Colors.black,
        selectColor: palette.primary2Color,
        selectTextColor: Colors.white
      },
      toggle: {
        thumbOnColor: palette.primary1Color,
        thumbOffColor: Colors.grey50,
        thumbDisabledColor: Colors.grey400,
        thumbRequiredColor: palette.primary1Color,
        trackOnColor: ColorManipulator.fade(palette.primary1Color, 0.5),
        trackOffColor: Colors.minBlack,
        trackDisabledColor: Colors.faintBlack,
        labelColor: palette.textColor,
        labelDisabledColor: palette.disabledColor
      },
      toolbar: {
        backgroundColor: ColorManipulator.darken("#eeeeee", 0.05),
        height: 56,
        titleFontSize: 20,
        iconColor: "rgba(0, 0, 0, .40)",
        separatorColor: "rgba(0, 0, 0, .175)",
        menuHoverColor: "rgba(0, 0, 0, .10)"
      },
      tabs: {
        backgroundColor: palette.primary1Color
      },
      textField: {
        textColor: palette.textColor,
        hintColor: palette.disabledColor,
        floatingLabelColor: palette.textColor,
        disabledTextColor: palette.disabledColor,
        errorColor: Colors.red500,
        focusColor: palette.primary1Color,
        backgroundColor: "transparent",
        borderColor: palette.borderColor
      }
    };

    obj.flatButton.disabledTextColor = ColorManipulator.fade(obj.flatButton.textColor, 0.3);
    obj.floatingActionButton.disabledColor = ColorManipulator.darken(Colors.white, 0.1);
    obj.floatingActionButton.disabledTextColor = ColorManipulator.fade(palette.textColor, 0.3);
    obj.raisedButton.disabledColor = ColorManipulator.darken(obj.raisedButton.color, 0.1);
    obj.raisedButton.disabledTextColor = ColorManipulator.fade(obj.raisedButton.textColor, 0.3);
    obj.slider.handleSizeActive = obj.slider.handleSize * 2;
    obj.toggle.trackRequiredColor = ColorManipulator.fade(obj.toggle.thumbRequiredColor, 0.5);

    return obj;
  }
}
