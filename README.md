# FC<sup>2</sup> ~ FCSquare ~ Fuzzy Calculus Core 

Software package for fuzzy relational calculus tasks with applications.

This package is created with the highly appreciated theoretical help and under the supervision of Prof. DSc. Ketty Peeva.

## Theoretical results and methods can be found in:

1. B. De Baets, Analytical solution methods for fuzzy relational equations, in the series: Fundamentals of Fuzzy Sets, The Handbooks of Fuzzy Sets Series, D. Dubois and H. Prade (eds.), Vol. 1, Kluwer Academic Publishers, pp. 291-340 (2000).
2. Di Nola, A., Lettieri, A.: Relation Equations in Residuated Lattices. Rendiconti del Circolo Matematico di Palermo, s. II, XXXVIII, pp.246-256 (1989).
3. A. Di Nola, S. Sessa, W. Pedrycz, E. Sanchez, Fuzzy Relation Equations and Their Applications to Knowledge Engineering, Kluwer Academic Press, Boston, 1989.
4. G. Klir, B. Yuan, Fuzzy Sets and Fuzzy Logic: Theory and Applications, Prentice Hall PTR, NJ, 1995.
5. G. Klir, U. H. St. Clair, B. Yuan, Fuzzy Set Theory Foundations and Applications, Prentice Hall PRT, 1997.
6. K. Peeva, Finite L-Fuzzy Machines, Fuzzy Sets and Systems, Vol 141, No 3, 2004, pp. 415-437. 
7. K. Peeva, Universal algorithm for solving fuzzy relational equations, Italian Journal of Pure and Applied Mathematics 19, 2006, pp. 9-20.
8. K. Peeva, Y. Kyosev, Fuzzy Relational Calculus-Theory, Applications and Software (with CD-ROM), In the series Advances in Fuzzy Systems - Applications and Theory, Vol. 22, World Scientific Publishing Company, 2004.
9. K. Peeva, Y. Kyosev, Algorithm for Solving Max-product Fuzzy Relational Equations, Soft Computing 11(7), 2007, pp. 593-605.
10. K. Peeva, Zl. Zahariev, Software for Testing Linear Dependence in Fuzzy Algebra, Second International Scientific Conference Computer Science, Chalkidiki, 30 Sept -2 Oct 2005, ISBN 954 438 526 6, part I, pp 294-299, 2005.
11. K. Peeva, Zl. Zahariev, Linear dependence in fuzzy algebra, Proceedings of 31th International Conference AMЕE, Sozopol June 2005 Softrade, Sofia 2006, ISBN 10: 954-334-032-3, pp. 71-83.
12. K. Peeva, Zl, Zahariev, Iv. Atanasov, Optimization of Linear Objective Function Under Max-product Fuzzy Relational Constraint, Proceedings of the 9th WSEAS International Conference on FUZZY SYSTEMS (FS’08) – Advanced Topics on Fuzzy Systems, Book Series: Artificial Intelligence Series- WSEAS, Sofia, Bulgaria, May 2-4, 2008, ISBN: 978-960-6766-56-5, ISSN: 1790-5109, 132-137.
13. K. Peeva, Zl. Zahariev, Computing behavior of finite fuzzy machines – Algorithm and its application to reduction and minimization, Information Sciences, Vol. 178 (2008) issue 21, 4152-4165.
14. K. Peeva, D. Petrov, Optimization of linear objective function under fuzzy equation constraint in BL-algebras – theory, algorithm and software, Springer Series "Studies in Computational Intelligence" V. Sgurev, M. Hadjiski. (eds),  A post conference IEEE IS'08 volume in SCI-Springer Verlag. Topic: Intelligent Systems - from Theory to Practice, Scope: Advanced Intelligent Systems ISSN: 1860-949X, http://www.springer.com/series/7092 (in press).
15. K. Peeva, Zl. Zahariev, I. Atanasov, Software for optimization of linear objective function with fuzzy relational constraint, Fourth International IEEE Conference on Intelligent Systems, Sept. 2008, Varna, Vol. 3 (2008), pp. 18-14–18-19, ISBN 978-I-4244-1739.
16. I. Perfilieva, L. Noskova, System of fuzzy relation equations with inf-? composition: complete sets of solutions, Fuzzy Sets and Systems 150, 17, 2256-2271.
17. E. Sanchez, Resolution of composite fuzzy relation equations, Information and Control, 30 (1976) 38-48.
18. Z. Zahariev, Software Packages to Deal with Fuzzy Systems, in Proceedings of 33rd International Conference Application of Mathematics in Engineering and Economics’33, M. Todorov (ed.) American Institute of Physics, 978-0-7354-0460, 2007, 217-278.
19. Z. Zahariev, Solving Max-min Relational Equations. Software and Applications, in International conference on Applications of Mathematics in Engineering and Economics, June 2008, Sozopol, Bulgaria, December 2008, pp 516-523.
20. Z. Zahariev, Software package and API in MATLAB for working with fuzzy algebras, In International Conference "Applications of Mathematics in Engineering and Economics (AMEE'09)", AIP Conference Proceedings, vol. 1184, G. Venkov, R. Kovatcheva, V. Pasheva (eds.) American Institute of Physics, ISBN 978-0-7354-0750-9, 2009, 434-350.

