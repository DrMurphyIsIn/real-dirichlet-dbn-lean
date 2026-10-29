import Lean
open Lean
-- bb: does Expr BEq (used by Comparator's derived ConstantInfo BEq) ignore binder names / binder info?
#eval (Expr.forallE `a (.const ``Nat []) (.bvar 0) .default) == (Expr.forallE `b (.const ``Nat []) (.bvar 0) .default)
#eval (Expr.forallE `a (.const ``Nat []) (.bvar 0) .default) == (Expr.forallE `a (.const ``Nat []) (.bvar 0) .instImplicit)
#eval (Expr.forallE `a (.const ``Nat []) (.bvar 0) .default) == (Expr.forallE `a (.const ``Int []) (.bvar 0) .default)
