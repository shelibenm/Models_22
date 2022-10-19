breed [naives naive ]
breed [skeptics skeptic]
breed [umbrellas umbrella]
globals [num  sites gardens]
turtles-own [hesitation body_size satisfection fear dry-here]
umbrellas-own [safe-zone skept-value entropy my-garden]
patches-own [dryness]

to setup
  clear-all

  set sites (list)
  set gardens (list)
  create-naives 6 [set hesitation 0 set body_size random 4 set shape "person" set color 88 ]
  create-skeptics 6 [set hesitation 1 set body_size precision 2 random-float 1 set shape "person" set color red ]
  create-umbrellas 7 [set shape "umb" set size random 20 setxy random-xcor random-ycor]
  ask turtles[set fear random 5]
  ask patches[ ifelse rain-shape = "scaterd" [set pcolor random-float rain-power + 2][set pcolor random-normal (rain-power + 2) 0.5] set dryness precision pcolor 3 ] ; dry / wet area
  ;if Safe-Sites = true [safe-site ]
  safe-site ; kindergarden, tree or stationary shelter
  ask umbrellas[ ifelse empty? sites [safe-site]
               [let center item 0 one-of sites set my-garden patch (item 0 center)(item 1 center) ]]

  reset-ticks
  ;tick
end
;use this for stationary safe-site like a kindergarden, tree or "Migunit"
to safe-site
  repeat 4[
    let site []
  let center (list random-xcor random-ycor)
    ask patch item 0 center item 1 center [set pcolor green ask neighbors [set pcolor green] let thisgarden patch-set [neighbors] of self
      set gardens lput thisgarden gardens ]
  set site  lput center site
  set sites lput site sites]
  ;foreach (list gardens) [ x -> show [who] of item 0 x]
end
;Enter one of umbrellas
to Get-Umbrella
  let my-site 0
  ask turtle 1[
   ( foreach (list turtle-set naives)(list turtle-set skeptics) ( list turtle-set umbrellas)
      [[x z y] ->
        ;insert here some condition naives goes faster fear - word * factor while skepticks takes time: fear - word*factor +  7*time [ticks / nearest round value *10]
        ask x [let brave-n fear - words * word-power  repeat  brave-n [rt 20 ] move-to one-of y set my-site [who] of y ]
        ask z [let brave-s fear - words * word-power + (7 * 1 /  ticks ) repeat brave-s [rt 20 fd body_size count-10] ; create delay
               move-to one-of y set my-site [who] of y ]])
  ] ; we use one of the turtles as a reporter
  ;ask turtle 2 [foreach (list turtle-set naives)[x -> ask x[fd 1]]]

end
;Entropy in this model represent contemporeray state and rational value for controling fear and make dicision
to site-entropy
  ;let skept-value []
  ask umbrellas [set safe-zone [size] of self / 2]
  ask umbrellas [if any? naives in-radius safe-zone or any? skeptics in-radius safe-zone
    [let n-value  [hesitation] of naives in-radius safe-zone
     let s-value  [hesitation] of skeptics in-radius safe-zone
      let n-p length n-value  ;show (word  "" (n-p) "--" "naives in " [who] of self)
      let s-p length s-value  ;show (word  "" (s-p) "--" "skeptics in" [who] of self)
      let kids n-p + s-p
       ;tested!
      let ent entropy-here n-p s-p kids show (word ent "----" "entropy of - "  [who] of self)
      set entropy ent
      set dry-here mean (list patch-here dryness patch-here neighbors dryness)
                 ]]
end


  to-report entropy-here [n s k]
  let empty (list)
  let ent map [x -> x / k ](list n s)
  ask turtle 1
  [ (foreach (ent) [[i ] -> ifelse i = 0 [set empty  lput i empty  ]
    [set empty lput (-1 * i *(log i 2))  empty ]]) ];;entropy fixed
  report  precision  reduce + empty 4 end

  to fear-from-other
  let kids (turtle-set skeptics naives)
  ask kids [site-entropy ask umbrellas-here
           [if [entropy] of self > entropy_threshold
           [ask myself [back size / 2 * friction-power rt 10 ] back 1 rt 10]]] ;
            ;makes the kids moves backword  due to friction factor [global] and size [local-personal] the umbrella's are the "braves"
            ;so the are the list influanced

  ;tick
  ; add entropy > fear -move to nearest umbrella
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to rain-info
  let kids (turtle-set skeptics naives)
  ask kids [ifelse any? umbrellas-here
    [let ume one-of umbrellas-here set dry-here [dry-here] of ume set satisfection 1 - ([entropy] of ume / dry-here)] ;;;an-other option dry-here / ([entropy] of ume + 0.1 ) ] ;
   ;; the dryness define satisfection- if entropy is high and dryness is high the gain from the situation decrease and vice versa 0.5 / 6  1.5 /3
    [set dry-here [dryness] of  patch-here set satisfection  satisfection - (fear / dry-here )]
     ] ; process dry

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;naives are more "word" influanced than skeptics so fear decrease accordingly
 ;also we apply some positive feedback for being in control for skeptics
