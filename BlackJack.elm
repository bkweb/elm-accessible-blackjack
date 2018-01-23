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
module BlackJack exposing (..)
import BlackJack.Cards exposing (..)
import BlackJack.Styling exposing (..)
import Accessibility exposing (labelAfter, button, radio)
import Accessibility.Live exposing (atomic)
import Accessibility.Aria exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)
import Keyboard exposing (..)
-- package: elm-community/random-extra
import Random exposing (Seed, generate)
import Random.List exposing (shuffle)

{--
  This function is missing in the accessiblity module. It produces an aria label attribute which is read by screen readers.
--}
ariaLabel : String -> Html.Attribute msg
ariaLabel =
    attribute "aria-label"
{--
  This function is missing in the accessiblity and html modules. It produces a role attribute. This can be used to help screen readers to recognize live regions whose contents
  is supposed to be observed to generate user notifications.
--}
role : String -> Html.Attribute msg
role =
    attribute "role"

{--
  This type is used to control the flow of the game.
--}
type GameStatus
  = Proceed
  | Win
  | Lose
  | Tie
  | Bust
  | GameOver
{--
  This function determines the state of the game.
--}
getGameStatus : Model -> GameStatus
getGameStatus model =
  if model.dealersTurn == False then
    if getHandValue model.playerHand == handLimit then
      Win
    else
      if (getHandValue model.playerHand < handLimit) && (getHandValue model.playerHand >= 0) then
        Proceed
      else
        if model.jetons <= 0 then
          GameOver
        else
          Bust
  else
    if (getHandValue model.dealerHand > handLimit) || ((getHandValue model.dealerHand < getHandValue model.playerHand) && (getHandValue model.dealerHand >= dealerMinValue)) then
      Win
    else
      if (getHandValue model.dealerHand == getHandValue model.playerHand) && (getHandValue model.dealerHand >= dealerMinValue) then
        Tie
      else
        if getHandValue model.dealerHand < dealerMinValue then
          Proceed
        else
          Lose

{--
  This function returns a status message which is displayed to indicate the game state.
--}
getStatusTextMessage : GameStatus -> String
getStatusTextMessage gameStatus =
  case gameStatus of
    Win ->
      "Win"
    Lose ->
      "Lose"
    Tie ->
      "Draw"
    Bust ->
      "Bust"
    GameOver ->
      "Game Over"
    Proceed ->
      ""
{--
  This function returns the style attributes for the status message label.
--}
getStatusTextMessageStyle : GameStatus -> Html.Attribute msg
getStatusTextMessageStyle gameStatus =
  case gameStatus of
    Win ->
      styleWin
    Tie ->
      styleProceed
    Lose ->
      styleBust
    Bust ->
      styleBust
    GameOver ->
      styleGameOver
    Proceed ->
      styleProceed

type alias Model =
  { playerHand : List Card
  , dealerHand : List Card
  , cardStack : List Card
  , currentCardStackIndex : Int -- an indicator moving over the cardStack
  , justShuffledCards : Bool -- is used to display a message that the cardStack hast just been shuffled
  , gameRoundRunning : Bool
  , dealersTurn : Bool
  , stake : Int -- the amount of jetons the player puts on the line
  , jetons : Int -- the current total amount of jetons the player has
  }
initialModel : Model
initialModel =
  { playerHand = []
  , dealerHand = []
  , cardStack = createCardStack
  , currentCardStackIndex = 0
  , justShuffledCards = False
  , gameRoundRunning = False
  , dealersTurn = False
  , stake = 5
  , jetons = 20
  }