## Supported operations:

I. Fuzzy matrices compositions:   

* Max-Min
* Min-Max
* Max-Product
* Max-Epsilon
* Min-Godel
* Min-Goguen
* Min-Lukasiewicz

II. Linear combinations, checking linear independence.

III. Direct and inverse problems resolution for fuzzy linear systems of equations and inequalities with the following compositions:

* Max-Min
* Min-Max
* Max-Product
* Min-Godel
* Min-Goguen
* Min-Lukasiewicz

IV. Solving fuzzy optimization problems.

V. Fuzzy machines - find, minimize and reduce behavior and full behavior matrices.

# Appendix Examples (Markdown)

## Examples for the `fuzzyMatrix` module

This section provides usage examples for the `fuzzyMatrix` module, including initialization, basic operations, and several types of fuzzy matrix composition.

### Max-min composition of two fuzzy matrices

```matlab
% Create new random fuzzy matrix.
>> A = fuzzyMatrix(rand(3))
A =
  3×3 fuzzyMatrix:
  double data:
    0.9649    0.9572    0.1419
    0.1576    0.4854    0.4218
    0.9706    0.8003    0.9157

>> B = fuzzyMatrix(rand(3))
B =
  3×3 fuzzyMatrix:
  double data:
    0.7922    0.0357    0.6787
    0.9595    0.8491    0.7577
    0.6557    0.9340    0.7431

% Compose two matrices with max-min composition
>> C = maxmin(A,B)
C =
  3×3 fuzzyMatrix:
  double data:
    0.9572    0.8491    0.7577
    0.4854    0.4854    0.4854
    0.8003    0.9157    0.7577
```

### Max-$\varepsilon$ composition of two fuzzy matrices

```matlab
% Compose two matrices with max-epsilon composition
>> C = maxepsilon(A,B)
C =
  3×3 fuzzyMatrix:
  double data:
    0.9595    0.9340    0.7431
    0.9595    0.9340    0.7577
    0.9595    0.9340         0
```

### Test for fuzzy linear combination with min-max composition

```matlab
>> coeffs = fuzzyMatrix(rand(3,1))
coeffs =
  3×1 fuzzyMatrix:
  double data:
    0.0344
    0.4387
    0.3816

% Create a linear combination for testing purposes
>> X = minmax(A, coeffs)
X =
  3×1 fuzzyMatrix:
  double data:
    0.3816
    0.1576
    0.8003

% Validate that X is a linear combination of A
>> is_lincomb('minmax', A, X)
ans =
  3×1 fuzzyMatrix:
  double data:
         0
         0
    0.3816
```

### Test for fuzzy linear dependence with min-max composition

```matlab

% Add the linear combination to the initial matrix A
>> A_extended = fuzzyMatrix([double(A) double(X)])
A_extended =
  3×4 fuzzyMatrix:
  double data:
    0.9649    0.9572    0.1419    0.3816
    0.1576    0.4854    0.4218    0.1576
    0.9706    0.8003    0.9157    0.8003

% Validate that the new matrix A is now linear dependant
% Column 4 is a linear combination of the other columns
>> is_linindep(A_extended, 'minmax', true)
ans =
     4
```

---

## Examples for the `fuzzySystem` module

This section provides example uses of the `fuzzySystem` class, illustrating how to construct and solve fuzzy relational systems under various compositions and inequality types.

### Solving A  X = B using $\odot$ composition

