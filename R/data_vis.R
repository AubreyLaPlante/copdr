#' Melt backslip data table
#'
#'
#' Melt backslip data table into a three column data frame that can be
#' plotted in ggplot.
#'
#' @importFrom reshape melt.data.frame
#' @param data_table A single table with x values as the first column and every
#' subsequent column is a PDF of y values for a single offset site.
#' @param offset_type Input can be "lateral", "vertical" or "total". Any other input
#' will result in an error.
#' @return A data frame with 3 columns including x values, all backslip names,
#' and offset values.
#' @export
#'
#'

simplify4plot <- function(data_table, offset_type = "lateral"){
     if(offset_type == "lateral"){
          data <- as.data.frame(data_table)
          data_melt <- reshape::melt.data.frame(data, id.vars = "h_x", variable.name = "backslip_ID", value.name = "lateral")

     }
     if(offset_type == "vertical"){
          data <- as.data.frame(data_table)
          data_melt <- reshape::melt.data.frame(data, id.vars = "z_x", variable.name = "backslip_ID", value.name = "vertical")

     }
     if(offset_type == "total"){
          data <- as.data.frame(data_table)
          data_melt <- reshape::melt.data.frame(data, id.vars = "t_x", variable.name = "backslip_ID", value.name = "total")

     }
     return(data_melt)
}



#' Clip x extent of offset datatable
#'
#'
#' Clip the x bounds of offset datatable for better plotting.
#'
#' @param data_table A single table with x values as the first column and every
#' subsequent column is a PDF of y values for a single offset site.
#' @param offset_type Input can be "lateral", "vertical" or "total". Any other input
#' will result in an error.
#' @param xmin The minimum x value. Values can be negative or positive but must be less than xmax.
#' @param xmax The maximum x value. Values can be negative or positive but must be greater than xmin.
#' @return A datatable similar to the input data table with a clipped extent for x values.
#' @export
#'
#'
#'


data.clip <- function(data_table, offset_type, xmin, xmax){
     if(xmin > xmax){
          stop("ERROR: X max cannot be less than X min")
     }
     if(xmin == xmax){
          stop("ERROR: X max and X min cannot be the same value.")
     }
     if(offset_type == "lateral"){
          datatable_clip <- data_table[which(data_table$h_x == xmin):which(data_table$h_x ==xmax),]
     }
     if(offset_type == "vertical"){
          datatable_clip <- data_table[which(data_table$z_x == xmin):which(data_table$z_x ==xmax),]
     }
     if(offset_type == "total"){
          datatable_clip <- data_table[which(data_table$t_x == xmin):which(data_table$t_x ==xmax),]
     }
     return(datatable_clip)
}




#' Plot all backslipped PDFs
#'
#'
#' Plot PDFs contained in a datatable.
#'
#' @importFrom ggplot2 ggplot aes stat_align xlim ylim labs
#' @param data_table A single table with x values as the first column and every
#' subsequent column is a PDF of y values for a single offset site. This table must be
#' an output from the 'simplify4plot' function.
#' @param offset_type Input can be "lateral", "vertical" or "total". Any other input
#' will result in an error. Also make sure your input offset type corresponds to the
#' correct datatable.
#' @param xmin The minimum x value. Values can be negative or positive but must be less than xmax.
#' @param xmax The maximum x value. Values can be negative or positive but must be greater than xmin.
#' @param ymin The minimum y value. Values can be negative or positive but must be less than ymax.
#' @param ymax The maximum y value. Values can be negative or positive but must be greater than ymin.
#' @param simplify Must be "Y" or "N". If yes, the data table is simplified using the simplify4plot function.
#' @return A plot produced by ggplot
#' @export
#'
#'
#'


plotPDF <- function(data_table, offset_type, xmin = -10, xmax = 10, ymin = -1, ymax = 1, simplify = "Y"){
     if(simplify == "Y"){
          data_table <- simplify4plot(data_table,offset_type)
     }
     if(offset_type == "lateral"){
          plot <- ggplot2::ggplot(mapping = aes(x=data_table$h_x,
                                                y = data_table$value,
                                                level = factor(data_table$variable)))+
               stat_align()+
               xlim(xmin,xmax)+
               ylim(ymin,ymax)+
               labs(title = "Lateral PDFs", x = "Lateral Offset (m)", y = "Probability")
     }
     if(offset_type == "vertical"){
          plot <- ggplot2::ggplot(mapping = aes(x=data_table$z_x,
                                                y = data_table$value,
                                                level = factor(data_table$variable)))+
               stat_align()+
               xlim(xmin,xmax)+
               ylim(ymin,ymax)+
               labs(title = "Vertical PDFs", x = "Vertical Offset (m)", y = "Probability")

     }
     if(offset_type == "total"){
          plot <- ggplot2::ggplot(mapping = aes(x=data_table$t_x,
                                                y = data_table$value,
                                                level = factor(data_table$variable)))+
               stat_align()+
               xlim(xmin,xmax)+
               ylim(ymin,ymax)+
               labs(title = "Total PDFs", x = "Total Offset (m)", y = "Probability")
     }
     return(plot)
}


#' Plot summed PDFs
#'
#'
#' Plot summed PDFs contained in a datatable.
#'
#' @importFrom ggplot2 ggplot aes stat_align xlim ylim labs
#' @param data_table A single table with "h_x", "z_x" or "t_x" values as the first column
#' and a 'y' column of summed PDF values
#' @param offset_type Input can be "lateral", "vertical" or "total". Any other input
#' will result in an error. Also make sure your input offset type corresponds to the
#' correct datatable.
#' @param maxCOV The threshold COV value. All values larger than the threshold are removed from COPD analysis.
#' @param xmin The minimum x value. Values can be negative or positive but must be less than xmax.
#' @param xmax The maximum x value. Values can be negative or positive but must be greater than xmin.
#' @return A plot produced by ggplot
#' @export
#'
#'
#'


plotCOPD <- function(data_table, offset_type, maxCOV, xmin = -10, xmax = 10){
     if(offset_type == "lateral"){
          plot <- ggplot2::ggplot(mapping = aes(x= data_table$h_x,
                                                y= data_table$y))+
               stat_align()+
               xlim(xmin,xmax)+
               labs(title = paste("Lateral COPDs;", "COV <",maxCOV),
                    x = "Lateral Offset (m)", y = "Cumulative Probability")
     }
     if(offset_type == "vertical"){
          plot <- ggplot2::ggplot(mapping = aes(x=data_table$z_x,
                                                y = data_table$y))+
               stat_align()+
               xlim(xmin,xmax)+
               labs(title = paste("Vertical COPDs;", "COV <",maxCOV),
                    x = "Vertical Offset (m)", y = "Cumulative Probability")

     }
     if(offset_type == "total"){
          plot <- ggplot2::ggplot(mapping = aes(x=data_table$t_x,
                                                y = data_table$y))+
               stat_align()+
               xlim(xmin,xmax)+
               labs(title = paste("Total COPDs;", "COV <",maxCOV),
                    x = "Total Offset (m)", y = "Cumulative Probability")
     }
     return(plot)
}
