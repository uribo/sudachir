import pandas as pd
from sudachipy import tokenizer
from sudachipy import dictionary

def tokenize_to_pd(docs, text_field, docid_field, instance, mode):
  
  doc_id = []
  token_id = []
  surface = []
  dict_form = []
  norm_form = []
  reading_form = []
  feature = []

  for i in range(len(docs)):
    texts = docs.get(text_field)[i].splitlines()
    docname = docs.get(docid_field)[i]
    tid = 1
    for text in filter(None, texts):
      for m in instance.tokenize(text, mode):
        doc_id.append(docname)
        token_id.append(tid)
        surface.append(m.surface())
        dict_form.append(m.dictionary_form())
        norm_form.append(m.normalized_form())
        reading_form.append(m.reading_form())
        feature.append(",".join(m.part_of_speech()))
        tid += 1
      tid = 1

  df = pd.DataFrame({
    "doc_id": doc_id,
    "token_id": token_id,
    "surface": surface,
    "dictionary_form": dict_form,
    "normalized_form": norm_form,
    "reading_form": reading_form,
    "feature": feature
  })

  return(df)
