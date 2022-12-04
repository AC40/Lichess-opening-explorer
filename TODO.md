# TODO

## Short Term
- add move recording system

## Mid Term
- combine both "movePiece" functions (from arbiter and chessboardVM) (too similar to be seperate)
- make promotion animation prettier
- make ChessColor and whiteTurn the same

## Long term
- add branches to move, recording system
- 50 move rule


----
### Brainstorm Move struct
struct Move {

    var start: Tile
    var end: Tile
    
    var piece: Piece?
    
    var flag: MoveFlag
}

enum MoveFlag {
    case 
}
