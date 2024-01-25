function leecode(){
    if [ -z "$1" ]; then
        echo "Usage: leecode <new_prob>"
        return 1
    fi
    if [ -e "$1" ]; then
        echo "Directory $1 exists"
    else
        mkdir $1
    fi
    echo "" > $1/answer.py
    echo "" > $1/think.md
    echo "" > $1/try.py
    echo "over."

}