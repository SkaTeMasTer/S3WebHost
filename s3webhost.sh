#!/bin/bash
#
# S3WebHost by Shawn Reimerdes
#
# Purpose: Automate Hosting Static Websites on AWS with S3.
#

# *** debug logging ***
LOGGING=1
DEBUG=""
if [ $LOGGING == 1 ]; then                                                                                                                                                                                                                                
		DEBUG="--debug"
fi

AWS_OUTPUT_COLORS="--colors auto"    # enable (auto) for colored output from awscli
AWS_OUTPUT_STYLE="--output table"		 # set default output style

# *** app vars ***
APPNAME="s3webhost"
APPVERSION="1.00"
APPRELEASEDATE="(Oct-1-2016)"


# *** parameters ***

BUCKET_NAME_DEFAULT=""  # $1
DIRECTORY_TO_COPY=""		# $2

# *** aws functions ***
CREATE_BUCKET=""
SYNC_BUCKET=""

AWS_CONFIG_LIST=$(aws configure list)


# *** S3 calls ***
#S3_SYNC_FOLDER=$(aws s3 sync MYFOLDER s3://DOMAINNAME/)
#S3_CHECK_BUCKET=$(aws s3 ls "s3://${BUCKET_NAME}")                                                                                                                                                
#  2>&1
#S3_BUCKET_SIZE=$(aws s3api list-objects --bucket "$BUCKET_NAME" --output json --query "[sum(Contents[].Size), length(Contents[])]" | awk 'NR!=2 {print $0;next} NR==2 {print $0/1024/1024/1024" GB"}')

# *** Route 53 calls ***
#R53_GET_HOSTED_ZONE_COUNT=$(aws route53 get-hosted-zone-count}
#R53_LIST_HOSTED_ZONES=$(aws route53 list-hosted-zones)

#R53_GET_CHANGE=$(aws route53 get-change --id)

IAM_LIST_ACCESSKEYS=$(aws iam list-access-keys)

#
# *** regular vars ***
CURRENT_STEP=1
TOTAL_STEPS=4

BUCKET_NAME=""

# //-----------------------//
# Use colors, but only if connected to a terminal, and that terminal supports them.
color_init() {

  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi
}


# //-----------------------//
show_appversion() {

				printf "\n\n\n${BLUE}[ ${BOLD} $APPNAME ${NORMAL}${BLUE} ] ${GREEN}v$APPVERSION, as of $APPRELEASEDATE; ${RED}by Shawn Reimerdes ${NORMAL}\n\n"
} 


# //-----------------------//
show_welcome() {
 
				printf "${NORMAL}Purpose: ${BOLD}Hosting Static Websites on AWS with S3. ${NORMAL}Elimitate the need for using their web-based admin console (aws.amazon.com) to complete the many steps that this requires and to do so with security in mind.  This automates the tedious, inane and slow procedures by communicating with Amazon's API directly from any local file system with the ${BOLD}'Amazon awscli'${NORMAL} package installed.\n"

} 

# //-----------------------//
show_usage() {

				printf "\nUsage:${RED} $APPNAME [domain_name] [directory_to_copy]${NORMAL}
		
For example:\n${GREEN}
\t s3webhost newdomain.net .
\t s3webhost xdomain.com /public_html/
\t s3webhost ydomain.me C:/webapps/ydomain.com/public_html/\n${NORMAL}\n"
 
}

# // ==============[ S3 ] ============================

# //-----------------------//
check_s3_bucket_exists() {

echo "Checking S3 bucket exists..."                                                                                                                                                                                                           
BUCKET_EXISTS=true                                                                                                                                                                                                                            
S3_CHECK=$(aws s3 ls "s3://${BUCKET_NAME}" 2>&1)                                                                                                                                                 

#Some sort of error happened with s3 check                                                                                                                                                                                                    
if [ $? != 0 ]                                                                                                                                                                                                                                
then                                                                                                                                                                                                                                          
  NO_BUCKET_CHECK=$(echo $S3_CHECK | grep -c 'NoSuchBucket')                                                                                                                                                                                     
  if [ $NO_BUCKET_CHECK = 1 ]; then                                                                                                                                                                                                              
    echo "Bucket does not exist"                                                                                                                                                                                                              
    BUCKET_EXISTS=false                                                                                                                                                                                                                       
  else                                                                                                                                                                                                                                        
    echo "Error checking S3 Bucket"                                                                                                                                                                                                           
    echo "$S3_CHECK"                                                                                                                                                                                                                          
    exit 1                                                                                                                                                                                                                                    
  fi 
else                                                                                                                                                                                                                                         
  echo "Bucket exists"
fi    
} 

# //-----------------------//
show_r53_change_status() {

#R53_GET_CHANGE="aws route53 get-change --id" 
# get the status of a change to resource record sets

				printf "\nStatus of changes: ${BLUE}[ ${BOLD} --- ${NORMAL}${BLUE} ]\n"
} 

# //-----------------------//
show_r53_total_host_count() {

#R53_GET_HOSTED_ZONE_COUNT

				printf "\nTotal hosted zones: ${BLUE}[ ${BOLD} 90 ${NORMAL}${BLUE} ]\n"
} 