to control-fear
  ifelse fear-desolver = "time-perception"[ask skeptics [set fear  fear - 0.01 set satisfection satisfection + 0.01]]
  [ask naives [set fear fear - 0.01]]

end

to count-10
  let c  0
  while [c < stimuli-sensitivity][set c c + 1] ; short count less sensitivty to exposer- impact only the skeptics
  output-print c end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report mean-st report mean [satisfection]of (turtle-set skeptics naives) end
to-report mean-fr report mean [fear]of (turtle-set skeptics naives) end
to-report mean-frs report mean [fear]of ( skeptics) end
to-report mean-frn report mean [fear]of ( naives) end
to-report mean-dry report mean [dry-here] of ( turtles) end
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to rich-garden[x ]
  ask x [if patch-here = my-garden [stop]] end

to go
  tick
  ask umbrellas [rich-garden self face my-garden fd 1 ask other turtles-here [face [my-garden] of myself fd 1]]
  ask (turtle-set naives skeptics)[
    Get-Umbrella if fear-control [control-fear] ]
  fear-from-other
  rain-info
  ;if fear-control [control-fear]
  ;control-fear
  ;tick
end

to find end
@#$#@#$#@
GRAPHICS-WINDOW
309
27
684
403
-1
-1
11.121212121212123
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
233
216
296
249
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
133
373
230
406
To-Umbrella
Get-Umbrella
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
162
112
302
145
rain-power
rain-power
2
10
6.0
1
1
NIL
HORIZONTAL

BUTTON
234
254
297
287
go
clear-all-plots\nrepeat num-run [go]
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

TEXTBOX
1095
118
1245
146
there is an umbrella inside or under umbrella
11
0.0
1

BUTTON
8
336
126
369
NIL
site-entropy
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
374
128
407
NIL
fear-from-other
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
10
108
145
153
fear-desolver
fear-desolver
"time-perception" "word and communication"
1

TEXTBOX
13
198
163
216
word control fear and feelings
11
0.0
1

SLIDER
10
220
182
253
entropy_threshold
entropy_threshold
0
3
0.6
0.2
1
NIL
HORIZONTAL

SLIDER
8
157
152
190
words
words
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
161
157
306
190
word-power
word-power
0
1
0.31
0.01
1
NIL
HORIZONTAL

BUTTON
133
337
231
370
NIL
rain-info
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
695
32
1037
297
Kids-satisfection
satisfection
NIL
-10.0
10.0
-10.0
10.0
true
true
"" ""
PENS
"Naives" 1.0 0 -16777216 true "" "plot sum [satisfection] of naives "
"Skeptics" 1.0 0 -7500403 true "" "plot sum [satisfection] of skeptics"
"all-kids" 1.0 0 -7858858 true "" "plot mean [satisfection] of (turtle-set skeptics naives)"

TEXTBOX
1092
32
1288
128
time-perception has impact mostly on skepticks\nwhile word i.e self reassurance and communication has more impact on naives
11
0.0
1

PLOT
824
472
1024
622
dryness of umbrellas
local dryness
NIL
0.0
10.0
0.0
10.0
false
true
"\nset-histogram-num-bars 6" ""
PENS
"umbrellas" 1.0 1 -13345367 true "set-histogram-num-bars count umbrellas" "if any? umbrellas [histogram [dry-here] of umbrellas]"

TEXTBOX
1099
168
1249
196
this is a potential bug but also an unexpected state- :)
11
0.0
1

PLOT
0
411
251
580
Fear-in-Population
NIL
NIL
0.0
12.0
0.0
1.0
true
true
"clear-plot\nset-histogram-num-bars 12\n" ""
PENS
"naives" 1.0 1 -14439633 true " clear-plot\n set-plot-x-range 0 6" "\nhistogram  [fear] of naives\n\n"
"skeptics" 1.0 1 -2674135 true "clear-plot\n\nset-plot-x-range 6 12" "histogram  [fear] of skeptics"

PLOT
697
308
897
458
fear-of-naives
NIL
NIL
0.0
6.0
0.0
2.0
true
true
"clear-plot\nset-histogram-num-bars 6" ""
PENS
"naives" 1.0 1 -14439633 true "" "histogram [fear] of naives"

PLOT
905
309
1105
459
fear-of-skeptics
NIL
NIL
0.0
6.0
-2.0
4.0
true
true
"clear-plot\nset-histogram-num-bars 6" ""
PENS
"skeptics" 1.0 1 -2674135 true "set-histogram-num-bars 6" "histogram [fear] of skeptics"

SLIDER
9
297
181
330
stimuli-sensitivity
stimuli-sensitivity
0
10
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
1098
206
1248
262
kids satisfection is the sum of all because the number of kids dosent matter-we didnt use mean or averge-
11
0.0
1

