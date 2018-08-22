module View.StartGame exposing (render)

import Actions exposing (Action)
import Box exposing (Box)
import Layers exposing (layers)
import Textures


render : ( Int, Int ) -> List Box
render ( width, height ) =
    [ Box.textured
        Textures.ClickToStart
        ( toFloat width / 2 - 5, toFloat height / 2 - 1 )
        0
        ( layers.clickToStart, 0 )
    , Box.clickable
        ( 10, 2 )
        ( 0, 0 )
        ( toFloat width / 2 - 5, toFloat height / 2 - 1 )
        ( layers.clickToStartAbove, 0 )
        Actions.Start
    , Box.textured
        Textures.ElmStreet404
        ( toFloat width / 2 - 6.5, toFloat height / 4 - 2 )
        0
        ( layers.shadow, 0 )
    ]