type Msg
  = Start
  | FirstCards
  | Hit
  | Stay
  | Draw
  | CheckStatus
  | SetStake Int
  | Shuffle
  | ShuffleList (List Card)
  | Key KeyCode
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Start ->
      -- The dealer takes the first card and then the player receives one triggered by Hit.
      ( { model | dealerHand = []
        , playerHand = []
        , justShuffledCards = False
        , gameRoundRunning = True
        , dealersTurn = False
        }
      )
      |> update FirstCards
    FirstCards ->
      ( { model | dealerHand = takeCard model.currentCardStackIndex model.cardStack model.dealerHand
        , playerHand = takeCard (model.currentCardStackIndex + 1) model.cardStack model.playerHand
        , currentCardStackIndex = if model.currentCardStackIndex < List.length model.cardStack - 2 then model.currentCardStackIndex + 2 else 0
        , gameRoundRunning = True
        }, Cmd.none
      )
    Hit ->
      -- The player takes the next card from the stack or takes the first if the end was reached.
      ( { model | playerHand = takeCard model.currentCardStackIndex model.cardStack model.playerHand
        , currentCardStackIndex = if model.currentCardStackIndex < (List.length model.cardStack) - 1 then model.currentCardStackIndex + 1 else 0
        }
      )
      |> update CheckStatus
    Draw ->
      -- The dealer takes the next card from the stack or takes the first if the end was reached.
      ( { model | dealerHand = takeCard model.currentCardStackIndex model.cardStack model.dealerHand
        , currentCardStackIndex = if model.currentCardStackIndex < List.length model.cardStack - 1 then model.currentCardStackIndex + 1 else 0
        , gameRoundRunning = False
        }
      )
      |> update CheckStatus
    Stay ->
      ( { model | dealersTurn = True }, Cmd.none )
    CheckStatus ->
      case getGameStatus model of
        Win ->
          ( { model | jetons = model.jetons + model.stake, gameRoundRunning = False }, Cmd.none )
        Proceed ->
          ( model, Cmd.none )
        Tie ->
          ( model, Cmd.none )
        Lose ->
          ( { model | jetons = model.jetons - model.stake, gameRoundRunning = False }, Cmd.none )
        Bust ->
          ( { model | jetons = model.jetons - model.stake, gameRoundRunning = False }, Cmd.none )
        GameOver ->
          ( { model | jetons = 0, gameRoundRunning = False }, Cmd.none )
    SetStake newStake ->
      ( { model | stake = newStake }, Cmd.none )
    Shuffle ->
      ( model, generate ShuffleList (shuffle model.cardStack) )
    ShuffleList shuffledList ->
      ( { model | cardStack = shuffledList, currentCardStackIndex = 0, justShuffledCards = True }, Cmd.none )
    Key keyCode ->
      case keyCode of
        72 -> -- 'h'-key
          if model.gameRoundRunning then
            ( model )
            |> update Hit
          else
            ( model, Cmd.none )
        83 -> -- 's'-key
          if model.gameRoundRunning && (List.length model.playerHand > 1) then
            ( model )
            |> update Stay
          else
            ( model, Cmd.none )
        78 -> -- 'n'-key
          if (model.gameRoundRunning == False) && (model.stake <= model.jetons) then
            ( model )
            |> update Start
          else
            ( model, Cmd.none )
        49 -> -- '1'-key
          if (model.gameRoundRunning == False) && (model.jetons >= 5) then
            ( model )
            |> update (SetStake 5)
          else
            ( model, Cmd.none )
        50 -> -- '2'-key
          if (model.gameRoundRunning == False) && (model.jetons >= 10) then
            ( model )
            |> update (SetStake 10)
          else
            ( model, Cmd.none )
        51 -> -- '3'-key
          if (model.gameRoundRunning == False) && (model.jetons >= 20) then
            ( model )
            |> update (SetStake 20)
          else
            ( model, Cmd.none )
        _ ->
          ( model, Cmd.none )

