type tree =
  | Leaf of int
  | Node of tree*tree
  (*Rajouter Empty comme possible?*)


let empty = Leaf (-1)

let rec egal_tree arb1 arb2 =
  match arb1, arb2 with
  |Leaf a, Leaf b ->  a = b 
  |Node(arb1a,arb1b), Node(arb2a,arb2b) -> (egal_tree arb1a arb2a) && (egal_tree arb1b arb2b)
  |Leaf a, Node _-> false
  |Node _, Leaf b -> false


let is_singleton abr = 
  match abr with
    | Leaf _ -> true
    | _      -> false
let is_empty abr = 
  match abr with
    | Leaf (-1) -> true
    | _ -> false 
let add abr1 abr2 = (*Crée un nouvel arbre avec abr1 Ng et abr2 ND*)
   Node(abr1, abr2)
  
let find_min abr = 
  let minimum a b =
    if a > b then b
    else a
  in
  let rec aux abr min = 
    match abr with
    | Leaf f -> minimum f min  (* Si c'est une feuille, comparer la valeur *)
    | Node (sarbg, sarbd) -> 
        let min_gauche = aux sarbg min in
        let min_droite = aux sarbd min in
        minimum min_gauche min_droite  (* Comparer les résultats des sous-arbres *)
    in
    aux abr 257 (*Les valeurs de l'arbre sont comprises entre 0 et 255*)

let remove_min abr = 
  (*
  let min = find_min abr in
  let rec aux abr min abrcopie b = 
    match abr with
      | Leaf f -> if f = min then b = false
      | Node (sarbg, sarbd) -> 
          if b then begin abrcopie = add sarbg sarbd;
                            aux sarbg min abrcopie b;
                            aux sarbd min abrcopie b end
        else
          match sarbg, sarbd with
            | Leaf f, _ ->  
  in *)
  failwith "todo"
    

let tree_to_list abr =
  let rec aux abr acc =
    match abr with
      | Leaf v -> v :: acc
      | Node (g, d) -> aux g (0 :: (aux d acc))
  in
  aux abr []
  

let list_to_tree lst =
  let rec aux lst =
    match lst with
      | [] -> failwith "Liste vide : impossible de reconstruire l'arbre"
      | 0 :: t -> 
          let gauche, reste1 = aux t in
          let droite, reste2 = aux reste1 in
          (Node (gauche, droite), reste2)
      | v :: t -> (Leaf v, t)
  in
  let arbre, reste = aux lst in
  if reste <> [] then failwith "Liste invalide : trop d'éléments" else arbre
  