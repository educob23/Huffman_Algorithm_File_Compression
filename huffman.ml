open Heap
open Bs
open Unix

(*************************************************************************************************
**************************************************************************************************
***********************fonctions de création et de gestion des arbres*****************************
**************************************************************************************************
**************************************************************************************************)

let input_code cin = 
  (*une fonction auxiliaire qui gère directement l’ exception*) 
  try 
    input_byte cin
  with End_of_file -> -1


(**[statistiques file] rend la file de priorité du fichier file ie un array contennant le nombre d'occurences de chaque octet.
  Chaque case i contient le nombre d’occurrences de l’octet i dans le fichier
  @param file le fichier à traiter
  @return le tableau de statistiques ie la file de priorité
*)
let rec statistiques file = 
  let tab = Array.make 256 0 in
  let cin = open_in file in
  let rec loop () = 
    let b = input_code cin in
    if b < 0 then 
      (*fin du fichier, renvoyer le résultat final*)
      ()
    else
      begin
      tab.(b) <- tab.(b) + 1;
      loop ();
      end
  in 
  loop ();
  close_in cin;
  tab


(**[file_priorite file] convertit la grande liste de 256 en une liste ne contennant que les éléments présents
  @param file le fichier à traiter
  @return une liste de paires (ocu, car)
*)
let file_priorite file = 
  let tab = statistiques file in (*convertit fichier dans le tab 256*)
  let rec aux cpt =
    if cpt >= Array.length tab then
      [] (* On a parcouru tout le tableau *)
    else if tab.(cpt) <> 0 then
      (tab.(cpt),cpt) :: (aux (cpt + 1)) (* Ajouter les éléments non nuls *)
    else
      aux (cpt + 1) (* Ignorer les éléments nuls *)
    in
  aux 0 


