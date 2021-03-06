#' Retrieve chemical information from HTTK package
#' 
#' This function provides the information specified in "info=" (can be single entry
#' or vector) for all chemicals for which a toxicokinetic model can be
#' paramterized for a given species.
#' 
#' When default.to.human is set to TRUE, and the species-specific data,
#' Funbound.plasma and Clint, are missing from chem.physical_and_invitro.data,
#' human values are given instead.
#' 
#' @param info A single character vector (or collection of character vectors)
#' from "Compound", "CAS", "DTXSID, "logP", "pKa_Donor"," pKa_Accept", "MW", "Clint",
#' "Clint.pValue", "Funbound.plasma","Structure_Formula", or "Substance_Type". info="all"
#' gives all information for the model and species.
#' @param species Species desired (either "Rat", "Rabbit", "Dog", "Mouse", or
#' default "Human").
#' @param fup.lod.default Default value used for fraction of unbound plasma for
#' chemicals where measured value was below the limit of detection. Default
#' value is 0.0005.
#' @param model Model used in calculation, 'pbtk' for the multiple compartment
#' model, '1compartment' for the one compartment model, '3compartment' for
#' three compartment model, '3compartmentss' for the three compartment model
#' without partition coefficients, or 'schmitt' for chemicals with logP and
#' fraction unbound (used in predict_partitioning_schmitt).
#' @param default.to.human Substitutes missing values with human values if
#' true.
#' @return \item{info}{Table/vector containing values specified in "info" for
#' valid chemicals.}
#' @author John Wambaugh and Robert Pearce
#' @keywords Retrieval
#' @examples
#' 
#' \dontrun{
#' # List all CAS numbers for which the 3compartmentss model can be run in humans: 
#' get_cheminfo()
#' 
#' get_cheminfo(info=c('compound','funbound.plasma','logP'),model='pbtk') 
#' # See all the data for humans:
#' get_cheminfo(info="all")
#' 
#' TPO.cas <- c("741-58-2", "333-41-5", "51707-55-2", "30560-19-1", "5598-13-0", 
#' "35575-96-3", "142459-58-3", "1634-78-2", "161326-34-7", "133-07-3", "533-74-4", 
#' "101-05-3", "330-54-1", "6153-64-6", "15299-99-7", "87-90-1", "42509-80-8", 
#' "10265-92-6", "122-14-5", "12427-38-2", "83-79-4", "55-38-9", "2310-17-0", 
#' "5234-68-4", "330-55-2", "3337-71-1", "6923-22-4", "23564-05-8", "101-02-0", 
#' "140-56-7", "120-71-8", "120-12-7", "123-31-9", "91-53-2", "131807-57-3", 
#' "68157-60-8", "5598-15-2", "115-32-2", "298-00-0", "60-51-5", "23031-36-9", 
#' "137-26-8", "96-45-7", "16672-87-0", "709-98-8", "149877-41-8", "145701-21-9", 
#' "7786-34-7", "54593-83-8", "23422-53-9", "56-38-2", "41198-08-7", "50-65-7", 
#' "28434-00-6", "56-72-4", "62-73-7", "6317-18-6", "96182-53-5", "87-86-5", 
#' "101-54-2", "121-69-7", "532-27-4", "91-59-8", "105-67-9", "90-04-0", 
#' "134-20-3", "599-64-4", "148-24-3", "2416-94-6", "121-79-9", "527-60-6", 
#' "99-97-8", "131-55-5", "105-87-3", "136-77-6", "1401-55-4", "1948-33-0", 
#' "121-00-6", "92-84-2", "140-66-9", "99-71-8", "150-13-0", "80-46-6", "120-95-6",
#' "128-39-2", "2687-25-4", "732-11-6", "5392-40-5", "80-05-7", "135158-54-2", 
#' "29232-93-7", "6734-80-1", "98-54-4", "97-53-0", "96-76-4", "118-71-8", 
#' "2451-62-9", "150-68-5", "732-26-3", "99-59-2", "59-30-3", "3811-73-2", 
#' "101-61-1", "4180-23-8", "101-80-4", "86-50-0", "2687-96-9", "108-46-3", 
#' "95-54-5", "101-77-9", "95-80-7", "420-04-2", "60-54-8", "375-95-1", "120-80-9",
#' "149-30-4", "135-19-3", "88-58-4", "84-16-2", "6381-77-7", "1478-61-1", 
#' "96-70-8", "128-04-1", "25956-17-6", "92-52-4", "1987-50-4", "563-12-2", 
#' "298-02-2", "79902-63-9", "27955-94-8")
#' httk.TPO.rat.table <- subset(get_cheminfo(info="all",species="rat"),
#'  CAS %in% TPO.cas)
#'  
#' httk.TPO.human.table <- subset(get_cheminfo(info="all",species="human"),
#'  CAS %in% TPO.cas)
#' }
#' 
#' @export get_cheminfo
get_cheminfo <- function(info="CAS",
                         species="Human",
                         fup.lod.default=0.005,
                         model='3compartmentss',
                         default.to.human=F)
{
# Parameters in this list can be retreive with the info argument:
  valid.info <- c("Compound",
                  "CAS",
                  "Clint",
                  "Clint.pValue",
                  "DTXSID",
                  "Formula",
                  "Funbound.plasma",
                  "logMA",
                  "logP",
                  "MW",
                  "Rblood2plasma",
                  "pKa_Accept",
                  "pKa_Donor"
                  )
  if (any(!(toupper(info) %in% toupper(valid.info))) & any(tolower(info)!="all")) stop(paste("Data on",
    info[!(info %in% valid.info)],"not available. Valid options are:",
    paste(valid.info,collapse=" ")))
  if (any(toupper(info)=="ALL")) info <- valid.info

  
  #R CMD CHECK throws notes about "no visible binding for global variable", for
  #each time a data.table column name is used without quotes. To appease R CMD
  #CHECK, a variable has to be created for each of these column names and set to
  #NULL. Note that within the data.table, these variables will not be NULL! Yes,
  #this is pointless and annoying.
  physiology.data <- NULL
  
  #End R CMD CHECK appeasement.

# Figure out which species we support
  valid.species <- colnames(httk::physiology.data)[!(colnames(httk::physiology.data)
    %in% c("Parameter","Units"))]
# Standardize the species capitalization
  if (tolower(species) %in% tolower(valid.species)) species <-
    valid.species[tolower(valid.species)==tolower(species)]
  else stop("Requested species not found in physiology.table.")
  
# We need to know model-specific information (from modelinfo_[MODEL].R]): 
  model <- tolower(model)
  if (!(model %in% names(model.list)))            
  {
    stop(paste("Model",model,"not available. Please select from:",
      paste(names(model.list),collapse=", ")))
  } else {
    necessary.params <- model.list[[model]]$required.params
    exclude.fup.zero <- model.list[[model]]$exclude.fup.zero
  }
  if (is.null(necessary.params)) stop(paste("Necessary parameters for model",
    model,"have not been defined."))
  
  # For now let's not require these because it's still hard to distringuish
  # between compounds that don't ionize and those for which we don't have
  # good predictions
  necessary.params <- necessary.params[!(tolower(necessary.params)%in%
    tolower(c("pKa_Donor","pKa_Accept","Dow74")))]
  
  # Change to the names in chem.physical_and_invitro.table:
  if ("pow" %in% tolower(necessary.params)) 
    necessary.params[tolower(necessary.params)=="pow"] <-
    "logP"
  
  # Flag in case we can't find a column for every parameter:
  incomplete.data <- F

  # Identify the appropriate column for Funbound (if needed):
  species.fup <- NULL
  if (tolower("Funbound.plasma") %in% unique(tolower(c(necessary.params,info))))
  {
    if (paste0(species,'.Funbound.plasma') %in% 
      colnames(chem.physical_and_invitro.data)) 
      species.fup <- paste0(species,'.Funbound.plasma')
    else if (default.to.human)
    {
      species.fup <- 'Human.Funbound.plasma'
      warning('Human values substituted for Funbound.plasma.')
    } else incomplete.data <- T
    if (!is.null(species.fup)) necessary.params[necessary.params=="Funbound.plasma"]<-species.fup
  }
      
  # Identify the appropriate column for Clint (if needed):
  species.clint <- NULL
  species.clint.pvalue <- NULL
  if (tolower("Clint") %in% unique(tolower(c(necessary.params,info))))   
  {
    if (paste0(species,'.Clint') %in% 
      colnames(chem.physical_and_invitro.data))
    {
      species.clint <- paste0(species,'.Clint')
      species.clint.pvalue <- paste0(species,'.Clint.pValue')
    } else if (default.to.human) {
      species.clint <- 'Human.Clint'
      species.clint.pvalue <- 'Human.Clint.pValue'
      warning('Human values substituted for Clint and Clint.pValue.')
    } else incomplete.data <- T
    if (!is.null(species.clint)) necessary.params[necessary.params=="Clint"]<-species.clint
  } 

  # Identify the appropriate column for Rblood2plasma (if needed):
  species.rblood2plasma <- NULL
  if (tolower("Rblood2plasma") %in% unique(tolower(c(necessary.params,info))))   
  {
    if (paste0(species,'.Rblood2plasma') %in% 
      colnames(chem.physical_and_invitro.data))
    {
      species.rblood2plasma <- paste0(species,'.Rblood2plasma')
    } else if (default.to.human) {
      species.rblood2plasma <- 'Human.Rblood2plasma'
      warning('Human values substituted for Rblood2plasma.')
    } else incomplete.data <- T
    if (!is.null(species.rblood2plasma)) necessary.params[necessary.params=="Rblood2plasma"]<-species.rblood2plasma
  } 

  if (!incomplete.data)
  {
    # Only look for parameters that we have in the table:
    necessary.params <- necessary.params[tolower(necessary.params) %in%
    tolower(colnames(chem.physical_and_invitro.data))]
  
  # Pare the chemical data down to only those chemicals where all the necessary
  # parameters are not NA
    good.chemicals.index <- apply(chem.physical_and_invitro.data[,necessary.params],
      1,function(x) all(!is.na(x)))
      
  # If we need fup:
    if (!is.null(species.fup))
    {  
  # Make sure that we have a usable fup:
      fup.values <- chem.physical_and_invitro.data[,species.fup]
      fup.values.numeric <- suppressWarnings(!is.na(as.numeric(fup.values)))
  # If we are exclude the fups with a zero, then get rid of those:
      if (exclude.fup.zero) 
      {
        suppressWarnings(fup.values.numeric[as.numeric(fup.values)==0] <- F)
        fup.values.numeric[is.na(fup.values.numeric)] <- F 
      }
  # However, we want to include the fups that are distributions:
      fup.values.dist <- suppressWarnings(nchar(fup.values) - nchar(gsub(",","",fup.values))==2) 
      fup.values.dist[is.na(fup.values.dist)] <- F
      good.chemicals.index <- good.chemicals.index & 
  # Either a numeric value:
        (fup.values.numeric |
  # or three values separated by two commas:
        fup.values.dist)
    }
    
# If we need Clint:
    if (!is.null(species.clint))
    {
      clint.values <- chem.physical_and_invitro.data[,species.clint]
      clint.values.numeric <- suppressWarnings(!is.na(as.numeric(clint.values)))
      clint.values.dist <- suppressWarnings(nchar(clint.values) - nchar(gsub(",","",clint.values))==3)
      clint.values.dist[is.na(clint.values.dist)] <- F
      good.chemicals.index <- good.chemicals.index &
# Either a numeric value:
        (clint.values.numeric |
# or four values separated by three commas:
        clint.values.dist)
    }
# Kep just the chemicals we want:    
    good.chemical.data <- chem.physical_and_invitro.data[good.chemicals.index,] 
    
# Get the calpitalizes tion correct on the information requested:
    if ('mw' %in% tolower(info)) info <- c('MW',info[tolower(info) != 'mw'])
    if ('pka_accept' %in% tolower(info)) info <- 
      c('pKa_Accept',info[tolower(info) != 'pka_accept'])
    if ('pka_donor' %in% tolower(info)) info <- 
      c('pKa_Donor',info[tolower(info) != 'pka_donor'])
    if ('logp' %in% tolower(info)) info <- 
      c('logP',info[tolower(info) != 'logp'])
    if ('compound' %in% tolower(info)) info <- 
      c('Compound',info[tolower(info) != 'compound'])
    if ('cas' %in% tolower(info)) info <- c('CAS',info[tolower(info) != 'cas'])
    if ('dsstox_substance_id' %in% tolower(info)) info <- 
      c('DSSTox_Substance_Id',info[tolower(info) != 'dsstox_substance_id'])
    if ('structure_formula' %in% tolower(info)) info <- 
      c('Structure_Formula',info[tolower(info) != 'structure_formula'])
    if ('substance_type' %in% tolower(info)) info <- 
      c('Substance_Type',info[tolower(info) != 'substance_type'])    
 
    if (toupper("Clint") %in% toupper(info)) 
      info[toupper(info)==toupper("Clint")] <- species.clint
    if (toupper("Clint.pValue") %in% toupper(info)) 
      info[toupper(info)==toupper("Clint.pValue")] <- species.clint.pvalue
    if (toupper("Funbound.plasma") %in% toupper(info)) 
      info[toupper(info)==toupper("Funbound.plasma")] <- species.fup
    if (toupper("Rblood2plasma") %in% toupper(info)) 
      info[toupper(info)==toupper("Rblood2plasma")] <- species.rblood2plasma
    
    columns <- colnames(chem.physical_and_invitro.data)
    this.subset <- good.chemical.data[,
      toupper(colnames(chem.physical_and_invitro.data))%in%toupper(columns)]
    
    if('CAS' %in% info) rownames(this.subset) <- NULL 
    
    if (!exclude.fup.zero) 
    {
      fup.zero.chems <- suppressWarnings(as.numeric(this.subset[,species.fup]) == 0)
      fup.zero.chems[is.na(fup.zero.chems)] <- FALSE
      this.subset[fup.zero.chems, species.fup] <- fup.lod.default
    }
                                
    return.info <- this.subset[,info]
  } else return.info <- NULL 
    
  return(return.info)
}
