PASSWORD="$1"
THIS_DIR="$( dirname "$( readlink -e "$0" )" )"/'database setup and mock data'/
THAT_DIR=~/'ddd'
rm -r "${THAT_DIR}"
mkdir "${THAT_DIR}"
cp "${THIS_DIR}"/* "${THAT_DIR}"
cd "${THAT_DIR}"
for f in *.csv.zip; do 7za x "$f"; done
mysql -u root -p"${PASSWORD}" <<EndOfFile
drop database 2154_INFSCI_2710_1080_project;
drop user ro@localhost;
drop user rw@localhost;
drop user insert_transaction_group@localhost;
EndOfFile
mysql -u root -p"${PASSWORD}" <<EndOfFile
source SCHEMA.sql;
SHOW WARNINGS;
source PROCEDURES.sql;
SHOW WARNINGS;
source INITIAL_DATA_DUMP.sql;
SHOW WARNINGS;
EndOfFile
rm -r "${THAT_DIR}"