```matlab
>> A = fuzzyMatrix([0.00, 0.20, 0.05, 0.00, 0.40, 0.00;
                    0.10, 0.60, 0.30, 0.00, 0.20, 0.20;
                    0.80, 0.48, 0.24, 0.48, 0.00, 0.00;
                    0.30, 0.00, 0.00, 0.40, 0.80, 0.15;
                    0.00, 0.00, 0.12, 0.20, 0.48, 0.10;
                    0.50, 0.30, 0.00, 0.10, 0.60, 0.00]);

>> B = fuzzyMatrix([0.10; 0.30; 0.24; 0.20; 0.12; 0.15]);

% Create a new fuzzy system form A and B with max-product composition
>> S = fuzzySystem('maxprod', A, B, [], true)
S =
  fuzzySystem with properties:
    composition: 'maxprod'
              a: [6×6 fuzzyMatrix]
              b: [6×1 fuzzyMatrix]
              x: [0×0 fuzzyMatrix]
           full: 1
   inequalities: 0

>> S.solve_inverse();

% Inspect the system solution
>> S.x
ans =
  struct with fields:
      rows: 6
      cols: 6
      help: [4×6 fuzzyMatrix]
        gr: [6×1 fuzzyMatrix]
       ind: [6×1 double]
     exist: 1
 dominated: [6 3]
 help_rows: 4
       low: [6×3 fuzzyMatrix]

% The system is compatible
>> S.x.exist
ans =
  logical
    1

% The greatest solution
>> S.x.gr
ans =
  6×1 fuzzyMatrix:
  double data:
    0.3000
    0.5000
    1.0000
    0.5000
    0.2500
    1.0000

% All lower solutions
>> S.x.low
ans =
  6×3 fuzzyMatrix:
  double data:
         0         0         0
    0.5000    0.5000         0
    1.0000         0    1.0000
    0.5000         0         0
         0    0.2500    0.2500
         0         0         0
```

### Fast compatability check for the same system

```matlab
% Set the system to solve only for the greatest soltution
>> S.full = false;

>> S.solve_inverse();

% Greates solution exists, so the system is compatible
>> S.x
ans =
  6×1 fuzzyMatrix:
  double data:
    0.3000
    0.5000
    1.0000
    0.5000
    0.2500
    1.0000
```

### Solving A \* X $\leq$ B using $\odot$ composition and the same A and B

```matlab
% Set the system as a A*X <= X inequalities system
>> S.inequalities = -1;

>> S.solve_inverse();

>> S.x
ans =
  struct with fields:
    rows: 6
    cols: 6
    help: [6×6 fuzzyMatrix]
      gr: [6×1 fuzzyMatrix]
     ind: [6×1 double]
   exist: 1
     low: [6×1 fuzzyMatrix]

>> S.x.exist
ans =
  logical
    1

>> S.x.gr
ans =
  6×1 fuzzyMatrix:
  double data:
    0.3000
    0.5000
    1.0000
    0.5000
    0.2500
    1.0000

>> S.x.low
ans =
  6×1 fuzzyMatrix:
  double data:
     0
     0
     0
     0
     0
     0
```

### Solving A \* X $\geq$ B using $\odot$ composition and the same A and B

```matlab
% Set the system as a A*X >= X inequalities system
>> S.inequalities = 1;

>> S.solve_inverse();

>> S.x
ans =
  struct with fields:
    rows: 6
    cols: 6
    help: [4×6 fuzzyMatrix]
      gr: [6×1 fuzzyMatrix]
     ind: [6×1 double]
   exist: 1
 dominated: [6 3]
 help_rows: 4
     low: [6×3 fuzzyMatrix]

>> S.x.exist
ans =
  logical
    1

>> S.x.gr
ans =
  6×1 fuzzyMatrix:
  double data:
    1
    1
    1
    1
    1
    1

> S.x.low
ans =
  6×3 fuzzyMatrix:
  double data:
         0         0         0
    0.5000    0.5000         0
    1.0000         0    1.0000
    0.5000         0         0
         0    0.2500    0.2500
         0         0         0
```

### Solving A \* X = B using Łukasiewicz composition

