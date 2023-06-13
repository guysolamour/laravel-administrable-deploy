#!/bin/bash
#------------------------------------------------------------------------------------------------------------------------------>
#---------------------------------------------------- SCAFFOLD ---------------------------------------------------------------->
#------------------------------------------------------------------------------------------------------------------------------>
#------------------------------------------------------------------------------------------------------------------------------>

# ./vendor/bin/deploy scaffold --host 161.97.172.55 --domain aswebagency.com --application aswebagency

#------------------------------------------------------------------------------------------------------------------------------>
#  VERIFIER SI LINSTALLATION NA PAS DEJA ETE FAIT VIA LE FICHIER DEPLOY.SH
#------------------------------------------------------------------------------------------------------------------------------>
if test -f "$STUB_DEPLOY_FILE_PATH"; then
    echoError "Scripts has already been generated. You can start deploying"
    exit 1
fi

#------------------------------------------------------------------------------------------------------------------------------>
#  ON RECUPERE LES OPTIONS POUR LES ASSIGNER DANS DES VARIABLES
#------------------------------------------------------------------------------------------------------------------------------>
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--host)
      OPTION_HOST="$2"
      shift # past argument
      shift # past value
      ;;
    -a|--application)
      OPTION_APPLICATION="$2"
      shift # past argument
      shift # past value
      ;;
    -d|--domain)
      OPTION_DOMAIN="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echoError "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters


#------------------------------------------------------------------------------------------------------------------------------>
#  ON VERIFIE SI L'OPTION --HOST N'EST PAS VIDE CAR OBLIGATOIRE
#------------------------------------------------------------------------------------------------------------------------------>
if [ -z "$OPTION_HOST" ]
then
    echoError "The host option can not be empty. Ex: --host=000.001.002.003"
    exit 1
fi

#------------------------------------------------------------------------------------------------------------------------------>
#  ON VERIFIE SI L'OPTION --APPLICATION N'EST PAS VIDE CAR OBLIGATOIRE
#------------------------------------------------------------------------------------------------------------------------------>
if [ -z "$OPTION_APPLICATION" ]
then
    echoError "The application option can not be empty. Ex: --application=name"
    exit 1
fi

#------------------------------------------------------------------------------------------------------------------------------>
#  ON VERIFIE SI L'OPTION --DOMAIN N'EST PAS VIDE CAR OBLIGATOIRE
#------------------------------------------------------------------------------------------------------------------------------>
if [ -z "$OPTION_DOMAIN" ]
then
    echoError "The domain option can not be empty. Ex: --domain=domain.com"
    exit 1
fi


PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' .  PHP_MINOR_VERSION;")
NODE_VERSION=$(php -r "echo substr(exec('node -v'), 1, 2);")
DATABASE_CONNECTION=$(php artisan tinker --execute="echo config('database.default');")

# echo PHP_VERSION $PHP_VERSION
# echo NODE_VERSION $NODE_VERSION
# echo DATABASE_CONNECTION $DATABASE_CONNECTION
# exit

#------------------------------------------------------------------------------------------------------------------------------>
#  RECUPERER LE MOT DE PASSE A INSERER .VAULTPASS
#------------------------------------------------------------------------------------------------------------------------------>
echo "Give vault code for decrypting password file ?"
read -sp 'Password: ' VAULT_PASSWORD


#------------------------------------------------------------------------------------------------------------------------------>
#  VERIFIER SI LA CHAINE EST VIDE ET THROW UNE ERREUR
#------------------------------------------------------------------------------------------------------------------------------>
if [ -z "$VAULT_PASSWORD" ]
then
  echoError "vault password is required"
  exit 1
fi


#------------------------------------------------------------------------------------------------------------------------------>
#  CREATE TEMPORARY DIRECTORY
#------------------------------------------------------------------------------------------------------------------------------>
echoDefault "Create temporary directory"
mkdir -p $TEMP_DIR

#------------------------------------------------------------------------------------------------------------------------------>
#  COPY DEPLOY.SH AND .VAULTPASS FILES TO CURRENT DIRECTORY
#------------------------------------------------------------------------------------------------------------------------------>
for stub in ${STUBS[@]}; do
  if [ -f "$STUBS_DIR/$stub" ];then
    echo "Copy $(echoSuccess ${stub}) to project directory"
    cp $STUBS_DIR/$stub $PROJECT_DIR/$stub
  fi
done

