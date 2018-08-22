module View.Warehouse exposing (render)

import Actions exposing (Action)
import Article exposing (Article)
import Box exposing (Box)
import Layers exposing (layers)
import MapObject exposing (MapObject)
import Textures
import View.Category
import View.Placeholder


render : List Article -> Int -> MapObject -> List Box
render articles capacity ({ position } as warehouse) =
    let
        ( x, y ) =
            position

        articlesInWarehouse =
            List.filter (Article.inWarehouse warehouse) articles

        numberOfArticles =
            List.length articlesInWarehouse

        placeholders =
            List.range 0 (capacity - numberOfArticles - 1)

        renderArticle number article =
            let
                pos =
                    ( toFloat (modBy 2 number) + x - 1, toFloat (number // 2) + y - 2 )
            in
            [ View.Category.render pos article.category
            , Box.clickable ( 1, 1 ) ( 0, 0 ) pos ( layers.clickAbove, 0 ) (Actions.ClickMapObject warehouse (Just <| Actions.ClickArticle article))
            ]

        renderPlaceholder number =
            View.Placeholder.render
                ( toFloat (modBy 2 (numberOfArticles + number)) + x - 1
                , toFloat ((numberOfArticles + number) // 2) + y - 2
                )

        renderCategory number =
            View.Category.render
                ( toFloat (modBy 2 (numberOfArticles + number)) + x - 1
                , toFloat ((numberOfArticles + number) // 2) + y - 2
                )
    in
    [ Box.offsetTextured ( 0, -1 ) Textures.Warehouse position 0 ( layers.obstacle, 0 )
    , Box.textured Textures.WarehouseShadow position 0 ( layers.shadow, 0 )
    , Box.clickable ( 4, 4 ) ( 0, -1 ) position ( layers.click, 0 ) (Actions.ClickMapObject warehouse Nothing)
    , Box.offsetTextured ( -2, -3 ) Textures.WarehouseBubble warehouse.position 0 ( layers.bubble, 0 )
    ]
        ++ List.concat (List.indexedMap renderArticle articlesInWarehouse)
        ++ List.map renderPlaceholder placeholders
