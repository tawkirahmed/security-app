#!/bin/bash
counter2=0
vulnerabilities1=( $(cut -d ',' -f1 smallSet.csv ) )
vulnerabilities2=( $(cut -d ',' -f2 smallSet.csv ) )
vulnerabilities3=( $(cut -d ',' -f3 smallSet.csv ) )

for var in "${vulnerabilities1[@]}"
do  
 if [[ "$counter2" != *"0"* ]]
 then
   arrayFinal[0]=lib_name,version,commit_hash,author,commentary,date,link,is_present
   #arrayLibName[counter]="${vulnerabilities1[$counter]}" 
   #arrayLibId[counter]="${vulnerabilities2[$counter]}" 
   #arrayGitLink[counter]="${vulnerabilities3[$counter]}" 
   link="${vulnerabilities3[$counter2]}" 
   prefix="\""
   suffix="\""
   github_link=${link#"$prefix"}
   github_link=${github_link%"$suffix"}
   git clone "${github_link}" "${vulnerabilities2[$counter2]}"
   cd "${vulnerabilities2[$counter2]}"
   git log --pretty="format:%H,%an,%f,%cI" > "${vulnerabilities2[$counter2]}".csv

   column1=( $(cut -d ',' -f1 "${vulnerabilities2[$counter2]}".csv) )
   column2=( $(cut -d ',' -f2 "${vulnerabilities2[$counter2]}".csv) )
   column3=( $(cut -d ',' -f3 "${vulnerabilities2[$counter2]}".csv) )
   column4=( $(cut -d ',' -f4 "${vulnerabilities2[$counter2]}".csv) )

  
   #printf "%s\n" "${eCollection[*]}"

   # This counter help to know in which part of the array we are
   counter=1

   for var in "${column1[@]}"
   do	
    #echo "${var}"
    git checkout "${var}" "package.json"

    bool=0
  
    if [ -f package.json ]
    then
      mv "package.json" "${var}".json
      #mkdir "${var}"
      #mv "package.json" /home/ms28/Jens/"${var}"
      # For each line in the file "repositoriesNames.txt" do:
      while IFS= read -r line
      do
       # The file that i am reading conteins the id of the repository separated by one ";" from the url
       # So it is used the split to have in one side the id and in the other the url
       IFS=':' read -r -a linesPackage <<< "$line"
       myString="${linesPackage[1]}"
       prefix=" \""
       suffix="\","
       foo=${myString#"$prefix"}
       foo=${foo%"$suffix"}
       if [[ "$line" == *"${vulnerabilities1[$counter2]}\""* ]]
       then 
        arrayVersion[counter]="${foo}"   
        arrayCommit[counter]="${var}"
        arrayAuthor[counter]="${column2[$counter]}" 
        arrayComment[counter]="${column3[$counter]}"
        arrayDate[counter]="${column4[$counter]}"
        arrayFinal[counter]="${vulnerabilities1[$counter2]}","${foo}","${var}","${column2[$counter]}","${column3[$counter]}","${column4[$counter]}","${github_link}",YES
        bool=1
       fi
       # When it is the last line of "repositoriesNames.txt" it stops reading   
      done < "${var}".json
      rm "${var}".json
      if [ "$bool" = 2 ]
      then
        arrayFinal[counter]="${vulnerabilities1[$counter2]}",,"${var}","${column2[$counter]}","${column3[$counter]}","${column4[$counter]}","${github_link}",NO
      fi 
        bool=1
    fi
    # Increase the counter to analyze next repository
    bool=0
    ((counter++))   
   done

   printf "%s\n" "${arrayFinal[@]}" > "${vulnerabilities2[$counter2]}".txt
   mv "${vulnerabilities2[$counter2]}".txt "${vulnerabilities2[$counter2]}".csv
   mv "${vulnerabilities2[$counter2]}".csv ..
   cd ..
   unset arrayFinal
   sudo rm -r "${vulnerabilities2[$counter2]}"
 fi 
 ((counter2++))
done