run.tests <- function(cmd.file, ref.file, object.file, tolerance = .000999, cutoff = -99)
{
  eval.fit <- function(idx, name, ref.data, replic, tolerance=.00001)
  {
    test_results <- data.frame(Test=idx,Name=name,Error=NA,Result="")
    test_results$Test=as.numeric(test_results$Test)
    test_results$Name=as.character(test_results$Name)
    test_results$Error=as.numeric(test_results$Error)
    test_results$Result=as.character(test_results$Result)
    
    print(paste("nrows",nrow(ref.data),nrow(replic)))
    test_results$Error[1] <- mean(colMeans(abs(ref.data - replic[1:nrow(ref.data),1:ncol(ref.data)]),na.rm=T))
    if (test_results$Error[1] < tolerance) test_results$Result[1]="Passed" else  
      test_results$Result[1]="Failed"
    
    return(test_results)           
  }

  colMax <- function(data) sapply(data, max, na.rm = TRUE)
  
  cmd.list <- read.csv(cmd.file,stringsAsFactors = F)
  ref.file.list <- read.csv(ref.file,stringsAsFactors = F)$ReferenceFile
  object.list <- read.csv(object.file,stringsAsFactors = F)$Object
  
  results <- NULL
  idx <- 1
  
  for (test in 1:ncol(cmd.list))
  {
    lazyNut_exec(paste(cmd.list[,test],"\n"))
    print(paste("Running",names(cmd.list)[test]))
    print(paste("Loading reference data:",ref.file.list[test]))
    ref.data <- read.csv(ref.file.list[test],quote="",comment.char = "")
    # some fiddling to allow parenthetical headers
    names(ref.data)=strsplit(head(readLines(ref.file.list[test]),1),",")[[1]]
    print("Headers in reference file:")
    print(names(ref.data))
#    check=tapply(names(ref.data),rep(1,length(names(ref.data)),function(x) {return (which(x == names(object.list[test])))} ))
    print(paste("Observing",object.list[test]))
    observed <- eN[as.character(object.list[test])]
#    print (names(observed))
    print("Check:")
    for (x in names(ref.data)) { print (x); print (which(x == names(observed)))}
    #    print(head(eN[as.character(object.list[test])],1))

#    write.csv(observed,paste(as.character(object.list[test]),"observed1.csv"))
    observed <- observed[,names(ref.data)]
    
    print(names(observed))
    print("Comparing observation with reference")
#    eN["tmp"] <- merge(eN[as.character(object.list[test])],ref.data,by="time")
    tmp <- merge(observed,ref.data,by="time")
#    write.csv(tmp,paste(as.character(object.list[test]),"merged.csv"))
    print(paste("nrow tmp after merge",nrow(tmp)))
#    tmp <- tmp %>% distinct(time)
    tmp <- subset(tmp, !duplicated(time)) 
    print(paste("nrow tmp after removal of duplicate times",nrow(tmp)))
#    write.csv(observed,paste(as.character(object.list[test]),"observed.csv"))
    write.csv(tmp,paste0("test",idx,".",as.character(object.list[test]),"observed.and.target.csv"))
    
    results <- rbind(results,eval.fit(idx,names(cmd.list)[idx],ref.data,tmp,tolerance))
    idx <- idx+1
  }
  
  eN["test_results"] <<- results
  print(eN["test_results"])
}