#------------------------------------------------------------------------------------------------------------------------------>
#  APPEND STUB FILES IN .GITIGNORE FILE
#------------------------------------------------------------------------------------------------------------------------------>
for stub in ${STUBS[@]}; do
  echo "Add $(echoSuccess $stub) to .gitignore file"
  echo $stub >> $PROJECT_DIR/.gitignore
done


#------------------------------------------------------------------------------------------------------------------------------>
#  APPEND PASSWORD TO VAULT FILE
#------------------------------------------------------------------------------------------------------------------------------>
echo $VAULT_PASSWORD > "$PROJECT_DIR/${STUBS[0]}"


#------------------------------------------------------------------------------------------------------------------------------>
#  SEARCH AND REPLACE IN DEPLOY.SH FILE
#------------------------------------------------------------------------------------------------------------------------------>

str_replace "@host" $OPTION_HOST
str_replace "@application" $OPTION_APPLICATION
str_replace "@domain" $OPTION_DOMAIN
str_replace "@whoami" "$(whoami)"
str_replace "@pwd" $PROJECT_DIR
str_replace "@phpversion" $PHP_VERSION
str_replace "@nodeversion" $NODE_VERSION
str_replace "@branch" "$(git config --get init.defaultBranch)"
str_replace "@dbconnection" $DATABASE_CONNECTION

#------------------------------------------------------------------------------------------------------------------------------>
#  COPY .env FILE TO .deploy-env
#------------------------------------------------------------------------------------------------------------------------------>
if [ -f "$PROJECT_DIR/.env" ];then
  cp "$PROJECT_DIR/.env" "$PROJECT_DIR/${STUBS[3]}"
fi

#------------------------------------------------------------------------------------------------------------------------------>
#  READ .deploy-env AND CHANGED SOME LINES FOR PRODUCTION
#------------------------------------------------------------------------------------------------------------------------------>
# gerer le cas de sqlite
while read line; do
    if [[ $line = APP_NAME* ]]; then
      echo '#------------------------------------------------------------------------------------------------------------------------------>'
      echo '#  NE PAS RETIRER LES VARIABLES DONT LES VALEURS CONTIENNENT DES @. ILS SERONT REMPLACEES DYNAMIQUEMENT'
      echo '#------------------------------------------------------------------------------------------------------------------------------>'

      echo 'APP_NAME=@application';
      echo 'APP_FIRST_NAME=@application';
      echo 'APP_LAST_NAME=@application';
      continue
    fi

    if [[ $line = APP_ENV* ]]; then
      echo 'APP_ENV=production'; continue
    fi

    if [[ $line = APP_KEY* ]]; then
      echo "APP_KEY=$(php $PROJECT_DIR/artisan key:generate --show)"; continue
    fi

    if [[ $line = APP_DEBUG* ]]; then
      echo 'APP_DEBUG=false'; continue
    fi

    if [[ $line = APP_URL* ]]; then
      echo 'APP_URL=https://@domain';
      echo ""
      echo "BACKUP_MAIL_TO="
      echo "DKIM_DOMAIN=@domain"
      echo "DKIM_PRIVATE_KEY=@dkimprivatekey"
      continue
    fi

    # verifier si sqlite
    if [[ $line = DB_DATABASE* ]]; then
      echo 'DB_DATABASE=@dbname'; continue
    # elif [[ $DATABASE_CONNECTION == sqlite ]]; then
    #   echo 'DB_DATABASE=@dbname'; continue
    fi

    if [[ $line = DB_USERNAME* ]]; then
      echo 'DB_USERNAME=@dbuser'; continue
    fi

    if [[ $line = DB_PASSWORD* ]]; then
      echo 'DB_PASSWORD=@dbpwd'; continue
    fi

    if [[ $line = MAIL_HOST* ]]; then
      echo 'MAIL_HOST=127.0.0.1'; continue
    fi

    if [[ $line = MAIL_PORT* ]]; then
      echo 'MAIL_PORT=25'; continue
    fi

    # dont add commented line
    if [[ $line = \#* ]]; then
      continue
    fi

    # ajouter le DB_DATABASE si existe pas

    echo $line

done < "$PROJECT_DIR/${STUBS[3]}" >  "$PROJECT_DIR/${STUBS[3]}-temp"

mv "$PROJECT_DIR/${STUBS[3]}-temp" "$PROJECT_DIR/${STUBS[3]}"

# add DB_DATABASE for sqlite if not present
if ! grep -q "DB_DATABASE" "$PROJECT_DIR/${STUBS[3]}"; then
  echo "DB_DATABASE=@dbname" >> "$PROJECT_DIR/${STUBS[3]}"
fi

echoMessage "Deploy scripts generated successfuly."
