{--
  Funktionale Frontend Entwicklung
  Björn Kaiser
  23.01.2018

  Additional installed packages: elm-community/random-extra, tesk9/accessible-html

  Accessibility module documentation: https://github.com/tesk9/accessible-html/blob/master/src/Accessibility.elm

  Requirements - The following software was used for testing:
    - the screen reader JAWS : http://www.freedomsci.de/serv01.htm
    - the Google Chrome browser

  Note: The tabindex (allows setting the focus on an element by means of the tab-key) value has three different meanings depending on the value:
    -1  : element cannot be focused
    0   : the elements' order is respected
    >0  : the value determines the tab position
--}
module BlackJack.Styling exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

getImageHeight : Int
getImageHeight =
    100

styleBody : Html.Attribute msg
styleBody =
  Html.Attributes.style
    [ ("font-family", "Helvetica")
    , ("background-color", "#888")
    , ("color", "white")
    ]
styleBackground : Html.Attribute msg
styleBackground =
  Html.Attributes.style
    [ ("text-align", "center")
    , ("padding", "1em")
    , ("background-color", "#004466")
    , ("width", "50%")
    , ("min-height", "1000px")
    , ("height", "100%")
    , ("border-width", "1px")
    , ("border-color", "white")
    , ("border-style", "solid")
    , ("margin-left", "25%")
    , ("margin-right", "25%")
    ]
styleInfoText : Html.Attribute msg
styleInfoText =
  Html.Attributes.style
    [ ("color", "#F8EFB9")
    , ("font-size", "1.5em")
    ]
styleExtraMargin : Html.Attribute msg
styleExtraMargin =
  Html.Attributes.style
    [ ("margin", "1em")
    , ("padding", "1em")
    ]
styleFloatLeft : Html.Attribute msg
styleFloatLeft =
  Html.Attributes.style
    [ ("float", "left")
    ]
styleCenter : Html.Attribute msg
styleCenter =
  Html.Attributes.style
    [ ("text-align", "center")
    ]
styleRight : Html.Attribute msg
styleRight =
  Html.Attributes.style
    [ ("text-align", "right")
    ]
styleLeft : Html.Attribute msg
styleLeft =
  Html.Attributes.style
    [ ("text-align", "left")
    ]
styleTextPlayedCards : Html.Attribute msg
styleTextPlayedCards =
  Html.Attributes.style
    [ ("color", "#F8EFB9")
    , ("font-size", "1.5em")
    , ("text-align", "center")
    ]
styleButton : Html.Attribute msg
styleButton =
  Html.Attributes.style
    [ ("font-size", "1.5em")
    , ("padding-left", "0.75em")
    , ("padding-right", "0.75em")
    , ("padding-top", "0.5em")
    , ("padding-bottom", "0.5em")
    , ("margin", "0.5em")
    , ("font-weight", "bold")
    ]
styleCard : Html.Attribute msg
styleCard =
  Html.Attributes.style
    [ ("margin", "0.5em")
    ]
styleGameOver : Html.Attribute msg
styleGameOver =
  Html.Attributes.style
    [ ("color", "red")
    , ("font-size", "2.5em")
    ]
styleWin : Html.Attribute msg
styleWin =
  Html.Attributes.style
    [ ("color", "#AAFFAA")
    , ("font-size", "2.5em")
    ]
styleBust : Html.Attribute msg
styleBust =
  Html.Attributes.style
    [ ("color", "orange")
    , ("font-size", "2.5em")
    ]
styleProceed : Html.Attribute msg
styleProceed =
  Html.Attributes.style
    [ ("color", "white")
    , ("font-size", "2.5em")
    ]
styleTextShuffledCards : Html.Attribute msg
styleTextShuffledCards =
  Html.Attributes.style
    [ ("color", "#B9EFF8")
    , ("font-size", "1em")
    , ("margin-left", "0.75em")
    ]