```matlab
% Similar example with max-lukasiewicz composition
>> A = fuzzyMatrix([0.8, 0.1, 0.7, 0.9;
                    0.9, 0.7, 0.2, 0.8;
                    0.2, 0.8, 0.9, 0.7;
                    0.3, 0.1, 0.0, 0.9]);

>> B = fuzzyMatrix([0.5; 0.6; 0.7; 0.0]);

>> S = fuzzySystem('maxlukasiewicz', A, B, [], true)
S =
  fuzzySystem with properties:
    composition: 'maxlukasiewicz'
              a: [4×4 fuzzyMatrix]
              b: [4×1 fuzzyMatrix]
              x: [0×0 fuzzyMatrix]
           full: 1
   inequalities: 0

>> S.solve_inverse();

>> S.x
ans =
  struct with fields:
      rows: 4
      cols: 4
      help: [3×4 fuzzyMatrix]
        gr: [4×1 fuzzyMatrix]
       ind: [4×1 double]
     exist: 1
 dominated: 4
 help_rows: 3
       low: [4×3 fuzzyMatrix]

>> S.x.exist
ans =
  logical
    1

>> S.x.gr
ans =
  4×1 fuzzyMatrix:
  double data:
    0.7000
    0.9000
    0.8000
    0.1000

>> S.x.low
ans =
  4×3 fuzzyMatrix:
    double data:
      0.7000    0.7000         0
      0.9000         0    0.9000
      0         0.8000    0.8000
      0         0         0
```

---

## Examples for the `fuzzyMachine` module

### Initialize a fuzzy finite machine using $\odot$ composition

```matlab
>> m1=fuzzyMatrix([0 0.6 0.5; 0.6 0.1 0.5; 0.2 0.1 0.2]);
>> m2=fuzzyMatrix([0 0 0; 0 0 0; 0.2 0.1 0.1])    
>> m3=fuzzyMatrix([0.4 0.2 0.1; 0.3 0.4 0.1; 0 0 0])
>> m4=fuzzyMatrix([0 0.3 0.2; 0.3 0.1 0.2; 0.1 0 0.1])

% Create new fuzzy machine with initial state m1, ..., m4
>> m = fuzzyMachine({m1,m2,m3,m4}, 'maxmin', 'none', 2, true)
m =
  fuzzyMachine with properties:
        initial_set: {
          [3×3 fuzzyMatrix]  [3×3 fuzzyMatrix]
          [3×3 fuzzyMatrix]  [3×3 fuzzyMatrix]
        }
        composition: 'maxmin'
               norm: 'max'
             conorm: 'min'
        postprocess: 'none'
        word_length: 2
               full: 1
    behavior_matrix: []
            letters: 3    
```

### Find full behavior for letters with length 2

```matlab
% Set the machine to find full behavior for words length = 2
>> m.word_length = 2; m.full = true; m.postprocess = 'none';

>> m.find_behavior

>> m.behavior_matrix
ans =
  3×21 fuzzyMatrix:
  double data:
  Columns 1 through 6
    1.0000    0.6000         0    0.4000    0.3000    0.6000
    1.0000    0.6000         0    0.4000    0.3000    0.6000
    1.0000    0.2000    0.2000         0    0.1000    0.2000

  Columns 7 through 12    
    0.2000    0.4000    0.3000         0         0         0
    0.2000    0.4000    0.3000         0         0         0
    0.2000    0.2000    0.2000    0.2000    0.1000    0.2000

  Columns 13 through 18
         0    0.4000    0.1000    0.4000    0.3000    0.3000
         0    0.4000    0.1000    0.4000    0.3000    0.3000
    0.2000         0         0         0         0    0.1000

  Columns 19 through 21
    0.2000    0.3000    0.3000
    0.2000    0.3000    0.3000
    0.1000    0.1000    0.1000
```

### Find minimized behavior for letters with arbitrary length

```matlab
% Set the machine to find minimized behavior with no word length limitations
>> m.word_length = -1; m.full = false; m.postprocess = 'minimize';

>> m.find_behavior

>> m.behavior_matrix
ans =
  2×4 fuzzyMatrix:
  double data:
    1.0000    0.6000         0    0.4000
    1.0000    0.6000         0    0.4000
    1.0000    0.2000    0.2000         0
```

### Find reduced behavior for letters with arbitrary length

```matlab
% Set the machine to find reduced behavior with no word length limitations
>> m.word_length = -1; m.full = false; m.postprocess = 'reduce';

>> m.find_behavior

>> m.behavior_matrix
ans =
  2×4 fuzzyMatrix:
  double data:
    1.0000    0.6000         0    0.4000
    1.0000    0.2000    0.2000         0
```

---

## Examples for the `fuzzyOptimizationProblem` module

This section provides examples demonstrating the use of the `fuzzyOptimizationProblem` class to define, minimize and maximize fuzzy optimization problems.

### Define a fuzzy optimization problem with $\odot$ composition constraints

