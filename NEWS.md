# sudachir (development version)

* The python environment is generated using virtualenv instead of conda.
* Refactored `tokenize_to_df` and `form`.
  * `mode` argument was removed. To change the split mode, pass a `mode` value to `rebuild_tokenizer`.
  * They now also accept a data.frame as the argument.

# sudachir 0.1.0

# sudachir 0.0.9000

* Added a `NEWS.md` file to track changes to the package.
