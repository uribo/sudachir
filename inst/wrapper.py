import pandas as pd
from sudachipy import tokenizer
from sudachipy import dictionary

def tokenize_to_pd(docs, text_field, docid_field, instance):
  """Tokenize text of a pandas dataframe

  Args:
    docs (pandas.DataFrame): A dataframe of corpus.
    text_field (str): Column name that contains text to be tokenized.
    docid_field (str): Column name that contains identifier of documents.
    instance (sudachipy.tokenizer.Tokenizer): Sudachi tokenizer.
    mode (sudachipy.tokenizer.Tokenizer.splitMode): Split mode.

  Returns:
    pandas.DataFrame: A dataframe of tokens.
  """

  doc_id = []
  sentence_id = []
  token_id = []
  surface = []
  dict_form = []
  norm_form = []
  reading_form = []
  feature = []

  for i in range(len(docs)):
    texts = docs.get(text_field)[i].splitlines()
    docname = docs.get(docid_field)[i]
    morphemes = instance.tokenize("");
    tid = 1
    for j, text in enumerate(filter(None, texts)):
      instance.tokenize(text, out = morphemes);
      for m in morphemes:
        doc_id.append(docname)
        sentence_id.append(j)
        token_id.append(tid)
        surface.append(m.surface())
        dict_form.append(m.dictionary_form())
        norm_form.append(m.normalized_form())
        reading_form.append(m.reading_form())
        feature.append(",".join(m.part_of_speech()))
        tid += 1
      tid = 1

  return(pd.DataFrame({
    "doc_id": doc_id,
    "sentence_id": sentence_id,
    "token_id": token_id,
    "surface": surface,
    "dictionary_form": dict_form,
    "normalized_form": norm_form,
    "reading_form": reading_form,
    "feature": feature
  }))