# //-----------------------//
get_r53_hostedzone() {

#R53_GET_HOSTED_ZONE_COUNT

				printf "\nId: ${BLUE}[ ${BOLD} 453ertreE ${NORMAL}${BLUE} ]\n"
} 
# //-----------------------//
verify_valid_bucketname() {

printf ""
}

# //-----------------------//
verify_valid_domainname() {
printf ""
}

# //-----------------------//
ask_for_bucketname() {

		printf "   __ _ ______  ________ _______________________  _______ ___ ___ _\n"

		printf " \t${BLUE}[[[ STEP # $CURRENT_STEP of $TOTAL_STEPS ]]] -- ${BOLD}NAME YOUR S3 BUCKET AS YOUR DOMAIN${NORMAL}\n"
		printf "   __ _ ______  ________ _______________________  _______ ___ ___ _\n\n"		
		printf "It is recommended that you ${BOLD}give your bucket the same name as your domain name${NORMAL}.
		
We automatically add a bucket for the 'www.' prefix for your site.
		
For example:\n
\t ${GREEN}correct: ${BOLD}newdomain.net ${NORMAL}
\t ${GREEN}correct: ${BOLD}website-newdomain.net 	${NORMAL}	
\t ${RED}incorrect: ${BOLD}www.newdomain.net${NORMAL}
\t ${RED}incorrect: ${BOLD}http://newdomain.net${NORMAL}\n"
		
					if [ "BUCKET_NAME_DEFAULT" == "" ] & [ "DIRECTORY_TO_COPY" == "" ]; then
                printf "${BOLD}${YELLOW}NOTE: Run with the optional parameters to avoid some of these questions.${NORMAL}"
          fi

					# question: domain name
					  printf  "\n${NORMAL}\t => Please enter desired bucket name (domain name): "
							  read bucket_name_user
						
										  
					# question: domain confirmtion
					  printf  "\n${NORMAL}\t => You have selected the domain name: ${BOLD}${YELLOW}$bucket_name_user	\n\n ${NORMAL}Is this correct [Y/n]:${NORMAL} "
					  read confirmation
					  if [ "$confirmation" != "y" ] | [ "$confirmation" != "Y" ] | [ "$confirmation" != "" ]; then
					    quitnow
					   
					  fi
 

		CURRENT_STEP=CURRENT_STEP+1
}

# //-----------------------//
show_iam_notice() {

		printf "\n   __ _ ______  ________ _______________________  _______ ___ ___ _\n"

		printf " \t${BLUE}[[[ STEP # $CURRENT_STEP of $TOTAL_STEPS ]]] -- ${BOLD}CONFIRM CORRECT IAM CREDENTIALS${NORMAL}\n"
		printf "   __ _ ______  ________ _______________________  _______ ___ ___ _\n"	
		
		printf "${BOLD}IAM is used to separate users & groups from the actions they need to perform.${NORMAL}

${BOLD}SECURITY NOTE${NORMAL}: default access keys ${BOLD}may have${NORMAL} more permissions then necessary! 

You can have multiple ${BOLD}named profiles${NORMAL} in addition to the ${BOLD}default profile${NORMAL} allowing you 
to easily choose which account before running this script.

${BOLD}${RED}If you have NOT already configured a named profile, you may want to consider so before continuing...${NORMAL}

   [+] create a new profile, quit and run: '${BOLD}${RED}aws configure --profile usernamehere${NORMAL}'

 ____________________
   ${BOLD}List of Profiles${NORMAL}
 ____________________
"
# Using them to authorize creation of new S3 sites, may pose a ${BOLD}potential security risk${NORMAL}.

#We are using the ${BOLD}access key${NORMAL} and ${BOLD}secret key${NORMAL} stored in your ${BOLD}AWS_ACCESS_KEY_ID${NORMAL} and${BOLD}AWS_SECRET_ACCESS_KEY${NORMAL} environment variables. 

# https://oliverhelm.me/sys-admin/updating-aws-dns-records-from-cli
RESULTS=$(printf "$AWS_CONFIG_LIST")
echo  "${GREEN}$RESULTS${NORMAL}"

RESULTS=$(printf "$IAM_LIST_ACCESSKEYS --output table --color auto")
echo  "${GREEN}$RESULTS${NORMAL}"


				# question: IAM credential warning
				  printf  "\n   => Continue authorizing with the above IAM credentials? [Y/n]:${NORMAL} "
				#  read confirmation
					if [ "$confirmation" != "y" ] | [ "$confirmation" != "Y" ] | [ "$confirmation" != "" ]; then
				    quitnow
				   
				  fi 
				  
				  
		CURRENT_STEP=CURRENT_STEP+1
}

# //-----------------------//
show_route53_notice() {
			printf "\n"
}

# //-----------------------//
show_finished_notice() {
			printf "\n"
}

# //-----------------------//
quitnow() {

				printf "\n\n${RED}Bye-bye... ${BOLD}${YELLOW}quiting...\n\n${NORMAL}"
				exit
}


# ============================================================================
# MAIN 
# ============================================================================

set -e # enable exit-on-error after the non-critical colorization stuff (may fail if lacking tput or terminfo)

# run our custom functions
color_init
show_appversion
show_welcome



# question: if no parameter passed, then ask for it
  if [ "$1" == "" ]; then
    show_usage
    ask_for_bucketname
    
  fi

show_iam_notice

 
   