```matlab
>> A = fuzzyMatrix([0.00, 0.20, 0.05, 0.00, 0.40, 0.00;
                    0.10, 0.60, 0.30, 0.00, 0.20, 0.20;
                    0.80, 0.48, 0.24, 0.48, 0.00, 0.00;
                    0.30, 0.00, 0.00, 0.40, 0.80, 0.15;
                    0.00, 0.00, 0.12, 0.20, 0.48, 0.10;
                    0.50, 0.30, 0.00, 0.10, 0.60, 0.00]);

>> B = fuzzyMatrix([0.10; 0.30; 0.24; 0.20; 0.12; 0.15]);

>> S = fuzzySystem('maxprod', A, B, [], true);

% Create new optimization task with parameters and fuzzy system S as constraints
>> O = fuzzyOptimizationProblem([5, -4, 8, 2, -3, 7], S)
O =
  fuzzyOptimizationProblem with properties:
             object: [5 -4 8 2 -3 7]
        constraints: [1×1 fuzzySystem]
    object_solution: []
       object_value: []
```

### Minimization

```matlab
>> O.minimize()
ans =
  fuzzyOptimizationProblem with properties:
             object: [5 -4 8 2 -3 7]
        constraints: [1×1 fuzzySystem]
    object_solution: [6×1 double]
       object_value: -2.7500

>> O.object_solution
ans =
         0
    0.5000
         0
         0
    0.2500
         0

>> O.object_value
ans =
   -2.7500
```

### Maximization

```matlab
>> O.maximize()
ans =
  fuzzyOptimizationProblem with properties:
             object: [5 -4 8 2 -3 7]
        constraints: [1×1 fuzzySystem]
    object_solution: [6×1 double]
       object_value: 16.7500

>> O.object_solution
ans =
    0.3000
         0
    1.0000
    0.5000
    0.2500
    1.0000

>> O.object_value
ans =
   16.7500
```

---

## Examples for access control and login anomaly

This example demonstrates access control or login anomaly detection applications.

For access control - four users are characterized by three policy attributes (e.g. KYC level, user role, and access context).

Matrix $A$ represents at what level each user satisfies these polices. Vector $X$ represents how important those policies are. Vector $B$ represents the level of access for each user. Direct problem resolution represents at what degree the users can access the resources. Inverse problem resolution identifies all the possible policy combinations able to access the resources at some observed level.

The same principle can by applied towards a login anomaly example. Here, four login attempts are evaluated against three indicators (e.g. time of login, location, and device type). Matrix $A$ gives the degree of normality of each attempt. Vector $X$ contains tolerance thresholds. Vector $B$ is the acceptability of each login. Direct problem resolution provides information about how normal a login is. Inverse problem resolution gives information about the desired acceptability levels.

### Enter the policy values

```matlab
>> A = fuzzyMatrix([0.90, 0.60, 0.20;
                   0.70, 0.80, 0.40;
                   0.40, 0.50, 0.90;
                   0.30, 0.70, 0.60]);
>> X = fuzzyMatrix([0.80; 0.60; 0.70]);
>> B = fuzzyMatrix([0.80; 0.70; 0.70; 0.60]);
>> S = fuzzySystem('maxmin', A, [], X);
```

### Check access

```matlab
>> S.solve_direct
ans =
  fuzzySystem with properties:
    composition: 'maxmin'
              a: [4×3 fuzzyMatrix]
              b: [4×1 fuzzyMatrix]
              x: [3×1 fuzzyMatrix]
           full: 0
   inequalities: 0

>> S.b
ans =
  4×1 fuzzyMatrix:
  double data:
    0.8000
    0.7000
    0.7000
    0.6000
```

### Access diagnostic

```matlab
>> S.full = true;
>> S.solve_inverse
ans =
  fuzzySystem with properties:
    composition: 'maxmin'
              a: [4×3 fuzzyMatrix]
              b: [4×1 fuzzyMatrix]
              x: [1×1 struct]
           full: 1
   inequalities: 0

>> S.x
ans =
  struct with fields:
    rows: 4
    cols: 3
    help: [2×3 fuzzyMatrix]
      gr: [3×1 fuzzyMatrix]
     ind: [4×1 double]
   exist: 1
 dominated: [4 2]
 help_rows: 2
     low: [3×1 fuzzyMatrix]

>> S.x.gr
ans =
  3×1 fuzzyMatrix:
  double data:
    0.8000
    0.6000
    0.7000

>> S.x.low
ans =
  3×1 fuzzyMatrix:
  double data:
    0.8000
         0
    0.7000
```

