# Get the command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Assign the argument to a variable
base_name <- args[1]

# Create the input and output file names
input_file <- paste0(base_name)
output_file <- paste0(base_name, ".csv")

# Read the data
dat <- read.delim(input_file, stringsAsFactors = FALSE, header = FALSE, skip = 1, sep = "")

# Set column names
colnames(dat) <- c("Individual", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10", "Status")

# Write the data to a CSV file
write.table(dat, output_file, quote = FALSE, sep = "\t", row.names = FALSE)