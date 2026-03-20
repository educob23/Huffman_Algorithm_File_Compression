# Algorithme de Huffman — Compression de fichiers

> Projet académique (L2, Université Paris-Saclay) — Compression et décompression de fichiers sans perte, implémentées en OCaml grâce à l'algorithme de Huffman.

---

## Présentation

Ce projet implémente un pipeline complet de compression et décompression de fichiers basé sur l'**algorithme de Huffman**, un algorithme qui attribue des codes binaires plus courts aux octets les plus fréquents. Le résultat est un format de compression sans perte qui fonctionne sur n'importe quel type de fichier (texte, PDF, binaire, etc.). Le rapport de projet complet est disponible dans [`docs/Rapport_de_projet.pdf`](docs/Rapport_de_projet.pdf).

Fonctionnalités principales :
- Compression et décompression de tout type de fichier
- L'arbre de Huffman est sérialisé directement dans le fichier compressé (aucun dictionnaire externe nécessaire)
- Statistiques de compression (taille, durée, taux)
- Tests automatiques de cohérence (compression puis décompression)

---

## Structure du projet

```
.
├── huffman.ml       # Algorithme principal : construction de l'arbre, compression, décompression
├── heap.ml          # Type arbre binaire et utilitaires
├── heap.mli         # Interface du module arbre
├── bs.ml            # Entrées/sorties bit à bit (lecture et écriture de bits et d'octets)
├── bs.mli           # Interface du module flux de bits
├── huff.ml          # Point d'entrée : gestion des arguments en ligne de commande
├── dune             # Règles de build
├── dune-project     # Descripteur du projet Dune
├── scripts          # fichier pour lancer les tests qui bypass le warning root-detection
└── fichiers_tests/  # Fichiers d'exemple pour les tests
```

---

## Prérequis

- [OCaml](https://ocaml.org/) ≥ 4.14
- [opam](https://opam.ocaml.org/) (gestionnaire de paquets OCaml)
- [dune](https://dune.build/) ≥ 3.0

---

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/educob23/Huffman_Algorithm_File_Compression.git
cd Huffman_Algorithm_File_Compression

# Installer les dépendances
opam install . --deps-only

---

## Utilisation

### Compresser un fichier

```bash
./scripts/compress.sh <fichier>
```

Exemple :

```bash
./scripts/compress.sh fichiers_tests/text.txt
# Résultat : text_txt.hf
```

### Décompresser un fichier

```bash
./scripts/decompress.sh <fichier>
```

Exemple :

```bash
./scripts/decompress.sh fichiers_tests/text_txt.hf
# Résultat : text_decompresse.txt
```

### Afficher les statistiques de compression
Compresse aussi le fichier

```bash
./scripts/stats.sh <fichier>
```

Exemple de sortie :

```
Taille du fichier non compressé : 102400 octets
Taille du fichier compressé     : 57832 octets
Taux de compression             : 56.48%
Temps de compression            : 0.043291 secondes
```

---

## Fonctionnement

1. **Analyse des fréquences** — Le fichier est lu octet par octet et le nombre d'occurrences de chaque octet (0–255) est compté.
2. **Construction de la file de priorité** — Seuls les octets présents dans le fichier sont conservés, triés par fréquence.
3. **Construction de l'arbre de Huffman** — Les deux nœuds de plus faible fréquence sont fusionnés de manière répétée en un nœud parent, jusqu'à ce qu'il ne reste qu'un seul arbre.
4. **Génération de la table de codes** — L'arbre est parcouru pour attribuer un code binaire à chaque octet (`0` = branche gauche, `1` = branche droite). Les octets fréquents obtiennent des codes plus courts.
5. **Sérialisation** — La structure de l'arbre est écrite en début de fichier compressé, afin que la décompression ne nécessite aucune donnée externe.
6. **Encodage** — Chaque octet du fichier original est remplacé par son code Huffman, et le résultat est écrit bit par bit.
7. **Décodage** — L'arbre est lu depuis le fichier compressé, puis les bits sont consommés un par un en parcourant l'arbre jusqu'à atteindre une feuille (= un octet).

---

## Lancer les tests

```bash
./scripts/test.sh
```

La suite de tests compresse puis décompresse plusieurs types de fichiers (texte simple, jeu de caractères étendu, binaire) et vérifie octet par octet que le résultat est identique au fichier d'origine.

---

## Limites

- Les fichiers ne contenant qu'un seul octet distinct ne sont pas gérés (un arbre de Huffman nécessite au moins deux symboles distincts).
- Les performances ne sont pas optimisées pour les très grands fichiers (> 1 Go).
