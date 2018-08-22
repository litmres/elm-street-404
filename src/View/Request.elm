module View.Request exposing (render)

import Actions exposing (Action)
import Box exposing (Box)
import Layers exposing (layers)
import MapObject exposing (MapObject)
import Request exposing (Request)
import Textures
import View.Category


renderReturn : ( Float, Float ) -> Box
renderReturn position =
    Box.textured
        Textures.Categories
        position
        13
        ( layers.article
        , 1
        )


render : ( Float, Float ) -> MapObject -> Request -> List Box
render position house request =
    let
        renderClickable =
            Box.clickable ( 1, 1 ) ( 0, 0 ) position ( layers.clickAbove, 0 )
    in
    case request.category of
        Request.Return article ->
            renderClickable (Actions.ClickMapObject house (Just <| Actions.ClickArticle article))
                :: (if request.blinkHidden then
                        []

                    else
                        [ renderReturn position
                        , View.Category.render position article.category
                        ]
                   )

        Request.Order category ->
            renderClickable (Actions.ClickMapObject house (Just <| Actions.ClickCategory category))
                :: (if request.blinkHidden then
                        []

                    else
                        [ View.Category.render position category ]
                   )
