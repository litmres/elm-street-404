module Box exposing
    ( Box
    , ClickableBoxData
    , TexturedBoxData
    , clickable
    , clicked
    , offsetTextured
    , split
    , textured
    )

import Actions
import Textures exposing (TextureId)


type Box
    = Clickable ClickableBoxData
    | Textured TexturedBoxData


type alias ClickableBoxData =
    { position : ( Float, Float )
    , size : ( Float, Float )
    , offset : ( Float, Float )
    , onClickAction : Actions.Action
    , layer : Float
    }


type alias TexturedBoxData =
    { position : ( Float, Float )
    , offset : ( Float, Float )
    , textureId : TextureId
    , frame : Int
    , layer : Float
    }


offsetTextured : ( Float, Float ) -> TextureId -> ( Float, Float ) -> Int -> ( Float, Float ) -> Box
offsetTextured offset textureId position frame layer =
    Textured
        { position = position
        , offset = offset
        , textureId = textureId
        , frame = frame
        , layer = boxLayer layer position
        }


textured : TextureId -> ( Float, Float ) -> Int -> ( Float, Float ) -> Box
textured =
    offsetTextured ( 0, 0 )


clickable : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Actions.Action -> Box
clickable size offset position layer onClickAction =
    Clickable
        { position = position
        , size = size
        , offset = offset
        , layer = boxLayer layer position
        , onClickAction = onClickAction
        }


clicked : ( Float, Float ) -> ClickableBoxData -> Bool
clicked ( x, y ) ({ position, offset, size, onClickAction } as box) =
    let
        left =
            Tuple.first position + Tuple.first offset

        top =
            Tuple.second position + Tuple.second offset

        right =
            left + Tuple.first size

        bottom =
            top + Tuple.second size
    in
    x >= left && x < right && y >= top && y < bottom


boxLayer : ( Float, Float ) -> ( Float, Float ) -> Float
boxLayer layer position =
    Tuple.first layer * 1000 + Tuple.second position * 100 + Tuple.second layer


split : List Box -> ( List TexturedBoxData, List ClickableBoxData )
split boxes =
    case boxes of
        [] ->
            ( [], [] )

        box :: rest ->
            let
                ( restTextured, restClickable ) =
                    split rest
            in
            case box of
                Textured texturedBox ->
                    ( texturedBox :: restTextured, restClickable )

                Clickable clickableBox ->
                    ( restTextured, clickableBox :: restClickable )