MONITOR
485
415
595
460
mean satisfection
mean-st
4
1
11

MONITOR
485
464
555
509
mean fear
mean-fr
4
1
11

PLOT
257
412
471
579
satisfection  fear correlation
satisfection
fear
0.0
2.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy mean-st mean-fr"

SWITCH
13
66
128
99
fear-control
fear-control
0
1
-1000

SLIDER
9
258
181
291
friction-power
friction-power
0
1
0.25
0.01
1
NIL
HORIZONTAL

MONITOR
564
463
630
508
NIL
mean-dry
3
1
11

TEXTBOX
486
518
815
588
the local dryness is random value in the range 2- rain power + 2 so it is the measure also sometimes there is two umbrellas so the dryness is bigger\nalso dryness value is the pcolor of patch-here this is fraction-round it?
11
0.0
1

CHOOSER
163
63
301
108
rain-shape
rain-shape
"scaterd" "normal"
0

SLIDER
208
295
300
328
num-run
num-run
0
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
this is a model based on hebrew children book calld "Dads Big Umbrella" Written by Levin Kipnis

Tal, whose name is Taltal, got up in the morning and wanted to go to the gardener.
But it was cloudy outside and rain was knocking on the window pane:
Tip-tip-tip! Tip-tap-tap! bag-bag-bag! Knock-knock-knock!
Tal's mother said: "Today you will not go to the garden, the rain is beating on the window pane!"
"The rain is knocking - let it knock! I'll take dad's big umbrella."
From the dew, he drank, he ate, he wore, he wore. He took the big umbrella - and left.
He went out into the street -
And here is Ilana, who loves bananas, peeking at him from the window.
He called to her: "Don't look at the window, come with me to the garden!"
Ilana came out and went under the umbrella.
The rain is dripping, the rain is pouring, under the umbrella who will get wet?
They go -
And here is Bethia standing in the stairwell.
"Batya, Batya, are you afraid of a bath? Come with us to garden!"
She hurried home and also went under the umbrella.
And the rain pours, the rain drips, under the umbrella no one will get wet!
They go -
And here is Joseph standing under a canopy. They called her: "Joseph, Yoseph, are you barefoot?
Leave the awning and come with us to the garden!" Yosef also entered under the umbrella.
The rain is falling, the wind is whistling, and Tali is chatting, and Ilana is shouting, Betya is laughing and even Yosef is not silent.
The four of them went together. And here is Dror [ sparrow], chirping like a bird, standing outside and shivering with cold.
They called him: "Don't perk up a donkey's ears! Come with us to the garden"
A sparrow quickly went under the umbrella too.
The flash of lightning, the thunder of thunder
The five of you went together! And here is Ephraim red-cheeked, wearing boots-jumping in the puddle of water.
They called him: "Hey Lord, come to Gannon [KinderGarden]!" He also went under the umbrella.
They went, six of them, together. And here opposite a puppy and a kitten howling by the fence,
Running around looking for a place to hide. Sparrow and Ephraim jumped and took them on their hands. and carried them under the umbrella -
Cheers to all her friends! In the meantime - the sky started to clear,
And the children - a song in their mouths and light in their eyes! And so singing a long [Bashir] and joy [Ron] they came to the garden.
All the children were happy and made a big circle - the puppy and the kitten also participated in the dance

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS
each kid assignd a type of personalty- naive and skeptic they enter an umbrella depending on thier hasitation and how
they "read" the situation if the umbrella is too crowded or the level of friction is high its influace thier satisfection

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT
setup the model by licking the setup button- this will set the kids and umbrellas
and then start the model by clicking the go button
(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE
look at the satisfection fear graph and follow the distribution of navies vs skeptics at the beginging and the end of simulation
(suggested things for the user to notice while running the model)

## THINGS TO TRY
1. change the word-time perception option
2. change the value of word power this will be of segnificance only if you choos the word option
3. 

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

umb
true
0
Polygon -1184463 false false 135 75 180 75 210 105 210 150 180 180 135 180 105 150 105 105 135 75 135 75
Polygon -1184463 true false 135 75 150 90 120 120 105 105 135 75
Polygon -1184463 true false 180 180 165 165 195 135 210 150 180 180
Polygon -1184463 true false 150 165 135 180 105 150 120 135 150 165
Polygon -1184463 true false 210 105 195 120 165 90 180 75 210 105
Polygon -1184463 true false 135 75 150 90 165 90 180 75 135 75
Polygon -1184463 true false 180 180 165 165 150 165 135 180 180 180
Polygon -1184463 true false 210 105 195 120 195 135 210 150 210 105
Polygon -1184463 true false 105 150 120 135 120 120 105 105 105 150

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>[satisfection] of turtles</metric>
    <enumeratedValueSet variable="fear-desolver">
      <value value="&quot;word and communication&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="word-power">
      <value value="0.73"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rain-power">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stimuli-sensitivity">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="words">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entropy_threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
