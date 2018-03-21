# ATTENTION

# this script must be run from project root
# otherwise the secret will be written in the wrong place

# END OF INSTRUCTIONS

function fallback_to_bash() {
    char_set="[:alnum:]"
    pwd_size=32

    NEW_SECRET=$(cat /dev/urandom | tr -cd "$char_set" | head -c $pwd_size)

    function write_secret() {
        echo "export SECRET_KEY_BASE=$NEW_SECRET" > $PWD/.env
        echo '' > $PWD/.env
    }

    if [ -f $PWD/.env ]
    then
        write_secret
    else
        touch .env
        write_secret
    fi
}

if [ -x $(which ruby) ]
then
    ruby -e "puts 'GENERATING SECRET_KEY_BASE'; sleep 1"
    ruby -e "File.open('./.env', 'w') { |f| f.write('export SECRET_KEY_BASE=' + ([*('A'..'Z'),*('0'..'9'),*('a'..'z')]-%w(0 1 I O)).sample(64).join) }"
else
    fallback_to_bash
fi
