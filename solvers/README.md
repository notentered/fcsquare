# Inverse solver contract

The eight inverse solvers remain separate, but they implement one common
algorithmic shape.  This is the extraction boundary for a future universal,
table-driven solver: its control flow should come from the four stages below;
only the operation row in the table should vary.

## Common four-stage algorithm

1. **Build the monotone boundary.**  Intersect every row constraint to obtain
   either the greatest vector satisfying `A o X <= B` (max compositions) or
   the least vector satisfying `A o X >= B` (min compositions).
2. **Verify the requested relation.**  Select the boundary for `<=`, `=`, or
   `>=` and evaluate the real direct composition.  A solver never infers
   consistency merely from a non-empty help matrix.
3. **Enumerate opposite extremals.**  Cover one unmet row at a time with an
   attainable operation-specific level.  Process target levels monotonically
   so one selected coordinate can cover compatible rows as well.
4. **Absorb dominated candidates.**  Retain only minimal lower boxes or maximal
   upper boxes, including endpoint openness when the operation is discontinuous.

The public full result has the same structural fields for every operation:
`low`, `gr`, `help`, `contribution`, `exist`, and the logical masks
`low_inclusive`, `gr_inclusive`, and `help_inclusive`.  A boundary value belongs
to its solution box exactly when the corresponding mask entry is true.

## Operation table

In the formulas below, `a = A(i,j)` and `b = B(i)`.  "Attains b" is the
operation-specific predicate/level used to cover an unmet row.

| Solver | Composition term | Monotone row restriction | Level that attains `b` |
| --- | --- | --- | --- |
| `smaxmin` | `min(a,x)` under `max` | `x <= b` when `a > b` | `x = b` when `a >= b` |
| `sminmax` | `max(a,x)` under `min` | `x >= b` when `a < b` | `x = b` when `a <= b` |
| `smaxprod` | `a*x` under `max` | `x <= min(1,b/a)` for `a > 0` | `x = b/a` when `a > 0` and `b/a <= 1` |
| `sgodel` | `a ->G x` under `min` | `x >= min(a,b)` | `x = b` when `a > b`; for `<=`, also the open endpoint `x < a` when `0 < a <= b < 1` |
| `sgoguen` | `a ->P x` under `min` | `x >= a*b` | `x = a*b` when `a > 0` and `b < 1` |
| `slukasiewicz` | `a ->L x` under `min` | `x >= max(0,a-(1-b))` | `x = max(0,a-(1-b))` when `a-(1-b) >= 0` and `b < 1` |
| `smaxepsilon` | `epsilon(a,x)` under `max` | `x <= max(a,b)` | `x = b` when `a < b`; for `>=`, the open endpoint `x > a` when `b <= a < 1` |
| `smaxlukasiewicz` | `max(0,a+x-1)` under `max` | `x <= min(1,1-(a-b))` | `x = min(1,1-(a-b))` when `a >= b` and `b > 0` |

The Gödel `<=` and max-epsilon `>=` rows are intentionally represented as
unions of boxes with inclusion masks.  Replacing their strict boundaries by
closed numeric endpoints changes the solution set and is not a permissible
floating-point approximation.

## Extension rule

When adding another operation, first define its direct scalar term, monotone
row restriction, attainable cover level, and endpoint inclusion rule.  Reuse
the four stages and the full-result contract above.  Add a literature fixture,
an independent finite-domain oracle for all three relations, and the shared
random contract before the operation is considered supported.
