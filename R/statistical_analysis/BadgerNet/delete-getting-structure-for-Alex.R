badger_load <- load_with_ref(
  "../../../data/BadgerNet/BadgerNet-processed.parquet",
  seperate_ref_sheet = "../../../data/BadgerNet/BadgerNet-RefGroups.xlsx",
  ref_sheet = "reference",
  add_colon = FALSE,
  return_ref = TRUE
)

badgerVar <- function(col) {
  return(class(badger[[col]])[[1]])
}

badgerMax <- function(col) {
  if (class(badger[[col]])[[1]] != "factor") {
    return(max(badger[[col]]))
  } else {
    return(max(as.character(badger[[col]])))
  }
}

badgerMin <- function(col) {
  if (class(badger[[col]])[[1]] != "factor") {
    return(min(badger[[col]]))
  } else {
    return(min(as.character(badger[[col]])))
  }
}

df <- data.frame(
  Variable = colnames(badger),
  Class = unlist(lapply(colnames(badger), badgerVar)),
  Max = unlist(lapply(colnames(badger), badgerMax)),
  Min = unlist(lapply(colnames(badger), badgerMin))
)

writexl::write_xlsx(df, "BN-structure.xlsx")

