DB_USER=""
DB_PASS=""
DB_HOST="hostname:port"
DB_SID=""

# SQL dotaz
SQL_QUERY="SELECT validFrom, status, onetimePwd FROM (SELECT * FROM table ORDER BY idOneTimePassword DESC) otp WHERE rownum = 1;"

# Spuštění dotazu a vrácení výsledku
result=$(echo "$SQL_QUERY" | sqlplus -s $DB_USER/$DB_PASS@$DB_HOST/$DB_SID)

# Výpis výsledku
echo "$result"

$SHELL