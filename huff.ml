open Heap
open Bs


(**[lecture commande] fonction pour traiter la ligne de commande
  @return l'exécution de la commande donnée en argument
*)
let lecture_commande = 
  let n = Array.length Sys.argv in

  if n > 3 || n = 1 then              (* cas ou n = 1 ou n > 3 : on a donné trop ou trop peux d'arguments *)
    if n = 1 then 
      failwith "Trop peu d'arguments (min 1)"
    else 
      failwith "Trop d'arguments (max 2)"
  
  else if n = 3 then                   (* cas ou n = 2 : on veux les stats *)
    begin
    if Sys.argv.(1) = "--stats" then 
      try
        Printf.printf "Compression du fichier et affichage de statistiques\n";
        Huffman.stats Sys.argv.(2)
      with
        Sys_error _ -> failwith "Fichier non trouve"  (* on ecrit Sys_error _ au lieu de Sys_error "error" afin d'eviter des warnings car _ marche toujours *)
    else 
      failwith "Faut ecrire '--stats fichier.txt' afin de compresser le fichier et afficher les statistiques"
    end

  else                               (* cas ou n = 1 : on veut compresser ou decompresser ou on demande --help *)
    if Sys.argv.(1) = "--help" then begin
      Printf.printf "Ecrire 'fichier.txt' pour compresser le fichier, 'fichier.hf' pour le decompresser et '--stats fichier.txt' pour comprimer ce fichier et afficher les statistiques de la compression.\nEcrire '--tests' pour executer les tests\n";
      exit(0)
    end
    else if Sys.argv.(1) = "--tests" then 
      begin
        Printf.printf "Execution des tests, cela peut prendre quelques  \n"; 
        Huffman.tests ()
      end
    else 
      let m = String.length Sys.argv.(1) in

      if String.get Sys.argv.(1) (m - 2) = 'h' && String.get Sys.argv.(1)(m - 1) = 'f' then     (* on a un fichier .hf : on doit decompresser *)
        try 
          Printf.printf "Decompression du fichier\n";
          Huffman.decompresse Sys.argv.(1) (*fction de compression*)
        with
          Sys_error _ -> failwith "Fichier non trouve"    (* on ecrit Sys_error _ au lieu de Sys_error "error" afin d'eviter des warnings car _ marche toujours *)

      else  (* on considère on peut tout compresser *)
        try 
          Printf.printf "Compression du fichier\n";
          Huffman.compresse Sys.argv.(1) (*fction de décompression*)
        with
          Sys_error _ -> failwith "Fichier non trouve"     (* on ecrit Sys_error _ au lieu de Sys_error "error" afin d'eviter des warnings car _ marche toujours *)



let() =  lecture_commande
