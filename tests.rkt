#lang play

(require "main.rkt")
;; Test sub-module.
;; See http://blog.racket-lang.org/2012/06/submodules.html

;this tests should never fail; these are tests for MiniScheme+ 
(module+ test
  (test (run '{+ 1 1}) 2)
  
  (test (run '{{fun {x y z} {+ x y z}} 1 2 3}) 6)  
  
  (test (run '{< 1 2}) #t)
  
  (test (run '{local {{define x 1}}
                x}) 1)
  
  (test (run '{local {{define x 2}
                      {define y {local {{define x 1}} x}}}
                {+ x x}}) 4)
  
  ;; datatypes  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {List? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {List? {Cons 1 2}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Cons? {Cons 1 2}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Cons 1 2}}})
        #f)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Cons? {Empty}}})
        #f)      
  
  ;; match
  (test (run '{match 1 {case 1 => 2}}) 2)
  
  (test (run '{match 2
                {case 1 => 2}
                {case 2 => 3}})             
        3)
  
  (test (run '{match #t {case #t => 2}}) 2)
  
  (test (run '{match #f
                {case #t => 2}
                {case #f => 3}})             
        3)

  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define pred {fun {n} 
                                        {match n
                                          {case {Zero} => {Zero}}
                                          {case {Succ m} => m}}}}}
                {Succ? {pred {Succ {Succ {Zero}}}}}})
        #t)
  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define pred {fun {n} 
                                        {match n
                                          {case {Zero} => {Zero}}
                                          {case {Succ m} => m}}}}}
                {Succ? {pred {Succ {Succ {Zero}}}}}}) #t))

;tests for extended MiniScheme+ 
#;(module+ sanity-tests
    (test (run '{local {{datatype Nat 
                  {Zero} 
                  {Succ n}}
                {define pred {fun {n} 
                               {match n
                                 {case {Zero} => {Zero}}
                                 {case {Succ m} => m}}}}}
          {pred {Succ {Succ {Zero}}}}}) "{Succ {Zero}}")
  
(test (run
 `{local ,stream-lib
          {local {,ones ,stream-take}
            {stream-take 11 ones}}}) "{list 1 1 1 1 1 1 1 1 1 1 1}")

(test (run `{local ,stream-lib
          {local {,stream-zipWith ,fibs}
            {stream-take 10 fibs}}}) "{list 1 1 2 3 5 8 13 21 34 55}")

(test (run `{local ,stream-lib
          {local {,ones ,stream-zipWith}
            {stream-take 10
                         {stream-zipWith
                          {fun {n m}
                               {+ n m}}
                          ones
                          ones}}}})  "{list 2 2 2 2 2 2 2 2 2 2}")
(test 
(run `{local ,stream-lib
               {local {,stream-take ,merge-sort ,fibs ,stream-zipWith}
                 {stream-take 10 {merge-sort fibs fibs}}}})   "{list 1 1 1 1 2 2 3 3 5 5}"))

; more tests
(module+ test
  ; pretty-printing
  (test (pretty-printing
         (structV 'Nat 'Succ (list (structV 'Nat 'Succ (list (structV 'Nat 'Zero empty))))))
        "{Succ {Succ {Zero}}}")
  
  ; run con pretty-printing
  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define pred {fun {n}
                                        {match n
                                          {case {Zero} => {Zero}}
                                          {case {Succ m} => m}}}}}
                {pred {Succ {Succ {Succ {Zero}}}}}}) "{Succ {Succ {Zero}}}")
  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define next {fun {n}
                                        {Succ n}}}}
                {next {Succ {Succ {Zero}}}}}) "{Succ {Succ {Succ {Zero}}}}")
  (test (run '{local {{datatype List {Empty} {Cons a b}}
                      {define rest {fun {n}
                                         {match n
                                           {case {Cons a b} => b}}}}}
                      {rest {Cons 1 {Cons 2 {Empty}}}}}) "{list 2}")
  (test (run '{local {{datatype List {Empty} {Cons a b}}
                      {define rest {fun {n}
                                         {match n
                                           {case {Cons a b} => b}}}}}
                      {rest {Cons #t {Cons #f {Empty}}}}}) "{list #f}")
  
  ; tests List
  (test (run '{List? {Empty}}) #t)
  (test (run '{List? {Cons 1 2}}) #t)
  (test (run '{Cons? {Cons 1 2}}) #t)
  (test (run '{Cons? {Cons 1 2}}) #t)
  (test (run '{Empty? {Empty}}) #t)
  (test (run '{Empty? {Cons 1 2}}) #f)
  
  ; tests length
  (test (run '{length {Cons 1 {Empty}}}) 1)
  (test (run '{length {Cons 1 {Cons 2 {Cons 3 {Empty}}}}}) 3)
  (test (run '{length {Empty}}) 0)
  
  ; tests sintactic sugar list
  (test (run '{match {list {+ 1 1} 4 6}
                {case {Cons h r} => h}
                {case _ => 0}})
        2)
  (test (run '{match {list {+ 1 1} {list 4 6} 7}
                {case {Cons h r} => r}
                {case _ => 0}})
        "{list {list 4 6} 7}")
  (test (run '{List? {list  1 2 3}}) #t)
  (test (run '{length {list 1 2 3 4 5 6}}) 6)
  (test (run '{Empty? {list}}) #t)
  (test (run '{List? {list 1 {list 2 3} 4}}) #t)
  (test (run '{List? {list {list 1 2} {list 3 4}}}) #t)

  ; tests pattern matching con list
  (test (run '{match {list 2 {list 4 5} 6}
                {case {list a {list b c} d} => c}}) 5)
  (test (run '{match {list}
                {case {list 1 2 3} => #t}
                {case {list} => #f}}) #f)
  (test (run '{match {Cons 1 {Cons 2 {Empty}}}
                {case {list a b} => b}}) 2)

  ; pretty-printing para listas
  (test (run '{list 1 4 6}) "{list 1 4 6}")
  (test (run '{list}) "{list}")
  (test (run '{list 1 {list 2 3} 4}) "{list 1 {list 2 3} 4}")
  (test (run '{list {list 1 2} 3 4}) "{list {list 1 2} 3 4}")

  ; lazy
  (test (run '{{fun {x {lazy y}} x} 1 {/ 1 0}}) 1)
  (test (run '{with {{f {fun {x {lazy y}} x}}} {f 1 {/ 1 0}}}) 1)
  (test/exn (run '{{fun {x y} x} 1 {/ 1 z}}) "env-lookup: no binding for identifier:")
  (test (run '{local {{datatype T
                                {C {lazy a}}}
                      {define x {C {/ 1 0}}}}
                {T? x}}) #t)
  (test/exn (run '{local {{datatype T
                                    {C {lazy a}}}
                          {define x {C {/ 1 z}}}}
                    {match x
                      {case {C a} => a}}}) "env-lookup: no binding for identifier:"))


