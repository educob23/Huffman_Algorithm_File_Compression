# Huffman Algorithm — File Compression

> Academic project (L2, Université Paris-Saclay) — Lossless file compression and decompression implemented in OCaml using the Huffman coding algorithm.

---

## Overview

This project implements a complete file compression and decompression pipeline based on **Huffman coding**, a greedy algorithm that assigns shorter binary codes to more frequent bytes. The result is a lossless compression format that works on any file type (text, PDF, binary, etc.).

Key features:
- Compression and decompression of any file type
- Huffman tree serialized directly into the compressed file (no external dictionary needed)
- Compression ratio statistics (size, time, percentage)
- Automatic round-trip tests to verify integrity

---

## Project Structure

```
.
├── huffman.ml       # Core algorithm: tree construction, compression, decompression
├── huffman.mli      # (optional) Interface file
├── heap.ml          # Binary tree type and utilities
├── heap.mli         # Interface for the tree module
├── bs.ml            # Bit-level I/O (read/write individual bits and bytes)
├── bs.mli           # Interface for the bit stream module
├── huff.ml          # Entry point: command-line argument parsing
├── dune             # Build rules
├── dune-project     # Dune project descriptor
└── tests/           # Sample files for testing
```

---

## Requirements

- [OCaml](https://ocaml.org/) ≥ 4.14
- [opam](https://opam.ocaml.org/) (OCaml package manager)
- [dune](https://dune.build/) ≥ 3.0

---

## Installation

```bash
# Clone the repository
git clone https://github.com/educob23/Huffman_Algorithm_File_Compression.git
cd Huffman_Algorithm_File_Compression

# Install dependencies
opam install . --deps-only

# Build
dune build
```

---

## Usage

### Compress a file

```bash
dune exec ./huff.exe -- compress <file>
```

Example:

```bash
dune exec ./huff.exe -- compress my_document.txt
# Output: my_document_txt.hf
```

### Decompress a file

```bash
dune exec ./huff.exe -- decompress <file.hf>
```

Example:

```bash
dune exec ./huff.exe -- decompress my_document_txt.hf
# Output: my_document_decompresse.txt
```

### Show compression statistics

```bash
dune exec ./huff.exe -- stats <file>
```

Example output:

```
Taille du fichier non compressé : 102400 octets
Taille du fichier compressé     : 57832 octets
Taux de compression             : 56.48%
Temps de compression            : 0.043291 secondes
```

---

## How It Works

1. **Frequency analysis** — The file is scanned byte by byte and the number of occurrences of each byte (0–255) is counted.
2. **Priority queue construction** — Only the bytes that actually appear in the file are kept, sorted by frequency.
3. **Huffman tree construction** — The two nodes with the lowest frequency are repeatedly merged into a parent node until a single tree remains.
4. **Code table generation** — The tree is traversed to assign a binary code to each byte (`0` = left branch, `1` = right branch). Frequent bytes get shorter codes.
5. **Serialization** — The tree structure is written at the beginning of the compressed file so that decompression requires no external data.
6. **Encoding** — Each byte of the original file is replaced by its Huffman code, and the result is written bit by bit.
7. **Decoding** — The tree is read from the compressed file, then bits are consumed one by one by traversing the tree until a leaf (= a byte) is reached.

---

## Running the Tests

```bash
dune test
```

The test suite compresses and then decompresses several file types (plain text, extended charset, binary) and verifies byte-for-byte that the output is identical to the original.

---

## Limitations

- Files containing only one distinct byte are not handled (a Huffman tree requires at least two distinct symbols).
- Performance is not optimized for very large files (> 1 GB).

---

## Academic Context

This project was completed as part of the **L2 Computer Science** curriculum at **Université Paris-Saclay**. The full project report (in French) is available in [`docs/Rapport_de_projet.pdf`](docs/Rapport_de_projet.pdf).

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
