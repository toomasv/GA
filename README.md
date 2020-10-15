# GA
Playing with geometric algebra

To see playground, use `play` after `do %d201.red` (or `do  %d301.red`).
Points are dragable only if declared with `point x y [z]` followed with string (i.e. named points).
E.g. in 2D `p0: point 1 0 "P0"`

## 2D
See examples in the end of `%d201.red`.

## 3D
Some examples in the end of `%d301.red`
Points with their names gathered into a block become rotatable.
E.g.:
```
p1: point -1 0 0 "P1"
p2: point 1 0 0 "P2"
[p1 p2]
...
```
Rotation axis is set by pressing `x`, `y` or `z` key. 
Points are rotated with wheel.
`esc` disables rotation.
