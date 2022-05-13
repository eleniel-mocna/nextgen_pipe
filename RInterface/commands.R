prepare_scripts <- function(from="/scripts", to_file="/scripts/RInterface.R", ext=".sh"){
  system("sudo chmod -R 777 /scripts")
  cat("library(magrittr)
run_script <- function(script, input){
  if (length(input)==1) system(paste("sudo", script, input), intern = TRUE)
  else system(paste("sudo", script), intern = TRUE, input = input)
}

change_config_file <- function(input, new_config){
  c(new_config, input[-1])
}

merge_output_lists<- function(config_file, ...){
  l<-list(...)
  l <-lapply(l, function(x){x[-1]})
  get_elements <- function(x){
    if (length(x[[1]])==0){
      return(list())
    }
    c(lapply(x, function(l){l[1]}), get_elements(lapply(x, function(l){l[-1]})))
  }
  c(config_file, unlist(get_elements(l)))
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