# This file contains the main import functions


read_metadata <- function(dataset){
  read.csv2(system.file("extdata",
                        paste0(dataset,'_files_metadata_harmonization.csv'),
                        package = "microdadosBrasil"),
            stringsAsFactors = FALSE)

}

read_var_translator <- function(dataset, ft){
  read.csv2(system.file("extdata",
                        paste0(dataset,'_',ft,'_varname_harmonization.csv'),
                        package = "microdadosBrasil"), stringsAsFactors = FALSE)
}




#' Reads fixed-width file (fwf) file based on dictionary.
#'
#' @param f A fixed-width file (fwf) (normally a .txt file).
#' @param dic A data.frame, containing the import dictionary, including the variables: var_name, int_pos, fin_pos, decima_places (optional)
#' @return a data.frame containing the imported data.
#'
#' @examples
#' aux_read_fwf(filename.txt,dicionary_name)
#' @import readr
#' @export
aux_read_fwf <- function(f,dic){
  print(f)
  f %>% read_fwf(fwf_positions(start=dic$int_pos,end=dic$fin_pos,col_names=dic$var_name),
                 col_types=paste(dic$col_type,collapse ='')) -> d
  for(i in names(d)){
    if(dic[dic$var_name==i,"col_type"] != 'c'){
      print(i)
    }
  }
  return(d)
}





#' Reads files (fwf or csv).
#'
#' Main import function. Parses metadata and import diciontaries (in case of fwf files) to obtain import parameters for the desired subdataset and year. Then imports based on those parameters. Should not be aceessed directly, unless you are trying to extend the package, but rather though the wrapper funtions (read_CENSO, read_PNAD, etc).
#' @param ft file type. Indicates the subdataset within the dataset. For example: "pessoa" (person) or "domicílio" (household) data from the "CENSO" (Census). For a list of available ft for the period just type an invalid ft (Ex: ft = 'aasfasf')
#' @param i period. Normally year in YYY format.
#' @param metadata a data.frame containing one row per period and columns indicating: period, type (fwf, csv) download location, directory structure of the source data, hamonized file and dictionary names for subdataset (ft).
#' @param dic_list a list containing import dictionary data.frames for each year and subdataset (ft). Only necessary if data is in fwf format
#' @param var_translator (optional) a data.frame containing a subdataset (ft) specific renaming dictionary. Rows indicate the variable and the columuns the periods.
#' @param root_path (optional) a path to the directory where dataset was downloaded
#'
#' @examples
#' CSV data:
#' read_data('escola',2014,CensoEscolar_metadata)
#' read_data('escola',2014,CensoEscolar_metadata,CensoEscolar_escola_varname_harmonization)
#'
#' FWF data: dictionary is mandatory
#' read_data('escola',2013,CensoEscolar_metadata,CensoEscolar_dics)

#' @import dplyr
#' @import data.table
#' @import stringr
#' @export
read_data <- function(ft,i,metadata,dic_list=NULL,var_translator=NULL,root_path=NULL){
  #root_path seria o local onde se encontra a pasta com os arquivos
print(i)
  #Extracting Parameters
    i_min    <- min(metadata$year)
    i_max    <- max(metadata$year)
    ft2      <- paste0("ft_",ft)
    ft_list  <- names(metadata)[grep("ft_", names(metadata))]
    ft_list2 <- gsub("ft_","",names(metadata)[grep("ft_", names(metadata))])
    var_list <- names(metadata)[ !(names(metadata) %in% ft_list)]
    #Checking if parameters are valid
    if (!(i %in% metadata$year)) { stop(paste0("Year must be between ", i_min," and ", i_max )) }
    if (!(ft %in% ft_list2 ))    { stop(paste0('ft (file type) must be one of these: ',paste(ft_list2, collapse=", "),
                                               '. See table of valid file types for each year at XXX'))  }

    #subseting metadata and var_translator
    md <- metadata %>% select_(.dots =c(var_list,ft2)) %>% filter(year==i) %>% rename_(.dots=setNames(ft2,ft))
    if (!is.null(var_translator)) {
      vt <- var_translator %>% rename_( old_varname = as.name(paste0('varname',i))) %>%
        select(std_varname ,old_varname ) %>% filter(!is.na(old_varname))
print(str(vt))
    }

    a <- md %>% select_(.dots = ft) %>% collect %>% .[[ft]]
    file_name <- unlist(strsplit(a, split='&'))[2]
    dic   <- unlist(strsplit(a, split='&'))[1] # for fwf files
    delim <- unlist(strsplit(a, split='&'))[1]  # for csv files
    format <- md %>% select_(.dots = 'format') %>% collect %>% .[['format']]
    # data_path <- paste0(root_path,"/",md$path,'/',md$data_folder)
    data_path <-  paste0(root_path,
                         md %>% with(paste0(ifelse(!is.null(root_path) & (!is.na(path)),"/",""),
                                          ifelse(is.na(path),"",path),
                                          ifelse(is.na(path),"","/"),
                                          ifelse(is.na(data_folder),"",data_folder))) )

print(file_name)
print(data_path)
    files <- paste0(data_path,'/',list.files(path=data_path,pattern = file_name, ignore.case=T,recursive = TRUE))
print(files)

  #Checking if parameters are valid
    if (!(i %in% metadata$year)) { stop(paste0("Year must be between ", i_min," and ", i_max )) }
    if (!(ft %in% ft_list2 ))    { stop(paste0('ft (file type) must be one of these: ',paste(ft_list2, collapse=", "),
                                          '. See table of valid file types for each year at XXX'))  }
    if (!file.exists(files)) { stop("Data not found. Check if you have unziped the data" )  }

  #Importing
    print(format)
    t0 <- Sys.time()
    if(format=='fwf'){
      print('a')
      dic <- dic_list[[as.character(i)]][[paste0("dic_",ft,"_",i)]]
      #dic <- get(paste('dic',ft,i,sep='_'))
      lapply(files,aux_read_fwf, dic=dic) %>% bind_rows -> d
    }
    if(format=='csv'){
      print('b')
      lapply(files,data.table::fread, sep = delim) %>% rbindlist(use.names=T) -> d
      #     lapply(files,read_delim, delim = delim) -> d2
      #     d2 %>% bind_rows -> d
      # d <- (csv_file, )
    }
    t1 <- Sys.time()
    print(t1-t0)
    print(object.size(d), units = "Gb")

  #adjusting var names
    if (!is.null(var_translator)) {
print('aaa')
      # d <- d %>% rename_(.dots = one_of(as.character(vt$old_varname), vt$new_varname))
      #names(d)[names(d) %in% vt$old_varname] <- vt$std_varname
      #d <- d %>% data.table::setnames(old = vt$old_varname, new = vt$new_varname)
      test_old_vars<- names(d) %in% vt$old_varname
      test_new_vars <- vt$old_varname %in% names(d)
      names(d)[test_old_vars]<- vt$old_varname[test_new_vars]
    }

  return(d)
}











