;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname |HW 10|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Data Definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; BG coord system is *cell* units, with (0,0) at lower/left corner,
;;; where one grid cell is a square big enough for one Brick

(define PIXELS/CELL 30)
(define BG-HEIGHT 20)
(define BG-WIDTH 10)

(define BG (empty-scene (* PIXELS/CELL BG-WIDTH) (* PIXELS/CELL BG-HEIGHT)))

;-------------------------------------------------------------------------------------------------

;;; A Brick is a (make-brick Number Number Color)
(define-struct brick [x y color])

(define BRICK-1 (make-brick 5 9 'pink))
(define BRICK-2 (make-brick 4 9 'green))
(define BRICK-3 (make-brick 7 7 'blue))

;-------------------------------------------------------------------------------------------------

;;; A Bricks (Set of Bricks) is one of:
;;; - empty
;;; - (cons Brick Bricks)
;;; Order does not matter.

(define EX-1 (list (make-brick 0 1 'green)  (make-brick 1 1 'green)
                   (make-brick 0 2 'green)  (make-brick 1 2 'green)))
(define EX-2 (list (make-brick 6 0 'blue)   (make-brick 7 0 'blue)
                   (make-brick 8 0 'blue)   (make-brick 9 0 'blue)))
(define EX-3 (list (make-brick 0 0 'purple) (make-brick 1 0 'purple)
                   (make-brick 2 0 'purple) (make-brick 2 1 'purple)))
(define EX-4 (list (make-brick 3 1 'cyan)   (make-brick 4 0 'cyan)
                   (make-brick 3 0 'cyan)   (make-brick 5 0 'cyan)))
(define EX-5 (list (make-brick 7 1 'orange) (make-brick 8 1 'orange)
                   (make-brick 9 1 'orange) (make-brick 8 2 'orange)))
(define EX-6 (list (make-brick 1 3 'pink)   (make-brick 2 3 'pink)
                   (make-brick 3 2 'pink)   (make-brick 2 2 'pink)))
(define EX-7 (list (make-brick 6 3 'red)    (make-brick 7 3 'red)
                   (make-brick 6 2 'red)    (make-brick 5 2 'red)))

;-------------------------------------------------------------------------------------------------

;;; A Pt (2D point) is a (make-posn Integer Integer)
;;;
;;; A Tetra is a (make-tetra Pt Bricks)
;;; The center point is the point around which the tetra
;;; rotates when it spins.
(define-struct tetra [center bricks])

(define O-TETRA (make-tetra (make-posn 0.5 1.5) EX-1))
(define I-TETRA (make-tetra (make-posn 7   0) EX-2))
(define L-TETRA (make-tetra (make-posn 1   0) EX-3))
(define J-TETRA (make-tetra (make-posn 4   0) EX-4))
(define T-TETRA (make-tetra (make-posn 8   1) EX-5))
(define Z-TETRA (make-tetra (make-posn 2   2) EX-6))
(define S-TETRA (make-tetra (make-posn 5   1) EX-7))

;-------------------------------------------------------------------------------------------------

;;; A World is a (make-world Tetra Bricks Number)
;;; The set of bricks represents the pile of bricks
;;; at the bottom of the screen.
(define-struct world [tetra pile score])

(define WORLD0 (make-world L-TETRA '() 0))
(define WORLD1 (make-world I-TETRA EX-3 4))
(define WORLD2 (make-world O-TETRA (append EX-2 EX-3) 8))

;-------------------------------------------------------------------------------------------------

(define NEW-BRICK (list (make-brick 5 17 'blue) (make-brick 5 18 'blue)
                        (make-brick 5 19 'blue) (make-brick 5 20 'blue)))
(define NEW-TETRA (make-tetra (make-posn 5 18) NEW-BRICK))
(define WORLD3 (make-world NEW-TETRA
                           (list (make-brick 5 13 'blue) (make-brick 5 14 'blue)
                                 (make-brick 5 15 'blue) (make-brick 5 16 'blue))
                           4))
(define WORLD4 (make-world T-TETRA '() 0))

(define WORLD5 (make-world
                (make-tetra (make-posn 5 16) (list (make-brick 4 16 'cyan) (make-brick 5 16 'cyan)
                                                   (make-brick 6 16 'cyan) (make-brick 4 17 'cyan)))
                (list
                 (make-brick 4 1 'orange) (make-brick 3 1 'orange) (make-brick 2 1 'orange)
                 (make-brick 3 0 'orange) (make-brick 0 0 'cyan)   (make-brick 1 0 'cyan)
                 (make-brick 2 0 'cyan)   (make-brick 0 1 'cyan)   (make-brick 4 0 'purple)
                 (make-brick 5 0 'purple) (make-brick 6 0 'purple) (make-brick 6 1 'purple)
                 (make-brick 7 0 'purple) (make-brick 8 0 'purple) (make-brick 9 0 'purple)
                 (make-brick 9 1 'purple))
                16))

(define WORLD6 (make-world
                (make-tetra (make-posn 4.5 10.5)
                            (list (make-brick 4 10 'green) (make-brick 5 10 'green)
                                  (make-brick 4 11 'green) (make-brick 5 11 'green)))
                (list (make-brick 8 2 'cyan) (make-brick 7 2 'cyan) (make-brick 6 2 'cyan)
                      (make-brick 8 1 'cyan) (make-brick 3 2 'pink) (make-brick 4 2 'pink)
                      (make-brick 4 1 'pink) (make-brick 5 1 'pink) (make-brick 5 0 'red)
                      (make-brick 6 0 'red) (make-brick 6 1 'red) (make-brick 7 1 'red)
                      (make-brick 2 1 'pink) (make-brick 3 1 'pink) (make-brick 3 0 'pink)
                      (make-brick 4 0 'pink) (make-brick 0 1 'pink) (make-brick 1 1 'pink)
                      (make-brick 1 0 'pink) (make-brick 2 0 'pink) (make-brick 7 0 'purple)
                      (make-brick 8 0 'purple) (make-brick 9 0 'purple) (make-brick 9 1 'purple))
                24))

(define WORLD7 (make-world
                (make-tetra (make-posn 5 20) (list (make-brick 4 20 'cyan) (make-brick 5 20 'cyan)
                                                   (make-brick 6 20 'cyan) (make-brick 4 21 'cyan)))
                (list (make-brick 2 4 'cyan) (make-brick 1 4 'cyan) (make-brick 0 4 'cyan)
                      (make-brick 2 3 'cyan) (make-brick 1 1 'purple) (make-brick 1 2 'purple)
                      (make-brick 1 3 'purple) (make-brick 0 3 'purple) (make-brick 8 3 'green)
                      (make-brick 9 3 'green) (make-brick 8 4 'green) (make-brick 9 4 'green)
                      (make-brick 5 3 'orange) (make-brick 6 3 'orange) (make-brick 7 3 'orange)
                      (make-brick 6 4 'orange) (make-brick 2 2 'red) (make-brick 3 2 'red)
                      (make-brick 3 3 'red) (make-brick 4 3 'red) (make-brick 6 2 'blue)
                      (make-brick 7 2 'blue) (make-brick 8 2 'blue) (make-brick 9 2 'blue)
                      (make-brick 5 0 'orange) (make-brick 6 0 'orange) (make-brick 7 0 'orange)
                      (make-brick 6 1 'orange) (make-brick 2 0 'cyan) (make-brick 3 0 'cyan)
                      (make-brick 4 0 'cyan) (make-brick 2 1 'cyan) (make-brick 8 0 'pink)
                      (make-brick 9 0 'pink) (make-brick 9 1 'pink) (make-brick 1 0 'cyan))
                56))

;-------------------------------------------------------------------------------------------------

; All of the list of bricks that we will use in our tetris. 
(define green-bricks (list (make-brick 4 20 'green)  (make-brick 5 20 'green)
                           (make-brick 4 21 'green)  (make-brick 5 21 'green)))
(define blue-bricks (list (make-brick 3 21 'blue)  (make-brick 4 21 'blue)
                          (make-brick 5 21 'blue)  (make-brick 6 21 'blue)))
(define purple-bricks (list (make-brick 4 20 'purple)  (make-brick 5 20 'purple)
                            (make-brick 6 20 'purple)  (make-brick 6 21 'purple)))
(define cyan-bricks (list (make-brick 4 20 'cyan)  (make-brick 5 20 'cyan)
                          (make-brick 6 20 'cyan)  (make-brick 4 21 'cyan)))
(define orange-bricks (list (make-brick 4 20 'orange)  (make-brick 5 20 'orange)
                            (make-brick 6 20 'orange)  (make-brick 5 21 'orange)))
(define pink-bricks (list (make-brick 4 21 'pink)  (make-brick 5 21 'pink)
                          (make-brick 5 20 'pink)  (make-brick 6 20 'pink)))
(define red-bricks (list (make-brick 4 20 'red)  (make-brick 5 20 'red)
                         (make-brick 5 21 'red)  (make-brick 6 21 'red)))

; Center point for bricks
(define CENTER-POINT (make-posn (/ BG-WIDTH 2) BG-HEIGHT))

(define O (make-tetra (make-posn (-  (/ BG-WIDTH 2) 0.5) (+ BG-HEIGHT 0.5)) green-bricks))
(define I (make-tetra CENTER-POINT blue-bricks))
(define L (make-tetra CENTER-POINT purple-bricks))
(define J (make-tetra CENTER-POINT cyan-bricks))
(define T (make-tetra CENTER-POINT orange-bricks))
(define Z (make-tetra CENTER-POINT pink-bricks))
(define S (make-tetra CENTER-POINT red-bricks))

;-------------------------------------------------------------------------------------------------

; A Dir (Direction) is:
; - 'left
; - 'right
; - 'down

; A Rot-Dir (Rotate Direction) is:
; - 'cw        (clockwise)
; - 'ccw       (counterclockwise)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; brick->image: Brick -> Image
; Turn a brick into a 2D square with black outline

(check-expect (brick->image BRICK-1) (overlay (square PIXELS/CELL 'outline 'black)
                                              (square PIXELS/CELL 'solid 'pink)))
(check-expect (brick->image BRICK-2) (overlay (square PIXELS/CELL 'outline 'black)
                                              (square PIXELS/CELL 'solid 'green)))
(check-expect (brick->image BRICK-3) (overlay (square PIXELS/CELL 'outline 'black)
                                              (square PIXELS/CELL 'solid 'blue)))

(define (brick->image b)
  (overlay (square PIXELS/CELL 'outline 'black)
           (square PIXELS/CELL 'solid (brick-color b))))


;-------------------------------------------------------------------------------------------------

; place-image/cell: Image Natural Natural Image -> Image
; Place-image in cells units

(check-expect (place-image/cell (brick->image BRICK-1) 1 1 BG)
              (place-image      (brick->image BRICK-1) 45 555 BG))
(check-expect (place-image/cell (brick->image BRICK-2) 2 0 BG)
              (place-image      (brick->image BRICK-2) 75 585 BG))
(check-expect (place-image/cell (brick->image BRICK-3) 1 2 BG)
              (place-image      (brick->image BRICK-3) 45 525 BG))
 
(define (place-image/cell i1 x y i2)
  (place-image i1
               (* PIXELS/CELL (+ 1/2 x))
               (* PIXELS/CELL (- BG-HEIGHT (+ 1/2 y)))
               i2))

;-------------------------------------------------------------------------------------------------

; brick+scene: Brick Image -> Image
; Adds Brick to scene

(check-expect (brick+scene BRICK-1 BG) (place-image/cell (brick->image BRICK-1) 5 9 BG))
(check-expect (brick+scene BRICK-2 BG) (place-image/cell (brick->image BRICK-2) 4 9 BG))
(check-expect (brick+scene BRICK-3 BG) (place-image/cell (brick->image BRICK-3) 7 7 BG))

(define (brick+scene b scene)
  (place-image/cell (brick->image b)
                    (brick-x b)
                    (brick-y b)
                    scene))

;-------------------------------------------------------------------------------------------------

; bricks+scene: Bricks Image -> Image
; Adds Bricks to scene

(check-expect (bricks+scene '() BG) BG)

(check-expect (bricks+scene EX-6 BG)
              (brick+scene (make-brick 1 3 'pink)
                           (brick+scene (make-brick 2 3 'pink)
                                        (brick+scene (make-brick 3 2 'pink)
                                                     (brick+scene (make-brick 2 2 'pink) BG)))))
(check-expect (bricks+scene EX-1 BG)
              (brick+scene (make-brick 0 1 'green)
                           (brick+scene (make-brick 1 1 'green)
                                        (brick+scene (make-brick 0 2 'green)
                                                     (brick+scene (make-brick 1 2 'green) BG)))))

(define (bricks+scene b scene)
  (foldr brick+scene scene b))

;-------------------------------------------------------------------------------------------------

; world->scene: World -> Image
; Renders current world to image

(check-expect (world->scene WORLD0)
              (bricks+scene (tetra-bricks L-TETRA) BG))
(check-expect (world->scene WORLD1)
              (bricks+scene (tetra-bricks I-TETRA) (bricks+scene EX-3 BG)))
(check-expect (world->scene WORLD2)
              (bricks+scene (tetra-bricks O-TETRA) (bricks+scene (append EX-2 EX-3) BG)))

(define (world->scene w)
  (bricks+scene (tetra-bricks (world-tetra w))
                (bricks+scene (world-pile w) BG)))
;-------------------------------------------------------------------------------------------------

; brick-rotate-ccw: Brick Pt -> Brick
; Rotate the brick 90 counterclockwise around the posn.

(check-expect (brick-rotate-ccw BRICK-1 (make-posn 4.5 8.5)) (make-brick 4 9 'pink))
(check-expect (brick-rotate-ccw BRICK-2 (make-posn 4.5 8.5)) (make-brick 4 8 'green))
(check-expect (brick-rotate-ccw BRICK-3 (make-posn 6.5 6.5)) (make-brick 6 7 'blue))

(define (brick-rotate-ccw b c)
  (make-brick (+ (posn-x c)
                 (- (posn-y c)
                    (brick-y b)))
              (+ (posn-y c)
                 (- (brick-x b)
                    (posn-x c)))
              (brick-color b)))

;-------------------------------------------------------------------------------------------------

; brick-rotate-cw: Brick Pt -> Brick
; Rotate the Brick 90 clockwise around the posn.

(check-expect (brick-rotate-cw BRICK-1 (make-posn 4.5 8.5)) (make-brick 5 8 'pink))
(check-expect (brick-rotate-cw BRICK-2 (make-posn 4.5 8.5)) (make-brick 5 9 'green))
(check-expect (brick-rotate-cw BRICK-3 (make-posn 6.5 6.5)) (make-brick 7 6 'blue))

(define (brick-rotate-cw b c)
  (brick-rotate-ccw (brick-rotate-ccw (brick-rotate-ccw b c) c) c))

;-------------------------------------------------------------------------------------------------

; bricks-rotate-ccw: Bricks Pt -> Brick
; Rotate the Bricks 90 counterclockwise around the posn
(check-expect (bricks-rotate-ccw '() (make-posn 3 5)) '())
(check-expect (bricks-rotate-ccw EX-5 (make-posn 8 1))
              (list (make-brick 8 0 'orange) (make-brick 8 1 'orange)
                    (make-brick 8 2 'orange) (make-brick 7 1 'orange)))
(check-expect (bricks-rotate-ccw EX-6 (make-posn 2 2))
              (list (make-brick 1 1 'pink) (make-brick 1 2 'pink)
                    (make-brick 2 3 'pink) (make-brick 2 2 'pink)))

(define (bricks-rotate-ccw b c)
  (map (lambda (x) (brick-rotate-ccw x c)) b))

;-------------------------------------------------------------------------------------------------

; bricks-rotate-cw: Bricks Pt -> Brick
; Rotate the Bricks 90 clockwise around the posn
(check-expect (bricks-rotate-cw '() (make-posn 3 5)) '())
(check-expect (bricks-rotate-cw EX-5 (make-posn 8 1))
              (list (make-brick 8 2 'orange) (make-brick 8 1 'orange)
                    (make-brick 8 0 'orange) (make-brick 9 1 'orange)))
(check-expect (bricks-rotate-cw EX-6 (make-posn 2 2))
              (list (make-brick 3 3 'pink) (make-brick 3 2 'pink)
                    (make-brick 2 1 'pink) (make-brick 2 2 'pink)))

(define (bricks-rotate-cw b c)
  (map (lambda (x) (brick-rotate-cw x c)) b))

;-------------------------------------------------------------------------------------------------

; tetra-rotate: Tetra Rot-Dir -> Tetra
; Rotate the Tetra 90 counterclockwise or clockwise around it's center point

(check-expect (tetra-rotate S-TETRA 'ccw) (make-tetra (make-posn 5 1)
                                                      (bricks-rotate-ccw EX-7 (make-posn 5 1))))
(check-expect (tetra-rotate Z-TETRA 'ccw) (make-tetra (make-posn 2 2)
                                                      (bricks-rotate-ccw EX-6 (make-posn 2 2))))
(check-expect (tetra-rotate S-TETRA 'cw) (make-tetra (make-posn 5 1)
                                                     (bricks-rotate-cw EX-7 (make-posn 5 1))))
(check-expect (tetra-rotate Z-TETRA 'cw) (make-tetra (make-posn 2 2)
                                                     (bricks-rotate-cw EX-6 (make-posn 2 2))))

(define (tetra-rotate t rd)
  (cond [(symbol=? 'ccw rd) (make-tetra (tetra-center t)
                                        (bricks-rotate-ccw (tetra-bricks t) (tetra-center t)))]
        [(symbol=? 'cw rd) (make-tetra (tetra-center t)
                                       (bricks-rotate-cw (tetra-bricks t) (tetra-center t)))]))

;-------------------------------------------------------------------------------------------------

; move-brick: Brick Dir -> Brick
; Move Brick one cell unit in given direction

(check-expect (move-brick BRICK-1 'right) (make-brick 6 9 'pink))
(check-expect (move-brick BRICK-1 'left)  (make-brick 4 9 'pink))
(check-expect (move-brick BRICK-2 'down)  (make-brick 4 8 'green))

(define (move-brick b d)
  (cond [(symbol=? d 'right) (make-brick (+ (brick-x b) 1) (brick-y b)    (brick-color b))]
        [(symbol=? d 'left)  (make-brick (- (brick-x b) 1) (brick-y b)    (brick-color b))]
        [(symbol=? d 'down)  (make-brick    (brick-x b) (- (brick-y b) 1) (brick-color b))]))

;-------------------------------------------------------------------------------------------------

; shift-bricks: Bricks Dir -> Bricks
; Shift Bricks one cell unit down, left and right

(check-expect (shift-bricks '() 'left) '())
(check-expect (shift-bricks EX-7 'down) (list (make-brick 6 2 'red)  (make-brick 7 2 'red)
                                              (make-brick 6 1 'red)  (make-brick 5 1 'red)))
(check-expect (shift-bricks EX-6 'right) (list (make-brick 2 3 'pink) (make-brick 3 3 'pink)
                                               (make-brick 4 2 'pink) (make-brick 3 2 'pink)))

(define (shift-bricks b d)
  (map (lambda (x) (move-brick x d)) b))

;-------------------------------------------------------------------------------------------------

; shift-tetra: Tetra Dir -> Tetra
; Shift Tetra one cell unit down, left and right

(check-expect (shift-tetra S-TETRA 'down)
              (make-tetra (make-posn 5 0)
                          (list (make-brick 6 2 'red) (make-brick 7 2 'red)
                                (make-brick 6 1 'red) (make-brick 5 1 'red))))
(check-expect (shift-tetra Z-TETRA 'left)
              (make-tetra (make-posn 1 2)
                          (list (make-brick 0 3 'pink) (make-brick 1 3 'pink)
                                (make-brick 2 2 'pink) (make-brick 1 2 'pink))))
(check-expect (shift-tetra T-TETRA 'right)
              (make-tetra (make-posn 9 1)
                          (list (make-brick 8 1 'orange) (make-brick 9 1 'orange)
                                (make-brick 10 1 'orange) (make-brick 9 2 'orange))))

(define (shift-tetra t d)
  (local [(define X-CORD (posn-x (tetra-center t)))
          (define Y-CORD (posn-y (tetra-center t)))
          (define SHIFT-TETRA (shift-bricks (tetra-bricks t) d))]
    (cond [(symbol=? d 'down)  (make-tetra (make-posn X-CORD (- Y-CORD 1)) SHIFT-TETRA)]
          [(symbol=? d 'right) (make-tetra (make-posn (+ X-CORD 1) Y-CORD) SHIFT-TETRA)]
          [(symbol=? d 'left)  (make-tetra (make-posn (- X-CORD 1) Y-CORD) SHIFT-TETRA)])))

;-------------------------------------------------------------------------------------------------

; wall-collide?: Bricks Dir -> Boolean
; Is the Brick touching the wall?

(check-expect (wall-collide? (shift-bricks EX-3 'left) 'left)  #t)
(check-expect (wall-collide? EX-7 'right) #f)
(check-expect (wall-collide? EX-3 'right) #f)
(check-expect (wall-collide? (shift-bricks EX-5 'right) 'right) #t)

(define (wall-collide? b d)
  (local [; x-cord: Brick -> Number
          ; Find the X-coordinate of given brick
          (define (x-cord br) (brick-x (move-brick br d)))]
    (cond [(symbol=? d 'left) (ormap (lambda (x) (< (x-cord x) 0)) b)]
          [(symbol=? d 'right) (ormap (lambda (x) (> (x-cord x) (- BG-WIDTH 1))) b)])))

;-------------------------------------------------------------------------------------------------

; over-top?: Bricks -> Boolean
; Is the Bricks over the top of the screen?

(check-expect (over-top? NEW-BRICK) #t)
(check-expect (over-top? EX-6) #f)
(check-expect (over-top? EX-5) #f)

(define (over-top? b)
  (ormap (lambda (br) (> (brick-y br) (- BG-HEIGHT 1))) b))

;-------------------------------------------------------------------------------------------------

; overflow?: World -> Boolean
; Is the top of the tetra touching the top of the screen after landed?

(check-expect (overflow? WORLD3) #t)
(check-expect (overflow? WORLD2) #f)
(check-expect (overflow? WORLD1) #f)

(define (overflow? w)
  (local [(define W-BRICKS (tetra-bricks (world-tetra w)))]
    (and (over-top? W-BRICKS)
         (touching? (world-pile w) (shift-bricks W-BRICKS 'down)))))

;-------------------------------------------------------------------------------------------------

; on-ground?: Bricks -> Boolean
; Is the Bricks on the ground?
(check-expect (on-ground? EX-3) #t)
(check-expect (on-ground? EX-1) #f)
(check-expect (on-ground? EX-6) #f)

(define (on-ground? b)
  (ormap (lambda (br) (<= (brick-y br) 0)) b))

;-------------------------------------------------------------------------------------------------

; b-touching?: Bricks Brick -> Boolean
; Is the Brick touching the Bricks (Set of Bricks)?

(check-expect (b-touching? EX-3   (make-brick 0 0 'red))  #t)
(check-expect (b-touching? EX-3   (make-brick 3 4 'pink)) #f)
(check-expect (b-touching? '() (make-brick 3 4 'pink)) #f)

(define (b-touching? s b)
  (ormap (lambda (br) 
           (and (= (brick-x br) (brick-x b))
                (= (brick-y br) (brick-y b))))
         s))

;-------------------------------------------------------------------------------------------------

; touching?: Bricks Bricks -> Boolean
; Are the two Bricks touching each other?

(check-expect (touching? '() EX-5) #f)
(check-expect (touching? EX-3 (shift-bricks EX-1 'right)) #t)
(check-expect (touching? EX-3 EX-5) #f)

(define (touching? b1 b2)
  (ormap (lambda (brick) (b-touching? b2 brick))
         b1))

;-------------------------------------------------------------------------------------------------

; landed?: World -> Boolean
; Has the Tetra landed on the ground or the Pile of Bricks?

(check-expect (landed? WORLD1) #t)
(check-expect (landed? WORLD4) #f)

(define (landed? w)
  (local [(define W-BRICKS (tetra-bricks (world-tetra w)))]
    (or (on-ground? W-BRICKS)
        (touching? (world-pile w) (shift-bricks  W-BRICKS 'down)))))

;-------------------------------------------------------------------------------------------------

; tetra+pile: World -> World
; Add Tetra to Pile of Bricks

(check-random (tetra+pile WORLD0) (make-world (spawn-tetra (random 7)) EX-3 4))
(check-random (tetra+pile WORLD1) (make-world (spawn-tetra (random 7)) (append EX-2 EX-3) 8))
(check-random (tetra+pile WORLD2) (make-world (spawn-tetra (random 7)) (append EX-1 EX-2 EX-3) 12))
(check-random (tetra+pile (make-world Z-TETRA (append EX-7 EX-5) 8))
              (make-world Z-TETRA (append EX-7 EX-5) 8))

(define (tetra+pile w)
  (if (landed? w) (make-world (spawn-tetra (random 7))
                              (append (tetra-bricks (world-tetra w)) (world-pile w))
                              (+ 4 (world-score w)))
      w))

;-------------------------------------------------------------------------------------------------

; spawn-tetra: Number -> Tetra
; Make a new Tetra over top of the screen given the number

(check-expect (spawn-tetra 3) (make-tetra (make-posn 5 20)
                                          (list (make-brick 4 20 'cyan)  (make-brick 5 20 'cyan)
                                                (make-brick 6 20 'cyan)  (make-brick 4 21 'cyan))))
(check-expect (spawn-tetra 0) (make-tetra (make-posn 4.5 20.5)
                                          (list (make-brick 4 20 'green)  (make-brick 5 20 'green)
                                                (make-brick 4 21 'green)  (make-brick 5 21 'green))))
(check-expect (spawn-tetra 5) (make-tetra (make-posn 5 20)
                                          (list (make-brick 4 21 'pink)  (make-brick 5 21 'pink)
                                                (make-brick 5 20 'pink)  (make-brick 6 20 'pink))))

(define (spawn-tetra n)
  (cond [(= n 0) O]
        [(= n 1) I]
        [(= n 2) L]
        [(= n 3) J]
        [(= n 4) T]
        [(= n 5) Z]
        [(= n 6) S]))

;-------------------------------------------------------------------------------------------------

; count-bricks: Bricks -> Number
; Counts how many Bricks there is in a Bricks (Set of Bricks)

(check-expect (count-bricks '()) 0)
(check-expect (count-bricks EX-6) 4)
(check-expect (count-bricks (append EX-7 EX-1)) 8)

(define (count-bricks b)
  (foldr (lambda (br total) (+ 1 total)) 0 b))

;-------------------------------------------------------------------------------------------------

; keep-list: World -> Bricks
; Keep bricks not in full row

(check-expect (keep-list WORLD1) (list (make-brick 0 0 'purple) (make-brick 1 0 'purple)
                                       (make-brick 2 0 'purple) (make-brick 2 1 'purple)))
(check-expect (keep-list WORLD5) (list (make-brick 4 1 'orange) (make-brick 3 1 'orange)
                                       (make-brick 2 1 'orange) (make-brick 0 1 'cyan)
                                       (make-brick 6 1 'purple) (make-brick 9 1 'purple)))


(define (keep-list w)
  (filter (lambda (b) (not (= (full-row-number w) (brick-y b)))) (world-pile w)))

;-------------------------------------------------------------------------------------------------

; full-row-number: World -> Number
; Find y-coordinate of the full row

(check-expect (full-row-number WORLD5) 0)
(check-expect (full-row-number WORLD6) 1)

(define (full-row-number w)
  (local [(define full-rows (filter (lambda (y) (full-row-at-y? y (world-pile w))) (range 0 20 1)))]
    (cond [(empty? full-rows) -1]
          [else (first full-rows)])))

;-------------------------------------------------------------------------------------------------

; full-row?: World -> Boolean
; is there any full row in the given world

(check-expect (full-row? WORLD5) #t)
(check-expect (full-row? WORLD6) #t)
(check-expect (full-row? WORLD1) #f)

(define (full-row? w)
  (full-row-list-y? (world-pile w)))

;-------------------------------------------------------------------------------------------------

; full-row-list-y?: Bricks -> Boolean
; is there a full row in any y-coordinate?

(check-expect (full-row-list-y? (world-pile WORLD1)) #f)
(check-expect (full-row-list-y? (world-pile WORLD5)) #t)
(check-expect (full-row-list-y? (world-pile WORLD6)) #t)

(define (full-row-list-y? b)
  (foldr (lambda (y bl) (or (full-row-at-y? y b) bl)) #f (range 0 20 1)))

;-------------------------------------------------------------------------------------------------

; full-row-at-y?: Number Bricks -> Boolean
; is there a full row at the given y-coordinate?

(check-expect (full-row-at-y? 0 (world-pile WORLD5)) #t)
(check-expect (full-row-at-y? 1 (world-pile WORLD5)) #f)
(check-expect (full-row-at-y? 2 (world-pile WORLD5)) #f)

(define (full-row-at-y? n b) (= (count-row n b) 10))

;-------------------------------------------------------------------------------------------------

; count-row: Number Bricks -> Number
; Counts how many bricks are in a row
(check-expect (count-row 0 (world-pile WORLD5)) 10)
(check-expect (count-row 10 (world-pile WORLD5)) 0)

(define (count-row n br)
  (foldr (lambda (b total)
           (if (contains-brick-at-y? n b) (+ 1 total) total))
         0
         br))

;-------------------------------------------------------------------------------------------------

; contains-brick-at-y?: Number Brick -> Boolean
; Is there a brick at the given y-coordinates of pt?

(check-expect (contains-brick-at-y? 9 BRICK-1) #t)
(check-expect (contains-brick-at-y? 4 BRICK-1) #f)

(define (contains-brick-at-y? n b)
  (= n (brick-y b)))

;-------------------------------------------------------------------------------------------------

; key-handler: World KE -> World
; Keys: left and right arrows to move, s to rotate cw, a to rotate ccw

(check-expect (key-handler WORLD2 "left")   WORLD2)
(check-expect (key-handler WORLD4 "left")  (make-world (shift-tetra T-TETRA 'left) '() 0))
(check-expect (key-handler WORLD0 "right") (make-world (shift-tetra L-TETRA 'right) '() 0))
(check-expect (key-handler WORLD3 "a")     (make-world (tetra-rotate NEW-TETRA 'ccw)
                                                       (list (make-brick 5 13 'blue)
                                                             (make-brick 5 14 'blue)
                                                             (make-brick 5 15 'blue)
                                                             (make-brick 5 16 'blue))
                                                       4))
(check-expect (key-handler WORLD2 "s")     (make-world (tetra-rotate O-TETRA 'cw)
                                                       (append EX-2 EX-3) 8))
(check-expect (key-handler WORLD1 "f")     WORLD1)

(define (key-handler w ke)
  (cond [(or (string=? "right" ke) (string=? "left" ke))
         (local [(define SHIFT-TETRA (shift-tetra (world-tetra w) (string->symbol ke)))]
           (if (not (or (wall-collide? (tetra-bricks (world-tetra w)) (string->symbol ke))
                        (touching? (tetra-bricks SHIFT-TETRA) (world-pile w))))
               (make-world SHIFT-TETRA (world-pile w) (world-score w))
               w))]
        [(or (string=? "s" ke) (string=? "a" ke))
         (local [; key-con: KeyEvent -> Rot-Dir
                 ; Convert keyevent into rotate direction
                 (define (key-con key) (if (string=? "s" ke) 'cw 'ccw))
                 ; hit-wall?: Tetra Rot-Dir -> Boolean
                 ; Check if the tetra would go out of bound after rotates
                 (define (hit-wall? t rd)
                   (ormap (lambda (b)
                            (or (< (brick-x b) 0) (> (brick-x b) (- BG-WIDTH 1)) (< (brick-y b) 0)))
                          (tetra-bricks (tetra-rotate t rd))))
                 (define ROTATE-TETRA (tetra-rotate (world-tetra w) (key-con ke)))]
           (if (not (or (hit-wall? (world-tetra w) (key-con ke))
                        (touching? (tetra-bricks ROTATE-TETRA) (world-pile w))))
               (make-world ROTATE-TETRA (world-pile w) (world-score w))
               w))]
        [else w]))

;-------------------------------------------------------------------------------------------------

; game-over: World -> Scene
; Display a message and final score

(check-expect (game-over WORLD3)
              (overlay/align "middle" "middle"
                             (text/font "GAME OVER" 30 "light turquoise" "Gill Sans"
                                        'modern 'normal 'bold #f)
                             (place-image/cell
                              (text/font "Score: 4" 20 "purple" #f 'modern 'normal 'bold #f)
                              (- (/ BG-WIDTH 2) 0.5)
                              (- (/ BG-HEIGHT 2) 2)
                              BG)))

(define (game-over w)
  (overlay/align "middle" "middle"
                 (text/font "GAME OVER" 30 "light turquoise" "Gill Sans" 'modern 'normal 'bold #f)
                 (place-image/cell
                  (text/font (string-append "Score: " (number->string (world-score w)))
                             20 "purple" #f 'modern 'normal 'bold #f)
                  (- (/ BG-WIDTH 2) 0.5)
                  (- (/ BG-HEIGHT 2) 2)
                  BG)))

;-------------------------------------------------------------------------------------------------

; new-world: World -> World
; Make a new world with keep-list of bricks, shift on top down

(check-expect (new-world WORLD5) (make-world
                                  (make-tetra (make-posn 5 16)
                                              (list (make-brick 4 16 'cyan) (make-brick 5 16 'cyan)
                                                    (make-brick 6 16 'cyan) (make-brick 4 17 'cyan)))
                                  (list (make-brick 4 0 'orange) (make-brick 3 0 'orange)
                                        (make-brick 2 0 'orange) (make-brick 0 0 'cyan)
                                        (make-brick 6 0 'purple) (make-brick 9 0 'purple))
                                  (world-score WORLD5)))
(check-expect (new-world WORLD7)
              (make-world (make-tetra (make-posn 5 20)
                                      (list (make-brick 4 20 'cyan) (make-brick 5 20 'cyan)
                                            (make-brick 6 20 'cyan) (make-brick 4 21 'cyan)))
                          (list (make-brick 2 3 'cyan) (make-brick 1 3 'cyan) (make-brick 0 3 'cyan)
                                (make-brick 8 3 'green) (make-brick 9 3 'green)
                                (make-brick 6 3 'orange) (make-brick 1 1 'purple)
                                (make-brick 1 2 'purple) (make-brick 2 2 'red)
                                (make-brick 3 2 'red) (make-brick 6 2 'blue) (make-brick 7 2 'blue)
                                (make-brick 8 2 'blue) (make-brick 9 2 'blue) (make-brick 5 0 'orange)
                                (make-brick 6 0 'orange) (make-brick 7 0 'orange)
                                (make-brick 6 1 'orange) (make-brick 2 0 'cyan) (make-brick 3 0 'cyan)
                                (make-brick 4 0 'cyan) (make-brick 2 1 'cyan) (make-brick 8 0 'pink)
                                (make-brick 9 0 'pink) (make-brick 9 1 'pink) (make-brick 1 0 'cyan))
                          56))

(define (new-world w)
  (make-world (world-tetra w)
              (append (shift-bricks
                       (filter (lambda (br) (> (brick-y br) (full-row-number w))) (keep-list w))
                       'down)
                      (filter (lambda (br) (< (brick-y br) (full-row-number w))) (keep-list w)))
              (world-score w)))

;-------------------------------------------------------------------------------------------------

; next-world: World -> World
; Spawns a new Tetra after the current one lands, otherwise shifts it down

(check-random (next-world WORLD2) (make-world (spawn-tetra (random 7)) (append EX-1 EX-2 EX-3) 12))
(check-random (next-world WORLD4)
              (make-world (make-tetra (make-posn 8 0)
                                      (list (make-brick 7 0 'orange) (make-brick 8 0 'orange)
                                            (make-brick 9 0 'orange) (make-brick 8 1 'orange)))
                          '() 0))
(check-random (next-world (make-world Z-TETRA '() 0))
              (make-world (make-tetra (make-posn 2 1)
                                      (list (make-brick 1 2 'pink) (make-brick 2 2 'pink)
                                            (make-brick 3 1 'pink) (make-brick 2 1 'pink))) '() 0))
               
(define (next-world w)
  (cond [(landed? w) (tetra+pile w)]
        [(full-row? w) (new-world w)]
        [else (make-world (shift-tetra (world-tetra w) 'down) (world-pile w) (world-score w))]))

;-------------------------------------------------------------------------------------------------
(big-bang (make-world (spawn-tetra (random 7)) '() 0)
  [on-tick next-world 0.2]
  [to-draw world->scene]
  [stop-when overflow? game-over]
  [on-key key-handler])