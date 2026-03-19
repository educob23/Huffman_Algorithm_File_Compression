
type tree =
  | Leaf of int
  | Node of tree*tree
(** The type of heaps. Elements are ordered using generic comparison.
*)

val empty : tree
(** [empty] is the empty heap. *)

val egal_tree : tree -> tree -> bool 
(** [egal_tree arb1 arb2] retourne la valeur d'égalité entre ces deux arbres*)

val add : tree -> tree -> tree
(** [add e h] add element [e] to [h]. *)

val find_min : tree -> int
(** [find_min h] returns the smallest elements of [h] w.r.t to 
    the generic comparison [<] *)

val remove_min : tree -> 'a * tree
(** [remove_min h] returns the pair of the smallest elements of [h] w.r.t to 
    the generic comparison [<] and [h] where that element has been removed. *)

val is_singleton : tree -> bool
(** [is_singleton h] returns [true] if [h] contains one element *)

val is_empty : tree -> bool
(** [is_empty h] returns [true] if [h] contains zero element *)

val tree_to_list : tree -> int list
(** [tree_to_list abr] retourne le parcours préfixe de l'arbre*)

val list_to_tree : int list -> tree
(** [list_to_tree lst] retourne l'arbre correspondant à la liste lst en préfixe*)