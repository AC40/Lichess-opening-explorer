# TODO

## Short Term
- consider pawn promotion in legal moves
- move display system:
    - display captures properly
    - display en passant (and other move flags)
    - display rank/file properly (if necessary: e.g. Nbd7, Rad1, etc.)

## Mid Term
- combine both "movePiece" functions (from arbiter and chessboardVM) (too similar to be seperate)
- make promotion animation prettier
- make ChessColor and whiteTurn the same

## Long term
- add branches to move, recording system
- 50 move rule


----
### Brainstorm Move struct
struct MoveBrainstorm {

    // Start and end tile respectivly (e2-e4, b1-c3, d1-h4 / or rather 6,4-4,4)
    var start: Tile
    var end: Tile
    
    //TODO: Decide, wether piece is really necessary
    var piece: Piece?
    
    // Remember captured piece, to enable backwards tracking
    var capture: Piece?
    
    // Flags special moves for easy handling
    var flag: MoveFlag
    
    // If a move has an alternative, than an array containing that move is added to variations: variations.append([move])
    // Any move, after said move is appended: variations[0].append(move)
    // Additional alternative moves create a seperate variation: variations.append([move2])
    var variations: [[Move]]?
}

enum MoveFlag {
    case capture
    case shortCastle
    case longCastle
    case promotion
    case enPassant
    case doubleStep
}

in Board:
moves: [Move] = [e2-e4, e7-e5 (alts: d7-d5, e4-d5]
