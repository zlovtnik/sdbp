trade:([ ]
  time:`timestamp$();
  sym:`symbol$();
  price:`long$();  / price in cents
  size:`long$();
  exchange:`symbol$();
  condition:`symbol$()
)

quote:([ ]
  time:`timestamp$();
  sym:`symbol$();
  bid:`long$();    / bid in cents
  ask:`long$();    / ask in cents
  bsize:`long$();
  asize:`long$();
  exchange:`symbol$()
)