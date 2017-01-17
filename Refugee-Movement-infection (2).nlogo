globals
[
  dead-refugees
  accepted-refugees
  working-variable
  second-variable
  third-variable
  fourth-variable

  %infected
  %immune

  average-time-traveled
  total-time-traveled
]

breed[ countries country ]
breed[ refugees refugee ]
undirected-link-breed [ border-links border-link ]
undirected-link-breed [ water-links water-link ]
undirected-link-breed [ land-links land-link ]

countries-own
[
  capacity
  resource-count
  willing-to-take-refugees
  accepted-refugees-count
  declined-refugees-count
]

refugees-own
[
  home-country
  age
  health
  accepted-country
  declined-countries
  destination
  transportation
  current-location
  stalled

  sick?
  immune?
  sick-count

  time-traveled
]

turtles-own
[
  name
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PROGRAMS STARTTTTTT!!!!!:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-water
  ask patches with [
    (pycor > 260 and pycor < 280 and pxcor < 400) or
    (pycor > 217 and pycor < 220 and pxcor < 70) or
    (pycor > 217 and pxcor > 65 and pxcor < 70) or
    (pycor > 89 and pycor < 110 and pxcor < 200) or
    (pycor > 60 and pycor < 90 and pxcor < 240 and pxcor > 80) or
    (pycor > 150 and pycor < 190 and pxcor > 250 and pxcor < 280)
    ]
  [
    set pcolor 83
  ]
end

to setup-refugees [number]
  set-default-shape refugees "person"
  create-refugees number
  [
    set xcor random-normal 250 3
    set ycor random-normal 50 3

    ;ages are distributed according to syrian refugee data
    ifelse random 100 < 18
    [
      set age random 4
    ]
    [
      ifelse random 82 < 21
      [
        set age 5 + random 6
      ]
      [
        ifelse random 61 < 13
        [
          set age 12 + random 5
        ]
        [
          ifelse random 48 < 45
          [
            set age 18 + random 51
          ]
          [
            set age 60 + random-poisson .5
          ]
        ]
      ]
    ]
    ;set health according to age
    set health abs ( 100 - 2 * ( 30 - age ) )

    ;set color white if healthy red if close to dying
    set color scale-color red health 0 50

    set home-country "Syria"
    set transportation "foot"
    set current-location "Syria"
    set destination "Syria"
    set declined-countries ["Syria"]
    set accepted-country nobody
    set stalled 0

    set sick-count 0
    set immune? false
    get-healthy

    if random 100 < starting-sick
    [
      get-sick
    ]

    set time-traveled 0
  ]
end

to establish-country [x y s n c]
  create-countries 1
  [
    set size s
    set name n
    set xcor x
    set ycor y
    set capacity c
    ifelse c = 0
    [
      set willing-to-take-refugees 0
    ]
    [
      set willing-to-take-refugees 100
    ]
    set accepted-refugees-count 0
    set declined-refugees-count 0
    set label name
    set color 45
  ]
end

to setup-countries-eurocentric
  set-default-shape countries "target"
  establish-country 118.5 222 34 "Germany" (115 * factor)
  establish-country 141 301 41 "Sweden" 69 * factor
  establish-country 177 135 13 "Greece" 35 * factor
  establish-country 75 185 64 "France" 122 * factor
  establish-country 138 190 8 "Austria" 42 * factor
  establish-country 128 158 29 "Italy" 89 * factor
  establish-country 100 302 30 "Norway" 69 * factor
  establish-country 53 234 24 "UK" 91 * factor
  establish-country 115 186 4 "Switzerland" 45 * factor
  establish-country 168 186 9 "Hungary" 30 * factor
  establish-country 194 154 11 "Bulgaria" 25 * factor
  establish-country 84 225 3 "Belgium" 37 * factor
  establish-country 250 115 77 "Turkey" (131 * factor)
  establish-country 173 168 9 "Serbia" 21 * factor
  establish-country 30 145 50 "Spain" 95 * factor

  if china = true
  [
    establish-country 450 146 90 "China" 45 * factor
  ]
  if us = true
  [
    establish-country 400 80 50 "US" 45 * factor
  ]

  establish-country 250 50 20 "Syria" 0
  establish-country 132 40 30 "Libya" 0
  establish-country 30 80 20 "Morocco" 0
end

to toggle-labels
  ask countries
  [
    ifelse label = name
    [
      set label ""
    ]
    [
      ifelse label = accepted-refugees-count
      [
        set label name
      ]
      [
        ifelse label = ""
        [
          set label capacity
        ]
        [
          set label accepted-refugees-count
        ]
      ]
    ]
  ]
end

to setup-routes
  ask countries with [name = "France"][create-border-links-with countries with [name = "Germany" or name = "Belgium" or name = "Switzerland" or name = "Italy"]]
  ask countries with [name = "Turkey"][create-border-links-with countries with [name = "Greece"]]
  ask countries with [name = "Austria"][create-border-links-with countries with [name = "Germany" or name = "Switzerland" or name = "Italy" or name = "Hungary"]]
  ask countries with [name = "Serbia"][create-border-links-with countries with [name = "Hungary" or name = "Bulgaria"]]
  ask countries with [name = "Bulgaria"][create-border-links-with countries with [name = "Greece" or name = "Turkey"]]
  ask countries with [name = "Germany"][create-border-links-with countries with [name = "Belgium"]]
  ask countries with [name = "Norway"][create-border-links-with countries with [name = "Sweden"]]
  ask countries with [name = "Spain"][create-border-links-with countries with [name = "France"]]
  ask countries with [name = "Syria"][create-border-links-with countries with [name = "Turkey"]]
  ask countries with [name = "Switzerland"][create-border-links-with countries with [name = "Germany"]]

  ask countries with [name = "Turkey"][create-water-links-with countries with [name = "Greece"]]
  ask countries with [name = "Libya"][create-water-links-with countries with [name = "Italy"]]
  ask countries with [name = "Morocco"][create-water-links-with countries with [name = "Spain"]]
  ask countries with [name = "UK"][create-water-links-with countries with [name = "France" or name = "Belgium"]]
  ask countries with [name = "Germany"][create-water-links-with countries with [name = "Norway" or name = "Sweden"]]

  ask countries with [name = "Greece"][create-land-links-with countries with [name = "Austria"]]
  ask countries with [name = "Libya"][create-land-links-with countries with [name = "Syria" or name = "Morocco"]]

  if china = true
  [
    ask countries with [name = "China"][create-land-links-with countries with [name = "Syria"]]
  ]
  if us = true
  [
    ask countries with [name = "US"][create-land-links-with countries with [name = "Syria"]]
  ]

  ask water-links
  [
    set color 86
    set thickness 2
  ]
  ask border-links
  [
    set color 67
    set thickness 3
  ]
  ask land-links
  [
    set color brown
    set thickness 2
  ]
end

to max-out-resources
  set norway-resources 1000
  set sweden-resources 1000
  set uk-resources 1000
  set belgium-resources 1000
  set germany-resources 1000
  set france-resources 1000
  set switzerland-resources 1000
  set austria-resources 1000
  set hungary-resources 1000
  set spain-resources 1000
  set italy-resources 1000
  set serbia-resources 1000
  set bulgaria-resources 1000
  set greece-resources 1000
  set turkey-resources 1000
  set china-resources 1000
  set us-resources 1000
end

to update-global-variables
  if count refugees > 0
  [
    set %infected (count refugees with [sick?]) / (count refugees) * 100
    set %immune (count refugees with [immune?]) / (count refugees) * 100
  ]
  if accepted-refugees > 0
  [
    set average-time-traveled total-time-traveled / accepted-refugees
  ]
end

to setup
  clear-all
  set total-refugees 1000
  ask patches
  [
    set pcolor 2
  ]
  setup-water
  setup-countries-eurocentric
  setup-routes

  if realistic
  [
    realistic-circumstances
  ]

  update-global-variables
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SETUP VS GO DIVIDE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to get-sick ;; turtle procedure
  set sick? true
  set immune? false
  set color red
end

to get-healthy ;; turtle procedure
  set sick? false
  set immune? false
  set sick-count 0
  set color green
end

to become-immune ;; turtle procedure
  set sick? false
  set sick-count 0
  set immune? true
  set color gray
end

to check-sick-count
  ask refugees
  [
    if sick?
      [ set sick-count (sick-count + 1) ]
  ]
end

;; If a turtle is sick, it infects other turtles on the same patch.
;; Immune turtles don't get sick.
to infect
  ask refugees with [sick?]
  [
    ask other refugees-here with [ not immune? ]
    [
      if (random-float 100) < infectiousness
      [
        get-sick
      ]
    ]
  ]
end

;; Once the turtle has been sick long enough, it
;; either recovers (and becomes immune) or it dies.
to recover
   ask refugees with [sick?]
   [
     if (random sick-count) > duration * 3 / 4  ;; If the turtle has survived past the virus' duration, then
     [
       ifelse ((random-float 100) < chance-recover)        ;; either recover or die
       [ become-immune ]
       [
         set dead-refugees dead-refugees + 1
         die
       ]
     ]
    ]
end

to-report report-distance [ other-turtle ]
  report sqrt( ( xcor - [xcor] of other-turtle )^ 2 + ( ycor - [ycor] of other-turtle )^ 2 )
end

to move-toward-country [country-name]
  face one-of turtles with [name = country-name]
  ifelse pcolor = green
  [
    forward .705
  ]
  [
    forward 2.25
  ]
end

to choose-new-destination
  ifelse any? [my-border-links] of working-variable
  [
    ifelse any? [my-water-links] of working-variable
    [
      ifelse any? [my-land-links] of working-variable
      [
        ;border, water, and ground exist
        ifelse random (water-preference + border-preference + land-preference) < water-preference
        [
          set working-variable [[name] of one-of water-link-neighbors] of working-variable
          set transportation "boat"
        ]
        [
          ifelse random (border-preference + land-preference) < land-preference
          [
            set working-variable [[name] of one-of land-link-neighbors] of working-variable
            set transportation "foot"
          ]
          [
            set working-variable [[name] of one-of border-link-neighbors] of working-variable
            set transportation "foot"
          ]
        ]
      ]
      [
        ;border and water exist
        ifelse random (water-preference + border-preference) < water-preference
        [
          set working-variable [[name] of one-of water-link-neighbors] of working-variable
          set transportation "boat"
        ]
        [
          set working-variable [[name] of one-of border-link-neighbors] of working-variable
          set transportation "foot"
        ]
      ]
    ]
    [
      ifelse any? [my-land-links] of working-variable
      [
        ;border and ground exist
        ifelse random (border-preference + land-preference) < border-preference
        [
          set working-variable [[name] of one-of border-link-neighbors] of working-variable
          set transportation "foot"
        ]
        [
          set working-variable [[name] of one-of land-link-neighbors] of working-variable
          set transportation "foot"
        ]
      ]
      [
        ;border exists
        set working-variable [[name] of one-of border-link-neighbors] of working-variable
        set transportation "foot"
      ]
    ]
  ]
  [
    ifelse any? [my-water-links] of working-variable
    [
      ifelse any? [my-land-links] of working-variable
      [
        ;water and ground exist
        ifelse random (water-preference + land-preference) < water-preference
        [
          set working-variable [[name] of one-of water-link-neighbors] of working-variable
          set transportation "boat"
        ]
        [
          set working-variable [[name] of one-of land-link-neighbors] of working-variable
          set transportation "foot"
        ]
      ]
      [
        ;water exists
        set working-variable [[name] of one-of water-link-neighbors] of working-variable
        set transportation "boat"
      ]
    ]
    [
      ;ground exists (should never reach here)
      set working-variable [[name] of one-of land-link-neighbors] of working-variable
      set transportation "foot"
    ]
  ]
end

to check-alive
  if random 100 < 3 or sick? = true
  [
    set health health - 1
  ]
  if health <= 0
  [
    set dead-refugees dead-refugees + 1
    die
  ]
  if accepted-country != nobody
  [
    set total-time-traveled total-time-traveled + time-traveled
    die
  ]
end

to realistic-circumstances
  ;set spain and stuff 0
  ask one-of countries with [name = "Hungary"]
  [
    set willing-to-take-refugees 0
  ]
  ask one-of countries with [name = "Greece"]
  [
    set willing-to-take-refugees 0
  ]
end

;drain resources and adjust willingness to take refugees
to-report drain-resources [country-name country-resources divider amount staying]
  ifelse country-resources > 0
  [
    set working-variable health
    set country-resources country-resources - ((100 - amount) / divider) - staying
    if country-resources < 0
    [
      set country-resources 0
    ]
    set health 100
  ]
  [
    ask one-of countries with [name = country-name]
    [
      set willing-to-take-refugees 0
      set working-variable country-name
    ]
    ask refugees with [current-location = working-variable]
    [
      set stalled 0
    ]
  ]
  report country-resources
end

to choose-untraveled-country
  set second-variable 0
  while [member? destination declined-countries = true]
  [
    set working-variable current-location
    set working-variable one-of countries with [ name = working-variable ]
    choose-new-destination
    if member? working-variable declined-countries = false
    [
      set destination working-variable
    ]
    set second-variable second-variable + 1
    if second-variable > 100
    [
      set declined-countries remove working-variable declined-countries
    ]
  ]
end

;what does this do?
;if you are at your destination, change your destination
;change it to somewhere where you have not been declined before
to change-destination [here]
  ;ifelse realistic = false
  ;[
    ;if one of the links is not full, go there

    ifelse count [link-neighbors with [willing-to-take-refugees > 0]] of one-of countries with [name = here] > 0
    [
      ask [one-of link-neighbors with [willing-to-take-refugees > 0]] of one-of countries with [name = here]
      [
        set working-variable name
      ]
      set destination working-variable
    ]
    [
      choose-untraveled-country
    ]
  ;]
  ;[
  ;  ;realistic is true, the turtles just go to a country that hasn't declined them yet
  ;  choose-untraveled-country
  ;]
end

to readjust-willingness-optimal
  ifelse accepted-refugees-count > capacity
  [
    set willing-to-take-refugees 0
    set working-variable name
    ask refugees with [current-location = working-variable]
    [
      set stalled 0
    ]
  ]
  [
    set willing-to-take-refugees 100 - ((accepted-refugees-count / capacity) * (1 - accepted-refugees / total-refugees)) * (100)
  ]
end

to test-acceptance [country-name country-resources]
  ifelse random 100 < [willing-to-take-refugees] of one-of countries with [name = country-name]
  [
    ;accepted
    ask countries with [name = country-name]
    [
      set accepted-refugees-count accepted-refugees-count + 1

      readjust-willingness-optimal
    ]
    set accepted-country country-name
    set accepted-refugees accepted-refugees + 1
  ]
  [
    ;rejected
    ask countries with [name = country-name]
    [
      set declined-refugees-count declined-refugees-count + 1
    ]
    if member? country-name declined-countries = false
    [
      set declined-countries lput country-name declined-countries
    ]

    if [willing-to-take-refugees] of one-of countries with [name = country-name] > 0
    [
      ifelse realistic
      [
        set stalled random stalling
      ]
      [
        set stalled random (stalling / 8)
      ]
    ]

    ;choose a new destination since you were rejected
    change-destination country-name
  ]
end

to-report in-country-check-action [country-name country-resources]
  if report-distance one-of countries with [name = country-name] < .5 * [size] of one-of countries with [name = country-name]
  [
    ;we are in 'country-name', now what do we do?
    ifelse current-location != country-name
    [
      ;we just entered

      ;update your location
      set current-location country-name

      ;see if you're accepted, if not, change your destination
      test-acceptance country-name country-resources

      ;drain resources
      ifelse accepted-country = country-name
      [
        set country-resources drain-resources country-name country-resources 10 health 1
      ]
      [
        set country-resources drain-resources country-name country-resources 100 health 0
      ]
    ]
    [
      ;we've been here a while

      if accepted-country != country-name
      [
        change-destination country-name
      ]

      ;drain resources
      set country-resources drain-resources country-name country-resources 100 health 0
    ]
  ]
  report country-resources
end

to check-location
  set Turkey-Resources in-country-check-action "Turkey" Turkey-Resources
  set Bulgaria-Resources in-country-check-action "Bulgaria" Bulgaria-Resources
  set Greece-Resources in-country-check-action "Greece" Greece-Resources
  set Serbia-Resources in-country-check-action "Serbia" Serbia-Resources
  set Hungary-Resources in-country-check-action "Hungary" Hungary-Resources
  set Italy-Resources in-country-check-action "Italy" Italy-Resources
  set Austria-Resources in-country-check-action "Austria" Austria-Resources
  set Germany-Resources in-country-check-action "Germany" Germany-Resources
  set Switzerland-Resources in-country-check-action "Switzerland" Switzerland-Resources
  set France-Resources in-country-check-action "France" France-Resources
  set UK-Resources in-country-check-action "UK" UK-Resources
  set Norway-Resources in-country-check-action "Norway" Norway-Resources
  set Sweden-Resources in-country-check-action "Sweden" Sweden-Resources
  set Belgium-Resources in-country-check-action "Belgium" Belgium-Resources
  set Spain-Resources in-country-check-action "Spain" Spain-Resources
  if china = true
  [
    set China-Resources in-country-check-action "China" China-Resources
  ]
  if us = true
  [
    set US-Resources in-country-check-action "US" US-Resources
  ]
  set fourth-variable in-country-check-action "Syria" 0
  set fourth-variable in-country-check-action "Morocco" 0
  set fourth-variable in-country-check-action "Libya" 0
end

to sudden-influx
  setup-refugees 100
  set total-refugees total-refugees + 100
end

to go
  ;create stream of refugees
  if ticks mod 8 = 0 and (ticks < (365 * 24) * total-refugees / 1000)
  [
    setup-refugees 1
  ]

  ask refugees
  [
    ;move refugees
    if stalled = 0
    [
      move-toward-country destination
    ]

    ;test if in country, and change attributes accordingly
    check-location

    ;turtles die slowly
    ;turtles are removed if accepted by a country
    check-alive

    if stalled > 0
    [
      set stalled stalled - 1
    ]

    set time-traveled time-traveled + 1
  ]

  ;updates
  ask countries
  [
    set label accepted-refugees-count
    if willing-to-take-refugees = 0
    [
      set color 25
      set shape "x"
    ]
  ]

  check-sick-count
  infect
  recover
  update-global-variables

  ;if 5% refugees left, stop
  if accepted-refugees >= (total-refugees * 19 / 20) or count refugees = 0
  [
    stop
  ]

  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
180
10
1006
580
-1
-1
1.63
1
10
1
1
1
0
0
0
1
0
500
0
330
1
1
1
ticks
30.0

BUTTON
1023
223
1086
256
NIL
setup
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
1093
223
1156
256
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1117
301
1219
334
NIL
toggle-labels
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1118
134
1202
179
NIL
count refugees
17
1
11

PLOT
1010
10
1170
130
Deaths
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot dead-refugees"

MONITOR
1010
133
1060
178
NIL
dead-refugees
17
1
11

SLIDER
4
16
176
49
Norway-Resources
Norway-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
4
51
176
84
Sweden-Resources
Sweden-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
4
86
176
119
UK-Resources
UK-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
5
121
177
154
Belgium-Resources
Belgium-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
6
157
178
190
Germany-Resources
Germany-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
4
228
179
261
Switzerland-Resources
Switzerland-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
6
193
178
226
France-Resources
France-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
7
263
179
296
Austria-Resources
Austria-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
7
299
179
332
Hungary-Resources
Hungary-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
8
334
180
367
Spain-Resources
Spain-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
7
370
179
403
Italy-Resources
Italy-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
8
406
180
439
Serbia-Resources
Serbia-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
6
442
178
475
Bulgaria-Resources
Bulgaria-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
6
477
178
510
Greece-Resources
Greece-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
7
513
179
546
Turkey-Resources
Turkey-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
1018
262
1110
295
Border-Preference
Border-Preference
0
100
85
1
1
NIL
HORIZONTAL

SLIDER
1018
298
1110
331
Land-Preference
Land-Preference
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
1019
334
1111
367
Water-Preference
Water-Preference
0
100
15
1
1
NIL
HORIZONTAL

MONITOR
1062
133
1115
178
NIL
accepted-refugees
17
1
11

PLOT
1173
10
1333
130
Accepted
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot accepted-refugees"

SLIDER
1012
181
1104
214
factor
factor
0
2
1.05
.05
1
NIL
HORIZONTAL

SLIDER
1125
344
1297
377
China-Resources
China-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
1106
181
1223
214
total-refugees
total-refugees
0
1000
1000
1
1
NIL
HORIZONTAL

SWITCH
1234
181
1324
214
China
China
1
1
-1000

SWITCH
1235
217
1325
250
US
US
1
1
-1000

SLIDER
1125
378
1297
411
US-Resources
US-Resources
0
1000
1000
1
1
NIL
HORIZONTAL

SWITCH
1113
261
1216
294
Realistic
Realistic
1
1
-1000

BUTTON
1226
302
1333
335
NIL
Max-out-resources
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
1162
224
1225
257
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1018
376
1110
409
stalling
stalling
0
1000
720
1
1
NIL
HORIZONTAL

BUTTON
1225
260
1331
293
NIL
sudden-influx
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1016
422
1141
455
infectiousness
infectiousness
0
100
86
1
1
%
HORIZONTAL

SLIDER
1016
460
1141
493
chance-recover
chance-recover
0
100
84
1
1
%
HORIZONTAL

SLIDER
1017
498
1143
531
duration
duration
0
100
71
1
1
hours
HORIZONTAL

MONITOR
1156
414
1227
459
NIL
%infected
17
1
11

MONITOR
1231
414
1298
459
NIL
%immune
17
1
11

PLOT
1156
460
1316
580
Populations
hours
people
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"sick" 1.0 0 -2674135 true "" "plot count refugees with [sick?]"
"immune" 1.0 0 -7500403 true "" "plot count refugees with [immune?]"
"healthy" 1.0 0 -13840069 true "" "plot count refugees with [not sick? and not immune?]"
"total" 1.0 0 -13791810 true "" "plot count refugees"

SLIDER
1017
536
1143
569
starting-sick
starting-sick
0
100
10
1
1
%
HORIZONTAL

MONITOR
1204
134
1335
179
NIL
average-time-traveled
17
1
11

@#$#@#$#@
## TODO List

find out best distribution of resources so that all used up
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
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Based Infinite Test" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>accepted-refugees &gt; (19 / 20 * total-refugees) or ticks &gt; 25000</exitCondition>
    <metric>ticks</metric>
    <metric>turkey-resources</metric>
    <metric>italy-resources</metric>
    <metric>hungary-resources</metric>
    <metric>bulgaria-resources</metric>
    <metric>sweden-resources</metric>
    <metric>serbia-resources</metric>
    <metric>france-resources</metric>
    <metric>switzerland-resources</metric>
    <metric>germany-resources</metric>
    <metric>greece-resources</metric>
    <metric>belgium-resources</metric>
    <metric>austria-resources</metric>
    <metric>uk-resources</metric>
    <metric>norway-resources</metric>
    <metric>spain-resources</metric>
    <metric>accepted-refugees</metric>
    <enumeratedValueSet variable="stalling">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Belgium-Resources">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Spain-Resources">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Land-Preference">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Turkey-Resources">
      <value value="420"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Norway-Resources">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Austria-Resources">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Italy-Resources">
      <value value="105"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bulgaria-Resources">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="France-Resources">
      <value value="140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Greece-Resources">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sweden-Resources">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Serbia-Resources">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Water-Preference">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-refugees">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Switzerland-Resources">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Border-Preference">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Realistic">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Germany-Resources">
      <value value="130"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hungary-Resources">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UK-Resources">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="realistic">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Equal Distribution" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>accepted-refugees &gt; (19 / 20 * total-refugees) or ticks &gt; 25000</exitCondition>
    <metric>ticks</metric>
    <metric>turkey-resources</metric>
    <metric>china-resources</metric>
    <metric>italy-resources</metric>
    <metric>hungary-resources</metric>
    <metric>bulgaria-resources</metric>
    <metric>sweden-resources</metric>
    <metric>serbia-resources</metric>
    <metric>france-resources</metric>
    <metric>switzerland-resources</metric>
    <metric>germany-resources</metric>
    <metric>greece-resources</metric>
    <metric>belgium-resources</metric>
    <metric>us-resources</metric>
    <metric>austria-resources</metric>
    <metric>uk-resources</metric>
    <metric>norway-resources</metric>
    <metric>spain-resources</metric>
    <enumeratedValueSet variable="stalling">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Belgium-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Spain-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Land-Preference">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Turkey-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Norway-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Austria-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Italy-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bulgaria-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="France-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Greece-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sweden-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Serbia-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Water-Preference">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-refugees">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Switzerland-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Border-Preference">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Realistic">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Germany-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hungary-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UK-Resources">
      <value value="84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="realistic">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Capacity Distribution" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>accepted-refugees &gt; (19 / 20 * total-refugees) or ticks &gt; 25000</exitCondition>
    <metric>ticks</metric>
    <metric>turkey-resources</metric>
    <metric>italy-resources</metric>
    <metric>hungary-resources</metric>
    <metric>bulgaria-resources</metric>
    <metric>sweden-resources</metric>
    <metric>serbia-resources</metric>
    <metric>france-resources</metric>
    <metric>switzerland-resources</metric>
    <metric>germany-resources</metric>
    <metric>greece-resources</metric>
    <metric>belgium-resources</metric>
    <metric>austria-resources</metric>
    <metric>uk-resources</metric>
    <metric>norway-resources</metric>
    <metric>spain-resources</metric>
    <metric>accepted-refugees</metric>
    <enumeratedValueSet variable="stalling">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Belgium-Resources">
      <value value="47.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Spain-Resources">
      <value value="121.68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Land-Preference">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Turkey-Resources">
      <value value="168.74"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Norway-Resources">
      <value value="88.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Austria-Resources">
      <value value="53.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Italy-Resources">
      <value value="114.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bulgaria-Resources">
      <value value="31.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="France-Resources">
      <value value="157.56"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Greece-Resources">
      <value value="44.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sweden-Resources">
      <value value="88.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Serbia-Resources">
      <value value="25.87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Water-Preference">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-refugees">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Switzerland-Resources">
      <value value="57.07"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Border-Preference">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Realistic">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Germany-Resources">
      <value value="147.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hungary-Resources">
      <value value="38.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UK-Resources">
      <value value="116.48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="realistic">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Low Mod Infinite Test" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>accepted-refugees &gt; (19 / 20 * total-refugees) or ticks &gt; 25000</exitCondition>
    <metric>ticks</metric>
    <metric>turkey-resources</metric>
    <metric>italy-resources</metric>
    <metric>hungary-resources</metric>
    <metric>bulgaria-resources</metric>
    <metric>sweden-resources</metric>
    <metric>serbia-resources</metric>
    <metric>france-resources</metric>
    <metric>switzerland-resources</metric>
    <metric>germany-resources</metric>
    <metric>greece-resources</metric>
    <metric>belgium-resources</metric>
    <metric>austria-resources</metric>
    <metric>uk-resources</metric>
    <metric>norway-resources</metric>
    <metric>spain-resources</metric>
    <metric>accepted-refugees</metric>
    <enumeratedValueSet variable="stalling">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Belgium-Resources">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Spain-Resources">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Land-Preference">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Turkey-Resources">
      <value value="420"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Norway-Resources">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Austria-Resources">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Italy-Resources">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bulgaria-Resources">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="France-Resources">
      <value value="140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Greece-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sweden-Resources">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Serbia-Resources">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Water-Preference">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="China-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-refugees">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Switzerland-Resources">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Border-Preference">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Realistic">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="factor">
      <value value="1.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Germany-Resources">
      <value value="130"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="US">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hungary-Resources">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UK-Resources">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="realistic">
      <value value="true"/>
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