(** [min_tab tab] trouve l'élément qui a le moins d'ocurrences dans une liste d'ocu et abr
    @param tab le tableau de paires (nombre d'ocurrence, feuille du caractère)
    @return le couple (min, elt) où min est le nombre d'ocurrence le plus petit et elt la feuille associée
*)
let min_tab tab =
  let rec aux tab min elt =
    match tab with 
      | [] -> (min, elt)
      | (ocu, abr)::t -> if ocu < min then aux t ocu abr
                        else aux t min elt
    in
  aux tab 43504354 (Leaf(-1))(*Arbre Vide*)
  

(**[elimine_min tab] elimine l'élément du tableau avec le moins d'ocurrences
  @param tab le tableau de paires (nombre d'ocurrence, feuille du caractère)
  @return le tableau sans l'élément avec le moins d'ocurrences
*)
let elimine_min tab = 
  let elt_min = min_tab tab in
  let rec aux t =
    match t with
      | [] -> []
      | (ocu, car)::tt -> if ocu = fst(elt_min) && (egal_tree car (snd(elt_min))) then tt
                          else (ocu, car)::(aux tt)
    in
  aux tab
    

(**[list_int_to_list_tree lst] convertit une liste de paires (ocu, car) en une liste de paires (ocu, Leaf(car))
  @param lst la liste de paires (ocu, car)
  @return la liste de paires (ocu, Leaf(car)
*)
let rec list_int_to_list_tree lst = 
  match lst with
    | [] -> failwith "Tableau vide"
    | [(ocu, car)] -> [ocu, (Leaf car)]
    | (ocu, car)::t -> (ocu, (Leaf car))::(list_int_to_list_tree t)

  
(**[creation_arbre tab] crée l'arbre cherché en prennant en argument le tab réduit
  @param le tableau de paires (nombre d'ocurrence, feuille du caractère)
  @return l'arbre de Huffman associé au texte*)
let rec creation_arbre tab = 
  match tab with (*Le plus petit va toujours vers la gauche*)
    | [] -> Leaf (-1)(*Arbre vide*)
    | [(ocu, abr)] -> abr (*retourne l'arbre cherché*)
    | (ocu, abr1)::(ocu2, abr2)::t -> let min1 = min_tab tab in
                                        let tt = elimine_min (tab) in
                                        let min2 = min_tab tt in
                                        creation_arbre((fst(min1)+fst(min2), (add (snd min1) (snd min2)))::(elimine_min tt))


(**[abr_to_list abr] rend une liste de paires (car:car_compresse) on évite ainsi de devoir parcourir à chaque fois l'arbre pour comprimer un caractère
  @param abr l'arbre de Huffman
  @return une liste de paires (car:car_compresse)
*)
let rec abr_to_list abr=
  let rec aux abr chemin acc=
    match abr with
      |Leaf v ->(v, chemin) :: acc
      |Node (sabrg, sabrd) -> let acc_gauche = aux sabrg (chemin ^ "0") acc in
                              aux sabrd (chemin ^ "1") acc_gauche
    in
  aux abr "" []


(*************************************************************************************************
**************************************************************************************************
***********************fonctions de gestion de la ligne de commande*******************************
**************************************************************************************************
**************************************************************************************************)

(**[get_extension fichier] récupère l'extension du fichier pour la décompression, ie le texte compris entre le dernier '_' et un '.'
   @param fichier le nom du fichier
   @return l'extension du fichier
   @raise Not_found si on a pas trouvé d'extension
*)
let get_extension fichier =
  try
    let underscore_index = String.rindex fichier '_' in
    let dot_index = String.rindex fichier '.' in
    if underscore_index < dot_index then
      String.sub fichier (underscore_index + 1) (dot_index - underscore_index - 1)
    else
      "" (* Aucun `.` après le dernier `_` *)
  with Not_found -> "" (* Pas de `_` ou pas de `.` *)
   
  
(**[elimine_extesion_compression filename] élimine l'extension du fichier pour la décompression, ie le texte après le dernier '_'
   @param filename le nom du fichier
   @return le nom du fichier sans l'extension
   @raise Not_found si on a pas trouvé pas d'extension
*)
let elimine_extesion_compression filename =
  try
    let underscore_index = String.rindex filename '_' in
    let dot_index = String.rindex filename '.' in
    if underscore_index < dot_index then
      (* Concatène la partie avant l'underscore et après le point *)
      String.sub filename 0 underscore_index ^ String.sub filename dot_index (String.length filename - dot_index)
    else
      filename (* Aucun `.` après `_`, retourne la chaîne telle quelle *)
  with Not_found ->
    filename (* Pas de `_` ou pas de `.` : retourne la chaîne telle quelle *)


(**[extension_sans_point fichier] convertit l'extension du fichier .extension en extension (sans le '.)
   @param fichier le nom du fichier
   @return l'extension du fichier sans le point
*)
let extension_sans_point fichier =
  let ext = Filename.extension fichier in
    if ext = "" then "" (* Pas d'extension *)
    else String.sub ext 1 (String.length ext - 1)


(*************************************************************************************************
**************************************************************************************************
***************************fonctions de compression des fichiers**********************************
**************************************************************************************************
**************************************************************************************************)

(**[serialise_abr abr ostream] fonction qui sérialise l'arbre de Huffman dans le fichier compressé
  @param abr l'arbre de Huffman déjà calculé
  @param ostream le flux de sortie
  @return l'écriture de l'arbre dans le fichier compressé
*)
let serialise_abr abr ostream = 
  let rec structure_abr abr ostream = 
    (*fonction qui écrit la structure de l'arbre dans le fichier*)
    match abr with
      | Leaf v -> write_bit ostream 0;
      | Node(sabrg, sabrd) -> write_bit ostream 1;
                            structure_abr sabrg ostream;
                            structure_abr sabrd ostream
    in

  let rec serialise_feuilles abr ostream= 
    (*fonction qui écrit le code original des feuilles de l'arbre dans le fichier*)
    match abr with
      | Leaf v -> write_byte ostream v
      | Node(sabrg, sabrd) -> serialise_feuilles sabrg ostream;
                            serialise_feuilles sabrd ostream
    in
  structure_abr abr ostream;
  serialise_feuilles abr ostream


let compresse fichier = 
  let rec compresse_caracteres istream ostream os abr_lst= (*boucle jusqu'à ce qu'on arrive à la fin, i.e on finit de lire tous els caractères*)
    let byte = input_code istream in (* Lit un caractère*)
    if byte == -1 then begin (* Fin du fichier *)
        finalize os;
        close_out ostream;
        close_in istream
    end
    else
      begin
        let car = List.assoc byte abr_lst in (*trouve le code compressé de byte sans devoir parcourir l'arbre*)
        String.iter (fun bit -> if bit = '0' then write_bit os 0 else write_bit os 1) car;
        compresse_caracteres istream ostream os abr_lst
      end
  in

  let abr = creation_arbre (list_int_to_list_tree (file_priorite fichier)) in (*création de l'arbre à partir du texte*)
  let ostream = open_out ((Filename.remove_extension fichier)^"_"^extension_sans_point fichier^".hf") in (*création du fichier compressé*)
  let os = of_out_channel ostream in
  let is = open_in fichier in
  
  serialise_abr abr os;
  let abr_lst= abr_to_list abr in

  compresse_caracteres is ostream os abr_lst


(************************************************************************************************
*************************************************************************************************
***************************fonctions de décompression des fichiers*******************************
*************************************************************************************************
*************************************************************************************************)

(**[deserealise_abr fichier istream] fonction qui rend l'arbre à partir du fichier compressé
  @param istream le flux d'entrée
  @return la désérialisation de l'arbre de Huffman associé au texte compressé
  @raise Invalid_stream si le flux n'est pas valide
*)
let deserialise_abr istream =
  (*fonction qui rend l'arbre à partir du fichier compressé*)
  let rec struct_abr istream =
    (*fonction qui rend la structure de l'arbre avec des Leaf(-1) aux feuilles*)
    let bit = read_bit istream in
    match bit with
      | 0 -> Leaf(-1)
      | 1 -> let sabrg = struct_abr istream in
              let sabrd = struct_abr istream in
              Node(sabrg, sabrd)
      | _ -> raise Invalid_stream
    in

  let rec lire_feuilles abr istream =
    (*fonction qui rend un nouvel arbre avec les valeurs des caractères comprimés*)
    match abr with
      | Leaf _ ->let feuille = read_byte istream in
                    Leaf(feuille)
      | Node(sabrg, sabrd) -> let gauche = lire_feuilles sabrg istream in
                              let droite = lire_feuilles sabrd istream in
                              Node(gauche, droite)
  in

  let res = struct_abr istream in 
  let abr = lire_feuilles res istream in
  abr


(**[decompresse_car abr istream] fonction qui rend le caractère décompressé, 
pour cela on lit bit par bit le flux jusau'à arriver à une feuille qui est donc 
le caractère décompressé par l'algorithme de Huffman
  @param abr l'arbre de Huffman
  @param istream le flux d'entrée
  @return le caractère décompressé
  @raise Invalid_stream si le flux n'est pas valide
*)
let rec decompresse_car abr istream =
  let read_bit_aux bit = 
    (*fonction gérant les exeptions de la fin du fichier*)
    try 
      read_bit bit 
    with 
      |Invalid_stream
      |End_of_stream -> -1 in
    
  match abr with
    | Leaf v -> v
    | Node(sabrg, sabrd) -> let bit = read_bit_aux istream in
                            match bit with
                              | 0 -> decompresse_car sabrg istream
                              | 1 -> decompresse_car sabrd istream
                              | _ -> -1


(**[decompresse fichier] fonction qui décompresse le fichier compressé
  @param fichier le fichier à décompresser
  @return le fichier décompressé qui se crée en parallèle
*)                              
let decompresse fichier =
  let rec ecrit_fichier abr istream ostream =
    (*fonction qui écrit le fichier décompressé en itérant la fonction decompresse_car jusqu'à arriver à la fin du fichier*)
    let car = decompresse_car abr istream in
    if car = -1 then ()
    else
      begin
      output_byte ostream car; (*on n'utilise pas la bibliothèque Bs pour écrire le fichier décomprimé*)
      ecrit_fichier abr istream ostream;
      end
    in
  
  let is = open_in fichier in
  let istream = of_in_channel is in
  let fichier_decoupe = elimine_extesion_compression fichier in
  
  let ostream = open_out ((Filename.remove_extension fichier_decoupe)^"_decompresse"^"."^get_extension fichier) in   
    
  let abr = deserialise_abr istream in

  ecrit_fichier abr istream ostream; 
  close_out ostream;
  close_in is;
  ()


(************************************************************************************************
*************************************************************************************************
***************************fonction de statistiques des fichiers*********************************
*************************************************************************************************
*************************************************************************************************)

(** [stats fichier] affiche les statistiques de compression d'un fichier 
    @param fichier le fichier à compresser
    @return les statistiques de compression
*)
let stats fichier = 
  let taille_originale = (Unix.stat fichier).st_size in
  
  let debut = Unix.gettimeofday () in
  compresse fichier;
  let fin = Unix.gettimeofday () in
  let temps_compression = fin -. debut in
  
  let taille_finale = (Unix.stat ((Filename.remove_extension fichier)^"_"^extension_sans_point fichier^".hf")).st_size in
  
  Printf.printf "Taille du fichier non compressé : %d octets \n" taille_originale;
  Printf.printf "Taille du fichier compressé : %d octets \n" taille_finale;
  Printf.printf "Taux de compression : %f%% \n" (100.0 *. (float_of_int taille_finale/. float_of_int taille_originale));
  Printf.printf "Temps de compression : %f secondes\n" temps_compression


(************************************************************************************************
*************************************************************************************************
***************************************fonctions de tests****************************************
*************************************************************************************************
*************************************************************************************************)

(**[egalite_entre_fichiers fichier1 fichier2] fonction qui compare deux fichiers pour voir s'ils sont égaux
  @param fichier1 le premier fichier
  @param fichier2 le deuxième fichier
  @return true si les fichiers sont égaux, false sinon
*)
let egalite_entre_fichiers fichier1 fichier2 =
  let is1 = open_in fichier1 in
  let is2 = open_in fichier2 in
  let b =
    try
      let rec aux () =
        let bit1 = input_byte is1 in
        let bit2 = input_byte is2 in
        if bit1 <> bit2 then false else aux ()
      in
      aux ()
    with
    | End_of_file ->
        (* Vérifie si les fichiers ont la même longueur *)
        (try ignore (input_byte is1); false
         with End_of_file ->
           try ignore (input_byte is2); false
           with End_of_file -> true)
  in
  close_in is1;
  close_in is2;
  b


(**[tests] vérifie si plusieurs fichiers de test sont égaux en comprimant puis décomprimant certains ficheirs*)
let tests ()= 
  compresse "./fichiers_tests/gros_texte.txt";
  decompresse "./fichiers_tests/gros_texte_txt.hf";
  let test1 = egalite_entre_fichiers "./fichiers_tests/gros_texte.txt" "./fichiers_tests/gros_texte_decompresse.txt" in
  if test1 then () else failwith "Test 1 failed";

  compresse "./fichiers_tests/text.txt";
  decompresse "./fichiers_tests/text_txt.hf";
  let test2 = egalite_entre_fichiers "./fichiers_tests/text.txt" "./fichiers_tests/text_decompresse.txt" in
  if test2 then () else failwith "Test 2 failed";

  compresse "./fichiers_tests/gros_texte_word.doc";
  decompresse "./fichiers_tests/gros_texte_word_doc.hf";
  let test3 = egalite_entre_fichiers "./fichiers_tests/gros_texte_word.doc" "./fichiers_tests/gros_texte_word_decompresse.doc" in 
  if test3 then () else failwith "Test 3 failed";

  compresse "./fichiers_tests/caractères_unicode.pdf";
  decompresse "./fichiers_tests/caractères_unicode_pdf.hf";
  let test4 = egalite_entre_fichiers "./fichiers_tests/caractères_unicode.pdf" "./fichiers_tests/caractères_unicode_decompresse.pdf" in
  if test4 then () else failwith "Test 4 failed";

  compresse "./fichiers_tests/extended_charset.txt";
  decompresse "./fichiers_tests/extended_charset_txt.hf";
  let test5 = egalite_entre_fichiers "./fichiers_tests/extended_charset.txt" "./fichiers_tests/extended_charset_decompresse.txt" in
  if test5 then () else failwith "Test 5 failed";

  compresse "./fichiers_tests/bible.pdf";
  decompresse "./fichiers_tests/bible_pdf.hf";
  let test6 = egalite_entre_fichiers "./fichiers_tests/bible.pdf" "./fichiers_tests/bible_decompresse.pdf" in
  if test6 then () else failwith "Test 6 failed";
  
  Printf.printf "All tests passed\n"

  