view : Model -> Html Msg
view model =
  body [styleBody]
    [ div [styleBackground]
      [ header [] [h1 [styleCenter] [Html.text "Black Jack"]]
      , Html.main_ []
        [ section [styleLeft]
          [ article []
            [ span []
              [ span [styleTextPlayedCards] [Html.text ("Played Cards")]
              , br [] []
              , span [styleTextPlayedCards] [Html.text ((toString model.currentCardStackIndex) ++ " / " ++ (toString (List.length model.cardStack)))]
              ]
            , Accessibility.button [id "buttonShuffle", Accessibility.Aria.controls "labelShuffledMessage", styleButton, tabindex 7, onClick Shuffle, hidden ((model.gameRoundRunning == True) || (model.jetons <= 0))] [Html.text "Shuffle"]
            , span [id "labelShuffledMessage", role "region", Accessibility.Live.livePolite, Accessibility.Live.atomic True, styleTextShuffledCards] [Html.text (if model.justShuffledCards then "Cards shuffled" else "")]
            ]
            -- labels for displaying the game status and the player's jetons
          , article []
            [ div [id "labelGameStatus", role "region", Accessibility.Live.livePolite, Accessibility.Live.atomic True, styleFloatLeft, styleCenter, getStatusTextMessageStyle (getGameStatus model){--, hidden (model.gameRoundRunning)--}] [Html.text ("Status: " ++ getStatusTextMessage (getGameStatus model))]
            , div [id "labelJetons", role "region", Accessibility.Live.livePolite, Accessibility.Live.atomic True, styleExtraMargin, styleInfoText, styleRight] [Html.text ("Amount of Jetons: " ++ (toString model.jetons))]
            ]
          ]
          -- the cards and labels for the hand values
        , section []
          [ div [id "labelDealerHandValue", role "region", Accessibility.Live.livePolite, Accessibility.Live.atomic True, styleInfoText, styleRight{--, hidden (List.length model.dealerHand == 0)--}] [Html.text ("Dealer's Hand: " ++ toString (getHandValue model.dealerHand))]
          , div [styleRight] (List.map (\card -> img [styleCard, (src card.url), (Html.Attributes.height getImageHeight)] []) model.dealerHand)
          , div [styleRight] (List.map (\card -> img [styleCard, (src card.url), (Html.Attributes.height getImageHeight)] []) model.playerHand)
          , div [id "labelPlayerHandValue", role "region", Accessibility.Live.livePolite, Accessibility.Live.atomic True, styleInfoText, styleRight{--, hidden (List.length model.playerHand == 0)--}] [Html.text ("Player's Hand: " ++ toString (getHandValue model.playerHand))]
          ]
          -- the stake radio buttons
        , section [styleCenter, styleExtraMargin]
          [ labelAfter [styleButton, tabindex 4, hidden model.gameRoundRunning] (text "5 Jetons") (radio  "stake" "5" (model.stake == 5) [onClick (SetStake 5)])
          , labelAfter [styleButton, tabindex 5, hidden model.gameRoundRunning] (text "10 Jetons") (radio  "stake" "10" (model.stake == 10) [onClick (SetStake 10)])
          , labelAfter [styleButton, tabindex 6, hidden model.gameRoundRunning] (text "20 Jetons") (radio  "stake" "20" (model.stake == 20) [onClick (SetStake 20)])
          ]
          -- main action buttons
        , section [styleCenter]
          [ Accessibility.button [id "buttonHit", Accessibility.Aria.controls "labelPlayerHandValue", styleButton, tabindex 3, onClick Hit, hidden ((model.gameRoundRunning == False) || (model.dealersTurn == True))] [Html.text "Hit"]
          , Accessibility.button [id "buttonStay", Accessibility.Aria.controls "labelDealerHandValue labelGameStatus labelJetons", styleButton, tabindex 2, onClick Stay, hidden ((model.gameRoundRunning == False) || (List.length model.playerHand == 1) || (model.dealersTurn == True))] [Html.text "Stay"]
          , Accessibility.button [id "buttonStart", Accessibility.Aria.controls "labelPlayerHandValue labelDealerHandValue", styleButton, tabindex 1, onClick Start, hidden ((model.gameRoundRunning == True) || (model.stake > model.jetons))] [Html.text "Start"]
          ]
        ]
      , footer []
        [ ul [styleExtraMargin, styleLeft]
          [ h4 [] [Html.text "Key settings:"]
          , li [] [Html.text "'h' - hit,"]
          , li [] [Html.text "'s' - stay,"]
          , li [] [Html.text "'n' - start"]
          , li [] [Html.text "'1' - 5 Jetons"]
          , li [] [Html.text "'2' - 10 Jetons"]
          , li [] [Html.text "'3' - 20 Jetons"]
          ]
        ]
      ]
    ]

subscriptions : Model -> Sub Msg
subscriptions currentModel =
  if currentModel.dealersTurn && getHandValue currentModel.dealerHand < dealerMinValue then
    Sub.batch [ Time.every (0.5 * Time.second) (\_ -> Draw) ]
  else
    Sub.batch [ Keyboard.downs Key ]
main : Program Never Model Msg
main =
  program
    { init = (initialModel, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions --\_ -> Sub.none
    }
