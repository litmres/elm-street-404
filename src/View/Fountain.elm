module View.Fountain exposing (render)

import Box exposing (Box)
import Fountain exposing (Fountain)
import Layers exposing (layers)
import MapObject exposing (MapObject)
import Textures


render : Fountain -> MapObject -> List Box
render { frame } { position } =
    [ Box.textured Textures.Fountain position 0 ( layers.obstacle, 0 )
    , Box.offsetTextured ( 1, -1 ) Textures.FountainSpring position frame ( layers.obstacle, 1 )
    , Box.offsetTextured ( 0, 1 ) Textures.FountainShadow position 0 ( layers.shadow, 0 )
    ]
