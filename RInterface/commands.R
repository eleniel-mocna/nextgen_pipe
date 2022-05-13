prepare_scripts <- function(from="/scripts", to_file="/scripts/RInterface.R", ext=".sh"){
  system("sudo chmod -R 777 /scripts")
  cat("library(magrittr)
  run_script <- function(script, input){
  if (length(input)==1) system(paste("sudo", script, input), intern = TRUE)
  else system(paste("sudo", script), intern = TRUE, input = input)
}

merge_output_lists<- function(config_file, ...){
  l<-list(...)
  l <- unlist(lapply(l, function(x){x[2:length(x)]}))
  c(config_file, l)
}
", file=to_file, sep="\n",append=FALSE)
  for (name in list.files(from)) {
    if (stringr::str_sub(name, -nchar(ext))!=ext){
      print(name)
      next
    }
    function_name <- stringr::str_sub(name, 0, -4)
    script <- paste0(from, "/", name)
    function_string <- glue::glue("\n",
                                  "[function_name] <- function(input) {",
                                  "    run_script(\"[script]\", input)",
                                  "}",
                                  "\n", .sep="\n", .open="[", .close="]")
    cat(function_string, file=to_file, append = TRUE)
  }
}
prepare_scripts()